# Review Gate — Pre-Push Agent Review

A local git pre-push hook that routes your diff through an agent code review
before anything reaches a protected branch. Critical findings block the push;
warnings pass with a summary. Zero CI cost, zero third-party service — the
review runs on your own machine with your own CLI.

## Why local

The usual alternative is a CI-based review workflow. This one instead:

- runs in seconds, before the push leaves your machine
- costs nothing per run
- keeps the diff private until you choose to push it
- works identically across projects once installed

## Install

```bash
cd your-project
/path/to/knowledge-hub/tools/review-gate/install-review-hook.sh        # install
install-review-hook.sh --dry-run                                        # preview
install-review-hook.sh --uninstall                                      # remove
```

`pre-push-review.sh` is the reviewer itself; the installer wires it into
`.git/hooks/pre-push` and writes a `.codex-review.conf` if you want
per-project overrides (protected branches, timeout, model).

## Bypass

```bash
git push --no-verify      # one-off
CODEX_REVIEW_SKIP=1 git push
```
