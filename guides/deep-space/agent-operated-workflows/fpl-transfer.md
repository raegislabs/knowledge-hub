---
name: fpl-transfer
description: Answer a specific transfer question (example skill)
argument-hint: out <player> in <player>
---

Question: `$ARGUMENTS`.

1. `uv run fpl status` for the gameweek, then `uv run fpl state show` for the bank, sell prices and free transfers.
2. `uv run fpl transfer compare --gw N --out "<player>" --in "<player>"`. Pass `--gw` explicitly: it is the gameweek `fpl status` reports. Before the GW1 deadline there are no transfers to compare (the whole squad is still open); answer with `fpl plan initial --lock "<player>"` or `--ban "<player>"` instead.
3. If the operator asked an open question rather than naming both sides, run `uv run fpl plan build --gw N --tag draft --alternatives 3` and read the alternatives table instead.
4. If a name matches several players the command lists them with ids; rerun with the id.

Then tell the operator:
- Whether it is affordable at today's sell price, and what the bank is afterwards. An "infeasible" scenario names the reason (usually money or the club limit); repeat it.
- The expected-points gain over the horizon, and whether it clears the hit hurdle if a hit is needed.
- What doing nothing is worth, since rolling a free transfer often wins.
- Any club-limit or availability problem the move creates.

Sell prices come from `fpl state show`, never from today's price. Purchase price plus half the rise is what the seller actually gets.
