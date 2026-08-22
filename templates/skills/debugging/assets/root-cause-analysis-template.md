# Root Cause Analysis: {Issue Title}

## Overview
**Issue ID**: {Bug ID or ticket number}
**Date**: {Analysis date}
**Analyst**: {Your name}
**Severity**: Critical | High | Medium | Low

## Problem Statement
{Clear, concise description of what went wrong}

**Symptoms**:
- {Observable symptom 1}
- {Observable symptom 2}
- {Observable symptom 3}

## The 5 Whys Method

### Problem: {State the problem}

**Why 1**: {First why - immediate cause}
→ Because {answer 1}

**Why 2**: {Second why - dig deeper}
→ Because {answer 2}

**Why 3**: {Third why - continue digging}
→ Because {answer 3}

**Why 4**: {Fourth why - get to systems/process level}
→ Because {answer 4}

**Why 5**: {Fifth why - root cause revealed}
→ Because {answer 5} **← ROOT CAUSE**

### Validation
{Test that fixing this root cause would prevent recurrence}

## Fishbone Diagram (Ishikawa)

```
                          {Problem}
                              ↑
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
    [People]              [Process]            [Technology]
        │                     │                     │
    - {cause}             - {cause}             - {cause}
    - {cause}             - {cause}             - {cause}
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                          {Problem}
                              ↓
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
    [Environment]         [Materials]         [Measurement]
        │                     │                     │
    - {cause}             - {cause}             - {cause}
    - {cause}             - {cause}             - {cause}
```

### Category Analysis

#### People
- **Contributing factors**: {Human factors - knowledge, training, communication}
- **Root causes identified**: {List any root causes in this category}

#### Process
- **Contributing factors**: {Process gaps, unclear procedures, missing steps}
- **Root causes identified**: {List any root causes in this category}

#### Technology
- **Contributing factors**: {Tool limitations, bugs, configuration}
- **Root causes identified**: {List any root causes in this category}

#### Environment
- **Contributing factors**: {Infrastructure, dependencies, external systems}
- **Root causes identified**: {List any root causes in this category}

#### Materials
- **Contributing factors**: {Data quality, input validation, resources}
- **Root causes identified**: {List any root causes in this category}

#### Measurement
- **Contributing factors**: {Monitoring gaps, metrics, observability}
- **Root causes identified**: {List any root causes in this category}

## Root Cause Summary

### Primary Root Cause
{The fundamental issue that, if fixed, would prevent recurrence}

**Category**: {People | Process | Technology | Environment | Materials | Measurement}

**Evidence**:
- {Evidence 1}
- {Evidence 2}
- {Evidence 3}

**How it led to the problem**:
{Trace from root cause → intermediate effects → final problem}

### Contributing Factors
1. **{Factor 1}**: {How it contributed}
2. **{Factor 2}**: {How it contributed}
3. **{Factor 3}**: {How it contributed}

### What Didn't Cause It
{List and eliminate red herrings to prevent misdirected fixes}
- ❌ {Not a cause}: {Why ruled out}
- ❌ {Not a cause}: {Why ruled out}

## Impact Analysis

### Blast Radius
- **Systems affected**: {List systems}
- **Users affected**: {Count or percentage}
- **Time period**: {When impact occurred}
- **Data integrity**: {Any data corruption}

### Business Impact
- **Revenue impact**: {$ amount or estimate}
- **User experience**: {How users were affected}
- **Reputation**: {Brand impact}
- **Legal/compliance**: {Any regulatory issues}

## Corrective Actions

### Immediate Fix (Stop the bleeding)
**Action**: {What was done to resolve immediate issue}
**Status**: ✅ Complete | 🔄 In Progress | ⏳ Planned
**Owner**: {Person responsible}
**Timeline**: {Completion date}

### Short-term Solutions (Address root cause)
1. **{Solution 1}**
   - **Action**: {Specific steps}
   - **Owner**: {Person}
   - **Timeline**: {Date}
   - **Success criteria**: {How we'll know it worked}

2. **{Solution 2}**
   - **Action**: {Specific steps}
   - **Owner**: {Person}
   - **Timeline**: {Date}
   - **Success criteria**: {How we'll know it worked}

### Long-term Preventive Measures
1. **{Prevention 1}** - {Description}
   - **Action**: {What to implement}
   - **Timeline**: {When}
   - **Benefit**: {How this prevents recurrence}

2. **{Prevention 2}** - {Description}
   - **Action**: {What to implement}
   - **Timeline**: {When}
   - **Benefit**: {How this prevents recurrence}

## Lessons Learned

### What Went Wrong
1. {Learning 1}
2. {Learning 2}
3. {Learning 3}

### What Went Right
1. {What worked well in detection/response}
2. {What worked well in resolution}

### What We'll Do Differently
1. {Process change 1}
2. {Process change 2}
3. {Technical change 1}

## Validation Plan

### How to Verify Fix
- [ ] {Verification step 1}
- [ ] {Verification step 2}
- [ ] {Verification step 3}

### Monitoring
- **Metrics to track**: {List metrics}
- **Alert thresholds**: {When to be notified}
- **Review schedule**: {When to check effectiveness}

### Success Criteria
- {Criterion 1 - measurable}
- {Criterion 2 - measurable}
- {Criterion 3 - measurable}

## Follow-up

### Review Date
{Date to review effectiveness of corrective actions}

### Related Action Items
- [ ] {Action item 1} - {Owner} - {Due date}
- [ ] {Action item 2} - {Owner} - {Due date}
- [ ] {Action item 3} - {Owner} - {Due date}

### Documentation Updates Needed
- [ ] {Update runbook for X}
- [ ] {Document new process for Y}
- [ ] {Update architecture docs for Z}

## References
- **Related incidents**: {Links to similar issues}
- **External resources**: {Blog posts, documentation}
- **Internal documentation**: {Runbooks, architecture diagrams}

---

**Sign-off**:
- **Analyst**: {Name} - {Date}
- **Technical Lead**: {Name} - {Date}
- **Engineering Manager**: {Name} - {Date}
