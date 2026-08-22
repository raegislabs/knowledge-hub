# Research Methodology Guide

## Purpose

Provide systematic approaches for conducting technical research that produces actionable, evidence-based recommendations.

## Research Process Overview

### Phase 1: Understanding the Problem

**Objective**: Clearly define what needs to be researched and why.

**Activities**:
1. **Clarify Requirements**: Understand functional and non-functional needs
2. **Identify Constraints**: Note budget, time, compatibility limitations
3. **Define Success Criteria**: What makes a solution "good enough"?
4. **Determine Scope**: Boundaries of the research (what's in/out of scope)

**Outputs**:
- Clear research question statement
- List of requirements (must-have vs nice-to-have)
- Constraints documentation
- Success criteria checklist

**Example Research Questions**:
- "Which frontend framework (React/Vue/Angular) best fits our team's skills and project requirements?"
- "What database solution provides the best balance of performance and developer experience for our use case?"
- "Which authentication library offers the strongest security with easiest implementation?"

### Phase 2: Discovery

**Objective**: Gather information from authoritative sources.

**Information Sources (in priority order)**:

1. **Official Documentation** (Highest Priority)
   - Project website and docs
   - Official API references
   - Getting started guides
   - Architecture documentation

2. **Source Code & Examples** (High Priority)
   - GitHub repository (stars, issues, PRs, activity)
   - Official example projects
   - Starter templates
   - Test suites (shows real usage)

3. **Community Resources** (Medium Priority)
   - Stack Overflow questions/answers
   - Reddit discussions (r/programming, language-specific subs)
   - Dev.to, Medium, personal blogs
   - Conference talks and presentations

4. **Benchmarks & Comparisons** (Medium Priority)
   - Independent benchmarks
   - Comparison articles
   - "X vs Y" blog posts
   - Performance metrics

5. **Commercial/Vendor Information** (Lower Priority)
   - Marketing materials (take with grain of salt)
   - Case studies
   - Whitepapers
   - Sales documentation

**Discovery Checklist**:
- [ ] Read official getting started guide
- [ ] Review API documentation structure
- [ ] Check GitHub: stars, issues, last commit, contributors
- [ ] Find 2-3 real-world usage examples
- [ ] Read 3-5 community comparisons/reviews
- [ ] Look for independent benchmarks
- [ ] Identify any red flags (abandoned, security issues, breaking changes)

### Phase 3: Evaluation

**Objective**: Systematically assess each option against criteria.

**Evaluation Dimensions**:

1. **Technical Quality**
   - Performance (speed, resource usage)
   - Scalability (handles growth)
   - Reliability (uptime, stability)
   - Security (vulnerabilities, best practices)

2. **Developer Experience**
   - Ease of use (learning curve)
   - Documentation quality
   - API design (intuitive vs complex)
   - Debugging experience
   - Development tools (IDE support, linters, formatters)

3. **Ecosystem & Community**
   - Community size and activity
   - Available plugins/extensions
   - Third-party integrations
   - Support forums and responsiveness
   - Corporate backing (stability indicator)

4. **Business Factors**
   - Cost (free, freemium, paid tiers)
   - Licensing (open-source license type, restrictions)
   - Support options (community, paid, enterprise)
   - Vendor lock-in risk
   - Long-term viability

5. **Compatibility**
   - Platform support (OS, browsers, environments)
   - Integration with existing stack
   - Migration path from current solution
   - Breaking change history

**Evaluation Methods**:

**Hands-On Testing** (Recommended):
```bash
# Create minimal proof-of-concept for each option
mkdir poc-option1 poc-option2 poc-option3

# Test setup time, basic operations, documentation clarity
time {setup && implement_basic_feature && run_tests}
```

**Scoring Matrix**:
- Use weighted criteria (see evaluation-matrix-template.md)
- Rate each option 1-5 stars per criterion
- Multiply by importance weight (High=3, Medium=2, Low=1)
- Sum total scores

**Comparative Analysis**:
- Side-by-side feature comparison
- Performance benchmarking
- Developer experience comparison (time to first working code)

### Phase 4: Synthesis

**Objective**: Distill findings into clear recommendation.

**Synthesis Activities**:

1. **Summarize Findings**
   - Key strengths of each option
   - Key weaknesses of each option
   - Notable differences between options

2. **Apply Context**
   - Match option strengths to specific requirements
   - Consider team capabilities and preferences
   - Factor in existing tech stack compatibility
   - Account for future roadmap alignment

3. **Make Recommendation**
   - Choose best option with clear rationale
   - Acknowledge trade-offs explicitly
   - Provide runner-up option (if primary choice fails)
   - Note edge cases where different option might be better

4. **Create Implementation Roadmap**
   - Immediate next steps (installation, setup)
   - Short-term tasks (basic implementation)
   - Long-term considerations (optimization, scaling)

**Synthesis Checklist**:
- [ ] Recommendation based on evidence, not preference
- [ ] Rationale clearly explains why option X > Y
- [ ] Trade-offs acknowledged and acceptable
- [ ] Implementation path is clear and actionable
- [ ] Edge cases and alternatives documented

## Research Quality Standards

### Authoritative Sources

**Prefer**:
- Official documentation
- Original source code
- Independent benchmarks
- Peer-reviewed articles
- Well-known technical blogs (with author credentials)

**Be Cautious Of**:
- Marketing materials (vendor bias)
- Outdated articles (check publication date)
- Anonymous sources (no author credentials)
- Anecdotal evidence without data
- Unreproducible benchmarks

### Up-to-Date Information

**Date Checking**:
- For fast-moving tech: prefer last 6 months
- For stable tech: last 2 years acceptable
- Always check library versions match current releases
- Note if tutorial uses deprecated APIs

**Version Awareness**:
```markdown
⚠️ This article was written for v2.x. Current version is v4.x.
Key differences: {list breaking changes or major updates}
```

### Verified Claims

**Test When Possible**:
```bash
# Don't trust "it's fast" - measure it
time python benchmark.py

# Don't trust "it's easy" - try it
time {read_docs && implement_hello_world}
```

**Cite Sources**:
```markdown
According to [benchmark X](https://example.com/benchmark),
Option A is 2.5x faster than Option B for workload Y.
```

## Common Research Pitfalls

### Pitfall 1: Analysis Paralysis

**Symptom**: Researching forever, never deciding
**Cause**: Seeking perfect option (which doesn't exist)
**Solution**:
- Set research time limit (e.g., 4 hours max)
- Use "good enough" threshold, not "perfect"
- Remember: decision reversibility (can change later)

### Pitfall 2: Popularity Bias

**Symptom**: Choosing most popular option without evaluation
**Cause**: Assuming popular = best for your use case
**Solution**:
- Popularity indicates maturity, not fit for your needs
- Evaluate against YOUR requirements, not general popularity
- Consider if you need enterprise-grade when simple tool suffices

### Pitfall 3: Recency Bias

**Symptom**: Choosing newest/trendiest option
**Cause**: Fear of missing out, excitement about new tech
**Solution**:
- Newer ≠ better (often means more bugs, less documentation)
- Consider maturity and stability needs
- Evaluate actual features vs hype

### Pitfall 4: Shallow Research

**Symptom**: Choosing based on surface-level reading
**Cause**: Time pressure, confirmation bias
**Solution**:
- Allocate sufficient time (2-4 hours for important decisions)
- Force yourself to find downsides (not just benefits)
- Test hands-on, don't just read

### Pitfall 5: Ignoring Total Cost of Ownership

**Symptom**: Choosing "free" option that costs more in time
**Cause**: Only considering upfront licensing cost
**Solution**:
- Factor in: learning time, integration effort, maintenance burden
- Paid tool with great docs might be cheaper than free tool with poor docs
- Consider long-term maintenance costs

## Research Time Guidelines

### Quick Research (30 min - 1 hour)
**When**: Low-risk decisions, easily reversible
**Activities**:
- Read official docs overview
- Check GitHub stars/activity
- Scan 1-2 comparison articles
**Output**: Quick comparison, basic recommendation

### Standard Research (2-4 hours)
**When**: Moderate-impact decisions
**Activities**:
- Full Phase 1-4 process
- Hands-on POC for top 2 options
- Detailed comparison matrix
**Output**: Research report with recommendation

### Deep Research (1-2 days)
**When**: Critical architectural decisions
**Activities**:
- Comprehensive evaluation of 3+ options
- Hands-on POCs for all viable options
- Team feedback sessions
- Prototype integration with existing system
**Output**: Technical research report + decision record + implementation guide

## Research Documentation

**Always Document**:
1. **Research Question**: What you investigated
2. **Options Considered**: What you evaluated
3. **Recommendation**: What you chose and why
4. **Trade-offs**: What you're giving up
5. **Next Steps**: How to implement

**Why Document**:
- Future you forgets the reasoning
- Team members need context
- Decision can be revisited with new information
- Saves time when similar question arises

**Documentation Template**: See `assets/research-report-template.md`

## Advanced Research Techniques

### Differential Analysis

Compare two similar options by focusing on key differences:

```markdown
## React vs Vue: Key Differences

Similarities (skip these):
- Both are component-based
- Both have virtual DOM
- Both have good ecosystem

Focus analysis on:
- JSX vs Templates (how does this affect our team?)
- React ecosystem size vs Vue simplicity (what matters more?)
- Corporate backing (Facebook vs community) (does this matter?)
```

### Decision Tree Approach

Use decision tree for clear-cut selection:

```markdown
Do you need enterprise support?
├─ Yes → Option A (has enterprise tier)
└─ No → Do you need extensive ecosystem?
    ├─ Yes → Option B (largest ecosystem)
    └─ No → Option C (simplest, lightest)
```

### Proof-of-Concept Evaluation

Build minimal working examples to evaluate real-world fit:

```bash
# Week 1: POC with Option A
poc-a/
  ├── implement_core_feature
  ├── measure_setup_time
  ├── test_integration
  └── document_pain_points

# Week 2: POC with Option B (only if Option A unclear)
```

## Research Workflow Summary

```
1. Define Problem (30 min)
   ├─ Clarify requirements
   ├─ Identify constraints
   └─ Set success criteria

2. Discover Options (1-2 hours)
   ├─ Read official docs
   ├─ Check GitHub/community
   ├─ Find examples
   └─ Read comparisons

3. Evaluate Options (1-2 hours)
   ├─ Score against criteria
   ├─ Hands-on POC (if needed)
   ├─ Compare trade-offs
   └─ Check dealbreakers

4. Synthesize & Recommend (30 min)
   ├─ Summarize findings
   ├─ Make recommendation
   ├─ Document rationale
   └─ Create implementation plan
```

**Total Time**: 2-4 hours for standard research

## Templates & Tools

Use these templates for consistent research outputs:

- `assets/research-report-template.md` - Full research documentation
- `assets/quick-start-template.md` - Implementation quick-start
- `assets/technology-comparison-template.md` - Side-by-side comparison
- `assets/evaluation-matrix-template.md` - Weighted scoring matrix
- `assets/implementation-guide-template.md` - Step-by-step implementation

## References

- "The Decision Book" - Decision-making frameworks
- "Thinking in Systems" - Systems thinking for technology evaluation
- Martin Fowler's Technology Radar - Adopting new technologies
- Joel Spolsky's "Strategy Letter" series - Technology decisions
