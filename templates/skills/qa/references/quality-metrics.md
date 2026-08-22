# Quality Metrics Guide

## Overview

This guide provides comprehensive metrics for measuring and tracking software quality, test effectiveness, and QA team performance. Use these metrics to make data-driven decisions about quality improvements.

---

## Test Coverage Metrics

### 1. Code Coverage

**Definition**: Percentage of code executed by automated tests.

**Formula**: `(Lines Executed / Total Lines) × 100`

**Types**:

- **Line Coverage**: % of code lines executed
- **Branch Coverage**: % of conditional branches executed
- **Function Coverage**: % of functions called
- **Statement Coverage**: % of statements executed

**Industry Targets**:
- **Critical Code**: >95% (payment, auth, data handling)
- **Core Features**: >90%
- **Overall Codebase**: >80%
- **Utilities/Helpers**: >70%

**Example**:
```python
# Module with 100 lines
# Tests execute 85 lines
Code Coverage = (85 / 100) × 100 = 85%
```

**Tools**:
- **Python**: pytest-cov, coverage.py
- **JavaScript**: Jest (--coverage), Istanbul, NYC
- **General**: SonarQube, Codecov, Coveralls

**Interpretation**:
- ✅ **>90%**: Excellent coverage
- ⚠️ **80-90%**: Good, room for improvement
- ❌ **<80%**: Insufficient coverage, high risk

**Caution**: High coverage ≠ good tests. Focus on quality over quantity.

---

### 2. Test Case Coverage

**Definition**: Percentage of requirements covered by test cases.

**Formula**: `(Requirements with Tests / Total Requirements) × 100`

**Target**: 100% for critical requirements, >95% overall

**Traceability Matrix**:

| Requirement ID | Test Case IDs | Status |
|----------------|---------------|--------|
| REQ-001 | TC-001, TC-002, TC-003 | ✅ Covered |
| REQ-002 | TC-004 | ✅ Covered |
| REQ-003 | — | ❌ Not Covered |

**Coverage**: 2/3 = 66.7%

---

### 3. Requirements Coverage

**Definition**: Percentage of acceptance criteria tested.

**Formula**: `(Tested Criteria / Total Criteria) × 100`

**Example**:
```
User Story: User Login
Acceptance Criteria (5):
- ✅ Valid credentials → Dashboard
- ✅ Invalid credentials → Error
- ✅ Locked account → Error
- ✅ Forgot password → Reset flow
- ❌ Remember me → Stay logged in

Coverage = 4/5 = 80%
```

---

## Defect Metrics

### 1. Defect Density

**Definition**: Number of defects per unit of code.

**Formula**: `Defects / 1000 Lines of Code (KLOC)`

**Industry Benchmarks**:
- **Excellent**: <0.5 defects/KLOC
- **Good**: 0.5-1.0 defects/KLOC
- **Average**: 1.0-2.0 defects/KLOC
- **Poor**: >2.0 defects/KLOC

**Example**:
```
Codebase: 50,000 lines
Defects Found: 30
Defect Density = (30 / 50) = 0.6 defects/KLOC (Good)
```

**Use**: Compare quality across modules, track improvement over time.

---

### 2. Defect Detection Rate (DDR)

**Definition**: Percentage of defects found before production.

**Formula**: `(Defects Found Pre-Production / Total Defects) × 100`

**Target**: >90%

**Example**:
```
Defects Found in Testing: 45
Defects Found in Production: 5
Total Defects: 50
DDR = (45 / 50) × 100 = 90%
```

**Interpretation**:
- ✅ **>90%**: Excellent testing effectiveness
- ⚠️ **80-90%**: Good, some improvements needed
- ❌ **<80%**: Poor testing, too many escaping to production

---

### 3. Defect Escape Rate (DER)

**Definition**: Percentage of defects that escape to production.

**Formula**: `(Production Defects / Total Defects) × 100`

**Target**: <10%

**Example**:
```
Defects Found in Production: 5
Total Defects: 50
DER = (5 / 50) × 100 = 10% (Acceptable)
```

**Inverse of Detection Rate**: DER = 100% - DDR

---

### 4. Defect Removal Efficiency (DRE)

**Definition**: Effectiveness of defect removal at each phase.

**Formula**: `(Defects Found in Phase / Total Defects Injected) × 100`

**Example**:
```
Phase         | Defects Found | DRE
--------------|---------------|-----
Requirements  | 5             | 10%
Design        | 10            | 20%
Code Review   | 15            | 30%
Unit Testing  | 10            | 20%
QA Testing    | 8             | 16%
Production    | 2             | 4%
Total         | 50            | 100%

Cumulative DRE before Production = 96%
```

**Target**: >95% cumulative DRE before production

---

### 5. Defect Aging

**Definition**: Time defects remain open.

**Metrics**:
- **Mean Age**: Average days open
- **Median Age**: Middle value
- **Age Distribution**: % by age bucket

**Age Buckets**:
- 0-7 days: Fresh
- 8-30 days: Moderate
- 31-90 days: Stale
- >90 days: Ancient

**Target**: <10% defects older than 30 days

**Example**:
```
Total Open Bugs: 50
- 0-7 days: 30 (60%)
- 8-30 days: 15 (30%)
- 31-90 days: 4 (8%)
- >90 days: 1 (2%)

Mean Age: 12 days (Good)
Ancient Bugs: 2% (Excellent)
```

---

### 6. Defect Injection Rate

**Definition**: Defects introduced per unit of work.

**Formula**: `Defects Injected / Features Delivered`

**Example**:
```
Features Delivered: 20
Defects Found: 40
Injection Rate = 40 / 20 = 2 defects per feature
```

**Trend**: Track over time to see if quality improving.

---

## Test Execution Metrics

### 1. Test Pass Rate

**Definition**: Percentage of tests that pass.

**Formula**: `(Passing Tests / Total Tests) × 100`

**Target**: >95%

**Example**:
```
Total Tests: 500
Passing: 485
Failing: 10
Skipped: 5
Pass Rate = (485 / 500) × 100 = 97%
```

**Interpretation**:
- ✅ **>95%**: Healthy test suite
- ⚠️ **90-95%**: Some issues, investigate failures
- ❌ **<90%**: Significant problems, fix immediately

---

### 2. Test Execution Time

**Definition**: Time to run full test suite.

**Targets**:
- **Unit Tests**: <10 seconds
- **Integration Tests**: <5 minutes
- **E2E Tests**: <30 minutes
- **Full Suite**: <1 hour

**Example**:
```
Unit Tests: 8 seconds (500 tests)
Integration: 3 minutes (100 tests)
E2E: 25 minutes (50 tests)
Total: 28 minutes ✅
```

**Use**: Track and optimize slow tests, parallelize execution.

---

### 3. Test Flakiness Rate

**Definition**: Percentage of tests that intermittently fail.

**Formula**: `(Flaky Tests / Total Tests) × 100`

**Target**: <2%

**Example**:
```
Total Tests: 500
Flaky Tests (fail intermittently): 8
Flakiness Rate = (8 / 500) × 100 = 1.6% ✅
```

**Impact**: Flaky tests erode confidence, must be fixed immediately.

---

### 4. Test Automation Coverage

**Definition**: Percentage of test cases automated.

**Formula**: `(Automated Tests / Total Tests) × 100`

**Targets**:
- **Regression Tests**: >90% automated
- **Smoke Tests**: 100% automated
- **Integration Tests**: >80% automated
- **E2E Tests**: >50% automated

**Example**:
```
Total Test Cases: 1000
Automated: 750
Manual: 250
Automation Coverage = (750 / 1000) × 100 = 75%
```

---

## Time-Based Metrics

### 1. Mean Time to Detect (MTTD)

**Definition**: Average time from defect injection to detection.

**Formula**: `Sum of (Detection Time - Injection Time) / Number of Defects`

**Target**: <24 hours (shift-left approach)

**Example**:
```
Bug #1: Injected Mon 9am, Detected Mon 11am = 2 hours
Bug #2: Injected Mon 9am, Detected Tue 9am = 24 hours
Bug #3: Injected Mon 9am, Detected Mon 3pm = 6 hours

MTTD = (2 + 24 + 6) / 3 = 10.7 hours ✅
```

---

### 2. Mean Time to Resolve (MTTR)

**Definition**: Average time from defect detection to resolution (deployed to production).

**Formula**: `Sum of Resolution Times / Number of Defects`

**Targets by Severity**:
- **Critical**: <24 hours
- **High**: <3 days
- **Medium**: <2 weeks
- **Low**: <1 month

**Example**:
```
Bug #1 (Critical): 18 hours
Bug #2 (High): 2 days
Bug #3 (Medium): 10 days

Average MTTR = (18hr + 48hr + 240hr) / 3 = 102 hours ≈ 4.25 days
```

---

### 3. Test Cycle Time

**Definition**: Time from test planning to test completion.

**Formula**: `Test End Date - Test Start Date`

**Target**: Depends on release cadence
- **Agile Sprint**: 1-2 weeks
- **Continuous Delivery**: <1 day
- **Waterfall Release**: 2-4 weeks

---

## Quality Trend Metrics

### 1. Bug Burn-Down Rate

**Definition**: Rate at which bugs are being closed.

**Formula**: `(Bugs Closed in Sprint / Bugs Opened in Sprint)`

**Target**: ≥1.0 (closing faster than opening)

**Example**:
```
Week 1: Opened 10, Closed 12 → Rate = 1.2 ✅
Week 2: Opened 8, Closed 10 → Rate = 1.25 ✅
Week 3: Opened 15, Closed 10 → Rate = 0.67 ❌
```

**Trend**: Should be ≥1.0 consistently, especially near release.

---

### 2. Test Case Effectiveness

**Definition**: Percentage of tests that have found at least one defect.

**Formula**: `(Tests That Found Bugs / Total Tests) × 100`

**Target**: >30% (too high may indicate poor code quality)

**Example**:
```
Total Tests: 500
Tests That Found Bugs: 175
Effectiveness = (175 / 500) × 100 = 35%
```

---

### 3. Defect Trend by Severity

**Metric**: Track defect counts over time by severity level.

**Example Chart**:
```
Severity    | Week 1 | Week 2 | Week 3 | Trend
------------|--------|--------|--------|-------
Critical    | 2      | 1      | 0      | ✅ Down
High        | 8      | 5      | 3      | ✅ Down
Medium      | 15     | 12     | 10     | ✅ Down
Low         | 20     | 18     | 22     | ⚠️ Up
```

**Goal**: Decreasing trend, especially for high-severity defects.

---

## Team Performance Metrics

### 1. Test Productivity

**Definition**: Test cases created per tester per day.

**Formula**: `Test Cases Created / (Testers × Days)`

**Benchmark**: 5-10 test cases/tester/day (varies by complexity)

**Example**:
```
Test Cases Created: 100
Testers: 2
Days: 10
Productivity = 100 / (2 × 10) = 5 test cases/tester/day
```

---

### 2. Defect Detection Efficiency

**Definition**: Defects found per tester per day.

**Formula**: `Defects Found / (Testers × Days)`

**Benchmark**: 2-5 defects/tester/day

**Example**:
```
Defects Found: 40
Testers: 2
Days: 10
Efficiency = 40 / (2 × 10) = 2 defects/tester/day
```

---

### 3. Test Execution Rate

**Definition**: Tests executed per tester per day.

**Formula**: `Tests Executed / (Testers × Days)`

**Benchmark**: 30-50 tests/tester/day (manual), 500+ (automated)

---

## Advanced Metrics

### 1. Weighted Defect Density

**Definition**: Defect density weighted by severity.

**Formula**: `(Σ Defects × Weight) / KLOC`

**Weights**:
- Critical: 10
- High: 5
- Medium: 2
- Low: 1

**Example**:
```
Codebase: 50 KLOC
Defects:
- Critical: 2 × 10 = 20
- High: 5 × 5 = 25
- Medium: 10 × 2 = 20
- Low: 20 × 1 = 20
Total Weighted: 85

Weighted Defect Density = 85 / 50 = 1.7 weighted defects/KLOC
```

---

### 2. Test ROI (Return on Investment)

**Definition**: Value of defects prevented vs. cost of testing.

**Formula**: `(Cost of Production Bugs Prevented / Testing Cost) × 100`

**Example**:
```
Testing Cost: $50,000
Production Bugs Prevented: 50
Average Cost per Production Bug: $2,000
Value Prevented: 50 × $2,000 = $100,000

ROI = ($100,000 / $50,000) × 100 = 200% ROI
```

---

### 3. Test Debt

**Definition**: Test cases that should exist but don't.

**Metric**: Count of untested requirements or features.

**Example**:
```
Total Features: 100
Features with Tests: 85
Test Debt = 100 - 85 = 15 untested features
```

---

## Dashboards and Reporting

### Executive Dashboard

**Metrics to Include**:
1. **Quality Score**: Overall health (composite metric)
2. **Defect Escape Rate**: <10%
3. **Test Pass Rate**: >95%
4. **Code Coverage**: >80%
5. **Critical Bugs Open**: Trend over time

**Frequency**: Weekly

---

### QA Team Dashboard

**Metrics to Include**:
1. Test execution progress
2. Defects found by severity
3. Test automation coverage
4. Flaky test count
5. MTTR by severity
6. Bug burn-down chart

**Frequency**: Daily

---

### Developer Dashboard

**Metrics to Include**:
1. Code coverage by module
2. Unit test pass rate
3. Static analysis violations
4. Defects assigned to me
5. Average fix time

**Frequency**: Real-time (CI/CD)

---

## Metric Anti-Patterns

### 1. Vanity Metrics

**Problem**: Metrics that look good but don't drive improvement.

**Examples**:
- ❌ Total number of tests (quantity over quality)
- ❌ 100% code coverage (doesn't mean good tests)
- ❌ Zero defects (hiding problems, not reporting)

**Solution**: Focus on actionable metrics (defect escape rate, MTTR, trend data).

---

### 2. Metric Gaming

**Problem**: Optimizing for the metric, not quality.

**Examples**:
- Writing tests that don't assert anything (inflate coverage)
- Marking bugs as "won't fix" to improve closure rate
- Running only fast tests in CI to meet time targets

**Solution**: Multiple metrics, code reviews, quality audits.

---

### 3. Lagging Indicators Only

**Problem**: Metrics tell you what happened, not what will happen.

**Examples**:
- Defects found (lagging)
- Test pass rate after release (lagging)

**Solution**: Balance with leading indicators:
- Code review coverage (leading)
- Test-first adoption (leading)
- Automated test growth (leading)

---

## Metrics Selection Guide

### For Waterfall Projects

**Key Metrics**:
1. Test case coverage
2. Defect density
3. Defect removal efficiency
4. Test execution progress

---

### For Agile Projects

**Key Metrics**:
1. Sprint velocity (tests added)
2. Bug burn-down rate
3. Test automation coverage
4. Defect escape rate

---

### For DevOps/Continuous Delivery

**Key Metrics**:
1. Build success rate
2. Test execution time
3. MTTD (Mean Time to Detect)
4. Deployment frequency
5. Lead time for changes

---

## Summary

**Essential Metrics** (track these at minimum):

1. **Code Coverage**: >80%
2. **Defect Escape Rate**: <10%
3. **Test Pass Rate**: >95%
4. **MTTR**: By severity (Critical <24hr, High <3d, Medium <2w)
5. **Test Automation Coverage**: >70%

**Key Principles**:

- **Actionable**: Metrics should drive improvement
- **Balanced**: Leading + lagging indicators
- **Trend-Focused**: Track over time, not just snapshots
- **Context-Aware**: Compare to your baselines, not just industry
- **Avoid Gaming**: Multiple metrics, qualitative reviews
- **Dashboard**: Visualize for stakeholders

**Recommended Reading**:
- "How to Measure Anything" by Douglas Hubbard
- "Accelerate" by Nicole Forsgren, Jez Humble, Gene Kim
- "Software Engineering Metrics" by Norman Fenton and James Bieman
