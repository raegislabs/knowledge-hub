---
name: testing-patterns
description: Comprehensive testing templates, patterns, and methodologies for writing, organizing, and maintaining test suites. Use when writing tests, reviewing test quality, organizing test suites, or establishing testing best practices. Provides templates for unit, integration, E2E tests, test data management, coverage reporting, and reference guides for testing strategies, naming conventions, mocking, test maintenance, and TDD workflows.
---

# Testing Patterns

## Overview

This skill provides production-ready testing templates, patterns, and comprehensive methodologies for creating and maintaining high-quality test suites. It enhances the @tests-steward agent by providing standardized formats, best practices, and systematic approaches to testing across all layers (unit, integration, E2E).

**When to use this skill:**
- Writing new tests (unit, integration, E2E)
- Organizing and structuring test suites
- Creating test fixtures and test data
- Reviewing and improving test quality
- Analyzing test coverage and identifying gaps
- Establishing testing conventions and standards
- Implementing TDD workflows
- Maintaining and refactoring test suites

**Skill Structure:** Template and Reference-based with reusable templates and comprehensive best practices.

---

## Available Templates

This skill provides 5 production-ready templates in `assets/`:

### 1. Unit Test Template
**File:** `assets/unit-test-template.md`

Complete unit testing guide with Arrange-Act-Assert pattern including:
- Basic unit test structure (Python pytest, JavaScript Jest/Vitest)
- Common testing patterns (parameterized tests, error conditions, mocking, async)
- Class method testing
- React component testing
- Best practices checklist (independence, determinism, speed, naming)
- Common assertions (Python pytest, JavaScript Jest/Vitest)
- Testing anti-patterns to avoid
- Framework-specific quick reference

**Use when:** Testing individual functions, methods, classes, or components in isolation.

**Example usage:**
```python
def test_calculate_tax_with_valid_rate_returns_correct_amount():
    """Test calculate_tax computes tax correctly."""
    # Arrange
    amount = 100
    rate = 0.10

    # Act
    result = calculate_tax(amount, rate)

    # Assert
    assert result == 10.0
```

### 2. Integration Test Template
**File:** `assets/integration-test-template.md`

API and database integration testing guide with:
- Basic API integration test structure (FastAPI, Express)
- Database integration tests (SQLAlchemy, Prisma)
- API endpoint testing patterns (CRUD operations, request validation, response formats)
- Authentication & authorization tests
- External service integration (with mocks)
- Multi-step workflow tests
- Database testing strategies (isolation, transactions, fixtures)
- Docker-based integration testing
- Integration testing anti-patterns

**Use when:** Testing interactions between components, API endpoints with databases, service-to-service communication.

**Example usage:**
```python
def test_post_users_with_valid_data_creates_user_and_returns_201(client, db_session):
    """Test POST /users creates user in database."""
    # Arrange
    user_data = {"email": "alice@example.com", "name": "Alice"}

    # Act
    response = client.post("/users", json=user_data)

    # Assert
    assert response.status_code == 201
    assert response.json()["email"] == user_data["email"]

    # Verify database state
    user = db_session.query(User).filter_by(email=user_data["email"]).first()
    assert user is not None
```

### 3. E2E Test Template
**File:** `assets/e2e-test-template.md`

End-to-end testing guide with browser automation:
- Basic E2E test structure (Playwright, Cypress)
- Page Object Model pattern
- Common E2E patterns (form submission, multi-step journeys, navigation, authentication)
- Dynamic content and loading states
- Modal and dialog interactions
- Test data management and fixtures
- Visual testing and accessibility testing
- Network interception and API mocking
- E2E testing best practices (data attributes, proper waits, test independence)
- Configuration examples

**Use when:** Testing complete user workflows from UI through entire application stack.

**Example usage:**
```javascript
test('user can complete checkout process', async ({ page }) => {
  // Step 1: Add to cart
  await page.goto('/products/laptop');
  await page.click('[data-testid="add-to-cart"]');

  // Step 2: Proceed to checkout
  await page.click('[data-testid="checkout"]');

  // Step 3: Fill payment info
  await page.fill('[name="card-number"]', '4111111111111111');
  await page.click('[data-testid="place-order"]');

  // Step 4: Verify confirmation
  await expect(page).toHaveURL(/order-confirmation/);
});
```

### 4. Test Data Template
**File:** `assets/test-data-template.md`

Test fixture, factory, and builder patterns:
- Fixture patterns (simple static data, database fixtures, persisted data)
- Factory patterns (factory functions, factory classes with sequences, ORM factories)
- Builder pattern for complex objects (fluent API)
- Test data files (JSON, CSV, SQL seed files)
- Faker for random realistic data
- Common test data patterns (valid/invalid sets, edge cases, relationships)
- Test data best practices (descriptive names, minimal data, obvious intent)
- Quick reference table

**Use when:** Creating reusable test data, managing fixtures, building complex test objects.

**Example usage:**
```python
# Factory function with overrides
def create_user(**overrides):
    """Factory function to create user with defaults."""
    defaults = {
        "email": "default@example.com",
        "name": "Default User",
        "role": "user",
        "active": True
    }
    return {**defaults, **overrides}

# Usage
user = create_user(email="custom@example.com", role="admin")
```

### 5. Test Coverage Report Template
**File:** `assets/test-coverage-report-template.md`

Comprehensive coverage analysis and reporting template:
- Executive summary format
- Coverage metrics (by layer, by module/feature)
- Detailed analysis (well-tested areas, coverage gaps)
- Uncovered code paths (critical, high priority, medium priority)
- Test type breakdown
- Coverage trends over time
- Action plan (immediate, short-term, long-term)
- Coverage goals and milestones
- Quality metrics beyond coverage
- Quick coverage analysis checklist
- Common coverage anti-patterns
- Coverage tools reference

**Use when:** Auditing test coverage, identifying gaps, planning test improvement initiatives, reporting to stakeholders.

**Example usage:**
```markdown
# Test Coverage Report: Payment Module

**Overall Coverage:** 75%

## Coverage Gaps ⚠️

**Payments Module (45% coverage)**
- ❌ **Critical Gap:** Refund processing untested
- ❌ **Critical Gap:** Webhook handling untested
- **Impact:** High - Financial transactions risk
- **Recommendation:** Prioritize immediately
```

---

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. Testing Strategies Guide
**File:** `references/testing-strategies.md`

Systematic approach for choosing the right test type:

**Key Topics:**
- **The Test Pyramid** - Ideal distribution (70% unit, 20% integration, 10% E2E)
- **When to Use Each Test Type** - Clear decision criteria for unit, integration, and E2E tests
- **Decision Tree** - Flow chart for selecting appropriate test type
- **Test Coverage Strategy** - How to structure testing at each level
- **Testing Different Application Layers** - Frontend, backend, database testing approaches
- **Special Testing Scenarios** - Error conditions, external services, authentication
- **Test Optimization** - Isolation, performance, flaky test management
- **Testing Checklist by Feature** - What to test when adding new features
- **Anti-Patterns** - Common mistakes and solutions

**Use when:** Deciding which test type to use, balancing test pyramid, optimizing test strategy.

### 2. Test Naming Conventions Guide
**File:** `references/test-naming-conventions.md`

Clear, descriptive naming patterns for tests:

**Key Topics:**
- **Core Naming Principle** - `test_<unit>_<behavior>_<expected_outcome>`
- **Naming Patterns by Test Type** - Unit, integration, E2E naming conventions
- **Framework-Specific Conventions** - pytest, Jest/Vitest, React Testing Library
- **Common Scenario Patterns** - Error conditions, edge cases, boundary values, state changes, async
- **BDD-Style Naming** - Given-When-Then format (long and short form)
- **Test Naming Anti-Patterns** - Vague names, implementation details, ambiguous outcomes
- **Naming Checklist** - 8 criteria for good test names
- **Test Organization Patterns** - Group by feature, group by scenario
- **File Naming Conventions** - Directory structure and file naming

**Use when:** Writing new tests, refactoring test names, establishing team conventions.

### 3. Mocking Patterns Guide
**File:** `references/mocking-patterns.md`

When and how to use test doubles effectively:

**Key Topics:**
- **Types of Test Doubles** - Mock, stub, spy, fake, dummy (with examples)
- **When to Mock** - External services, database calls, slow operations, non-deterministic behavior
- **When NOT to Mock** - System under test, value objects, simple logic
- **Mocking Patterns** - Dependency injection, partial mocking, return values, exceptions, async
- **Mocking External Services** - HTTP requests, database, file system
- **Mock Assertions** - Python unittest.mock and JavaScript Vitest/Jest
- **Mocking Anti-Patterns** - Over-mocking, mocking internals, not resetting mocks
- **Quick Reference Table** - Test double comparison

**Use when:** Deciding what to mock, writing tests with dependencies, isolating units for testing.

### 4. Test Maintenance Guide
**File:** `references/test-maintenance.md`

Keeping test suites fast, reliable, and valuable:

**Key Topics:**
- **Common Test Smells** - Flaky tests, slow tests, brittle tests, unclear failures, duplication
- **Test Refactoring Patterns** - Extract helpers, page objects, consolidate assertions
- **Managing Test Data** - Factories, seed data files
- **Handling Test Database** - Transaction rollback, cleanup, isolation
- **Dealing with External Dependencies** - Mocking strategies, test doubles
- **Test Organization Strategies** - Grouping, directory structure
- **CI/CD Integration** - Fail fast, parallel execution
- **Test Metrics to Track** - Coverage trends, execution time, flaky test rate
- **Refactoring Checklist** - 10-item checklist for test refactoring
- **Common Maintenance Tasks** - Weekly, monthly, quarterly tasks

**Use when:** Refactoring tests, fixing flaky tests, improving test performance, organizing test suites.

### 5. TDD Workflow Guide
**File:** `references/tdd-workflow.md`

Test-Driven Development process and best practices:

**Key Topics:**
- **Red-Green-Refactor Cycle** - The core TDD loop with examples
- **TDD Workflow Steps** - Full cycle example with multiple iterations
- **TDD Best Practices** - Start simple, one test at a time, test behavior, refactor, fast tests
- **TDD Patterns** - Fake it till you make it, triangulation, obvious implementation
- **TDD for Different Scenarios** - API development, frontend components, legacy code
- **Common TDD Mistakes** - Too much code before testing, not running tests frequently, skipping refactoring
- **TDD Workflow Checklist** - Step-by-step checklist for each feature
- **Quick Reference** - Phase goals, time estimates, focus areas

**Use when:** Implementing TDD, teaching TDD, test-driving new features.

---

## Usage Patterns

### Pattern 1: Writing Unit Tests

**Scenario:** Need to write unit tests for new business logic.

**Process:**
1. Read `testing-strategies.md` → When to Use Unit Tests section
2. Read `tdd-workflow.md` → Red-Green-Refactor cycle (if using TDD)
3. Use `unit-test-template.md` → Basic Unit Test (AAA pattern)
4. Use `test-naming-conventions.md` → Unit test naming patterns
5. Use `test-data-template.md` → Create fixtures/factories if needed
6. Use `mocking-patterns.md` → Mock external dependencies

**Time:** 30 minutes - 2 hours depending on complexity

### Pattern 2: Writing Integration Tests

**Scenario:** Need to test API endpoints with database.

**Process:**
1. Read `testing-strategies.md` → When to Use Integration Tests section
2. Use `integration-test-template.md` → Basic API Integration Test
3. Use `test-data-template.md` → Database fixtures
4. Use `test-naming-conventions.md` → Integration test naming
5. Use `mocking-patterns.md` → Mock external services (not database)

**Time:** 1-3 hours

### Pattern 3: Writing E2E Tests

**Scenario:** Need to test critical user journey.

**Process:**
1. Read `testing-strategies.md` → When to Use E2E Tests section
2. Use `e2e-test-template.md` → Page Object Model pattern
3. Use `test-data-template.md` → Seeding test data
4. Use `test-naming-conventions.md` → E2E test naming
5. Read `test-maintenance.md` → E2E best practices (avoid flakiness)

**Time:** 2-4 hours

### Pattern 4: Improving Test Coverage

**Scenario:** Coverage audit and gap identification.

**Process:**
1. Use `test-coverage-report-template.md` → Generate coverage report
2. Read `testing-strategies.md` → Test pyramid and coverage strategy
3. Identify gaps (critical paths, error handling, edge cases)
4. Use appropriate template (`unit-test-template.md`, `integration-test-template.md`, `e2e-test-template.md`)
5. Read `test-maintenance.md` → Avoid common pitfalls

**Time:** 4-8 hours for comprehensive audit

### Pattern 5: Refactoring Test Suite

**Scenario:** Test suite is slow, flaky, or hard to maintain.

**Process:**
1. Read `test-maintenance.md` → Common Test Smells section
2. Identify issues (flaky tests, slow tests, duplication)
3. Read `test-maintenance.md` → Test Refactoring Patterns
4. Use `test-data-template.md` → Consolidate fixtures/factories
5. Read `testing-strategies.md` → Optimize test pyramid
6. Use `test-naming-conventions.md` → Improve test names

**Time:** 1-3 days depending on suite size

### Pattern 6: Implementing TDD

**Scenario:** Want to use TDD for new feature development.

**Process:**
1. Read `tdd-workflow.md` → Red-Green-Refactor cycle
2. Use `unit-test-template.md` → Write first failing test
3. Use `test-naming-conventions.md` → Name test clearly
4. Follow TDD cycle: RED → GREEN → REFACTOR
5. Use `testing-strategies.md` → Verify test pyramid balance

**Time:** Ongoing (5-15 min per TDD cycle)

### Pattern 7: Reviewing Test Quality

**Scenario:** Code review focusing on test quality.

**Process:**
1. Check `test-naming-conventions.md` → Are names descriptive?
2. Check `testing-strategies.md` → Right test type used?
3. Check `mocking-patterns.md` → Appropriate mocking?
4. Check `test-maintenance.md` → Any test smells?
5. Check `unit-test-template.md` → Follows AAA pattern?

**Time:** 15-30 minutes per PR

---

## Integration with @tests-steward

This skill is designed to enhance the @tests-steward agent:

**Agent's Role:**
- Audits test coverage for features
- Implements and refactors tests
- Maintains test fixtures and mocks
- Identifies and resolves flaky tests
- Updates test documentation

**Skill's Role:**
- Provides standardized templates for consistency
- Offers methodologies for systematic testing
- Ensures best practices are followed
- Provides reference guides for decision-making

**Workflow:**
```markdown
User: "@tests-steward, add integration tests for the new payments API"

Agent:
1. Loads testing-patterns skill
2. Reads testing-strategies.md → Confirms integration tests appropriate
3. Reads integration-test-template.md → API endpoint testing patterns
4. Reads test-naming-conventions.md → Integration test naming
5. Reads mocking-patterns.md → Mock payment gateway
6. Implements tests using templates and best practices
7. Uses test-coverage-report-template.md to document coverage improvement
```

---

## Best Practices

### 1. Follow the Test Pyramid
Always use `testing-strategies.md` to ensure proper balance: 70% unit, 20% integration, 10% E2E.

### 2. Use Descriptive Test Names
Use `test-naming-conventions.md` patterns: `test_<unit>_<behavior>_<expected_outcome>`.

### 3. Mock Appropriately
Use `mocking-patterns.md` to decide what to mock. Mock external dependencies, not the system under test.

### 4. Keep Tests Fast
Use `testing-strategies.md` optimization strategies. Unit tests <10ms, integration <1s, E2E <30s.

### 5. Test Behavior, Not Implementation
Use templates to focus on observable behavior, not internal implementation details.

### 6. Use Test Data Patterns
Use `test-data-template.md` factories and fixtures to avoid duplication and improve maintainability.

### 7. Maintain Test Suites
Regularly use `test-maintenance.md` checklists (weekly/monthly/quarterly tasks).

### 8. Follow TDD When Appropriate
Use `tdd-workflow.md` Red-Green-Refactor cycle for new feature development.

### 9. Monitor Coverage Trends
Use `test-coverage-report-template.md` to track coverage over time and identify gaps.

### 10. Organize Tests Clearly
Use `test-naming-conventions.md` file naming and directory structure patterns.

---

## Complete Examples

### Example 1: Adding Tests for New Feature

```markdown
User: "Add comprehensive tests for the new user registration feature"

Process:
1. Read testing-strategies.md → Determine test types needed:
   - Unit tests for validation logic
   - Integration tests for API endpoint + database
   - E2E test for complete registration flow

2. Unit Tests (use unit-test-template.md):
   - test_validate_email_with_valid_format_returns_true()
   - test_validate_email_with_invalid_format_returns_false()
   - test_hash_password_returns_bcrypt_hash()

3. Integration Tests (use integration-test-template.md):
   - test_post_register_with_valid_data_creates_user_and_returns_201()
   - test_post_register_with_duplicate_email_returns_409()
   - test_post_register_sends_verification_email()

4. E2E Test (use e2e-test-template.md):
   - test_user_can_register_verify_email_and_login()

5. Test Data (use test-data-template.md):
   - create_user() factory for reusable user data
   - valid_emails and invalid_emails parameterized data

6. Coverage Report (use test-coverage-report-template.md):
   - Document initial coverage: 0%
   - Document final coverage: 92%
   - Identify remaining gap: Email delivery failure handling
```

### Example 2: Fixing Flaky E2E Tests

```markdown
User: "The checkout E2E test fails intermittently"

Process:
1. Read test-maintenance.md → Common Test Smells → Flaky Tests section
   - Identified cause: Race condition waiting for payment processing

2. Read e2e-test-template.md → E2E Testing Best Practices → Wait for Elements Properly
   - Replace arbitrary timeout with waitForSelector

3. Before (Flaky):
   ```javascript
   await page.click('[data-testid="place-order"]');
   await page.waitForTimeout(3000);  // Arbitrary wait
   expect(page.locator('.success')).toBeVisible();
   ```

4. After (Reliable):
   ```javascript
   await page.click('[data-testid="place-order"]');
   await page.waitForSelector('.success', { state: 'visible' });
   expect(page.locator('.success')).toBeVisible();
   ```

5. Result: Test now passes consistently (100 consecutive runs)
```

### Example 3: Improving Test Coverage

```markdown
User: "Audit test coverage and create action plan"

Process:
1. Use test-coverage-report-template.md to structure analysis:

   **Overall Coverage:** 68%

   **Coverage by Module:**
   - Authentication: 92% ✅
   - Payments: 45% ⚠️ (Critical gap)
   - Reporting: 88% ✅
   - Admin: 34% ⚠️

2. Read testing-strategies.md → Identify missing test types:
   - Payments needs integration tests (API + gateway mocking)
   - Admin needs E2E tests (user deletion workflow)

3. Create Action Plan:
   **Immediate (This Sprint):**
   - Add integration tests for payment refund flow (+15% coverage)
   - Add integration tests for webhook handling (+10% coverage)

   **Short-Term (Next 2 Sprints):**
   - Add E2E tests for admin user deletion
   - Add edge case tests for payment retry logic

4. Implement using appropriate templates:
   - integration-test-template.md for payment tests
   - e2e-test-template.md for admin tests
   - mocking-patterns.md for payment gateway mocking

5. Result: Coverage increases from 68% → 85% over 3 sprints
```

---

## Tips & Tricks

### Tip 1: Start with Unit Tests
Unit tests are fastest to write and run. Use `unit-test-template.md` to build solid foundation before adding integration/E2E tests.

### Tip 2: Use Test Data Factories
Use `test-data-template.md` factory patterns to avoid duplicating test data setup across tests.

### Tip 3: Name Tests as Documentation
Use `test-naming-conventions.md` patterns to make tests serve as living documentation. Good test names explain behavior.

### Tip 4: Mock External Services, Not Your Code
Use `mocking-patterns.md` to identify what should be mocked. Mock external APIs, payment gateways, email services. Don't mock your own business logic.

### Tip 5: Organize Tests by Feature
Use `test-naming-conventions.md` directory structure to organize tests by feature, not by test type. Easier to find and maintain.

### Tip 6: Keep E2E Tests Minimal
Use `testing-strategies.md` test pyramid. Only write E2E tests for critical user journeys (login, checkout, registration). Cover edge cases with unit tests.

### Tip 7: Use Page Objects for E2E Tests
Use `e2e-test-template.md` Page Object Model pattern to avoid duplicating selectors and improve E2E test maintainability.

### Tip 8: Monitor Coverage Trends
Use `test-coverage-report-template.md` to track coverage over time. Declining coverage indicates testing is falling behind development.

### Tip 9: Refactor Tests Regularly
Use `test-maintenance.md` weekly/monthly checklists to identify and fix flaky tests, slow tests, and duplicated code.

### Tip 10: Follow TDD for Complex Logic
Use `tdd-workflow.md` Red-Green-Refactor cycle for complex business logic. TDD helps clarify requirements and produces better design.

---

## Resources

### assets/
Template files designed to be copied and customized:

- **unit-test-template.md** - Unit testing with AAA pattern, parameterized tests, mocking, async, React components
- **integration-test-template.md** - API + database testing, authentication, external services, multi-step workflows
- **e2e-test-template.md** - Browser automation, Page Object Model, user journeys, visual testing, accessibility
- **test-data-template.md** - Fixtures, factories, builders, Faker, edge cases, relationship data
- **test-coverage-report-template.md** - Coverage analysis, gap identification, action planning, trend tracking

**Usage:** Copy template sections, fill in with your test code, customize as needed.

### references/
Comprehensive reference guides loaded into context:

- **testing-strategies.md** - Test pyramid, when to use each test type, decision tree, optimization strategies
- **test-naming-conventions.md** - Naming patterns, framework conventions, BDD-style, anti-patterns, organization
- **mocking-patterns.md** - Test doubles, when to mock, mocking patterns, assertions, anti-patterns
- **test-maintenance.md** - Test smells, refactoring patterns, test data management, CI/CD integration, metrics
- **tdd-workflow.md** - Red-Green-Refactor cycle, TDD patterns, scenarios, mistakes, checklist

**Usage:** Read relevant sections to inform testing approach and decision-making.

---

## Related Skills

- None currently (standalone skill)

## Related Agents

- @tests-steward - Primary consumer of this skill's templates and methodologies for maintaining test quality and coverage across the project

---

**Last Updated:** 2025-10-24
**Version:** 1.0.0
**Maintained By:** BMAD Tests Steward Team
