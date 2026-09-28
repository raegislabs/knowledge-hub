# Secrets Hygiene for Agent Workflows

Coding agents inspect files, run commands and quote diagnostic output. That
makes accidental disclosure through transcripts, logs, shell history and Git a
normal threat to design for.

## 1. Give the agent a job interface, not a secret value

Prefer a narrow wrapper that fetches a scoped credential and immediately
executes the approved job:

```text
agent -> agent-run <job> -> secret manager -> child process
```

The wrapper should:

- accept an allowlisted job name rather than an arbitrary shell command
- request only the credential needed for that job
- avoid printing values or the child environment
- remove temporary material on every exit path
- return a documented exit code without copying sensitive output

This reduces exposure. It does not create a security boundary if the agent has
the same operating-system permissions as the secret manager client.

## 2. Scope every credential

- Use one credential per service, environment and purpose.
- Grant read or write access only where the job requires it.
- Prefer short lifetimes where the provider supports them.
- Record the owner, consumer and rotation procedure.
- Do not share a broad server token across unrelated jobs.

A useful name states the service, environment and purpose:
`<service>-<environment>-<purpose>`.

## 3. Keep one writable source

Use a secrets manager as the writable source. Generated environment files are
deployment artifacts, not a second place to edit.

- Keep bootstrap credentials in an OS keychain or hardware-backed store.
- Restrict generated host files to the service account.
- Do not place real values in `.env.example`.
- Keep production secrets out of repository settings and hosted CI runners.
- Rotate a secret in the manager, regenerate the consumer and verify the old
  value no longer works.

## 4. Keep secrets out of commands and logs

Command-line arguments may appear in process listings and shell history.
Prefer standard input, a protected file descriptor or a provider SDK.

When a human must enter a value in a shell:

```bash
IFS= read -r -s SECRET_VALUE
printf '\n'
```

Do not rely on a shell's history-ignore setting as the primary control.

For application logs:

- allowlist fields that may be recorded
- redact headers such as `Authorization` and `Cookie` at the logger boundary
- reject fields named `token`, `secret`, `password` or `api_key`
- review error objects from SDKs, which may contain request headers
- set retention and access rules for agent transcripts and tool logs

## 5. Add a mechanical publish check

This repository includes [`sanitize-check.sh`](../../scripts/sanitize-check.sh)
for client markers, infrastructure identifiers and common token shapes.

```bash
./scripts/sanitize-check.sh
git diff --cached
```

Pattern scans have false negatives. Also inspect:

- the staged diff
- untracked files
- the full Git history when a real secret was ever committed
- generated examples and fixtures
- screenshots, recordings and exported transcripts

If a credential entered Git history, revoke it before cleaning the history.
Rewriting the repository does not make the credential safe again.

## 6. Make rotation ordinary

Test one rotation on a schedule:

1. issue a replacement with the same narrow scope
2. update the manager and regenerate the consumer
3. verify the service with the new credential
4. revoke the old credential
5. confirm alerts, backups and secondary jobs still work
6. record duration and any hidden consumer

Slow or risky rotation usually indicates an undocumented consumer or excessive
credential scope.

## Minimum review

- [ ] agent invokes an allowlisted wrapper
- [ ] wrapper fetches one job-scoped credential
- [ ] secret values never appear in arguments or normal logs
- [ ] generated environment files have restrictive ownership and mode
- [ ] repository and transcript retention are defined
- [ ] publish scan and staged-diff review both run locally
- [ ] rotation and revocation have been tested
