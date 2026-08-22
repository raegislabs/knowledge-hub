# Test Maintenance Reference Guide

## Overview

Test suites require ongoing maintenance to remain effective. This guide covers strategies for keeping tests fast, reliable, and valuable as codebases evolve.

---

## Common Test Smells

### 1. Flaky Tests

**Symptom:** Tests pass/fail intermittently without code changes.

**Causes:**
- Race conditions
- Timing dependencies
- Shared state between tests
- External service dependencies
- Non-deterministic data (random values, timestamps)

**Solutions:**

```javascript
// BAD - Flaky due to timing
it('should show notification', async () => {
  showNotification();
  await new Promise(resolve => setTimeout(resolve, 1000));  // Arbitrary wait
  expect(getNotification()).toBeVisible();
});

// GOOD - Wait for specific condition
it('should show notification', async () => {
  showNotification();
  await waitFor(() => expect(getNotification()).toBeVisible());
});
```

```python
// BAD - Non-deterministic
def test_user_creation():
    user = create_user(name=random.choice(["Alice", "Bob"]))  # Random
    assert user.name in ["Alice", "Bob"]  # Flaky

# GOOD - Deterministic
def test_user_creation():
    user = create_user(name="Alice")  # Fixed
    assert user.name == "Alice"
```

### 2. Slow Tests

**Symptom:** Test suite takes too long to run.

**Causes:**
- Too many E2E tests
- Real database operations in unit tests
- Unnecessary setup/teardown
- Serial execution when parallel possible

**Solutions:**

```python
# BAD - Slow database setup per test
def test_user_creation():
    db = create_real_database()  # Slow
    user = create_user(db)
    assert user.id is not None
    drop_database(db)

# GOOD - In-memory database
@pytest.fixture(scope="session")
def db():
    return create_engine("sqlite:///:memory:")  # Fast
```

```javascript
// BAD - Serial execution
describe('User tests', () => {
  it('test 1', async () => { /* slow */ });
  it('test 2', async () => { /* slow */ });
  // Tests run one by one
});

// GOOD - Parallel execution
describe.concurrent('User tests', () => {
  it('test 1', async () => { /* runs in parallel */ });
  it('test 2', async () => { /* runs in parallel */ });
});
```

### 3. Brittle Tests

**Symptom:** Tests break frequently on refactoring.

**Causes:**
- Testing implementation details
- Tight coupling to internal structure
- Hard-coded selectors (CSS classes)

**Solutions:**

```javascript
// BAD - Brittle (tests implementation)
it('should update state', () => {
  const spy = vi.spyOn(component, '_updateInternalState');
  component.doSomething();
  expect(spy).toHaveBeenCalled();  // Breaks on refactoring
});

// GOOD - Resilient (tests behavior)
it('should display updated value', () => {
  component.doSomething();
  expect(component.getValue()).toBe('expected');  // Public API
});
```

```python
# BAD - Hard-coded CSS
def test_click_button(page):
    page.click('.btn.btn-primary.submit-btn')  # Breaks if class changes

# GOOD - Test ID
def test_click_button(page):
    page.click('[data-testid="submit-button"]')  # Stable selector
```

### 4. Unclear Test Failures

**Symptom:** When test fails, it's hard to understand why.

**Causes:**
- Poor test names
- Generic assertions
- Missing error messages

**Solutions:**

```python
# BAD - Unclear failure
def test_user():
    assert user.age == 25  # What if this fails? Why?

# GOOD - Clear failure message
def test_user_age_is_calculated_from_birthdate():
    user = User(birthdate=date(1998, 1, 1))
    assert user.age == 25, f"Expected age 25, got {user.age}"
```

```javascript
// BAD - Generic assertion
expect(response.status).toBeTruthy();

// GOOD - Specific assertion
expect(response.status).toBe(200);  // Clear expected value
```

### 5. Test Duplication

**Symptom:** Similar test code repeated across tests.

**Causes:**
- Not using fixtures/factories
- Copy-paste test patterns
- Lack of test helpers

**Solutions:**

```python
# BAD - Duplicated setup
def test_1():
    user = User(email="test@example.com", name="Test", role="user")
    # ... test logic

def test_2():
    user = User(email="test@example.com", name="Test", role="user")
    # ... test logic

# GOOD - Shared fixture
@pytest.fixture
def user():
    return User(email="test@example.com", name="Test", role="user")

def test_1(user):
    # ... test logic

def test_2(user):
    # ... test logic
```

---

## Test Refactoring Patterns

### 1. Extract Test Helpers

```javascript
// Before - Duplicated logic
it('test 1', async () => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('[type="submit"]');
  // ... test logic
});

it('test 2', async () => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'admin@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('[type="submit"]');
  // ... test logic
});

// After - Extracted helper
async function login(page, email, password) {
  await page.goto('/login');
  await page.fill('[name="email"]', email);
  await page.fill('[name="password"]', password);
  await page.click('[type="submit"]');
}

it('test 1', async () => {
  await login(page, 'user@example.com', 'password');
  // ... test logic
});
```

### 2. Use Page Object Model

```javascript
// Before - Scattered selectors
it('should login', async () => {
  await page.fill('[data-testid="email-input"]', 'user@example.com');
  await page.fill('[data-testid="password-input"]', 'password');
  await page.click('[data-testid="login-button"]');
});

// After - Page Object
class LoginPage {
  constructor(page) {
    this.page = page;
  }

  async login(email, password) {
    await this.page.fill('[data-testid="email-input"]', email);
    await this.page.fill('[data-testid="password-input"]', password);
    await this.page.click('[data-testid="login-button"]');
  }
}

it('should login', async () => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password');
});
```

### 3. Consolidate Assertions

```python
# Before - Repetitive assertions
def test_user_creation():
    user = create_user(email="test@example.com", name="Test")

    assert user.email == "test@example.com"
    assert user.name == "Test"
    assert user.id is not None
    assert user.created_at is not None
    assert user.active is True

# After - Helper function
def assert_user_valid(user, email, name):
    """Assert user has expected attributes."""
    assert user.email == email
    assert user.name == name
    assert user.id is not None
    assert user.created_at is not None
    assert user.active is True

def test_user_creation():
    user = create_user(email="test@example.com", name="Test")
    assert_user_valid(user, "test@example.com", "Test")
```

---

## Managing Test Data

### 1. Use Factories for Complex Objects

```python
# Before - Manual object creation
def test_1():
    user = User(
        email="test@example.com",
        name="Test User",
        role="user",
        active=True,
        created_at=datetime.now()
    )

# After - Factory
def create_user(**overrides):
    defaults = {
        "email": "test@example.com",
        "name": "Test User",
        "role": "user",
        "active": True,
        "created_at": datetime.now()
    }
    return User(**{**defaults, **overrides})

def test_1():
    user = create_user(email="custom@example.com")  # Override only what you need
```

### 2. Seed Data Files

```python
# Load seed data from file
@pytest.fixture
def seed_data(db_session):
    with open('tests/fixtures/seed.json') as f:
        data = json.load(f)
    for user_data in data['users']:
        db_session.add(User(**user_data))
    db_session.commit()
```

---

## Handling Test Database

### 1. Transaction Rollback

```python
# Rollback after each test
@pytest.fixture(autouse=True)
def db_transaction(db_session):
    # Start transaction
    yield
    # Rollback transaction
    db_session.rollback()
```

### 2. Database Cleanup

```javascript
// Clean up after each test
afterEach(async () => {
  await db.query('DELETE FROM users');
  await db.query('DELETE FROM posts');
});
```

### 3. Test Database Isolation

```python
# Separate test database
@pytest.fixture(scope="session")
def test_db():
    engine = create_engine("postgresql://localhost/test_db")
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
```

---

## Dealing with External Dependencies

### 1. Mock External APIs

```python
@pytest.fixture
def mock_payment_gateway():
    with patch('app.services.PaymentGateway') as mock:
        mock.charge.return_value = {"status": "success"}
        yield mock
```

### 2. Use Test Doubles for Services

```javascript
// Create test double for external service
class FakeEmailService {
  async send(email) {
    this.sentEmails.push(email);
    return { success: true };
  }
}

const emailService = new FakeEmailService();
```

---

## Test Organization Strategies

### 1. Group Related Tests

```python
class TestUserAuthentication:
    """Tests for user authentication flows."""

    class TestLogin:
        def test_successful_login(self):
            pass

        def test_failed_login_invalid_credentials(self):
            pass

    class TestLogout:
        def test_successful_logout(self):
            pass
```

### 2. Separate Test Types

```
tests/
  unit/
    services/
      user_service_test.py
    utils/
      validators_test.py
  integration/
    api/
      user_endpoints_test.py
    database/
      user_repository_test.py
  e2e/
    auth/
      login_flow_test.ts
```

---

## CI/CD Integration

### 1. Fail Fast

```yaml
# Run fast unit tests first
name: Tests
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - run: npm test:unit  # Fast, fail early

  integration-tests:
    needs: unit-tests  # Only if unit tests pass
    runs-on: ubuntu-latest
    steps:
      - run: npm test:integration

  e2e-tests:
    needs: integration-tests  # Only if integration tests pass
    runs-on: ubuntu-latest
    steps:
      - run: npm test:e2e
```

### 2. Parallel Execution

```yaml
# Run tests in parallel
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - run: npm test -- --shard=${{ matrix.shard }}/4
```

---

## Test Metrics to Track

### 1. Coverage Trends

```bash
# Track coverage over time
npm test -- --coverage
# Store coverage/lcov.info for trend analysis
```

### 2. Test Execution Time

```bash
# Identify slow tests
pytest --durations=10  # Show 10 slowest tests
```

### 3. Flaky Test Rate

```bash
# Track flaky tests
npm test -- --retries=3 --reporter=flaky-test-reporter
```

---

## Refactoring Checklist

When refactoring tests:

- [ ] Remove duplicate setup code (use fixtures/factories)
- [ ] Extract test helpers for common operations
- [ ] Replace hard-coded values with constants
- [ ] Use data-testid instead of CSS classes
- [ ] Add descriptive error messages to assertions
- [ ] Group related tests in describe blocks or classes
- [ ] Remove obsolete tests for removed features
- [ ] Update test names to match new behavior
- [ ] Ensure tests are independent (no shared state)
- [ ] Mock external dependencies consistently

---

## Common Maintenance Tasks

### Weekly

- [ ] Review and fix flaky tests
- [ ] Check test execution time (identify slow tests)
- [ ] Review test coverage (identify gaps)

### Monthly

- [ ] Refactor duplicate test code
- [ ] Update test data/fixtures
- [ ] Review and remove obsolete tests
- [ ] Check for brittle tests (tight coupling)

### Quarterly

- [ ] Audit test strategy (unit/integration/E2E balance)
- [ ] Review test infrastructure (CI/CD, test databases)
- [ ] Evaluate testing tools (consider upgrades)

---

## Quick Reference

| Problem | Solution |
|---------|----------|
| Flaky tests | Use deterministic data, proper waits |
| Slow tests | Use in-memory DB, parallel execution |
| Brittle tests | Test behavior, not implementation |
| Unclear failures | Descriptive names, specific assertions |
| Test duplication | Fixtures, factories, helpers |
| Hard to debug | Break tests into smaller units |

---

## Related References

- **testing-strategies.md** - Choosing right test types
- **test-naming-conventions.md** - Clear, maintainable test names
- **mocking-patterns.md** - Managing mocks effectively
- **test-data-template.md** - Creating maintainable test data
