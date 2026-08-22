# Unit Test Template

## Overview

Unit tests verify individual functions, methods, or classes in isolation. They should be fast, deterministic, and focused on a single unit of behavior.

**Use this template when:**
- Testing pure functions or methods
- Verifying business logic
- Testing component behavior in isolation
- Building test-driven development (TDD) workflows

---

## Template Structure

### Basic Unit Test (Arrange-Act-Assert)

```python
# Python (pytest)
import pytest
from module_name import function_to_test

def test_function_name_behavior_expected_outcome():
    """Test that function_name does X when Y."""
    # Arrange - Set up test data and dependencies
    input_data = "test_value"
    expected_output = "expected_value"

    # Act - Execute the function being tested
    actual_output = function_to_test(input_data)

    # Assert - Verify the outcome
    assert actual_output == expected_output
```

```javascript
// JavaScript (Jest/Vitest)
import { describe, it, expect } from 'vitest';
import { functionToTest } from './module';

describe('functionToTest', () => {
  it('should return expected outcome when given valid input', () => {
    // Arrange
    const inputData = 'test_value';
    const expectedOutput = 'expected_value';

    // Act
    const actualOutput = functionToTest(inputData);

    // Assert
    expect(actualOutput).toBe(expectedOutput);
  });
});
```

---

## Common Patterns

### 1. Testing with Multiple Scenarios (Parameterized Tests)

```python
# Python
@pytest.mark.parametrize("input_value,expected_output", [
    ("lowercase", "LOWERCASE"),
    ("UPPERCASE", "UPPERCASE"),
    ("MixedCase", "MIXEDCASE"),
    ("", ""),
])
def test_to_uppercase_various_inputs(input_value, expected_output):
    """Test to_uppercase with various input cases."""
    assert to_uppercase(input_value) == expected_output
```

```javascript
// JavaScript
describe.each([
  ['lowercase', 'LOWERCASE'],
  ['UPPERCASE', 'UPPERCASE'],
  ['MixedCase', 'MIXEDCASE'],
  ['', ''],
])('toUppercase(%s)', (input, expected) => {
  it(`should return ${expected}`, () => {
    expect(toUppercase(input)).toBe(expected);
  });
});
```

### 2. Testing Error Conditions

```python
# Python
def test_divide_raises_error_on_zero_division():
    """Test that divide raises ValueError when dividing by zero."""
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)
```

```javascript
// JavaScript
it('should throw error when dividing by zero', () => {
  expect(() => divide(10, 0)).toThrow('Cannot divide by zero');
});
```

### 3. Testing with Mocks (Dependencies Isolated)

```python
# Python
from unittest.mock import Mock, patch

def test_user_service_calls_database(mocker):
    """Test that UserService.get_user calls database with correct ID."""
    # Arrange
    mock_db = mocker.Mock()
    mock_db.query.return_value = {"id": 1, "name": "Alice"}
    service = UserService(db=mock_db)

    # Act
    result = service.get_user(user_id=1)

    # Assert
    mock_db.query.assert_called_once_with("SELECT * FROM users WHERE id = ?", 1)
    assert result["name"] == "Alice"
```

```javascript
// JavaScript
import { vi } from 'vitest';

it('should call database with correct user ID', () => {
  // Arrange
  const mockDb = {
    query: vi.fn().mockResolvedValue({ id: 1, name: 'Alice' })
  };
  const service = new UserService(mockDb);

  // Act
  const result = await service.getUser(1);

  // Assert
  expect(mockDb.query).toHaveBeenCalledWith('SELECT * FROM users WHERE id = ?', 1);
  expect(result.name).toBe('Alice');
});
```

### 4. Testing Async Functions

```python
# Python
@pytest.mark.asyncio
async def test_async_fetch_data_returns_json():
    """Test that async_fetch_data returns parsed JSON."""
    # Arrange
    url = "https://api.example.com/data"
    expected_data = {"key": "value"}

    # Act
    result = await async_fetch_data(url)

    # Assert
    assert result == expected_data
```

```javascript
// JavaScript
it('should fetch and parse JSON data', async () => {
  // Arrange
  const url = 'https://api.example.com/data';
  const expectedData = { key: 'value' };

  // Act
  const result = await fetchData(url);

  // Assert
  expect(result).toEqual(expectedData);
});
```

### 5. Testing Class Methods

```python
# Python
class TestCalculator:
    """Test suite for Calculator class."""

    def setup_method(self):
        """Set up test fixtures before each test."""
        self.calculator = Calculator()

    def test_add_positive_numbers(self):
        """Test adding two positive numbers."""
        result = self.calculator.add(2, 3)
        assert result == 5

    def test_add_negative_numbers(self):
        """Test adding two negative numbers."""
        result = self.calculator.add(-2, -3)
        assert result == -5
```

```javascript
// JavaScript
describe('Calculator', () => {
  let calculator;

  beforeEach(() => {
    calculator = new Calculator();
  });

  it('should add two positive numbers', () => {
    const result = calculator.add(2, 3);
    expect(result).toBe(5);
  });

  it('should add two negative numbers', () => {
    const result = calculator.add(-2, -3);
    expect(result).toBe(-5);
  });
});
```

### 6. Testing React Components

```javascript
// JavaScript (React Testing Library)
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Button from './Button';

describe('Button', () => {
  it('should call onClick handler when clicked', async () => {
    // Arrange
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click Me</Button>);

    // Act
    await userEvent.click(screen.getByText('Click Me'));

    // Assert
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should display loading state when isLoading is true', () => {
    // Arrange & Act
    render(<Button isLoading={true}>Submit</Button>);

    // Assert
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    expect(screen.queryByText('Submit')).not.toBeInTheDocument();
  });
});
```

---

## Best Practices Checklist

- [ ] **Test is independent** - Does not rely on other tests or external state
- [ ] **Test is deterministic** - Always produces same result with same input
- [ ] **Test is fast** - Runs in milliseconds, not seconds
- [ ] **Test name is descriptive** - Follows pattern: `test_<unit>_<behavior>_<expected_outcome>`
- [ ] **One assertion focus** - Each test verifies one specific behavior
- [ ] **Minimal mocking** - Only mock external dependencies, not the unit under test
- [ ] **Clear AAA structure** - Arrange, Act, Assert sections are obvious
- [ ] **Edge cases covered** - Tests null, empty, boundary values
- [ ] **Error conditions tested** - Verifies exceptions are raised correctly
- [ ] **Setup/teardown used** - Shared fixtures extracted to setup methods

---

## Common Assertions

### Python (pytest)

```python
# Equality
assert result == expected
assert result != unexpected

# Truthiness
assert result is True
assert result is False
assert result is None

# Containment
assert item in collection
assert item not in collection

# Type checking
assert isinstance(result, ExpectedClass)

# Exceptions
with pytest.raises(ValueError):
    function_that_should_raise()

# Approximate equality (floats)
assert result == pytest.approx(3.14159, abs=0.001)
```

### JavaScript (Jest/Vitest)

```javascript
// Equality
expect(result).toBe(expected);          // Strict equality (===)
expect(result).toEqual(expected);       // Deep equality (objects/arrays)
expect(result).not.toBe(unexpected);

// Truthiness
expect(result).toBeTruthy();
expect(result).toBeFalsy();
expect(result).toBeNull();
expect(result).toBeUndefined();

// Numbers
expect(result).toBeGreaterThan(5);
expect(result).toBeLessThanOrEqual(10);
expect(result).toBeCloseTo(3.14159, 2); // Precision digits

// Strings
expect(result).toMatch(/pattern/);
expect(result).toContain('substring');

// Arrays/Objects
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key', 'value');

// Functions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith(arg1, arg2);
expect(mockFn).toHaveBeenCalledTimes(3);

// Async
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow(Error);
```

---

## Testing Anti-Patterns to Avoid

### ❌ Testing Implementation Details

```javascript
// BAD - Tests how it works, not what it does
it('should call internal _calculateTax method', () => {
  const spy = vi.spyOn(service, '_calculateTax');
  service.getTotal(100);
  expect(spy).toHaveBeenCalled();
});

// GOOD - Tests observable behavior
it('should include tax in total price', () => {
  const total = service.getTotal(100);
  expect(total).toBe(110); // 10% tax assumed
});
```

### ❌ Multiple Unrelated Assertions

```javascript
// BAD - Testing multiple behaviors
it('should handle user operations', () => {
  expect(service.createUser()).toBeDefined();
  expect(service.deleteUser()).toBe(true);
  expect(service.updateUser()).toThrow();
});

// GOOD - One behavior per test
it('should create user successfully', () => {
  expect(service.createUser()).toBeDefined();
});

it('should delete existing user', () => {
  expect(service.deleteUser()).toBe(true);
});
```

### ❌ Shared Mutable State

```python
# BAD - Tests can affect each other
calculator = Calculator()  # Shared across tests

def test_addition():
    calculator.add(2, 3)  # State persists

def test_subtraction():
    # This test may fail if addition test runs first
    calculator.subtract(5, 2)

# GOOD - Isolated state
@pytest.fixture
def calculator():
    return Calculator()

def test_addition(calculator):
    calculator.add(2, 3)

def test_subtraction(calculator):
    calculator.subtract(5, 2)  # Fresh instance
```

---

## Quick Reference

| Framework | Run Tests | Run with Coverage | Watch Mode |
|-----------|-----------|------------------|------------|
| pytest    | `pytest` | `pytest --cov` | `pytest-watch` |
| Jest      | `npm test` | `npm test -- --coverage` | `npm test -- --watch` |
| Vitest    | `vitest run` | `vitest run --coverage` | `vitest` |

---

## Related Templates

- **integration-test-template.md** - For testing multiple components together
- **e2e-test-template.md** - For testing complete user workflows
- **test-data-template.md** - For creating test fixtures and factories
- **mocking-patterns.md** - Deep dive on test doubles and mocking strategies
