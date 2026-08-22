#!/usr/bin/env bash
# prose-lint.sh — deterministic detection of mechanical AI-writing tells.
#
# Catches only what a regex can identify reproducibly. Hard punctuation and
# empty formulas fail. Favorite words, action inflation, and generated cadence
# are contextual candidates for reading rather than automatic violations.
# Structural tells remain in ref-prose-deslop.md and the Book Gen style audit.
#
# Usage:
#   prose-lint.sh FILE [FILE...]
#   cat draft.md | prose-lint.sh
#   prose-lint.sh --quiet FILE      # exit code only, no output
#   prose-lint.sh --strict-contextual FILE
#
# Exit: 0 = no hard failures, 1 = hard failures (or any candidate under
# --strict-contextual), 2 = usage error.

set -uo pipefail

QUIET=0
STRICT_CONTEXTUAL=0
while [[ "${1:-}" == "--quiet" || "${1:-}" == "--strict-contextual" ]]; do
  if [[ "$1" == "--quiet" ]]; then QUIET=1; fi
  if [[ "$1" == "--strict-contextual" ]]; then STRICT_CONTEXTUAL=1; fi
  shift
done
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

TMP=""; OUT=""; HARD_OUT=""; CANDIDATE_OUT=""
cleanup() {
  [[ -n "$TMP" ]] && rm -f "$TMP"
  [[ -n "$OUT" ]] && rm -f "$OUT"
  [[ -n "$HARD_OUT" ]] && rm -f "$HARD_OUT"
  [[ -n "$CANDIDATE_OUT" ]] && rm -f "$CANDIDATE_OUT"
  return 0
}
trap cleanup EXIT

if [[ $# -eq 0 ]]; then
  if [[ -t 0 ]]; then echo "prose-lint: no files given and no stdin" >&2; exit 2; fi
  TMP="$(mktemp -t proselint)"
  cat > "$TMP"
  set -- "$TMP"
fi

# --- Pattern groups -----------------------------------------------------------
# Contextual single words needing whole-word matching (-w).
WORDS='delve|delves|delving|tapestry|myriad|plethora|realm|landscape|underscore|underscores|pivotal|crucial|vital|robust|seamless|seamlessly|leverage|leveraging|unlock|unlocks|unlocking|harness|harnessing|elevate|elevates|showcase|showcases|nuanced|multifaceted|holistic|paradigm|synergy|transformative|game-changer|cutting-edge|state-of-the-art|bespoke|curated|meticulous|meticulously|profound|remarkable|invaluable|unwavering|steadfast'

# Multi-word stock phrases.
PHRASES="it is worth noting|it's worth noting|it is important to note|it's important to note|it is important to remember|let's dive in|let us dive in|dive deep|deep dive into|in today's fast-paced|in today's digital|in an era where|at its core|at the heart of|when it comes to|the fact that|navigate the complexities|navigating the complexities|a testament to|stands as a testament|plays a crucial role|plays a vital role|plays a pivotal role|paving the way|in conclusion|to sum up|in summary,|last but not least|needless to say|the bottom line is|that being said|with that said|first and foremost|a wide range of|a diverse range of|wide array of|rich tapestry|ever-evolving|ever-changing|fast-paced world|digital age|new heights|the world of|one of the most|it goes without saying|shed light on|the key takeaway|key takeaways|actionable insights|best practices|move the needle|low-hanging fruit|circle back|double-click on|unpack that|at the end of the day"

# Antithesis / rhetorical templates.
TEMPLATES="not just [a-z' ]{1,30}(but|it's|its)|isn't just|isn't about|is not just|is not about|rather than merely|more than just|it's not [a-z' ]{1,25}, it's|this isn't|that's not [a-z' ]{1,20}\. that's"

# Sentence openers that signal generated cadence.
OPENERS="^[[:space:]]*(moreover|furthermore|additionally|indeed|notably|importantly|ultimately|essentially|fundamentally|crucially),"

# Fragment questions used as transitions ("The result?").
FRAGQ="^[[:space:]]*(the result|the problem|the catch|the reason|the answer|the outcome|the takeaway|sound familiar|the best part|why does this matter|so what does this mean)\?"

# Contextual verb inflation and significance padding.
ACTION="\b(serves|served|serving|stands|stood|standing|functions|functioned|functioning|operates|operated|operating) as\b|\b(it|this|the (book|chapter|section|work|text|tractate|volume|edition|manuscript|account|story|collection|passage|source|figure|table|map|guide)) (also |prominently )?features\b"
PADDING="\b(crucially|importantly|notably|significantly|of course|in many ways)\b|\b(may|might|could) potentially\b|\b(may|might|could) arguably\b"

for f in "$@"; do
  [[ -r "$f" ]] || { echo "prose-lint: cannot read $f" >&2; exit 2; }
done

# Label each grep's output. Collected into a file rather than counted inline:
# `grep ... | while read` runs the loop in a subshell, so a counter incremented
# there is lost to the parent and the script would always report clean.
label() { local l="$1" line; while IFS= read -r line; do printf '%s [%s]\n' "$line" "$l"; done; }

HARD_OUT="$(mktemp -t proselint-hard)"
{
  # Em dash: the single most reliable tell.
  grep -Hno  -- '—'          "$@" 2>/dev/null | label HARD:EM-DASH
  # Spaced en dash standing in for an em dash.
  grep -Hno  -- ' – '        "$@" 2>/dev/null | label HARD:EN-DASH
  grep -HnoEi  -- "$PHRASES"   "$@" 2>/dev/null | label HARD:STOCK-PHRASE
  grep -HnoEi  -- "$TEMPLATES" "$@" 2>/dev/null | label HARD:ANTITHESIS
  grep -HnoEi  -- "$FRAGQ"     "$@" 2>/dev/null | label HARD:FRAGMENT-Q
} > "$HARD_OUT"

CANDIDATE_OUT="$(mktemp -t proselint-candidate)"
{
  grep -HnoEiw -- "$WORDS"   "$@" 2>/dev/null | label CANDIDATE:LEXICAL
  grep -HnoEi  -- "$OPENERS" "$@" 2>/dev/null | label CANDIDATE:OPENER
  grep -HnoEi  -- "$ACTION"  "$@" 2>/dev/null | label CANDIDATE:ACTION-INFLATION
  grep -HnoEi  -- "$PADDING" "$@" 2>/dev/null | label CANDIDATE:PADDING
} > "$CANDIDATE_OUT"

OUT="$(mktemp -t proselint-out)"
cat "$HARD_OUT" "$CANDIDATE_OUT" > "$OUT"

# Reading from stdin leaves the mktemp path in every line; label it honestly.
[[ -n "$TMP" ]] && sed -i '' "s|^${TMP}:|(stdin):|" "$OUT" 2>/dev/null

HARD_HITS=$(wc -l < "$HARD_OUT" | tr -d '[:space:]')
CANDIDATE_HITS=$(wc -l < "$CANDIDATE_OUT" | tr -d '[:space:]')

if [[ $QUIET -eq 0 ]]; then
  cat "$OUT"
  echo
  if [[ $HARD_HITS -eq 0 && $CANDIDATE_HITS -eq 0 ]]; then
    echo "prose-lint: clean (0 hard failures, 0 contextual candidates)"
    echo "Structural tells are checked by the de-ai and Book Gen style reviews."
  else
    echo "prose-lint: $HARD_HITS hard failure(s), $CANDIDATE_HITS contextual candidate(s)"
    echo "Read contextual candidates for fit, frequency, and clustering before editing."
    echo "Structural tells are checked by the de-ai and Book Gen style reviews."
  fi
fi

if [[ $HARD_HITS -gt 0 ]]; then exit 1; fi
if [[ $STRICT_CONTEXTUAL -eq 1 && $CANDIDATE_HITS -gt 0 ]]; then exit 1; fi
exit 0
