# Modular Instructions: Claude Code vs Codex CLI

**Purpose**: Guide to modular instruction architecture for both AI coding assistants
**Status**: Reference guide
**Last Updated**: 2025-10-29

---

## Executive Summary

Both **Claude Code** and **Codex CLI** support **modular instruction architectures**, but use different mechanisms:

- **Claude Code**: Lazy-loading with contextual files (trigger-based)
- **Codex CLI**: Hierarchical merging with cascading configs (location-based)

Both approaches achieve the same goals:
- ✅ **Token efficiency** (load only what's needed)
- ✅ **Maintainability** (single source of truth)
- ✅ **Context specificity** (user → project → task)
- ✅ **Modularity** (separate concerns)

---

## Research Findings

### Web Search Evidence (2025)

**Modular Approach is Best Practice**:
> "As CLAUDE.md files grow larger and more monolithic, the model's ability to pinpoint the most relevant piece of information diminishes. The signal gets lost in the noise."

**Optimal File Sizes**:
- General instructions: 500-1000 words
- Detailed specs: 1500-3000 words
- Task-specific: 300-800 words

**Sources**:
- Anthropic Best Practices (2025)
- Claude 4.5 Integration Guide (2025)
- OpenAI Codex CLI Documentation (2025)

---

## Architecture Comparison

### Claude Code: Lazy-Loading

**Mechanism**: Trigger-based contextual file loading

**File Structure**:
```
~/.claude/
├── core/                          # Always loaded (~7k tokens)
│   ├── PRINCIPLES.md              # Engineering philosophy
│   └── TRIGGERS.md                # Activation patterns
├── contextual/                    # Load on demand (0k baseline)
│   ├── MODE_LIBRARY.md            # Behavioral modes
│   ├── MCP_GUIDES.md              # MCP server docs
│   ├── TESTING_STANDARDS.md       # Testing best practices
│   ├── BUSINESS_FRAMEWORK.md      # Business analysis
│   └── RESEARCH_DEEP.md           # Deep research config
└── CLAUDE.md                      # User essentials (~7k tokens)

# Project-level (optional)
~/project/.claude/
└── CLAUDE.md                      # Project-specific instructions
```

**How It Works**:
1. **Core files** always loaded (PRINCIPLES.md, TRIGGERS.md, CLAUDE.md)
2. **Contextual files** loaded when keywords detected
3. **Triggers** defined in TRIGGERS.md (e.g., "test" → TESTING_STANDARDS.md)
4. **Project files** supplement global instructions

**Example**:
```
User: "Write E2E tests for login"

Claude:
1. Detects "E2E tests" keyword
2. Loads ~/.claude/contextual/TESTING_STANDARDS.md (~6-8k tokens)
3. Reads .claude/TESTING.md in project (if exists)
4. Applies global + project-specific testing patterns
```

**Token Usage**:
- **Normal conversation**: ~50k tokens (core only)
- **Testing conversation**: ~56-58k tokens (core + TESTING_STANDARDS.md)
- **Savings**: 6-8k tokens saved in non-testing conversations

---

### Codex CLI: Hierarchical Merging

**Mechanism**: Location-based cascading configuration

**File Structure**:
```
~/.codex/
├── AGENTS.md                      # User-level (personal preferences)
├── instructions.md                # Optional global context
├── config.toml                    # Configuration (model, MCP)
└── prompts/                       # Custom slash commands
    └── *.md

~/project/
├── AGENTS.md                      # Project-level (shared team)
└── feature/
    └── AGENTS.md                  # Task-level (feature-specific)
```

**How It Works**:
1. **User-level** (`~/.codex/AGENTS.md`) - Personal preferences
2. **Project-level** (`repo-root/AGENTS.md`) - Project context
3. **Task-level** (`current-dir/AGENTS.md`) - Feature specifics
4. **Merging**: Top-down with deeper instructions prioritized (cascading)

**Example**:
```
User in ~/project/features/auth/: "Write tests"

Codex:
1. Reads ~/.codex/AGENTS.md (user preferences, testing standards)
2. Reads ~/project/AGENTS.md (project DB config, test commands)
3. Reads ~/project/features/auth/AGENTS.md (auth-specific patterns)
4. Merges all three, prioritizing deeper instructions
```

**Token Usage**:
- All found AGENTS.md files loaded and merged
- Hierarchical approach prevents duplication
- Deeper instructions override higher-level ones

---

## Detailed Comparison Table

| Aspect | Claude Code | Codex CLI |
|--------|-------------|-----------|
| **Mechanism** | Trigger-based lazy-loading | Location-based hierarchical merging |
| **User-Level File** | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` |
| **Modular Files** | `~/.claude/contextual/*.md` | Multiple `AGENTS.md` at different levels |
| **Loading Strategy** | Load on keyword detection | Load and merge all found files |
| **Token Efficiency** | Loads only triggered contexts | Loads all in hierarchy (but avoids duplication) |
| **Priority** | Later loads supplement earlier | Deeper locations override higher |
| **Project-Level** | `.claude/CLAUDE.md` (optional) | `repo-root/AGENTS.md` (optional) |
| **Task-Level** | Not directly supported | `current-dir/AGENTS.md` (optional) |
| **Global Context** | `~/.claude/core/*.md` (always loaded) | `~/.codex/instructions.md` (optional) |
| **Custom Commands** | Skills (separate tool) | `~/.codex/prompts/*.md` |
| **Configuration** | `~/.claude.json` | `~/.codex/config.toml` |

---

## Common Patterns

### Testing Standards

**Both support comprehensive testing guidelines**:

**Claude**:
```
User: "write tests"
→ Loads ~/.claude/contextual/TESTING_STANDARDS.md
→ Reads .claude/TESTING.md (if exists)
→ Applies global + project patterns
```

**Codex**:
```
User: "write tests"
→ Reads ~/.codex/AGENTS.md (includes testing section)
→ Reads repo-root/AGENTS.md (project test config)
→ Reads current-dir/AGENTS.md (feature test patterns)
→ Merges all three hierarchically
```

**Both provide**:
- 4 testing lanes (unit, component, integration, E2E)
- Ephemeral database patterns (Testcontainers)
- CI optimization strategies (sharding, path filtering)
- Stable locator patterns (data-testid)
- Health check patterns

---

### Documentation Policy

**Both enforce the same policy**:

**Never create documentation files unless explicitly requested.**

**Acceptable outputs** (no request needed):
- ✅ Code comments, docstrings
- ✅ Linear comments (status, findings)
- ✅ Git commit messages
- ✅ Terminal output
- ✅ Update existing docs if part of task

**Forbidden** (unless requested):
- ❌ Implementation summaries
- ❌ Analysis documents
- ❌ Test reports
- ❌ New .md files
- ❌ Updates to docs/canonical/

---

### Code Preferences

**Both share the same preferences**:
- **JS/TS**: 2-space, `const` over `let`, JSDoc
- **Python**: 4-space, type hints, descriptive names
- **Git**: Feature branches, clear commit messages
- **Security**: No secrets, environment variables, validate input

---

## Migration Guide

### From Monolithic to Modular (Claude)

**Before** (monolithic):
```
~/.claude/CLAUDE.md (30k tokens, always loaded)
```

**After** (modular):
```
~/.claude/
├── core/TRIGGERS.md (3k, always loaded)
├── core/PRINCIPLES.md (4k, always loaded)
├── CLAUDE.md (7k, always loaded)
└── contextual/
    └── TESTING_STANDARDS.md (8k, loaded on demand)

Total always-loaded: 14k (down from 30k)
Total available: 22k (same content)
Savings: 8k tokens in non-testing conversations
```

**Benefits**:
- 57% reduction in baseline context
- Same content available when needed
- Better signal-to-noise ratio

---

### From Monolithic to Modular (Codex)

**Before** (monolithic):
```
~/.codex/AGENTS.md (25k tokens, always loaded)
```

**After** (modular):
```
~/.codex/AGENTS.md (10k, user-level)
~/project/AGENTS.md (8k, project-level)
~/project/feature/AGENTS.md (3k, task-level)

Total loaded: 21k (down from 25k)
Better organized by scope
Easier to maintain
```

**Benefits**:
- 16% reduction while maintaining same content
- Clear separation of concerns
- Team can maintain project-level independently

---

## Setup Instructions

### Claude Code Setup

**1. Create modular structure**:
```bash
# Core files (always loaded)
mkdir -p ~/.claude/core
touch ~/.claude/core/PRINCIPLES.md
touch ~/.claude/core/TRIGGERS.md

# Contextual files (load on demand)
mkdir -p ~/.claude/contextual
touch ~/.claude/contextual/TESTING_STANDARDS.md
touch ~/.claude/contextual/MODE_LIBRARY.md

# User essentials
touch ~/.claude/CLAUDE.md
```

**2. Configure triggers**:
```markdown
# ~/.claude/core/TRIGGERS.md

### Testing Standards Mode
Triggers: "test", "testing", "e2e", "playwright", "jest", "vitest"
Load: ~/.claude/contextual/TESTING_STANDARDS.md
Behavior: Layered testing strategy, CI optimization
```

**3. Add user essentials**:
```markdown
# ~/.claude/CLAUDE.md

## Contextual Files (Loaded on Activation)
- ~/.claude/contextual/TESTING_STANDARDS.md - Testing best practices

Usage: Claude automatically loads when testing keywords detected.
```

**4. Create project config** (optional):
```bash
mkdir -p ~/project/.claude
touch ~/project/.claude/TESTING.md
```

---

### Codex CLI Setup

**1. Create user-level file**:
```bash
touch ~/.codex/AGENTS.md
```

**2. Add comprehensive instructions**:
```markdown
# ~/.codex/AGENTS.md

## Testing Standards
[Include full testing guidelines]

## Code Preferences
[Include style guidelines]

## Project-Specific Context
Hierarchical Override: Project-level AGENTS.md can override these defaults.
```

**3. Create project-level file** (optional):
```bash
touch ~/project/AGENTS.md
```

**4. Create task-level file** (optional):
```bash
touch ~/project/feature/AGENTS.md
```

**5. Verify hierarchy**:
```bash
# From feature directory
cd ~/project/feature/

# Codex will merge:
# 1. ~/.codex/AGENTS.md (user)
# 2. ~/project/AGENTS.md (project)
# 3. ~/project/feature/AGENTS.md (task)
```

---

## Best Practices

### For Both Systems

**1. Keep Files Focused**:
- 500-1000 words for general instructions
- 1500-3000 words for detailed specs
- 300-800 words for task-specific

**2. Avoid Duplication**:
- Define once at appropriate level
- Let inheritance/merging handle propagation
- Override only when necessary

**3. Document Hierarchy**:
- Explain which file overrides which
- Make inheritance explicit
- Note when to use each level

**4. Regular Review**:
- Monthly for user-level files
- After major learnings
- When patterns emerge across projects

**5. Version Control**:
- **User-level**: Personal, not committed
- **Project-level**: Committed to repo
- **Task-level**: Committed with feature

---

## Performance Comparison

### Claude Code

**Token Usage** (200k context window):
```
Baseline (no testing):
- Core: 7k (PRINCIPLES.md, TRIGGERS.md)
- User essentials: 7k (CLAUDE.md)
- Total: 14k (7% of context)

With testing:
- Baseline: 14k
- Testing standards: 8k (loaded on demand)
- Total: 22k (11% of context)

Headroom: 178k (89%)
```

**Benefits**:
- 8k tokens saved in non-testing conversations
- Large headroom for code exploration
- Fast loading (only what's needed)

---

### Codex CLI

**Token Usage** (128k context window for gpt-5-codex):
```
User + Project + Task:
- User-level: 10k (~/.codex/AGENTS.md)
- Project-level: 8k (repo-root/AGENTS.md)
- Task-level: 3k (current-dir/AGENTS.md)
- Total: 21k (16% of context)

Headroom: 107k (84%)
```

**Benefits**:
- All relevant context loaded upfront
- No trigger mechanism needed
- Deeper instructions override higher

---

## Real-World Examples

### Example 1: Testing Workflow

**User request**: "Write E2E tests for login flow"

**Claude Code**:
```
1. Detects "E2E tests" → loads TESTING_STANDARDS.md
2. Reads .claude/TESTING.md (project config)
3. Applies patterns:
   - Use Playwright
   - Use data-testid attributes
   - Tag test with @smoke
   - Follow project conventions
4. Writes test file
5. Documents in Linear comment
```

**Codex CLI**:
```
1. Merges instructions:
   - User: ~/.codex/AGENTS.md (testing section)
   - Project: repo-root/AGENTS.md (test commands, DB config)
   - Task: features/auth/AGENTS.md (auth patterns)
2. Applies merged patterns:
   - Use Playwright (from user)
   - Use project test DB config (from project)
   - Follow auth-specific patterns (from task)
3. Writes test file
4. Documents in Linear comment
```

**Result**: Same outcome, different mechanism

---

### Example 2: Project-Specific Override

**Scenario**: Project uses different testing tools

**Claude Code**:
```markdown
# ~/project/.claude/TESTING.md

## Project-Specific Testing Config

Override global standards:
- Use Cypress instead of Playwright (legacy project)
- Use Mocha instead of Jest
- Custom test commands in package.json
```

**Codex CLI**:
```markdown
# ~/project/AGENTS.md

## Testing (Project Override)

This project uses legacy tools:
- E2E: Cypress (not Playwright)
- Unit: Mocha (not Jest)

[Rest follows global patterns from ~/.codex/AGENTS.md]
```

**Both**: Project-specific config overrides global defaults

---

## Troubleshooting

### Claude Code

**Issue**: "Contextual file not loading"

**Solution**: Check triggers in TRIGGERS.md
```markdown
# ~/.claude/core/TRIGGERS.md

### Testing Standards Mode
Triggers: "test", "testing", "e2e", ...
Load: ~/.claude/contextual/TESTING_STANDARDS.md
```

**Issue**: "Instructions seem outdated"

**Solution**: Update appropriate file
- User-level: `~/.claude/CLAUDE.md`
- Core: `~/.claude/core/PRINCIPLES.md`
- Contextual: `~/.claude/contextual/*.md`
- Project: `.claude/CLAUDE.md`

---

### Codex CLI

**Issue**: "Instructions not being followed"

**Solution**: Check hierarchy
```bash
# Verify which files exist
ls -la ~/.codex/AGENTS.md
ls -la ~/project/AGENTS.md
ls -la ~/project/feature/AGENTS.md

# Codex merges all found files
# Deeper instructions override higher
```

**Issue**: "Project instructions override user preferences too aggressively"

**Solution**: Be explicit in user-level file
```markdown
# ~/.codex/AGENTS.md

## Critical Rules (NEVER OVERRIDE)

These rules apply to ALL projects:
- [Critical rules that should never be overridden]
```

---

## Maintenance Checklist

### Monthly Review

**For Claude Code**:
- [ ] Review `~/.claude/CLAUDE.md` for outdated info
- [ ] Update `~/.claude/contextual/*.md` with new learnings
- [ ] Check triggers in `~/.claude/core/TRIGGERS.md`
- [ ] Update project-level `.claude/TESTING.md` if needed
- [ ] Verify token usage: `claude mcp list`

**For Codex CLI**:
- [ ] Review `~/.codex/AGENTS.md` for outdated info
- [ ] Update project-level `AGENTS.md` with team learnings
- [ ] Check task-level `AGENTS.md` for completed features
- [ ] Verify config: `cat ~/.codex/config.toml`
- [ ] Clean up old project overrides

---

## Resources

### Documentation
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Codex CLI Documentation](https://developers.openai.com/codex/cli/)
- [Codex Configuration Guide](https://developers.openai.com/codex/local-config/)

### Related Guides
- [Configure Project Testing](./configure-project-testing.md)
- [Optimize Context Usage](./optimize-claude-context-usage.md)

### Files Created
- `~/.claude/contextual/TESTING_STANDARDS.md` - Comprehensive testing guide
- `~/.codex/AGENTS.md` - User-level instructions for Codex
- This document - Cross-platform comparison

---

## Summary

**Key Takeaways**:

1. ✅ **Both systems support modularity** (trigger-based vs hierarchical)
2. ✅ **Same testing standards** can be shared across both
3. ✅ **Token efficiency** achieved through different mechanisms
4. ✅ **Project-specific overrides** supported in both
5. ✅ **Best practice**: Separate focused files over monolithic

**Choose Based On**:
- **Claude Code**: Better for conditional loading, larger context window
- **Codex CLI**: Better for hierarchical overrides, cascading configs
- **Both**: Use modular approach for maintainability and efficiency

**Migration Path**:
- Start with user-level modular files
- Add project-level configs as needed
- Refine based on actual usage patterns
- Review and update monthly
