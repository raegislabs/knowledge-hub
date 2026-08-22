# Regression Test Template

## Overview
This template provides a structure for creating regression tests that prevent bugs from reoccurring.

---

## Python Regression Test (pytest)

```python
"""
Regression test for bug: {BUG-ID}

Ensures that {brief description of what bug caused} is handled correctly.

Related issue: {Link to issue tracker}
Fixed in: {Commit SHA or version}
"""

import pytest
from {module} import {function_under_test}


def test_bug_{bug_id}_{descriptive_name}():
    """
    Test that {specific condition} doesn't cause {specific failure}.

    This was the root cause of bug {BUG-ID}.

    Background:
    {Brief explanation of what the bug was}
    """
    # Arrange
    {setup_data} = {value_that_triggered_bug}

    # Act
    result = {function_under_test}({setup_data})

    # Assert
    assert {expected_condition}, "{failure_message}"


def test_bug_{bug_id}_edge_case_1():
    """
    Test edge case: {description of edge case}
    """
    # Arrange
    edge_case_data = {value}

    # Act
    result = {function_under_test}(edge_case_data)

    # Assert
    assert {condition}


def test_bug_{bug_id}_edge_case_2():
    """
    Test edge case: {description of edge case}
    """
    # Arrange
    edge_case_data = {value}

    # Act
    result = {function_under_test}(edge_case_data)

    # Assert
    assert {condition}


def test_bug_{bug_id}_normal_case_still_works():
    """
    Verify that the fix doesn't break normal operation.

    Tests the happy path to ensure no regression in standard behavior.
    """
    # Arrange
    valid_data = {normal_input}

    # Act
    result = {function_under_test}(valid_data)

    # Assert
    assert {expected_behavior}
    assert {additional_check}


@pytest.mark.parametrize("input_data,expected", [
    (None, {expected_for_none}),
    ([], {expected_for_empty_list}),
    ({}, {expected_for_empty_dict}),
    ("", {expected_for_empty_string}),
    ({boundary_value}, {expected_output}),
])
def test_bug_{bug_id}_parametrized_cases(input_data, expected):
    """
    Test various input scenarios that could trigger the bug.

    Parametrized test ensures all edge cases are covered.
    """
    # Act
    result = {function_under_test}(input_data)

    # Assert
    assert result == expected


def test_bug_{bug_id}_error_handling():
    """
    Test that appropriate errors are raised for invalid input.

    The original bug silently failed; ensure we now raise proper exceptions.
    """
    # Arrange
    invalid_data = {value_that_should_fail}

    # Act & Assert
    with pytest.raises({ExpectedError}, match="{error_message_pattern}"):
        {function_under_test}(invalid_data)


@pytest.fixture
def setup_for_bug_{bug_id}():
    """
    Setup fixture for bug {BUG-ID} tests.

    Creates necessary test data and environment.
    """
    # Setup
    {setup_code}

    yield {test_data}

    # Teardown
    {cleanup_code}


def test_bug_{bug_id}_with_fixture(setup_for_bug_{bug_id}):
    """
    Test using fixture for complex setup.
    """
    # Arrange
    data = setup_for_bug_{bug_id}

    # Act
    result = {function_under_test}(data)

    # Assert
    assert {condition}
```

---

## JavaScript Regression Test (Jest)

```javascript
/**
 * Regression test for bug: {BUG-ID}
 *
 * Ensures that {brief description of what bug caused} is handled correctly.
 *
 * @see {Link to issue tracker}
 * @see {Link to fix commit}
 */

import { functionUnderTest } from './module';

describe('Bug {BUG-ID}: {Descriptive name}', () => {
  test('should handle {specific condition} without {failure}', () => {
    // Arrange
    const inputData = {value_that_triggered_bug};

    // Act
    const result = functionUnderTest(inputData);

    // Assert
    expect(result).toBe({expected_value});
  });

  test('should handle edge case: null input', () => {
    // Arrange
    const inputData = null;

    // Act
    const result = functionUnderTest(inputData);

    // Assert
    expect(result).toBeNull(); // or appropriate expectation
  });

  test('should handle edge case: empty array', () => {
    // Arrange
    const inputData = [];

    // Act
    const result = functionUnderTest(inputData);

    // Assert
    expect(result).toEqual([]);
  });

  test('should not break normal operation', () => {
    // Arrange
    const validData = {normal_input};

    // Act
    const result = functionUnderTest(validData);

    // Assert
    expect(result).toBeDefined();
    expect(result).toHaveProperty({property});
  });

  test.each([
    [null, {expected}],
    [[], {expected}],
    [{}, {expected}],
    ['', {expected}],
    [{edge_case}, {expected}],
  ])('should handle input %p correctly', (input, expected) => {
    // Act
    const result = functionUnderTest(input);

    // Assert
    expect(result).toEqual(expected);
  });

  test('should throw error for invalid input', () => {
    // Arrange
    const invalidData = {value_that_should_fail};

    // Act & Assert
    expect(() => {
      functionUnderTest(invalidData);
    }).toThrow({ErrorType});
  });
});
```

---

## Integration Regression Test

```python
"""
Integration regression test for bug: {BUG-ID}

Tests the interaction between {component A} and {component B}
that caused the original bug.
"""

import pytest
from {module_a} import {ComponentA}
from {module_b} import {ComponentB}


@pytest.mark.integration
def test_bug_{bug_id}_integration():
    """
    Test full flow from {entry point} to {exit point}.

    The original bug occurred when {ComponentA} passed {value} to {ComponentB}.
    """
    # Arrange
    component_a = {ComponentA}({config})
    component_b = {ComponentB}({config})

    # Act
    intermediate = component_a.process({input})
    result = component_b.handle(intermediate)

    # Assert
    assert result.status == "success"
    assert result.data is not None


@pytest.mark.integration
@pytest.mark.database
def test_bug_{bug_id}_database_integration():
    """
    Test database interaction that caused the bug.

    The original bug occurred when {specific database condition}.
    """
    # Arrange
    {setup_database_state}

    # Act
    result = {function_that_queries_db}({params})

    # Assert
    assert {expected_database_state}
    assert {expected_result}


@pytest.mark.integration
@pytest.mark.slow
def test_bug_{bug_id}_end_to_end():
    """
    Full end-to-end test of the bug scenario.

    Simulates real-world usage that triggered the bug.
    """
    # Arrange
    {setup_full_environment}

    # Act
    {execute_full_workflow}

    # Assert
    {verify_complete_state}
```

---

## API Regression Test

```python
"""
API regression test for bug: {BUG-ID}

Tests API endpoint that exhibited the bug.
"""

import pytest
from fastapi.testclient import TestClient
from {module} import app

client = TestClient(app)


def test_bug_{bug_id}_api_endpoint():
    """
    Test that {endpoint} handles {condition} correctly.

    Previously returned 500; should now return {expected_status}.
    """
    # Arrange
    payload = {request_data_that_triggered_bug}

    # Act
    response = client.post("/api/{endpoint}", json=payload)

    # Assert
    assert response.status_code == {expected_status}
    assert response.json() == {expected_response}


def test_bug_{bug_id}_api_error_response():
    """
    Test that API returns proper error for invalid input.

    Previously crashed; should now return 400 with helpful message.
    """
    # Arrange
    invalid_payload = {invalid_data}

    # Act
    response = client.post("/api/{endpoint}", json=invalid_payload)

    # Assert
    assert response.status_code == 400
    assert "error" in response.json()
    assert {specific_error_message} in response.json()["error"]
```

---

## Best Practices for Regression Tests

### 1. Clear Documentation
```python
def test_bug_123_null_pointer_in_user_processing():
    """
    Test that processing a user with null email doesn't crash.

    Bug #123: NullPointerException when user.email was null.
    Root cause: No null check before calling email.toLowerCase().
    Fix: Added null check and default value.

    @see https://github.com/org/repo/issues/123
    @see https://github.com/org/repo/commit/abc123
    """
```

### 2. Test the Exact Bug Scenario
```python
# Don't test something similar - test the EXACT scenario
def test_bug_456_exact_scenario():
    # Use the exact data that triggered the bug
    user = User(email=None, name="John")  # This was the exact input
    preferences = {"theme": "dark"}       # This was the context

    # Call the exact function that failed
    result = process_user_preferences(user, preferences)

    # Verify the exact failure is now handled
    assert result is not None
```

### 3. Test Edge Cases Around the Bug
```python
@pytest.mark.parametrize("email,should_succeed", [
    (None, True),           # The bug case
    ("", True),             # Similar edge case
    ("  ", True),           # Whitespace
    ("test@example.com", True),  # Normal case
])
def test_bug_789_email_edge_cases(email, should_succeed):
    user = User(email=email)
    result = process_user(user)
    assert (result is not None) == should_succeed
```

### 4. Include Comments About the Bug
```python
def test_bug_101_off_by_one_in_pagination():
    """Test that page boundaries don't cause index errors."""
    items = list(range(100))

    # Bug was here: range(0, 101) caused index error
    # because items only had 100 elements (0-99)
    result = paginate(items, page=10, per_page=10)

    # Should return empty list, not raise IndexError
    assert result == []
```

### 5. Keep Tests Focused
```python
# Good: One test per bug aspect
def test_bug_202_null_handling():
    """Test null input handling."""
    assert process(None) == []

def test_bug_202_empty_handling():
    """Test empty input handling."""
    assert process([]) == []

# Bad: Testing too many things
def test_bug_202_everything():
    assert process(None) == []
    assert process([]) == []
    assert process([1, 2]) == [1, 2]
    # ... many more assertions
```

### 6. Use Descriptive Names
```python
# Good names that explain the bug
test_bug_303_division_by_zero_when_no_items()
test_bug_404_unicode_characters_in_filename()
test_bug_505_race_condition_in_cache_update()

# Bad names that don't explain
test_bug_303()
test_error_case()
test_fix()
```

### 7. Include Performance Regression Tests
```python
def test_bug_606_performance_regression():
    """Ensure optimization didn't regress performance."""
    items = generate_test_items(10000)

    start = time.time()
    result = process_items(items)
    duration = time.time() - start

    # Bug #606: Processing took 30s; should be <1s after fix
    assert duration < 1.0, f"Too slow: {duration}s"
```

---

## Checklist for Regression Tests

Before committing regression tests:

- [ ] Test covers the exact bug scenario
- [ ] Test includes edge cases around the bug
- [ ] Test has clear documentation (bug ID, description, link)
- [ ] Test would have failed before the fix
- [ ] Test passes after the fix
- [ ] Test doesn't break existing tests
- [ ] Test has descriptive name
- [ ] Test is in appropriate test file/module
- [ ] Test runs quickly (or marked as slow if needed)
- [ ] Test is deterministic (no flaky behavior)
