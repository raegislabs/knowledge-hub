# One Instruction Source for Several Coding CLIs

Claude Code, Codex and OpenCode look for user and project instructions under
different filenames. These scripts make one file the source and point each
CLI at it with symlinks, so a rule is written once.

```text
User level                          Project level
~/.agents-global/AGENTS.md          AGENTS.md            (committed; read by Codex and OpenCode)
    ├── ~/.claude/CLAUDE.md             └── .claude/CLAUDE.md   (symlink for Claude Code)
    ├── ~/.codex/AGENTS.md
    └── ~/.config/opencode/AGENTS.md
```

If you use only one CLI, you do not need this. Edit that CLI's own
instruction file and keep it short.

## Why the project source is the root AGENTS.md

Codex reads project instructions from `AGENTS.md` files between the
repository root and the working directory. It does not read
`.codex/AGENTS.md`, so a setup that links only that path gives Codex no
project rules at all. OpenCode also reads the root `AGENTS.md`. Claude Code is
the one CLI that needs a link, and `.claude/CLAUDE.md` is one of the paths it
reads.

The root file follows the open [AGENTS.md format](https://github.com/agentsmd/agents.md).

## Keep the files short

Instruction files are loaded into context on every turn, so every line costs
tokens for the whole session. That matters most on a small subscription plan.
The [user template](AGENTS.md.example) includes a short set of context rules:
search before reading, no subagents for small tasks, no repeated commands,
proportional handoffs. Put detail that only some tasks need in a skill or a
referenced document, not in the always-loaded file.

## Install user-level instructions

```bash
./install.sh --dry-run --global
./install.sh --global
```

The installer:

- creates `~/.agents-global/AGENTS.md` from the example only when no file
  exists there
- preserves an existing source file without editing it
- moves an existing CLI instruction file to a timestamped backup
- creates all three links, even when a CLI is not installed yet

Edit `~/.agents-global/AGENTS.md` afterwards. Never put secrets, private keys
or production credentials in an instruction file.

## Set up one project

```bash
cp project-AGENTS.md.example /path/to/project/AGENTS.md
./install.sh --project /path/to/project --dry-run
./install.sh --project /path/to/project
```

Commit `AGENTS.md`. The script adds only `.claude/CLAUDE.md` to `.gitignore`
and leaves the rest of `.claude/` alone. An existing regular
`.claude/CLAUDE.md` is kept, with a warning; merge it into `AGENTS.md` and
rerun.

Remove the project link with:

```bash
./setup-project.sh --remove /path/to/project
```

Remove mode deletes the link only when it points at `../AGENTS.md`.

## Uninstall user-level links

```bash
./install.sh --uninstall --dry-run
./install.sh --uninstall
```

Uninstall removes only links that point at `~/.agents-global/AGENTS.md` and
restores the newest installer backup for each path. It keeps the source file,
which may hold rules you wrote.

## Windows

The scripts are bash and need macOS, Linux or WSL. Native Windows symlinks
need Developer Mode or an elevated shell. Two alternatives avoid links:

- Codex alone: edit `%USERPROFILE%\.codex\AGENTS.md` and each project's root
  `AGENTS.md` directly.
- Claude Code alongside another CLI: make `CLAUDE.md` a one-line file that
  imports the shared source with `@AGENTS.md` (project) or
  `@~/.agents-global/AGENTS.md` (user).

## Verify

```bash
./tests/smoke.sh
```

The smoke test runs against a temporary home directory. It covers a fresh
install, preservation of existing files, uninstall restoration and project
link setup and removal.

## Boundaries

- A shared file does not make CLI features or permission models identical.
- CLIs change their discovery paths. Check current documentation after an
  upgrade.
- Adding another CLI means adding one path to `CLI_LINKS` in `install.sh`.
- Project instructions should extend or override user rules explicitly.
