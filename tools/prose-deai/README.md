# Fact-Preserving Prose Quality Gates

This tool combines three separate checks:

1. `prose-lint.sh` finds deterministic punctuation, phrase and structural
   patterns.
2. `prose-detect.mjs` runs a scored detector for broader AI-writing signals.
3. `prose-factlock.py` compares an edited draft with its source and flags
   missing or added numbers, dates, URLs, email addresses and quoted text.

Pattern detection and rewriting already have good public sources. The added
Raegis contribution is treating factual drift as a failed edit in the same
repeatable pass.

## Run all gates

```bash
./prose-clean.sh edited.md original.md
```

Without an original file, the command runs lint and detection only:

```bash
./prose-clean.sh draft.md
```

Exit code `0` means every enabled gate passed. Exit code `1` means at least
one gate found an issue. Exit code `2` means the invocation was invalid.

## Run one gate

```bash
./prose-lint.sh draft.md
node ./prose-detect.mjs draft.md
python3 ./prose-factlock.py original.md edited.md --strict-added
```

Use [`ref-prose-deslop.md`](ref-prose-deslop.md) for the human review pass.
The detector score is a triage signal, not proof of who wrote the text.

## Fact-lock boundary

Fact lock checks surface preservation. It cannot decide whether a claim is
true, whether a paraphrase keeps the same implication, or whether a source was
credible. A human still reviews meaning and evidence.

Bare figures are checked, including one- and two-digit values. Numbers used as
Markdown ordered-list or numbered-heading markers are ignored.

Use `--strict-added` when an edit should not introduce any new fact-shaped
token. Review every reported change instead of automatically copying the
original token back into a sentence.

## Requirements

- Bash
- Node.js
- Python 3
- standard macOS or Linux command-line tools

No network call is required by these scripts.

Run the fact-lock regression suite with:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```

## Attribution

`prose-patterns.js` is vendored from
[conorbronsdon/avoid-ai-writing at commit `ca2206c`](https://github.com/conorbronsdon/avoid-ai-writing/blob/ca2206c2f5fa0919291c0c0f2c320bdf7e3985b0/detector/patterns.js)
under the included [MIT notice](LICENSE-prose-patterns.js.txt). The only local
differences in the detector are comments that remove references to files not
included in this repository.
`prose-detect.mjs` is the small local command-line wrapper around that engine.
The prose reference credits additional patterns adapted from
[blader/humanizer](https://github.com/blader/humanizer), also MIT licensed.

For a rewrite-only workflow, use those upstream projects directly. Use this
tool when mechanical enforcement and fact preservation are part of the
acceptance gate.
