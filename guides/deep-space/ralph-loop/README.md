# The Ralph Loop — Autonomous Iteration Protocol

Ralph is an indefinite agent loop that keeps working a backlog of stories
across sessions without human babysitting. Its defining trick: **context
amnesia as a feature**. Each iteration re-reads its plan and progress from
disk instead of relying on conversation memory, so the loop survives context
resets, session crashes, and days-long runs.

## How the loop works

1. A driver prompt tells the agent: *find the next unchecked story in
   `PLAN.md`, execute it, update `PROGRESS.md`, repeat.*
2. The agent works entirely from the four runtime-state files below —
   never from its own recollection of earlier iterations.
3. `ralph-watch.py` gives a human a live TUI over the session: current
   story, phase, files touched, and stall detection.

## The runtime-state pattern (the transferable idea)

The loop's memory lives in four markdown files in the working directory:

| File | Written by | Purpose |
|---|---|---|
| `GUARDRAILS.md` | Human, once | Hard constraints: stack rules, phase rules, safety lines. The agent re-reads this every iteration. |
| `PLAN.md` | Human, once | The story backlog as a checkbox list. The loop's source of truth for "what's next". |
| `PROGRESS.md` | Agent, per story | Append-only log: files touched, decisions made, test counts. This is what makes amnesia safe. |
| `scratchpad.md` | Agent, per iteration | Ephemeral working notes. Wiped or ignored across iterations; anything durable gets promoted to PROGRESS. |

The example `GUARDRAILS.md`, `PLAN.md`, and `PROGRESS.md` in this directory
are trimmed from real runs — read them as shapes to copy, not content to
reuse.

## Files

- `ralph-iterate.xml` — the task definition fed to the orchestrator agent:
  phases, transitions, failure handling, and the exact re-read protocol.
- `GUARDRAILS.md` / `PLAN.md` / `PROGRESS.md` — example runtime state.
- `ralph-watch.py` — rich TUI monitor for a running loop (phase, story,
  recent activity, stall detection).

## Why it works

- **Crash-safe by construction**: state is on disk, not in the context
  window. Kill the session mid-story; the next iteration picks up from the
  last completed checkbox.
- **Self-verifying**: each story ends with tests run and results logged in
  PROGRESS, so the loop can't silently drift into broken states.
- **Bounded autonomy**: GUARDRAILS forbids destructive git operations and
  pushes, so the worst case is a messy working tree, not a lost repo.
