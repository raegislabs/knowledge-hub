---
name: debugging-templates
description: Comprehensive templates and methodologies for systematic debugging and issue resolution. Use when investigating bugs, conducting root cause analysis, or documenting debugging sessions. Provides structured templates for bug reports, investigation tracking, performance analysis, and debugging best practices.
---

# Debugging Templates

## Overview

This skill provides production-ready templates and systematic methodologies for debugging software issues. It complements the @debugger agent by providing standardized formats, investigation frameworks, and best practices for identifying and resolving bugs efficiently.

**When to use this skill:**
- Investigating bugs and production issues
- Conducting root cause analysis (5 Whys, Fishbone diagrams)
- Writing comprehensive bug reports
- Tracking debugging sessions and hypotheses
- Analyzing performance bottlenecks
- Creating regression tests for fixed bugs
- Documenting debugging processes and learnings

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive methodologies.

## Available Templates

This skill provides 6 production-ready templates in `assets/`:

### 1. Bug Investigation Template
**File:** `assets/bug-investigation-template.md`

Systematic bug investigation format including:
- Summary (issue, severity, status, timeline)
- Reproduction steps with environment details
- Expected vs actual behavior documentation
- Investigation log with hypothesis testing
- Root cause analysis (technical cause, why it occurs, impact)
- Solution implementation details with code changes
- Prevention measures and monitoring suggestions
- Complete timeline tracking

**Use when:** Investigating any bug from initial report through to fix and documentation.

**Example usage:**
```markdown
# Bug Investigation: RAE-456 - Null Pointer in User Processing

## Summary
**Issue**: NullPointerException when processing users with null email
**Severity**: High
**Status**: Fixed

## Reproduction
1. Create user with email=null in database
2. Call process_user_preferences(user_id)
3. Observe crash at user.email.toLowerCase()

[Continue filling out investigation sections...]
```

### 2. Root Cause Analysis Template
**File:** `assets/root-cause-analysis-template.md`

Structured RCA format with:
- 5 Whys methodology for root cause identification
- Fishbone diagram (Ishikawa) analysis
- Category-based cause analysis (People, Process, Technology, Environment, Materials, Measurement)
- Primary root cause identification with evidence
- Contributing factors documentation
- Corrective actions (immediate, short-term, long-term)
- Lessons learned and validation plan

**Use when:** Conducting formal root cause analysis for critical bugs or recurring issues.

**Example usage:**
```markdown
# Root Cause Analysis: Production Outage - Database Timeout

## The 5 Whys
**Problem**: API returned 500 errors

**Why 1**: Database queries timed out
→ Because queries took >30 seconds

**Why 2**: Queries required full table scan
→ Because index was missing

**Why 3**: Index was not created during deployment
→ Because migration script had a typo

**Why 4**: Typo wasn't caught in review
→ Because no automated schema validation

**Why 5**: No schema validation in pipeline
→ Because we never implemented it **← ROOT CAUSE**
```

### 3. Bug Report Template
**File:** `assets/bug-report-template.md`

Complete bug report format with:
- Basic information (ID, reporter, date, priority, component)
- Clear reproduction steps
- Expected vs actual behavior
- Screenshots and error messages
- Environment details (OS, versions, configuration)
- Sample data and inputs
- Network information (for API issues)
- Impact assessment and severity justification
- Attempted solutions and workarounds

**Use when:** Reporting bugs to team or tracking issues systematically.

**Example usage:**
```markdown
# Bug Report: Login Fails with Special Characters in Password

## Steps to Reproduce
1. Navigate to /login
2. Enter username: test@example.com
3. Enter password: P@ssw0rd! (contains special chars)
4. Click "Login"

## Expected Behavior
User should be logged in and redirected to dashboard

## Actual Behavior
Login form displays "Invalid credentials" error
Password validation fails even with correct password

## Error Messages
```
AuthenticationError: Password validation failed
  at validatePassword (auth.py:78)
  Expected special chars to be escaped
```
```

### 4. Debugging Session Notes Template
**File:** `assets/debugging-session-notes-template.md`

Real-time debugging session tracker with:
- Session metadata (date, time, goal, participants)
- Initial state (what we know, don't know, hypotheses)
- Chronological debugging log with timestamps
- Hypothesis tracking (confirmed, ruled out, modified)
- Key discoveries and eureka moments
- Dead ends documentation (what didn't work)
- Code snippets and variable state tracking
- Breakpoint notes and stack traces
- Questions and answers
- Root cause identification and solution plan
- Session metrics and lessons learned

**Use when:** During active debugging sessions to track progress and maintain context.

**Example usage:**
```markdown
# Debugging Session: Memory Leak in Background Worker

## Session Information
**Date/Time**: 2024-10-24 14:00 - 16:30
**Issue**: Worker process memory grows from 100MB to 2GB over 24 hours
**Goal**: Identify and fix memory leak

## Starting Hypotheses
1. **Database connections not closed** - High confidence
2. **Unbounded cache growth** - Medium confidence
3. **Circular references in job data** - Low confidence

## Debugging Log

### 14:15 - Added memory profiling
**Method**: tracemalloc

**What I did**: Added tracemalloc to worker process startup

**What I observed**: Memory grows 50MB per 1000 jobs processed

**Hypothesis updated**: ✅ Confirms leak exists, 50KB per job
```

### 5. Performance Investigation Template
**File:** `assets/performance-investigation-template.md`

Performance debugging format with:
- Performance baseline metrics (p50, p95, p99, throughput)
- Initial hypotheses ranked by likelihood and impact
- Profiling results (CPU, memory, database, network)
- Bottleneck analysis with dependency mapping
- Root cause identification
- Optimization solutions with expected improvements
- Phased optimization plan (quick wins, medium-term, long-term)
- Testing and validation with benchmarks
- Monitoring and alerting configuration

**Use when:** Investigating slow performance, high resource usage, or scalability issues.

**Example usage:**
```markdown
# Performance Investigation: API Response Time Spike

## Performance Baseline
| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Response Time (p50) | 2500ms | 200ms | 2300ms |
| Response Time (p95) | 4500ms | 500ms | 4000ms |
| Database Queries | 47 queries | <10 | 37 extra |

## Profiling Results

### CPU Profiling
**Top Functions by Time**:
1. `fetch_user_preferences` - 45% of total time (N+1 query issue!)
2. `serialize_response` - 30% of total time
3. `validate_permissions` - 15% of total time

## Primary Bottleneck
**Component**: Database queries (N+1 problem)
**Time consumed**: 2100ms (84% of total)
[Continue with analysis...]
```

### 6. Regression Test Template
**File:** `assets/regression-test-template.md`

Test creation guide with:
- Python pytest examples
- JavaScript Jest examples
- Integration test examples
- API regression test examples
- Best practices for regression tests
- Checklist for test completeness

**Use when:** Creating tests to prevent bugs from recurring after fixes.

**Example usage:**
```python
"""
Regression test for bug: RAE-123

Ensures that processing users with null email is handled correctly.
"""

def test_bug_123_null_email_handling():
    """
    Test that null email doesn't cause crash.

    This was the root cause of bug RAE-123.
    """
    # Arrange
    user = User(id=123, email=None, name="Test")

    # Act
    result = process_user_preferences(user)

    # Assert
    assert result is not None, "Null email should be handled gracefully"
    assert result.status == "success"
```

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. Debugging Methodology
**File:** `references/debugging-methodology.md`

Systematic debugging process with:

**The Scientific Debugging Process:**
1. **Observation** - Gather facts without assumptions
2. **Hypothesis Formation** - Develop testable theories
3. **Experimentation** - Test hypotheses systematically
4. **Analysis** - Interpret results and refine understanding
5. **Solution** - Fix root cause, not symptoms
6. **Validation** - Confirm fix works without side effects

**Debugging Phases:**
- Understanding (10-20% of time) - Fully grasp the problem
- Reproduction (20-30% of time) - Reliably trigger the bug
- Investigation (30-40% of time) - Identify root cause
- Solution (10-20% of time) - Implement fix
- Verification (10-15% of time) - Validate completeness

**Additional Topics:**
- Debugging techniques overview
- Common pitfalls (assuming, random changes, treating symptoms)
- Debugging mindset (systematic, patient, skeptical, curious)
- Debugging checklist

**Use when:** Need systematic framework for debugging from start to finish.

### 2. Debugging Techniques
**File:** `references/debugging-techniques.md`

Practical debugging methods with examples:

**Techniques Covered:**
1. **Print/Log Debugging** - Strategic logging, log levels, structured logging
2. **Breakpoint Debugging** - IDE breakpoints, pdb/debugger, conditional breakpoints
3. **Binary Search Debugging** - Git bisect, code bisect, halving technique
4. **Rubber Duck Debugging** - Explaining code line-by-line to find issues
5. **Differential Debugging** - Comparing versions, environments, data
6. **Stack Trace Analysis** - Reading and interpreting stack traces
7. **Logging Analysis** - Finding patterns, correlation analysis
8. **Memory Debugging** - Finding leaks, object tracking
9. **Performance Debugging** - CPU profiling, bottleneck identification
10. **Network Debugging** - HTTP inspection, packet capture
11. **Testing-Based Debugging** - Writing tests that reproduce bugs

**Each technique includes:**
- When to use
- How to use (with code examples)
- Best practices
- Pros and cons

**Use when:** Need specific debugging technique for particular problem type.

### 3. Common Bug Patterns
**File:** `references/common-bug-patterns.md`

Catalog of frequent bugs with detection and fixes:

**Bug Patterns Covered:**
1. **Off-by-One Errors** - Array indexing, loop bounds, pagination
2. **Null/None Handling** - Null pointer exceptions, optional chains
3. **Race Conditions** - Shared state, TOCTOU, async races
4. **Type Mismatches** - String vs number, list vs single item
5. **Memory Leaks** - Circular references, unbounded caches, unclosed resources
6. **Async/Await Issues** - Forgotten await, blocking in async, unhandled exceptions
7. **SQL Injection** - String concatenation, parameterized queries
8. **Unhandled Exceptions** - No error handling, crashes

**For each pattern:**
- Description
- Common causes
- Code examples (buggy and fixed)
- Detection methods
- Prevention strategies

**Quick reference table** for rapid pattern identification.

**Use when:** Encountering common bug types or during code review.

### 4. Logging Strategies
**File:** `references/logging-strategies.md`

Effective logging practices:

**Core Topics:**
- Logging principles (log for future debuggers, signal vs noise, structured logging)
- Log levels (ERROR, WARNING, INFO, DEBUG, TRACE)
- What to log (always: errors, security events, external interactions, state changes)
- What never to log (passwords, API keys, PII, credit cards)
- Logging patterns (request logging, transaction logging, batch jobs, audit logs)
- Configuration (Python setup, log rotation)
- Best practices (correlation IDs, timing information, central aggregation, alerting, sampling)
- Common pitfalls (logging in loops, expensive log calls, no context)

**Structured Logging Examples:**
```python
# Good: Structured and queryable
logger.info(
    "Order placed",
    extra={
        "order_id": order.id,
        "user_id": user.id,
        "total": total,
        "currency": "USD"
    }
)
```

**Use when:** Setting up logging infrastructure or improving log quality.

### 5. Troubleshooting Guide
**File:** `references/troubleshooting-guide.md`

Systematic troubleshooting for common issues:

**General Process:**
1. Define the problem
2. Gather information
3. Form hypothesis
4. Test & verify
5. Implement solution

**Issue Categories:**
- **Network Issues** - Can't connect, slow performance, DNS problems
- **Database Issues** - Slow queries, connection pool exhausted
- **Memory Issues** - Out of memory, memory leaks
- **Performance Issues** - CPU-bound, I/O-bound, application logic
- **Application Crashes** - Random crashes, OOM, segfaults
- **Deployment Issues** - Works locally, fails in production
- **API Issues** - 500 errors, 404 errors
- **Docker Issues** - Container won't start, keeps restarting

**For each issue:**
- Decision trees
- Diagnostic commands
- Common causes
- Solutions with examples

**Quick reference commands** for system, network, process, and disk troubleshooting.

**Use when:** Troubleshooting system-level issues or infrastructure problems.

## Usage Patterns

### Pattern 1: Investigating a New Bug

**Scenario:** User reports a bug, need to investigate from scratch.

**Process:**
1. Read `debugging-methodology.md` → Understanding phase
2. Use `bug-report-template.md` to gather information
3. Use `debugging-session-notes-template.md` to track investigation
4. Use `debugging-techniques.md` for specific debugging methods
5. Use `bug-investigation-template.md` for final documentation
6. Use `regression-test-template.md` to create tests

**Time:** 2-8 hours depending on complexity

### Pattern 2: Performance Problem

**Scenario:** Application is slow, need to identify bottleneck.

**Process:**
1. Read `debugging-methodology.md` → Investigation phase
2. Use `performance-investigation-template.md` as structure
3. Use `debugging-techniques.md` → Performance Debugging section
4. Use `troubleshooting-guide.md` → Performance Issues section
5. Document findings in `performance-investigation-template.md`
6. Create performance regression tests

**Time:** 4-16 hours depending on complexity

### Pattern 3: Production Incident

**Scenario:** Critical production issue, need rapid resolution and RCA.

**Process:**
1. Use `troubleshooting-guide.md` for immediate diagnostic steps
2. Use `debugging-session-notes-template.md` to track investigation in real-time
3. Use `logging-strategies.md` to analyze production logs
4. Once fixed, use `root-cause-analysis-template.md` for formal RCA
5. Use `bug-investigation-template.md` for complete documentation
6. Implement prevention measures

**Time:** 1-4 hours for fix, 1-2 hours for RCA

### Pattern 4: Learning from Bugs

**Scenario:** Want to improve debugging skills or document patterns.

**Process:**
1. Read all reference guides completely
2. Review `common-bug-patterns.md` for pattern recognition
3. Study `debugging-techniques.md` for new techniques
4. Implement structured logging from `logging-strategies.md`
5. Practice with `debugging-session-notes-template.md` tracking

**Time:** 4-8 hours for initial learning

### Pattern 5: Creating Regression Tests

**Scenario:** Fixed a bug, need to prevent recurrence.

**Process:**
1. Use `regression-test-template.md` as guide
2. Write test that reproduces original bug
3. Verify test fails before fix
4. Verify test passes after fix
5. Add edge case tests
6. Document bug reference in test

**Time:** 30 minutes - 2 hours per bug

### Pattern 6: Code Review for Bug Prevention

**Scenario:** Reviewing code to catch bugs before they happen.

**Process:**
1. Read `common-bug-patterns.md` → Use as checklist
2. Check for patterns: null handling, race conditions, type mismatches
3. Verify error handling exists
4. Check logging quality against `logging-strategies.md`
5. Suggest improvements or tests

**Time:** 15-30 minutes per code review

## Integration with @debugger

This skill is designed to complement the @debugger agent:

**Agent's Role:**
- Applies debugging methodology to specific bugs
- Analyzes stack traces and error messages
- Identifies root causes through investigation
- Implements fixes with proper error handling

**Skill's Role:**
- Provides standardized templates for documentation
- Offers systematic methodologies for investigation
- Ensures best practices are followed
- Captures learnings for future reference

**Workflow:**
```markdown
User: "@debugger, investigate why users with null email crash the system"

Agent:
1. Loads debugging-templates skill
2. Reads debugging-methodology.md for systematic process
3. Uses bug-investigation-template.md for structure
4. Reads common-bug-patterns.md → Null/None Handling section
5. Uses debugging-techniques.md → Print/Log Debugging
6. Conducts investigation systematically
7. Fills out bug-investigation-template.md with findings
8. Uses regression-test-template.md to create tests
9. Documents in structured format
```

## Best Practices

### 1. Start with Methodology
Always read `debugging-methodology.md` first to understand the systematic 6-phase process.

### 2. Use Appropriate Template
- New bug investigation → `bug-investigation-template.md`
- Performance issue → `performance-investigation-template.md`
- Active debugging → `debugging-session-notes-template.md`
- Formal RCA → `root-cause-analysis-template.md`
- Bug reporting → `bug-report-template.md`
- Test creation → `regression-test-template.md`

### 3. Track Hypotheses Systematically
Use templates to document what you test, not just what works. Dead ends are valuable information.

### 4. Always Create Regression Tests
Use `regression-test-template.md` for every fixed bug. Tests prevent recurrence and document the fix.

### 5. Learn from Common Patterns
Review `common-bug-patterns.md` regularly to recognize patterns faster.

### 6. Implement Good Logging Early
Use `logging-strategies.md` to set up logging infrastructure before bugs occur.

### 7. Document Everything
Future you (or teammates) will thank you. Use templates consistently for searchable history.

### 8. Fix Root Causes, Not Symptoms
Use 5 Whys from `root-cause-analysis-template.md` to ensure you're fixing the underlying issue.

### 9. Share Learnings
Use completed templates as documentation and teaching tools for the team.

### 10. Maintain Debug Context
Use `debugging-session-notes-template.md` to maintain context across interruptions.

## Resources

### assets/
Template files designed to be copied and customized:

- **bug-investigation-template.md** - Complete investigation documentation (280 lines)
- **root-cause-analysis-template.md** - 5 Whys and Fishbone RCA format (280 lines)
- **bug-report-template.md** - Comprehensive bug report format (230 lines)
- **debugging-session-notes-template.md** - Real-time session tracker (310 lines)
- **performance-investigation-template.md** - Performance analysis format (450 lines)
- **regression-test-template.md** - Test creation guide with examples (320 lines)

**Total:** 1,870 lines of templates

**Usage:** Copy template to your docs/debugging/ or docs/bugs/ directory, fill in sections, customize as needed.

### references/
Comprehensive reference guides loaded into context:

- **debugging-methodology.md** - 6-phase scientific debugging process, techniques overview, mindset (680 lines)
- **debugging-techniques.md** - 11 practical techniques with code examples (860 lines)
- **common-bug-patterns.md** - 8 common patterns with detection and fixes (650 lines)
- **logging-strategies.md** - Logging principles, levels, patterns, best practices (720 lines)
- **troubleshooting-guide.md** - System troubleshooting for 8 issue categories (540 lines)

**Total:** 3,450 lines of reference material

**Usage:** Read relevant sections to inform debugging approach and decision-making.

## Examples

### Example 1: Null Pointer Exception

```markdown
User: "App crashes when processing user with null email"

Process:
1. Read debugging-methodology.md → Start with Understanding phase
2. Read common-bug-patterns.md → Null/None Handling section
3. Use bug-investigation-template.md:
   - Reproduction: Create user with email=null, call process_user()
   - Investigation: Add logging, use breakpoint debugger
   - Hypothesis 1: No null check before email.toLowerCase()
   - Test: Add logging to verify email is null
   - Result: ✅ Confirmed
4. Root cause: Missing null validation
5. Fix: Add null check with default behavior
6. Use regression-test-template.md:
   ```python
   def test_bug_123_null_email():
       user = User(email=None)
       result = process_user(user)
       assert result is not None
   ```

Output:
- Complete bug investigation document
- Regression test preventing recurrence
- Logging improvements for future debugging
```

### Example 2: Performance Degradation

```markdown
User: "API endpoint went from 100ms to 3000ms response time"

Process:
1. Read debugging-methodology.md → Investigation phase
2. Use performance-investigation-template.md:
   - Baseline: p50=3000ms (was 100ms)
   - Hypothesis 1: Database N+1 query issue
3. Read debugging-techniques.md → Performance Debugging
4. Profile with cProfile:
   - fetch_user_preferences: 45% of time
   - 47 database queries (N+1 problem!)
5. Read common-bug-patterns.md → Check for similar patterns
6. Solution: Use eager loading
   ```python
   # Before: N+1 queries
   for pref in preferences:
       user = db.query(User).get(pref.user_id)  # Query per iteration!

   # After: Single query
   user_ids = {p.user_id for p in preferences}
   users = {u.id: u for u in db.query(User).filter(User.id.in_(user_ids))}
   ```
7. Benchmark: p50 = 120ms (25x improvement!)
8. Add performance regression test

Output:
- Performance investigation document
- Code optimization
- Performance benchmarks
- Monitoring alerts for regression
```

### Example 3: Production Outage RCA

```markdown
User: "Production went down, need RCA for incident review"

Process:
1. Read troubleshooting-guide.md → Database Issues section
2. Use debugging-session-notes-template.md during incident:
   - 14:00: Reports of 500 errors
   - 14:05: Checked logs - database timeout errors
   - 14:10: Database CPU at 100%
   - 14:15: Found slow query taking 45 seconds
   - 14:20: Missing index on new column
   - 14:25: Added index, issue resolved
3. Post-incident, use root-cause-analysis-template.md:
   - 5 Whys:
     - Why 1: Database queries timed out
     - Why 2: Queries required full table scan
     - Why 3: Index missing on email column
     - Why 4: Migration script had typo
     - Why 5: No schema validation in CI ← ROOT CAUSE
   - Corrective actions:
     - Immediate: Added missing index
     - Short-term: Fixed migration script
     - Long-term: Add schema validation to CI pipeline
4. Lessons learned documented
5. Prevention measures implemented

Output:
- Complete RCA document
- Process improvements
- Monitoring enhancements
- Team learning
```

## Tips & Tricks

### Tip 1: Create Personal Template Library
Copy frequently used templates to a personal docs/templates/ folder with your customizations.

### Tip 2: Use Templates as Checklists
Even if not filling out completely, use template sections as reminders of what to check.

### Tip 3: Progressive Detail
Start with quick notes in debugging-session-notes-template.md, then transfer to formal bug-investigation-template.md.

### Tip 4: Learn One Pattern at a Time
Study one section of common-bug-patterns.md per week. Practice recognizing that pattern in code reviews.

### Tip 5: Automate Common Checks
Create scripts from troubleshooting-guide.md commands for common diagnostic tasks.

### Tip 6: Version Control Your Investigations
Keep debugging documentation in git alongside code. It's valuable historical context.

### Tip 7: Rubber Duck with Templates
Reading template sections out loud can trigger insights (rubber duck debugging).

### Tip 8: Share War Stories
Use completed investigations as case studies for team learning sessions.

### Tip 9: Build a Bug Pattern Database
Tag bugs by pattern from common-bug-patterns.md. Track which patterns you see most often.

### Tip 10: Set Up Logging Early
Implement logging-strategies.md practices before you need them. Good logs make debugging 10x faster.

---

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @debugger - Primary consumer of this skill's templates and methodologies

**Extracted From:**
- templates/agents/debugger.yaml (328 lines)
- Total expansion: 5,320 lines of templates and references
