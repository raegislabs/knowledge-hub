#!/usr/bin/env bash

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/review-gate-test.XXXXXX")"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

INSTALL_REPO="$TEST_ROOT/install-repo"
mkdir -p "$INSTALL_REPO/scripts"
git -C "$INSTALL_REPO" init -q
# The variable belongs to the generated existing hook.
# shellcheck disable=SC2016
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" chained > "${CHAIN_MARKER:?}"' \
    > "$INSTALL_REPO/.git/hooks/pre-push"
printf '%s\n' '#!/usr/bin/env bash' 'echo original-script' \
    > "$INSTALL_REPO/scripts/pre-push-review.sh"
chmod +x "$INSTALL_REPO/.git/hooks/pre-push"

bash "$TOOL_DIR/install-review-hook.sh" --target "$INSTALL_REPO" >/dev/null
grep -qF 'raegislabs/knowledge-hub review-gate' \
    "$INSTALL_REPO/.git/hooks/pre-push" \
    || fail "installer did not create its marked hook"
CHAIN_MARKER="$TEST_ROOT/chained-hook"
(
    cd "$INSTALL_REPO"
    CHAIN_MARKER="$CHAIN_MARKER" CODEX_REVIEW_SKIP=1 \
        .git/hooks/pre-push origin example.invalid </dev/null >/dev/null
)
[[ -f "$CHAIN_MARKER" ]] || fail "installed wrapper did not run the existing hook"

bash "$TOOL_DIR/install-review-hook.sh" --target "$INSTALL_REPO" --uninstall \
    >/dev/null
grep -qF 'CHAIN_MARKER' "$INSTALL_REPO/.git/hooks/pre-push" \
    || fail "uninstall did not restore the existing hook"
grep -qF 'original-script' "$INSTALL_REPO/scripts/pre-push-review.sh" \
    || fail "uninstall did not restore the existing script"

REVIEW_REPO="$TEST_ROOT/review-repo"
FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$REVIEW_REPO/scripts" "$FAKE_BIN"
git -C "$REVIEW_REPO" init -q
git -C "$REVIEW_REPO" config user.name "Review Gate Test"
git -C "$REVIEW_REPO" config user.email "review-gate@example.invalid"
printf '%s\n' 'before' > "$REVIEW_REPO/example.txt"
git -C "$REVIEW_REPO" add example.txt
git -C "$REVIEW_REPO" commit -qm "baseline"
BASE_OID="$(git -C "$REVIEW_REPO" rev-parse HEAD)"
printf '%s\n' 'after' >> "$REVIEW_REPO/example.txt"
git -C "$REVIEW_REPO" add example.txt
git -C "$REVIEW_REPO" commit -qm "change"
HEAD_OID="$(git -C "$REVIEW_REPO" rev-parse HEAD)"
cp "$TOOL_DIR/pre-push-review.sh" "$REVIEW_REPO/scripts/pre-push-review.sh"

# These variables belong to the generated fake executable.
# shellcheck disable=SC2016
printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$@" > "${FAKE_CAPTURE:?}"' \
    'printf "%s\n" "LGTM: test review" "REVIEW_RESULT: ${FAKE_VERDICT:-PASS}"' \
    > "$FAKE_BIN/codex"
chmod +x "$FAKE_BIN/codex"

CAPTURE="$TEST_ROOT/codex-args.txt"
OUTPUT="$TEST_ROOT/review-output.txt"
REF_LINE="refs/heads/main $HEAD_OID refs/heads/main $BASE_OID"

if ! (
    cd "$REVIEW_REPO"
    printf '%s\n' "$REF_LINE" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          FAKE_VERDICT=PASS CODEX_REVIEW_LOG=0 CODEX_REVIEW_EFFORT=high \
          bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1; then
    cat "$OUTPUT" >&2
    fail "PASS verdict blocked the push"
fi

grep -qF "git diff $BASE_OID..$HEAD_OID" "$CAPTURE" \
    || fail "review did not use the remote object ID range"
grep -qF 'model_reasoning_effort="high"' "$CAPTURE" \
    || fail "reasoning effort did not use the current Codex config flag"

printf '%s\n' \
    'CODEX_REVIEW_EFFORT="high"' \
    'CODEX_REVIEW_BRANCHES="main"' \
    'CODEX_REVIEW_LOG=0' \
    > "$REVIEW_REPO/.codex-review.conf"
if ! (
    cd "$REVIEW_REPO"
    printf '%s\n' "$REF_LINE" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          FAKE_VERDICT=PASS CODEX_REVIEW_EFFORT='' \
          bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1; then
    cat "$OUTPUT" >&2
    fail "quoted config values were not parsed"
fi
grep -qF 'model_reasoning_effort="high"' "$CAPTURE" \
    || fail "quoted effort config was not applied"
rm "$REVIEW_REPO/.codex-review.conf"

ZERO_OID="0000000000000000000000000000000000000000"
if ! (
    cd "$REVIEW_REPO"
    printf '%s\n' "refs/heads/main $HEAD_OID refs/heads/main $ZERO_OID" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          FAKE_VERDICT=PASS CODEX_REVIEW_LOG=0 \
          bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1; then
    cat "$OUTPUT" >&2
    fail "new protected branch review failed"
fi
EMPTY_TREE_OID="$(git -C "$REVIEW_REPO" hash-object -t tree /dev/null)"
grep -qF "git diff $EMPTY_TREE_OID..$HEAD_OID" "$CAPTURE" \
    || fail "new protected branch was not reviewed from the empty tree"

set +e
(
    cd "$REVIEW_REPO"
    printf '%s\n' "$REF_LINE" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          FAKE_VERDICT=FAIL CODEX_REVIEW_LOG=0 \
          bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1
review_exit=$?
set -e
[[ "$review_exit" -eq 1 ]] || fail "FAIL verdict did not block the push"

TOUCH_TARGET="$TEST_ROOT/config-executed"
# The command substitution must remain literal to prove config is not sourced.
# shellcheck disable=SC2016
printf 'UNSUPPORTED=$(touch %s)\n' "$TOUCH_TARGET" \
    > "$REVIEW_REPO/.codex-review.conf"
if ! (
    cd "$REVIEW_REPO"
    printf '%s\n' "$REF_LINE" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          FAKE_VERDICT=PASS CODEX_REVIEW_LOG=0 \
          bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1; then
    cat "$OUTPUT" >&2
    fail "unsupported config key prevented review"
fi
[[ ! -e "$TOUCH_TARGET" ]] || fail "config file executed a shell expression"

set +e
(
    cd "$REVIEW_REPO"
    printf '%s\n' "refs/heads/main $ZERO_OID refs/heads/main $HEAD_OID" \
        | PATH="$FAKE_BIN:$PATH" FAKE_CAPTURE="$CAPTURE" \
          CODEX_REVIEW_LOG=0 bash scripts/pre-push-review.sh origin example.invalid
) > "$OUTPUT" 2>&1
delete_exit=$?
set -e
[[ "$delete_exit" -eq 1 ]] || fail "protected branch deletion was not blocked"

echo "review-gate-smoke: PASS"
