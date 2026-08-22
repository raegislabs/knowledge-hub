# Test Strategy Guide

## Overview

This guide provides comprehensive strategies and methodologies for designing effective test plans and executing quality assurance activities.

---

## Levels of Testing

### 1. Unit Testing

**Purpose**: Test individual functions, methods, or classes in isolation.

**Characteristics**:
- Smallest testable units
- Fast execution (<100ms per test)
- Independent of external dependencies (use mocks)
- High volume (hundreds to thousands of tests)
- Run frequently (on every code change)

**What to Test**:
- Single function/method behavior
- Return values for various inputs
- Exception handling
- Edge cases and boundary conditions
- Private methods (through public interface)

**Frameworks**:
- **Python**: pytest, unittest
- **JavaScript**: Jest, Mocha, Vitest
- **Java**: JUnit, TestNG

**Example (pytest)**:
```python
def test_calculate_discount():
    # Arrange
    price = 100
    discount_percent = 10

    # Act
    result = calculate_discount(price, discount_percent)

    # Assert
    assert result == 90
```

**Best Practices**:
- Follow Arrange-Act-Assert (AAA) pattern
- One assertion per test (preferably)
- Clear, descriptive test names
- Test behavior, not implementation
- Aim for >90% code coverage

---

### 2. Integration Testing

**Purpose**: Test interactions between components or systems.

**Characteristics**:
- Tests multiple components together
- Slower than unit tests (seconds per test)
- May use real dependencies or test doubles
- Medium volume (dozens to hundreds of tests)
- Run before deployment

**What to Test**:
- Component interactions
- Database operations (CRUD)
- API integrations
- Message queues
- File system operations
- Authentication/authorization flows

**Approaches**:
- **Big Bang**: Test all components at once
- **Top-Down**: Start with high-level modules
- **Bottom-Up**: Start with low-level modules
- **Sandwich**: Combination of top-down and bottom-up

**Example (pytest with database)**:
```python
def test_save_user_to_database(test_db):
    # Arrange
    user = User(name="John", email="john@example.com")

    # Act
    user_id = user.save()

    # Assert
    retrieved_user = User.get_by_id(user_id)
    assert retrieved_user.name == "John"
    assert retrieved_user.email == "john@example.com"
```

**Best Practices**:
- Use test databases or sandboxes
- Clean up after each test (fixtures)
- Test realistic scenarios
- Mock external services (APIs, third-party)
- Test error handling and retries

---

### 3. System Testing

**Purpose**: Test the complete, integrated system as a whole.

**Characteristics**:
- Tests entire application end-to-end
- Slowest tests (minutes per test)
- Uses real or staging environment
- Low volume (dozens of tests)
- Run before releases

**What to Test**:
- Complete user workflows
- Business processes
- System behavior under load
- Cross-browser compatibility (web)
- Multi-platform support

**Types**:
- **Functional Testing**: Features work as specified
- **Non-Functional Testing**: Performance, security, usability
- **End-to-End Testing**: User journeys from start to finish

**Example (E2E with Playwright)**:
```python
def test_complete_checkout_flow(page):
    # User adds item to cart
    page.goto("/products")
    page.click("button:has-text('Add to Cart')")

    # User proceeds to checkout
    page.click("a:has-text('Cart')")
    page.click("button:has-text('Checkout')")

    # User completes payment
    page.fill("#card-number", "4242424242424242")
    page.fill("#expiry", "12/25")
    page.click("button:has-text('Pay')")

    # Verify success
    assert page.locator(".success-message").is_visible()
```

**Best Practices**:
- Focus on critical paths
- Test realistic user scenarios
- Use staging environment
- Automate where possible
- Document manual test steps

---

### 4. Acceptance Testing

**Purpose**: Verify system meets business requirements and is acceptable for delivery.

**Characteristics**:
- Business-focused, not technical
- Performed by stakeholders/users
- Based on acceptance criteria
- Manual or automated
- Final gate before production

**Types**:
- **User Acceptance Testing (UAT)**: End users validate
- **Business Acceptance Testing (BAT)**: Business stakeholders validate
- **Alpha Testing**: Internal testing before release
- **Beta Testing**: External users test pre-release

**What to Test**:
- Business requirements met
- User stories completed
- Acceptance criteria satisfied
- Usability and user experience
- Real-world usage scenarios

**Best Practices**:
- Clear acceptance criteria defined upfront
- Involve actual users
- Test in production-like environment
- Document user feedback
- Sign-off process defined

---

## Test Strategy Approaches

### Risk-Based Testing

**Concept**: Prioritize testing based on risk assessment.

**Risk Factors**:
1. **Complexity**: More complex = higher risk
2. **Criticality**: Business-critical features = higher risk
3. **Change Frequency**: Frequently changed = higher risk
4. **Defect History**: Historically buggy = higher risk
5. **Visibility**: Customer-facing = higher risk

**Risk Assessment Matrix**:

| Likelihood ↓ / Impact → | Low | Medium | High |
|-------------------------|-----|--------|------|
| **High** | Medium | High | Critical |
| **Medium** | Low | Medium | High |
| **Low** | Low | Low | Medium |

**Prioritization**:
1. **Critical Risk**: Test first, most thoroughly, automated
2. **High Risk**: Test early, thoroughly
3. **Medium Risk**: Standard testing
4. **Low Risk**: Minimal testing, may skip if time-constrained

**Example**:
```
Feature: Payment Processing
- Risk: CRITICAL (high impact, medium likelihood)
- Strategy:
  - Comprehensive unit tests (>95% coverage)
  - Integration tests with test payment gateway
  - End-to-end tests for all payment flows
  - Security testing (PCI compliance)
  - Error handling for all failure modes
  - Load testing for concurrent transactions
```

---

### Shift-Left Testing

**Concept**: Test early and often in the development lifecycle.

**Principles**:
1. **Test Planning Early**: Define test strategy before coding
2. **Static Analysis**: Code reviews, linters before execution
3. **Unit Tests First**: TDD approach (write tests before code)
4. **Continuous Testing**: Automated tests in CI/CD
5. **Early Bug Detection**: Cheaper to fix early

**Benefits**:
- Bugs found earlier (cheaper to fix)
- Faster feedback loops
- Better code quality
- Reduced technical debt

**Implementation**:
```
Traditional:
Requirements → Design → Code → Test → Deploy

Shift-Left:
Requirements + Tests → Design + Tests → Code + Tests → Deploy
```

**Best Practices**:
- Write acceptance tests during requirements phase
- Code reviews for every change
- Automated tests run on every commit
- Static analysis in IDE and CI/CD
- Developers write unit tests

---

### Test-Driven Development (TDD)

**Concept**: Write tests before writing code.

**Red-Green-Refactor Cycle**:
1. **Red**: Write a failing test
2. **Green**: Write minimal code to pass test
3. **Refactor**: Improve code while keeping tests green

**Benefits**:
- Better code design (testable code)
- Higher test coverage (100% possible)
- Clear requirements (tests as specs)
- Confidence to refactor

**Example**:
```python
# Step 1: RED - Write failing test
def test_calculate_total():
    cart = ShoppingCart()
    cart.add_item(price=10, quantity=2)
    assert cart.calculate_total() == 20

# Step 2: GREEN - Write minimal code
class ShoppingCart:
    def __init__(self):
        self.items = []

    def add_item(self, price, quantity):
        self.items.append({"price": price, "quantity": quantity})

    def calculate_total(self):
        return sum(item["price"] * item["quantity"] for item in self.items)

# Step 3: REFACTOR - Improve code (tests still pass)
```

---

### Behavior-Driven Development (BDD)

**Concept**: Specify behavior in plain language, automate as tests.

**Gherkin Syntax**:
```gherkin
Feature: Shopping Cart

  Scenario: Add items to cart
    Given I am on the products page
    When I click "Add to Cart" for "Widget"
    Then I should see "1 item" in my cart
    And the cart total should be "$10.00"
```

**Tools**:
- **Python**: behave, pytest-bdd
- **JavaScript**: Cucumber.js
- **Ruby**: Cucumber

**Benefits**:
- Shared understanding (business + dev + QA)
- Living documentation
- Clear acceptance criteria
- Non-technical stakeholders can read

---

## Test Design Techniques

### Equivalence Partitioning

**Concept**: Divide inputs into groups (partitions) that should behave similarly.

**Example**:
```
Function: validate_age(age)
- Valid: 0-120
- Invalid: <0, >120

Partitions:
1. Invalid: -10 (negative)
2. Valid: 0 (boundary)
3. Valid: 50 (normal)
4. Valid: 120 (boundary)
5. Invalid: 150 (too high)

Test Cases: One from each partition
```

---

### Boundary Value Analysis

**Concept**: Test at the edges of equivalence partitions.

**Example**:
```
Function: validate_discount(percent)
- Valid: 0-100

Boundary Tests:
- -1 (just below min) → INVALID
- 0 (min) → VALID
- 1 (just above min) → VALID
- 99 (just below max) → VALID
- 100 (max) → VALID
- 101 (just above max) → INVALID
```

---

### Decision Table Testing

**Concept**: Test all combinations of conditions and actions.

**Example**:
```
Login System:
- Condition 1: Username valid (Y/N)
- Condition 2: Password valid (Y/N)

Decision Table:
| Test | User | Pass | Result |
|------|------|------|--------|
| 1    | Y    | Y    | Success |
| 2    | Y    | N    | Fail    |
| 3    | N    | Y    | Fail    |
| 4    | N    | N    | Fail    |
```

---

### State Transition Testing

**Concept**: Test state changes and transitions.

**Example**:
```
Order States: Draft → Submitted → Paid → Shipped → Delivered

Test Transitions:
- Draft → Submitted (valid)
- Draft → Paid (invalid, should fail)
- Submitted → Draft (invalid, should fail)
- Submitted → Paid (valid)
- Paid → Shipped (valid)
- Shipped → Delivered (valid)
```

---

### Pairwise Testing

**Concept**: Test all pairs of parameters, not all combinations.

**Example**:
```
Browser: [Chrome, Firefox, Safari]
OS: [Windows, macOS, Linux]
Resolution: [1080p, 4K]

All combinations: 3 × 3 × 2 = 18 tests

Pairwise: ~9 tests (covers all pairs of parameters)
```

**Tool**: PICT (Pairwise Independent Combinatorial Testing)

---

## Quality Metrics

### Code Coverage

**Types**:
- **Line Coverage**: % of lines executed
- **Branch Coverage**: % of branches executed
- **Function Coverage**: % of functions called
- **Statement Coverage**: % of statements executed

**Target**: >90% for critical code, >80% overall

**Note**: High coverage ≠ good tests. Quality > quantity.

---

### Defect Metrics

**Defect Density**: Defects per 1000 lines of code
- Target: <1.0 for mature code

**Defect Detection Rate**: Defects found / Total defects
- Target: >90% (find bugs before production)

**Defect Escape Rate**: Prod bugs / Total bugs
- Target: <10% (keep bugs out of production)

---

### Test Effectiveness

**Test Pass Rate**: Passing tests / Total tests
- Target: >95%

**Flaky Test Rate**: Intermittent failures / Total tests
- Target: <2% (flaky tests erode confidence)

**Mean Time to Detect (MTTD)**: Time from bug introduction to detection
- Target: <1 day (shift-left approach)

---

## Best Practices

### 1. Test Pyramid

**Concept**: More unit tests, fewer integration tests, even fewer E2E tests.

```
       /\
      /E2E\      ← Few (slow, expensive, brittle)
     /______\
    /  Integ \   ← Some (medium speed, medium cost)
   /__________\
  /   Unit     \ ← Many (fast, cheap, stable)
 /______________\
```

**Rationale**:
- Unit tests are fast, stable, easy to maintain
- E2E tests are slow, brittle, expensive
- Balance provides confidence with efficiency

---

### 2. Test Naming Conventions

**Good Test Names**:
```python
def test_calculate_discount_with_valid_percentage_returns_correct_amount():
    pass

def test_calculate_discount_with_negative_percentage_raises_value_error():
    pass
```

**Format**: `test_{method}_{scenario}_{expected_result}`

---

### 3. Test Independence

**Principle**: Tests should not depend on each other.

**Bad** (tests depend on order):
```python
def test_create_user():
    user = create_user("John")
    # User created, stored in DB

def test_update_user():
    # Assumes user from previous test exists
    update_user("John", email="new@example.com")
```

**Good** (tests are independent):
```python
@pytest.fixture
def user():
    user = create_user("John")
    yield user
    delete_user(user.id)  # Clean up

def test_update_user(user):
    update_user(user.id, email="new@example.com")
    assert user.email == "new@example.com"
```

---

### 4. Fast Feedback

**Principle**: Tests should run quickly to enable frequent execution.

**Strategies**:
- Run unit tests on every save (IDE)
- Run subset of tests pre-commit
- Run full suite in CI/CD
- Parallelize test execution
- Cache dependencies

---

### 5. Test Data Management

**Strategies**:
- **Fixtures**: Reusable test data
- **Factories**: Generate test data programmatically
- **Builders**: Fluent API for test data creation
- **Snapshots**: Capture and compare outputs

**Example (Factory)**:
```python
class UserFactory:
    @staticmethod
    def create(name="John", email=None):
        email = email or f"{name.lower()}@example.com"
        return User(name=name, email=email)

# Usage
user = UserFactory.create(name="Jane")
```

---

### 6. Avoid Test Duplication

**Principle**: Don't test the same thing multiple ways.

**Bad**:
```python
def test_add_numbers():
    assert add(2, 3) == 5

def test_addition():
    assert add(2, 3) == 5
```

**Good**:
```python
def test_add_numbers():
    assert add(2, 3) == 5

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add_multiple_scenarios(a, b, expected):
    assert add(a, b) == expected
```

---

### 7. Test Maintenance

**Principle**: Tests are code too—keep them clean and maintainable.

**Strategies**:
- Refactor tests when refactoring code
- Remove obsolete tests
- Fix flaky tests immediately
- Clear, descriptive names
- DRY (Don't Repeat Yourself)

---

## Summary

**Key Takeaways**:

1. **Multiple Levels**: Unit, integration, system, acceptance
2. **Risk-Based**: Prioritize based on impact and likelihood
3. **Shift-Left**: Test early and often
4. **Test Pyramid**: Many unit tests, few E2E tests
5. **Independence**: Tests should not depend on each other
6. **Fast Feedback**: Run tests frequently
7. **Metrics**: Track coverage, defect density, effectiveness
8. **Maintenance**: Treat tests as first-class code

**Recommended Reading**:
- "The Art of Software Testing" by Glenford Myers
- "Growing Object-Oriented Software, Guided by Tests" by Steve Freeman
- "Test Driven Development: By Example" by Kent Beck
