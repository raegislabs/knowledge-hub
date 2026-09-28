#!/usr/bin/env bash
# Make a project's root AGENTS.md the single instruction source.
# Codex and OpenCode read the root AGENTS.md directly; Claude Code gets a
# .claude/CLAUDE.md symlink to it.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
REMOVE=false
PROJECT_DIR=""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[info]${NC}  $1"; }
ok() { echo -e "${GREEN}[ok]${NC}    $1"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $1"; }
err() { echo -e "${RED}[error]${NC} $1" >&2; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --remove) REMOVE=true ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--remove] [PROJECT_DIR]"
            exit 0
            ;;
        -*)
            err "Unknown flag: $1"
            exit 2
            ;;
        *)
            if [[ -n "$PROJECT_DIR" ]]; then
                err "Only one project directory may be supplied"
                exit 2
            fi
            PROJECT_DIR="$1"
            ;;
    esac
    shift
done

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
if [[ ! -d "$PROJECT_DIR" ]]; then
    err "Project directory does not exist: $PROJECT_DIR"
    exit 1
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
SOURCE_FILE="$PROJECT_DIR/AGENTS.md"

LINK_PATHS=(
    "$PROJECT_DIR/.claude/CLAUDE.md"
)
LINK_TARGETS=(
    "../AGENTS.md"
)
IGNORE_ENTRIES=(
    ".claude/CLAUDE.md"
)

if $REMOVE; then
    for index in "${!LINK_PATHS[@]}"; do
        link="${LINK_PATHS[$index]}"
        expected="${LINK_TARGETS[$index]}"
        if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$expected" ]]; then
            if $DRY_RUN; then
                info "Would remove: $link"
            else
                rm "$link"
                ok "Removed: $link"
            fi
        elif [[ -e "$link" || -L "$link" ]]; then
            warn "Kept unrelated path: $link"
        fi
    done

    if ! $DRY_RUN; then
        rmdir "$PROJECT_DIR/.claude" 2>/dev/null || true
    fi
    info "AGENTS.md and .gitignore entries were kept."
    exit 0
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
    err "Missing $SOURCE_FILE"
    echo "Copy and edit the template first:" >&2
    echo "  cp $SCRIPT_DIR/project-AGENTS.md.example $SOURCE_FILE" >&2
    exit 1
fi

for index in "${!LINK_PATHS[@]}"; do
    link="${LINK_PATHS[$index]}"
    expected="${LINK_TARGETS[$index]}"
    if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$expected" ]]; then
        info "Already linked: $link"
    elif [[ -e "$link" || -L "$link" ]]; then
        warn "Kept existing path: $link"
    elif $DRY_RUN; then
        info "Would link: $link -> $expected"
    else
        mkdir -p "$(dirname "$link")"
        ln -s "$expected" "$link"
        ok "Linked: $link -> $expected"
    fi
done

GITIGNORE="$PROJECT_DIR/.gitignore"
for entry in "${IGNORE_ENTRIES[@]}"; do
    if ! grep -qFx "$entry" "$GITIGNORE" 2>/dev/null; then
        if $DRY_RUN; then
            info "Would add to .gitignore: $entry"
        else
            if [[ ! -s "$GITIGNORE" ]]; then
                printf '%s\n' '# Local instruction symlink' > "$GITIGNORE"
            elif ! grep -qF '# Local instruction symlink' "$GITIGNORE"; then
                printf '\n%s\n' '# Local instruction symlink' >> "$GITIGNORE"
            fi
            printf '%s\n' "$entry" >> "$GITIGNORE"
        fi
    fi
done

$DRY_RUN || ok "Project links configured."
