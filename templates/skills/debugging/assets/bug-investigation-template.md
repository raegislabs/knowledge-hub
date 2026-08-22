# Bug Investigation: {Bug ID/Title}

## Summary
**Issue**: {One-line description of the bug}
**Severity**: Critical | High | Medium | Low
**Status**: Investigating | Root Cause Found | Fixed | Verified
**Reported**: {Date}
**Reporter**: {Name/Email}

## Reproduction

### Steps to Reproduce
1. {Step 1 - be specific}
2. {Step 2 - include data/inputs}
3. {Step 3 - include expected action}

### Expected Behavior
{Describe what should happen}

### Actual Behavior
{Describe what actually happens - be precise}

### Environment
- **OS**: {operating system and version}
- **Runtime**: {Python/Node/Java version}
- **Dependencies**: {relevant package versions}
- **Configuration**: {relevant config settings}
- **Data**: {sample data characteristics}

## Investigation

### Error Message
```
{Full error message and stack trace - preserve formatting}
```

### Hypothesis 1: {Description of theory}
**Test**: {How you tested this hypothesis}
**Result**: ✅ Confirmed | ❌ Ruled out | ⚠️ Partially explains
**Evidence**: {What you found - logs, values, behavior}
**Notes**: {Additional observations}

### Hypothesis 2: {Description of theory}
**Test**: {How you tested this hypothesis}
**Result**: ✅ Confirmed | ❌ Ruled out | ⚠️ Partially explains
**Evidence**: {What you found}
**Notes**: {Additional observations}

### Hypothesis 3: {Description of theory}
**Test**: {How you tested this hypothesis}
**Result**: ✅ Confirmed | ❌ Ruled out | ⚠️ Partially explains
**Evidence**: {What you found}
**Notes**: {Additional observations}

### Investigation Log
| Time | Action | Finding |
|------|--------|---------|
| {timestamp} | {What you did} | {What you learned} |
| {timestamp} | {What you did} | {What you learned} |

## Root Cause

### Technical Cause
{Detailed explanation of what's happening at the code level}
- **Location**: {File, function, line number}
- **Mechanism**: {How the bug manifests}
- **Trigger**: {What conditions cause it}

### Why It Occurs
{Explanation of why the code behaves this way}
- Was it an incorrect assumption?
- Missing validation?
- Race condition?
- Edge case not handled?

### Affected Components
- **Primary**: {Component directly causing issue}
- **Secondary**: {Components affected by the bug}
- **Dependent**: {Components that depend on affected behavior}

### Impact Assessment
**Users Affected**: {Percentage or count}
**Frequency**: {How often it occurs}
**Data Integrity**: {Any data corruption risk}
**Security Impact**: {Any security implications}
**Business Impact**: {Revenue, reputation, legal implications}

## Solution

### Approach
{High-level description of the fix strategy}

### Implementation Details
{Specific changes needed - be detailed}
1. {Change 1}
2. {Change 2}
3. {Change 3}

### Code Changes
```python
# Before (buggy code)
def problematic_function(data):
    result = process(data)  # Fails when data is empty
    return result

# After (fixed code)
def problematic_function(data):
    if not data:
        logger.warning("Empty data received in problematic_function")
        return None  # Handle empty case explicitly
    result = process(data)
    return result
```

### Testing
- ✅ Bug no longer reproduces with original steps
- ✅ Regression test created and passes
- ✅ Existing unit tests still pass
- ✅ Edge cases tested (empty, null, boundary values)
- ✅ Integration tests pass
- ⚠️ Performance impact measured (if applicable)

## Prevention

### How to Avoid This Bug in Future
1. {Prevention measure 1 - process, review, validation}
2. {Prevention measure 2 - testing, monitoring}
3. {Prevention measure 3 - documentation, training}

### Code Improvements Recommended
- **Input Validation**: {Add validation for X}
- **Error Handling**: {Improve error handling in Y}
- **Tests**: {Add tests for Z}
- **Documentation**: {Document assumption about A}

### Monitoring Suggestions
- **Logging**: {Add logging for X events}
- **Metrics**: {Track Y metric}
- **Alerts**: {Alert on Z condition}

## Related Issues
- {Link to similar issues}
- {Reference to related bugs}
- {Link to feature request that would prevent this}

## Timeline
- **Reported**: {Date/time}
- **Investigation started**: {Date/time}
- **Root cause identified**: {Date/time}
- **Fix implemented**: {Date/time}
- **Fix deployed**: {Date/time}
- **Verified**: {Date/time}

## Notes
{Any additional context, learnings, or observations}
