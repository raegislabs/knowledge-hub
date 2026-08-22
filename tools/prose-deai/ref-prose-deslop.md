# Prose De-AI Reference (SSoT)

Canonical checklist for making written work read as human-written. In our
setup it is consumed by a Claude Code skill, a Codex prompt, and the
deterministic scripts in this directory — the doc itself is
tool-agnostic, so wire it into whatever editor or CLI you run.

---

## The pass, in order

Three deterministic gates around one editorial pass. Run all of it with:

```bash
./prose-clean.sh DRAFT [ORIGINAL]
```

| | What | Tool | Bar |
|---|---|---|---|
| **Gate A** | Mechanical tells: em dashes, stock phrases, antithesis templates, generated openers | `prose-lint.sh` | 0 hard failures |
| **Gate B** | Tells a regex cannot see: hashtag stuffing, stylometry, vocabulary-tier density, AI-tool fingerprints | `prose-detect.mjs` | score < 25 |
| **Editorial** | Layers 2 and 3 below, at the strictness the context profile sets | you, reading it | judgement |
| **Gate C** | Every number, date, URL and quote in the original survives, and none is invented | `prose-factlock.py --strict-added` | PASS |

Gate C applies to anything carrying figures: a brief, a data-led post, a report summary. It is the
one that stops the most dangerous failure mode, which is not a clumsy sentence but an edit that
quietly changes a number or adds a claim the source never made. **Its limit:** it matches facts, so
it cannot tell that a figure already in the text has been reused for a new claim ("ADR fell 6%" →
"if that comes with another 6% decline"). Read for invented claims yourself; a human gate stays
responsible for anything that will be published under a person's name.

Chosen by bake-off, 22 Aug 2026: four candidate skills over three samples, scored on all three
gates plus a judge on voice, meaning, flattening and tells removed. Rules below marked
*(borrowed)* come from those candidates, all MIT:
[conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing),
[blader/humanizer](https://github.com/blader/humanizer) (after Wikipedia's *Signs of AI writing*),
[petergyang/no-ai-slop](https://github.com/petergyang/no-ai-slop). `prose-patterns.js` behind Gate B
is avoid-ai-writing's detector, vendored with its licence.

**Scope.** Prose written for human readers: bios, proposals, emails, LinkedIn posts,
landing copy, reports, documentation intended to be read rather than parsed. Not code,
not agent-facing instruction files, not structured data. Inside quoted source material,
flag but never silently edit.

**Prime directive.** Remove the tells without flattening the writing. A de-AI'd draft that
is now bland has failed. Cutting a bad sentence is better than replacing it with a safe one.

---

## Layer 1 — Mechanical and lexical (run `prose-lint.sh` first)

The linter has two tiers. Hard punctuation and empty formulas must be removed.
Contextual candidates must be read before they are changed.

### Hard failures

- **Em dashes.** Replace with a full stop, comma, colon, or parentheses, or restructure the
  sentence. If a sentence needs an em dash to hold together, it is usually two sentences.
- **Spaced en dashes** standing in for em dashes.
- **Stock phrases.** `it's worth noting`, `at its core`, `a testament to`, `navigate the
  complexities`, `paving the way`, `in today's fast-paced`, `plays a crucial role`,
  `in conclusion`, `first and foremost`, `at the end of the day`.
- **Antithesis templates.** `not just X but Y`, `isn't just X, it's Y`, `it's not about X,
  it's about Y`. One may survive if it is genuinely the clearest construction. Two is a tell.
  Three is a signature.
- **Generated openers.** Sentences starting `Moreover,` `Furthermore,` `Additionally,`
  `Indeed,` `Ultimately,` `Essentially,`.
- **Fragment questions** used as transitions: `The result?` `The problem?` `Sound familiar?`

### Contextual candidates

- **Favorite words.** `delve`, `tapestry`, `testament`, `beacon`, `realm`, `landscape`,
  `robust`, `seamless`, `leverage` as a verb, `unlock`, `harness`, `elevate`, `showcase`,
  `pivotal`, `crucial`, `vital`, `holistic`, `bespoke`, `curated`, `transformative`,
  `revolutionize`, `paramount`, and similar fashionable terms.
- **Action inflation.** `serves as`, `stands as`, `functions as`, `operates as`, or
  `features` where `is`, `has`, `shows`, or a direct verb would be clearer.
- **Significance padding.** `crucially`, `importantly`, `notably`, `of course`, and
  `in many ways` when the fact can carry its own weight.

A candidate is not proof of a problem. `Realm` may be the source's literal
cosmological term. `Features` may accurately describe the contents of a work.
Read the sentence, paragraph, document frequency, and local cluster. Keep an
isolated useful instance when it is the clearest wording. Record the reason in
formal editorial work. Revise rote repetition and empty inflation. Never run a
global synonym swap merely to lower a count.

---

## Layer 2 — Structural (requires reading, not grep)

This is where most of the machine-written feel actually lives.

1. **Uniform sentence length.** Four or five sentences of near-identical length in sequence is
   the loudest structural tell. Human prose varies hard: a 40-word sentence next to a 5-word one.
   Fix by breaking one long sentence and letting a short one stand alone.

2. **Capstone sentences.** A closing line that restates what the preceding facts already
   established, usually signalled by `which is why`, `and that means`, `much of the value lies
   in`, `it is what allows`. Confident writing states the fact and stops. Delete the capstone;
   check whether anything was actually lost.

3. **Explaining its own significance.** Adjacent to the above: telling the reader that
   something is uncommon, notable, or important rather than presenting it and letting them
   conclude. Also usually a boast when it appears in a bio.

4. **Symmetry.** Every paragraph the same length, every list exactly three items, every section
   with the same internal shape. Real writing is lumpy because some points need more room.

5. **Adjective triples.** `precise, professional, and thorough`. Cut to one, or to the one that
   is doing work.

6. **Hedge stacks.** `may potentially help to`, `can often serve to`, `might arguably`. Pick one
   hedge or none.

7. **Rhetorical question then answer.** `So what does this mean in practice? It means...`

8. **Bold-everything.** Emphasis applied so widely that nothing is emphasised.

9. **Emoji section headers** in professional prose.

10. **The neat bow.** A final paragraph that summarises, uplifts, and resolves. Most real
    documents just end.

11. **Diplomatic overbalancing.** The prose gives equal rhetorical weight to
    every position even when the evidence supports a firmer conclusion. Keep
    real uncertainty and material alternatives. Remove symmetry used to avoid
    judgment.

12. **Repeated transition frames.** Sentence openings such as `Yet`, `At the
    same time`, `The result is`, `This is why`, and `What matters is` become a
    machine signature when they recur across several pages.

13. **Invented specificity.** An edit that adds a number, a date, a name, a causal claim or an
    extrapolation the source did not contain. The most damaging failure of every anti-AI skill
    tested: one turned "39% to 35%" into "four points of margin gone" (a derivation presented as a
    quote) and invented "if that comes with another 6% rate decline". Derivations are allowed only
    when labelled as ours ("on our arithmetic"); new claims are never allowed. *(borrowed: the
    failure came from no-ai-slop, the rule from the brief's verification gate)*

14. **Hashtag stuffing.** Six or more hashtags on a social post reads as machine-written; human
    posts that exceed five are usually trading reach for engagement. Cut to three or four that a
    person would actually follow. Gate B flags this; Gate A cannot see it. *(borrowed:
    avoid-ai-writing)*

15. **Vague third-party validation.** "Industry reports show", "experts agree", "independent
    testing confirms" with no named source. Name the source, the test and the date, or cut the
    claim. Distinct from name-dropping, which piles on *specific* names to borrow their weight.
    *(borrowed: humanizer and avoid-ai-writing)*

16. **Shallow -ing analysis.** A participle phrase bolted on to make a plain fact sound deeper:
    "…, reflecting the region's commitment to growth", "…, underscoring a broader shift". Cut it,
    or replace it with the specific consequence. *(borrowed: humanizer, from Wikipedia's list)*

17. **Copula avoidance.** "serves as", "stands as", "boasts", "features" where "is" or "has" is
    what you mean. *(borrowed: humanizer)*

18. **Portability test.** Read each sentence and ask whether it could move to another company's
    document unchanged. If it could, it is filler: name the project, the person, the market or the
    number, or cut it. *(borrowed: no-ai-slop)*

---

## Layer 3 — Voice checks

- Would the author say this out loud? Read the suspect sentence aloud.
- Does any sentence make a claim about *other people* (`few people`, `unlike most`,
  `many struggle to`) in order to elevate the subject? That is a boast wearing a statistic's
  clothes. Recast as a description of method or delete.
- Is the register borrowed from somewhere it does not belong? Marketing cadence in a bio,
  consulting cadence in an email.
- Are there specifics? Named things, numbers, dates, places. Generated prose drifts to the
  general; humans reach for the particular.

---

## Context profiles

Same rules, different strictness. Pick the profile from what the text is, and say which you used.
*(borrowed and trimmed from avoid-ai-writing's tolerance matrix.)*

| Rule | linkedin | article / blog | brief / report | email | docs |
|---|---|---|---|---|---|
| Em dashes | none | none | one, in a fixed heading | none | none |
| Fragments and one-line paragraphs | fine, they are the form | sparing | sparing | fine | skip the rule |
| Bullets where prose would read better | skip, lists work here | strict | skip, scanning is the job | relaxed | skip |
| Hashtags | 3-4 maximum | n/a | n/a | n/a | n/a |
| Capstone / neat-bow ending | strict, end on the question | strict | strict, end on the last fact | relaxed | skip |
| Contractions and first person | encouraged | fine | avoid in fact bullets, fine in commentary | encouraged | avoid |
| Sentence-length variation | strict | strict | relaxed, bullets are uniform by design | relaxed | relaxed |
| Fact lock (Gate C) | when figures appear | when figures appear | always | when figures appear | always |

Register targets: **linkedin** punchy, first person, one idea per paragraph. **article** measured,
evidence then implication. **brief** flat and numerate, no interpretation outside a marked
relevance block. **email** direct, shortest thing that carries the decision. **docs** plain and
scannable, no personality.

---

## Reporting format

Report findings before editing, grouped:

```
PROFILE          — which context profile you used
GATE A (n)       — from prose-lint.sh, file:line; must be resolved
GATE B (score)   — from prose-detect.mjs, by type; must land under 25
CANDIDATE (n)    — quote, assess frequency and context, revise or retain with reason
STRUCTURAL (n)   — quote the sentence, name the tell, give the replacement
VOICE (n)        — quote, explain, propose
GATE C           — factlock PASS/FAIL; list anything missing, invented or restated
```

Then apply. Never rewrite beyond the flagged issues. If a fix would change meaning, flag it
and ask instead of guessing.
