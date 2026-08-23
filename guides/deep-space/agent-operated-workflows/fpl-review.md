---
name: fpl-review
description: Score the finished gameweek and say what the model got wrong (example skill)
argument-hint: [gameweek number]
---

Gameweek: `$ARGUMENTS` (if empty, the `review_pending_gw` from `uv run fpl status`).

1. `uv run fpl status`.
2. Read the "Post-gameweek review" step of the weekly runbook in PROJECT-AGENTS.md.
3. `uv run fpl weekly --phase post-gw --gw N`.
4. `uv run fpl report --gw N --kind review --open` opens the HTML for the operator (the weekly phase already does this). Read `reports/gwNN_review.md` yourself.
5. `uv run fpl review trend` reads every review logged so far and raises the five drift flags. Report any that fired, with the permitted response from the "Learning loop" table in PROJECT-AGENTS.md. A flag is a reason to look, not a licence to change a parameter.

If there is no frozen artefact the review still runs, on the decision layer only:
`pool_scored` comes back false, every whole-pool metric and the miss table are absent,
and the predicted numbers come from the plan's own lineup slots. Report the decisions
and say plainly that the forecast could not be scored, and that `fpl model freeze` must
run before the next deadline. It exits 3 only when there is neither a frozen artefact
nor a plan. If it exits 3 saying there is no live-scoring snapshot, the gameweek is not
`data_checked` yet: say when to try again rather than forcing it.

Then tell the operator:
- Our score, the average, hits paid, bench points and whether an auto-sub saved us.
- Whether the model beat the official expected-points baseline on MAE, and by how much (skip if unscored).
- The captain call: what we picked, the best we owned, and what most managers captained.
- Whether the team-news overrides helped or hurt, by Brier score.
- The overrides scorecard's `by_kind` split, once predicted line-ups are in play: `human` is the operator's news pass, `predicted_lineup` is the provider's XI at half weight. Say plainly whether the predictions beat the model on `p_start`. They were taken on the understanding that the review would judge them, so after about six gameweeks of readings that judgement is due: if they are not winning, say the weights in `config/model_params.yaml` should come down or `config/lineups.yaml` should be switched off.
- The decisions block: what the transfers were worth against rolling, what the armband left behind, what the bench order cost, and the season running totals of both.
- The component bias table: which part of the forecast was wrong, not just by how much.
- Any expected starter who played no minutes that nobody had flagged, which is the only bucket the news pass can fix.
- The three biggest misses with their reason tags, and what that suggests about the model.
- Any drift flag from `fpl review trend`.

Be blunt about what went wrong. A review that only reports the good numbers is useless.

**Reports.** The HTML is what the operator reads; the markdown twin is your working copy.
`uv run fpl report --gw N --kind review --open` writes both and opens the HTML in
the browser. Read the markdown yourself for the summary you give, and say the report
is open rather than pasting it back.
