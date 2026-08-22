#!/usr/bin/env bash
# prose-clean.sh — run every deterministic gate of the de-ai pass over one file.
#   prose-clean.sh DRAFT [ORIGINAL]
# Gate A  prose-lint.sh       hard mechanical tells (em dashes, stock phrases, antithesis, openers)
# Gate B  prose-detect.mjs    scored tells a regex misses (hashtag stuffing, stylometry, vocab density)
# Gate C  prose-factlock.py   every number, date, URL and quote in ORIGINAL survives, none invented
# Gate C runs only when ORIGINAL is given. Exit 0 = all gates pass.
set -uo pipefail
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
D="${1:-}"; O="${2:-}"
[ -f "${D:-}" ] || { sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
rc=0
echo "── Gate A: mechanical (prose-lint.sh)"
"$BIN/prose-lint.sh" "$D" || rc=1
echo
echo "── Gate B: detector (prose-detect.mjs)"
node "$BIN/prose-detect.mjs" "$D" || rc=1
if [ -n "$O" ]; then
  echo
  echo "── Gate C: fact lock (prose-factlock.py --strict-added)"
  python3 "$BIN/prose-factlock.py" "$O" "$D" --strict-added || rc=1
fi
echo
[ $rc -eq 0 ] && echo "prose-clean: PASS" || echo "prose-clean: FAIL (fix the gates above and re-run)"
exit $rc
