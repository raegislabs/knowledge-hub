# QA Templates

---
name: qa-templates
description: Comprehensive templates and methodologies for quality assurance, testing, and bug management. Use when planning tests, writing test cases, reporting bugs, validating releases, or conducting exploratory testing. Provides structured templates for test plans, bug reports, QA checklists, and release validation procedures.
---

## Overview

This skill provides production-ready templates and systematic methodologies for conducting comprehensive quality assurance and testing activities. It complements the @qa-engineer agent by providing standardized formats, testing frameworks, and best practices for ensuring software quality.

**When to use this skill:**
- Planning test strategies and writing test plans
- Creating comprehensive test cases
- Reporting and tracking bugs systematically
- Conducting release validation and smoke testing
- Performing exploratory testing sessions
- Reviewing code quality before deployment
- Tracking quality metrics and test coverage
- Implementing QA processes and standards

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive methodologies.

---

## Available Templates

This skill provides 7 production-ready templates in `assets/`:

### 1. Test Plan Template
**File:** `assets/test-plan-template.md`

Complete test planning documentation format including:
- Test overview (purpose, scope, objectives)
- Test strategy (levels, approach, risk-based testing)
- Test environment (prerequisites, data, setup)
- Detailed test cases (functional, edge cases, error handling, integration)
- Test schedule (phases and timeline)
- Resources (team, tools, documentation)
- Entry and exit criteria
- Risk assessment and mitigation
- Deliverables and approval

**Use when:** Planning testing for new features, releases, or major changes requiring formal test strategy.

**Example usage:**
```markdown
# Test Plan: User Authentication System

## 1. Test Overview

### Purpose
Verify the user authentication system meets security requirements and provides reliable login/logout functionality.

### Scope
**In Scope:**
- Login with username/password
- Multi-factor authentication (2FA)
- Password reset flow
- Session management
- Account lockout after failed attempts

**Out of Scope:**
- Third-party OAuth integration (future release)
- SSO enterprise features
```

---

### 2. Test Case Template
**File:** `assets/test-case-template.md`

Detailed test case specification format with:
- Test case information (ID, name, priority, type)
- Test objective and description
- Preconditions and test data
- Detailed test steps (Arrange-Act-Assert)
- Expected results vs actual results
- Postconditions and cleanup
- pytest implementation examples
- Dependencies and automation status
- Test execution history

**Use when:** Writing individual test cases for features, user stories, or acceptance criteria.

**Example usage:**
```markdown
# Test Case: TC-LOGIN-001

**Test Case ID**: TC-LOGIN-001
**Test Case Name**: Login with valid credentials succeeds
**Priority**: High
**Test Type**: Integration

## Test Objective
Verify that users can successfully log in with valid username and password.

## Preconditions
- User account exists in database
- User account is active (not locked)

## Test Steps

| Step # | Action | Expected Result |
|--------|--------|-----------------|
| 1 | Navigate to /login | Login page displays |
| 2 | Enter valid username | Username accepted |
| 3 | Enter valid password | Password accepted |
| 4 | Click "Login" button | Redirect to dashboard |

### pytest Implementation
```python
def test_login_with_valid_credentials(test_client):
    response = test_client.post('/login', data={
        'username': 'john@example.com',
        'password': 'ValidPass123!'
    })
    assert response.status_code == 302
    assert response.location == '/dashboard'
```
```

---

### 3. Bug Report Template
**File:** `assets/bug-report-template.md`

Comprehensive bug reporting format with:
- Bug information (ID, title, status, priority, severity)
- Priority and severity definitions (with matrix)
- Environment details (OS, browser, version, config)
- Clear steps to reproduce
- Expected vs actual behavior
- Screenshots, error messages, logs
- Code context and affected files
- Root cause analysis section
- Impact assessment (user, system, business)
- Workaround documentation
- Test case for regression prevention
- Resolution tracking and verification

**Use when:** Reporting bugs, tracking defects, or documenting quality issues.

**Example usage:**
```markdown
# Bug Report: Login Fails with Valid Credentials After 2FA Enabled

## Bug Information

**Bug ID**: BUG-247
**Status**: Assigned
**Priority**: High (affects key feature, workaround difficult)
**Severity**: Major (functionality broken, workaround exists)
**Reported By**: Jane Smith (QA)
**Assigned To**: John Developer

## Steps to Reproduce

1. Create user account with email `test@example.com`
2. Enable 2FA in account settings
3. Log out completely
4. Navigate to /login
5. Enter valid credentials
6. Enter valid 2FA code
7. Click "Login"
8. Observe error: "Invalid session"

**Expected Result:** User redirected to dashboard
**Actual Result:** Error message "Invalid session", user not logged in

## Environment
- Browser: Chrome 120
- OS: macOS 14.0
- Application Version: v2.3.1
```

---

### 4. QA Checklist Template
**File:** `assets/qa-checklist-template.md`

Comprehensive quality assurance checklist covering:
1. **Functional Testing** (core functionality, input/output validation, edge cases)
2. **User Interface Testing** (visual design, usability, accessibility, browser compatibility)
3. **Performance Testing** (load time, resource usage, scalability)
4. **Security Testing** (authentication, authorization, data protection, API security)
5. **Integration Testing** (database, external APIs, third-party services)
6. **Data Testing** (integrity, migration, validation)
7. **Error Handling** (detection, recovery, logging)
8. **Test Coverage** (unit, integration, regression tests)
9. **Documentation** (code, user, technical docs)
10. **Deployment Readiness** (configuration, validation, post-deployment)

**Use when:** Conducting comprehensive QA review before releases, deployments, or feature sign-offs.

**Example usage:**
```markdown
# QA Checklist: Payment Processing Feature v2.0

## 1. Functional Testing

### Core Functionality
- [x] Credit card payments process successfully
- [x] Debit card payments process successfully
- [x] Payment confirmation email sent
- [x] Transaction recorded in database
- [x] Receipt generated and downloadable

### Input Validation
- [x] Card number validation (Luhn algorithm)
- [x] Expiry date validation (future dates only)
- [x] CVV validation (3-4 digits)
- [x] Billing address required fields enforced
- [ ] International postal codes handled (BLOCKED: BUG-248)

## Issues Found: 1 (BUG-248 - Medium Priority)
```

---

### 5. Test Report Template
**File:** `assets/test-report-template.md`

Detailed test execution report with:
- Executive summary and quick metrics
- Test coverage summary (total tests, pass rate, code coverage)
- Test categories (functionality, edge cases, error handling, integration, performance, security, UI)
- Issues found by severity (critical, high, medium, low)
- Test execution details (environment, commands, output)
- Test artifacts (reports, data, screenshots)
- Recommendations (release decision, improvements, technical debt)
- Test metrics history and trends
- Regression testing results
- Sign-off section

**Use when:** Documenting test results, reporting to stakeholders, or archiving test execution records.

**Example usage:**
```markdown
# Test Report: User Authentication v2.0

## Executive Summary

**Overall Status**: ✅ Pass
**Recommendation**: Approved for Release

### Quick Summary
Comprehensive testing of user authentication system (v2.0) completed over 5-day period. All 87 test cases executed with 97% pass rate. Code coverage exceeds 90% target. No critical or high-severity bugs remain open. System meets quality standards for production deployment.

## Test Coverage Summary

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Total Tests** | 87 | - | - |
| **Passed** | 85 | - | ✅ |
| **Failed** | 2 | 0 | ⚠️ (Low severity) |
| **Code Coverage** | 93% | ≥90% | ✅ |
| **Bugs Found** | 8 | - | - |
| **Critical Bugs** | 0 | 0 | ✅ |
```

---

### 6. Release Validation Template
**File:** `assets/release-validation-template.md`

Complete release validation checklist with:
- Pre-release checklist (code quality, documentation, dependencies, configuration)
- Smoke tests (critical paths with detailed steps)
- Regression validation (high/medium/low priority features)
- Performance validation (response times, resource usage, load testing)
- Security validation (auth, data protection, input validation)
- Database validation (schema, data integrity)
- Monitoring and logging checks
- Browser and platform validation
- User acceptance testing (UAT) sign-off
- Issues discovered during validation
- Go/No-Go decision framework
- Post-release monitoring plan
- Rollback plan and procedure

**Use when:** Validating releases before production deployment, conducting smoke tests, or making go/no-go decisions.

**Example usage:**
```markdown
# Release Validation: v2.3.0

## Pre-Release Checklist

### Code Quality
- [x] All tests passing in CI/CD
- [x] Code coverage ≥ 90% (actual: 93%)
- [x] No critical or high-severity bugs open
- [x] Code review completed and approved
- [x] Security scan completed (no critical vulnerabilities)

## Smoke Tests

### Critical Path 1: User Login Flow
**Status**: ✅ Pass

1. [x] Navigate to login page
2. [x] Enter valid credentials
3. [x] Verify successful login
4. [x] Verify dashboard loads
5. [x] Logout successfully

**Result**: Pass
**Time**: 2 minutes

## Go/No-Go Decision

**Decision**: ✅ GO for Production Release

**Justification**: All smoke tests pass, no critical issues, performance within SLA, stakeholder approval received.
```

---

### 7. Exploratory Testing Charter Template
**File:** `assets/exploratory-testing-charter-template.md`

Session-based exploratory testing format with:
- Charter information (mission, scope, time box)
- Testing strategy (heuristics, tours, areas of focus)
- Pre-session test ideas
- Session log (time-stamped actions and observations)
- Bugs and issues found
- Observations and insights
- Coverage assessment
- Risks identified
- Test data used
- Session metrics (time allocation, productivity)
- Recommendations and next steps
- Debrief notes
- Template usage guide

**Use when:** Conducting exploratory testing sessions, testing new features, or looking for unknown issues beyond scripted tests.

**Example usage:**
```markdown
# Exploratory Testing Charter

## Charter Information

**Charter ID**: ETC-042
**Feature/Area**: User Registration Flow
**Tester**: Jane Smith
**Time Box**: 60 minutes

## Mission

**Explore** the user registration flow
**With** various input combinations, special characters, edge cases
**To discover** input validation bugs, UX issues, security vulnerabilities

## Session Log

**Time**: 14:00
**Action**: Tested registration with email "user+test@example.com"
**Observation**: Plus sign (+) not accepted, shown as invalid character
**Notes**: Bug? Many email providers support + addressing

**Time**: 14:15
**Action**: Tried registering with very long name (200 characters)
**Observation**: Form accepts but truncates to 50 chars without warning
**Notes**: Should show error or character limit indicator

## Bugs Found: 2 (filed as BUG-249, BUG-250)
```

---

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. Test Strategy Guide
**File:** `references/test-strategy-guide.md`

Comprehensive testing strategies and methodologies with:

**4 Levels of Testing:**
1. **Unit Testing** - Individual functions/methods, fast (<100ms), high volume
2. **Integration Testing** - Component interactions, medium speed (seconds), moderate volume
3. **System Testing** - Complete application E2E, slow (minutes), low volume
4. **Acceptance Testing** - Business requirements, user validation, manual or automated

**Test Strategy Approaches:**
- **Risk-Based Testing**: Prioritize by complexity, criticality, change frequency, defect history
- **Shift-Left Testing**: Test early and often in development lifecycle
- **Test-Driven Development (TDD)**: Red-Green-Refactor cycle
- **Behavior-Driven Development (BDD)**: Gherkin syntax, shared understanding

**Test Design Techniques:**
- Equivalence Partitioning
- Boundary Value Analysis
- Decision Table Testing
- State Transition Testing
- Pairwise Testing

**Quality Metrics:**
- Code Coverage (>90% for critical code)
- Defect Density (<1.0 defects/KLOC)
- Defect Detection Rate (>90%)
- Test Effectiveness metrics

**Best Practices:**
- Test Pyramid (many unit tests, few E2E tests)
- Test naming conventions
- Test independence
- Fast feedback loops
- Test data management

**Use when:** Designing overall test strategy, choosing testing methodologies, or implementing quality standards.

---

### 2. Test Case Design Guide
**File:** `references/test-case-design.md`

Techniques and patterns for designing effective test cases:

**Black-Box Testing Techniques:**

1. **Equivalence Partitioning**: Divide inputs into groups with similar behavior
   - Example: Age validation (invalid <18, valid 18-65, invalid >65)

2. **Boundary Value Analysis**: Test at edges of partitions
   - Example: For range 0-100, test -1, 0, 1, 99, 100, 101

3. **Decision Table Testing**: Test all condition combinations
   - Example: Login (username valid Y/N × password valid Y/N = 4 combinations)

4. **State Transition Testing**: Test state changes
   - Example: Order states (Draft → Submitted → Paid → Shipped → Delivered)

5. **Use Case Testing**: Derive tests from user stories
   - Example: Login use case with primary and alternative flows

6. **Error Guessing**: Anticipate common errors
   - Empty strings, null values, special characters, SQL injection

**White-Box Testing Techniques:**

1. **Statement Coverage**: Execute every line of code
2. **Branch Coverage**: Execute every conditional branch
3. **Path Coverage**: Execute every possible path

**Advanced Patterns:**

- **Pairwise Testing**: Test all pairs of parameters (reduces combinatorial explosion)
- **Property-Based Testing**: Define properties, generate random inputs (Hypothesis)
- **Exploratory Testing**: Structured exploration with charters

**Test Organization:**
- Grouping strategies (by feature, test type, priority)
- Naming conventions
- Test data builders and fixtures

**Use when:** Writing test cases, improving test coverage, or teaching testing techniques.

---

### 3. Bug Lifecycle Guide
**File:** `references/bug-lifecycle.md`

Complete bug management lifecycle and processes:

**Bug States:**
```
New → Assigned → In Progress → Fixed → Verified → Closed
                      ↓
                  Reopened (if fails verification)
                      ↓
                  Deferred/Won't Fix
```

**Severity Levels:**
- **Critical (Blocker)**: System crash, data loss, security breach
- **High**: Major functionality broken, no workaround
- **Medium (Major)**: Functionality broken, workaround available
- **Low (Minor)**: Minor issues, cosmetic problems
- **Trivial**: Cosmetic only, no functional impact

**Priority Levels:**
- **P0 (Critical)**: Fix immediately, hotfix ASAP
- **P1 (High)**: Must fix for current release
- **P2 (Medium)**: Should fix if time permits
- **P3 (Low)**: Fix when convenient
- **P4 (Won't Fix)**: Acknowledged but not planned

**Severity vs Priority Matrix:**
Determines urgency based on technical impact and business value

**Bug Triage Process:**
- Daily/weekly triage meetings
- Verify reproducibility, assess severity, assign priority
- Decision: Accept, Defer, Reject, Need More Info, Duplicate

**Bug Metrics:**
- Defect Density (<1.0/KLOC target)
- Defect Detection Rate (>90% target)
- Defect Escape Rate (<10% target)
- Mean Time to Resolve (MTTR)
- Bug Age Distribution

**Bug Prevention:**
- Code reviews (catch 60-70% of bugs)
- Static analysis (automated error detection)
- TDD (better design, fewer bugs)
- Continuous Integration (fast feedback)

**Root Cause Analysis:**
- 5 Whys technique
- Fishbone diagram (Ishikawa)
- RCA documentation

**Use when:** Managing bugs, conducting triage, tracking defects, or implementing bug workflows.

---

### 4. QA Methodologies Guide
**File:** `references/qa-methodologies.md`

Testing approaches for different software development lifecycles:

**Waterfall Testing:**
- Sequential phases (Requirements → Design → Development → Testing → Deployment)
- Testing after development complete
- Formal documentation, clear exit criteria
- **Best for**: Stable requirements, regulated industries

**Agile Testing:**
- Iterative development (sprints)
- Continuous testing, dev+QA collaboration
- Agile Testing Quadrants (Q1: Unit/Integration, Q2: Functional, Q3: Exploratory/UAT, Q4: Performance/Security)
- **Best for**: Evolving requirements, fast-moving products

**DevOps Testing (Continuous Testing):**
- Automated testing in CI/CD pipeline
- Shift-left (test early) and shift-right (test in production)
- Fast feedback loops (<10 min)
- **Best for**: SaaS products, high-frequency releases

**Testing Methodologies:**

1. **Test-Driven Development (TDD)**
   - Red-Green-Refactor cycle
   - Write tests before code
   - 100% coverage achievable

2. **Behavior-Driven Development (BDD)**
   - Gherkin syntax (Given-When-Then)
   - Shared understanding
   - Living documentation

3. **Acceptance Test-Driven Development (ATDD)**
   - Write acceptance tests before development
   - Clear definition of done

**Testing Types:**

- **Functional**: Unit, Integration, System, Regression, Smoke, Sanity
- **Non-Functional**: Performance (load, stress, spike, endurance), Security, Usability, Compatibility, Reliability

**Test Automation:**
- Test Pyramid (70% unit, 20% service, 10% E2E)
- What to automate (regression, smoke, API tests)
- What not to automate (one-time, changing UI, exploratory)

**Context-Specific Testing:**
- Microservices (contract testing, chaos engineering)
- Mobile apps (device fragmentation, network conditions)
- API testing (request/response, status codes, security)

**Use when:** Choosing testing methodology, adapting to SDLC, or implementing test automation strategy.

---

### 5. Quality Metrics Guide
**File:** `references/quality-metrics.md`

Comprehensive metrics for measuring and tracking quality:

**Test Coverage Metrics:**
- **Code Coverage**: >80% overall, >95% critical code (line, branch, function coverage)
- **Test Case Coverage**: 100% critical requirements, >95% overall
- **Requirements Coverage**: % of acceptance criteria tested

**Defect Metrics:**
- **Defect Density**: <1.0 defects/KLOC (good)
- **Defect Detection Rate**: >90% (find before production)
- **Defect Escape Rate**: <10% (keep out of production)
- **Defect Removal Efficiency**: >95% cumulative before production
- **Defect Aging**: <10% bugs older than 30 days
- **Defect Injection Rate**: Track defects per feature

**Test Execution Metrics:**
- **Test Pass Rate**: >95% target
- **Test Execution Time**: Unit <10s, Integration <5min, E2E <30min
- **Test Flakiness Rate**: <2% target (flaky tests erode confidence)
- **Test Automation Coverage**: >70% target

**Time-Based Metrics:**
- **Mean Time to Detect (MTTD)**: <24 hours target (shift-left)
- **Mean Time to Resolve (MTTR)**: Critical <24hr, High <3d, Medium <2w, Low <1m
- **Test Cycle Time**: Varies by release cadence

**Quality Trend Metrics:**
- **Bug Burn-Down Rate**: ≥1.0 target (closing faster than opening)
- **Test Case Effectiveness**: >30% tests found bugs
- **Defect Trend by Severity**: Track over time

**Team Performance Metrics:**
- Test Productivity (5-10 test cases/tester/day)
- Defect Detection Efficiency (2-5 defects/tester/day)
- Test Execution Rate (30-50 manual, 500+ automated)

**Advanced Metrics:**
- Weighted Defect Density (severity-weighted)
- Test ROI (value prevented vs testing cost)
- Test Debt (untested requirements)

**Dashboards:**
- Executive Dashboard (quality score, escape rate, critical bugs)
- QA Team Dashboard (execution progress, defects, automation, MTTR)
- Developer Dashboard (coverage, pass rate, static analysis)

**Metric Anti-Patterns:**
- Vanity metrics (total tests, 100% coverage without quality)
- Metric gaming (optimizing metric, not quality)
- Lagging indicators only (balance with leading indicators)

**Use when:** Tracking quality, measuring test effectiveness, reporting to stakeholders, or making data-driven decisions.

---

## Usage Patterns

### Pattern 1: New Feature Testing (Comprehensive)

**Scenario:** Testing a new feature requiring full test strategy and documentation.

**Process:**
1. Read `test-strategy-guide.md` → Risk-Based Testing section
2. Use `test-plan-template.md` to create comprehensive test plan
3. Read `test-case-design.md` → Black-Box Techniques
4. Use `test-case-template.md` to write detailed test cases
5. Execute tests and use `test-report-template.md` for results
6. File bugs using `bug-report-template.md` as needed

**Time:** 1-2 weeks (depending on feature complexity)

**Deliverables:**
- Test plan document
- 20-50 detailed test cases
- Test execution report
- Bug reports for issues found

---

### Pattern 2: Quick Bug Reporting

**Scenario:** Found a bug, need to report it quickly and clearly.

**Process:**
1. Use `bug-report-template.md` as guide
2. Fill in: Title, Steps to Reproduce, Expected vs Actual, Environment
3. Read `bug-lifecycle.md` → Severity/Priority Definitions
4. Assign appropriate severity and priority
5. Attach screenshots/logs if available

**Time:** 15-30 minutes

**Deliverables:**
- Complete bug report ready for triage

---

### Pattern 3: Release Validation

**Scenario:** Validating a release before production deployment.

**Process:**
1. Use `release-validation-template.md` as checklist
2. Complete pre-release checklist (code quality, docs, dependencies)
3. Execute all smoke tests (critical paths)
4. Run regression validation
5. Check performance, security, database validation
6. Make Go/No-Go decision based on criteria
7. Document post-release monitoring plan

**Time:** 4-8 hours

**Deliverables:**
- Completed release validation checklist
- Go/No-Go decision with justification
- Issues log (if any discovered)

---

### Pattern 4: Exploratory Testing Session

**Scenario:** Testing new or unfamiliar feature with time-boxed exploration.

**Process:**
1. Use `exploratory-testing-charter-template.md`
2. Define clear mission/charter (60-90 min time box)
3. Read `test-case-design.md` → Error Guessing section
4. Conduct session, log observations in real-time
5. File bugs immediately using `bug-report-template.md`
6. Complete session metrics and recommendations

**Time:** 60-90 minutes (session) + 15-30 minutes (documentation)

**Deliverables:**
- Completed exploratory testing charter
- Bug reports for issues discovered
- Test ideas for future automation

---

### Pattern 5: QA Process Implementation

**Scenario:** Setting up QA processes for a new project or team.

**Process:**
1. Read `qa-methodologies.md` → Choose appropriate SDLC approach
2. Read `test-strategy-guide.md` → Establish testing strategy
3. Set up templates in project (test plan, test case, bug report)
4. Read `quality-metrics.md` → Define metrics to track
5. Establish bug triage process from `bug-lifecycle.md`
6. Train team on templates and workflows

**Time:** 1-2 weeks (setup and training)

**Deliverables:**
- QA process documentation
- Template library for team
- Metrics dashboard
- Team training materials

---

### Pattern 6: Metrics Tracking and Reporting

**Scenario:** Need to track and report quality metrics to stakeholders.

**Process:**
1. Read `quality-metrics.md` → Essential Metrics section
2. Choose metrics appropriate for your context (Waterfall/Agile/DevOps)
3. Set up dashboard (Executive, QA Team, or Developer)
4. Track metrics weekly/monthly
5. Include metrics summary in `test-report-template.md`
6. Use trends to drive improvement decisions

**Time:** 1-2 hours/week (ongoing)

**Deliverables:**
- Quality metrics dashboard
- Weekly/monthly quality reports
- Trend analysis and improvement recommendations

---

## Integration with @qa-engineer

This skill is designed to complement the @qa-engineer agent:

**Agent's Role:**
- Analyzes features and identifies test scenarios
- Writes pytest tests (unit, integration)
- Reviews code for quality issues
- Validates feature completeness
- Applies domain expertise and critical thinking

**Skill's Role:**
- Provides standardized templates for consistency
- Offers methodologies for systematic testing
- Ensures best practices are followed
- Supplies comprehensive checklists
- Guides bug management and triage processes

**Workflow:**
```markdown
User: "@qa-engineer, test the new payment processing feature"

Agent:
1. Loads qa-templates skill
2. Reads test-strategy-guide.md for approach
3. Reads test-case-design.md for techniques
4. Creates test plan using test-plan-template.md
5. Writes detailed test cases using test-case-template.md
6. Implements pytest tests based on test cases
7. Executes tests and uses test-report-template.md for results
8. Files bugs using bug-report-template.md if issues found
9. Uses qa-checklist-template.md for final validation
```

---

## Best Practices

### 1. Start with Strategy
Always read `test-strategy-guide.md` and `qa-methodologies.md` first to understand the systematic approach before diving into templates.

### 2. Use Appropriate Template
- **Comprehensive testing** → `test-plan-template.md` + `test-case-template.md`
- **Quick bug report** → `bug-report-template.md`
- **Release validation** → `release-validation-template.md` + `qa-checklist-template.md`
- **Exploratory testing** → `exploratory-testing-charter-template.md`
- **Test results** → `test-report-template.md`

### 3. Prioritize Based on Risk
Use `test-strategy-guide.md` → Risk-Based Testing framework to prioritize what to test first.

### 4. Document Systematically
Use templates consistently across team for standardization. Customize templates to fit your project needs.

### 5. Track Metrics
Use `quality-metrics.md` to identify essential metrics for your context. Track trends over time, not just snapshots.

### 6. Clear Bug Reports
Use `bug-report-template.md` for complete information. Include steps to reproduce, environment details, and evidence (screenshots/logs).

### 7. Comprehensive Checklists
Use `qa-checklist-template.md` before releases to ensure nothing is missed. Track issues found and resolution status.

### 8. Time-Box Exploratory Testing
Use `exploratory-testing-charter-template.md` with 60-90 minute time boxes. Focus on single mission per session.

### 9. Systematic Test Design
Use `test-case-design.md` techniques (equivalence partitioning, boundary analysis) for comprehensive coverage without redundancy.

### 10. Understand Bug Lifecycle
Read `bug-lifecycle.md` to understand severity vs priority, triage process, and bug prevention strategies.

---

## Complete Examples

### Example 1: Testing Login Feature

```markdown
**Scenario:** New login feature with username/password authentication needs comprehensive testing.

**Process:**

1. **Create Test Plan** (test-plan-template.md):
   - Scope: Login, logout, session management, password validation
   - Strategy: Risk-based (high priority - security critical)
   - Test cases: 25 planned (functional, edge cases, security)
   - Schedule: 3 days (design, execute, report)

2. **Design Test Cases** (test-case-design.md + test-case-template.md):
   - TC-LOGIN-001: Valid credentials → Success
   - TC-LOGIN-002: Invalid password → Error
   - TC-LOGIN-003: Account locked after 5 failures → Lockout
   - TC-LOGIN-004: SQL injection attempt → Sanitized
   - TC-LOGIN-005: XSS in username → Sanitized
   (20 more test cases...)

3. **Implement pytest Tests**:
```python
def test_login_with_valid_credentials(test_client):
    response = test_client.post('/login', data={
        'username': 'john@example.com',
        'password': 'ValidPass123!'
    })
    assert response.status_code == 302
    assert response.location == '/dashboard'

def test_login_with_invalid_password(test_client):
    response = test_client.post('/login', data={
        'username': 'john@example.com',
        'password': 'WrongPassword'
    })
    assert response.status_code == 401
    assert b'Invalid credentials' in response.data
```

4. **Execute Tests and Report** (test-report-template.md):
   - Total Tests: 25
   - Passed: 23
   - Failed: 2 (bugs found)
   - Coverage: 94%
   - Bugs Filed: BUG-101 (High), BUG-102 (Medium)

5. **File Bugs** (bug-report-template.md):
   - BUG-101: Account lockout doesn't reset after password reset
   - BUG-102: Error message reveals whether username exists (security)

**Result:** Comprehensive testing completed, critical security bug found and fixed before release.
```

---

### Example 2: Release Validation for Production

```markdown
**Scenario:** Release v2.5.0 ready for production, need validation before deployment.

**Process:**

1. **Pre-Release Checklist** (release-validation-template.md):
   - [x] All tests passing (487/487)
   - [x] Code coverage >90% (actual: 92%)
   - [x] No critical/high bugs open
   - [x] Security scan clean
   - [x] Documentation updated

2. **Smoke Tests** (5 critical paths):
   - Path 1: User Login → ✅ Pass (2 min)
   - Path 2: Create Order → ✅ Pass (3 min)
   - Path 3: Payment Processing → ✅ Pass (4 min)
   - Path 4: Admin Dashboard → ✅ Pass (2 min)
   - Path 5: API Health Check → ✅ Pass (1 min)

3. **Performance Validation**:
   - API response time: 280ms (target <500ms) → ✅
   - Page load time: 1.8s (target <3s) → ✅
   - Memory usage: 320MB (target <500MB) → ✅

4. **Security Validation**:
   - [x] SQL injection prevention verified
   - [x] XSS prevention verified
   - [x] Authentication working
   - [x] API keys secured

5. **Go/No-Go Decision**:
   - **Decision**: ✅ GO for Production
   - **Justification**: All smoke tests pass, performance within SLA, no critical issues
   - **Post-Release Monitoring**: 24-hour observation period, error rate monitoring

**Result:** Release approved and successfully deployed to production.
```

---

### Example 3: Exploratory Testing of New Feature

```markdown
**Scenario:** New "Advanced Search" feature just implemented, needs exploratory testing to find unexpected issues.

**Process:**

1. **Define Charter** (exploratory-testing-charter-template.md):
   - **Mission**: Explore advanced search with various query combinations
   - **Focus**: Input validation, performance, edge cases, UX issues
   - **Time Box**: 90 minutes

2. **Conduct Session**:
   **14:00** - Tested search with special characters (@, #, $)
   - Found: @ symbol causes 500 error → BUG-201

   **14:20** - Tested very long search queries (500+ chars)
   - Found: No character limit, slow response (8 seconds) → BUG-202

   **14:35** - Tested search with all filters enabled
   - Found: Date range picker allows end date before start date → BUG-203

   **14:50** - Tested search results pagination
   - Positive: Works well, fast navigation

   **15:05** - Tested search on mobile viewport
   - Found: Advanced filters hidden, no way to access → BUG-204

3. **File Bugs** (bug-report-template.md):
   - BUG-201: Special character @ causes 500 error (High)
   - BUG-202: No query length limit, performance degradation (Medium)
   - BUG-203: Date picker validation missing (Medium)
   - BUG-204: Mobile UX issue - filters inaccessible (High)

4. **Session Summary**:
   - **Bugs Found**: 4 (2 High, 2 Medium)
   - **Test Ideas for Automation**: 6
   - **Coverage**: ~60% of feature explored
   - **Recommendation**: Fix High priority bugs before release

**Result:** Found 4 bugs in 90 minutes that weren't caught by scripted tests.
```

---

## Tips & Tricks

### Tip 1: Customize Templates for Your Context
Templates are starting points - adapt to your project's needs. Add sections relevant to your domain, remove sections that don't apply.

### Tip 2: Version Control Your Test Artifacts
Store test plans, test reports, and bug templates in `docs/testing/` or similar. They're valuable historical references.

### Tip 3: Automate Repetitive Checks
Use `qa-checklist-template.md` to identify checks that can be automated. Add to CI/CD pipeline.

### Tip 4: Link Tests to Requirements
Maintain traceability matrix (requirement ID → test case IDs). Ensures all requirements tested.

### Tip 5: Review Metrics Weekly
Use `quality-metrics.md` dashboards to track trends. Weekly review helps catch quality issues early.

### Tip 6: Time-Box Exploratory Testing
Use 60-90 minute sessions with `exploratory-testing-charter-template.md`. Longer sessions lose focus.

### Tip 7: Bug Triage Regularly
Hold daily/weekly triage meetings using `bug-lifecycle.md` process. Prevents bug backlog buildup.

### Tip 8: Test Early and Often (Shift-Left)
Use `test-strategy-guide.md` → Shift-Left approach. Write tests during development, not after.

### Tip 9: Focus on Critical Paths First
Use `test-strategy-guide.md` → Risk-Based Testing. Test high-risk, high-value features first.

### Tip 10: Learn from Bugs
Use `bug-lifecycle.md` → Root Cause Analysis. Understand why bugs occurred, prevent similar issues.

---

## Resources

### assets/
Template files designed to be copied and customized:

- **test-plan-template.md** - Comprehensive test planning format (400+ lines)
- **test-case-template.md** - Detailed test case specification (200+ lines)
- **bug-report-template.md** - Complete bug reporting format (300+ lines)
- **qa-checklist-template.md** - 10-category QA validation checklist (400+ lines)
- **test-report-template.md** - Detailed test execution report (500+ lines)
- **release-validation-template.md** - Pre-release validation and smoke tests (400+ lines)
- **exploratory-testing-charter-template.md** - Session-based exploration format (400+ lines)

**Usage:** Copy template, fill in sections with your project details, customize as needed for your context.

### references/
Comprehensive reference guides loaded into context:

- **test-strategy-guide.md** - Testing levels, strategies, techniques, metrics, best practices (600+ lines)
- **test-case-design.md** - Black/white-box techniques, advanced patterns, test organization (700+ lines)
- **bug-lifecycle.md** - Bug states, severity/priority, triage, metrics, prevention, RCA (800+ lines)
- **qa-methodologies.md** - SDLC approaches, testing types, automation strategies (800+ lines)
- **quality-metrics.md** - Coverage, defect, execution, trend metrics, dashboards (700+ lines)

**Usage:** Read relevant sections to inform testing approach, decision-making, and process implementation.

---

**Total Content:** 6,100+ lines of production-ready templates and comprehensive methodologies.

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @qa-engineer - Primary consumer of this skill's templates and methodologies
- @developer - May reference test templates when writing code
- @devops-engineer - May use release validation and quality metrics
