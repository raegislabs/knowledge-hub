# Knowledge Hub

Templates, guides, prompts and tooling for agentic AI workflows and coding —
distilled from real Raegis Labs project work and published for reuse.

Browses best from the website: **[raegislabs.com/knowledge-hub](https://raegislabs.com/knowledge-hub)**

## Difficulty tiers

| Tier | For |
|---|---|
| **Ignition** | First contact: install the tools, run your first agent, copy a working prompt or template. |
| **Orbit** | You ship with agents daily: wire up pipelines, hooks, multi-CLI setups, context discipline. |
| **Deep Space** | Long-range work: orchestration loops, subagent protocols, portfolio-scale systems. |

## What's here

```
guides/
  ignition/     first-skill guides
  orbit/        multi-CLI config, context optimisation, cross-CLI invocation, port assignment,
                deployment standards, secrets hygiene, Traefik file routing, platform onboarding
  deep-space/   agentic coding ecosystem, the Ralph loop, subagent sentinel validation,
                agent-operated workflow design
templates/
  skills/       ready-to-adapt agent skill packs (qa, git-workflow, backend, frontend,
                research, architecture, debugging, devops, project-ops, testing)
  agents/       AGENTS.md starters for multi-CLI agent config
tools/
  prose-deai/   three-gate toolchain that strips AI tells from prose
  review-gate/  pre-push hook that routes your diff through an agent review
  db-safe/      timestamped SQLite backup and migration scripts with retention
```

## Using the skill packs

Each pack under `templates/skills/` is a folder with a `SKILL.md` (the
instructions an agent reads), `assets/` (fill-in templates), and `references/`
(method notes). To use one with Claude Code, copy the pack into
`.claude/skills/<name>/` in your project (or `~/.claude/skills/` for all
projects). Codex, Gemini CLI and OpenCode take the same content in their own
prompt directories — see
[multi-cli-agent-setup](https://github.com/raegislabs/multi-cli-agent-setup)
for the wiring.

## Companion repositories

- [multi-cli-agent-setup](https://github.com/raegislabs/multi-cli-agent-setup) — one instruction file, four agent CLIs
- [terminal-ai-workspace](https://github.com/raegislabs/terminal-ai-workspace) — WezTerm + Zellij environment for AI-assisted coding
- [linctl](https://github.com/raegislabs/linctl) — Linear CLI built for agents

## License

MIT — see [LICENSE](LICENSE). Third-party bits and their licences are listed
in [ATTRIBUTION.md](ATTRIBUTION.md).
