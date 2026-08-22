# Exploratory Testing Charter

## Charter Information

**Charter ID**: ETC-XXX
**Feature/Area**: {Feature or Area to Explore}
**Tester**: {Name}
**Date**: YYYY-MM-DD
**Time Box**: {Duration, e.g., 60 minutes}
**Session Start**: HH:MM
**Session End**: HH:MM

---

## Mission

### Charter Statement

**Explore** {the feature/area being tested}
**With** {resources, tools, or data to be used}
**To discover** {what you're looking for: bugs, risks, usability issues, etc.}

**Example:**
> Explore the user registration flow with various input combinations to discover edge cases, validation issues, and usability problems.

---

## Scope

### In Scope
What will be explored in this session:
-
-
-

### Out of Scope
What will NOT be explored in this session:
-
-
-

---

## Strategy & Approach

### Test Heuristics to Apply

Select applicable heuristics:

- [ ] **Boundary Testing**: Min/max values, just inside/outside boundaries
- [ ] **Equivalence Partitioning**: Representative values from each input class
- [ ] **Error Guessing**: What could go wrong? What would users try?
- [ ] **State Transition**: Different states, transitions between states
- [ ] **Negative Testing**: Invalid inputs, unexpected actions
- [ ] **Exploratory Tours**: Use different "touring" techniques (see below)

### Testing Tours (if applicable)

- [ ] **Guidebook Tour**: Follow documentation/help as a guide
- [ ] **Money Tour**: Test the most valuable/critical features
- [ ] **Landmark Tour**: Visit every major feature once
- [ ] **Intellectual Tour**: Try to break the system, think like an attacker
- [ ] **Bad Neighborhood Tour**: Focus on areas with known issues
- [ ] **Museum Tour**: Look for old code, legacy features

### Areas of Focus

1. **Primary Focus**:
2. **Secondary Focus**:
3. **Nice to Have**:

---

## Test Ideas & Notes

### Test Ideas Before Starting

Pre-session brainstorm of things to try:

1.
2.
3.
4.
5.

---

## Session Log

### Test Actions Taken

**Time**: {HH:MM}
**Action**: {What you did}
**Observation**: {What you observed}
**Notes**: {Thoughts, questions, or concerns}

---

**Time**: {HH:MM}
**Action**:
**Observation**:
**Notes**:

---

**Time**: {HH:MM}
**Action**:
**Observation**:
**Notes**:

---

**Time**: {HH:MM}
**Action**:
**Observation**:
**Notes**:

---

**Time**: {HH:MM}
**Action**:
**Observation**:
**Notes**:

---

*Continue logging throughout session...*

---

## Bugs & Issues Found

### Bug 1: {Title}

**Severity**: Critical / High / Medium / Low
**Steps to Reproduce**:
1.
2.
3.

**Expected Result**:
**Actual Result**:
**Evidence**: Screenshot/video link

**Bug ID** (if logged): BUG-XXX

---

### Bug 2: {Title}

**Severity**: Critical / High / Medium / Low
**Steps to Reproduce**:
1.
2.
3.

**Expected Result**:
**Actual Result**:
**Evidence**:

**Bug ID** (if logged): BUG-XXX

---

*Add more bugs as discovered...*

---

## Observations & Insights

### Positive Findings
What worked well:
-
-

### Usability Observations
User experience notes:
-
-

### Performance Notes
Performance observations:
-
-

### Questions Raised
Questions for dev/product team:
1.
2.
3.

### Areas Requiring Follow-Up
What needs more investigation:
-
-

---

## Coverage Assessment

### What Was Tested

**Coverage Achieved** (estimate):
- Functional coverage: X% (subjective estimate)
- Edge cases covered: X scenarios
- Input combinations tried: X
- User workflows tested: X

**Specific Areas Covered**:
- ✅ {Area 1}
- ✅ {Area 2}
- ✅ {Area 3}
- ⚠️ {Area 4} - Partially covered
- ❌ {Area 5} - Not covered (out of time)

### What Was NOT Tested

**Areas Skipped** (and why):
- {Area A}: Out of scope
- {Area B}: No time remaining
- {Area C}: Blocked by issue BUG-XXX

---

## Risks Identified

### Risk 1: {Risk Name}
**Likelihood**: High / Medium / Low
**Impact**: High / Medium / Low
**Description**:
**Mitigation**:

### Risk 2: {Risk Name}
**Likelihood**: High / Medium / Low
**Impact**: High / Medium / Low
**Description**:
**Mitigation**:

---

## Test Data Used

### Data Sets
- **Dataset 1**: {Description}
- **Dataset 2**: {Description}

### User Accounts
- **Account 1**: {Username/Role}
- **Account 2**: {Username/Role}

### Environment
- **Browser**: Chrome 120
- **OS**: macOS 14.0
- **Test Environment**: Staging
- **API Version**: vX.Y.Z

---

## Session Metrics

### Time Allocation

| Activity | Time Spent | % of Session |
|----------|------------|--------------|
| Setup | X min | X% |
| Testing | X min | X% |
| Bug Investigation | X min | X% |
| Documentation | X min | X% |
| **Total** | **X min** | **100%** |

### Productivity Assessment

**Charter Completion**: X% (how much of planned testing was completed)
**Test vs. Bug vs. Setup Ratio**: {Test%:Bug%:Setup%}
**Efficiency**: High / Medium / Low

**Notes on Productivity**:


---

## Recommendations

### Immediate Actions
1.
2.
3.

### Follow-Up Testing Needed
1.
2.
3.

### Improvements for Product
1.
2.
3.

### Process Improvements
1.
2.
3.

---

## Next Steps

### Additional Charters Needed

**Charter 1**:
- **Focus**:
- **Priority**: High / Medium / Low
- **Estimated Time**: X minutes

**Charter 2**:
- **Focus**:
- **Priority**: High / Medium / Low
- **Estimated Time**: X minutes

### Blocked Items
What's blocking further testing:
-
-

---

## Debrief Notes

### What Went Well
-
-

### What Could Be Improved
-
-

### Surprises
-
-

### Key Learnings
-
-

---

## Attachments

### Screenshots
- `screenshot-1.png`: {Description}
- `screenshot-2.png`: {Description}

### Videos
- `session-recording.mp4`: {Description}

### Logs
- `console-output.log`: {Description}
- `network-trace.har`: {Description}

---

## Sign-Off

**Tester**: _____________________ Date: _____
**Reviewed By**: _____________________ Date: _____

---

## Template Usage Guide

### When to Use This Template

Use exploratory testing charters when:
- Testing new or unfamiliar features
- Time-boxed testing sessions needed
- Looking for unknown issues (not following scripts)
- Complementing scripted testing
- Testing areas with poor documentation
- Rapid testing required (spike, prototype)

### How to Use This Template

1. **Pre-Session** (5-10 min):
   - Define clear mission/charter
   - Set time box (typically 60-90 min)
   - Identify scope and test ideas
   - Prepare test data and environment

2. **During Session** (60-90 min):
   - Focus on exploration, not documentation
   - Take brief notes in session log
   - Log bugs immediately when found
   - Stay within time box

3. **Post-Session** (15-30 min):
   - Complete session log
   - File bugs with detailed steps
   - Document observations and risks
   - Assess coverage and recommend next steps

### Tips for Effective Exploratory Testing

1. **Time Box**: Stick to the time limit to maintain focus
2. **Single Focus**: One charter per session, don't try to test everything
3. **Note-Taking**: Keep notes brief during session, expand afterwards
4. **Pair Testing**: Consider pairing with another tester or developer
5. **Variety**: Use different touring techniques for broader coverage
6. **Follow Hunches**: If something feels wrong, investigate it
7. **Document Learnings**: Capture insights for future testing

### Charter Sizing Guidelines

- **Short Session (30-45 min)**: Narrow scope, specific feature
- **Standard Session (60-90 min)**: Medium scope, feature area
- **Long Session (2 hours)**: Broad scope, entire workflow

### Common Pitfalls to Avoid

- ❌ Scope too broad (can't finish in time)
- ❌ No clear mission (unfocused testing)
- ❌ Over-documenting during session (wastes testing time)
- ❌ Ignoring time box (session drags on)
- ❌ Not logging bugs immediately (forget details later)
