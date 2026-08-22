# Debugging Session: {Issue Summary}

## Session Information
**Date/Time**: {YYYY-MM-DD HH:MM - HH:MM}
**Issue**: {Bug ID or description}
**Debugger**: {Your name}
**Pairing with**: {Collaborator names, if any}

## Quick Context
**Problem**: {One-line problem statement}
**Goal**: {What you're trying to achieve this session}
**Time budget**: {How much time allocated}

## Initial State

### What We Know
- {Fact 1 about the bug}
- {Fact 2 about symptoms}
- {Fact 3 about environment}

### What We Don't Know
- {Question 1}
- {Question 2}
- {Question 3}

### Starting Hypotheses
1. **{Hypothesis A}** - Confidence: High | Medium | Low
   - Reasoning: {Why you think this}

2. **{Hypothesis B}** - Confidence: High | Medium | Low
   - Reasoning: {Why you think this}

## Debugging Log

### {HH:MM} - {Action taken}
**Method**: Print/Log debugging | Breakpoint | Code review | Binary search | Other

**What I did**:
{Describe what you tried}

**What I observed**:
{What you learned from this attempt}

**Hypothesis updated**:
- ✅ Confirmed {hypothesis}
- ❌ Ruled out {hypothesis}
- 🔄 Modified {hypothesis} to {new understanding}

---

### {HH:MM} - {Action taken}
**Method**: Print/Log debugging | Breakpoint | Code review | Binary search | Other

**What I did**:
{Describe what you tried}

**What I observed**:
{What you learned from this attempt}

**Hypothesis updated**:
- ✅ Confirmed {hypothesis}
- ❌ Ruled out {hypothesis}
- 🔄 Modified {hypothesis} to {new understanding}

---

### {HH:MM} - {Action taken}
**Method**: Print/Log debugging | Breakpoint | Code review | Binary search | Other

**What I did**:
{Describe what you tried}

**What I observed**:
{What you learned from this attempt}

**Hypothesis updated**:
- ✅ Confirmed {hypothesis}
- ❌ Ruled out {hypothesis}
- 🔄 Modified {hypothesis} to {new understanding}

---

## Discoveries

### Key Findings
1. **{Finding 1}**
   - Evidence: {Logs, values, behavior}
   - Significance: {Why this matters}

2. **{Finding 2}**
   - Evidence: {Logs, values, behavior}
   - Significance: {Why this matters}

### Eureka Moments
**{HH:MM}**: {What clicked - the "aha!" moment}
- What triggered it: {Code inspection, rubber ducking, taking a break}
- Impact: {How this changed your understanding}

### Dead Ends
{Document what didn't work to save time later}

1. **{Dead end 1}**: {What you tried}
   - Why it failed: {Explanation}
   - Time spent: {X minutes}

2. **{Dead end 2}**: {What you tried}
   - Why it failed: {Explanation}
   - Time spent: {X minutes}

## Code Snippets

### Relevant Code Section 1
```python
# File: path/to/file.py:42-58
def problematic_function(data):
    # Line 45: This is where it breaks
    result = process(data)
    return result
```

**Notes**: {Why this code is relevant}

### Relevant Code Section 2
```python
# File: path/to/another.py:102-115
def calling_function():
    # Line 108: Passes None sometimes
    data = get_data()
    return problematic_function(data)
```

**Notes**: {Why this code is relevant}

## Variable State Tracking

### Critical Variables
{Track variable values at key points}

| Variable | Expected | Actual | Location |
|----------|----------|--------|----------|
| `data` | `[1,2,3]` | `None` | file.py:45 |
| `user_id` | `123` | `"123"` | auth.py:78 |
| `config` | `{...}` | `{}` | main.py:12 |

### State Timeline
{How state changes through execution}

1. **Entry point**: `data = None` (Unexpected!)
2. **After validation**: `data = None` (Validation passed - BUG!)
3. **Before processing**: `data = None` (Will crash)
4. **Crash point**: `AttributeError: 'NoneType' object has no attribute 'items'`

## Breakpoint Notes

### Breakpoint 1: file.py:45
**When hit**: {Conditions}
**Variables inspected**:
```
data = None
config = {'debug': True}
user = <User object at 0x...>
```

**Stack trace at this point**:
```
-> problematic_function(data=None)
   calling_function()
   main()
```

**Observations**: {What you learned}

### Breakpoint 2: another.py:108
**When hit**: {Conditions}
**Variables inspected**:
```
query_result = []
cached_data = None  # Cache miss!
```

**Observations**: {What you learned}

## Questions & Answers

### Question 1: {Question}
**Answer**: {What you discovered}
**How found**: {Method used}

### Question 2: {Question}
**Answer**: {What you discovered}
**How found**: {Method used}

### Unanswered Questions
- {Question that still needs investigation}
- {Question that still needs investigation}

## Root Cause

### Technical Explanation
{Detailed explanation of what's actually happening}

**Problem location**: {File, function, line}

**Why it fails**: {Mechanism of failure}

**Trigger conditions**: {What causes it to manifest}

### Contributing Factors
1. {Factor 1} - {How it contributes}
2. {Factor 2} - {How it contributes}

## Solution

### Approach
{High-level fix strategy}

### Implementation Plan
1. {Step 1}
2. {Step 2}
3. {Step 3}

### Code Changes Needed
```python
# Before
def problematic_function(data):
    result = process(data)
    return result

# After
def problematic_function(data):
    if data is None:
        logger.warning("Received None data")
        return []  # Safe default
    result = process(data)
    return result
```

## Next Steps

### Immediate
- [ ] Implement fix
- [ ] Write regression test
- [ ] Test fix locally
- [ ] Review with team

### Follow-up
- [ ] {Related code to check}
- [ ] {Documentation to update}
- [ ] {Monitoring to add}

## Session Metrics

**Time tracking**:
- Total time: {X hours Y minutes}
- Time to reproduce: {X minutes}
- Time investigating: {X hours}
- Time implementing fix: {X minutes}

**Efficiency notes**:
- What slowed us down: {Obstacles}
- What helped: {Useful tools, techniques}

## Lessons Learned

### What Worked Well
1. {Technique/approach that was effective}
2. {Tool that was helpful}
3. {Insight that accelerated progress}

### What to Improve
1. {What could have been done better}
2. {Tool or knowledge gap identified}
3. {Process improvement idea}

### Debugging Techniques Used
- [x] Print/log debugging
- [x] Breakpoint debugging
- [ ] Binary search debugging
- [x] Rubber duck debugging
- [ ] Git bisect
- [x] Stack trace analysis
- [ ] Memory profiler
- [ ] Performance profiler
- [x] Code review

## References
- Related issues: {Links}
- Documentation: {Links}
- Stack Overflow: {Links}
- Code references: {Commits, PRs}

## Notes for Future
{Anything to remember for next time you encounter similar issues}

---

**Session Status**: 🔄 In Progress | ✅ Root Cause Found | 🎯 Fixed | ⏸️ Paused

**Confidence Level**: {How confident you are in the solution}
- High (>90%) - Ready to implement
- Medium (60-90%) - Need validation
- Low (<60%) - Need more investigation
