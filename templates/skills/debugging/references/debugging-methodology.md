# Debugging Methodology Reference

## Overview
Systematic approaches to debugging that apply scientific method to software issues. This guide provides structured processes for investigating and resolving bugs efficiently.

---

## The Scientific Debugging Process

Debugging is hypothesis-driven investigation. Follow the scientific method:

### 1. Observation
**Goal**: Gather facts about the bug without assumptions.

**What to observe**:
- Error messages (complete stack traces)
- System state (logs, metrics, memory usage)
- User reports (exact steps, environment)
- Reproduction rate (always, sometimes, once)

**Techniques**:
- Read error messages completely (don't skim)
- Check logs before and after the error
- Examine monitoring dashboards
- Review recent changes (code, config, data, infrastructure)

**Anti-patterns**:
- ❌ Jumping to solutions before understanding
- ❌ Assuming you know the cause
- ❌ Ignoring partial information

### 2. Hypothesis Formation
**Goal**: Develop testable theories about the cause.

**How to form hypotheses**:
- Based on error message content
- Based on code that's executing
- Based on recent changes
- Based on similar past bugs

**Good hypothesis structure**:
"I think {X} is causing {Y} because {evidence}. If this is true, then {testable prediction}."

**Example**:
"I think the null pointer exception is caused by missing user validation because the stack trace shows user.email.toLowerCase() failing. If this is true, then adding a null check should prevent the error."

**Prioritize hypotheses**:
1. **High likelihood + high impact**: Test first
2. **High likelihood + low impact**: Test second
3. **Low likelihood + high impact**: Test third
4. **Low likelihood + low impact**: Test last or skip

### 3. Experimentation
**Goal**: Test hypotheses systematically.

**Design experiments that**:
- Test one hypothesis at a time
- Have clear pass/fail criteria
- Are reproducible
- Don't change production code (use logging, breakpoints)

**Experiment types**:
- **Add logging**: Insert strategic log statements
- **Use debugger**: Set breakpoints, inspect state
- **Change inputs**: Vary data to isolate trigger
- **Binary search**: Disable half the code to isolate
- **Git bisect**: Find commit that introduced bug

**Document results**:
- What you tested
- What you observed
- Whether hypothesis was confirmed or ruled out

### 4. Analysis
**Goal**: Interpret experimental results and refine understanding.

**Questions to ask**:
- Does the evidence support the hypothesis?
- Are there alternative explanations?
- What new information did we learn?
- Do we need to revise our hypothesis?

**Iterate**:
- If hypothesis confirmed → Proceed to solution
- If hypothesis ruled out → Form new hypothesis
- If partially explains → Refine hypothesis

### 5. Solution
**Goal**: Fix the root cause, not symptoms.

**Verify you're fixing root cause**:
- Ask "Why?" five times to get to fundamental issue
- Ensure fix prevents recurrence
- Check that fix doesn't break other things

**Implementation**:
- Make minimal changes
- Add tests that would have caught the bug
- Document why the bug occurred

### 6. Validation
**Goal**: Confirm the fix works and has no side effects.

**Validation checklist**:
- [ ] Bug no longer reproduces
- [ ] Regression test passes
- [ ] Existing tests still pass
- [ ] No new errors introduced
- [ ] Edge cases handled
- [ ] Performance acceptable

---

## Debugging Phases

### Phase 1: Understanding (10-20% of time)
**Goal**: Fully understand the problem before touching code.

**Activities**:
- Read error messages completely
- Review bug report details
- Understand expected vs actual behavior
- Clarify reproduction steps

**Output**: Clear problem statement

**Time box**: Don't rush this phase; investment here pays off later.

### Phase 2: Reproduction (20-30% of time)
**Goal**: Reliably trigger the bug.

**Activities**:
- Follow reported steps exactly
- Vary inputs to test consistency
- Simplify to minimal reproduction case
- Document reliable reproduction steps

**Output**: Minimal, reliable reproduction steps

**If can't reproduce**:
- Environment differs from reporter's
- Missing information about preconditions
- Timing/race condition
- Already fixed (check version)

### Phase 3: Investigation (30-40% of time)
**Goal**: Identify root cause through systematic testing.

**Activities**:
- Form hypotheses
- Design experiments
- Execute tests
- Document findings
- Refine understanding

**Output**: Root cause identified with evidence

**Techniques**: See "Debugging Techniques" section below.

### Phase 4: Solution (10-20% of time)
**Goal**: Implement fix for root cause.

**Activities**:
- Design minimal fix
- Implement changes
- Add regression test
- Test thoroughly

**Output**: Working fix with tests

### Phase 5: Verification (10-15% of time)
**Goal**: Ensure fix is complete and safe.

**Activities**:
- Run full test suite
- Test edge cases
- Review code changes
- Check for side effects

**Output**: Validated, tested fix ready for deployment

---

## Debugging Techniques

### 1. Print/Log Debugging
**When to use**: First resort, fastest for simple bugs.

**How**:
```python
# Strategic logging
logger.info(f"Function called with: {param}")
logger.debug(f"Variable state: {var}")
logger.info(f"About to execute: {operation}")
```

**Best practices**:
- Log inputs, outputs, intermediate state
- Include context (function name, request ID)
- Use appropriate log levels
- Remove or disable after debugging

**Pros**: Simple, no special tools
**Cons**: Requires code changes, clutters logs

### 2. Breakpoint Debugging
**When to use**: Complex logic, need to inspect multiple variables.

**How**:
```python
# Python
import pdb; pdb.set_trace()  # Or use IDE breakpoints

# JavaScript
debugger;  // In browser DevTools
```

**Debugger commands**:
- `n` (next): Execute next line
- `s` (step): Step into function
- `c` (continue): Continue to next breakpoint
- `p variable`: Print variable value
- `l` (list): Show current code location

**Best practices**:
- Set breakpoints strategically (not randomly)
- Inspect state, don't just step through
- Use conditional breakpoints for loops

**Pros**: Interactive, can inspect everything
**Cons**: Slower, changes execution timing

### 3. Binary Search Debugging
**When to use**: Bug is somewhere in large codebase/recent changes.

**How**:
1. Disable half the code/features
2. Test if bug still occurs
3. If yes, bug is in remaining half
4. If no, bug is in disabled half
5. Repeat until isolated

**Example**:
```python
# Comment out half the processing
def process_data(items):
    # step1(items)  # Disabled
    # step2(items)  # Disabled
    step3(items)
    step4(items)
    # Bug still occurs? Must be in step3 or step4
```

**Best practices**:
- Use version control to track changes
- Keep system in valid state while testing
- Document which sections you've eliminated

**Pros**: Efficient for large codebases
**Cons**: Requires careful isolation

### 4. Rubber Duck Debugging
**When to use**: Stuck, can't see the obvious issue.

**How**:
1. Explain code line-by-line to a rubber duck (or person)
2. Describe what each line does
3. Verify assumptions as you go
4. Often reveals the issue through explanation

**Why it works**: Forces you to articulate assumptions you haven't examined.

**Best practices**:
- Go slowly, don't skip "obvious" parts
- Explain why, not just what
- Question every assumption

**Pros**: No tools needed, reveals assumptions
**Cons**: Feels silly, time-consuming

### 5. Differential Debugging
**When to use**: Bug appeared after changes, works in one version not another.

**How**:
```bash
# Git bisect to find bug-introducing commit
git bisect start
git bisect bad  # Current version is bad
git bisect good v1.2.3  # Last known good version
# Git checks out middle commit
# Test if bug exists
git bisect good  # or bad
# Repeat until bug-introducing commit found
```

**Compare**:
- Working version vs broken version
- Development vs production
- Different environments
- Different data sets

**Best practices**:
- Have automated test to speed bisect
- Keep bisect search focused
- Document what changed

**Pros**: Quickly finds when bug was introduced
**Cons**: Requires version history

### 6. Stack Trace Analysis
**When to use**: Exception or crash with stack trace.

**How to read stack traces**:
```
Traceback (most recent call last):
  File "main.py", line 42, in main          ← Entry point
    result = process(data)
  File "processor.py", line 15, in process  ← Calling function
    return analyze(data)
  File "analyzer.py", line 78, in analyze   ← Where error occurred
    value = data['key'].lower()
AttributeError: 'NoneType' object has no attribute 'lower'  ← Error
```

**Analysis steps**:
1. **Read error message**: `'NoneType' has no attribute 'lower'`
   - `data['key']` is None

2. **Find error location**: `analyzer.py:78`
   - This is where to look first

3. **Trace call path**: main → process → analyze
   - Where did None come from?

4. **Check each frame**: Inspect variables at each level
   - Was data valid in main?
   - Did process modify it?
   - Did analyze receive None?

**Best practices**:
- Read from bottom up (where error occurred)
- Check each stack frame for clues
- Look for your code vs library code
- Identify last place you controlled data

**Pros**: Points directly to error location
**Cons**: May be symptom, not root cause

### 7. Hypothesis Testing
**When to use**: Multiple possible causes, need systematic elimination.

**How**:
1. List all hypotheses
2. Rank by likelihood and impact
3. Design test for each
4. Execute tests systematically
5. Document results
6. Refine hypotheses based on results

**Example**:
```markdown
Hypotheses for "API returns 500":
1. Database connection timeout (High likelihood, High impact)
   Test: Check database logs
   Result: ❌ Ruled out - no timeout errors

2. Invalid input data (Medium likelihood, High impact)
   Test: Log request payload
   Result: ✅ Confirmed - null in required field

3. Server out of memory (Low likelihood, High impact)
   Test: Check server metrics
   Result: ❌ Ruled out - memory usage normal
```

**Best practices**:
- Write down hypotheses (don't keep in head)
- Test highest impact first
- Don't test multiple at once
- Document what ruled out each hypothesis

**Pros**: Systematic, prevents wasted effort
**Cons**: Requires discipline, documentation

### 8. Logging Analysis
**When to use**: Production bugs, intermittent issues, distributed systems.

**What to look for**:
- Errors and exceptions
- Timing patterns (when errors occur)
- Correlation (what happens before error)
- Anomalies (unexpected values, patterns)

**Log analysis tools**:
- `grep` for pattern matching
- `awk` for field extraction
- `sort | uniq -c` for frequency counting
- Log aggregation tools (ELK, Splunk)

**Example**:
```bash
# Find all errors in last hour
grep ERROR app.log | grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')"

# Count error types
grep ERROR app.log | awk '{print $5}' | sort | uniq -c | sort -rn

# Find requests that took >1s
awk '$7 > 1000 {print $0}' access.log
```

**Best practices**:
- Use structured logging (JSON)
- Include correlation IDs
- Log context, not just errors
- Use appropriate log levels

**Pros**: Works for production issues
**Cons**: Requires good logging infrastructure

---

## Common Pitfalls

### Pitfall 1: Assuming, Not Verifying
**Mistake**: "I know what's wrong" without testing.

**Fix**: Test every assumption, even obvious ones.

**Example**:
```python
# Assumption: user is never None
# Reality: user can be None after failed login
if user.is_admin:  # Crashes if user is None
    ...

# Fix: Verify assumption
assert user is not None, "User should not be None here"
```

### Pitfall 2: Changing Multiple Things
**Mistake**: Making several changes at once.

**Fix**: Change one thing, test, then change another.

**Example**:
```python
# Bad: Changed 3 things
- Added null check
- Changed algorithm
- Updated logging

# If bug is fixed, which change fixed it?

# Good: Change one at a time
1. Add null check → Test → Still broken
2. Change algorithm → Test → Fixed! (this was it)
```

### Pitfall 3: Treating Symptoms, Not Causes
**Mistake**: Fixing the immediate error without understanding why.

**Fix**: Ask "Why?" five times to find root cause.

**Example**:
```python
# Symptom: NullPointerException
# Surface fix: Add null check
if value is not None:
    result = value.lower()

# Root cause: Why is value None?
# Because: User lookup failed
# Why: Database query returned empty
# Why: User ID was invalid
# Why: Input validation missing
# Fix: Add input validation (prevents root cause)
```

### Pitfall 4: Debugging by Random Changes
**Mistake**: Trying random things hoping something works.

**Fix**: Form hypothesis, test systematically.

**Example**:
```python
# Random: Let me try changing this timeout
# Random: Maybe if I reload the page
# Random: What if I restart the server

# Systematic:
# Hypothesis: Timeout is too short for large datasets
# Test: Measure query time with large dataset
# Result: Query takes 35s, timeout is 30s
# Fix: Increase timeout OR optimize query
```

### Pitfall 5: Not Reproducing Reliably
**Mistake**: Debugging without consistent reproduction.

**Fix**: First invest in reliable reproduction.

**Why it matters**: Can't verify fix if can't reproduce bug.

### Pitfall 6: Debugging in Production
**Mistake**: Making changes directly in production to debug.

**Fix**: Reproduce in dev/staging environment.

**Exception**: Critical production issue with no other option.
- Make minimal changes
- Have rollback plan
- Document everything

---

## Debugging Mindset

### Be Systematic
- Follow a process
- Document findings
- Don't skip steps

### Be Patient
- Rushing leads to mistakes
- Take breaks when stuck
- Sleep on difficult bugs

### Be Skeptical
- Question assumptions
- Verify "obvious" things
- Don't trust without evidence

### Be Curious
- Understand why, not just what
- Learn from every bug
- Build debugging intuition

### Be Collaborative
- Explain to others (rubber duck)
- Ask for help when stuck
- Share learnings

---

## Debugging Checklist

Before starting:
- [ ] Read error message completely
- [ ] Understand expected behavior
- [ ] Have reliable reproduction steps

During debugging:
- [ ] Form hypothesis before changing code
- [ ] Change one thing at a time
- [ ] Document what you try
- [ ] Test each change

Before marking as fixed:
- [ ] Understand root cause
- [ ] Have regression test
- [ ] Verify no side effects
- [ ] Document solution

---

## Resources

**Books**:
- "Debugging: The 9 Indispensable Rules" by David Agans
- "The Pragmatic Programmer" by Hunt & Thomas

**Tools**:
- Debuggers (pdb, gdb, Chrome DevTools)
- Profilers (cProfile, py-spy, perf)
- Log aggregation (ELK stack, Splunk)
- APM tools (New Relic, Datadog)

**Techniques**:
- Scientific method
- Binary search
- Hypothesis testing
- Root cause analysis (5 Whys, Fishbone)
