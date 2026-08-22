# Test Case: {Test Case ID}

## Test Case Information

**Test Case ID**: TC-XXX
**Test Case Name**: Descriptive name of what is being tested
**Feature**: {Feature Name}
**Priority**: High / Medium / Low
**Test Type**: Unit / Integration / System / Regression
**Created By**: {Tester Name}
**Created Date**: YYYY-MM-DD
**Last Updated**: YYYY-MM-DD

## Test Objective

Clear description of what this test case aims to verify.

## Preconditions

List all conditions that must be met before executing this test:

- System in known state
- Test data available
- Dependencies initialized
- Configuration set correctly

## Test Data

Specific data required for this test:

```python
test_data = {
    "input_field_1": "value_1",
    "input_field_2": "value_2",
    "expected_output": "expected_value"
}
```

## Test Steps

| Step # | Action | Expected Result |
|--------|--------|-----------------|
| 1 | Arrange: Set up test environment and data | Test environment ready |
| 2 | Act: Execute the feature/method under test | Method executes without error |
| 3 | Assert: Verify the output matches expected result | Output == expected_output |

### Detailed Steps

**Step 1: Arrange**
```python
# Set up test instance
feature_instance = FeatureName(param1="test")

# Prepare test data
input_data = {"key": "value"}
```

**Step 2: Act**
```python
# Execute the method
result = feature_instance.main_method(input_data)
```

**Step 3: Assert**
```python
# Verify results
assert result is not None
assert result == expected_output
```

## Expected Results

Describe the expected outcome in detail:

- Method returns expected value
- No exceptions raised
- System state updated correctly
- Side effects occur as expected

## Actual Results

*To be filled during test execution*

- [ ] Test Passed
- [ ] Test Failed
- [ ] Test Blocked

**Notes**:

## Postconditions

State of the system after test execution:

- System returned to known state
- Test data cleaned up
- Resources released

## Test Implementation

### pytest Implementation

```python
"""Test case TC-XXX: {Test Case Name}"""

import pytest
from unittest.mock import Mock, patch


class Test{FeatureName}:
    """Test suite for {Feature Name}."""

    @pytest.fixture
    def feature_instance(self):
        """Create a feature instance for testing."""
        return FeatureName(param1="test")

    def test_{test_case_name}(self, feature_instance):
        """
        TC-XXX: {Test objective}

        This test verifies that {detailed description}.
        """
        # Arrange
        input_data = {"key": "value"}
        expected_output = "expected_value"

        # Act
        result = feature_instance.main_method(input_data)

        # Assert
        assert result is not None
        assert result == expected_output
```

## Dependencies

List any dependencies or related test cases:

- Depends on: TC-XXX (must pass first)
- Related to: TC-YYY (similar functionality)
- Blocks: TC-ZZZ (must pass before)

## Automation Status

- [ ] Manual Test Only
- [x] Automated Test
- [ ] Partially Automated

**Automation Notes**:

## Test Execution History

| Date | Tester | Status | Notes |
|------|--------|--------|-------|
| YYYY-MM-DD | Name | Pass | Initial execution |
| YYYY-MM-DD | Name | Fail | Bug #123 found |
| YYYY-MM-DD | Name | Pass | After bug fix |

## Notes and Comments

Additional information about this test case:

- Edge cases covered
- Known limitations
- Future improvements needed

## References

- Feature Specification: Link or section reference
- API Documentation: Link
- Related Bug Reports: BUG-XXX
