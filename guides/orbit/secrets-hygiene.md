# Secrets Hygiene for Agent Workflows

AI coding agents are the newest member of the team that will cheerfully
cat any file, echo any variable into a log, and paste a token into a commit
message while trying to be helpful. Standard secrets discipline assumed a
human's sense of shame. Agents don't have one. This is the rulebook that
works anyway.

---

## The problem, concretely

An agent with filesystem access and a debugging task will, left to itself:

1. Read `.env` to "check the configuration" and quote it into the transcript
2. Run `env` or print config objects to see what's loaded
3. Write example files containing the *real* values it saw
4. Fix a failing integration test by hardcoding the credential it found
   in a sibling project

None of this is malicious. All of it ends with a secret in a log file,
a shell history, or a public repo.

## Principle 1: agents don't read secrets, they use them

Secrets should be injected at execution time by a wrapper the agent invokes,
never read from a file the agent can open:

```
agent runs:  agent-run deploy-job
             └── wrapper pulls creds from the secrets manager
             └── child process gets env vars; agent's shell never sees them
```

The agent learns "there is a command that does the thing", not "the key
lives at this path". Knowledge of *how* and *that* separated is the whole
game.

## Principle 2: one secret, one purpose, one scope

Every credential answers to a single job:

- Per-service tokens, not a shared "server token"
- Scoped permissions (read-only database creds for analytics jobs;
  write only where the job writes)
- Short TTLs where the provider supports them
- A name that encodes the owner and purpose:
  `<service>-<environment>-<purpose>`

When a token leaks — and plan for the day one does — scoping is what turns
an incident into a rotation.

## Principle 3: the manager is the only writable source

Pick one secrets manager (Infisical, Bitwarden Secrets Manager, Doppler,
Vault — they're all fine) and treat it as the single source of truth:

- Nothing hand-edits generated env files; they're artifacts, regenerated
- Local `.env` files, when unavoidable, hold only non-secret config
- The bootstrap credential for the manager itself lives in the OS keychain
  or is typed by a human — never in the repo, never in a dotfile an agent
  can read

## Principle 4: keep the leak-proofing mechanical

Because agents generate traffic at machine speed, the guards must be
mechanical too:

- **Grep gate on publish.** A pre-push hook that fails on token-shaped
  strings (`sk-…`, `ghp_…`, `AKIA…`, Bearer headers, `password =` lines)
  before anything leaves the machine. This repo ships one: see
  `scripts/sanitize-check.sh` in the repo root.
- **History hygiene on publish.** Publishing a repo? Fresh `git init`, copy
  the tree in. Old history is where since-deleted secrets go to be found.
- **Log redaction at the source.** Structured logging with a denylist of
  field names (`token`, `authorization`, `api_key`) beats hoping no agent
  ever prints them.
- **Shell history is a secret store.** It shouldn't be. `HISTCONTROL` with
  `ignorespace`, and a habit of ` read -s` in scripts that take credentials.

## Principle 5: rotation is routine, not an event

If rotating a credential is a big deal, you have a coupling problem. A
quarterly rotation that takes ten minutes per service means each secret has
exactly one consumer and the manager distributes the new value without
humans editing files. If rotation is scary, find the hard-coded consumer
first — that consumer is your real security posture.

---

## A minimal working setup

1. Secrets manager with one project per environment, entries named
   `<service>-<purpose>`
2. A wrapper command (`agent-run <job>` or your equivalent) that fetches
   and execs — the only door agents get
3. Pre-push grep gate in every repo, extended with your own patterns
  (client names, internal hostnames)
4. Quarterly calendar reminder: rotate one project's secrets, time it

That's the whole stack. The discipline is in the wrapper being the only
door, not in the choice of manager.
