# Cross-CLI Agent Invocation Reference

> Externalized from `~/.agents-global/AGENTS.md` to reduce context window overhead.
> This file is loaded on-demand when agents need CLI invocation details.

Agents can spawn other AI tools via CLI for specialized tasks. This enables:
- Using Gemini's large context window for codebase-wide analysis
- Using Codex's agentic capabilities for autonomous refactoring
- Using Claude for complex reasoning and code generation

## Claude Code CLI

**Basic Usage:**
```bash
# Interactive mode
claude

# Non-interactive execution (exec mode)
claude -p "your prompt here"

# Uses default model (recommended)
# If specific model needed: claude --model <model> -p "your prompt"

# Continue last conversation
claude --continue

# Resume specific conversation
claude --resume <conversation-id>
```

**Key Flags:**
- `-p, --prompt`: Non-interactive single prompt execution
- `--model`: Choose model (use with caution - may cause errors if unavailable)
- `--continue`: Continue most recent conversation
- `--resume`: Resume specific conversation by ID
- `--allowedTools`: Restrict available tools
- `--disallowedTools`: Block specific tools
- `--max-turns`: Limit agentic turns

**Spawning from other agents:**
```bash
# From Gemini or Codex, run Claude for complex reasoning
claude -p "Analyze this architecture decision: ..."

# Run Claude with file context
claude -p "Review this code: $(cat src/main.py)"
```

## Gemini CLI

**IMPORTANT - Invocation Constraints:**
- `-p` flag and `@file` positional args are **mutually exclusive** — do NOT combine them
- For prompts with file context: embed file content in the prompt text, use `-p` only
- `@path` syntax is for **interactive mode only** (positional query argument)
- Gemini's internal grep uses `rg --hyperlink-format` which may fail on older ripgrep versions — if Gemini errors on grep, it's an environment issue (upgrade ripgrep or skip Gemini for that task)

**Basic Usage:**
```bash
# Interactive mode
gemini

# Non-interactive execution (prompt only — no @file args)
gemini -p "your prompt here"

# WRONG — combining -p with @file causes error:
# gemini -p "Analyze:" @src/ @tests/

# CORRECT — use @file in interactive mode only:
gemini "Analyze: @src/ @tests/"

# CORRECT — for non-interactive with file context, embed content:
gemini -p "Analyze this code: $(cat src/main.py)"

# Sandbox mode for code execution
gemini --sandbox -p "Write and test a sorting algorithm"
```

**Key Flags:**
- `-p, --prompt`: Non-interactive prompt execution (CANNOT combine with @file args)
- `@path`: Include file/directory contents — interactive mode positional arg only
- `--sandbox`: Enable code execution sandbox
- `--model`: Select model variant (use with caution - may cause errors if unavailable)
- `-o json`: JSON output format (useful for structured review output)

**Large Context Analysis (Gemini's strength):**
```bash
# Interactive mode with file inclusion (leverages 1M+ token context)
gemini "Analyze the architecture of this codebase: @src/ @lib/ @tests/"

# Non-interactive with inline content
gemini -p "Review this diff for issues: $(git diff HEAD~1..HEAD)"

# Non-interactive with file content embedded
gemini -p "Analyze this migration: $(cat migrations/versions/359_*.py)"
```

**Spawning from other agents:**
```bash
# From Claude or Codex — non-interactive, prompt-only
gemini -p "Analyze entire codebase for technical debt: $(cat src/main.py)"

# For large file sets, write prompt to temp file first
cat /tmp/review-prompt.md | gemini -p "$(cat /tmp/review-prompt.md)"
```

## Codex CLI (OpenAI)

**IMPORTANT - Invocation Constraints:**
When spawning Codex from another agent (Claude Code, Gemini), commands run in a non-TTY shell.
- **For short prompts** (<4KB): pass as positional arg: `codex exec "short prompt"`
- **For long prompts** (>4KB): pipe from file: `cat /tmp/prompt.md | codex exec`
  - `codex exec "$(cat file)"` FAILS for large prompts — shell ARG_MAX or Codex stdin conflict
  - Piping via `cat file | codex exec` works reliably (Codex reads from stdin)
- Codex has **NO** `-p` flag -- use `codex exec "prompt"` for non-interactive mode
- Codex has **NO** `--full-auto` flag -- use `-c approval_mode="full-auto"` instead
- Codex has **NO** `-q` flag

**Basic Usage:**
```bash
# Interactive mode (only works in a real terminal, NOT from other agents)
codex

# Non-interactive execution — short prompts
codex exec "your task description"

# Non-interactive execution — long prompts (e.g., review with inline diff)
cat /tmp/review-prompt.md | codex exec -c approval_mode="full-auto"

# Uses default model automatically (recommended to avoid model selection errors)
# If specific model needed: codex exec -m <model-name> "task"

# With reasoning effort control
codex exec -c model_reasoning_effort="high" "complex task"

# Resume last session
codex exec resume --last
```

**Code Review (dedicated subcommand):**
```bash
# Review uncommitted changes (staged + unstaged + untracked)
codex review --uncommitted

# Review changes against a base branch
codex review --base main

# Review a specific commit
codex review --commit HEAD

# Review with custom instructions
codex review --uncommitted "Focus on security and error handling"

# Non-interactive review (via exec subcommand)
codex exec review --uncommitted
codex exec review --base main "Check for OWASP top 10 vulnerabilities"
```

**Key Flags:**
- `exec`: Execute task non-interactively (required when spawning from other agents)
- `review`: Dedicated code review subcommand (also available as `codex exec review`)
- `-m, --model`: Model selection (use with caution - may cause errors if model unavailable)
- `-c, --config <key=value>`: Override config values (model, reasoning, approval mode, sandbox)
- `--json`: Output events as JSONL (useful for structured handoffs)
- `resume --last`: Resume previous session

**Config Overrides (via `-c` flag):**
```bash
# Approval mode (replaces the non-existent --full-auto flag)
codex exec -c approval_mode="full-auto" "task"      # Skip all confirmations
codex exec -c approval_mode="unless-allow-listed" "task"  # Default behavior

# Reasoning effort
codex exec -c model_reasoning_effort="high" "complex task"
codex exec -c model_reasoning_effort="low" "simple task"

# Sandbox permissions
codex exec -c 'sandbox_permissions=["disk-full-read-access"]' "analyze code"
codex exec -c 'sandbox_permissions=["disk-full-read-access","disk-write-cwd"]' "refactor"
```

**Spawning from other agents (Claude Code, Gemini):**
```bash
# Code review (most common cross-agent use case)
codex review --uncommitted
codex review --base main
codex exec review --base main "Check for security issues"

# Non-interactive task execution
codex exec "Add comprehensive tests to src/auth/"

# With full autonomy (no confirmation prompts)
codex exec -c approval_mode="full-auto" "Refactor auth module"

# With JSONL output for structured handoffs
codex exec --json "Analyze code quality in src/"

# Complex multi-file refactoring
codex exec -c model_reasoning_effort="high" \
  -c approval_mode="full-auto" "Migrate from REST to GraphQL"
```

## OpenCode CLI

**Basic Usage:**
```bash
# Interactive mode
opencode

# With specific agent
opencode --agent architect

# Non-interactive (if supported)
opencode -p "your prompt"
```

## Cross-Invocation Patterns

**Pattern 1: Claude orchestrates, Gemini analyzes**
```bash
gemini -p "Analyze all 500+ files for security issues: @src/ @lib/ @tests/"
```

**Pattern 2: Claude orchestrates, Codex implements**
```bash
codex exec -c approval_mode="full-auto" \
  "Implement the auth refactoring plan documented in docs/auth-refactor.md"
```

**Pattern 3: Gemini analyzes, Claude reasons, Codex implements**
```bash
gemini -p "Identify all technical debt in: @src/" > /tmp/tech-debt.md
claude -p "Prioritize this technical debt list: $(cat /tmp/tech-debt.md)"
codex exec -c approval_mode="full-auto" "Fix top priority: ..."
```

**Pattern 4: Parallel agent execution**
```bash
gemini -p "Security audit: @src/" &
claude -p "Architecture review of: $(cat src/main.py)" &
wait
```

## Best Practices for Cross-Invocation

1. **Use the right tool for the job:**
   - Gemini: Large context analysis (>100K tokens), codebase-wide searches
   - Claude: Complex reasoning, nuanced decisions, code generation
   - Codex: Autonomous multi-step implementation, refactoring

2. **Prefer non-interactive modes** for predictable automation (Claude: `-p`, Gemini: `-p`, Codex: `exec`)

3. **Capture output** for downstream processing:
   ```bash
   ANALYSIS=$(gemini -p "analyze @src/")
   claude -p "Based on this analysis: $ANALYSIS, recommend next steps"
   ```

4. **Use appropriate sandbox modes** in Codex for safety

5. **Chain tools sequentially** when output of one informs the next
