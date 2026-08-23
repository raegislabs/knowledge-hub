# Agent-Operated Workflows

Most "AI automation" gives the agent a UI to fumble through or a pile of
scripts it reads and hopes to run in the right order. There is a better
shape: design the workflow so an *agent* is its intended operator, the way
UNIX tools are designed for a shell.

This directory documents the conventions, drawn from a season-long
decision system (a fantasy-football pipeline run entirely by agent) but
applicable to any repeat decision process: a weekly trading review, a
content pipeline, an ops rota.

---

## The conventions

### 1. One front-door command

```
$ workflow status
```

A single command reports where the workflow is, what is ready, what is
missing, and the next command to run. The agent never has to remember the
map — it asks. This is the difference between a 15-skill pile and a system.

### 2. State changes only through commands, every one with a reason

```
$ workflow state set-free-transfers 2 --reason "read off the site 2026-01-03"
```

No editing state files by hand, ever. Every mutation goes through a command
that validates it and records *why*. When something is wrong three weeks
later, the reason log is the debug session.

### 3. Exit codes are the API

| Code | Meaning | Agent response |
|---|---|---|
| 0 | done | read output, continue |
| 1 | usage error | fix arguments |
| 2 | precondition unmet | report what's missing, stop |
| 3 | not yet possible | say when to retry, don't force |

The agent branches on the code, not on parsing prose for "error-ish
words". Document the code table in the skill; honour it in the tool.

### 4. Two reports, one truth

Every report renders twice from the same data:

- **HTML** for the human — rich, opened in a browser, skim-friendly
- **Markdown twin** for the agent — the working copy it reads and reasons over

Generating the markdown from the same source as the HTML means the human
and the agent are never looking at different numbers.

### 5. The learning loop is drift flags, not vibes

After every cycle, a review command compares predictions to outcomes and
raises named drift flags ("captain picks underperforming model baseline",
"override pass hurting accuracy"). Each flag has a *permitted response*,
listed in advance. The agent reports the flag and its permitted response;
it does not freelance a parameter change. Trust is built by the
restriction, not the capability.

---

## The example skills

`fpl-status.md`, `fpl-transfer.md` and `fpl-review.md` in this directory
are lightly edited versions of real skills from the fantasy-football
system — status, decision and review being the three archetypes of the
pattern. Notice
how little they do besides: run the command, read the report, report back
in a fixed shape, and refuse to take unrequested actions. The restraint
is the design. A skill that says "do not run the next command unless
asked" is a skill you can leave alone in a terminal at 11pm.

## Why this matters beyond football

Anywhere you have a repeat decision with data, a model of it, and a human
who wants the reasoning surfaced rather than a black-box answer, this shape
applies. The agent becomes a trustworthy operator precisely because the
workflow was built to constrain it: state can only change through
auditable commands, exits are codes, actions beyond the permitted list are
refused. You get the leverage of automation and the accountability of a
checklist.
