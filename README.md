# Raegis Labs Knowledge Hub

A small public shelf of tools and field notes from Raegis Labs. Material stays
here only when it adds a tested constraint or operating pattern that a stronger
upstream project does not already provide.

The website's [public repository field guide](https://raegislabs.com/knowledge-hub)
lists the upstream projects we recommend for BMAD, coding agents, skills, MCP,
evaluation, browser automation, retrieval and prose quality.

## Maintained resources

| Resource | What it adds | Use upstream instead when |
|---|---|---|
| [Fact-preserving prose gates](tools/prose-deai/) | Mechanical lint, a vendored pattern detector and a fact lock in one repeatable pass | A focused rewrite skill is enough |
| [Local pre-push review gate](tools/review-gate/) | An operator-owned Codex review before protected-branch pushes, with no hosted CI | Your existing local release gate already performs independent review |
| [One instruction source for several CLIs](tools/instruction-links/) | A reversible installer that points Claude Code, Codex and OpenCode at one `AGENTS.md`, wired to the paths each CLI actually reads | You use one CLI; edit its own instruction file instead |
| [Agent-operated workflow design](guides/deep-space/agent-operated-workflows/) | Status, state mutation, exit-code and drift-response contracts for repeat agent-run work | You need a distributed workflow runtime rather than an operator interface |
| [Single-server deployment standards](guides/orbit/deployment-standards.md) | Host-service rules for systemd, loopback binding, secrets and recoverable backups | You run entirely on a managed platform |
| [Coolify onboarding checklist](guides/orbit/coolify-onboarding-checklist.md) | The container and platform boundary checks most often missed during onboarding | You need current product behaviour, which belongs in Coolify's documentation |
| [Traefik file routing](guides/orbit/traefik-file-routing.md) | A safe file-provider pattern for mixed host and container services | Docker labels already give one clear routing source |
| [Secrets hygiene for agents](guides/orbit/secrets-hygiene.md) | Practical controls that reduce accidental disclosure through files, logs and shell commands | Your organisation has a stricter security standard |

## Deliberate omissions

This repository does not carry generic architecture, backend, frontend,
DevOps, Git, QA, research or testing skill packs. Those packs repeated common
guidance, aged quickly and made the useful work harder to find. It also does
not mirror Ralph, skill creators, CLI flag references or agent-framework
catalogues. The original projects are better sources for those jobs.

## Public-safety check

Run the repository gate before publishing changes:

```bash
./scripts/sanitize-check.sh
```

The script resolves this repository from its own location, so it can be called
from another working directory. It scans tracked and untracked, non-ignored
files against [the public forbidden-pattern list](config/forbidden-patterns.txt).
It is a supplemental check, not a substitute for reviewing the diff and Git
history.

## Licence and attribution

Raegis Labs material is MIT licensed under [LICENSE](LICENSE).
The prose detector vendored from
[conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing)
retains its own [MIT notice](tools/prose-deai/LICENSE-prose-patterns.js.txt).
The prose reference also credits patterns adapted from
[blader/humanizer](https://github.com/blader/humanizer).
