# Agent-Operated Workflow Design

Design a repeat workflow around an explicit operator contract. The agent should
ask the system for status, make validated changes through commands and receive
machine-readable outcomes. It should not infer the procedure from a folder of
scripts.

The examples in this directory come from a season-long fantasy-football
decision system. The same contracts fit recurring research, portfolio review,
content operations and service checks.

## 1. One status command is the front door

```console
$ workflow status
```

The response states:

- current phase and freshness
- satisfied and missing prerequisites
- next permitted command
- paths to the human and machine-readable evidence

The agent asks for current state instead of carrying a stale process map in
context.

## 2. Mutations require a command and a reason

```console
$ workflow state set-free-transfers 2 --reason "read from source on 2026-01-03"
```

Do not edit state files by hand. The command validates the transition and
records who changed what, when and why. This makes a later discrepancy
traceable without reconstructing a chat.

## 3. Exit codes are part of the API

| Code | Meaning | Agent response |
|---|---|---|
| 0 | Command completed | Read the output and continue if authorised |
| 1 | Arguments invalid | Correct the invocation |
| 2 | Precondition missing | Report the missing input and stop |
| 3 | Action not yet available | Report when it can be retried |

Document the table next to the command. Keep prose for human context and use
the exit code for branching.

## 4. Human and agent reports share one data source

Render two views from the same result object:

- HTML for scanning, charts and review
- Markdown or JSON for agent reasoning and diffs

Do not calculate a metric separately in each renderer. Record source time,
generation time and input identifiers in both views.

## 5. Drift has named responses

After each cycle, compare the previous expectation with the outcome and emit a
named drift flag. Each flag maps to a small set of permitted responses.

```text
flag: override_accuracy_below_baseline
permitted:
  - collect_two_more_cycles
  - disable_override_after_human_approval
```

The agent reports the evidence and the permitted response. It does not invent a
parameter change because one result looks surprising.

## 6. Separate recommendation from execution

A decision command may prepare a recommendation and evidence. A second,
explicitly authorised command performs the external action. This boundary
prevents a request to analyse from becoming permission to publish, trade,
transfer or deploy.

## Worked skills

- [`fpl-status.md`](fpl-status.md) shows the front-door status contract.
- [`fpl-transfer.md`](fpl-transfer.md) shows a decision workflow with explicit
  preconditions and no unrequested external action.
- [`fpl-review.md`](fpl-review.md) shows outcome review and bounded drift
  responses.

The domain is deliberately concrete. Copy the contracts, not the football
rules.

## Design checklist

- [ ] one status command reports state, freshness and next action
- [ ] state files cannot be edited through the normal operator path
- [ ] every mutation records a reason
- [ ] exit codes have documented meanings
- [ ] human and agent reports derive from one result object
- [ ] recommendation and external execution use separate commands
- [ ] drift flags have predefined responses
- [ ] every command has a stop condition and idempotency rule
