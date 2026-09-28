#!/usr/bin/env bash
# Install one user-level instruction source for Claude Code, Codex and
# OpenCode, or delegate project setup to setup-project.sh.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
INSTALL_GLOBAL=false
UNINSTALL=false
PROJECT_PATH=""
BACKUP_SUFFIX=".before-instruction-links.$(date +%Y%m%d%H%M%S)"

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
        --global)
            INSTALL_GLOBAL=true
            ;;
        --project)
            shift
            if [[ $# -eq 0 ]]; then
                err "--project requires a directory"
                exit 2
            fi
            PROJECT_PATH="$1"
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --uninstall)
            UNINSTALL=true
            ;;
        --help|-h)
            echo "Usage: $0 [--global] [--project DIR] [--dry-run] [--uninstall]"
            echo ""
            echo "  --global       Create one user-level source and three CLI symlinks"
            echo "  --project DIR  Link Claude Code to the AGENTS.md in DIR"
            echo "  --dry-run      Print intended changes without writing"
            echo "  --uninstall    Remove user-level links and restore installer backups"
            exit 0
            ;;
        *)
            err "Unknown argument: $1"
            exit 2
            ;;
    esac
    shift
done

if ! $INSTALL_GLOBAL && ! $UNINSTALL && [[ -z "$PROJECT_PATH" ]]; then
    err "Choose --global, --project DIR or --uninstall"
    exit 2
fi

if $UNINSTALL && { $INSTALL_GLOBAL || [[ -n "$PROJECT_PATH" ]]; }; then
    err "--uninstall cannot be combined with --global or --project"
    exit 2
fi

GLOBAL_DIR="$HOME/.agents-global"
GLOBAL_FILE="$GLOBAL_DIR/AGENTS.md"
EXAMPLE_FILE="$REPO_DIR/AGENTS.md.example"
CLI_LINKS=(
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.codex/AGENTS.md"
    "$HOME/.config/opencode/AGENTS.md"
)

latest_backup() {
    local target="$1"
    find "$(dirname "$target")" -maxdepth 1 \
        -name "$(basename "$target").before-instruction-links.*" -print 2>/dev/null \
        | sort -r | head -1 || true
}

install_link() {
    local target="$1"
    local current=""

    if [[ -L "$target" ]]; then
        current="$(readlink "$target")"
        if [[ "$current" == "$GLOBAL_FILE" ]]; then
            info "Already linked: $target"
            return
        fi
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        if $DRY_RUN; then
            info "Would move existing path: $target -> ${target}${BACKUP_SUFFIX}"
        else
            mv "$target" "${target}${BACKUP_SUFFIX}"
            ok "Saved existing path: ${target}${BACKUP_SUFFIX}"
        fi
    fi

    if $DRY_RUN; then
        info "Would link: $target -> $GLOBAL_FILE"
    else
        mkdir -p "$(dirname "$target")"
        ln -s "$GLOBAL_FILE" "$target"
        ok "Linked: $target -> $GLOBAL_FILE"
    fi
}

if $UNINSTALL; then
    for target in "${CLI_LINKS[@]}"; do
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$GLOBAL_FILE" ]]; then
            backup="$(latest_backup "$target")"
            if $DRY_RUN; then
                info "Would remove link: $target"
                [[ -n "$backup" ]] && info "Would restore: $backup -> $target"
            else
                rm "$target"
                ok "Removed link: $target"
                if [[ -n "$backup" ]]; then
                    mv "$backup" "$target"
                    ok "Restored: $target"
                fi
            fi
        elif [[ -e "$target" || -L "$target" ]]; then
            warn "Kept unrelated path: $target"
        fi
    done
    info "Kept user instruction source: $GLOBAL_FILE"
    exit 0
fi

if $INSTALL_GLOBAL; then
    if [[ -f "$GLOBAL_FILE" ]]; then
        info "Preserving existing source: $GLOBAL_FILE"
    elif [[ -e "$GLOBAL_FILE" || -L "$GLOBAL_FILE" ]]; then
        err "Expected a regular file or no path at $GLOBAL_FILE"
        exit 1
    elif $DRY_RUN; then
        info "Would create: $GLOBAL_FILE from $EXAMPLE_FILE"
    else
        mkdir -p "$GLOBAL_DIR"
        cp "$EXAMPLE_FILE" "$GLOBAL_FILE"
        ok "Created: $GLOBAL_FILE"
    fi

    for target in "${CLI_LINKS[@]}"; do
        install_link "$target"
    done
fi

if [[ -n "$PROJECT_PATH" ]]; then
    if $DRY_RUN; then
        bash "$REPO_DIR/setup-project.sh" --dry-run "$PROJECT_PATH"
    else
        bash "$REPO_DIR/setup-project.sh" "$PROJECT_PATH"
    fi
fi
