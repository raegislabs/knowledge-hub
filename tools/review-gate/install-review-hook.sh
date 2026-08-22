#!/usr/bin/env bash
# ============================================================================
# install-review-hook.sh — Install the Codex pre-push review hook
# ============================================================================
# Installs the pre-push code review hook into any git repository.
# Can be run from the framework repo or from a target project.
#
# Usage:
#   # From target project directory:
#   /path/to/this/repo/tools/review-gate/install-review-hook.sh
#
#   # Or with explicit target:
#   install-review-hook.sh --target ~/projects/my-project
#
#   # Dry run:
#   scripts/install-review-hook.sh --dry-run
#
#   # Uninstall:
#   scripts/install-review-hook.sh --uninstall
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- Locate the canonical script ---
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANONICAL_SCRIPT="${INSTALLER_DIR}/pre-push-review.sh"

# --- Parse args ---
TARGET_DIR=""
DRY_RUN=0
UNINSTALL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)    TARGET_DIR="$2"; shift 2 ;;
        --dry-run)   DRY_RUN=1; shift ;;
        --uninstall) UNINSTALL=1; shift ;;
        -h|--help)
            echo "Usage: install-review-hook.sh [--target DIR] [--dry-run] [--uninstall]"
            echo ""
            echo "Installs the Codex pre-push review hook into a git repository."
            echo ""
            echo "Options:"
            echo "  --target DIR   Target repo directory (default: current directory)"
            echo "  --dry-run      Show what would be done without doing it"
            echo "  --uninstall    Remove the hook and config"
            exit 0
            ;;
        *)           shift ;;
    esac
done

# --- Resolve target ---
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$(pwd)"
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Verify it's a git repo
if ! git -C "$TARGET_DIR" rev-parse --show-toplevel &>/dev/null; then
    echo -e "${RED}Error: ${TARGET_DIR} is not a git repository${NC}"
    exit 1
fi

REPO_ROOT="$(git -C "$TARGET_DIR" rev-parse --show-toplevel)"
HOOKS_DIR="${REPO_ROOT}/.git/hooks"
SCRIPTS_DIR="${REPO_ROOT}/scripts"
HOOK_FILE="${HOOKS_DIR}/pre-push"
SCRIPT_FILE="${SCRIPTS_DIR}/pre-push-review.sh"
CONFIG_FILE="${REPO_ROOT}/.codex-review.conf"

# --- Uninstall ---
if [[ "$UNINSTALL" == "1" ]]; then
    echo -e "${BOLD}Uninstalling Codex review hook from ${REPO_ROOT}${NC}"

    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "${BLUE}  [dry-run] Would remove: ${HOOK_FILE}${NC}"
        echo -e "${BLUE}  [dry-run] Would remove: ${SCRIPT_FILE}${NC}"
        echo -e "${BLUE}  [dry-run] Would keep:   ${CONFIG_FILE} (manual removal)${NC}"
    else
        rm -f "$HOOK_FILE" && echo -e "${GREEN}  Removed: ${HOOK_FILE}${NC}" || true
        rm -f "$SCRIPT_FILE" && echo -e "${GREEN}  Removed: ${SCRIPT_FILE}${NC}" || true
        echo -e "${YELLOW}  Kept: ${CONFIG_FILE} (remove manually if desired)${NC}"
    fi
    echo -e "${GREEN}Done.${NC}"
    exit 0
fi

# --- Verify canonical script exists ---
if [[ ! -f "$CANONICAL_SCRIPT" ]]; then
    echo -e "${RED}Error: Canonical script not found at ${CANONICAL_SCRIPT}${NC}"
    echo -e "${YELLOW}Expected to find pre-push-review.sh in the same directory as this installer.${NC}"
    exit 1
fi

# --- Install ---
echo -e "${BOLD}Installing Codex pre-push review hook${NC}"
echo -e "${BLUE}  Source: ${CANONICAL_SCRIPT}${NC}"
echo -e "${BLUE}  Target: ${REPO_ROOT}${NC}"
echo ""

# 1. Copy the review script to target's scripts/ directory
if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "${BLUE}  [dry-run] Would create: ${SCRIPTS_DIR}/${NC}"
    echo -e "${BLUE}  [dry-run] Would copy:   ${CANONICAL_SCRIPT} → ${SCRIPT_FILE}${NC}"
else
    mkdir -p "$SCRIPTS_DIR"
    cp "$CANONICAL_SCRIPT" "$SCRIPT_FILE"
    chmod +x "$SCRIPT_FILE"
    echo -e "${GREEN}  Copied: ${SCRIPT_FILE}${NC}"
fi

# 2. Create the git hook (thin wrapper)
HOOK_CONTENT='#!/usr/bin/env bash
# Git pre-push hook — delegates to scripts/pre-push-review.sh
# Installed by: agent-orchestration-framework/scripts/install-review-hook.sh
# To bypass: git push --no-verify

REPO_ROOT="$(git rev-parse --show-toplevel)"
REVIEW_SCRIPT="${REPO_ROOT}/scripts/pre-push-review.sh"

if [[ -f "$REVIEW_SCRIPT" ]]; then
    exec "$REVIEW_SCRIPT" "$@"
else
    echo "[pre-push] Review script not found at ${REVIEW_SCRIPT}. Skipping."
    exit 0
fi'

if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "${BLUE}  [dry-run] Would create: ${HOOK_FILE}${NC}"
else
    # Check for existing pre-push hook
    if [[ -f "$HOOK_FILE" ]]; then
        echo -e "${YELLOW}  Existing pre-push hook found. Backing up to ${HOOK_FILE}.bak${NC}"
        cp "$HOOK_FILE" "${HOOK_FILE}.bak"
    fi

    echo "$HOOK_CONTENT" > "$HOOK_FILE"
    chmod +x "$HOOK_FILE"
    echo -e "${GREEN}  Created: ${HOOK_FILE}${NC}"
fi

# 3. Create config template if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    CONFIG_CONTENT='# Codex Pre-Push Review Configuration
# =====================================
# Sourced by scripts/pre-push-review.sh
# All values are optional — unset values inherit from ~/.codex/config.toml

# Model override (leave empty to use ~/.codex/config.toml default)
# CODEX_REVIEW_MODEL=""

# Reasoning effort override (leave empty to use ~/.codex/config.toml default)
# CODEX_REVIEW_EFFORT=""

# Protected branches that require review (space-separated)
CODEX_REVIEW_BRANCHES="main"

# Max diff lines before showing a warning (review still runs)
CODEX_REVIEW_MAX_DIFF=2000

# Timeout in seconds (default: 300 = 5 minutes)
CODEX_REVIEW_TIMEOUT=300

# Set to "1" to disable review entirely for this project
# CODEX_REVIEW_SKIP=0

# Set to "0" to disable local audit logging
# CODEX_REVIEW_LOG=1'

    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "${BLUE}  [dry-run] Would create: ${CONFIG_FILE}${NC}"
    else
        echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
        echo -e "${GREEN}  Created: ${CONFIG_FILE}${NC}"
    fi
else
    echo -e "${YELLOW}  Kept existing: ${CONFIG_FILE}${NC}"
fi

# 4. Ensure .codex-review-log/ is in .gitignore
GITIGNORE="${REPO_ROOT}/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if ! grep -qF '.codex-review-log/' "$GITIGNORE" 2>/dev/null; then
        if [[ "$DRY_RUN" == "1" ]]; then
            echo -e "${BLUE}  [dry-run] Would add '.codex-review-log/' to ${GITIGNORE}${NC}"
        else
            echo '.codex-review-log/' >> "$GITIGNORE"
            echo -e "${GREEN}  Added '.codex-review-log/' to .gitignore${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}Installation complete!${NC}"
echo ""
echo -e "  ${BOLD}How it works:${NC}"
echo -e "    git push → pre-push hook → codex reviews diff → PASS/FAIL"
echo ""
echo -e "  ${BOLD}Configuration:${NC} ${CONFIG_FILE}"
echo -e "  ${BOLD}Bypass once:${NC}  git push --no-verify"
echo -e "  ${BOLD}Disable:${NC}      CODEX_REVIEW_SKIP=1 git push"
echo -e "  ${BOLD}Uninstall:${NC}    $(basename "$0") --target ${REPO_ROOT} --uninstall"
