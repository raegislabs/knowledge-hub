---
name: fpl-status
description: Where we are in the FPL week and what to run next (example skill)
---

Run `uv run fpl status`. If it says no bootstrap snapshot, run `uv run fpl data fetch` first and try again.

Read the "Weekly runbook" section of PROJECT-AGENTS.md for the phase it reports.

Then tell the operator, in this shape:
- Gameweek and deadline, UTC with local time in brackets, and how long is left.
- Phase, and whether the data, xP artefact, overrides and plan are ready or missing. "overrides: template" means the file exists but holds no entries yet, so the team-news procedure has not been done.
- Whether state is seeded and whether a review is still outstanding.
- The single next command to run, and why it is that one.

Say plainly if anything is stale or missing. Do not run the next command yourself unless the operator asks.
