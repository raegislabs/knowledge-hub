# Subagent Execution with Sentinel Validation

The hardest failure mode of multi-agent pipelines: a subagent claims it did
the work, but didn't. It reports success, the orchestrator moves on, and the
gap surfaces three stages later with no clean trail back.

This pattern fixes it with **sentinel files**: every subagent must produce a
specific artifact on disk as proof of completion. No artifact, no credit.

## The contract

1. The orchestrator spawns a subagent with a task definition
   (`subagent-execute.xml`) that specifies, per output, the exact sentinel
   file path to write.
2. The wrapper script (or skill) runs the subagent, captures its exit code,
   then **checks the sentinel independently** — it never trusts the
   subagent's self-report.
3. On sentinel mismatch: classified retry. Transient errors (timeout,
   network) retry immediately with a different backend; logic errors retry
   after a fix prompt; repeated failure escalates to the orchestrator's
   failure ledger instead of looping forever.
4. Backend fallback is built in: after two consecutive failures on one CLI
   backend, the next attempt routes to another (`codex exec` ↔ `claude -p`),
   so a single provider's bad day doesn't stall the pipeline.

## Why sentinel files and not exit codes

Exit codes tell you the process ended; they say nothing about whether the
*work* happened. An agent can exit 0 with empty output, truncated files, or
a hallucinated summary. The sentinel file is the difference between "the
agent says done" and "the artifact exists".

## File

- `subagent-execute.xml` — the full task definition: output contract,
  sentinel rules, retry classification, backend fallback, structured
  result schema. Feed it to your orchestrator of choice; the pattern is
  agent-agnostic.
