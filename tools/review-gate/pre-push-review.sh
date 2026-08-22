#!/usr/bin/env bash
# ============================================================================
# pre-push-review.sh — Local Codex code review before push
# ============================================================================
# Runs a Codex code review on changes being pushed to protected branches.
# Replaces GitHub Actions-based reviews — enforced at the developer machine.
#
# Install:  scripts/install-review-hook.sh   (from agent-orchestration-framework)
# Manual:   scripts/pre-push-review.sh [--skip] [--model MODEL] [--effort EFFORT]
#
# Configuration (env vars or .codex-review.conf):
#   CODEX_REVIEW_MODEL        — Model override (default: from ~/.codex/config.toml)
#   CODEX_REVIEW_EFFORT       — Reasoning effort override (default: from config.toml)
#   CODEX_REVIEW_BRANCHES     — Space-separated protected branches (default: "main master")
#   CODEX_REVIEW_SKIP         — Set to "1" to skip review
#   CODEX_REVIEW_MAX_DIFF     — Max diff lines before warning (default: 2000)
#   CODEX_REVIEW_TIMEOUT      — Timeout in seconds (default: 300)
#   CODEX_REVIEW_LOG          — Set to "0" to disable audit logging (default: "1")
# ============================================================================

set -uo pipefail
# Note: -e intentionally omitted — we handle errors explicitly to avoid
# premature exits from git/wc pipeline failures.

# --- Colors (disabled if not a terminal) ---
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# --- Load project-level config if present ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || dirname "$SCRIPT_DIR")"
CONFIG_FILE="${REPO_ROOT}/.codex-review.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# --- Defaults (inherit from ~/.codex/config.toml unless overridden) ---
CODEX_REVIEW_MODEL="${CODEX_REVIEW_MODEL:-}"
CODEX_REVIEW_EFFORT="${CODEX_REVIEW_EFFORT:-}"
CODEX_REVIEW_BRANCHES="${CODEX_REVIEW_BRANCHES:-main master}"
CODEX_REVIEW_SKIP="${CODEX_REVIEW_SKIP:-0}"
CODEX_REVIEW_MAX_DIFF="${CODEX_REVIEW_MAX_DIFF:-2000}"
CODEX_REVIEW_TIMEOUT="${CODEX_REVIEW_TIMEOUT:-300}"
CODEX_REVIEW_LOG="${CODEX_REVIEW_LOG:-1}"

# --- Parse CLI args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip)       CODEX_REVIEW_SKIP=1; shift ;;
        --model)      CODEX_REVIEW_MODEL="$2"; shift 2 ;;
        --effort)     CODEX_REVIEW_EFFORT="$2"; shift 2 ;;
        --timeout)    CODEX_REVIEW_TIMEOUT="$2"; shift 2 ;;
        --branches)   CODEX_REVIEW_BRANCHES="$2"; shift 2 ;;
        --no-log)     CODEX_REVIEW_LOG=0; shift ;;
        *)            shift ;;  # ignore unknown args (git passes remote name/url)
    esac
done

# --- Skip check ---
if [[ "$CODEX_REVIEW_SKIP" == "1" ]]; then
    echo -e "${YELLOW}[codex-review] Skipping review (CODEX_REVIEW_SKIP=1)${NC}"
    exit 0
fi

# --- Check codex is available ---
if ! command -v codex &>/dev/null; then
    echo -e "${RED}[codex-review] codex CLI not found in PATH. Install it or set CODEX_REVIEW_SKIP=1 to bypass.${NC}"
    exit 1
fi

# --- Determine target branches from stdin (git hook protocol) ---
# Git pre-push sends one line per ref: <local ref> <local sha> <remote ref> <remote sha>
# We collect ALL protected refs being pushed, not just the last one.
PROTECTED_TARGETS=()
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if ! tty -s 2>/dev/null; then
    while IFS= read -r line; do
        local_ref=$(echo "$line" | awk '{print $1}')
        remote_ref=$(echo "$line" | awk '{print $3}')
        target="${remote_ref##refs/heads/}"

        for branch in $CODEX_REVIEW_BRANCHES; do
            if [[ "$target" == "$branch" ]]; then
                PROTECTED_TARGETS+=("$target")
                break
            fi
        done
    done
fi

# Manual invocation — check current branch
if [[ ${#PROTECTED_TARGETS[@]} -eq 0 ]]; then
    for branch in $CODEX_REVIEW_BRANCHES; do
        if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
            PROTECTED_TARGETS+=("$branch")
            break
        fi
    done
fi

# --- Not pushing to a protected branch ---
if [[ ${#PROTECTED_TARGETS[@]} -eq 0 ]]; then
    echo -e "${BLUE}[codex-review] Not pushing to a protected branch — skipping review${NC}"
    exit 0
fi

# Use the first protected target for diffing (typically there's only one)
TARGET_BRANCH="${PROTECTED_TARGETS[0]}"

# --- Find the merge base to diff against ---
MERGE_BASE="origin/${TARGET_BRANCH}"
if ! git rev-parse "$MERGE_BASE" &>/dev/null; then
    MERGE_BASE="$TARGET_BRANCH"
fi

# --- Compute diff stats (safely, without set -e pipeline issues) ---
DIFF_STAT=$(git diff --stat "${MERGE_BASE}...HEAD" 2>/dev/null) || \
DIFF_STAT=$(git diff --stat "${MERGE_BASE}" HEAD 2>/dev/null) || \
DIFF_STAT=""

DIFF_CONTENT=$(git diff "${MERGE_BASE}...HEAD" 2>/dev/null) || \
DIFF_CONTENT=$(git diff "${MERGE_BASE}" HEAD 2>/dev/null) || \
DIFF_CONTENT=""

DIFF_LINES=$(echo "$DIFF_CONTENT" | wc -l | tr -d ' ')

if [[ -z "$DIFF_CONTENT" || "$DIFF_LINES" == "0" ]]; then
    echo -e "${GREEN}[codex-review] No changes to review${NC}"
    exit 0
fi

# --- Build codex command ---
CODEX_CMD=(codex exec)

if [[ -n "$CODEX_REVIEW_MODEL" ]]; then
    CODEX_CMD+=(--model "$CODEX_REVIEW_MODEL")
fi

if [[ -n "$CODEX_REVIEW_EFFORT" ]]; then
    CODEX_CMD+=(--reasoning-effort "$CODEX_REVIEW_EFFORT")
fi

# --- Large diff warning ---
if [[ "$DIFF_LINES" -gt "$CODEX_REVIEW_MAX_DIFF" ]]; then
    echo -e "${YELLOW}[codex-review] Large diff detected (${DIFF_LINES} lines). Review may take longer.${NC}"
    echo -e "${YELLOW}  Consider breaking into smaller commits or set CODEX_REVIEW_MAX_DIFF higher.${NC}"
fi

# --- Build the review prompt ---
FILES_CHANGED=$(git diff --name-only "${MERGE_BASE}...HEAD" 2>/dev/null) || \
FILES_CHANGED=$(git diff --name-only "${MERGE_BASE}" HEAD 2>/dev/null) || \
FILES_CHANGED="unknown"

FILE_COUNT=$(echo "$FILES_CHANGED" | wc -l | tr -d ' ')

REVIEW_PROMPT="You are reviewing a code change before it is pushed to the '${TARGET_BRANCH}' branch.

## Changed files:
${FILES_CHANGED}

## Diff summary:
${DIFF_STAT}

## Instructions:
Review the git diff for this branch (use git diff ${MERGE_BASE}...HEAD) and check for:
1. **Bugs & logic errors** — incorrect behavior, off-by-one, null handling
2. **Security issues** — injection, auth bypass, secrets in code
3. **Breaking changes** — API contract changes, migration safety
4. **Type safety** — mismatched types, missing null checks
5. **Test coverage** — are new code paths tested?

## Output format:
- If issues found: list each with severity (CRITICAL/WARNING/INFO), file, line, description
- If no issues: say 'LGTM — no issues found'
- End with a single line: REVIEW_RESULT: PASS or REVIEW_RESULT: FAIL
- Only FAIL for CRITICAL issues. Warnings alone should PASS."

# --- Run the review ---
echo -e "${CYAN}${BOLD}[codex-review] Reviewing changes before push to '${TARGET_BRANCH}'...${NC}"
echo -e "${BLUE}  Branch: ${CURRENT_BRANCH} → ${TARGET_BRANCH}${NC}"
echo -e "${BLUE}  Files:  ${FILE_COUNT} changed${NC}"
echo -e "${BLUE}  Diff:   ${DIFF_LINES} lines${NC}"
if [[ -n "$CODEX_REVIEW_MODEL" ]]; then
    echo -e "${BLUE}  Model:  ${CODEX_REVIEW_MODEL}${NC}"
else
    echo -e "${BLUE}  Model:  (from ~/.codex/config.toml)${NC}"
fi
if [[ -n "$CODEX_REVIEW_EFFORT" ]]; then
    echo -e "${BLUE}  Effort: ${CODEX_REVIEW_EFFORT}${NC}"
else
    echo -e "${BLUE}  Effort: (from ~/.codex/config.toml)${NC}"
fi
echo ""

# Run with timeout.
# GNU coreutils `timeout` is absent on stock macOS (homebrew installs it as `gtimeout`).
# Without this detection the bare `timeout` call fails with 127, which the handler below
# misreads as a codex error and fails OPEN — silently disabling the review on every push.
REVIEW_OUTPUT=""
REVIEW_EXIT=0
REVIEW_START=$(date +%s)

TIMEOUT_PREFIX=()
if command -v timeout &>/dev/null; then
    TIMEOUT_PREFIX=(timeout "${CODEX_REVIEW_TIMEOUT}")
elif command -v gtimeout &>/dev/null; then
    TIMEOUT_PREFIX=(gtimeout "${CODEX_REVIEW_TIMEOUT}")
elif command -v perl &>/dev/null; then
    # Stock macOS has neither timeout nor gtimeout, but always has perl. alarm()
    # gives the same semantics, so the cap survives without asking every machine
    # to install coreutils. It terminates via SIGALRM, hence exit 142 below.
    TIMEOUT_PREFIX=(perl -e 'alarm shift; exec @ARGV' "${CODEX_REVIEW_TIMEOUT}")
else
    echo -e "${YELLOW}[codex-review] No 'timeout'/'gtimeout'/'perl' on PATH — running codex unbounded.${NC}"
fi

# Build the full command. Guard the expansion by length: bash 3.2 (stock macOS) throws
# "unbound variable" on "${empty[@]}" under `set -u`, but "${#empty[@]}" is always safe.
if [[ ${#TIMEOUT_PREFIX[@]} -gt 0 ]]; then
    REVIEW_CMD=("${TIMEOUT_PREFIX[@]}" "${CODEX_CMD[@]}")
else
    REVIEW_CMD=("${CODEX_CMD[@]}")
fi

# Redirect stdin from /dev/null: a git pre-push hook is fed the pushed refs on stdin
# (read above for ref parsing), and codex exec otherwise consumes that stream ("Reading
# additional input from stdin...") instead of the argv prompt — reviewing garbage on some
# runs and a real diff on others. /dev/null gives it clean EOF so the argv prompt always wins.
if REVIEW_OUTPUT=$("${REVIEW_CMD[@]}" "$REVIEW_PROMPT" </dev/null 2>&1); then
    REVIEW_EXIT=0
else
    REVIEW_EXIT=$?
fi

REVIEW_END=$(date +%s)
REVIEW_DURATION=$(( REVIEW_END - REVIEW_START ))

# --- Handle timeout ---
if [[ "$REVIEW_EXIT" == "124" || "$REVIEW_EXIT" == "142" ]]; then
    echo -e "${YELLOW}[codex-review] Review timed out after ${CODEX_REVIEW_TIMEOUT}s. Push proceeding.${NC}"
    echo -e "${YELLOW}  Increase timeout: CODEX_REVIEW_TIMEOUT=600 git push${NC}"
    exit 0
fi

# --- Handle codex failure ---
if [[ "$REVIEW_EXIT" != "0" ]]; then
    echo -e "${YELLOW}[codex-review] Codex exited with code ${REVIEW_EXIT}. Push proceeding.${NC}"
    if [[ -n "$REVIEW_OUTPUT" ]]; then
        echo -e "${YELLOW}  Output: $(echo "$REVIEW_OUTPUT" | head -3)${NC}"
    fi
    exit 0
fi

# --- Validate output looks like a review (not just an error message) ---
if [[ ${#REVIEW_OUTPUT} -lt 20 ]] || ! echo "$REVIEW_OUTPUT" | grep -qE "REVIEW_RESULT:|LGTM|CRITICAL|WARNING|INFO|issue|bug|security"; then
    echo -e "${YELLOW}[codex-review] Review output doesn't look like a structured review. Push proceeding.${NC}"
    echo -e "${YELLOW}  Output: $(echo "$REVIEW_OUTPUT" | head -5)${NC}"
    exit 0
fi

# --- Display review ---
echo -e "${BOLD}--- Codex Review ---${NC}"
echo "$REVIEW_OUTPUT"
echo -e "${BOLD}--- End Review (${REVIEW_DURATION}s) ---${NC}"
echo ""

# --- Audit log ---
log_review() {
    if [[ "$CODEX_REVIEW_LOG" != "1" ]]; then return; fi

    local log_dir="${REPO_ROOT}/.codex-review-log"
    mkdir -p "$log_dir"

    # Add to .gitignore if not already there
    local gitignore="${REPO_ROOT}/.gitignore"
    if [[ -f "$gitignore" ]]; then
        if ! grep -qF '.codex-review-log/' "$gitignore" 2>/dev/null; then
            echo '.codex-review-log/' >> "$gitignore"
        fi
    fi

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local log_file="${log_dir}/${timestamp}_${1}.md"
    local sha
    sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

    cat > "$log_file" <<LOGEOF
# Codex Review — ${timestamp}

- **Result:** ${1}
- **Branch:** ${CURRENT_BRANCH} → ${TARGET_BRANCH}
- **SHA:** ${sha}
- **Files:** ${FILE_COUNT}
- **Diff lines:** ${DIFF_LINES}
- **Duration:** ${REVIEW_DURATION}s
- **Model:** ${CODEX_REVIEW_MODEL:-config.toml default}
- **Effort:** ${CODEX_REVIEW_EFFORT:-config.toml default}

## Review Output

\`\`\`
${REVIEW_OUTPUT}
\`\`\`
LOGEOF

    # Prune old logs (keep last 50)
    local count
    count=$(ls -1 "$log_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 50 ]]; then
        ls -1t "$log_dir"/*.md | tail -n +"51" | xargs rm -f
    fi
}

# --- Parse result ---
# Take the LAST explicit verdict line, not any mention of the token. Codex's prose can
# reference "REVIEW_RESULT: FAIL" while explaining its reasoning (and injected workflow
# text can too), so a plain `grep -q FAIL` over the whole output blocks clean PASS reviews.
# Anchored to a line that contains ONLY a verdict. Unanchored, the echoed
# instruction "REVIEW_RESULT: PASS or REVIEW_RESULT: FAIL" matches mid-sentence,
# so a review that never reached a verdict is read as FAIL and blocks the push.
# With no standalone verdict line VERDICT is empty and the inconclusive branch
# below lets the push through, matching how the hook already treats a codex error.
VERDICT=$(echo "$REVIEW_OUTPUT" \
    | grep -oE "^[[:space:]]*REVIEW_RESULT: *(PASS|FAIL)[[:space:]]*$" \
    | tail -1 | grep -oE "PASS|FAIL")

if [[ "$VERDICT" == "FAIL" ]]; then
    echo -e "${RED}${BOLD}[codex-review] FAILED — Critical issues found. Push blocked.${NC}"
    echo -e "${YELLOW}  To push anyway: git push --no-verify${NC}"
    echo -e "${YELLOW}  To skip review: CODEX_REVIEW_SKIP=1 git push${NC}"

    log_review "FAIL"

    # TTS notification
    if [[ -f "$HOME/.agents/hooks/tts/play-tts.sh" ]] && [[ ! -f "$HOME/.agentvibes-muted" ]]; then
        bash "$HOME/.agents/hooks/tts/play-tts.sh" "Codex review failed. Critical issues found." >/dev/null 2>&1 &
    fi

    exit 1
elif [[ "$VERDICT" == "PASS" ]]; then
    echo -e "${GREEN}${BOLD}[codex-review] PASSED — Push proceeding.${NC}"

    log_review "PASS"

    # TTS notification
    if [[ -f "$HOME/.agents/hooks/tts/play-tts.sh" ]] && [[ ! -f "$HOME/.agentvibes-muted" ]]; then
        bash "$HOME/.agents/hooks/tts/play-tts.sh" "Codex review passed. Push proceeding." >/dev/null 2>&1 &
    fi

    exit 0
else
    echo -e "${YELLOW}[codex-review] Could not parse review result. Push proceeding.${NC}"
    log_review "UNPARSED"
    exit 0
fi
