# TDD Workflow Reference Guide

## Overview

Test-Driven Development (TDD) is a development process where tests are written before the implementation code. This guide covers the TDD cycle, best practices, and practical workflows.

---

## The Red-Green-Refactor Cycle

```
1. RED     →  2. GREEN    →  3. REFACTOR  →  (repeat)
Write test     Make it pass     Improve code
that fails     (simplest way)   (keep tests green)
```

### 1. RED: Write a Failing Test

**Goal:** Define expected behavior before implementation.

```python
# Step 1: Write test that fails
def test_calculate_tax_returns_correct_amount():
    """Test that calculate_tax computes 10% tax correctly."""
    result = calculate_tax(amount=100, rate=0.10)
    assert result == 10.0  # ❌ FAILS - Function doesn't exist yet
```

**Why it fails:** Function not implemented yet.

### 2. GREEN: Make the Test Pass

**Goal:** Write simplest code to make test pass.

```python
# Step 2: Implement minimal code to pass
def calculate_tax(amount, rate):
    """Calculate tax amount."""
    return amount * rate  # ✅ PASSES

# Run test
# test_calculate_tax_returns_correct_amount ... PASSED
```

**Focus:** Get to green quickly, don't over-engineer.

### 3. REFACTOR: Improve the Code

**Goal:** Clean up code while keeping tests green.

```python
# Step 3: Refactor for clarity (tests still pass)
def calculate_tax(amount: float, rate: float) -> float:
    """
    Calculate tax amount.

    Args:
        amount: Base amount
        rate: Tax rate (e.g., 0.10 for 10%)

    Returns:
        Tax amount
    """
    if amount < 0:
        raise ValueError("Amount must be non-negative")
    if not 0 <= rate <= 1:
        raise ValueError("Rate must be between 0 and 1")

    return round(amount * rate, 2)  # ✅ Still PASSES
```

**Benefits:** Better readability, type hints, validation, precision.

---

## TDD Workflow Steps

### Full Cycle Example

```python
# Iteration 1: Basic functionality
# RED
def test_add_positive_numbers():
    assert add(2, 3) == 5  # ❌ FAILS

# GREEN
def add(a, b):
    return a + b  # ✅ PASSES

# Iteration 2: Handle edge case
# RED
def test_add_zero_returns_same_number():
    assert add(5, 0) == 5  # ✅ Already passes (good implementation)

# Iteration 3: Handle negative numbers
# RED
def test_add_negative_numbers():
    assert add(-2, -3) == -5  # ✅ Already passes

# Iteration 4: Validation
# RED
def test_add_non_numbers_raises_error():
    with pytest.raises(TypeError):
        add("a", "b")  # ❌ FAILS

# GREEN
def add(a, b):
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("Arguments must be numbers")
    return a + b  # ✅ PASSES

# REFACTOR
def add(a: Union[int, float], b: Union[int, float]) -> Union[int, float]:
    """Add two numbers."""
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("Arguments must be numbers")
    return a + b
```

---

## TDD Best Practices

### 1. Start with the Simplest Test

```python
# Good - Start simple
def test_empty_list_has_length_zero():
    assert len([]) == 0

# Bad - Start complex
def test_complex_filtering_sorting_and_grouping():
    # Too much to implement at once
    pass
```

### 2. One Test at a Time

```python
# Good - Focus on one behavior
def test_user_creation_sets_email():
    user = User(email="test@example.com")
    assert user.email == "test@example.com"

def test_user_creation_sets_active_to_true():
    user = User(email="test@example.com")
    assert user.active is True

# Bad - Testing multiple things
def test_user_creation():
    user = User(email="test@example.com")
    assert user.email == "test@example.com"
    assert user.active is True
    assert user.created_at is not None
    # ... 10 more assertions
```

### 3. Test Behavior, Not Implementation

```python
# Good - Test behavior
def test_user_service_sends_welcome_email():
    service = UserService()
    service.register_user("test@example.com")
    # Verify email was sent (behavior)
    assert email_sent_to("test@example.com")

# Bad - Test implementation
def test_user_service_calls_send_email_method():
    service = UserService()
    spy = Mock(wraps=service._send_email)
    service.register_user("test@example.com")
    # Verifies internal method call (implementation)
    spy.assert_called_once()
```

### 4. Don't Skip the Refactor Step

```python
# After GREEN, always REFACTOR
def calculate_discount(price, is_premium, is_holiday, quantity):
    # Initial implementation (GREEN)
    if is_premium:
        if is_holiday:
            if quantity > 10:
                return price * 0.3
            else:
                return price * 0.2
        else:
            return price * 0.1
    else:
        return 0

# REFACTOR for clarity
def calculate_discount(price, is_premium, is_holiday, quantity):
    """Calculate discount based on membership and purchase details."""
    if not is_premium:
        return 0

    base_discount = 0.1
    if is_holiday:
        base_discount = 0.2
    if quantity > 10:
        base_discount += 0.1

    return price * base_discount
```

### 5. Keep Tests Fast

```python
# Good - Fast unit test
def test_calculate_tax():
    result = calculate_tax(100, 0.1)
    assert result == 10.0  # <10ms

# Bad - Slow test in TDD cycle
def test_calculate_tax():
    db = create_real_database()  # Slow!
    user = create_user(db)
    result = calculate_tax_for_user(user)  # 500ms - too slow for TDD
```

---

## TDD Patterns

### 1. Fake It Till You Make It

Start with hard-coded values, then generalize.

```python
# Iteration 1: Fake it
def test_get_greeting_returns_hello():
    assert get_greeting() == "Hello"

def get_greeting():
    return "Hello"  # Hard-coded

# Iteration 2: Add parameter
def test_get_greeting_with_name():
    assert get_greeting("Alice") == "Hello, Alice"

def get_greeting(name="World"):
    return f"Hello, {name}"  # Generalized
```

### 2. Triangulation

Use multiple test cases to guide towards general solution.

```python
# Test 1
def test_fibonacci_0_returns_0():
    assert fibonacci(0) == 0

# Test 2
def test_fibonacci_1_returns_1():
    assert fibonacci(1) == 1

# Test 3
def test_fibonacci_2_returns_1():
    assert fibonacci(2) == 1

# Test 4
def test_fibonacci_5_returns_5():
    assert fibonacci(5) == 5

# General implementation emerges
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

### 3. Obvious Implementation

When solution is obvious, implement directly.

```python
# Test
def test_square_returns_number_multiplied_by_itself():
    assert square(4) == 16

# Obvious implementation (no need to fake it)
def square(n):
    return n * n
```

---

## TDD for Different Scenarios

### API Endpoint Development

```python
# Test 1: Basic endpoint exists
def test_get_users_endpoint_exists(client):
    response = client.get("/users")
    assert response.status_code != 404  # ❌ FAILS

# Implementation
@app.get("/users")
def get_users():
    return []  # ✅ PASSES

# Test 2: Returns list of users
def test_get_users_returns_list(client):
    response = client.get("/users")
    assert isinstance(response.json(), list)  # ✅ Already passes

# Test 3: Returns user data
def test_get_users_returns_user_data(client, db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    db_session.commit()

    response = client.get("/users")
    assert len(response.json()) == 1  # ❌ FAILS
    assert response.json()[0]["email"] == "test@example.com"

# Implementation
@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return [{"id": u.id, "email": u.email} for u in users]  # ✅ PASSES
```

### Frontend Component Development

```javascript
// Test 1: Component renders
it('should render without crashing', () => {
  render(<LoginForm />);  // ❌ FAILS - component doesn't exist
});

// Implementation
function LoginForm() {
  return <div>Login</div>;  // ✅ PASSES
}

// Test 2: Shows email input
it('should display email input', () => {
  render(<LoginForm />);
  expect(screen.getByLabelText('Email')).toBeInTheDocument();  // ❌ FAILS
});

// Implementation
function LoginForm() {
  return (
    <div>
      <label htmlFor="email">Email</label>
      <input id="email" type="email" />
    </div>
  );  // ✅ PASSES
}

// Test 3: Validates email on submit
it('should show error when email is invalid', async () => {
  render(<LoginForm />);
  const submitButton = screen.getByText('Submit');
  await userEvent.click(submitButton);
  expect(screen.getByText('Email is required')).toBeInTheDocument();  // ❌ FAILS
});

// Implementation (simplified)
function LoginForm() {
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    const email = e.target.email.value;
    if (!email) {
      setError('Email is required');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="email">Email</label>
      <input id="email" type="email" />
      <button type="submit">Submit</button>
      {error && <div>{error}</div>}
    </form>
  );  // ✅ PASSES
}
```

---

## TDD with Legacy Code

### 1. Characterization Tests

Write tests that describe current behavior before changing.

```python
# Existing function (unclear behavior)
def process_order(order):
    # Complex legacy code
    pass

# Characterization test
def test_process_order_current_behavior():
    """Document current behavior before refactoring."""
    order = {"items": [{"id": 1, "qty": 2}], "total": 100}
    result = process_order(order)

    # Assert current behavior (even if wrong)
    assert result["status"] == "processed"
    assert result["total"] == 100
    # Now safe to refactor!
```

### 2. Add Tests Around the Change

```python
# Before changing legacy code, add test
def test_new_feature_integration_with_legacy_code():
    result = legacy_function(new_input)
    assert result.new_field == expected_value  # ❌ FAILS

# Modify legacy code minimally
def legacy_function(input):
    # ... existing logic
    if hasattr(input, 'new_field'):
        return handle_new_feature(input)  # ✅ PASSES
    # ... existing logic
```

---

## Common TDD Mistakes

### ❌ Writing Too Much Code Before Testing

```python
# BAD - Wrote entire feature without test
def create_user(email, name, role, permissions, preferences):
    # 100 lines of code
    pass

# GOOD - Test-drive small pieces
def test_create_user_sets_email():
    user = create_user(email="test@example.com")
    assert user.email == "test@example.com"
```

### ❌ Not Running Tests Frequently

```python
# BAD - Write 10 tests, then run all
def test_1(): pass
def test_2(): pass
# ... (write all tests)
# Run tests  # Many failures, hard to debug

# GOOD - Run after each test
def test_1(): pass  # ❌ FAIL → implement → ✅ PASS
def test_2(): pass  # ❌ FAIL → implement → ✅ PASS
```

### ❌ Skipping Refactoring

```python
# BAD - Leave code messy
def calculate(a, b, c, d, e):
    if c:
        if d:
            return a + b
        else:
            return a - b
    # ... complex nested logic

# GOOD - Refactor after green
def calculate(a, b, operation, apply_discount, discount_rate):
    """Calculate result based on operation."""
    result = apply_operation(a, b, operation)
    if apply_discount:
        result = apply_discount(result, discount_rate)
    return result
```

---

## TDD Workflow Checklist

For each feature:

- [ ] Write failing test (RED)
- [ ] Run test to confirm it fails
- [ ] Write minimal code to pass (GREEN)
- [ ] Run test to confirm it passes
- [ ] Refactor code (keep tests green)
- [ ] Run tests to confirm still passing
- [ ] Commit (RED → GREEN → REFACTOR cycle complete)

---

## Quick Reference

| Phase | Goal | Time | Focus |
|-------|------|------|-------|
| **RED** | Define behavior | 1-2 min | What should it do? |
| **GREEN** | Make it work | 2-5 min | Simplest implementation |
| **REFACTOR** | Make it clean | 3-10 min | Improve design |

**Cycle Time:** 5-15 minutes per iteration

---

## Related References

- **unit-test-template.md** - Writing unit tests for TDD
- **testing-strategies.md** - When to use TDD vs other approaches
- **test-naming-conventions.md** - Clear test names for TDD
- **test-maintenance.md** - Maintaining test suites over time
