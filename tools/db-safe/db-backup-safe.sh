#!/usr/bin/env bash
#
# Safe Database Backup Script
#
# Creates timestamped backups with WAL checkpoint and retention management
#
# Usage:
#   ./db-backup-safe.sh [--keep-days N] [--db-path PATH]
#

set -euo pipefail

# Default configuration
DB_PATH="${BMAD_DB_PATH:-$HOME/.bmad/workflow.db}"
BACKUP_DIR="$HOME/.bmad/backups"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-7}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-days)
            KEEP_DAYS="$2"
            shift 2
            ;;
        --db-path)
            DB_PATH="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--keep-days N] [--db-path PATH]"
            echo ""
            echo "Options:"
            echo "  --keep-days N    Keep backups for N days (default: 7)"
            echo "  --db-path PATH   Database path (default: ~/.bmad/workflow.db)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate database exists
if [[ ! -f "$DB_PATH" ]]; then
    echo "❌ Database not found: $DB_PATH"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup filename
BACKUP_FILE="$BACKUP_DIR/workflow.db.backup-$TIMESTAMP"

# CRITICAL: Checkpoint WAL to ensure backup consistency
# This forces all WAL changes into the main database file
echo "🔄 Checkpointing WAL..."
sqlite3 "$DB_PATH" "PRAGMA wal_checkpoint(TRUNCATE);" 2>&1 || {
    echo "⚠️  Warning: WAL checkpoint failed, backup may be inconsistent"
}

# Create backup with verification
echo "💾 Creating backup: $BACKUP_FILE"
cp "$DB_PATH" "$BACKUP_FILE"

# Verify backup integrity
echo "✅ Verifying backup integrity..."
if sqlite3 "$BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    echo "✅ Backup verified: $BACKUP_FILE"

    # Get counts for verification
    PROJECTS=$(sqlite3 "$BACKUP_FILE" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "0")
    EPICS=$(sqlite3 "$BACKUP_FILE" "SELECT COUNT(*) FROM epics;" 2>/dev/null || echo "0")
    STORIES=$(sqlite3 "$BACKUP_FILE" "SELECT COUNT(*) FROM stories;" 2>/dev/null || echo "0")

    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

    echo "📊 Backup contents:"
    echo "   Projects: $PROJECTS"
    echo "   Epics: $EPICS"
    echo "   Stories: $STORIES"
    echo "   Size: $SIZE"
else
    echo "❌ Backup verification FAILED - backup may be corrupted"
    exit 1
fi

# Cleanup old backups
if [[ "$KEEP_DAYS" -gt 0 ]]; then
    echo "🧹 Cleaning up backups older than $KEEP_DAYS days..."
    find "$BACKUP_DIR" -name "workflow.db.backup-*" -type f -mtime +"$KEEP_DAYS" -delete

    REMAINING=$(find "$BACKUP_DIR" -name "workflow.db.backup-*" -type f | wc -l | tr -d ' ')
    echo "📦 $REMAINING backups remaining"
fi

# Export backup path for use in scripts
echo "BACKUP_FILE=$BACKUP_FILE"
