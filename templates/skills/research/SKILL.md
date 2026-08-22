---
name: research-templates
description: Comprehensive templates and methodologies for conducting systematic technical research. Use when evaluating technologies, libraries, frameworks, or tools. Provides structured templates for research reports, quick-start guides, technology comparisons, evaluation matrices, and implementation guides.
---

# Research Templates

## Overview

This skill provides production-ready templates and systematic methodologies for conducting technical research. It complements the @technical-researcher agent by providing standardized formats, evaluation frameworks, and best practices for comparing technologies and making evidence-based recommendations.

**When to use this skill:**
- Evaluating technology options (frameworks, libraries, databases, tools)
- Creating research reports for technical decisions
- Comparing multiple solutions systematically
- Documenting quick-start guides for new technologies
- Building implementation guides for adopted technologies
- Conducting architecture research and vendor evaluations

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive methodologies.

## Available Templates

This skill provides 5 production-ready templates in `assets/`:

### 1. Research Report Template
**File:** `assets/research-report-template.md`

Complete technical research documentation format including:
- Research question and context
- Requirements (functional & non-functional)
- Options evaluated (detailed analysis of 3+ options)
- Comparison matrix (side-by-side feature comparison)
- Recommendation (clear choice with rationale)
- Implementation guidance (immediate next steps)
- Risk assessment and mitigation
- Decision record for future reference

**Use when:** Conducting comprehensive technology evaluations requiring formal documentation.

**Example usage:**
```markdown
# Technical Research: State Management for React Application

## Research Question
Which state management solution (Redux, Zustand, Jotai, Recoil) best fits our medium-sized React application?

## Context
[Copy template sections and fill in...]
```

### 2. Quick-Start Template
**File:** `assets/quick-start-template.md`

5-minute setup guide format with:
- Prerequisites checklist
- One-line installation commands
- Minimal working example (smallest possible code)
- Verification steps
- Common tasks with code examples
- Troubleshooting common errors
- Learn more resources

**Use when:** Creating onboarding documentation for newly adopted technologies.

**Example usage:**
```markdown
# Quick Start: FastAPI

## 5-Minute Setup

### Prerequisites
- Python 3.7+
- pip

### Installation
```bash
pip install fastapi uvicorn
```
[...]
```

### 3. Technology Comparison Template
**File:** `assets/technology-comparison-template.md`

Side-by-side comparison format with:
- Quick comparison table (at-a-glance)
- Detailed analysis by dimension
- Use case recommendations ("Choose X when...")
- Migration considerations

**Use when:** Comparing 2-4 similar technologies and need clear differentiation.

**Example usage:**
```markdown
# Technology Comparison: PostgreSQL vs MySQL vs MongoDB

## Quick Comparison

| Feature | PostgreSQL | MySQL | MongoDB | Winner |
|---------|-----------|-------|---------|--------|
| ACID | Full | Full | Partial | PostgreSQL/MySQL |
[...]
```

### 4. Evaluation Matrix Template
**File:** `assets/evaluation-matrix-template.md`

Systematic weighted scoring matrix with:
- Technical criteria (performance, scalability, reliability, security)
- Developer experience criteria (ease of use, docs, learning curve)
- Ecosystem & community criteria
- Business criteria (cost, licensing, support)
- Compatibility criteria
- Weighted scoring methodology (High/Medium/Low weights)
- Decision factors (must-haves, nice-to-haves, dealbreakers)
- Risk assessment matrix

**Use when:** Need objective, systematic evaluation with quantified scoring.

**Example usage:**
```markdown
# Evaluation Matrix: Frontend Frameworks

| Criterion | Weight | React | Vue | Svelte | Notes |
|-----------|--------|-------|-----|--------|-------|
| **Performance** | High | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Svelte smallest bundle |

Weighted Score:
- React: 87/100
- Vue: 78/100
- Svelte: 72/100
```

### 5. Implementation Guide Template
**File:** `assets/implementation-guide-template.md`

Step-by-step implementation documentation with:
- Getting started (installation, basic config, hello world)
- Core implementation steps (numbered, progressive)
- Best practices (5 key practices with explanations)
- Common pitfalls (warnings with solutions)
- Advanced usage patterns
- Testing strategies (unit & integration)
- Deployment guidance (dev & production)
- Troubleshooting (error messages with solutions)
- Additional resources

**Use when:** Creating comprehensive implementation documentation for adopted technology.

**Example usage:**
```markdown
# Implementation Guide: Redis Caching Layer

## Getting Started

### Installation
```bash
docker run -d -p 6379:6379 redis:7
```

### Step 1: Connect to Redis
[Code example with Python/Redis]
[...]
```

## Reference Guides

This skill provides 4 comprehensive reference guides in `references/`:

### 1. Research Methodology Guide
**File:** `references/research-methodology-guide.md`

Systematic approaches for conducting technical research with:

**4-Phase Research Process:**
1. **Understanding the Problem** - Clarify requirements, identify constraints, define success criteria
2. **Discovery** - Gather information from authoritative sources (docs, code, community, benchmarks)
3. **Evaluation** - Systematically assess options against criteria (scoring, hands-on testing)
4. **Synthesis** - Distill findings into clear recommendations with implementation roadmap

**Additional Topics:**
- Research quality standards (authoritative sources, up-to-date info, verified claims)
- Common research pitfalls (analysis paralysis, popularity bias, recency bias, shallow research)
- Research time guidelines (quick 30min, standard 2-4hr, deep 1-2 days)
- Advanced techniques (differential analysis, decision trees, POC evaluation)

**Use when:** Need systematic framework for conducting research from start to finish.

### 2. Source Evaluation Guide
**File:** `references/source-evaluation-guide.md`

How to assess credibility, authority, and reliability of information sources:

**Source Hierarchy (5 Tiers):**
1. **Primary Authoritative** - Official docs, API references (Highest trust)
2. **Source Code & Examples** - GitHub repos, test suites (High trust)
3. **Community Resources** - Stack Overflow, blogs, tutorials (Medium trust)
4. **Benchmarks & Comparisons** - Independent benchmarks (Medium trust)
5. **Commercial/Vendor** - Marketing materials, whitepapers (Low trust, verify independently)

**Additional Topics:**
- Recency evaluation (fast-moving vs stable tech, version awareness)
- Authority assessment (author credentials, publication venue)
- Verification strategies (cross-reference, reproducibility, expert validation)
- Source quality scorecard (weighted scoring for source credibility)

**Use when:** Need to evaluate reliability of research sources and avoid misinformation.

### 3. Comparison Criteria Guide
**File:** `references/comparison-criteria-guide.md`

Standard dimensions for systematically comparing technologies:

**5 Core Comparison Dimensions:**
1. **Technical Performance** - Speed, resource usage, scalability, reliability
2. **Developer Experience** - Learning curve, documentation, API design, debugging
3. **Ecosystem & Community** - Community size, plugins, integrations, corporate backing
4. **Business & Licensing** - Cost, licensing, support, vendor lock-in, TCO
5. **Compatibility** - Platform support, integration, migration path, breaking changes

**Specialized Criteria:**
- For databases (data model, ACID, replication)
- For frontend frameworks (rendering, state management, bundle size)
- For CI/CD tools (config format, build minutes, self-hosted)

**Weighted Scoring Methodology:**
- Define importance weights (High=3x, Medium=2x, Low=1x)
- Score each criterion (1-5 stars)
- Calculate weighted totals
- Check for dealbreakers

**Use when:** Need standard evaluation framework to compare technologies objectively.

### 4. Recommendation Framework
**File:** `references/recommendation-framework.md`

How to synthesize research into clear, actionable recommendations:

**Three-Part Recommendation Structure:**
1. **The Recommendation** - What to do (specific, not vague)
2. **The Rationale** - Why this is best (evidence-based, not generic)
3. **The Caveats** - When this might not be best (edge cases)

**Decision Confidence Levels:**
- **High Confidence (90%+)** - Clear winner, strong evidence, low risk
- **Medium Confidence (60-80%)** - Best option available, but with caveats
- **Low Confidence (<60%)** - No clear winner, need more information (POC recommended)

**Additional Topics:**
- Trade-off communication ("Yes, but..." framework)
- Context-aware recommendations (project phase, team experience)
- Runner-up options (always provide fallback)
- Implementation guidance (immediate next steps, risk mitigation)
- Decision documentation (decision records for future reference)
- Recommendation anti-patterns (the hedge, the buzzword, the technology hammer)

**Use when:** Need to synthesize research findings into actionable, well-justified recommendations.

## Usage Patterns

### Pattern 1: Quick Technology Evaluation

**Scenario:** Need to choose between 2-3 well-known options quickly.

**Process:**
1. Read `research-methodology-guide.md` → Quick Research (30min-1hr) section
2. Use `technology-comparison-template.md` for side-by-side comparison
3. Use `recommendation-framework.md` → Quick confidence assessment

**Time:** 1-2 hours

### Pattern 2: Standard Research Project

**Scenario:** Moderate-impact decision requiring systematic evaluation.

**Process:**
1. Read `research-methodology-guide.md` → Standard Research (2-4hr) section
2. Use `evaluation-matrix-template.md` for weighted scoring
3. Conduct hands-on POC for top 2 options
4. Use `research-report-template.md` for documentation
5. Use `recommendation-framework.md` for synthesis

**Time:** 2-4 hours

### Pattern 3: Deep Architecture Research

**Scenario:** Critical architectural decision requiring comprehensive analysis.

**Process:**
1. Read all 4 reference guides completely
2. Use `research-report-template.md` as primary structure
3. Use `evaluation-matrix-template.md` for systematic comparison
4. Conduct POCs for all viable options (3+)
5. Use `comparison-criteria-guide.md` for specialized criteria
6. Use `source-evaluation-guide.md` to validate all claims
7. Use `recommendation-framework.md` for high-confidence recommendation
8. Create `implementation-guide-template.md` for chosen solution

**Time:** 1-2 days

### Pattern 4: Post-Decision Documentation

**Scenario:** Already chose technology, need to document for team.

**Process:**
1. Use `quick-start-template.md` for immediate team onboarding
2. Use `implementation-guide-template.md` for comprehensive documentation
3. Use decision record template from `recommendation-framework.md`

**Time:** 2-4 hours

### Pattern 5: Source Verification

**Scenario:** Found information but need to verify credibility.

**Process:**
1. Read `source-evaluation-guide.md` → Source Hierarchy section
2. Apply source quality scorecard
3. Cross-reference with 2-3 additional sources
4. Document confidence level

**Time:** 15-30 minutes per source

## Integration with @technical-researcher

This skill is designed to complement the @technical-researcher agent:

**Agent's Role:**
- Conducts research based on user requirements
- Applies critical thinking and domain expertise
- Makes judgment calls on trade-offs

**Skill's Role:**
- Provides standardized templates for consistency
- Offers methodologies for systematic evaluation
- Ensures best practices are followed

**Workflow:**
```markdown
User: "@technical-researcher, evaluate state management libraries for React"

Agent:
1. Loads research-templates skill
2. Reads research-methodology-guide.md for process
3. Reads comparison-criteria-guide.md for evaluation dimensions
4. Conducts research using systematic methodology
5. Uses evaluation-matrix-template.md to score options
6. Uses recommendation-framework.md to synthesize findings
7. Fills out research-report-template.md for final output
```

## Best Practices

### 1. Start with Methodology
Always read `research-methodology-guide.md` first to understand the systematic 4-phase process.

### 2. Use Appropriate Template
- Quick decision → `technology-comparison-template.md`
- Systematic evaluation → `evaluation-matrix-template.md`
- Comprehensive research → `research-report-template.md`
- Post-decision docs → `quick-start-template.md` + `implementation-guide-template.md`

### 3. Verify Sources
Use `source-evaluation-guide.md` to assess all information sources. Don't trust single sources for critical decisions.

### 4. Quantify When Possible
Use weighted scoring from `evaluation-matrix-template.md` for objective comparisons. Avoid purely subjective assessments.

### 5. Document Decisions
Always use decision record template from `recommendation-framework.md` to preserve rationale for future reference.

### 6. State Confidence Level
Use confidence levels (High/Medium/Low) from `recommendation-framework.md` to calibrate expectations.

### 7. Provide Runner-Up
Always document second-best option and when to choose it instead.

## Resources

### assets/
Template files designed to be copied and customized:

- **research-report-template.md** - Complete research documentation format
- **quick-start-template.md** - 5-minute setup guide format
- **technology-comparison-template.md** - Side-by-side comparison format
- **evaluation-matrix-template.md** - Weighted scoring matrix format
- **implementation-guide-template.md** - Step-by-step implementation format

**Usage:** Copy template, fill in sections with research findings, customize as needed.

### references/
Comprehensive reference guides loaded into context:

- **research-methodology-guide.md** - Systematic 4-phase research process with pitfalls, time guidelines, and advanced techniques
- **source-evaluation-guide.md** - 5-tier source hierarchy, recency evaluation, authority assessment, verification strategies
- **comparison-criteria-guide.md** - 5 core comparison dimensions, specialized criteria, weighted scoring methodology
- **recommendation-framework.md** - 3-part recommendation structure, confidence levels, trade-off communication, decision documentation

**Usage:** Read relevant sections to inform research process and decision-making.

## Examples

### Example 1: Choosing a Database

```markdown
User: "Help me choose between PostgreSQL, MySQL, and MongoDB for an e-commerce platform"

Process:
1. Read research-methodology-guide.md → Standard Research section
2. Read comparison-criteria-guide.md → For Databases section
3. Use evaluation-matrix-template.md:
   - Technical: ACID, performance, scalability
   - Business: Cost, licensing, support
   - Compatibility: Integration with existing stack
4. Hands-on POC: Test checkout flow with PostgreSQL & MongoDB
5. Use recommendation-framework.md → High Confidence template
6. Fill out research-report-template.md with findings

Output:
- Recommendation: PostgreSQL (HIGH CONFIDENCE - 90%)
- Rationale: ACID compliance critical for financial transactions, proven e-commerce fit (Shopify, Instagram), team has experience
- Runner-up: MongoDB (choose if schema flexibility > transactional integrity)
- Implementation: Use quick-start-template.md for team onboarding
```

### Example 2: Framework Comparison

```markdown
User: "Compare React, Vue, and Svelte for our team"

Process:
1. Read research-methodology-guide.md → Quick Research section
2. Use technology-comparison-template.md for side-by-side
3. Read comparison-criteria-guide.md → For Frontend Frameworks
4. Use source-evaluation-guide.md to verify benchmark claims
5. Use recommendation-framework.md → Medium Confidence (team context)

Output:
- Quick Comparison table (performance, ecosystem, learning curve)
- Detailed analysis by dimension
- Use case recommendations:
  - Choose React when: Large team, need ecosystem
  - Choose Vue when: Easier learning curve prioritized
  - Choose Svelte when: Performance critical, small team
```

### Example 3: Vendor Evaluation

```markdown
User: "Evaluate cloud providers (AWS, Azure, GCP) for our startup"

Process:
1. Read all 4 reference guides (deep research)
2. Use evaluation-matrix-template.md with weighted scoring:
   - Cost: HIGH weight (startup budget-constrained)
   - Ecosystem: HIGH weight (need integrations)
   - Performance: MEDIUM weight (good enough okay)
3. Read source-evaluation-guide.md → Be cautious of vendor materials
4. Cross-reference independent benchmarks
5. Use recommendation-framework.md → Context-aware (startup phase)
6. Fill out research-report-template.md

Output:
- Recommendation: GCP (MEDIUM CONFIDENCE - 70%)
- Rationale: Best free tier for startups, simpler pricing, team has experience
- Caveat: AWS has larger ecosystem, revisit at 100k users
- Implementation: Use quick-start-template.md + implementation-guide-template.md
```

## Tips & Tricks

### Tip 1: Customize Templates
Templates are starting points - adapt to your specific needs. Delete irrelevant sections, add project-specific criteria.

### Tip 2: Version Control
Store completed research reports in `docs/research/` or similar. They're valuable references for future decisions.

### Tip 3: Progressive Disclosure
Don't read all reference guides upfront. Start with methodology, then load relevant guides as needed.

### Tip 4: Measure Confidence
Low confidence (<60%)? Do a POC before committing. Medium confidence (60-80%)? Document risks and mitigation.

### Tip 5: Set Review Dates
All decisions should have scheduled review dates or trigger conditions (e.g., "revisit at 100k users").

### Tip 6: Favor Evidence
Use `source-evaluation-guide.md` scorecard for any claim that influences decision. Benchmark everything testable.

---

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @technical-researcher - Primary consumer of this skill's templates and methodologies
