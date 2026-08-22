# Testing Strategies Reference Guide

## Overview

This guide helps you choose the right testing strategy for different scenarios, understand the test pyramid, and balance test types for optimal coverage and efficiency.

---

## The Test Pyramid

```
           /\
          /  \
         / E2E \      <- Few: Slow, expensive, high confidence
        /------\
       /        \
      /Integration\   <- Some: Medium speed, moderate confidence
     /------------\
    /              \
   /   Unit Tests   \  <- Many: Fast, cheap, focused confidence
  /------------------\
```

**Principle:** Most tests should be unit tests (fast, focused), fewer integration tests (medium speed), and very few E2E tests (slow, expensive).

### Ideal Distribution

- **70% Unit Tests** - Fast, isolated, many scenarios
- **20% Integration Tests** - API + Database, key workflows
- **10% E2E Tests** - Critical user journeys only

---

## When to Use Each Test Type

### Unit Tests

**Use when testing:**
- Pure functions (input → output, no side effects)
- Business logic calculations
- Validation rules
- Data transformations
- Utility functions
- Component rendering (React, Vue)

**Characteristics:**
- ✅ Very fast (<10ms per test)
- ✅ No external dependencies
- ✅ Easy to debug (small scope)
- ✅ Many scenarios easily tested
- ❌ Doesn't verify integration

**Example scenarios:**
```python
# Good for unit tests
def calculate_tax(amount, tax_rate):
    return amount * tax_rate

def validate_email(email):
    return re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)

def format_currency(amount):
    return f"${amount:,.2f}"
```

**When NOT to use:**
- Testing database queries → Use integration tests
- Testing API endpoints → Use integration tests
- Testing UI workflows → Use E2E tests
- Testing external service calls → Use integration tests with mocks

---

### Integration Tests

**Use when testing:**
- API endpoints with database
- Database queries and transactions
- Service-to-service communication
- Middleware chains
- Authentication flows
- File system operations
- Multi-component workflows

**Characteristics:**
- ✅ Verifies components work together
- ✅ Catches integration bugs
- ✅ Tests real database operations
- ⚠️ Slower than unit tests (100ms-1s per test)
- ⚠️ Requires test database/services
- ❌ Harder to debug than unit tests

**Example scenarios:**
```python
# Good for integration tests
def test_create_user_endpoint(client, db_session):
    """Test POST /users creates user in database."""
    response = client.post("/users", json={"email": "test@example.com"})
    assert response.status_code == 201

    # Verify database state
    user = db_session.query(User).filter_by(email="test@example.com").first()
    assert user is not None
```

**When NOT to use:**
- Testing pure business logic → Use unit tests
- Testing complete UI workflows → Use E2E tests
- Testing every edge case → Use unit tests (faster)

---

### E2E Tests

**Use when testing:**
- Critical user journeys (login, checkout, onboarding)
- Complete workflows across UI + API + Database
- Browser-specific behavior
- Visual regressions
- Accessibility

**Characteristics:**
- ✅ Highest confidence (tests real user experience)
- ✅ Catches integration + UI bugs
- ✅ Validates complete workflows
- ❌ Very slow (5-30s per test)
- ❌ Flaky (network, timing issues)
- ❌ Expensive to maintain
- ❌ Hard to debug

**Example scenarios:**
```javascript
// Good for E2E tests
test('user can complete checkout', async ({ page }) => {
  // 1. Add to cart
  await page.goto('/products/laptop');
  await page.click('[data-testid="add-to-cart"]');

  // 2. Proceed to checkout
  await page.click('[data-testid="checkout"]');

  // 3. Fill payment info
  await page.fill('[name="card-number"]', '4111111111111111');
  await page.click('[data-testid="place-order"]');

  // 4. Verify confirmation
  await expect(page).toHaveURL(/order-confirmation/);
});
```

**When NOT to use:**
- Testing edge cases → Use unit tests
- Testing API logic → Use integration tests
- Testing every scenario → Too slow and expensive

---

## Decision Tree: Which Test Type?

```
Start
  |
  ├─ Is this a complete user workflow? (login → checkout → confirmation)
  │    ├─ Yes → E2E Test
  │    └─ No ↓
  |
  ├─ Does it involve multiple systems? (API + Database + External service)
  │    ├─ Yes → Integration Test
  │    └─ No ↓
  |
  ├─ Is it pure logic or a single component?
  │    ├─ Yes → Unit Test
  │    └─ No ↓
  |
  └─ Does it require browser rendering?
       ├─ Yes → E2E Test or Component Test
       └─ No → Integration Test
```

---

## Test Coverage Strategy

### 1. Start with Unit Tests (70%)

**Test thoroughly at the unit level:**
- All business logic edge cases
- Error conditions
- Boundary values
- Invalid inputs

**Example:**
```python
# Unit tests cover all edge cases
def test_divide_by_zero_raises_error():
    with pytest.raises(ValueError):
        divide(10, 0)

def test_divide_positive_numbers():
    assert divide(10, 2) == 5

def test_divide_negative_numbers():
    assert divide(-10, 2) == -5

def test_divide_by_one():
    assert divide(10, 1) == 10
```

### 2. Add Integration Tests (20%)

**Test key integration points:**
- API endpoints (happy path + common errors)
- Database operations (CRUD + transactions)
- External service integrations (with mocks)

**Example:**
```python
# Integration tests cover main flows
def test_create_user_success(client):
    response = client.post("/users", json={"email": "test@example.com"})
    assert response.status_code == 201

def test_create_user_duplicate_email_fails(client):
    client.post("/users", json={"email": "test@example.com"})
    response = client.post("/users", json={"email": "test@example.com"})
    assert response.status_code == 409  # Conflict
```

### 3. Add E2E Tests (10%)

**Test only critical paths:**
- User registration → Login → Dashboard
- Product search → Add to cart → Checkout → Confirmation
- Create post → Edit post → Delete post

**Example:**
```javascript
// E2E tests cover critical journeys only
test('complete user onboarding', async ({ page }) => {
  await page.goto('/register');
  // ... registration flow
  await page.goto('/onboarding');
  // ... onboarding flow
  await expect(page).toHaveURL('/dashboard');
});
```

---

## Testing Different Application Layers

### Frontend (React, Vue, Angular)

**Component Tests (Unit):**
```javascript
// Test component logic, not implementation
it('should display error when form is invalid', () => {
  render(<LoginForm />);
  userEvent.click(screen.getByText('Submit'));
  expect(screen.getByText('Email is required')).toBeInTheDocument();
});
```

**Integration Tests:**
```javascript
// Test component + API integration
it('should load and display user data', async () => {
  render(<UserProfile userId={1} />);
  await waitFor(() => {
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });
});
```

**E2E Tests:**
```javascript
// Test complete user flow
test('user can update profile', async ({ page }) => {
  await page.goto('/profile');
  await page.fill('[name="bio"]', 'New bio');
  await page.click('[data-testid="save"]');
  await expect(page.locator('.success')).toBeVisible();
});
```

### Backend (APIs, Services)

**Unit Tests:**
```python
# Test business logic
def test_calculate_discount():
    assert calculate_discount(100, 0.1) == 10
```

**Integration Tests:**
```python
# Test API + Database
def test_get_user_endpoint(client, db_session):
    user = create_user(db_session)
    response = client.get(f"/users/{user.id}")
    assert response.status_code == 200
```

**E2E Tests:**
```python
# Test complete API workflow
def test_user_registration_workflow(client):
    # Register
    response = client.post("/auth/register", json={...})
    # Verify email
    response = client.post("/auth/verify", json={...})
    # Login
    response = client.post("/auth/login", json={...})
    assert "access_token" in response.json()
```

### Database Layer

**Unit Tests:**
```python
# Test repository methods (with in-memory DB)
def test_user_repository_find_by_email(db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    db_session.commit()

    found = UserRepository(db_session).find_by_email("test@example.com")
    assert found.email == "test@example.com"
```

**Integration Tests:**
```python
# Test database queries with real database
def test_complex_query_returns_correct_results(db_session):
    # Seed data
    create_users(db_session, count=10)

    # Query
    results = db_session.query(User).filter(User.active == True).all()

    # Verify
    assert len(results) == 8
```

---

## Special Testing Scenarios

### Testing Error Conditions

**Prefer unit tests:**
```python
# Fast, focused error testing
def test_invalid_email_raises_error():
    with pytest.raises(ValueError, match="Invalid email"):
        create_user(email="not-an-email")

def test_negative_amount_raises_error():
    with pytest.raises(ValueError):
        charge_payment(amount=-100)
```

### Testing External Services

**Use integration tests with mocks:**
```python
# Mock external service
def test_payment_gateway_success(mock_stripe):
    mock_stripe.charge.return_value = {"id": "ch_123", "status": "success"}

    result = process_payment(amount=100)

    assert result["status"] == "success"
    mock_stripe.charge.assert_called_once()
```

### Testing Authentication

**Combination of all levels:**
```python
# Unit: Test token generation
def test_generate_jwt_token():
    token = generate_token(user_id=1)
    assert decode_token(token)["user_id"] == 1

# Integration: Test login endpoint
def test_login_endpoint(client):
    response = client.post("/auth/login", json={...})
    assert response.status_code == 200
    assert "access_token" in response.json()

# E2E: Test complete auth flow
test('user can login and access protected page', async ({ page }) => {
  await loginPage.login('user@example.com', 'password');
  await page.goto('/dashboard');
  await expect(page).toHaveURL('/dashboard');
});
```

---

## Test Optimization Strategies

### 1. Test Isolation

**Good:**
```python
# Each test is independent
@pytest.fixture
def user(db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    db_session.commit()
    return user

def test_update_user(user, db_session):
    user.name = "Updated"
    db_session.commit()
    assert user.name == "Updated"
```

**Bad:**
```python
# Tests depend on order
user = None

def test_create_user():
    global user
    user = create_user()

def test_update_user():
    # Fails if test_create_user doesn't run first
    user.name = "Updated"
```

### 2. Test Performance

**Unit tests:**
- Target: <10ms per test
- Use in-memory databases (SQLite)
- Mock external dependencies
- Avoid file I/O

**Integration tests:**
- Target: <1s per test
- Use test database (PostgreSQL/MySQL with test schema)
- Rollback transactions after each test
- Minimize network calls

**E2E tests:**
- Target: <30s per test
- Run critical paths only (5-10 tests max)
- Use parallel execution
- Consider visual regression testing separately

### 3. Flaky Test Management

**Identify causes:**
- Race conditions → Add proper waits
- Shared state → Isolate tests
- External dependencies → Mock or use test doubles
- Timing issues → Use deterministic waits, not timeouts

**Example fix:**
```javascript
// BAD - Flaky
await page.click('[data-testid="submit"]');
await page.waitForTimeout(1000); // Arbitrary wait
expect(page.locator('.success')).toBeVisible();

// GOOD - Reliable
await page.click('[data-testid="submit"]');
await page.waitForSelector('.success', { state: 'visible' }); // Wait for element
expect(page.locator('.success')).toBeVisible();
```

---

## Testing Checklist by Feature

When adding a new feature, ensure:

**Unit Tests:**
- [ ] All business logic functions tested
- [ ] Edge cases covered (null, empty, boundary values)
- [ ] Error conditions tested
- [ ] Validation rules tested

**Integration Tests:**
- [ ] API endpoints tested (happy path)
- [ ] Database operations tested (CRUD)
- [ ] Common error responses tested (400, 404, 500)
- [ ] Authentication/authorization tested

**E2E Tests:**
- [ ] Critical user journey tested (if applicable)
- [ ] Visual feedback tested (success/error messages)

---

## Anti-Patterns to Avoid

### ❌ Testing Everything with E2E Tests

**Problem:** Slow, flaky, hard to maintain
**Solution:** Use test pyramid (70% unit, 20% integration, 10% E2E)

### ❌ No Integration Tests

**Problem:** Unit tests pass, but app fails in production
**Solution:** Add integration tests for API + database interactions

### ❌ Overmocking

**Problem:** Tests pass but app doesn't work
**Solution:** Mock external dependencies only, test real integrations

### ❌ Testing Implementation Details

**Problem:** Tests break on refactoring
**Solution:** Test observable behavior, not internal implementation

---

## Quick Reference

| Scenario | Test Type | Reason |
|----------|-----------|---------|
| Pure function | Unit | Fast, isolated |
| Business logic | Unit | Fast, many scenarios |
| API endpoint | Integration | Tests API + DB |
| Database query | Integration | Tests real DB |
| External service | Integration (mocked) | Fast + controlled |
| Complete user flow | E2E | High confidence |
| Browser rendering | E2E or Component | Visual validation |
| Error handling | Unit | Fast, many cases |
| Authentication | All levels | Critical feature |

---

## Related References

- **test-naming-conventions.md** - Clear test names for all types
- **mocking-patterns.md** - When and how to mock
- **test-maintenance.md** - Maintaining tests as codebase grows
- **tdd-workflow.md** - Test-driven development process
