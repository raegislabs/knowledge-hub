# Source Evaluation Guide

## Purpose

Learn how to assess the credibility, authority, and reliability of information sources when conducting technical research.

## Source Hierarchy

### Tier 1: Primary Authoritative Sources (Highest Trust)

**Official Documentation**
- Project website and official docs
- API references and specifications
- Architecture documentation
- Release notes and changelogs

**Indicators of Quality**:
- ✅ Maintained by project maintainers
- ✅ Updated with each release
- ✅ Versioned documentation
- ✅ Clear examples and code samples
- ✅ Comprehensive error documentation

**Red Flags**:
- ⚠️ Last updated >2 years ago
- ⚠️ No version information
- ⚠️ Broken links or examples
- ⚠️ Community-maintained (not official)

**Example Evaluation**:
```markdown
Source: React Official Documentation (https://react.dev)
- Authority: ✅ Maintained by Meta/React team
- Recency: ✅ Updated for React 18+
- Completeness: ✅ Comprehensive API reference
- Examples: ✅ Interactive code samples
- Trust Level: PRIMARY SOURCE
```

### Tier 2: Source Code & Examples (High Trust)

**GitHub Repository**
- Official codebase
- Issue tracker
- Pull requests
- Test suites
- Example projects

**Evaluation Checklist**:
- [ ] Repository activity (commits in last 3 months)
- [ ] Issue response time (<7 days for critical issues)
- [ ] PR review process (multiple reviewers)
- [ ] Test coverage (>70% ideal)
- [ ] Contributor diversity (not single-maintainer)

**GitHub Health Indicators**:

| Indicator | Healthy | Caution | Red Flag |
|-----------|---------|---------|----------|
| Last Commit | <1 month | 1-6 months | >6 months |
| Open Issues | <50 | 50-200 | >500 |
| Stars | >1,000 | 100-1,000 | <100 |
| Contributors | >10 | 3-10 | 1-2 |
| License | OSI-approved | Custom | None |

**Example Evaluation**:
```markdown
Source: axios/axios GitHub Repository
- Stars: 104k ⭐ (Very Popular)
- Last Commit: 2 days ago ✅
- Open Issues: 234 (Manageable)
- Contributors: 400+ (Healthy)
- License: MIT ✅
- Test Coverage: 95% ✅
- Trust Level: HIGH
```

### Tier 3: Community Resources (Medium Trust)

**Stack Overflow**
- Question quality (upvotes, views)
- Answer quality (accepted, upvotes, recency)
- Answerer reputation (>10k ideal)

**Evaluation Criteria**:
```markdown
Good SO Answer:
- ✅ Accepted by questioner
- ✅ 50+ upvotes
- ✅ Posted/updated within 2 years
- ✅ Answerer has >10k reputation
- ✅ Code examples included
- ✅ Explanation of why it works

Questionable SO Answer:
- ⚠️ Not accepted
- ⚠️ <5 upvotes
- ⚠️ Posted >5 years ago
- ⚠️ No explanation, just code dump
- ⚠️ Deprecated methods used
```

**Technical Blogs**
- Author credentials and expertise
- Recency of publication
- Technical depth and accuracy
- Code examples and reproducibility

**Author Credibility Checklist**:
- [ ] Works on the technology professionally
- [ ] Contributes to relevant open-source projects
- [ ] Has technical background (not just marketing)
- [ ] Provides working code examples
- [ ] Cites sources for claims
- [ ] Acknowledges limitations and trade-offs

**Trusted Blog Sources**:
- **High Trust**: Kent C. Dodds, Dan Abramov, Martin Fowler, Scott Hanselman
- **Medium Trust**: Dev.to posts by verified authors
- **Low Trust**: Anonymous Medium posts, content farms

### Tier 4: Benchmarks & Comparisons (Medium Trust)

**Independent Benchmarks**
- Methodology transparency
- Reproducible setup
- Multiple test scenarios
- Fair comparison conditions

**Benchmark Quality Checklist**:
- [ ] Hardware specs documented
- [ ] Software versions specified
- [ ] Test methodology explained
- [ ] Raw data published
- [ ] Multiple runs averaged
- [ ] Confidence intervals shown
- [ ] Code available for reproduction

**Red Flags**:
- ⚠️ Vendor-sponsored benchmarks (bias risk)
- ⚠️ Single test run (no statistical validity)
- ⚠️ Unrealistic test scenarios
- ⚠️ Cherry-picked metrics
- ⚠️ No methodology disclosure

**Example Evaluation**:
```markdown
Source: "React vs Vue Performance Benchmark" by TechBlog
- Methodology: ✅ Documented (Chrome DevTools)
- Reproducibility: ❌ No code provided
- Fairness: ⚠️ Only tested one use case
- Recency: ✅ Published 6 months ago
- Bias: ⚠️ Author works at company using React
- Trust Level: MEDIUM (use with caution)
```

### Tier 5: Commercial/Vendor Information (Low Trust)

**Marketing Materials**
- White papers
- Case studies
- Product comparisons
- Sales documentation

**Critical Evaluation Required**:
- ⚠️ Vendor bias (emphasizes strengths, hides weaknesses)
- ⚠️ Cherry-picked testimonials
- ⚠️ Unrealistic use cases
- ⚠️ Missing cost information
- ⚠️ Vague performance claims

**How to Use Vendor Information**:
1. **Extract Facts**: Product features, pricing tiers, support options
2. **Verify Independently**: Cross-reference claims with independent sources
3. **Identify Gaps**: What isn't mentioned? (usually weaknesses)
4. **Seek Balance**: Find critical reviews and comparisons

**Example Evaluation**:
```markdown
Source: MongoDB White Paper "Why MongoDB is Faster"
- Type: Vendor Marketing Material
- Useful Info: ✅ Feature list, use cases
- Suspicious: ⚠️ Only shows MongoDB winning benchmarks
- Missing: ❌ Scenarios where SQL might be better
- Trust Level: LOW (verify all claims independently)
Action: Cross-reference with independent benchmarks
```

## Recency Evaluation

### Technology Age and Update Frequency

**Fast-Moving Technologies** (prefer <6 months):
- JavaScript frameworks (React, Vue, Angular)
- Cloud platforms (AWS, Azure, GCP)
- AI/ML libraries
- Mobile development (iOS, Android)

**Stable Technologies** (2 years acceptable):
- Programming languages (Python, Java, Go)
- Databases (PostgreSQL, MySQL)
- Operating systems
- Networking protocols

### Version Awareness

**Always Check**:
```markdown
Article: "Getting Started with React Hooks"
- Publication Date: March 2019
- React Version at Time: 16.8
- Current React Version: 18.2
- Age: 4 years ⚠️
- Still Valid? Mostly, but check for:
  - New hooks introduced (useId, useTransition, useDeferredValue)
  - Deprecated patterns
  - Performance improvements
```

**Version Translation Table**:

| Article Version | Current Version | Status |
|----------------|-----------------|--------|
| Same major.minor | Current | ✅ Use directly |
| Same major, older minor | Current | ⚠️ Check changelog |
| Older major | Current | ❌ Verify compatibility |
| Pre-release/beta | Current stable | ❌ Re-verify everything |

## Authority Assessment

### Author Credentials

**Strong Indicators**:
- ✅ Core maintainer of the technology
- ✅ Works at company that created/maintains it
- ✅ Significant open-source contributions
- ✅ Published technical books
- ✅ Conference speaker on topic
- ✅ Has professional experience using the tech

**Weak Indicators**:
- ⚠️ No technical background visible
- ⚠️ Only writes about topic, doesn't use it
- ⚠️ Anonymous or pseudonymous author
- ⚠️ No code examples or repos
- ⚠️ Content farm writer

### Publication Venue

**High Authority Venues**:
- Official project blogs
- ACM/IEEE publications
- O'Reilly, Manning, Pragmatic Programmers
- InfoQ, A List Apart
- Company engineering blogs (Uber, Netflix, Airbnb)

**Medium Authority Venues**:
- Dev.to (with author verification)
- Medium (with author credentials)
- Personal blogs (by established experts)
- YouTube (by verified creators)

**Low Authority Venues**:
- Content farms (no editorial review)
- Anonymous paste sites
- Unverified social media posts
- AI-generated content sites

## Verification Strategies

### Cross-Reference Method

**Never trust a single source for critical decisions**

```markdown
Research Question: "Is PostgreSQL faster than MongoDB for our use case?"

Sources to Check:
1. Official docs (PostgreSQL, MongoDB)
2. Independent benchmarks (3+ sources)
3. Stack Overflow discussions
4. Reddit r/database threads
5. Company engineering blogs (who uses what)
6. Academic papers (if available)

Cross-Reference:
- If 4+ sources agree → Likely accurate
- If sources disagree → Investigate why (workload differences?)
- If only 1 source claims X → Verify independently
```

### Reproducibility Test

**For Code Examples and Tutorials**:

```bash
# Don't just read - test it
git clone example-repo
npm install
npm test

# Measure claims
time npm run build  # Is it really "fast"?
ls -lh dist/        # Is bundle size really "small"?
```

**For Benchmarks**:
- Download their code/data
- Run on your hardware
- Vary test parameters
- Compare results with claimed results

### Expert Validation

**Find Domain Experts**:
- Twitter/X tech community
- LinkedIn technical groups
- Reddit (r/programming, r/webdev, language-specific)
- Discord/Slack communities
- Conference speakers and workshop leaders

**Ask for Verification**:
```markdown
"I found this article claiming X about Y technology.
Based on your experience, does this align with what you've seen?
Are there caveats or edge cases I should know about?"
```

## Common Source Evaluation Mistakes

### Mistake 1: Popularity = Correctness

**Wrong**: "This blog post has 10k upvotes, must be right"
**Right**: "Popular post, but let me verify the core claims"

**Why It Fails**: Viral content often oversimplifies or sensationalizes

### Mistake 2: Recency = Accuracy

**Wrong**: "Published yesterday, must be the latest info"
**Right**: "Recent, but is the author credible? Are claims verified?"

**Why It Fails**: Anyone can publish quickly; quality takes time

### Mistake 3: Official = Always Best

**Wrong**: "Official docs say X, so that's the only way"
**Right**: "Official docs say X, but community found better pattern Y for my use case"

**Why It Fails**: Official docs may lag best practices or cover generic cases

### Mistake 4: One Bad Source = Entire Topic Unreliable

**Wrong**: "Found one outdated article, this whole technology must be immature"
**Right**: "Found one outdated article, let me find more recent sources"

**Why It Fails**: Good information exists; search strategy may need refinement

## Source Quality Scorecard

Use this to systematically rate sources:

| Criterion | Weight | Score (1-5) | Weighted |
|-----------|--------|-------------|----------|
| **Authority** (author credentials) | 3x | ⭐⭐⭐⭐ | 12 |
| **Recency** (publication date) | 3x | ⭐⭐⭐ | 9 |
| **Completeness** (depth of coverage) | 2x | ⭐⭐⭐⭐⭐ | 10 |
| **Reproducibility** (code examples work) | 2x | ⭐⭐⭐⭐ | 8 |
| **Objectivity** (bias-free) | 2x | ⭐⭐⭐ | 6 |
| **Citations** (sources cited) | 1x | ⭐⭐⭐⭐ | 4 |
| **Community Validation** (upvotes/references) | 1x | ⭐⭐⭐⭐ | 4 |

**Total Score**: 53/70 (76%) → **HIGH QUALITY SOURCE**

**Interpretation**:
- 90-100%: Exceptional source (use as primary)
- 75-89%: High quality (trustworthy)
- 60-74%: Good (verify key claims)
- 45-59%: Acceptable (cross-reference important points)
- <45%: Low quality (use only if no alternatives)

## Practical Workflows

### Quick Source Check (2 minutes)

```markdown
1. Who wrote this? (30 sec)
   - Check author bio
   - Google author name + technology

2. When was it written? (15 sec)
   - Check publication date
   - Note technology version

3. Is it complete? (1 min)
   - Skim headings
   - Check for code examples
   - Look for caveats/limitations

4. Can I verify it? (15 sec)
   - Are sources cited?
   - Can I reproduce examples?

Decision: Use, Skip, or Deep Dive
```

### Deep Source Evaluation (10 minutes)

```markdown
1. Author Research (3 min)
   - Check GitHub contributions
   - Review other publications
   - Assess domain expertise

2. Content Analysis (4 min)
   - Read full article carefully
   - Test code examples
   - Identify assumptions

3. Cross-Reference (3 min)
   - Find 2-3 similar sources
   - Compare conclusions
   - Note discrepancies

Decision: Primary Source, Secondary Source, or Discard
```

## Reference Materials

**Books on Information Evaluation**:
- "The Information Diet" - Clay Johnson
- "Calling Bullshit" - Carl Bergstrom & Jevin West
- "A Field Guide to Lies" - Daniel Levitin

**Online Resources**:
- CRAAP Test (Currency, Relevance, Authority, Accuracy, Purpose)
- SIFT Method (Stop, Investigate, Find, Trace)
- Lateral Reading techniques

**Academic Standards**:
- Peer-review process understanding
- Citation analysis
- Impact factor interpretation
