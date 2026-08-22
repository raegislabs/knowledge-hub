# Bug Lifecycle Guide

## Overview

This guide explains the complete lifecycle of a bug from discovery through resolution, including states, severity levels, priority assignment, triage processes, and best practices for bug management.

---

## Bug States

### Standard Bug Lifecycle

```
New → Assigned → In Progress → Fixed → Verified → Closed
                        ↓
                    Reopened (if verification fails)
                        ↓
                    Deferred/Won't Fix (if decision made not to fix)
```

---

### 1. New

**Description**: Bug has been reported but not yet reviewed.

**Who Can Set**: QA Engineer, Developer, User

**Next Steps**:
- Triage meeting to review
- Assign severity and priority
- Assign to developer or defer

**Typical Duration**: <24 hours

---

### 2. Assigned

**Description**: Bug has been triaged and assigned to a developer.

**Who Can Set**: QA Lead, Tech Lead, Project Manager

**Requirements**:
- Severity defined
- Priority defined
- Developer assigned
- Target version set (if applicable)

**Next Steps**:
- Developer acknowledges assignment
- Developer investigates and reproduces
- Developer begins work

**Typical Duration**: <48 hours before work begins

---

### 3. In Progress

**Description**: Developer is actively working on the fix.

**Who Can Set**: Assigned Developer

**Requirements**:
- Bug reproduced and root cause identified
- Fix approach determined
- Work actively underway

**Activities**:
- Code changes
- Unit tests written/updated
- Code review prepared

**Next Steps**:
- Code complete and tested locally
- Code review requested
- Move to Fixed

**Typical Duration**: 1-5 days (varies by severity)

---

### 4. Fixed

**Description**: Developer has completed the fix and it's ready for verification.

**Who Can Set**: Assigned Developer

**Requirements**:
- Code changes complete
- Code reviewed and approved
- Unit tests passing
- Merged to appropriate branch
- Build deployed to test environment

**Next Steps**:
- QA verifies the fix
- Regression testing performed
- Move to Verified (if pass) or Reopened (if fail)

**Typical Duration**: 1-3 days (waiting for QA verification)

---

### 5. Verified

**Description**: QA has confirmed the fix resolves the issue.

**Who Can Set**: QA Engineer

**Requirements**:
- Original bug no longer reproduces
- Regression tests pass
- No new issues introduced
- Fix confirmed in test environment

**Next Steps**:
- Wait for deployment to production
- Move to Closed after production deployment

**Typical Duration**: Until next release

---

### 6. Closed

**Description**: Bug is resolved and deployed to production.

**Who Can Set**: QA Engineer, Release Manager

**Requirements**:
- Fix deployed to production
- Smoke tests pass in production
- No regression issues reported

**Final State**: Yes

**Can Reopen**: Yes (if bug reappears in production)

---

### 7. Reopened

**Description**: Bug failed verification or reappeared after being closed.

**Who Can Set**: QA Engineer

**Reasons**:
- Fix didn't resolve the issue
- Regression occurred
- Bug reappeared in production
- Incomplete fix

**Next Steps**:
- Re-assign to developer
- Additional investigation
- Return to In Progress

---

### 8. Deferred

**Description**: Bug acknowledged but will not be fixed in current release.

**Who Can Set**: Product Owner, Tech Lead, Project Manager

**Reasons**:
- Low priority/severity
- Limited resources
- Workaround available
- Edge case with minimal impact
- Scheduled for future release

**Requirements**:
- Justification documented
- Future target version set (optional)
- Stakeholder approval

**Final State**: No (can be reopened for future release)

---

### 9. Won't Fix

**Description**: Bug acknowledged but decision made not to fix.

**Who Can Set**: Product Owner, Tech Lead

**Reasons**:
- Working as designed
- Feature deprecated
- Cost of fix exceeds benefit
- Better solution planned
- Not reproducible

**Requirements**:
- Detailed justification
- Stakeholder agreement
- Alternative solution documented (if applicable)

**Final State**: Yes

---

## Severity Levels

### Critical (Blocker)

**Definition**: System crash, data loss, security breach, complete feature failure.

**Examples**:
- Application crashes on startup
- Database corruption
- Security vulnerability (SQL injection, XSS)
- Data loss during operation
- Payment processing fails
- Authentication completely broken

**Impact**: All users affected, system unusable

**Response Time**: Immediate (same day)

**Fix Timeline**: Hotfix within 24-48 hours

**Escalation**: Immediate notification to leadership

---

### High (Critical)

**Definition**: Major functionality broken, no workaround, severely impacts users.

**Examples**:
- Core feature completely non-functional
- Unable to save work
- Critical workflow blocked
- API endpoints returning 500 errors
- Performance degradation >50%
- Data displayed incorrectly

**Impact**: Many users affected, major functionality lost

**Response Time**: Within 24 hours

**Fix Timeline**: Next patch release (1-7 days)

**Escalation**: Notification to tech lead and product owner

---

### Medium (Major)

**Definition**: Functionality broken but workaround available, moderate user impact.

**Examples**:
- Feature works but with incorrect behavior
- UI rendering issues
- Search returns incomplete results
- Validation errors on edge cases
- Performance degradation <50%
- Minor data inconsistencies

**Impact**: Some users affected, workaround available

**Response Time**: Within 48-72 hours

**Fix Timeline**: Next minor/major release (1-4 weeks)

**Escalation**: Standard bug tracking

---

### Low (Minor)

**Definition**: Minor functionality issue, cosmetic problems, minimal impact.

**Examples**:
- UI misalignment
- Typos in error messages
- Non-critical validation missing
- Minor usability improvements
- Console warnings (not errors)
- Tooltip not showing

**Impact**: Few users affected, minimal disruption

**Response Time**: Within 1 week

**Fix Timeline**: Future release when convenient

**Escalation**: None

---

### Trivial

**Definition**: Cosmetic issues only, no functional impact.

**Examples**:
- Text color slightly off
- Icon size inconsistent
- Spacing issues
- Typos in comments
- Outdated documentation

**Impact**: Negligible

**Response Time**: No SLA

**Fix Timeline**: When resources available

**Escalation**: None

---

## Priority Levels

**Note**: Severity ≠ Priority. Severity is technical impact; priority is business urgency.

### P0 (Critical)

**Definition**: Must fix immediately, blocks release or production.

**Examples**:
- Production system down
- Security breach
- Data loss in progress
- Legal/compliance violation

**Fix Timeline**: Hotfix ASAP (hours)

**Resource Allocation**: All hands on deck

---

### P1 (High)

**Definition**: Must fix for current release.

**Examples**:
- Blocker severity bugs
- High-severity bugs affecting key features
- Bugs in critical user paths

**Fix Timeline**: Before release (days)

**Resource Allocation**: Prioritize over new features

---

### P2 (Medium)

**Definition**: Should fix if time permits in current release.

**Examples**:
- Medium severity bugs
- Non-critical functionality issues
- Usability improvements

**Fix Timeline**: Current or next release (weeks)

**Resource Allocation**: Balance with feature work

---

### P3 (Low)

**Definition**: Fix when convenient, nice to have.

**Examples**:
- Low/trivial severity bugs
- Edge cases
- Cosmetic issues
- Tech debt

**Fix Timeline**: Future release (months)

**Resource Allocation**: Backlog

---

### P4 (Won't Fix / Deferred)

**Definition**: Acknowledged but not planned for fixing.

**Examples**:
- Trivial cosmetic issues
- Rarely used features
- Issues with workarounds
- Deprecated functionality

**Fix Timeline**: Never or distant future

**Resource Allocation**: None

---

## Severity vs Priority Matrix

| Severity ↓ / Probability → | Rare | Occasional | Frequent |
|---------------------------|------|------------|----------|
| **Critical (Blocker)** | P1 | P0 | P0 |
| **High** | P2 | P1 | P0 |
| **Medium** | P3 | P2 | P1 |
| **Low** | P4 | P3 | P2 |
| **Trivial** | P4 | P4 | P3 |

---

## Bug Triage Process

### Triage Meeting Structure

**Frequency**: Daily (for active projects) or Weekly

**Attendees**:
- QA Lead
- Tech Lead
- Product Owner
- Senior Developers (as needed)

**Duration**: 15-30 minutes

**Agenda**:
1. Review new bugs (5 min)
2. Assign severity and priority (10 min)
3. Assign to developers (5 min)
4. Review deferred/won't fix decisions (5 min)
5. Update target versions (5 min)

---

### Triage Decision Framework

**For Each Bug**:

1. **Verify Reproducibility**
   - Can we reproduce it?
   - Is it a real bug or user error?
   - Is it a duplicate?

2. **Assess Severity**
   - What's the technical impact?
   - How many users affected?
   - Is there a workaround?

3. **Assign Priority**
   - Business urgency?
   - Customer impact?
   - Release schedule?

4. **Make Decision**
   - Fix now (P0/P1)
   - Fix soon (P2)
   - Fix later (P3)
   - Defer/Won't Fix (P4)

5. **Assign Owner**
   - Who's best suited to fix?
   - Workload balancing
   - Domain expertise

---

### Triage Outcomes

**Possible Decisions**:
- ✅ **Accept**: Assign and schedule for fix
- ⏸️ **Defer**: Move to future release
- ❌ **Reject**: Won't fix (not a bug, by design, etc.)
- 🔄 **Need More Info**: Insufficient details, assign back to reporter
- 🔀 **Duplicate**: Close as duplicate of existing bug

---

## Bug Reporting Best Practices

### Essential Information

Every bug report must include:

1. **Title**: Clear, concise summary
2. **Environment**: OS, browser, version, configuration
3. **Steps to Reproduce**: Exact steps, numbered
4. **Expected Result**: What should happen
5. **Actual Result**: What actually happens
6. **Severity**: Technical impact assessment
7. **Evidence**: Screenshots, logs, videos

---

### Good Bug Title Examples

**Bad**:
- "Login doesn't work"
- "Error in checkout"
- "Bug in dashboard"

**Good**:
- "Login fails with 'Invalid session' error for users with 2FA enabled"
- "Checkout page shows 500 error when applying promo code 'SAVE20'"
- "Dashboard widgets fail to load for users in 'Europe/London' timezone"

**Format**: `[Component] Brief description of issue with key details`

---

### Steps to Reproduce Template

```markdown
**Steps to Reproduce:**

1. Navigate to {URL/Page}
2. Enter {specific data} in {field name}
3. Click {button name}
4. Observe {what happens}

**Expected Result:**
{What should happen}

**Actual Result:**
{What actually happens}

**Additional Context:**
- Browser: Chrome 120
- OS: macOS 14.0
- User Role: Admin
- Account Type: Premium
```

---

## Bug Metrics and KPIs

### Defect Density

**Formula**: Defects / 1000 Lines of Code (KLOC)

**Industry Benchmarks**:
- Excellent: <0.5 defects/KLOC
- Good: 0.5-1.0 defects/KLOC
- Average: 1.0-2.0 defects/KLOC
- Poor: >2.0 defects/KLOC

---

### Defect Detection Rate

**Formula**: (Defects Found Pre-Prod / Total Defects) × 100

**Target**: >90% (catch bugs before production)

---

### Defect Escape Rate

**Formula**: (Production Defects / Total Defects) × 100

**Target**: <10% (keep bugs out of production)

---

### Mean Time to Detect (MTTD)

**Formula**: Average time from bug introduction to detection

**Target**: <24 hours (shift-left testing)

---

### Mean Time to Resolve (MTTR)

**Formula**: Average time from bug report to fix deployed

**By Severity**:
- Critical: <24 hours
- High: <3 days
- Medium: <2 weeks
- Low: <1 month

---

### Bug Burn-Down Rate

**Formula**: Bugs closed per sprint / Bugs opened per sprint

**Target**: ≥1.0 (closing faster than opening)

---

### Bug Age Distribution

**Metrics**:
- % bugs <7 days old
- % bugs 7-30 days old
- % bugs >30 days old

**Target**: <10% bugs older than 30 days

---

## Bug Prevention Strategies

### 1. Code Reviews

**Process**:
- Every code change reviewed by 2+ developers
- Checklist-based review
- Focus on common bug patterns

**Benefit**: Catch 60-70% of bugs before testing

---

### 2. Static Analysis

**Tools**:
- **Python**: pylint, mypy, bandit
- **JavaScript**: ESLint, TypeScript
- **General**: SonarQube

**Benefit**: Catch common errors automatically

---

### 3. Test-Driven Development (TDD)

**Process**:
- Write tests before code
- Red → Green → Refactor

**Benefit**: Better design, fewer bugs, higher coverage

---

### 4. Continuous Integration

**Process**:
- Automated tests run on every commit
- Fast feedback (< 10 minutes)
- Fail fast, fix fast

**Benefit**: Catch bugs within minutes of introduction

---

### 5. Pair Programming

**Process**:
- Two developers, one keyboard
- Driver codes, navigator reviews
- Rotate roles regularly

**Benefit**: Real-time code review, knowledge sharing

---

## Bug Fix Validation

### Verification Checklist

**Before Marking as Fixed**:

- [ ] Original bug no longer reproduces
- [ ] All steps in bug report pass
- [ ] Edge cases tested
- [ ] Regression testing performed
- [ ] Unit tests added/updated
- [ ] Code review completed
- [ ] No new bugs introduced
- [ ] Performance not degraded
- [ ] Documentation updated (if needed)

---

### Regression Testing

**Scope**:
- Test original bug scenario
- Test related functionality
- Test common workflows
- Run automated regression suite

**Risk Areas**:
- Same module as bug fix
- Modules that depend on fixed module
- Similar functionality elsewhere

---

## Bug Communication

### Bug Status Updates

**Frequency**:
- **Critical bugs**: Daily updates
- **High priority**: Every 2-3 days
- **Medium/Low**: Weekly

**Content**:
- Current status
- Progress made
- Blockers (if any)
- Expected resolution date

---

### Stakeholder Notification

**Notify When**:
- Critical bug discovered
- Target fix date changes
- Bug deferred or won't fix
- Bug verified and ready for release
- Bug reappears after being fixed

**Recipients**:
- Product Owner
- Tech Lead
- Affected team members
- Customer Support (if customer-facing)

---

## Common Pitfalls

### 1. Unclear Bug Reports

**Problem**: Missing steps, vague description
**Solution**: Use bug report template, require all fields

---

### 2. Duplicate Bugs

**Problem**: Same bug reported multiple times
**Solution**: Search before reporting, link duplicates

---

### 3. Stale Bugs

**Problem**: Bugs sit in backlog for months
**Solution**: Regular triage, deferred/won't fix decisions

---

### 4. Severity Inflation

**Problem**: Everything marked "Critical"
**Solution**: Clear severity definitions, triage review

---

### 5. Lack of Prioritization

**Problem**: All bugs treated equally
**Solution**: Priority framework, regular re-prioritization

---

### 6. Not Reproducing Bugs

**Problem**: Marking as "Cannot Reproduce" too quickly
**Solution**: Try different environments, ask reporter for details

---

### 7. Fixing Symptoms, Not Root Cause

**Problem**: Bug returns in different form
**Solution**: Root cause analysis, comprehensive fix

---

## Root Cause Analysis (RCA)

### 5 Whys Technique

**Example**:

```
Bug: Login fails for some users

Why? → Session token is null
Why? → Token generation failed
Why? → Random number generator seeded incorrectly
Why? → Seed value is timestamp, but server time out of sync
Why? → NTP service not running on server

Root Cause: NTP service not running
Fix: Configure NTP, add monitoring
```

---

### Fishbone Diagram (Ishikawa)

**Categories**:
- **People**: Skills, training, mistakes
- **Process**: Procedures, reviews, testing
- **Technology**: Tools, platforms, dependencies
- **Environment**: Configuration, infrastructure

---

### RCA Documentation Template

```markdown
## Bug: {Title}

**Symptom**: What users experienced

**Root Cause**: Underlying issue that caused the bug

**Why It Occurred**: How/why the root cause existed

**Fix Applied**: What was changed

**Prevention**: How to prevent similar bugs
- Code changes
- Process improvements
- New tests added
- Documentation updated
```

---

## Summary

**Key Concepts**:

1. **Bug Lifecycle**: New → Assigned → In Progress → Fixed → Verified → Closed
2. **Severity**: Technical impact (Blocker, Critical, Major, Minor, Trivial)
3. **Priority**: Business urgency (P0, P1, P2, P3, P4)
4. **Triage**: Regular review, severity/priority assignment, decision-making
5. **Metrics**: Defect density, detection rate, escape rate, MTTR
6. **Prevention**: Code reviews, static analysis, TDD, CI/CD
7. **RCA**: Find and fix root causes, not just symptoms

**Best Practices**:

- Clear bug reports with steps to reproduce
- Regular triage meetings
- Prioritize based on severity and business impact
- Verify fixes thoroughly before closing
- Learn from bugs (RCA) to prevent recurrence
- Communicate status updates to stakeholders
- Track metrics to measure improvement

**Recommended Reading**:
- "Managing the Testing Process" by Rex Black
- "Software Testing" by Ron Patton
- "The Art of Agile Development" by James Shore
