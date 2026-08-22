# Recommendation Framework

## Purpose

Learn how to synthesize research findings into clear, actionable recommendations that help teams make confident technical decisions.

## Recommendation Structure

### The Three-Part Recommendation

Every strong technical recommendation consists of:

1. **The Recommendation** - What to do
2. **The Rationale** - Why this is the best choice
3. **The Caveats** - When this might not be the best choice

**Template**:
```markdown
## Recommendation: [Technology X]

We recommend using [Technology X] for [use case] because [key rationale in 1-2 sentences].

**Primary Rationale**:
- [Reason 1 with evidence]
- [Reason 2 with evidence]
- [Reason 3 with evidence]

**Trade-offs Accepted**:
- [What we're giving up by not choosing alternative Y]
- [How we'll mitigate this limitation]

**When NOT to use [Technology X]**:
- [Edge case 1]
- [Edge case 2]
```

## Evidence-Based Rationale

### Strong vs Weak Justifications

**Strong Justifications** (Use These):
```markdown
✅ "React because our team has 2 years of experience with it, reducing onboarding time from 2 months to 2 weeks"
✅ "PostgreSQL because our data model is highly relational (15+ joined tables) and requires ACID transactions"
✅ "Kubernetes because our system needs to scale from 100 to 10k requests/second elastically"
✅ "TypeScript because it caught 147 bugs in our last project during compile time (measured)"
```

**Weak Justifications** (Avoid These):
```markdown
❌ "React because it's popular"
❌ "PostgreSQL because I like it"
❌ "Kubernetes because it's industry standard"
❌ "TypeScript because types are good"
```

**Difference**: Strong justifications connect choice to SPECIFIC requirements or constraints. Weak justifications are generic.

### Connecting Features to Requirements

**Feature-Requirement Mapping**:

```markdown
Requirement: Handle 10k concurrent users
↓
Evaluated: Horizontal scalability
↓
Finding: Tool A scales linearly to 50k users (tested)
↓
Justification: "Tool A meets our scalability requirement with 5x headroom"
```

**Example Mapping Table**:

| Requirement | Tool A Feature | How It Satisfies | Evidence |
|-------------|----------------|------------------|----------|
| Multi-tenancy | Row-level security | Isolates tenant data | PostgreSQL docs |
| Real-time updates | WebSocket support | Pushes changes instantly | Benchmark: <50ms latency |
| Offline-first | Service worker API | Caches data locally | PWA compatibility test |
| Audit logging | Built-in CDC | Captures all changes | Tested with 1M events |

## Decision Confidence Levels

### High Confidence Recommendation

**When to use**: Clear winner, strong evidence, low risk

```markdown
## Recommendation: PostgreSQL (HIGH CONFIDENCE)

We recommend PostgreSQL for our e-commerce database.

**Rationale**:
1. **Proven Fit**: Successfully used in similar e-commerce projects (Shopify, Instagram)
2. **Requirements Match**: 100% of our 12 functional requirements met
3. **Team Experience**: 3/4 developers have 2+ years PostgreSQL experience
4. **Performance**: Handles 50k TPS in our load tests (we need 10k TPS)
5. **Low Risk**: Mature (25+ years), stable, active community

**Confidence Level**: HIGH (95%)
- Evidence quality: Strong (benchmarks, case studies, hands-on testing)
- Risk level: Low (proven technology, experienced team)
- Reversibility: Medium (migration to MySQL possible if needed)
```

### Medium Confidence Recommendation

**When to use**: Best option available, but with caveats

```markdown
## Recommendation: SvelteKit (MEDIUM CONFIDENCE)

We recommend SvelteKit for our web application.

**Rationale**:
1. **Performance**: Smallest bundle size (30KB vs 120KB for Next.js)
2. **Developer Experience**: Simpler mental model than React
3. **Requirements**: Meets 10/12 functional requirements

**Caveats**:
1. **Team Learning Curve**: No one has Svelte experience (2-week ramp-up)
2. **Ecosystem**: Smaller plugin ecosystem than React/Vue
3. **Enterprise Support**: No commercial support available

**Confidence Level**: MEDIUM (70%)
- Evidence quality: Good (benchmarks, docs), but limited real-world usage
- Risk level: Medium (team learning, smaller community)
- Reversibility: High (can migrate to React if needed)

**Mitigation Plan**:
- Allocate 2 weeks for team training
- Build POC before full commitment
- Identify fallback option (Next.js)
```

### Low Confidence Recommendation

**When to use**: No clear winner, need more information

```markdown
## Recommendation: Conduct POC with Django AND FastAPI (LOW CONFIDENCE)

We cannot confidently recommend either Django or FastAPI at this time.

**Situation**:
- Both meet core requirements
- Performance difference unclear for our use case
- Team has no experience with either

**Proposed Approach**:
1. Build 2-week POC with each framework
2. Implement same 3 core features
3. Measure: development time, performance, developer satisfaction
4. Reconvene with data to make final decision

**Confidence Level**: LOW (40%)
- Need more evidence through hands-on testing
- Cannot predict team productivity accurately
- Risk of wrong choice is high (6-month project)
```

## Trade-off Communication

### Explicitly Acknowledge Trade-offs

**Poor Trade-off Communication**:
```markdown
❌ "We recommend React"
(No mention of what we're giving up)
```

**Good Trade-off Communication**:
```markdown
✅ "We recommend React over Vue"

**What we gain**:
- Larger ecosystem (200k NPM packages vs 50k)
- More team experience (3/5 developers)
- Better job market (easier hiring)

**What we give up**:
- Steeper learning curve for new developers
- More boilerplate code
- Larger bundle size (42KB vs 34KB)

**Why this trade-off is acceptable**:
We prioritize ecosystem and team experience over bundle size because our application is not bundle-size constrained (budget: 200KB, React: 42KB = 21% of budget).
```

### The "Yes, But" Framework

Use this to acknowledge limitations while maintaining recommendation:

```markdown
"We recommend [Technology X]...

**Yes, [limitation] is a concern, but...**
- [Why this limitation doesn't apply to our use case], OR
- [How we'll mitigate this limitation], OR
- [Why the benefits outweigh this cost]

Example:
"We recommend MongoDB for our content management system.

**Yes, MongoDB lacks JOIN support, but...**
- Our data model is document-oriented (blog posts, comments, tags)
- Denormalization is acceptable for read-heavy workloads (95% reads)
- Query patterns don't require complex joins"
```

## Context-Aware Recommendations

### Tailor to Project Phase

**Startup/MVP Phase**:
```markdown
Recommendation: Ruby on Rails

**Rationale for MVP**:
- Fastest time-to-market (convention over configuration)
- Validates business model quickly
- Easy to change/pivot (high reversibility)

**Not optimizing for** (yet):
- Extreme scalability (< 10k users initially)
- Performance (acceptable to be "fast enough")
- Long-term architecture (may rebuild in 1-2 years)

**Future Path**:
When we reach 50k users, re-evaluate for scalability. Likely migration to microservices at that point.
```

**Scale-up Phase**:
```markdown
Recommendation: Migrate to Microservices (Go + gRPC)

**Rationale for Scale-up**:
- Current monolith hitting performance limits (500ms p99 latency)
- Team has grown (3 → 15 engineers, need independent deployment)
- Requirements stabilized (less churn, more optimization)

**What we're optimizing for NOW**:
- Scalability (100k → 1M users)
- Team velocity (parallel development)
- Performance (reduce latency 80%)

**Trade-offs**:
- Increased operational complexity (10 services vs 1 monolith)
- Distributed tracing required
- Higher infrastructure costs (acceptable given revenue)
```

### Team-Specific Recommendations

**Experienced Team**:
```markdown
Recommendation: Rust for high-performance service

**Why this works for our team**:
- All 4 developers have systems programming background
- Performance is critical (real-time bidding, <10ms latency)
- Team prefers strong type systems

**Would NOT recommend for**:
- Junior team (steep learning curve)
- Rapid prototyping (slower initial development)
```

**Junior Team**:
```markdown
Recommendation: Python + FastAPI

**Why this works for our team**:
- 2/3 developers know Python from bootcamp
- Excellent documentation and tutorials
- Forgiving language (won't shoot yourself in foot)
- Fast enough for our use case (API server, not low-latency)

**Would NOT recommend for**:
- Expert team (might prefer more control)
- Performance-critical path (use Go/Rust instead)
```

## Runner-Up Option

### Always Provide a Fallback

```markdown
## Primary Recommendation: PostgreSQL

[Full rationale above]

## Runner-Up: MySQL

**When to choose MySQL instead**:
- If your team has strong MySQL experience and no PostgreSQL experience
- If you need to integrate with MySQL-specific tooling (e.g., existing internal tools)
- If read-scalability is more important than write-consistency (MySQL replication is simpler)

**How close was this?**:
- PostgreSQL scored 87/100 in our evaluation
- MySQL scored 79/100
- Key differentiator: PostgreSQL's advanced features (JSON, full-text search, PostGIS) align with our roadmap

**Migration path**:
If we chose MySQL and later needed PostgreSQL features, migration is well-supported (both SQL databases, many tools available).
```

## Implementation Guidance

### Immediate Next Steps

**Poor Next Steps**:
```markdown
❌ "Use React for the project"
(Too vague, not actionable)
```

**Good Next Steps**:
```markdown
✅ Immediate Actions (This Week):
1. Create new React project: `npx create-react-app project-name`
2. Install recommended dependencies (list in appendix)
3. Set up development environment (Node.js 18+, VS Code)
4. Complete official React tutorial (https://react.dev/learn)

Short-term (Weeks 2-4):
1. Build authentication flow (use our auth-template)
2. Implement core data model
3. Set up CI/CD pipeline

Long-term Considerations (Months 2-6):
1. Performance optimization (lazy loading, code splitting)
2. Accessibility audit (WCAG 2.1 AA)
3. Evaluate state management (if app grows complex)
```

### Risk Mitigation Plan

```markdown
## Potential Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Team learning curve delays delivery | Medium | High | - Allocate 2 weeks for training<br>- Pair junior devs with experienced<br>- Build POC before full commitment |
| Performance doesn't meet requirements | Low | High | - Benchmark early (week 1)<br>- Set performance budgets<br>- Have fallback option (MySQL) ready |
| Library becomes unmaintained | Low | Medium | - Choose libraries with >100 contributors<br>- Monitor release frequency<br>- Avoid deep dependencies on any single library |
```

## Decision Documentation

### Why Document the Decision?

1. **Future Reference**: "Why did we choose X over Y?" (6 months later)
2. **Team Onboarding**: New members understand the rationale
3. **Re-evaluation**: Know when to revisit (technology landscape changes)
4. **Learning**: What worked, what didn't (retrospective)

### Decision Record Template

```markdown
# Decision Record: [Technology Choice]

**Date**: 2024-01-15
**Status**: Accepted
**Deciders**: [Names/Roles]
**Consulted**: [Names/Roles]

## Context

What problem are we solving?
[2-3 sentences describing the need]

## Decision

We will use [Technology X] for [use case].

## Rationale

1. [Key reason 1 with evidence]
2. [Key reason 2 with evidence]
3. [Key reason 3 with evidence]

## Alternatives Considered

- **Technology Y**: [Why not chosen]
- **Technology Z**: [Why not chosen]

## Consequences

**Positive**:
- [Expected benefit 1]
- [Expected benefit 2]

**Negative**:
- [Trade-off 1 and mitigation]
- [Trade-off 2 and mitigation]

## Review Date

[When to re-evaluate this decision]
- Scheduled: 2024-07-15 (6 months)
- Trigger: If we reach 100k users before then
```

## Recommendation Anti-Patterns

### Anti-Pattern 1: The Hedge

**Wrong**:
```markdown
❌ "We could use either React or Vue, both are good, depends on what you prefer"
```

**Right**:
```markdown
✅ "We recommend React for these specific reasons: [1, 2, 3]. Vue is a strong alternative if [specific condition]."
```

**Why**: Teams need clear direction. Hedging creates decision paralysis.

### Anti-Pattern 2: The Buzzword

**Wrong**:
```markdown
❌ "We should use microservices and Kubernetes because they're cloud-native and scalable"
```

**Right**:
```markdown
✅ "We should use microservices because our 15-person team needs independent deployment. Current monolith creates deployment bottlenecks (3-day release cycle). Microservices will enable daily releases per team."
```

**Why**: Connect technology to specific problems, not generic benefits.

### Anti-Pattern 3: The Technology Hammer

**Wrong**:
```markdown
❌ "We should use [my favorite technology] for everything"
```

**Right**:
```markdown
✅ "We should use [technology X] for [specific use case where it excels]. For [different use case], we'll use [different technology]."
```

**Why**: Right tool for the job. No technology is universally best.

### Anti-Pattern 4: The Resume-Driven Development

**Wrong**:
```markdown
❌ "Let's use [trendy new technology] because it will look good on our resumes"
```

**Right**:
```markdown
✅ "Let's use [technology] because it solves our specific problem better than alternatives: [evidence]"
```

**Why**: Optimize for project success, not personal branding.

## Confidence Calibration

### How to Assess Your Confidence

```markdown
Ask yourself:

1. **Evidence Quality**
   - Have I tested this hands-on? (High confidence)
   - Have I only read about it? (Medium confidence)
   - Am I guessing? (Low confidence)

2. **Reversibility**
   - Can we easily switch if wrong? (Increase confidence)
   - Is this a one-way door? (Decrease confidence)

3. **Risk Level**
   - What's the cost if we're wrong?
   - High cost + low evidence = Low confidence
   - Low cost + strong evidence = High confidence

4. **Time Pressure**
   - Do we have time for a POC? (Can increase confidence)
   - Must decide now? (Accept lower confidence, but document)
```

### Confidence Statement Examples

```markdown
High Confidence (90%+):
"Based on our 2-week POC, team expertise, and performance benchmarks, we're highly confident PostgreSQL is the right choice."

Medium Confidence (60-80%):
"Based on research and documentation, we believe SvelteKit is the best choice. We recommend a 1-week POC to increase confidence before full commitment."

Low Confidence (40-60%):
"We don't have sufficient evidence to confidently recommend either option. We propose building POCs with both to gather the data we need."
```

## Synthesis Process

### From Research to Recommendation (Step-by-Step)

**Step 1: Summarize Findings**
```markdown
We evaluated 3 options:
- React: Score 85/100 (Strong ecosystem, team experience)
- Vue: Score 78/100 (Easier learning, good docs)
- Svelte: Score 72/100 (Best performance, smallest ecosystem)
```

**Step 2: Apply Context**
```markdown
Our context:
- Team: 5 developers, 3 know React
- Timeline: 3 months to MVP
- Scale: 10k users initially
- Priority: Speed of development > Performance
```

**Step 3: Make Decision**
```markdown
React wins because:
1. Team experience reduces development time 30%
2. Large ecosystem means fewer custom solutions needed
3. Performance is "good enough" for 10k users

Vue is close second (78 vs 85), but team experience tips scale.
```

**Step 4: Document Trade-offs**
```markdown
We're accepting:
- Larger bundle size (42KB vs Svelte's 2KB)
- More boilerplate code
- Steeper learning curve for 2 new developers

These are acceptable because:
- 42KB is within our 200KB bundle budget
- Boilerplate is manageable with templates
- 2-week onboarding is acceptable for 3-month project
```

**Step 5: Provide Implementation Path**
```markdown
Week 1: Setup, training, hello world
Week 2-4: Core features
Week 5-12: Full implementation
```

## Quality Checklist

Before finalizing recommendation, verify:

```markdown
□ Recommendation is specific (not "use React" but "use React with Vite + TypeScript")
□ Rationale connects to requirements (not generic benefits)
□ Evidence is cited (benchmarks, tests, case studies)
□ Trade-offs are explicitly stated
□ Runner-up option is provided
□ Confidence level is stated and calibrated
□ Edge cases / when NOT to use are documented
□ Implementation path is clear and actionable
□ Decision is documented for future reference
□ Review/re-evaluation date is set
```

## Example: Complete Recommendation

```markdown
# Technology Recommendation: Database for E-commerce Platform

**Date**: 2024-01-15
**Confidence**: HIGH (90%)

## Recommendation: PostgreSQL 15

We recommend PostgreSQL 15 as the primary database for our e-commerce platform.

## Rationale

1. **Proven E-commerce Fit**
   - Successfully used by Shopify (1M+ merchants), Instagram (1B+ users)
   - Handles complex transactions required for checkout flow
   - ACID compliance ensures data integrity for financial transactions

2. **Performance Validated**
   - Our load tests: 50,000 TPS sustained (requirement: 10,000 TPS)
   - p99 latency: 5ms (requirement: <10ms)
   - Horizontal scaling via read replicas tested to 5x capacity

3. **Feature Alignment**
   - Native JSON support for flexible product attributes
   - Full-text search for product catalog (avoid separate search engine)
   - PostGIS for location-based features (store finder)
   - Row-level security for multi-tenancy

4. **Team & Ecosystem**
   - 3/4 backend developers have 2+ years PostgreSQL experience
   - Extensive tooling: pgAdmin, Postico, DataGrip all supported
   - Active community: 450k Stack Overflow questions

5. **Operational Maturity**
   - 25+ years of production stability
   - Clear upgrade path (tested 14 → 15 migration)
   - Excellent documentation and security track record

## Trade-offs Accepted

**What we're giving up (vs MongoDB)**:
- Schema flexibility (PostgreSQL requires migrations for schema changes)
- Native horizontal write scaling (PostgreSQL scales reads easily, writes with effort)

**Why this is acceptable**:
- Our product schema is stable (infrequent changes)
- Write load is 10% of traffic (read-heavy workload)
- ACID guarantees outweigh flexibility for financial transactions

## Runner-Up: MySQL 8.0

**Score**: 79/100 (PostgreSQL: 87/100)

**Choose MySQL instead if**:
- Team has deep MySQL experience and no PostgreSQL experience
- Integrating with MySQL-specific tooling
- Read-scalability is top priority (MySQL replication is simpler)

**Why PostgreSQL won**:
- Advanced features (JSON, full-text search, PostGIS) align with roadmap
- Better handling of complex queries (Common Table Expressions)
- More active development and feature additions

## When NOT to Use PostgreSQL

- **Pure key-value workload**: Use Redis instead
- **Time-series data at massive scale**: Use TimescaleDB or InfluxDB
- **Document store with frequent schema changes**: Consider MongoDB
- **Multi-region, active-active writes**: Consider CockroachDB or Spanner

## Implementation Plan

### Immediate (Week 1)
```bash
# Provision PostgreSQL 15
# AWS RDS, db.r6g.xlarge instance
# Multi-AZ deployment for HA

# Initial schema migration
createdb ecommerce_production
psql ecommerce_production < schema.sql
```

### Short-term (Weeks 2-4)
- Set up read replicas (2x for redundancy)
- Configure connection pooling (pgBouncer)
- Implement backup strategy (daily automated, 30-day retention)
- Set up monitoring (CloudWatch + pg_stat_statements)

### Long-term (Months 2-6)
- Query optimization (identify slow queries, add indexes)
- Partitioning for large tables (orders, events)
- Upgrade to PostgreSQL 16 when stable (Q3 2024)

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Write scaling bottleneck | Medium | High | - Start with powerful instance (scale up)<br>- Plan sharding strategy for Year 2<br>- Monitor write metrics weekly |
| Migration complexity | Low | Medium | - Test migrations in staging first<br>- Have rollback plan<br>- Maintain backward compatibility |
| Team knowledge gaps | Low | Low | - PostgreSQL experts on team<br>- Budget for training (2 developers)<br>- Official documentation is excellent |

## Success Metrics

We'll know this was the right choice if:
- [ ] All queries complete in <10ms p99 (baseline: 5ms)
- [ ] Zero data integrity issues in first 6 months
- [ ] Team velocity: 10+ features/month (no database bottleneck)
- [ ] Operational uptime: 99.95%+

## Review Date

**Scheduled**: 2024-07-15 (6 months from now)
**Trigger**: If we exceed 100k transactions/day before then

At review, reassess:
- Are performance metrics still met?
- Has the technology landscape changed?
- Are new features still supported by PostgreSQL?
```

## Templates & References

See also:
- `../assets/research-report-template.md` - Full research report
- `../assets/technology-comparison-template.md` - Side-by-side comparison
- `../assets/evaluation-matrix-template.md` - Weighted scoring
- `./research-methodology-guide.md` - Research process
- `./comparison-criteria-guide.md` - Evaluation criteria
