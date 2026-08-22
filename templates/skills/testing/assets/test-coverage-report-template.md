# Test Coverage Report Template

## Overview

Test coverage reports provide insights into which parts of your codebase are tested and which are not. This template helps document coverage analysis, identify gaps, and create action plans for improving test coverage.

**Use this template when:**
- Auditing test coverage for a project or feature
- Identifying untested code paths
- Planning test improvement initiatives
- Reporting test quality to stakeholders
- Establishing coverage baselines and goals

---

## Coverage Report Template

```markdown
# Test Coverage Report: [Project/Feature Name]

**Date:** YYYY-MM-DD
**Author:** [Your Name]
**Scope:** [Full project | Specific feature | Module]
**Coverage Tool:** [Jest | pytest-cov | Istanbul | etc.]

---

## Executive Summary

**Overall Coverage:** XX%

- ✅ **Strengths:** [Brief summary of well-tested areas]
- ⚠️ **Gaps:** [Brief summary of major coverage gaps]
- 🎯 **Recommendation:** [High-level action item]

---

## Coverage Metrics

### By Layer

| Layer | Line Coverage | Branch Coverage | Function Coverage | Status |
|-------|--------------|----------------|------------------|---------|
| Frontend Components | XX% | XX% | XX% | 🟢 Good / 🟡 Fair / 🔴 Poor |
| API Endpoints | XX% | XX% | XX% | 🟢 Good / 🟡 Fair / 🔴 Poor |
| Business Logic | XX% | XX% | XX% | 🟢 Good / 🟡 Fair / 🔴 Poor |
| Data Access | XX% | XX% | XX% | 🟢 Good / 🟡 Fair / 🔴 Poor |
| Utilities | XX% | XX% | XX% | 🟢 Good / 🟡 Fair / 🔴 Poor |

**Legend:**
- 🟢 Good: ≥80%
- 🟡 Fair: 60-79%
- 🔴 Poor: <60%

### By Module/Feature

| Module | Files | Line Coverage | Status | Priority |
|--------|-------|--------------|--------|----------|
| Authentication | 8 | 92% | 🟢 | Low |
| User Management | 12 | 78% | 🟡 | Medium |
| Payments | 15 | 45% | 🔴 | High |
| Reporting | 6 | 88% | 🟢 | Low |
| Admin Panel | 10 | 34% | 🔴 | High |

---

## Detailed Analysis

### Well-Tested Areas ✅

**Authentication Module (92% coverage)**
- All login/logout flows covered
- Password reset covered with edge cases
- Token validation thoroughly tested
- **Strengths:**
  - Comprehensive E2E tests
  - Good edge case coverage
  - Clear test organization

**Reporting Module (88% coverage)**
- Report generation logic covered
- Export functionality tested
- **Strengths:**
  - Unit tests for calculations
  - Integration tests for data queries

### Coverage Gaps ⚠️

**Payments Module (45% coverage)**
- ❌ **Critical Gap:** Refund processing untested
- ❌ **Critical Gap:** Webhook handling untested
- ⚠️ **Medium Gap:** Payment retry logic partially tested
- **Impact:** High - Financial transactions risk
- **Recommendation:** Prioritize immediately

**Admin Panel (34% coverage)**
- ❌ **Critical Gap:** User deletion flow untested
- ❌ **Critical Gap:** Role management untested
- ⚠️ **Medium Gap:** Bulk operations partially tested
- **Impact:** Medium - Admin-only, lower frequency
- **Recommendation:** Address within sprint

**User Management (78% coverage)**
- ⚠️ **Medium Gap:** Profile update validation incomplete
- ⚠️ **Medium Gap:** Email verification edge cases missing
- **Impact:** Medium - Common user operations
- **Recommendation:** Improve incrementally

---

## Uncovered Code Paths

### Critical (Must Fix)

1. **File:** `src/payments/refund.ts`
   **Lines:** 45-78
   **Function:** `processRefund()`
   **Reason:** Complex business logic, financial impact
   **Suggested Test:** Integration test with mock payment gateway

2. **File:** `src/webhooks/payment-webhook.ts`
   **Lines:** 12-89
   **Function:** `handlePaymentWebhook()`
   **Reason:** External integration, error handling crucial
   **Suggested Test:** Unit tests for all webhook event types

3. **File:** `src/admin/user-deletion.ts`
   **Lines:** 34-102
   **Function:** `deleteUserAndRelatedData()`
   **Reason:** Data integrity risk, cascading deletes
   **Suggested Test:** Integration test with database verification

### High Priority

4. **File:** `src/auth/password-reset.ts`
   **Lines:** 56-67
   **Function:** `validateResetToken()`
   **Reason:** Incomplete edge case coverage (expired tokens)
   **Suggested Test:** Unit tests for edge cases

5. **File:** `src/users/profile-update.ts`
   **Lines:** 89-120
   **Function:** `validateProfileData()`
   **Reason:** Input validation gaps
   **Suggested Test:** Parameterized tests with invalid inputs

### Medium Priority

6. **File:** `src/reports/export.ts`
   **Lines:** 145-167
   **Function:** `exportToExcel()`
   **Reason:** Error handling for large datasets
   **Suggested Test:** Integration test with large dataset

---

## Test Type Breakdown

| Test Type | Count | Coverage Contribution | Status |
|-----------|-------|---------------------|---------|
| Unit Tests | 234 | ~60% | 🟡 Need more edge cases |
| Integration Tests | 89 | ~25% | 🟢 Good API coverage |
| E2E Tests | 42 | ~10% | 🟡 Need critical path coverage |
| Contract Tests | 12 | ~5% | 🔴 Minimal, needs expansion |

---

## Coverage Trends

| Date | Overall | Frontend | Backend | Change |
|------|---------|----------|---------|---------|
| 2025-01-15 | 68% | 72% | 64% | - |
| 2025-02-01 | 71% | 75% | 67% | +3% ⬆️ |
| 2025-02-15 | 73% | 78% | 68% | +2% ⬆️ |
| 2025-03-01 | 75% | 80% | 70% | +2% ⬆️ |

**Trend:** 📈 Improving (+7% over 6 weeks)

---

## Action Plan

### Immediate (This Sprint)

- [ ] **Priority 1:** Add integration tests for payment refund flow
  **Owner:** [Name]
  **Estimated Effort:** 8 hours
  **Target Coverage:** +15% for Payments module

- [ ] **Priority 2:** Add unit tests for webhook handling
  **Owner:** [Name]
  **Estimated Effort:** 6 hours
  **Target Coverage:** +10% for Payments module

- [ ] **Priority 3:** Add integration test for user deletion
  **Owner:** [Name]
  **Estimated Effort:** 4 hours
  **Target Coverage:** +20% for Admin module

### Short-Term (Next 2 Sprints)

- [ ] Add edge case tests for password reset (expired tokens, invalid tokens)
- [ ] Add validation tests for profile updates
- [ ] Add E2E tests for critical admin workflows
- [ ] Add contract tests for all external API integrations

### Long-Term (Next Quarter)

- [ ] Establish coverage floor: No file below 70%
- [ ] Add mutation testing to validate test quality
- [ ] Implement coverage gates in CI/CD (block PRs <80% coverage)
- [ ] Create coverage dashboard for team visibility

---

## Coverage Goals

| Timeframe | Target | Current | Gap |
|-----------|--------|---------|-----|
| End of Sprint | 78% | 75% | +3% |
| End of Quarter | 85% | 75% | +10% |
| End of Year | 90% | 75% | +15% |

**Key Milestones:**
- ✅ Achieve 80% by end of Q2
- ✅ All critical modules ≥85% by end of Q3
- ✅ Establish 90% coverage floor by EOY

---

## Quality Metrics Beyond Coverage

### Test Reliability
- **Flaky Tests:** 3 (1.2% of suite) - Within acceptable range (🟢)
- **Slow Tests:** 12 tests >10s - Needs optimization (🟡)

### Test Maintainability
- **Test-to-Code Ratio:** 1.8:1 (good balance) 🟢
- **Average Test Complexity:** Low (mostly simple AAA structure) 🟢
- **Test Duplication:** Minimal (shared fixtures/factories) 🟢

### Test Effectiveness
- **Bugs Caught by Tests (Last Month):** 23 🟢
- **Production Bugs (Last Month):** 4 (15% escape rate) 🟡
- **Regression Detection Rate:** 92% 🟢

---

## Appendix

### How Coverage Was Measured

**Tools:**
- Frontend: Jest with `--coverage` flag
- Backend: pytest with pytest-cov
- Combined: Istanbul for merged report

**Commands:**
```bash
# Frontend
npm test -- --coverage

# Backend
pytest --cov=src --cov-report=html

# View report
open coverage/index.html
```

### Coverage Thresholds (CI/CD)

```json
{
  "coverageThreshold": {
    "global": {
      "branches": 70,
      "functions": 75,
      "lines": 75,
      "statements": 75
    },
    "src/payments/**/*.ts": {
      "branches": 85,
      "functions": 90,
      "lines": 90,
      "statements": 90
    }
  }
}
```

### Exclusions

The following are intentionally excluded from coverage:
- `src/generated/**` - Auto-generated code
- `src/**/*.d.ts` - TypeScript definitions
- `src/scripts/**` - One-time migration scripts
- `src/config/**` - Configuration files

---

## Sign-Off

**Prepared by:** [Your Name]
**Reviewed by:** [Tech Lead]
**Approved by:** [Engineering Manager]
**Date:** YYYY-MM-DD

---

## Notes

- Coverage is a metric, not a goal. Focus on testing critical paths and business logic.
- 100% coverage does not guarantee bug-free code. Prioritize test quality over quantity.
- Use coverage to identify gaps, not as a measure of team performance.
```

---

## Quick Coverage Analysis Checklist

When analyzing coverage reports, check:

- [ ] **Critical paths covered?** (Auth, payments, data integrity)
- [ ] **Error handling tested?** (Exceptions, edge cases, timeouts)
- [ ] **Business logic covered?** (Calculations, validations, workflows)
- [ ] **Untested files identified?** (Files with 0% coverage)
- [ ] **Branch coverage adequate?** (All if/else paths tested)
- [ ] **Integration points covered?** (APIs, database, external services)
- [ ] **Coverage trends tracked?** (Improving or declining?)
- [ ] **Action plan created?** (Specific tasks to improve coverage)

---

## Common Coverage Anti-Patterns

### ❌ Coverage for Coverage's Sake

```javascript
// BAD - Test that adds no value, just coverage
it('should instantiate class', () => {
  const instance = new MyClass();
  expect(instance).toBeDefined(); // No real assertion
});
```

### ❌ Ignoring Branch Coverage

```python
# Function with 100% line coverage but poor branch coverage
def process_payment(amount, method):
    if amount > 0:  # Positive branch tested
        if method == "credit":  # Only credit tested
            charge_credit(amount)
        elif method == "debit":  # Debit NOT tested
            charge_debit(amount)
        else:  # Default NOT tested
            raise ValueError("Invalid method")
    return True  # This line is always executed (covered)

# Test only covers one branch
def test_process_payment():
    assert process_payment(100, "credit") is True
    # 100% line coverage, but debit and error branches untested!
```

### ❌ Testing Implementation, Not Behavior

```javascript
// BAD - Brittle test focused on implementation
it('should call private method', () => {
  const spy = jest.spyOn(service, '_internalHelper');
  service.publicMethod();
  expect(spy).toHaveBeenCalled(); // Testing implementation detail
});

// GOOD - Test observable behavior
it('should return correct result', () => {
  const result = service.publicMethod();
  expect(result).toBe(expectedValue); // Testing outcome
});
```

---

## Coverage Tools Reference

| Language | Tool | Command | Report Format |
|----------|------|---------|---------------|
| JavaScript | Jest | `jest --coverage` | HTML, JSON, LCOV |
| JavaScript | Istanbul | `nyc npm test` | HTML, JSON, LCOV |
| Python | pytest-cov | `pytest --cov` | Terminal, HTML, XML |
| Python | Coverage.py | `coverage run -m pytest` | HTML, XML, JSON |
| Java | JaCoCo | Maven/Gradle plugin | HTML, XML, CSV |
| Go | go test | `go test -cover` | Terminal, HTML |
| Ruby | SimpleCov | Automatic with RSpec | HTML |

---

## Related Templates

- **unit-test-template.md** - Writing tests to improve coverage
- **integration-test-template.md** - Integration tests for coverage
- **testing-strategies.md** - Choosing what to test for optimal coverage
- **test-maintenance.md** - Maintaining test suites as coverage grows
