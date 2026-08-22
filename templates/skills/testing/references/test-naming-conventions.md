# Test Naming Conventions Reference Guide

## Overview

Well-named tests serve as living documentation and make test failures immediately understandable. This guide provides patterns for clear, descriptive test names across different testing frameworks.

---

## Core Naming Principle

**Pattern:** `test_<unit>_<behavior>_<expected_outcome>`

**Examples:**
```python
# Good - Clear and descriptive
def test_divide_by_zero_raises_value_error()
def test_get_user_by_id_returns_user_when_exists()
def test_create_user_with_duplicate_email_returns_409()

# Bad - Vague or unclear
def test_divide()
def test_user()
def test_1()
```

---

## Naming Patterns by Test Type

### Unit Tests

**Format:** `test_<function_or_method>_<scenario>_<expected_result>`

```python
# Python
def test_calculate_tax_with_valid_rate_returns_correct_amount()
def test_validate_email_with_invalid_format_returns_false()
def test_format_currency_with_negative_amount_adds_minus_sign()
```

```javascript
// JavaScript
describe('calculateTax', () => {
  it('should return correct amount with valid rate', () => { });
  it('should throw error when rate is negative', () => { });
  it('should return zero when amount is zero', () => { });
});
```

### Integration Tests

**Format:** `test_<endpoint_or_integration>_<scenario>_<expected_result>`

```python
# Python - API integration
def test_post_users_with_valid_data_creates_user_and_returns_201()
def test_get_user_with_nonexistent_id_returns_404()
def test_put_user_with_duplicate_email_returns_409()

# Python - Database integration
def test_user_repository_find_by_email_returns_user_when_exists()
def test_user_repository_find_by_email_returns_none_when_not_found()
```

```javascript
// JavaScript - API integration
describe('POST /users', () => {
  it('should create user and return 201 with valid data', async () => { });
  it('should return 422 when email is invalid', async () => { });
  it('should return 409 when email already exists', async () => { });
});
```

### E2E Tests

**Format:** `test_<user_action>_<expected_outcome>` or describe user journey

```javascript
// Playwright
describe('User Authentication', () => {
  it('should allow user to login with valid credentials', async ({ page }) => { });
  it('should display error message with invalid credentials', async ({ page }) => { });
  it('should redirect to dashboard after successful login', async ({ page }) => { });
});

describe('Checkout Flow', () => {
  it('should complete checkout process from cart to confirmation', async ({ page }) => { });
  it('should validate payment details before processing', async ({ page }) => { });
});
```

```python
# Python - E2E
def test_user_can_register_verify_email_and_login()
def test_user_can_add_item_to_cart_and_complete_checkout()
def test_admin_can_delete_user_and_related_data()
```

---

## Naming Conventions by Framework

### pytest (Python)

**Format:** `test_<unit>_<scenario>_<expected>`

```python
# Functions
def test_add_positive_numbers_returns_sum()
def test_add_with_zero_returns_same_number()
def test_add_negative_numbers_returns_negative_sum()

# Classes (group related tests)
class TestCalculator:
    """Test suite for Calculator class."""

    def test_add_returns_correct_sum(self):
        pass

    def test_subtract_returns_correct_difference(self):
        pass

    def test_divide_by_zero_raises_value_error(self):
        pass
```

**Parameterized tests:**
```python
@pytest.mark.parametrize("input_val,expected", [
    (0, "zero"),
    (1, "one"),
    (2, "two"),
])
def test_number_to_word_converts_correctly(input_val, expected):
    """Test number_to_word with various inputs."""
    pass
```

### Jest/Vitest (JavaScript)

**Format:** Use `describe` for grouping, `it` for test cases

```javascript
// Clear hierarchy with describe blocks
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => { });
    it('should throw error when email is invalid', () => { });
    it('should hash password before storing', () => { });
  });

  describe('getUser', () => {
    it('should return user when ID exists', () => { });
    it('should return null when ID does not exist', () => { });
  });
});
```

**BDD-style naming:**
```javascript
describe('User authentication', () => {
  describe('when credentials are valid', () => {
    it('should return access token', () => { });
    it('should update last login timestamp', () => { });
  });

  describe('when credentials are invalid', () => {
    it('should return 401 status', () => { });
    it('should not return access token', () => { });
  });
});
```

### React Testing Library

**Format:** Focus on user behavior, not implementation

```javascript
describe('LoginForm', () => {
  it('should display error when submitted without email', () => { });
  it('should display error when email format is invalid', () => { });
  it('should call onSubmit handler when form is valid', () => { });
  it('should disable submit button while loading', () => { });
});

// Component state tests
describe('TodoList', () => {
  it('should add new todo when form is submitted', () => { });
  it('should toggle todo completion when clicked', () => { });
  it('should remove todo when delete button is clicked', () => { });
  it('should filter todos by status when filter is changed', () => { });
});
```

---

## Naming Patterns for Common Scenarios

### Testing Error Conditions

```python
# Pattern: test_<function>_<error_condition>_<expected_exception>
def test_divide_by_zero_raises_value_error()
def test_create_user_with_invalid_email_raises_validation_error()
def test_get_user_with_negative_id_raises_value_error()
```

```javascript
describe('Error conditions', () => {
  it('should throw error when dividing by zero', () => { });
  it('should throw ValidationError when email is invalid', () => { });
});
```

### Testing Edge Cases

```python
# Pattern: test_<function>_<edge_case>_<expected_result>
def test_sort_empty_list_returns_empty_list()
def test_find_in_single_element_list_returns_element()
def test_calculate_with_max_integer_does_not_overflow()
```

```javascript
describe('Edge cases', () => {
  it('should return empty array when input is empty', () => { });
  it('should handle single-element array correctly', () => { });
  it('should not overflow with maximum safe integer', () => { });
});
```

### Testing Boundary Values

```python
# Pattern: test_<function>_<boundary>_<expected>
def test_validate_age_with_minimum_value_returns_true()
def test_validate_age_with_maximum_value_returns_true()
def test_validate_age_below_minimum_returns_false()
def test_validate_age_above_maximum_returns_false()
```

### Testing State Changes

```javascript
describe('State changes', () => {
  it('should set loading to true when fetch starts', () => { });
  it('should set data when fetch succeeds', () => { });
  it('should set error when fetch fails', () => { });
  it('should set loading to false when fetch completes', () => { });
});
```

### Testing Asynchronous Operations

```python
@pytest.mark.asyncio
async def test_async_fetch_data_returns_json_when_successful()

@pytest.mark.asyncio
async def test_async_fetch_data_raises_timeout_error_when_slow()
```

```javascript
describe('Async operations', () => {
  it('should fetch and return data when request succeeds', async () => { });
  it('should throw error when request fails', async () => { });
  it('should timeout after 5 seconds', async () => { });
});
```

---

## BDD-Style Naming (Given-When-Then)

### Long Form (Cucumber-style)

```gherkin
# Feature files
Feature: User Authentication

  Scenario: Successful login with valid credentials
    Given a user with email "user@example.com" exists
    When the user submits the login form with correct password
    Then the user should be redirected to the dashboard
    And an access token should be returned

  Scenario: Failed login with invalid credentials
    Given a user with email "user@example.com" exists
    When the user submits the login form with incorrect password
    Then an error message should be displayed
    And the user should remain on the login page
```

### Short Form (in test descriptions)

```javascript
describe('User login', () => {
  describe('given valid credentials', () => {
    it('should redirect to dashboard when submitted', () => { });
    it('should store access token when successful', () => { });
  });

  describe('given invalid credentials', () => {
    it('should show error message when submitted', () => { });
    it('should not store access token when failed', () => { });
  });
});
```

---

## Test Naming Anti-Patterns

### ❌ Vague Names

```python
# BAD
def test_user()
def test_login()
def test_edge_case()

# GOOD
def test_create_user_with_valid_data_returns_201()
def test_login_with_invalid_credentials_returns_401()
def test_validate_email_with_empty_string_returns_false()
```

### ❌ Implementation Details

```javascript
// BAD - Exposes implementation
it('should call setState with user data', () => { });
it('should call private method _validate', () => { });

// GOOD - Focuses on behavior
it('should display user data when loaded', () => { });
it('should show error when data is invalid', () => { });
```

### ❌ Ambiguous Outcomes

```python
# BAD
def test_divide()  # What's the expected outcome?
def test_user_creation()  # Success or failure?

# GOOD
def test_divide_returns_quotient()
def test_create_user_with_duplicate_email_fails()
```

### ❌ Generic Numbers

```javascript
// BAD
it('test 1', () => { });
it('test 2', () => { });
it('scenario 3', () => { });

// GOOD
it('should validate email format', () => { });
it('should accept international phone numbers', () => { });
it('should reject empty input', () => { });
```

---

## Naming Checklist

Good test names should:

- [ ] **Be descriptive** - Explain what is being tested
- [ ] **Include the scenario** - What conditions or inputs
- [ ] **State the expected outcome** - What should happen
- [ ] **Use domain language** - Business terms, not technical jargon
- [ ] **Be readable as sentences** - Natural language flow
- [ ] **Avoid abbreviations** - Write out full words (unless very common)
- [ ] **Be specific** - Not vague or ambiguous
- [ ] **Focus on behavior** - Not implementation details

---

## Test Organization Patterns

### Group by Feature

```javascript
describe('User Management', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => { });
    it('should reject invalid email', () => { });
  });

  describe('updateUser', () => {
    it('should update user fields', () => { });
    it('should not allow email change', () => { });
  });

  describe('deleteUser', () => {
    it('should soft delete user', () => { });
    it('should delete related data', () => { });
  });
});
```

### Group by Scenario

```python
class TestPaymentProcessing:
    """Tests for payment processing workflows."""

    class TestSuccessfulPayment:
        """Tests for successful payment scenarios."""

        def test_credit_card_payment_succeeds(self):
            pass

        def test_debit_card_payment_succeeds(self):
            pass

    class TestFailedPayment:
        """Tests for failed payment scenarios."""

        def test_insufficient_funds_fails_gracefully(self):
            pass

        def test_expired_card_fails_with_error(self):
            pass
```

---

## File Naming Conventions

### Unit Tests

```
src/
  services/
    user-service.ts
tests/
  unit/
    services/
      user-service.test.ts       # Matches source file
      user-service.spec.ts       # Alternative
```

### Integration Tests

```
tests/
  integration/
    api/
      user-endpoints.test.ts
      auth-endpoints.test.ts
    database/
      user-repository.test.ts
```

### E2E Tests

```
tests/
  e2e/
    auth/
      login.spec.ts
      registration.spec.ts
    checkout/
      complete-purchase.spec.ts
```

---

## Quick Reference

| Pattern | Example | Use Case |
|---------|---------|----------|
| `test_<unit>_<scenario>_<expected>` | `test_divide_by_zero_raises_error` | Python unit tests |
| `describe/it` | `describe('User').it('should...')` | JavaScript tests |
| `should_<action>_<outcome>` | `should_return_user_when_found` | BDD-style |
| `given_when_then` | `given_valid_user_when_login_then_success` | BDD verbose |
| `<feature>_<scenario>` | `login_with_invalid_credentials` | Feature-focused |

---

## Related References

- **testing-strategies.md** - Choosing test types
- **unit-test-template.md** - Unit test examples with good names
- **integration-test-template.md** - Integration test naming examples
- **e2e-test-template.md** - E2E test naming patterns
