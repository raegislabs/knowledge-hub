# Bug Report: {Bug Title}

## Bug Information

**Bug ID**: BUG-XXX
**Title**: Brief, descriptive title of the issue
**Status**: New / Assigned / In Progress / Fixed / Verified / Closed
**Priority**: Critical / High / Medium / Low
**Severity**: Blocker / Critical / Major / Minor / Trivial
**Reported By**: {Reporter Name}
**Reported Date**: YYYY-MM-DD
**Assigned To**: {Developer Name}
**Target Version**: vX.Y.Z

## Priority and Severity Definitions

### Priority (Business Impact)
- **Critical**: Blocks release, affects all users
- **High**: Affects major functionality, workaround difficult
- **Medium**: Affects minor functionality, workaround available
- **Low**: Cosmetic issue, minimal impact

### Severity (Technical Impact)
- **Blocker**: System crash, data loss, security breach
- **Critical**: Major functionality broken, no workaround
- **Major**: Major functionality broken, workaround exists
- **Minor**: Minor functionality issue
- **Trivial**: UI glitch, typo

## Environment

**Operating System**: macOS 14.0 / Ubuntu 22.04 / Windows 11
**Browser** (if applicable): Chrome 120 / Firefox 121 / Safari 17
**Application Version**: vX.Y.Z
**Database Version**: PostgreSQL 15.2
**Python Version**: 3.11.5
**Dependencies**: List key dependency versions

### Environment Variables
```bash
ENV_VAR_1=value1
ENV_VAR_2=value2
```

## Summary

One-paragraph summary of the bug: what went wrong, where, and when.

## Steps to Reproduce

Detailed steps to consistently reproduce the issue:

1. Navigate to / Execute command / Call function
2. Enter specific data / Trigger specific action
3. Click button / Submit form / Run process
4. Observe the error

**Reproducibility**: Always / Sometimes / Rarely

**Frequency**: 100% / 50% / <10%

## Expected Behavior

Describe what should happen:

- Feature should perform X
- System should return Y
- User should see Z

## Actual Behavior

Describe what actually happens:

- Feature crashes with error
- System returns incorrect value
- User sees error message

## Screenshots/Recordings

![Screenshot of error](path/to/screenshot.png)

*Or describe visually if screenshot not available*

## Error Messages

### Console Output
```
Traceback (most recent call last):
  File "module.py", line 42, in function_name
    result = some_operation()
ValueError: Invalid input: expected X but got Y
```

### Log Files
```
2025-10-24 10:30:45 ERROR [module.function] Operation failed: Connection timeout
2025-10-24 10:30:45 DEBUG [module.function] Retrying connection (attempt 2/3)
```

## Code Context

### Affected Files
- `src/module_name.py` - Line 42
- `src/helper_module.py` - Line 128

### Code Snippet
```python
# Line 42 in module_name.py
def problematic_function(input_data):
    # This line causes the error
    result = some_operation(input_data)  # ValueError here
    return result
```

## Root Cause Analysis

*To be filled by developer*

**Root Cause**:

**Why It Occurred**:

## Impact Assessment

**User Impact**:
- Number of users affected: All / Some / Few
- User workflows blocked: Critical / Important / Minor
- Data integrity risk: High / Medium / Low / None

**System Impact**:
- Performance degradation: Yes / No
- Data loss risk: Yes / No
- Security implications: Yes / No

**Business Impact**:
- Revenue impact: High / Medium / Low / None
- Customer satisfaction: High / Medium / Low / None
- Regulatory compliance: Affected / Not Affected

## Workaround

**Temporary Workaround Available**: Yes / No

**Workaround Steps**:
1. Instead of X, do Y
2. Use alternative method Z
3. Manually correct data

**Workaround Limitations**:
- Not suitable for production
- Requires manual intervention
- Performance impact

## Suggested Fix

*Optional: Tester's suggestion for fixing the issue*

**Approach**:
- Add validation for input_data
- Handle edge case when input is None
- Add try-except for external API calls

**Code Suggestion**:
```python
def fixed_function(input_data):
    # Add validation
    if not input_data:
        raise ValueError("input_data cannot be empty")

    try:
        result = some_operation(input_data)
    except SomeException as e:
        logger.error(f"Operation failed: {e}")
        raise

    return result
```

## Test Case

**Related Test Case**: TC-XXX
**Test Coverage**: This scenario is / is not covered by existing tests

**New Test Case Needed**:
```python
def test_handle_empty_input():
    """Test that empty input is handled correctly."""
    feature = FeatureName()

    with pytest.raises(ValueError, match="input_data cannot be empty"):
        feature.problematic_function({})
```

## Regression Risk

**Risk Level**: High / Medium / Low

**Regression Areas to Test**:
- Related functionality A
- Dependent module B
- Integration with system C

## Additional Information

### Related Issues
- Related to: BUG-YYY
- Duplicate of: None
- Blocks: BUG-ZZZ

### Attachments
- Log file: `logs/error-2025-10-24.log`
- Database dump: `dumps/bug-xxx-data.sql`
- Network trace: `traces/api-call-failure.har`

### Investigation Notes
- Investigated on YYYY-MM-DD
- Found correlation with recent deployment
- Occurs only when feature flag X is enabled

## Resolution

*To be filled when bug is resolved*

**Fixed In Version**: vX.Y.Z
**Fix Date**: YYYY-MM-DD
**Fixed By**: {Developer Name}

**Fix Description**:


**Verification**:
- [ ] Unit tests added
- [ ] Integration tests updated
- [ ] Manual testing completed
- [ ] Regression testing passed
- [ ] Code review approved

**Verification Date**: YYYY-MM-DD
**Verified By**: {Tester Name}

## Comments

### YYYY-MM-DD - {Name}
Comment text here

### YYYY-MM-DD - {Name}
Additional comment

---

**Status History**:
- YYYY-MM-DD: New → Assigned ({Developer Name})
- YYYY-MM-DD: Assigned → In Progress
- YYYY-MM-DD: In Progress → Fixed
- YYYY-MM-DD: Fixed → Verified
- YYYY-MM-DD: Verified → Closed
