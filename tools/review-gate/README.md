# Local Pre-Push Codex Review Gate

A Git pre-push hook that asks Codex to review the diff before a protected
branch leaves the developer machine. A model-reported critical finding blocks
the push. Warnings are printed and pass.

This is a second opinion, not a test runner. Run deterministic local tests and
release checks first.

## Behaviour

| Condition | Result |
|---|---|
| Structured review reports `REVIEW_RESULT: FAIL` | Push is blocked |
| Structured review passes or reports warnings only | Push proceeds |
| Codex is not installed | Push is blocked |
| Review times out, Codex fails or output is malformed | Push proceeds with a visible warning |
| Target branch is not protected | Review is skipped |

Model and timeout failures are deliberately fail-open so a provider outage
does not trap local work. If your release policy requires fail-closed review,
this script is not sufficient without changing those branches.

## Install

From the target Git repository:

```bash
/path/to/knowledge-hub/tools/review-gate/install-review-hook.sh --dry-run
/path/to/knowledge-hub/tools/review-gate/install-review-hook.sh
```

The installer:

1. copies `pre-push-review.sh` into the target repository's `scripts/`
2. backs up an existing `pre-push` hook and runs it before Codex review
3. creates `.codex-review.conf` when it does not exist
4. keeps local review logs out of Git

Inspect the copied script and configuration before the first protected-branch
push.

Run the local smoke test for installer restoration, pass/fail parsing, diff
selection and config safety:

```bash
./tests/smoke.sh
```

## Configuration

`.codex-review.conf` accepts only these assignment keys:

```bash
CODEX_REVIEW_MODEL=""
CODEX_REVIEW_EFFORT="high"
CODEX_REVIEW_BRANCHES="main master"
CODEX_REVIEW_MAX_DIFF=2000
CODEX_REVIEW_TIMEOUT=300
CODEX_REVIEW_SKIP=0
CODEX_REVIEW_LOG=1
```

The parser does not execute shell expressions from this file. Model and effort
inherit from the local Codex configuration when left empty.

## Run manually

```bash
scripts/pre-push-review.sh
```

The Git hook uses the remote object ID supplied by Git, so it reviews the
commits entering the protected branch rather than relying on a possibly stale
remote-tracking reference.

## Bypass and uninstall

```bash
git push --no-verify
CODEX_REVIEW_SKIP=1 git push
/path/to/install-review-hook.sh --target /path/to/project --uninstall
```

Uninstall restores the hook backup when one was created. Bypasses are
intentional operator controls and should be recorded for a production release.

## Limits

- A model can miss defects or misclassify severity.
- Large diffs reduce review quality. Split unrelated changes.
- Local hooks are not enforced on other clones.
- The hook can inspect repository content through the local Codex CLI.
- Audit logs may contain code excerpts. Treat them with repository-level
  access controls.
