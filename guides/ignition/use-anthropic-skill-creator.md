# How to Use the Anthropic Skill Creator

## Overview

The Anthropic Skill Creator is an **official Anthropic skill** that guides you through creating custom Claude skills using a collaborative, question-driven approach. Unlike autonomous generation tools, this skill works with you interactively to understand your needs and iteratively refine your skill.

**Best for**: Custom skills, unique workflows, learning the skill creation process

**Time investment**: Variable (depends on complexity and iterations)

**Output**: Refined custom skills with official Anthropic patterns

## When to Use This Skill

**Use the Anthropic Skill Creator when you need**:
- ✅ Custom skills for unique workflows
- ✅ Skills requiring human judgment and domain expertise
- ✅ Interactive refinement and iterative development
- ✅ Learning how to create skills properly
- ✅ Skills with specific user requirements that need clarification

**Don't use when**:
- ❌ You need automation agents (use agent-skill-creator instead)
- ❌ The workflow is purely API-driven data collection
- ❌ You want autonomous generation without interaction
- ❌ You need a production agent in under 2 hours

## Getting Started

### Prerequisites

- Claude Code installed and configured
- Anthropic Skill Creator installed in `~/.claude/skills/anthropic-skill-creator/`
- Basic understanding of what you want to build

### Activation

The skill activates when you:
- Explicitly request skill creation: "Create a skill for..."
- Ask about skill development: "How do I make a skill for...?"
- Need skill guidance: "Help me build a skill that..."

## The 6-Step Collaborative Process

### Step 1: Understanding with Concrete Examples

**What happens**: Claude asks questions to understand your skill requirements

**Your role**:
- Describe what the skill should do
- Provide concrete examples of how you'd use it
- Clarify trigger conditions

**Example conversation**:
```
You: "I want to create a skill for managing brand guidelines"

Claude: "What functionality should this skill support?"
You: "Loading brand colors, fonts, logos, and ensuring consistency"

Claude: "Can you give examples of how you'd use this?"
You: "Show me our brand colors for this design"
You: "What's our primary font?"
You: "Check if this hex color matches our palette"

Claude: "What would trigger this skill?"
You: "Questions about brand, design system, style guide, colors, fonts"
```

**Tips**:
- Be specific with examples
- Think about edge cases
- Describe the ideal user experience

### Step 2: Planning Reusable Contents

**What happens**: Claude analyzes your examples and plans skill components

**Claude identifies**:
- **Scripts**: Code that should be executable (deterministic tasks)
- **References**: Documentation to load as needed (schemas, guidelines)
- **Assets**: Files used in outputs (templates, logos, fonts)

**Example for brand guidelines skill**:
```
Reusable Contents Identified:

Scripts:
- scripts/validate_color.py - Check hex codes against palette
- scripts/generate_palette.py - Export palette in various formats

References:
- references/brand_colors.md - Official color definitions
- references/typography.md - Font specifications and usage
- references/logo_guidelines.md - Logo usage rules

Assets:
- assets/logo-primary.svg - Primary logo
- assets/logo-variations/ - Logo variations (white, black, color)
- assets/fonts/ - Brand font files
```

**Your role**:
- Review Claude's analysis
- Provide missing resources (brand docs, files)
- Clarify any misunderstandings

### Step 3: Initializing the Skill

**What happens**: Claude uses the initialization script to create skill structure

**Command executed**:
```bash
scripts/init_skill.py brand-guidelines --path ~/.claude/skills/
```

**Creates**:
```
brand-guidelines/
├── SKILL.md (template)
├── scripts/ (example files)
├── references/ (example files)
└── assets/ (example directory)
```

**Your role**: Minimal - just verify the structure was created

### Step 4: Editing the Skill

**What happens**: Claude populates the skill with actual content

**4a. Add Reusable Contents**
```
Adding resources:
├── references/brand_colors.md (from your brand docs)
├── references/typography.md (from your brand docs)
├── assets/logo-primary.svg (from your assets)
└── scripts/validate_color.py (new script)
```

**Note**: You may need to provide actual files from your organization

**4b. Update SKILL.md**

Claude creates comprehensive documentation:
```markdown
---
name: brand-guidelines
description: Brand management skill for [Company]. Use when questions involve brand colors, typography, logos, design system, or visual identity. Triggers on: brand, style guide, colors, fonts, logo, design system.
---

# Brand Guidelines

## Purpose
[What the skill does]

## When to Use
[Activation conditions]

## Using the Skill
[Step-by-step workflows]

## Resources
[How to use scripts, references, assets]
```

**Writing style**: Imperative/infinitive form (verb-first instructions)

**Your role**:
- Review SKILL.md for accuracy
- Suggest improvements
- Provide additional context

### Step 5: Packaging the Skill

**What happens**: Claude validates and packages your skill

**Validation checks**:
- ✓ YAML frontmatter format correct
- ✓ Required fields present (`name`, `description`)
- ✓ Skill naming conventions followed
- ✓ Description quality sufficient
- ✓ File organization proper

**Command**:
```bash
scripts/package_skill.py ~/.claude/skills/brand-guidelines
```

**Output**: `brand-guidelines.zip` (ready to share)

**If validation fails**: Claude reports errors and you fix them before re-packaging

### Step 6: Iteration

**What happens**: You test the skill and request improvements

**Iteration workflow**:
1. Use skill on real task
2. Notice what works / doesn't work
3. Tell Claude what needs improvement
4. Claude updates skill
5. Test again
6. Repeat until satisfied

**Example iteration**:
```
You: "The color validation script doesn't handle RGB values, only hex"

Claude: [Updates scripts/validate_color.py to handle RGB]

You: "The logo guidelines reference should include spacing requirements"

Claude: [Adds spacing section to references/logo_guidelines.md]
```

## Practical Examples

### Example 1: Brand Guidelines Skill

**Initial request**:
```
"Create a skill for managing our company's brand guidelines"
```

**Questions Claude asks**:
- What aspects of brand guidelines? (colors, fonts, logos, voice?)
- How will users interact with it? (queries, validation, generation?)
- What resources do you have? (existing brand docs, asset files?)
- Who's the audience? (designers, developers, marketers?)

**Result**: Custom skill with your brand resources that validates designs and provides guidelines on demand

### Example 2: Database Schema Skill

**Initial request**:
```
"Help me create a skill for our production database schemas"
```

**Resources needed**:
- Database schema definitions (tables, columns, relationships)
- Query examples
- Data dictionaries

**Reusable contents**:
```
references/
├── user_schema.md
├── product_schema.md
├── order_schema.md
└── relationships.md

scripts/
└── validate_query.py (validates SQL against schema)
```

**Result**: Skill that provides schema information and validates queries

### Example 3: Internal API Skill

**Initial request**:
```
"Build a skill for our internal REST API documentation"
```

**Resources needed**:
- API documentation
- Authentication requirements
- Code examples for each endpoint

**Reusable contents**:
```
references/
├── authentication.md
├── users_api.md
├── products_api.md
└── orders_api.md

assets/
└── api-examples/
    ├── user_create.py
    ├── product_list.py
    └── order_update.py
```

**Result**: Skill that explains API usage and provides working code examples

## Best Practices

### Preparation

**Before starting**:
1. **Gather resources**: Collect existing documentation, files, and examples
2. **Define scope**: Know what the skill should and shouldn't do
3. **Identify trigger words**: Think about how users will ask for this skill
4. **Consider audience**: Who will use this and what's their skill level?

### During Creation

**Effective collaboration**:
- Answer Claude's questions completely
- Provide real examples, not generic ones
- Share actual files when possible
- Review generated content carefully
- Ask clarifying questions if unclear

**Resource organization**:
- Keep references focused (one topic per file)
- Use descriptive filenames
- Include search patterns for large files
- Separate output resources (assets) from documentation (references)

### Progressive Disclosure

**Optimize for context efficiency**:
1. **SKILL.md**: Essential instructions only (< 5K words)
2. **References**: Detailed information loaded as needed
3. **Scripts**: Executable code (may not need to be read)

**Avoid**:
- Duplicating information between SKILL.md and references
- Putting detailed examples in SKILL.md when references would work better
- Creating one giant SKILL.md instead of using bundled resources

### Quality Guidelines

**SKILL.md description**:
- Be specific about when to use skill
- Include clear trigger keywords
- Define negative scope (when NOT to activate)
- Use third-person ("This skill should be used when...")

**Bundled resources**:
- Scripts: For repeated code generation or deterministic tasks
- References: For documentation that informs Claude's work
- Assets: For files used in output

**Validation**:
- Test skill on actual use cases before considering it done
- Verify activation triggers work
- Check that references are loaded correctly
- Ensure scripts execute successfully

## Troubleshooting

### Skill Not Activating

**Problem**: Skill doesn't trigger when expected

**Solutions**:
1. Check SKILL.md description has specific trigger keywords
2. Verify frontmatter YAML is valid
3. Test with explicit skill references
4. Broaden description if too specific

### Resources Not Loading

**Problem**: References aren't being used

**Solution**:
1. Verify file paths in SKILL.md are correct
2. Check reference files exist in correct directories
3. Ensure SKILL.md mentions when to load each reference
4. For large files, add grep patterns to SKILL.md

### Scripts Failing

**Problem**: Bundled scripts have errors

**Solutions**:
1. Test scripts manually outside Claude
2. Check for missing dependencies
3. Verify paths and permissions
4. Add error handling and logging

### Validation Errors

**Problem**: Packaging script reports issues

**Solutions**:
1. Fix YAML frontmatter syntax
2. Add missing required fields
3. Ensure name follows conventions (lowercase-with-hyphens)
4. Improve description quality

## Comparison: Anthropic Skill Creator vs Agent Skill Creator

### Anthropic Skill Creator (This Tool)

**Approach**: Interactive/Collaborative
- Question-driven requirements gathering
- Iterative refinement with your feedback
- Learn the skill creation process
- Best for custom, unique skills

**Example use case**:
```
"Create a skill for our company's specific brand guidelines"
→ Claude asks questions about your brand
→ You provide brand docs and assets
→ Together you refine the skill
→ Result: Custom skill tailored to your organization
```

### Agent Skill Creator (Autonomous Generation)

**Approach**: Autonomous/Automatic
- Minimal user input required
- Researches APIs automatically
- Creates production agents fast (30-120 min)
- Best for workflow automation

**Example use case**:
```
"Automate my daily 2h USDA crop data analysis"
→ Agent researches USDA API
→ Agent designs analysis functions
→ Agent generates complete code
→ Result: Production agent with tests and docs
```

### Decision Matrix

| Factor | Anthropic Skill Creator | Agent Skill Creator |
|--------|------------------------|-------------------|
| **User Input** | High (interactive) | Low (autonomous) |
| **Time** | Variable (iterative) | Fast (30-120 min) |
| **Best For** | Custom skills | Workflow automation |
| **Output** | Refined custom skills | Production agents |
| **Learning** | High (you learn process) | Low (autonomous) |
| **Use Case** | Brand guidelines, internal docs | API automation, data analysis |

**When to use both**:
1. Use Agent Skill Creator for initial generation
2. Use Anthropic Skill Creator for refinement and customization
3. Combine autonomous speed with collaborative refinement

## Advanced Topics

### Multi-File References

For large documentation (> 10K words), split into multiple reference files:

```
references/
├── api_overview.md (general info)
├── authentication.md (auth details)
├── users_endpoint.md (user API)
└── products_endpoint.md (product API)
```

Add grep patterns to SKILL.md:
```markdown
To find user endpoint information: `grep -r "POST /users" references/`
```

### Conditional Resource Loading

Specify when to load each reference:

```markdown
**When user asks about authentication**: Read `references/authentication.md`
**When user asks about users API**: Read `references/users_endpoint.md`
**When generating code examples**: Check `assets/api-examples/`
```

### Script Execution Patterns

```python
# scripts/validate_color.py
# Can be executed without loading into context

#!/usr/bin/env python3
import sys

def validate_color(hex_color, brand_colors):
    """Check if color is in brand palette."""
    # Implementation
    pass

if __name__ == "__main__":
    color = sys.argv[1]
    result = validate_color(color, BRAND_COLORS)
    print(result)
```

### Asset Organization

```
assets/
├── templates/          # File templates
│   ├── email.html
│   └── slide.pptx
├── fonts/             # Brand fonts
│   ├── primary.ttf
│   └── secondary.ttf
└── logos/             # Logo variations
    ├── primary.svg
    ├── white.svg
    └── black.svg
```

## Resources

### Official Documentation

- **SKILL.md in skill**: Complete reference for skill creation process
- **init_skill.py**: Template generation script
- **package_skill.py**: Validation and packaging script
- **Anthropic Documentation**: https://claude.ai/docs

### Example Skills

Study existing skills for patterns:
- Template skill: `~/.claude/skills/template-skill/`
- Other installed skills: `~/.claude/skills/`

### Community

- Share skills with your team
- Document learnings
- Contribute improvements

## Summary

**Key takeaways**:
- Anthropic Skill Creator is **collaborative and interactive**
- 6-step process: Understand → Plan → Init → Edit → Package → Iterate
- Best for **custom skills** requiring domain expertise
- Uses **progressive disclosure** (SKILL.md + references + assets)
- Complements **agent-skill-creator** for different use cases

**Next steps**:
1. Gather resources for your skill
2. Start with a clear example of what you want
3. Answer Claude's questions completely
4. Test and iterate until satisfied
5. Share your skill with others

**Remember**: This is a collaborative process. The better your examples and feedback, the better your skill will be!
