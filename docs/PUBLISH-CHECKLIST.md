# Publish Checklist

The grep gate (`scripts/sanitize-check.sh`) catches patterns; it cannot catch
context. Walk this list before every push to a public Raegis Labs repo.

## Automated gate

- [ ] `scripts/sanitize-check.sh` exits 0 locally, immediately before the push
- [ ] After pushing: fresh clone, run the gate again against the clone
      (proves the pushed tree is exactly what was checked)

## History

- [ ] Repo history is fresh (`git init` + new commits only) — never a transplant
      of an internal repo's history
- [ ] `git log -p` spot-check on the first commits: no internal paths, no
      since-deleted files riding along in history

## Content the grep cannot see

- [ ] Screenshots / terminal captures: no visible hostnames, paths, usernames,
      browser tabs, or open editor buffers
- [ ] No names of client organisations, their staff, or engagement details —
      sector-level phrasing ("a hospitality advisory firm") is fine
- [ ] No live infrastructure details: hostnames, droplet names, port maps of
      running services, deployment targets
- [ ] Example domains use example.com / example.org / your-domain.test

## Licensing

- [ ] Every third-party file is listed in ATTRIBUTION.md with its license
- [ ] Third-party license headers kept intact in-file
- [ ] Nothing rehosted that was shipped by a vendor (e.g. Anthropic-distributed
      skills/docs) — link to the source instead
- [ ] BMAD-derived content attributes the BMAD method

## Last pass

- [ ] Read the two most-edited files end to end (the ones with manual edits
      for publication) — fresh eyes, full document
- [ ] README links resolve (click every one)
