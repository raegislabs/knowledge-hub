#!/usr/bin/env bash
#
# Safe Database Migration Wrapper
#
# Wraps SQL migrations with automatic backup, transaction support, and rollback
#
# Usage:
#   ./db-migrate-safe.sh <migration.sql> [--dry-run]
#

set -euo pipefail

# Configuration
DB_PATH="${BMAD_DB_PATH:-$HOME/.bmad/workflow.db}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
MIGRATION_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 <migration.sql> [--dry-run]"
            echo ""
            echo "Safe migration wrapper that:"
            echo "  1. Creates automatic backup"
            echo "  2. Runs migration in transaction"
            echo "  3. Verifies integrity after migration"
            echo "  4. Auto-rolls back on failure"
            echo ""
            echo "Options:"
            echo "  --dry-run    Test migration without applying changes"
            exit 0
            ;;
        *)
            MIGRATION_FILE="$1"
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$MIGRATION_FILE" ]]; then
    echo -e "${RED}❌ Error: Migration file required${NC}"
    echo "Usage: $0 <migration.sql> [--dry-run]"
    exit 1
fi

if [[ ! -f "$MIGRATION_FILE" ]]; then
    echo -e "${RED}❌ Migration file not found: $MIGRATION_FILE${NC}"
    exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
    echo -e "${RED}❌ Database not found: $DB_PATH${NC}"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "  Safe Database Migration"
echo "═══════════════════════════════════════════════════════════════"
echo "Migration: $(basename "$MIGRATION_FILE")"
echo "Database: $DB_PATH"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE")"
echo ""

# Step 1: Create backup (always, even for dry-run)
echo "📦 Step 1: Creating backup..."
BACKUP_OUTPUT=$("$SCRIPT_DIR/db-backup-safe.sh" 2>&1)
BACKUP_FILE=$(echo "$BACKUP_OUTPUT" | grep "BACKUP_FILE=" | cut -d= -f2)

if [[ -z "$BACKUP_FILE" ]]; then
    echo -e "${RED}❌ Backup failed${NC}"
    echo "$BACKUP_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"
echo ""

# Step 2: Get current state
echo "📊 Step 2: Recording current state..."
BEFORE_PROJECTS=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "0")
BEFORE_EPICS=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM epics;" 2>/dev/null || echo "0")
BEFORE_STORIES=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM stories;" 2>/dev/null || echo "0")

echo "   Projects: $BEFORE_PROJECTS"
echo "   Epics: $BEFORE_EPICS"
echo "   Stories: $BEFORE_STORIES"
echo ""

# Step 3: Validate migration SQL
echo "🔍 Step 3: Validating migration SQL..."
if grep -qi "DROP TABLE" "$MIGRATION_FILE"; then
    echo -e "${YELLOW}⚠️  Warning: Migration contains DROP TABLE${NC}"
fi

if ! grep -qi "BEGIN\|BEGIN TRANSACTION" "$MIGRATION_FILE"; then
    echo -e "${YELLOW}⚠️  Warning: Migration doesn't use transactions, wrapping automatically${NC}"
    USE_TRANSACTION=true
else
    USE_TRANSACTION=false
fi

# Step 4: Apply migration
if [[ "$DRY_RUN" = true ]]; then
    echo -e "${YELLOW}🧪 Step 4: DRY RUN - Testing migration on backup copy...${NC}"

    # Create temp copy for dry run
    TEMP_DB="/tmp/workflow-dryrun-$$.db"
    cp "$DB_PATH" "$TEMP_DB"

    # Run migration on temp copy
    if [[ "$USE_TRANSACTION" = true ]]; then
        (
            echo "BEGIN TRANSACTION;"
            cat "$MIGRATION_FILE"
            echo "COMMIT;"
        ) | sqlite3 "$TEMP_DB" 2>&1 && MIGRATION_STATUS=0 || MIGRATION_STATUS=$?
    else
        sqlite3 "$TEMP_DB" < "$MIGRATION_FILE" 2>&1 && MIGRATION_STATUS=0 || MIGRATION_STATUS=$?
    fi

    if [[ $MIGRATION_STATUS -eq 0 ]]; then
        echo -e "${GREEN}✅ Dry run successful${NC}"

        # Show what would change
        AFTER_PROJECTS=$(sqlite3 "$TEMP_DB" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "0")
        AFTER_EPICS=$(sqlite3 "$TEMP_DB" "SELECT COUNT(*) FROM epics;" 2>/dev/null || echo "0")
        AFTER_STORIES=$(sqlite3 "$TEMP_DB" "SELECT COUNT(*) FROM stories;" 2>/dev/null || echo "0")

        echo ""
        echo "📊 Projected changes:"
        echo "   Projects: $BEFORE_PROJECTS → $AFTER_PROJECTS"
        echo "   Epics: $BEFORE_EPICS → $AFTER_EPICS"
        echo "   Stories: $BEFORE_STORIES → $AFTER_STORIES"

        echo ""
        echo -e "${GREEN}✅ Migration validated - safe to run without --dry-run${NC}"
    else
        echo -e "${RED}❌ Dry run FAILED - migration has errors${NC}"
        echo "Fix the migration and try again"
    fi

    # Cleanup
    rm -f "$TEMP_DB"
    exit $MIGRATION_STATUS

else
    echo "🚀 Step 4: Applying migration to live database..."

    # Apply with transaction wrapper if needed
    if [[ "$USE_TRANSACTION" = true ]]; then
        (
            echo "BEGIN TRANSACTION;"
            cat "$MIGRATION_FILE"
            echo "COMMIT;"
        ) | sqlite3 "$DB_PATH" 2>&1 && MIGRATION_STATUS=0 || MIGRATION_STATUS=$?
    else
        sqlite3 "$DB_PATH" < "$MIGRATION_FILE" 2>&1 && MIGRATION_STATUS=0 || MIGRATION_STATUS=$?
    fi

    if [[ $MIGRATION_STATUS -ne 0 ]]; then
        echo -e "${RED}❌ Migration FAILED${NC}"
        echo ""
        echo "🔄 Attempting automatic rollback..."

        # Restore from backup
        cp "$BACKUP_FILE" "$DB_PATH"

        # Verify restore
        if sqlite3 "$DB_PATH" "PRAGMA integrity_check;" | grep -q "ok"; then
            echo -e "${GREEN}✅ Database restored from backup${NC}"
            echo "   Backup: $BACKUP_FILE"
        else
            echo -e "${RED}❌ CRITICAL: Restore failed, database may be corrupted${NC}"
            echo "   Manual restore needed: cp $BACKUP_FILE $DB_PATH"
        fi

        exit 1
    fi

    echo -e "${GREEN}✅ Migration applied successfully${NC}"
fi

# Step 5: Verify integrity
echo ""
echo "🔍 Step 5: Verifying database integrity..."
if sqlite3 "$DB_PATH" "PRAGMA integrity_check;" | grep -q "ok"; then
    echo -e "${GREEN}✅ Integrity check passed${NC}"
else
    echo -e "${RED}❌ CRITICAL: Integrity check FAILED${NC}"
    echo "Restoring from backup..."
    cp "$BACKUP_FILE" "$DB_PATH"
    exit 1
fi

# Step 6: Verify counts
echo ""
echo "📊 Step 6: Verifying data..."
AFTER_PROJECTS=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "0")
AFTER_EPICS=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM epics;" 2>/dev/null || echo "0")
AFTER_STORIES=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM stories;" 2>/dev/null || echo "0")

echo "   Before → After:"
echo "   Projects: $BEFORE_PROJECTS → $AFTER_PROJECTS"
echo "   Epics: $BEFORE_EPICS → $AFTER_EPICS"
echo "   Stories: $BEFORE_STORIES → $AFTER_STORIES"

# Warn if data decreased unexpectedly
if [[ $AFTER_PROJECTS -lt $BEFORE_PROJECTS ]] || \
   [[ $AFTER_EPICS -lt $BEFORE_EPICS ]] || \
   [[ $AFTER_STORIES -lt $BEFORE_STORIES ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: Record counts decreased${NC}"
    echo "If this was unintentional, restore from backup:"
    echo "  cp $BACKUP_FILE $DB_PATH"
fi

# Success
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Migration completed successfully${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo "Backup: $BACKUP_FILE"
echo ""
