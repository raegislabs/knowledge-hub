# QA Methodologies Guide

## Overview

This guide covers different QA methodologies, testing approaches for various software development lifecycles, and how to adapt testing strategies to different project types and team structures.

---

## Testing in Different SDLC Models

### 1. Waterfall Testing

**Characteristics**:
- Sequential phases
- Testing after development complete
- Formal documentation
- Clear exit criteria

**Testing Phases**:

```
Requirements → Design → Development → Testing → Deployment → Maintenance
                                        ↑
                            Integration → System → UAT
```

**Test Approach**:

1. **Requirements Phase**:
   - Create test plan
   - Define test strategy
   - Identify test scenarios

2. **Design Phase**:
   - Write detailed test cases
   - Prepare test data
   - Set up test environment

3. **Development Phase**:
   - Developers perform unit testing
   - QA prepares integration tests

4. **Testing Phase**:
   - Execute test cases
   - Log defects
   - Regression testing
   - User acceptance testing

**Pros**:
- ✅ Clear structure and documentation
- ✅ Well-defined milestones
- ✅ Thorough testing before release
- ✅ Good for stable requirements

**Cons**:
- ❌ Late defect detection (expensive fixes)
- ❌ No working software until late
- ❌ Inflexible to changes
- ❌ Long feedback loops

**Best For**:
- Projects with stable, well-defined requirements
- Regulated industries (healthcare, finance)
- Large, complex systems with formal processes

---

### 2. Agile Testing

**Characteristics**:
- Iterative development (sprints)
- Continuous testing
- Collaboration between dev and QA
- Rapid feedback

**Testing Approach**:

```
Sprint Planning → Development + Testing → Sprint Review → Retrospective
       ↑                                                         ↓
       └─────────────────── Continuous Improvement ─────────────┘
```

**Agile Testing Quadrants** (by Brian Marick):

```
        Business-Facing
             ↑
    Q2       |       Q3
 Automated   | Manual
 Functional  | Exploratory
    ──────────┼──────────
    Q1       |       Q4
 Automated   | Automated
 Unit/Integ  | Performance
             |
        Technology-Facing
```

**Quadrant 1** (Technology-Facing, Automated):
- Unit tests
- Integration tests
- Component tests
- **Purpose**: Support development

**Quadrant 2** (Business-Facing, Automated/Manual):
- Functional tests
- Story tests
- Prototypes
- **Purpose**: Critique product

**Quadrant 3** (Business-Facing, Manual):
- Exploratory testing
- Usability testing
- User acceptance testing
- **Purpose**: Critique product

**Quadrant 4** (Technology-Facing, Automated):
- Performance tests
- Load tests
- Security tests
- **Purpose**: Support development

**Sprint Testing Workflow**:

**Day 1-2** (Sprint Planning):
- Understand user stories
- Define acceptance criteria
- Identify testable scenarios
- Estimate testing effort

**Day 3-8** (Development + Testing):
- Developers write unit tests (TDD)
- QA writes automated tests
- Continuous integration runs tests
- Exploratory testing of completed stories
- Bug fixes and retesting

**Day 9-10** (Sprint Review/Retrospective):
- Demo to stakeholders
- UAT sign-off
- Regression testing
- Retrospective (what went well, what to improve)

**Pros**:
- ✅ Early and continuous feedback
- ✅ Flexible to changing requirements
- ✅ Working software every sprint
- ✅ Collaboration and communication
- ✅ Early defect detection (cheaper fixes)

**Cons**:
- ❌ Less documentation
- ❌ Requires discipline and automation
- ❌ Continuous pressure
- ❌ Hard to estimate long-term

**Best For**:
- Projects with evolving requirements
- Fast-moving startups
- Products requiring frequent releases
- Teams with strong collaboration

---

### 3. DevOps Testing (Continuous Testing)

**Characteristics**:
- Automated testing in CI/CD pipeline
- Shift-left (test early) and shift-right (test in production)
- Fast feedback loops
- Production monitoring

**CI/CD Pipeline**:

```
Code Commit → Build → Unit Tests → Integration Tests → Deploy to Staging → E2E Tests → Deploy to Prod → Monitor
                                        ↓                                         ↓
                                   (5-10 min)                                (Continuous)
```

**Testing Stages**:

1. **Pre-Commit** (Developer's machine):
   - Linting
   - Unit tests
   - Fast (<1 min)

2. **Post-Commit** (CI server):
   - Full unit test suite
   - Static analysis
   - Code coverage
   - Medium (<10 min)

3. **Integration** (CI server):
   - Integration tests
   - API tests
   - Database tests
   - Medium-slow (<30 min)

4. **Staging** (Staging environment):
   - End-to-end tests
   - Performance tests
   - Security scans
   - Slow (<1 hour)

5. **Production** (Production environment):
   - Smoke tests
   - Monitoring
   - Canary testing
   - Continuous

**Shift-Right Testing** (Testing in Production):

- **Canary Deployments**: Deploy to 5% of users first
- **Feature Flags**: Enable features for subset of users
- **A/B Testing**: Compare two versions
- **Synthetic Monitoring**: Automated checks in production
- **Real User Monitoring (RUM)**: Track actual user behavior

**Pros**:
- ✅ Very fast feedback (<10 min)
- ✅ High confidence through automation
- ✅ Frequent releases (daily, hourly)
- ✅ Production monitoring catches issues early

**Cons**:
- ❌ Requires significant automation investment
- ❌ Complex infrastructure
- ❌ Learning curve for tools
- ❌ Requires cultural shift

**Best For**:
- SaaS products
- Web applications
- Teams with strong automation culture
- High-frequency release cadence

---

## Testing Strategies

### 1. Test-Driven Development (TDD)

**Concept**: Write tests before writing code.

**Red-Green-Refactor Cycle**:

```
1. Red: Write a failing test
   ↓
2. Green: Write minimal code to pass
   ↓
3. Refactor: Improve code, keep tests green
   ↓
Repeat
```

**Example**:

```python
# Step 1: RED - Write failing test
def test_add_two_numbers():
    calculator = Calculator()
    result = calculator.add(2, 3)
    assert result == 5

# (Run test → FAIL, Calculator doesn't exist)

# Step 2: GREEN - Write minimal code
class Calculator:
    def add(self, a, b):
        return a + b

# (Run test → PASS)

# Step 3: REFACTOR - Improve if needed
class Calculator:
    def add(self, a: int, b: int) -> int:
        """Add two integers and return the sum."""
        return a + b

# (Run test → PASS, code improved)
```

**Benefits**:
- 100% code coverage achievable
- Better code design (testable by default)
- Tests as executable documentation
- Confidence to refactor

**Challenges**:
- Slower initial development
- Requires discipline
- Learning curve
- May over-test trivial code

**Best For**:
- Complex business logic
- Critical algorithms
- Teams new to testing (enforces discipline)
- Long-term maintainability

---

### 2. Behavior-Driven Development (BDD)

**Concept**: Specify behavior in plain language, automate as tests.

**Gherkin Syntax**:

```gherkin
Feature: Shopping Cart
  As a customer
  I want to add items to my cart
  So that I can purchase them later

  Scenario: Add item to empty cart
    Given I am on the products page
    When I click "Add to Cart" for "Widget"
    Then I should see "1 item" in my cart
    And the cart total should be "$10.00"

  Scenario: Add multiple items
    Given I have "Widget" in my cart
    When I click "Add to Cart" for "Gadget"
    Then I should see "2 items" in my cart
    And the cart total should be "$25.00"
```

**Implementation** (Python with behave):

```python
# features/steps/cart_steps.py
from behave import given, when, then

@given('I am on the products page')
def step_impl(context):
    context.browser.get('/products')

@when('I click "Add to Cart" for "{product}"')
def step_impl(context, product):
    context.browser.find_element_by_xpath(
        f"//button[@data-product='{product}']"
    ).click()

@then('I should see "{count}" in my cart')
def step_impl(context, count):
    cart_count = context.browser.find_element_by_id('cart-count').text
    assert cart_count == count
```

**Benefits**:
- Shared understanding (business + dev + QA)
- Living documentation
- Non-technical stakeholders can read
- Focuses on behavior, not implementation

**Challenges**:
- Can be verbose
- Maintenance overhead
- Risk of over-specification
- Learning curve for Gherkin

**Best For**:
- Complex business rules
- Stakeholder involvement in testing
- Regulated industries (audit trail)
- Teams with mixed technical skills

---

### 3. Acceptance Test-Driven Development (ATDD)

**Concept**: Write acceptance tests before development begins.

**Process**:

```
1. Discuss: Team defines acceptance criteria
   ↓
2. Write: QA writes automated acceptance tests
   ↓
3. Develop: Dev implements feature to pass tests
   ↓
4. Verify: Tests pass, feature accepted
```

**Example**:

```python
# Acceptance Criteria (from user story)
# - User can log in with valid credentials
# - User sees error with invalid credentials
# - User is redirected to dashboard after login

# Acceptance Tests (written before development)
def test_login_with_valid_credentials():
    page.goto('/login')
    page.fill('#username', 'john@example.com')
    page.fill('#password', 'password123')
    page.click('button:has-text("Login")')
    assert page.url == '/dashboard'

def test_login_with_invalid_credentials():
    page.goto('/login')
    page.fill('#username', 'john@example.com')
    page.fill('#password', 'wrongpassword')
    page.click('button:has-text("Login")')
    assert page.locator('.error').text_content() == 'Invalid credentials'
```

**Benefits**:
- Clear definition of done
- Prevents misunderstandings
- Automated acceptance tests
- Business and technical alignment

**Challenges**:
- Requires collaboration
- Time investment upfront
- May slow initial progress

**Best For**:
- Teams with strong collaboration
- Complex user stories
- Projects with clear acceptance criteria

---

## Testing Types

### 1. Functional Testing

**Focus**: Does the software do what it's supposed to do?

**Types**:
- **Unit Testing**: Individual functions/methods
- **Integration Testing**: Component interactions
- **System Testing**: End-to-end workflows
- **Regression Testing**: Existing functionality still works
- **Smoke Testing**: Basic critical functionality
- **Sanity Testing**: Quick check after changes

---

### 2. Non-Functional Testing

**Focus**: How well does the software perform?

**Types**:

**Performance Testing**:
- **Load Testing**: Behavior under expected load
- **Stress Testing**: Behavior under extreme load
- **Spike Testing**: Sudden load increases
- **Endurance Testing**: Sustained load over time

**Security Testing**:
- Penetration testing
- Vulnerability scanning
- Security code review
- Authentication/authorization testing

**Usability Testing**:
- User experience testing
- Accessibility testing (WCAG)
- Cross-browser testing
- Mobile responsiveness

**Compatibility Testing**:
- Browser compatibility
- OS compatibility
- Device compatibility
- Backward compatibility

**Reliability Testing**:
- Failover testing
- Recovery testing
- Availability testing

---

## Testing Levels

### 1. Component/Unit Testing

**Scope**: Individual functions, methods, classes

**Who**: Developers

**When**: During development

**Tools**: pytest, Jest, JUnit

**Coverage**: >90% code coverage

**Example**:
```python
def test_calculate_tax():
    assert calculate_tax(100, rate=0.1) == 10
```

---

### 2. Integration Testing

**Scope**: Interactions between components

**Who**: Developers and QA

**When**: After unit testing

**Tools**: pytest, Postman, REST Assured

**Coverage**: All integration points

**Example**:
```python
def test_save_user_to_database():
    user = User(name="John")
    user.save()
    retrieved = User.get_by_name("John")
    assert retrieved.name == "John"
```

---

### 3. System Testing

**Scope**: Complete integrated system

**Who**: QA Team

**When**: After integration testing

**Tools**: Selenium, Playwright, Cypress

**Coverage**: End-to-end user workflows

**Example**:
```python
def test_complete_checkout_flow():
    page.goto('/products')
    page.click('button:has-text("Add to Cart")')
    page.click('a:has-text("Checkout")')
    page.fill('#card-number', '4242424242424242')
    page.click('button:has-text("Pay")')
    assert page.locator('.success').is_visible()
```

---

### 4. Acceptance Testing

**Scope**: Business requirements met

**Who**: Business stakeholders, QA

**When**: Before release

**Tools**: Manual testing, Cucumber, behave

**Coverage**: Acceptance criteria

---

## Test Automation Strategies

### Test Automation Pyramid

```
       /\
      /E2E\       ← 10% (Slow, brittle, expensive)
     /______\
    / Service\    ← 20% (Medium speed, API tests)
   /__________\
  /   Unit     \  ← 70% (Fast, stable, cheap)
 /______________\
```

**Rationale**:
- **Unit tests**: Fast (<100ms), cheap to write/maintain, stable
- **Service/API tests**: Medium speed (~1s), integration coverage
- **E2E tests**: Slow (minutes), expensive, brittle, but critical

---

### What to Automate

**Good Candidates**:
- ✅ Regression tests (run repeatedly)
- ✅ Smoke tests (run on every build)
- ✅ API tests (fast, stable)
- ✅ Unit tests (fast, easy to maintain)
- ✅ Data-driven tests (many inputs)

**Poor Candidates**:
- ❌ One-time tests
- ❌ Rapidly changing UI
- ❌ Usability testing (needs human judgment)
- ❌ Exploratory testing
- ❌ Tests harder to automate than run manually

---

### Automation Best Practices

1. **Start Small**: Automate critical paths first
2. **Fast Feedback**: Unit tests <10s, E2E <5min
3. **Stable**: Flaky tests erode confidence
4. **Maintainable**: Page Object pattern, reusable components
5. **Independent**: Tests don't depend on each other
6. **Clear Failures**: Easy to diagnose what broke
7. **Parallel Execution**: Speed up test suite

---

## Exploratory Testing

**Concept**: Simultaneous test design, execution, and learning.

**When to Use**:
- New features (no test cases yet)
- Usability testing
- Finding unexpected bugs
- Complement to scripted testing

**Session-Based Testing**:

```
Charter: Explore login flow with various inputs
Time Box: 60 minutes
Focus: Input validation, error messages, edge cases

Notes:
- Found: Email validation accepts invalid format
- Found: Error message generic, not helpful
- Positive: Password strength indicator works well
- Question: Should spaces be allowed in passwords?

Bugs Filed: 2
Test Ideas for Automation: 5
```

**Benefits**:
- Finds bugs automation misses
- Fast feedback on new features
- Encourages critical thinking
- Good for usability issues

**Challenges**:
- Not repeatable
- Depends on tester skill
- Hard to estimate time
- Less documentation

---

## Testing in Different Contexts

### Microservices Testing

**Challenges**:
- Many services to test
- Complex interactions
- Distributed systems

**Strategy**:

1. **Unit Tests**: Each service independently (70%)
2. **Contract Tests**: Service interfaces (Pact) (20%)
3. **Integration Tests**: Service-to-service (10%)
4. **E2E Tests**: Critical paths only (<5%)
5. **Chaos Engineering**: Failure scenarios

**Tools**: Pact, Testcontainers, WireMock

---

### Mobile App Testing

**Considerations**:
- Multiple devices and OS versions
- Network conditions (3G, 4G, 5G, WiFi, offline)
- Touch gestures
- Battery consumption
- App permissions

**Strategy**:
- Cloud device farms (BrowserStack, Sauce Labs)
- Emulators for quick feedback
- Real devices for critical scenarios
- Automated tests with Appium, Detox

---

### API Testing

**Focus**:
- Request/response validation
- Status codes
- Error handling
- Performance
- Security

**Tools**: Postman, REST Assured, Pytest + requests

**Example**:
```python
def test_get_user_api():
    response = requests.get('/api/users/123')
    assert response.status_code == 200
    assert response.json()['name'] == 'John'
    assert response.headers['Content-Type'] == 'application/json'
```

---

## Summary

**Key Methodologies**:

1. **Waterfall**: Sequential, formal, late testing
2. **Agile**: Iterative, continuous testing, collaboration
3. **DevOps**: Automated, CI/CD, shift-left and shift-right
4. **TDD**: Write tests first, better design
5. **BDD**: Behavior specification, shared understanding
6. **ATDD**: Acceptance tests before development

**Testing Strategies**:

- **Test Pyramid**: Many unit tests, few E2E tests
- **Automation**: Automate regression, smoke, API tests
- **Exploratory**: Human intelligence, usability, new features
- **Risk-Based**: Prioritize critical, high-risk areas

**Adapt to Context**:

- **Waterfall**: Stable requirements, regulated industries
- **Agile**: Evolving requirements, fast feedback
- **DevOps**: Continuous delivery, high automation
- **Microservices**: Contract testing, chaos engineering
- **Mobile**: Device fragmentation, network conditions
- **API**: Request/response validation, performance

**Best Practices**:

- Test early and often (shift-left)
- Automate wisely (pyramid)
- Collaborate (dev + QA + business)
- Continuous improvement (retrospectives)
- Metrics-driven (track and improve)

**Recommended Reading**:
- "Agile Testing" by Lisa Crispin and Janet Gregory
- "Continuous Delivery" by Jez Humble and David Farley
- "The DevOps Handbook" by Gene Kim et al.
- "Test-Driven Development" by Kent Beck
