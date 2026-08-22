# Common Bug Patterns Reference

## Overview
Catalog of frequently encountered bug patterns with examples, detection methods, and fixes. Use this as a quick reference when debugging or during code review.

---

## Off-by-One Errors

### Pattern Description
Looping one time too many or too few, typically with array indexing or range operations.

### Common Causes
- Using `<=` instead of `<` in loop conditions
- Forgetting arrays are zero-indexed
- Incorrect range bounds

### Examples

**Example 1: Array Index**
```python
# Bug: Tries to access index 10 when array has 10 elements (0-9)
items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
for i in range(0, 11):  # Wrong! Should be range(0, 10) or range(10)
    print(items[i])  # IndexError on i=10
```

**Fix**:
```python
# Correct: Use len() or proper range
items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
for i in range(len(items)):  # or range(10)
    print(items[i])

# Or use iteration directly
for item in items:
    print(item)
```

**Example 2: Pagination**
```python
# Bug: Incorrect page calculation
def get_page(items, page_num, page_size):
    start = page_num * page_size  # Off by one for 1-indexed pages!
    end = start + page_size
    return items[start:end]

# For page 1: start=10, end=20 (skips first 10 items!)
```

**Fix**:
```python
def get_page(items, page_num, page_size):
    # If pages are 1-indexed, subtract 1
    start = (page_num - 1) * page_size
    end = start + page_size
    return items[start:end]

# For page 1: start=0, end=10 (correct!)
```

### Detection
- Boundary condition testing
- Check loop conditions carefully
- Test with smallest and largest valid indices

### Prevention
- Use language idioms (`for item in items` instead of indices)
- Test boundary cases explicitly
- Use inclusive/exclusive conventions consistently

---

## Null/None Handling

### Pattern Description
Attempting to access properties or methods on null/None values.

### Common Causes
- Missing null checks
- Assuming database queries always return results
- Not validating optional parameters
- Chaining methods without null checks

### Examples

**Example 1: Null Pointer**
```python
# Bug: user could be None
def process_user(user_id):
    user = db.query(User).filter_by(id=user_id).first()  # Returns None if not found
    email = user.email.lower()  # AttributeError if user is None
    return email
```

**Fix**:
```python
def process_user(user_id):
    user = db.query(User).filter_by(id=user_id).first()
    if user is None:
        logger.warning(f"User {user_id} not found")
        return None
    email = user.email.lower()
    return email

# Or use Optional type hint
from typing import Optional

def process_user(user_id: int) -> Optional[str]:
    user = db.query(User).filter_by(id=user_id).first()
    return user.email.lower() if user else None
```

**Example 2: Optional Chain**
```javascript
// Bug: Accessing nested property without null checks
function getCity(user) {
    return user.address.city.name;  // Crashes if any part is null
}
```

**Fix**:
```javascript
// Option 1: Manual checks
function getCity(user) {
    if (user && user.address && user.address.city) {
        return user.address.city.name;
    }
    return null;
}

// Option 2: Optional chaining (modern JavaScript)
function getCity(user) {
    return user?.address?.city?.name ?? null;
}
```

### Detection
- Look for object property access without null checks
- Check all database query results
- Review function parameters that could be None
- Use static type checkers (mypy, TypeScript)

### Prevention
- Validate inputs at function entry
- Use type hints with `Optional`
- Return default values instead of null when possible
- Use null-safe navigation operators

---

## Race Conditions

### Pattern Description
Bugs that occur when timing or order of operations matters, typically in concurrent or asynchronous code.

### Common Causes
- Shared mutable state without synchronization
- Assuming sequential execution in async code
- Missing locks on critical sections
- Time-of-check to time-of-use (TOCTOU) issues

### Examples

**Example 1: Shared Counter**
```python
# Bug: Non-atomic increment
class Counter:
    def __init__(self):
        self.count = 0

    def increment(self):
        self.count += 1  # Not atomic! Read-modify-write race

# Two threads both read count=0, both increment, both write count=1
# Result: count=1 instead of expected count=2
```

**Fix**:
```python
import threading

class Counter:
    def __init__(self):
        self.count = 0
        self.lock = threading.Lock()

    def increment(self):
        with self.lock:  # Atomic increment
            self.count += 1

# Or use atomic operations
from threading import Lock
from collections import defaultdict

counter = defaultdict(int)
lock = Lock()

with lock:
    counter['key'] += 1
```

**Example 2: TOCTOU (Time-of-Check Time-of-Use)**
```python
# Bug: File could be deleted between check and use
if os.path.exists(filepath):
    # Another process could delete file here!
    with open(filepath) as f:  # FileNotFoundError
        data = f.read()
```

**Fix**:
```python
# Don't check, just handle error
try:
    with open(filepath) as f:
        data = f.read()
except FileNotFoundError:
    logger.warning(f"File not found: {filepath}")
    data = None
```

**Example 3: Async Race**
```python
# Bug: Assuming async operations complete in order
async def process_user(user_id):
    user = await fetch_user(user_id)  # Takes 100ms
    permissions = await fetch_permissions(user_id)  # Takes 50ms
    # Total: 150ms (sequential)

    # If fetch_permissions completes first, user might not be set yet
    return user, permissions
```

**Fix**:
```python
# Wait for both concurrently
async def process_user(user_id):
    user, permissions = await asyncio.gather(
        fetch_user(user_id),
        fetch_permissions(user_id)
    )
    # Total: 100ms (parallel), both guaranteed complete
    return user, permissions
```

### Detection
- Intermittent failures
- Bugs that disappear when adding logging
- Different behavior under load
- Testing with race condition detectors (ThreadSanitizer, etc.)

### Prevention
- Use locks/semaphores for shared state
- Prefer immutable data structures
- Use atomic operations
- Test under concurrent load
- Avoid shared mutable state when possible

---

## Type Mismatches

### Pattern Description
Operating on data of unexpected type, often due to implicit conversions or missing validation.

### Common Causes
- Mixing strings and numbers
- Assuming JSON types
- Database returns different type than expected
- Missing type validation on API inputs

### Examples

**Example 1: String vs Number**
```python
# Bug: ID comes from URL as string
def get_user(user_id):
    # user_id = "123" (string from URL parameter)
    user = db.query(User).filter_by(id=user_id).first()  # Comparison "123" == 123 fails
    return user  # None!
```

**Fix**:
```python
def get_user(user_id):
    # Convert to int explicitly
    user_id = int(user_id)
    user = db.query(User).filter_by(id=user_id).first()
    return user

# Or use type hints and validation
def get_user(user_id: int) -> Optional[User]:
    if not isinstance(user_id, int):
        raise TypeError(f"user_id must be int, got {type(user_id)}")
    user = db.query(User).filter_by(id=user_id).first()
    return user
```

**Example 2: List vs Single Item**
```python
# Bug: Sometimes returns list, sometimes single item
def get_items(query):
    if query == "all":
        return [item1, item2, item3]  # List
    else:
        return item1  # Single item!

# Consumer code assumes list
items = get_items(query)
for item in items:  # Fails if single item returned
    process(item)
```

**Fix**:
```python
# Always return same type
def get_items(query):
    if query == "all":
        return [item1, item2, item3]
    else:
        return [item1]  # List with one item

# Or explicitly handle both cases
def get_items(query):
    if query == "all":
        return [item1, item2, item3]
    else:
        return item1

# Consumer checks type
items = get_items(query)
if not isinstance(items, list):
    items = [items]  # Normalize to list
for item in items:
    process(item)
```

### Detection
- Type checkers (mypy, TypeScript)
- Runtime type validation
- Test with different input types
- Use strongly-typed languages/modes

### Prevention
- Use type hints
- Validate types at API boundaries
- Be explicit about conversions
- Document expected types

---

## Memory Leaks

### Pattern Description
Memory that's allocated but never freed, causing gradual memory growth.

### Common Causes
- Circular references
- Event listeners not removed
- Caches without size limits
- Resources not closed (files, connections)

### Examples

**Example 1: Circular Reference**
```python
# Bug: Parent and child reference each other, preventing GC
class Parent:
    def __init__(self):
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        child.parent = self  # Circular reference!

# Objects never freed even when no longer needed
```

**Fix**:
```python
import weakref

class Parent:
    def __init__(self):
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        child.parent = weakref.ref(self)  # Weak reference breaks cycle

# Or manually break cycle
parent.children = []  # Clear references when done
```

**Example 2: Unbounded Cache**
```python
# Bug: Cache grows forever
cache = {}

def expensive_operation(key):
    if key not in cache:
        cache[key] = compute_expensive(key)  # Cache grows without limit
    return cache[key]
```

**Fix**:
```python
from functools import lru_cache

@lru_cache(maxsize=1000)  # Limit cache size
def expensive_operation(key):
    return compute_expensive(key)

# Or use explicit cache with eviction
from collections import OrderedDict

class LRUCache:
    def __init__(self, max_size=1000):
        self.cache = OrderedDict()
        self.max_size = max_size

    def get(self, key):
        if key in self.cache:
            self.cache.move_to_end(key)  # Mark as recently used
            return self.cache[key]
        return None

    def put(self, key, value):
        if len(self.cache) >= self.max_size:
            self.cache.popitem(last=False)  # Remove oldest
        self.cache[key] = value
```

**Example 3: Unclosed Resources**
```python
# Bug: File handle leak
def read_config():
    f = open('config.txt')
    data = f.read()
    # f never closed! Leaks file handle
    return data
```

**Fix**:
```python
# Use context manager
def read_config():
    with open('config.txt') as f:
        data = f.read()
    # f automatically closed
    return data
```

### Detection
- Monitor memory usage over time
- Use memory profilers (tracemalloc, heapy)
- Check for unclosed resources
- Use leak detection tools

### Prevention
- Use context managers (`with` statements)
- Implement `__del__` methods carefully
- Use weak references for callbacks/caches
- Limit cache sizes
- Close resources explicitly

---

## Async/Await Issues

### Pattern Description
Incorrect use of async/await leading to blocking, race conditions, or unexpected behavior.

### Common Causes
- Forgetting `await`
- Mixing sync and async code
- Not handling exceptions in async code
- Deadlocks in async code

### Examples

**Example 1: Forgotten await**
```python
# Bug: Forgot await, gets coroutine instead of result
async def fetch_data():
    return "data"

async def process():
    data = fetch_data()  # BUG! Missing await
    print(data)  # Prints: <coroutine object fetch_data>
```

**Fix**:
```python
async def process():
    data = await fetch_data()  # Correct
    print(data)  # Prints: "data"
```

**Example 2: Blocking in Async**
```python
# Bug: Blocking call in async function
import time
import asyncio

async def process():
    time.sleep(5)  # BUG! Blocks entire event loop
    return "done"
```

**Fix**:
```python
import asyncio

async def process():
    await asyncio.sleep(5)  # Non-blocking
    return "done"
```

**Example 3: Unhandled Async Exceptions**
```python
# Bug: Exception in async task is silently swallowed
async def background_task():
    raise Exception("This error is lost!")

async def main():
    task = asyncio.create_task(background_task())
    # Exception happens but isn't handled
```

**Fix**:
```python
async def main():
    task = asyncio.create_task(background_task())
    try:
        await task  # Raises exception
    except Exception as e:
        logger.error(f"Background task failed: {e}")

# Or add done callback
def handle_result(task):
    try:
        task.result()
    except Exception as e:
        logger.error(f"Task failed: {e}")

task = asyncio.create_task(background_task())
task.add_done_callback(handle_result)
```

### Detection
- Type checkers warn about unawaited coroutines
- Test async code thoroughly
- Use async linters

### Prevention
- Always `await` async functions
- Use async libraries for I/O
- Handle exceptions in async code
- Test with async test frameworks

---

## SQL Injection

### Pattern Description
Unsanitized user input in SQL queries allowing malicious SQL execution.

### Common Causes
- String concatenation for SQL queries
- Not using parameterized queries
- Improper escaping

### Examples

**Example 1: Classic SQL Injection**
```python
# Bug: User input directly in SQL
def get_user(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(query)

# Attacker inputs: admin' OR '1'='1
# Query becomes: SELECT * FROM users WHERE username = 'admin' OR '1'='1'
# Returns all users!
```

**Fix**:
```python
# Use parameterized queries
def get_user(username):
    query = "SELECT * FROM users WHERE username = ?"
    return db.execute(query, (username,))

# Or use ORM
def get_user(username):
    return db.query(User).filter_by(username=username).first()
```

### Detection
- Code review for string concatenation in queries
- SQL injection scanners
- Security testing

### Prevention
- Always use parameterized queries
- Use ORMs
- Validate and sanitize input
- Principle of least privilege for database accounts

---

## Unhandled Exceptions

### Pattern Description
Exceptions that crash the program instead of being handled gracefully.

### Examples

**Example 1: No Error Handling**
```python
# Bug: Network error crashes program
def fetch_data(url):
    response = requests.get(url)  # Could timeout, 404, network error
    return response.json()  # Could be invalid JSON
```

**Fix**:
```python
def fetch_data(url):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise exception for 4xx/5xx
        return response.json()
    except requests.Timeout:
        logger.error(f"Timeout fetching {url}")
        return None
    except requests.HTTPError as e:
        logger.error(f"HTTP error {e.response.status_code}: {url}")
        return None
    except ValueError:  # JSON decode error
        logger.error(f"Invalid JSON from {url}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error fetching {url}: {e}")
        return None
```

### Prevention
- Wrap external calls in try/except
- Handle specific exceptions
- Have fallback behavior
- Log errors with context

---

## Quick Reference Table

| Pattern | Symptom | Common Fix |
|---------|---------|------------|
| Off-by-One | IndexError, wrong count | Check bounds, use len() |
| Null/None | AttributeError, NullPointerException | Add null checks |
| Race Condition | Intermittent failures | Add locks, use atomic ops |
| Type Mismatch | TypeError, unexpected behavior | Validate types, use type hints |
| Memory Leak | Growing memory usage | Close resources, limit caches |
| Async Issues | Blocking, wrong results | Use await, async libraries |
| SQL Injection | Security vulnerability | Parameterized queries |
| Unhandled Exception | Crashes | Try/except, graceful handling |
