#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/instruction-links-test.XXXXXX")"
TEST_HOME="$TEST_ROOT/home"
TEST_PROJECT="$TEST_ROOT/project"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_link() {
    local path="$1"
    local target="$2"
    [[ -L "$path" ]] || fail "expected symlink: $path"
    [[ "$(readlink "$path")" == "$target" ]] \
        || fail "unexpected target for $path"
}

mkdir -p "$TEST_HOME/.claude"
printf '%s\n' "original claude rules" > "$TEST_HOME/.claude/CLAUDE.md"

HOME="$TEST_HOME" bash "$REPO_DIR/install.sh" --global >/dev/null

GLOBAL_FILE="$TEST_HOME/.agents-global/AGENTS.md"
[[ -f "$GLOBAL_FILE" ]] || fail "global source was not created"
assert_link "$TEST_HOME/.claude/CLAUDE.md" "$GLOBAL_FILE"
assert_link "$TEST_HOME/.codex/AGENTS.md" "$GLOBAL_FILE"
[[ ! -e "$TEST_HOME/.gemini" ]] || fail "installer touched .gemini"
assert_link "$TEST_HOME/.config/opencode/AGENTS.md" "$GLOBAL_FILE"

backup="$(find "$TEST_HOME/.claude" -maxdepth 1 \
    -name 'CLAUDE.md.before-instruction-links.*' -print | head -1)"
[[ -f "$backup" ]] || fail "existing Claude file was not backed up"

printf '%s\n' "custom source survives reinstall" > "$GLOBAL_FILE"
HOME="$TEST_HOME" bash "$REPO_DIR/install.sh" --global >/dev/null
grep -qF "custom source survives reinstall" "$GLOBAL_FILE" \
    || fail "reinstall replaced the user source"

HOME="$TEST_HOME" bash "$REPO_DIR/install.sh" --uninstall >/dev/null
[[ -f "$TEST_HOME/.claude/CLAUDE.md" ]] \
    || fail "Claude backup was not restored"
[[ ! -L "$TEST_HOME/.claude/CLAUDE.md" ]] \
    || fail "Claude link remained after uninstall"
grep -qF "original claude rules" "$TEST_HOME/.claude/CLAUDE.md" \
    || fail "restored Claude file changed"
[[ -f "$GLOBAL_FILE" ]] || fail "uninstall removed the user source"

mkdir -p "$TEST_PROJECT"
if bash "$REPO_DIR/setup-project.sh" "$TEST_PROJECT" >/dev/null 2>&1; then
    fail "project setup succeeded without AGENTS.md"
fi
cp "$REPO_DIR/project-AGENTS.md.example" "$TEST_PROJECT/AGENTS.md"
bash "$REPO_DIR/setup-project.sh" "$TEST_PROJECT" >/dev/null

assert_link "$TEST_PROJECT/.claude/CLAUDE.md" "../AGENTS.md"
[[ ! -e "$TEST_PROJECT/.codex" ]] || fail "project setup created .codex"
grep -qFx ".claude/CLAUDE.md" "$TEST_PROJECT/.gitignore" \
    || fail "specific Claude ignore entry missing"
if grep -qFx ".claude/" "$TEST_PROJECT/.gitignore"; then
    fail "project setup ignored the whole .claude directory"
fi

bash "$REPO_DIR/setup-project.sh" "$TEST_PROJECT" >/dev/null
[[ "$(grep -cFx ".claude/CLAUDE.md" "$TEST_PROJECT/.gitignore")" == 1 ]] \
    || fail "rerun duplicated the ignore entry"

bash "$REPO_DIR/setup-project.sh" --remove "$TEST_PROJECT" >/dev/null
[[ ! -e "$TEST_PROJECT/.claude/CLAUDE.md" ]] || fail "project link remained"
[[ -f "$TEST_PROJECT/AGENTS.md" ]] \
    || fail "project source was removed"

echo "instruction-links-smoke: PASS"
