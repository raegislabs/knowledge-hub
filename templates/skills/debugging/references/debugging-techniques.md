# Debugging Techniques Reference

## Overview
Practical debugging techniques with examples and when to use each. This is a hands-on companion to the debugging methodology guide.

---

## Print/Log Debugging

### Basic Technique
**Best for**: Quick investigation, simple bugs, production debugging.

```python
# Python
print(f"DEBUG: variable = {variable}")
logger.debug(f"Function called with param={param}")

# JavaScript
console.log('DEBUG: variable =', variable);
console.debug('Function called with', { param });
```

### Strategic Logging
Don't just log everything - be strategic:

```python
# At function entry
logger.info(f"process_order called: order_id={order_id}, user_id={user_id}")

# Before critical operations
logger.debug(f"About to query database: {query}")

# After critical operations
logger.debug(f"Database returned {len(results)} results")

# At decision points
if condition:
    logger.debug(f"Taking path A because {reason}")
else:
    logger.debug(f"Taking path B because {reason}")

# At function exit
logger.info(f"process_order complete: status={status}, time={duration}ms")
```

### Log Levels
Use appropriate levels:

```python
# ERROR: Something failed
logger.error(f"Failed to process order {order_id}: {error}")

# WARNING: Something unexpected but not fatal
logger.warning(f"Order {order_id} missing optional field: {field}")

# INFO: Important business events
logger.info(f"Order {order_id} completed successfully")

# DEBUG: Detailed diagnostic information
logger.debug(f"Checking inventory for item {item_id}")

# TRACE: Very detailed, typically disabled
logger.trace(f"Variable state: {vars()}")
```

### Structured Logging
Better than string concatenation:

```python
# Bad: String concatenation
logger.info(f"User {user_id} placed order {order_id} for ${amount}")

# Good: Structured fields
logger.info(
    "Order placed",
    extra={
        "user_id": user_id,
        "order_id": order_id,
        "amount": amount,
        "currency": "USD"
    }
)

# Allows querying: "All orders > $100" or "All orders by user 123"
```

### Temporary Debug Logging
Mark clearly and remove after debugging:

```python
# DEBUG_START - Remove before commit
logger.debug(f"TEMP: Variable state = {variable}")
print(f"DEBUG: Checkpoint reached")
# DEBUG_END
```

---

## Breakpoint Debugging

### IDE Breakpoints
**Best for**: Complex logic, inspecting state, stepping through execution.

**Setting breakpoints**:
- Click left margin in IDE
- Set conditional breakpoints (only stop when condition true)
- Set logpoint (log without stopping)

### Interactive Debugger (pdb)

```python
# Python debugger
import pdb; pdb.set_trace()  # Pause here

# Or use breakpoint() in Python 3.7+
breakpoint()  # Pause here
```

**Common pdb commands**:
```
n (next)       - Execute next line
s (step)       - Step into function
c (continue)   - Continue to next breakpoint
l (list)       - Show current code
p variable     - Print variable
pp variable    - Pretty-print variable
w (where)      - Show stack trace
u (up)         - Move up stack frame
d (down)       - Move down stack frame
q (quit)       - Exit debugger
```

### JavaScript Debugger

```javascript
// In browser code
debugger;  // Pause here when DevTools open

// In Node.js
node inspect script.js
```

**Chrome DevTools debugging**:
- Set breakpoints by clicking line numbers
- Use "Watch" panel to monitor variables
- Use "Call Stack" to see execution path
- Use "Scope" to see all variables in scope

### Conditional Breakpoints

```python
# Only pause when specific condition is true
# In IDE: Right-click breakpoint → Edit → Condition

# Example: Only pause when user_id is 123
# Condition: user_id == 123

# Example: Only pause on 100th iteration
# Condition: loop_counter == 100

# Example: Only pause when error occurs
# Condition: result.status == 'error'
```

### Watch Expressions

Monitor expressions while debugging:

```
# Watch Panel in IDE
user.is_admin
len(items)
sum(item.price for item in cart)
```

### Logpoints (Non-breaking Breakpoints)

Log without pausing execution:

```
# IDE Logpoint: Right-click line → Add Logpoint
# Message: "User {user_id} reached checkpoint"
# Equivalent to adding logger.debug(), but no code change
```

---

## Binary Search Debugging

### Technique Overview
**Best for**: Bug somewhere in recent changes or large codebase.

### Git Bisect
Find commit that introduced bug:

```bash
# Start bisect
git bisect start

# Mark current version as bad
git bisect bad

# Mark last known good version
git bisect good v1.2.0

# Git checks out middle commit
# Test if bug exists
./run_test.sh

# If bug exists
git bisect bad

# If bug doesn't exist
git bisect good

# Repeat until git finds first bad commit
# Git will output: "abc123 is the first bad commit"

# Reset when done
git bisect reset
```

### Automated Bisect

```bash
# Write test script that exits 0 if good, 1 if bad
cat > test.sh << 'EOF'
#!/bin/bash
python -m pytest tests/test_bug.py
EOF

chmod +x test.sh

# Run automated bisect
git bisect start HEAD v1.2.0
git bisect run ./test.sh

# Git automatically finds first bad commit
```

### Code Bisect
Binary search within code:

```python
def process_items(items):
    step1(items)
    step2(items)
    step3(items)  # Bug somewhere in process_items
    step4(items)
    step5(items)
    step6(items)

# Test by commenting out half
def process_items(items):
    step1(items)
    step2(items)
    step3(items)
    # step4(items)  # Disabled
    # step5(items)  # Disabled
    # step6(items)  # Disabled

# If bug still occurs, it's in step1-3
# If bug gone, it's in step4-6
# Repeat until isolated
```

---

## Rubber Duck Debugging

### Technique Overview
**Best for**: When stuck, can't see obvious issue.

### How to Rubber Duck

1. **Get a rubber duck** (or colleague, pet, houseplant)

2. **Explain your code line by line**:
   ```
   "This function takes a user ID.
    First, it queries the database for the user.
    Then it checks if the user exists.
    Wait... I'm checking if user exists AFTER calling user.email.
    That's the bug! I need to check before accessing user.email."
   ```

3. **Describe what each line should do**:
   - "This should validate the input"
   - "This should calculate the total"
   - "This should... wait, why am I doing this here?"

4. **Question every assumption**:
   - "I assume the user is always logged in... but what if they're not?"
   - "I assume the list has items... but what if it's empty?"

### Virtual Rubber Duck

Write it out as a comment:

```python
def problematic_function(data):
    # RUBBER DUCK SESSION
    # I'm trying to process user data
    # First I get the user from the database
    user = db.query(User).filter_by(id=data['user_id']).first()

    # Then I access the user's email
    # WAIT - what if user is None? (query returned nothing)
    # That's the bug! I need to check if user exists first

    if user is None:
        logger.warning(f"User not found: {data['user_id']}")
        return None

    email = user.email.lower()
    # ... rest of function
```

---

## Differential Debugging

### Comparing Versions
**Best for**: "It worked before, now it's broken."

### Compare Code

```bash
# See what changed between versions
git diff v1.2.0..v1.3.0 src/module.py

# Compare working branch to broken branch
git diff working-branch..broken-branch

# See changes in last N commits
git log -p -5 -- src/module.py
```

### Compare Environments

```python
# Development vs Production
# Check configuration differences
diff dev_config.yml prod_config.yml

# Check dependency versions
diff dev_requirements.txt prod_requirements.txt

# Check environment variables
env | grep APP_  # In each environment
```

### Compare Data

```python
# Working dataset vs broken dataset
# What's different about data that triggers bug?

# Log data characteristics
logger.debug(f"Data size: {len(data)}")
logger.debug(f"Data type: {type(data)}")
logger.debug(f"Data sample: {data[:5]}")
logger.debug(f"Null values: {sum(1 for x in data if x is None)}")
logger.debug(f"Empty strings: {sum(1 for x in data if x == '')}")
```

---

## Stack Trace Analysis

### Reading Stack Traces

Python stack trace:
```
Traceback (most recent call last):
  File "main.py", line 42, in <module>
    result = process(data)
  File "processor.py", line 15, in process
    return analyze(data)
  File "analyzer.py", line 78, in analyze
    value = data['key'].lower()
KeyError: 'key'
```

**How to read**:
1. **Bottom up**: Error is at bottom (`KeyError: 'key'`)
2. **Location**: `analyzer.py:78` is where error occurred
3. **Call path**: main → process → analyze
4. **Error type**: `KeyError` means dictionary key not found

JavaScript stack trace:
```
TypeError: Cannot read property 'toLowerCase' of undefined
    at analyze (analyzer.js:78:24)
    at process (processor.js:15:10)
    at main (main.js:42:12)
```

**How to read**:
1. **Top line**: Error type and message
2. **Stack frames**: Most recent first (analyze → process → main)
3. **File:line:column**: Exact location of error

### Analyzing Stack Frames

For each frame, ask:
- What's the state of variables here?
- Was data valid at this level?
- Did this function change data?
- Are we using correct parameters?

```python
# Use debugger to inspect each frame
import pdb; pdb.set_trace()

# When in debugger:
w              # Show full stack
u              # Move up a frame
p variable     # Print variable in this frame
u              # Move up another frame
p variable     # Compare value here
```

---

## Logging Analysis

### Finding Patterns in Logs

```bash
# Find all errors
grep ERROR application.log

# Count error types
grep ERROR application.log | awk '{print $6}' | sort | uniq -c | sort -rn

# Errors in last hour
grep ERROR application.log | grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')"

# Follow specific request
grep "request_id=abc123" application.log

# Find slow requests
awk '$8 > 1000 {print}' access.log  # Response time > 1s
```

### Correlation Analysis

Find what happens before errors:

```bash
# Get timestamp of error
ERROR_TIME=$(grep "KeyError" app.log | head -1 | awk '{print $1}')

# Get logs from 1 minute before error
grep "$ERROR_TIME" app.log | head -100

# Look for pattern:
# - What user action preceded it?
# - What data was being processed?
# - What system state?
```

---

## Memory Debugging

### Finding Memory Leaks

```python
# Track memory usage
import tracemalloc

tracemalloc.start()

# Your code here
process_data()

# Get memory snapshot
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')

# Show top 10 memory consumers
for stat in top_stats[:10]:
    print(stat)
```

### Object Tracking

```python
import gc
import sys

# Count objects of specific type
def count_objects(obj_type):
    return sum(1 for obj in gc.get_objects() if isinstance(obj, obj_type))

# Before operation
before = count_objects(MyClass)

# Perform operation
process_data()

# After operation
after = count_objects(MyClass)

print(f"Objects created: {after - before}")
# If this number keeps growing, you have a leak
```

---

## Performance Debugging

### Profiling CPU Usage

```python
import cProfile
import pstats

# Profile code
cProfile.run('process_data()', 'profile_stats')

# Analyze results
stats = pstats.Stats('profile_stats')
stats.sort_stats('cumulative')
stats.print_stats(10)  # Top 10 slowest functions
```

### Timing Specific Sections

```python
import time

def timed_function(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        duration = (time.time() - start) * 1000
        logger.debug(f"{func.__name__} took {duration:.2f}ms")
        return result
    return wrapper

@timed_function
def slow_operation():
    # Your code
    pass
```

### Finding Bottlenecks

```python
# Profile line by line
from line_profiler import LineProfiler

profiler = LineProfiler()
profiler.add_function(process_data)
profiler.enable()

process_data()

profiler.disable()
profiler.print_stats()
```

---

## Network Debugging

### Inspecting HTTP Requests

```bash
# Using curl with verbose output
curl -v https://api.example.com/endpoint

# Capture full request/response
curl -v --trace-ascii - https://api.example.com/endpoint

# Measure timing
curl -w "@curl-format.txt" -o /dev/null -s https://example.com
```

curl-format.txt:
```
time_namelookup:  %{time_namelookup}\n
time_connect:     %{time_connect}\n
time_appconnect:  %{time_appconnect}\n
time_pretransfer: %{time_pretransfer}\n
time_starttransfer: %{time_starttransfer}\n
time_total:       %{time_total}\n
```

### Using Browser DevTools

1. Open DevTools (F12)
2. Network tab
3. Reload page
4. Click request to see:
   - Headers
   - Request payload
   - Response
   - Timing breakdown

### Packet Capture

```bash
# Capture network traffic
tcpdump -i any -w capture.pcap port 8080

# Read capture
tcpdump -r capture.pcap -A
```

---

## Testing-Based Debugging

### Write Test that Reproduces Bug

```python
def test_bug_reproduction():
    """Test that reproduces the bug."""
    # Exact steps from bug report
    user = User(email=None)  # This is the problematic input
    result = process_user(user)

    # This will fail until bug is fixed
    assert result is not None
```

### Use Minimal Reproduction

```python
# Instead of full application
def test_minimal_reproduction():
    """Minimal case that triggers bug."""
    # Just the specific function with specific input
    result = problematic_function(None)
    # Should not crash
```

### Parametrized Testing for Edge Cases

```python
@pytest.mark.parametrize("input_data,expected", [
    (None, None),
    ([], []),
    ({}, {}),
    ("", ""),
    # Add case that reproduces bug
    ({"key": None}, ???),  # What should happen?
])
def test_edge_cases(input_data, expected):
    result = function_under_test(input_data)
    assert result == expected
```

---

## Debugging Checklist

When stuck, try these in order:

1. [ ] Read the error message completely
2. [ ] Add strategic logging
3. [ ] Use debugger with breakpoints
4. [ ] Rubber duck (explain to someone/something)
5. [ ] Binary search (disable half the code)
6. [ ] Check stack trace for clues
7. [ ] Compare with working version (git diff)
8. [ ] Write minimal reproduction test
9. [ ] Search for similar issues
10. [ ] Take a break (fresh perspective helps)
