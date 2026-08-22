#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""prose-factlock.py: deterministic check that an edit did not lose or change the facts.

usage: prose-factlock.py BEFORE AFTER [--json] [--strict-added]
Extracts from both texts: numbers with their units (%, currency codes and symbols, k/m/bn, x),
dates, URLs, e-mail addresses, and double-quoted strings. Reports what went missing, what appeared,
and what changed count. Exit 0 = every fact in BEFORE survives in AFTER (added facts are warnings);
exit 1 = something missing. Use after any anti-AI or editorial pass on text that carries figures.
"""
import re, sys, json, collections
NUM = r"(?:[A-Z]{3}\s?|[$€£¥]\s?|(?:IDR|MVR|SGD|USD|THB|MYR|RM|Rp|AUD|JPY|KRW)\s?)?\d[\d,]*(?:\.\d+)?\s?(?:%|percent|bn|billion|m\b|million|k\b|x\b|pts?\b|points?\b|kWh|m3|sq ?m|keys?|rooms?|hotels?|units?|nights?)?"
DATE = r"\b(?:\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\.?\s+\d{4}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\s+\d{4}|\d{4}-\d{2}-\d{2}|\b(?:FY|Q[1-4])\s?\d{2,4})\b"
URL = r"https?://[^\s)>\]]+"
MAIL = r"[\w.+-]+@[\w-]+\.[\w.-]+"
QUOTE = r"[\"“]([^\"”]{4,200})[\"”]"
def norm_num(s):
    s = s.strip().replace(",", "").lower()
    s = re.sub(r"\s+", "", s)
    return s
def facts(text):
    f = collections.Counter()
    for m in re.finditer(NUM, text):
        s = m.group(0).strip()
        if re.search(r"\d", s) and len(re.sub(r"\D", "", s)) >= 1:
            # skip bare small integers that are likely list numbering or years inside dates handled below
            if re.fullmatch(r"\d{1,2}\.?", s): continue
            f["num:" + norm_num(s)] += 1
    for m in re.finditer(DATE, text): f["date:" + re.sub(r"\s+", " ", m.group(0).strip().lower())] += 1
    for m in re.finditer(URL, text): f["url:" + m.group(0).rstrip(".,;")] += 1
    for m in re.finditer(MAIL, text): f["mail:" + m.group(0).lower()] += 1
    for m in re.finditer(QUOTE, text): f["quote:" + re.sub(r"\s+", " ", m.group(1).strip().lower())] += 1
    return f
def digits(k):
    """Numeric core of a fact key, for matching '19.5' against '19.5points'."""
    return re.sub(r"[^0-9.]", "", k.split(":", 1)[1]) if k.startswith("num:") else None

def main():
    argv = sys.argv[1:]
    as_json = "--json" in argv; strict_added = "--strict-added" in argv
    args = [a for a in argv if not a.startswith("--")]
    if len(args) != 2: print(__doc__); return 2
    b = facts(open(args[0], encoding="utf-8", errors="replace").read())
    a = facts(open(args[1], encoding="utf-8", errors="replace").read())
    missing = {k: v for k, v in b.items() if a.get(k, 0) < v}
    added = {k: v for k, v in a.items() if b.get(k, 0) < v}
    # A number whose unit was made explicit or dropped ("19.5" -> "19.5 points") is a restatement,
    # not a lost fact. Pair those off and report them separately.
    restated = []
    for mk in list(missing):
        dm = digits(mk)
        if not dm: continue
        for ak in list(added):
            da = digits(ak)
            if da and da == dm:
                restated.append((mk, ak)); missing.pop(mk, None); added.pop(ak, None); break
    # Added facts are warnings by default and failures under --strict-added, which is the right
    # setting for text carrying a verification gate: an invented figure is as bad as a lost one.
    # A fact already present in BEFORE that simply appears more often in AFTER is a repeat, not an
    # invention. Only genuinely new keys count against --strict-added.
    repeats = {k: v for k, v in added.items() if k in b}
    for k in repeats: added.pop(k, None)
    added_nums = {k: v for k, v in added.items() if k.startswith(("num:", "date:", "quote:"))}
    ok = not missing and (not added_nums if strict_added else True)
    res = {"facts_before": sum(b.values()), "facts_after": sum(a.values()), "missing": missing,
           "added": added, "restated": restated, "repeats": repeats, "strict_added": strict_added, "ok": ok}
    if as_json: print(json.dumps(res, indent=2))
    else:
        print(f"factlock: {res['facts_before']} facts before, {res['facts_after']} after, "
              f"{len(missing)} missing, {len(added)} added, {len(restated)} restated")
        for k in sorted(missing): print("  MISSING", k)
        for k in sorted(added): print(("  ADDED   " if (strict_added and k in added_nums) else "  added   ") + k)
        for mk, ak in restated: print(f"  restated {mk} -> {ak}")
        for k in sorted(repeats): print("  repeat   " + k)
        print("PASS" if ok else "FAIL")
    return 0 if ok else 1
if __name__ == "__main__":
    sys.exit(main())
