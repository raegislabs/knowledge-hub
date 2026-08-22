# How to Optimize Claude Code Context Usage

**Goal**: Reduce baseline memory usage from ~113k tokens (57%) to ~55k tokens (28%) or better

**Savings**: ~60k tokens (30% of 200k budget freed up)

---

## Quick Summary

**Two optimizations**:
1. **Memory files**: Lazy-loading architecture (saves 24.5k tokens)
2. **MCP servers**: Disable unused servers (saves 30.4k tokens per project)

**Total**: ~55k tokens saved, 2.5x more working memory

---

## Part 1: Memory File Optimization (One-Time Setup)

### What This Does

Restructures your `~/.claude/` directory to load documentation only when needed.

**Before**: 31.5k tokens always loaded
**After**: 7k tokens baseline, contextual files loaded on demand

### Setup Steps

1. **Verify current usage**:
   ```bash
   # In Claude Code
   /context

   # Look for "Memory files" - should show ~31.5k tokens
   ```

2. **The optimization is already applied** if you see:
   ```
   Memory files: 7.0k tokens (3.5%)
   ```

3. **If not optimized**, the framework files should be in:
   ```
   ~/.claude/core/              # Always loaded
   ~/.claude/contextual/        # Loaded on demand
   ~/.claude/archive/           # Original files (backup)
   ```

### How Lazy-Loading Works

**Baseline** (always loaded):
- `~/.claude/core/TRIGGERS.md` - Activation patterns
- `~/.claude/core/PRINCIPLES.md` - Core philosophy
- `~/.claude/CLAUDE.md` - User essentials

**Contextual** (loaded when triggered):
- `contextual/MODE_LIBRARY.md` - When modes activate
- `contextual/MCP_GUIDES.md` - When MCP servers used
- `contextual/BUSINESS_FRAMEWORK.md` - With `/sc:business-panel`
- `contextual/RESEARCH_DEEP.md` - With `/sc:research --deep`

**Example**:
```bash
# Session start: 7k tokens baseline
/sc:business-panel @doc.pdf
# Temporarily loads: BUSINESS_FRAMEWORK.md (spikes to 19k)
# After task: Returns to 7k baseline
```

---

## Part 2: MCP Server Optimization (Per-Project or Global)

### What This Does

Disables unused MCP servers to save ~30k tokens per project.

**Recommended to disable**:
- `chrome-devtools` - 16.5k tokens (redundant with Playwright)
- `playwright` - 10.5k tokens (not needed for template/docs work)
- `magic` - 3.4k tokens (not needed for non-UI work)

**Keep active**:
- `linear` - 15.5k tokens (project management)
- `sequential-thinking` - 1.5k tokens (complex reasoning)
- `context7` - minimal (library docs)
- `tavily` - minimal (web research)
- `serena` - moderate (project memory)
- `morphllm` - moderate (fast edits)

### Option A: Apply to All Projects (Recommended)

**Best for**: Consistent optimization across all projects

```bash
# Run the global application script
~/.claude/scripts/apply-mcp-to-all-projects.sh

# Type 'y' when prompted

# Restart Claude Code
```

**What this does**:
- Adds `disabledMcpServers` to ALL projects in `~/.claude.json`
- Saves ~30k tokens per project
- Creates backup first (safe)

**After**:
- All projects optimized
- Can re-enable for specific projects if needed

### Option B: Apply Per-Project

**Best for**: Selective optimization as you work

**Easy way** (recommended):
```bash
# Navigate to your project
cd ~/path/to/project

# Run the command
/init-mcp

# Restart Claude Code
```

**Manual way**:
```bash
# For current project only
PROJECT_PATH=$(pwd)
jq --arg p "$PROJECT_PATH" \
   '.projects[$p].disabledMcpServers = ["chrome-devtools", "playwright", "magic"]' \
   ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# Restart Claude Code
```

### Re-enabling for Specific Projects

If a UI/web project needs playwright or magic:

```bash
# Keep only chrome-devtools disabled
PROJECT="/path/to/ui-project"
jq --arg p "$PROJECT" \
   '.projects[$p].disabledMcpServers = ["chrome-devtools"]' \
   ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# Or re-enable everything
jq --arg p "$PROJECT" \
   'del(.projects[$p].disabledMcpServers)' \
   ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# Restart Claude Code
```

---

## Verification

### Check Optimization Status

```bash
# In Claude Code
/context
```

**Look for**:
```
Memory files: 7.0k tokens (3.5%)      ← Should be ~7k (was ~31k)
MCP tools: 22.3k tokens (11.1%)       ← Should be ~22k (was ~57k)
Total: 94k/200k (47%)                 ← Should be <50% (was >60%)
Free space: 106k (53%)                ← Should be >50% (was ~34%)
```

### Verify MCP Configuration

```bash
# Check disabled servers for current project
jq '.projects["'$(pwd)'"].disabledMcpServers' ~/.claude.json

# Should show:
# ["chrome-devtools", "playwright", "magic"]
```

### Verify Lazy-Loading

```bash
# Check core files exist
ls -la ~/.claude/core/
# Should show: TRIGGERS.md, PRINCIPLES.md

# Check contextual files exist
ls -la ~/.claude/contextual/
# Should show: MODE_LIBRARY.md, MCP_GUIDES.md, etc.

# Check originals archived
ls -la ~/.claude/archive/
# Should show: CLAUDE_ORIGINAL.md, BUSINESS_*.md, MODE_*.md, etc.
```

---

## Project Type Recommendations

### Template/Docs/YAML Projects
```bash
# Disable: chrome-devtools, playwright, magic
# Keep: linear, sequential-thinking, context7, tavily
# Savings: 30.4k tokens
```

### Backend/API Projects
```bash
# Disable: chrome-devtools, playwright, magic
# Keep: linear, sequential-thinking, tavily, serena
# Savings: 30.4k tokens
```

### UI/Web Projects
```bash
# Disable: chrome-devtools only
# Keep: playwright, magic, linear, sequential-thinking
# Savings: 16.5k tokens
```

### Full-Stack Projects
```bash
# Disable: chrome-devtools only
# Keep: playwright, magic, linear, sequential-thinking, tavily
# Savings: 16.5k tokens
```

---

## Rollback Instructions

### Restore Original Memory Files

```bash
# Restore original CLAUDE.md
cp ~/.claude/archive/CLAUDE_ORIGINAL.md ~/.claude/CLAUDE.md

# Restore framework files
cp ~/.claude/archive/*.md ~/.claude/

# Remove new directories
rm -rf ~/.claude/core ~/.claude/contextual
```

### Re-enable MCP Servers

```bash
# For specific project
PROJECT="/path/to/project"
jq --arg p "$PROJECT" \
   'del(.projects[$p].disabledMcpServers)' \
   ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# For all projects
jq '.projects |= with_entries(.value.disabledMcpServers = [])' \
   ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# Restart Claude Code
```

---

## Expected Results

### Before Optimization
```
Total Used: 113k/200k (57%)
├── MCP tools: 57.0k (28.5%)
├── Memory files: 31.5k (15.8%)
└── Messages: ~24.5k

Available: 87k (43%)
```

### After Optimization
```
Total Used: 55k/200k (28%)
├── MCP tools: 22.3k (11.1%)
├── Memory files: 7.0k (3.5%)
└── Messages: ~26k

Available: 145k (72%)
```

### What This Enables

With 145k tokens available:
- ✅ Read 50+ files in parallel (vs 30 before)
- ✅ Complex agent orchestration workflows
- ✅ Deep research sessions with multiple sources
- ✅ Extended conversations without context pressure
- ✅ Multi-project operations

---

## Troubleshooting

### Memory files still high (>10k)

**Check**: Are framework files in the right location?
```bash
ls ~/.claude/core/
ls ~/.claude/contextual/
```

**Fix**: Original files may still be in `~/.claude/` root
```bash
mv ~/.claude/BUSINESS_*.md ~/.claude/archive/
mv ~/.claude/MODE_*.md ~/.claude/archive/
mv ~/.claude/MCP_*.md ~/.claude/archive/
```

### MCP tools still high (>30k)

**Check**: Disabled servers configured?
```bash
jq '.projects["'$(pwd)'"].disabledMcpServers' ~/.claude.json
```

**Fix**: Apply MCP optimization
```bash
~/.claude/scripts/apply-mcp-to-all-projects.sh
# Or per-project script
```

**Important**: **Restart Claude Code** after any configuration changes!

### Lazy-loading not working

**Symptom**: Memory files spike and don't return to baseline

**Check**: TRIGGERS.md references correct paths?
```bash
grep "contextual" ~/.claude/core/TRIGGERS.md
```

**Should see**: `~/.claude/contextual/` paths, not absolute paths

---

## Scripts Reference

**Located in**: `~/.claude/scripts/`

### Available Scripts

```bash
# Verify optimization status
~/.claude/scripts/verify-optimization.sh

# Apply MCP optimization to all projects
~/.claude/scripts/apply-mcp-to-all-projects.sh

# Disable MCP for single project
~/.claude/scripts/disable-mcp-servers.sh
```

---

## Documentation

**Full guides in**: `~/.claude/`

- `HOW_LAZY_LOADING_WORKS.md` - Technical explanation
- `SYSTEM_VS_PROJECT_MCP.md` - Global vs per-project MCP
- `APPLY_TO_ALL_PROJECTS_GUIDE.md` - Bulk application guide
- `MIGRATION_SUMMARY.md` - Complete migration details
- `OPTIMIZATION_QUICK_REFERENCE.md` - Quick commands
- `FINAL_RESULTS.md` - Verification and results

---

## Quick Start Checklist

- [ ] Check current context usage: `/context`
- [ ] Apply memory optimization (if needed)
- [ ] Apply MCP optimization: `~/.claude/scripts/apply-mcp-to-all-projects.sh`
- [ ] Restart Claude Code
- [ ] Verify: `/context` shows ~7k memory, ~22k MCP
- [ ] Work normally, re-enable MCP servers for specific projects if needed

**Expected result**: 55k/200k (28%) context usage, 145k available
