# Mocking Patterns Reference Guide

## Overview

Mocking is the practice of replacing real dependencies with controlled test doubles. This guide covers when to mock, different types of test doubles, and best practices for effective mocking.

---

## Types of Test Doubles

### 1. Mock

**Definition:** Object that records interactions and allows verification of calls.

**Use when:** You need to verify that specific methods were called with specific arguments.

```python
# Python (unittest.mock)
from unittest.mock import Mock

def test_user_service_calls_email_service():
    # Arrange
    mock_email = Mock()
    user_service = UserService(email_service=mock_email)

    # Act
    user_service.register_user("test@example.com")

    # Assert - Verify method was called
    mock_email.send_welcome_email.assert_called_once_with("test@example.com")
```

```javascript
// JavaScript (Vitest)
import { vi } from 'vitest';

it('should call email service when registering user', () => {
  // Arrange
  const mockEmail = {
    sendWelcomeEmail: vi.fn()
  };
  const userService = new UserService(mockEmail);

  // Act
  userService.registerUser('test@example.com');

  // Assert
  expect(mockEmail.sendWelcomeEmail).toHaveBeenCalledWith('test@example.com');
});
```

### 2. Stub

**Definition:** Object that returns predefined responses, but doesn't verify interactions.

**Use when:** You need to control return values but don't care about verification.

```python
# Python
def test_user_service_handles_email_failure():
    # Arrange - Stub that always fails
    stub_email = Mock()
    stub_email.send_welcome_email.return_value = False

    user_service = UserService(email_service=stub_email)

    # Act
    result = user_service.register_user("test@example.com")

    # Assert - Focus on behavior, not interaction
    assert result.email_sent is False
```

```javascript
// JavaScript
it('should handle email service failure', () => {
  // Arrange
  const stubEmail = {
    sendWelcomeEmail: vi.fn().mockReturnValue(false)
  };

  // Act
  const result = userService.registerUser('test@example.com');

  // Assert
  expect(result.emailSent).toBe(false);
});
```

### 3. Spy

**Definition:** Wrapper around real object that records interactions while maintaining real behavior.

**Use when:** You want real functionality but also need to verify calls.

```python
# Python
def test_user_service_uses_real_validator_but_tracks_calls():
    # Arrange
    real_validator = EmailValidator()
    spy = Mock(wraps=real_validator)  # Spy on real object

    user_service = UserService(validator=spy)

    # Act
    user_service.register_user("test@example.com")

    # Assert - Real validation happened AND we can verify
    spy.validate.assert_called_once()
    assert spy.validate.return_value is True  # Real validation result
```

```javascript
// JavaScript
it('should use real validator and track calls', () => {
  // Arrange
  const realValidator = new EmailValidator();
  const spy = vi.spyOn(realValidator, 'validate');

  // Act
  userService.registerUser('test@example.com');

  // Assert
  expect(spy).toHaveBeenCalled();
  expect(spy).toHaveReturnedWith(true);  // Real result
});
```

### 4. Fake

**Definition:** Working implementation with simplified behavior (e.g., in-memory database).

**Use when:** Real implementation is too slow or complex, but you need realistic behavior.

```python
# Python - Fake database
class FakeUserRepository:
    """In-memory fake for testing."""
    def __init__(self):
        self.users = {}

    def save(self, user):
        self.users[user.id] = user

    def find_by_id(self, user_id):
        return self.users.get(user_id)

def test_user_service_with_fake_repository():
    # Arrange
    fake_repo = FakeUserRepository()
    user_service = UserService(repository=fake_repo)

    # Act
    user = user_service.create_user(email="test@example.com")

    # Assert
    assert fake_repo.find_by_id(user.id) is not None
```

```javascript
// JavaScript - Fake API client
class FakeApiClient {
  constructor() {
    this.data = new Map();
  }

  async get(id) {
    return this.data.get(id);
  }

  async post(data) {
    const id = Date.now();
    this.data.set(id, { ...data, id });
    return { id };
  }
}
```

### 5. Dummy

**Definition:** Object passed around but never used (satisfies parameter requirements).

**Use when:** You need to fill parameters but value doesn't matter.

```python
# Python
def test_user_service_doesnt_use_logger():
    # Arrange - Dummy logger (not used in this test path)
    dummy_logger = None  # or Mock()

    user_service = UserService(logger=dummy_logger)

    # Act - Path that doesn't log
    result = user_service.get_user_count()

    # Assert
    assert result == 0
```

---

## When to Mock

### ✅ DO Mock

**External Services:**
```python
# Mock external API calls
@patch('requests.get')
def test_fetch_user_from_api(mock_get):
    mock_get.return_value.json.return_value = {"id": 1, "name": "Alice"}
    user = fetch_user_from_external_api(1)
    assert user["name"] == "Alice"
```

**Database Calls (in unit tests):**
```python
# Mock database in unit tests
def test_user_service_creates_user():
    mock_db = Mock()
    mock_db.save.return_value = User(id=1, email="test@example.com")

    service = UserService(db=mock_db)
    user = service.create_user(email="test@example.com")

    assert user.id == 1
    mock_db.save.assert_called_once()
```

**Slow Operations:**
```javascript
// Mock file system operations
it('should process file', () => {
  const mockFs = {
    readFile: vi.fn().mockReturnValue('file content')
  };
  const processor = new FileProcessor(mockFs);
  const result = processor.process('file.txt');
  expect(result).toBe('processed: file content');
});
```

**Non-Deterministic Behavior:**
```python
# Mock current time for consistent tests
@patch('datetime.datetime')
def test_is_expired(mock_datetime):
    mock_datetime.now.return_value = datetime(2025, 1, 1, 12, 0, 0)

    subscription = Subscription(expires_at=datetime(2025, 1, 1, 11, 0, 0))
    assert subscription.is_expired() is True
```

### ❌ DON'T Mock

**The System Under Test:**
```python
# BAD - Mocking what you're testing
def test_calculate_total():
    mock_calculator = Mock()
    mock_calculator.calculate_total.return_value = 100
    result = mock_calculator.calculate_total()  # This tests nothing!
    assert result == 100
```

**Value Objects:**
```python
# BAD - Mocking simple data
def test_user_age():
    mock_date = Mock()  # Unnecessary
    mock_date.year = 1990

    # GOOD - Use real date
    birthdate = date(1990, 1, 1)
    user = User(birthdate=birthdate)
    assert user.age > 0
```

**Simple Logic:**
```javascript
// BAD - Over-mocking
it('should add two numbers', () => {
  const mockMath = vi.fn().mockReturnValue(5);
  expect(mockMath(2, 3)).toBe(5);  // Tests the mock, not the logic!
});

// GOOD - Test real logic
it('should add two numbers', () => {
  expect(add(2, 3)).toBe(5);
});
```

---

## Mocking Patterns

### 1. Dependency Injection

**Best practice:** Inject dependencies explicitly for easy mocking.

```python
# Good - Dependencies injected
class UserService:
    def __init__(self, db, email_service, logger):
        self.db = db
        self.email_service = email_service
        self.logger = logger

# Easy to test
def test_user_service():
    mock_db = Mock()
    mock_email = Mock()
    mock_logger = Mock()

    service = UserService(db=mock_db, email=mock_email, logger=mock_logger)
```

```javascript
// Good - Dependencies injected
class UserService {
  constructor(db, emailService, logger) {
    this.db = db;
    this.emailService = emailService;
    this.logger = logger;
  }
}

// Easy to test
const mockDb = { save: vi.fn() };
const mockEmail = { send: vi.fn() };
const service = new UserService(mockDb, mockEmail);
```

### 2. Partial Mocking

**Mock only specific methods, keep rest real.**

```python
# Python
def test_user_service_partial_mock():
    user_service = UserService()

    # Mock only external call, keep rest real
    with patch.object(user_service, '_send_email') as mock_email:
        user_service.register_user("test@example.com")
        mock_email.assert_called_once()
```

```javascript
// JavaScript
it('should mock only specific method', () => {
  const service = new UserService();
  vi.spyOn(service, 'sendEmail').mockImplementation(() => true);

  service.registerUser('test@example.com');

  expect(service.sendEmail).toHaveBeenCalled();
});
```

### 3. Return Value Mocking

```python
# Python - Different return values per call
mock_api = Mock()
mock_api.get_user.side_effect = [
    {"id": 1, "name": "Alice"},  # First call
    {"id": 2, "name": "Bob"},    # Second call
    None                         # Third call
]

assert mock_api.get_user(1)["name"] == "Alice"
assert mock_api.get_user(2)["name"] == "Bob"
assert mock_api.get_user(3) is None
```

```javascript
// JavaScript
const mockApi = {
  getUser: vi.fn()
    .mockReturnValueOnce({ id: 1, name: 'Alice' })
    .mockReturnValueOnce({ id: 2, name: 'Bob' })
    .mockReturnValueOnce(null)
};
```

### 4. Exception Mocking

```python
# Python
def test_user_service_handles_database_error():
    mock_db = Mock()
    mock_db.save.side_effect = DatabaseError("Connection failed")

    service = UserService(db=mock_db)

    with pytest.raises(ServiceError):
        service.create_user(email="test@example.com")
```

```javascript
// JavaScript
it('should handle database error', async () => {
  const mockDb = {
    save: vi.fn().mockRejectedValue(new Error('Connection failed'))
  };

  await expect(service.createUser('test@example.com')).rejects.toThrow();
});
```

### 5. Async Mocking

```python
# Python
@pytest.mark.asyncio
async def test_async_fetch_data():
    mock_client = AsyncMock()
    mock_client.fetch.return_value = {"data": "value"}

    result = await fetch_data(mock_client)

    assert result["data"] == "value"
    mock_client.fetch.assert_called_once()
```

```javascript
// JavaScript
it('should fetch data asynchronously', async () => {
  const mockClient = {
    fetch: vi.fn().mockResolvedValue({ data: 'value' })
  };

  const result = await fetchData(mockClient);

  expect(result.data).toBe('value');
  expect(mockClient.fetch).toHaveBeenCalled();
});
```

---

## Mocking External Services

### HTTP Requests

```python
# Python (requests library)
@patch('requests.get')
def test_fetch_user(mock_get):
    # Mock response
    mock_response = Mock()
    mock_response.json.return_value = {"id": 1, "name": "Alice"}
    mock_response.status_code = 200
    mock_get.return_value = mock_response

    # Test
    user = fetch_user_from_api(1)

    assert user["name"] == "Alice"
    mock_get.assert_called_with("https://api.example.com/users/1")
```

```javascript
// JavaScript (fetch)
global.fetch = vi.fn().mockResolvedValue({
  ok: true,
  json: async () => ({ id: 1, name: 'Alice' })
});

it('should fetch user from API', async () => {
  const user = await fetchUser(1);
  expect(user.name).toBe('Alice');
});
```

### Database Mocking

```python
# Python - Mock SQLAlchemy session
def test_user_repository():
    mock_session = Mock()
    mock_session.query.return_value.filter_by.return_value.first.return_value = User(id=1)

    repo = UserRepository(session=mock_session)
    user = repo.find_by_id(1)

    assert user.id == 1
```

```javascript
// JavaScript - Mock Prisma client
const mockPrisma = {
  user: {
    findUnique: vi.fn().mockResolvedValue({ id: 1, email: 'test@example.com' }),
    create: vi.fn().mockResolvedValue({ id: 2, email: 'new@example.com' })
  }
};
```

### File System Mocking

```python
# Python
@patch('builtins.open', new_callable=mock_open, read_data='file content')
def test_read_file(mock_file):
    content = read_config_file('config.txt')
    assert content == 'file content'
    mock_file.assert_called_with('config.txt', 'r')
```

---

## Mock Assertions

### Python (unittest.mock)

```python
# Called once
mock.assert_called_once()
mock.assert_called_once_with(arg1, arg2)

# Called with specific args
mock.assert_called_with(arg1, arg2)
mock.assert_any_call(arg1, arg2)

# Call count
mock.assert_called()
assert mock.call_count == 3

# Not called
mock.assert_not_called()
```

### JavaScript (Vitest/Jest)

```javascript
// Called
expect(mock).toHaveBeenCalled();
expect(mock).toHaveBeenCalledTimes(3);

// Called with args
expect(mock).toHaveBeenCalledWith(arg1, arg2);
expect(mock).toHaveBeenLastCalledWith(arg1, arg2);

// Not called
expect(mock).not.toHaveBeenCalled();

// Return value
expect(mock).toHaveReturnedWith(value);
```

---

## Mocking Anti-Patterns

### ❌ Over-Mocking

```python
# BAD - Mocking everything
def test_user_service():
    mock_db = Mock()
    mock_email = Mock()
    mock_logger = Mock()
    mock_validator = Mock()
    mock_hasher = Mock()
    # ... 10 more mocks

    # This test is testing the mocks, not the real code!
```

**Solution:** Mock only external dependencies, test real logic.

### ❌ Mocking Internals

```javascript
// BAD - Testing implementation details
it('should call internal method', () => {
  const spy = vi.spyOn(service, '_internalHelper');
  service.publicMethod();
  expect(spy).toHaveBeenCalled();  // Brittle test
});

// GOOD - Test observable behavior
it('should return correct result', () => {
  const result = service.publicMethod();
  expect(result).toBe(expectedValue);
});
```

### ❌ Not Resetting Mocks

```python
# BAD - Mock state leaks between tests
mock_service = Mock()

def test_1():
    mock_service.do_thing()
    assert mock_service.do_thing.call_count == 1

def test_2():
    # Fails! Mock still has call from test_1
    assert mock_service.do_thing.call_count == 0  # Fails

# GOOD - Reset mocks
@pytest.fixture
def mock_service():
    return Mock()  # Fresh mock for each test
```

---

## Quick Reference

| Test Double | Use Case | Verifies Calls | Returns Values |
|-------------|----------|----------------|----------------|
| **Mock** | Verify interactions | ✅ Yes | ✅ Yes |
| **Stub** | Control return values | ❌ No | ✅ Yes |
| **Spy** | Track + real behavior | ✅ Yes | ✅ Yes (real) |
| **Fake** | Simplified implementation | ❌ No | ✅ Yes (fake) |
| **Dummy** | Fill parameters | ❌ No | ❌ No |

---

## Related References

- **unit-test-template.md** - Mocking in unit tests
- **integration-test-template.md** - When NOT to mock
- **testing-strategies.md** - Choosing when to use mocks
- **test-maintenance.md** - Maintaining mocked tests
