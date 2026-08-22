# Integration Test Template

## Overview

Integration tests verify that multiple components, modules, or systems work together correctly. They test interactions between units, database operations, API calls, and external services.

**Use this template when:**
- Testing API endpoints with real/mock databases
- Verifying database queries and transactions
- Testing service-to-service communication
- Validating multi-component workflows
- Testing middleware and authentication flows

---

## Template Structure

### Basic API Integration Test

```python
# Python (pytest + FastAPI/Flask)
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import get_db

@pytest.fixture
def client():
    """Create test client for API."""
    return TestClient(app)

@pytest.fixture
def db_session():
    """Create isolated database session for testing."""
    # Setup: Create test database
    engine = create_test_database()
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()

    yield db

    # Teardown: Clean up
    db.close()
    drop_test_database(engine)

def test_create_user_endpoint_returns_201(client, db_session):
    """Test POST /users creates user and returns 201."""
    # Arrange
    user_data = {
        "email": "alice@example.com",
        "name": "Alice Smith"
    }

    # Act
    response = client.post("/users", json=user_data)

    # Assert
    assert response.status_code == 201
    assert response.json()["email"] == user_data["email"]
    assert "id" in response.json()

    # Verify database state
    user = db_session.query(User).filter_by(email=user_data["email"]).first()
    assert user is not None
    assert user.name == user_data["name"]
```

```javascript
// JavaScript (Vitest + Express + Supertest)
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import request from 'supertest';
import app from '../src/app.js';
import { createTestDatabase, dropTestDatabase } from './helpers/db.js';

describe('POST /users', () => {
  let db;

  beforeEach(async () => {
    // Setup: Create test database
    db = await createTestDatabase();
  });

  afterEach(async () => {
    // Teardown: Clean up
    await dropTestDatabase(db);
  });

  it('should create user and return 201', async () => {
    // Arrange
    const userData = {
      email: 'alice@example.com',
      name: 'Alice Smith'
    };

    // Act
    const response = await request(app)
      .post('/users')
      .send(userData);

    // Assert
    expect(response.status).toBe(201);
    expect(response.body.email).toBe(userData.email);
    expect(response.body).toHaveProperty('id');

    // Verify database state
    const user = await db.query('SELECT * FROM users WHERE email = ?', [userData.email]);
    expect(user).toBeDefined();
    expect(user.name).toBe(userData.name);
  });
});
```

---

## Common Integration Test Patterns

### 1. Database Integration Tests

```python
# Python
def test_user_repository_creates_and_retrieves_user(db_session):
    """Test UserRepository can persist and retrieve users."""
    # Arrange
    repo = UserRepository(db_session)
    user_data = {"email": "bob@example.com", "name": "Bob"}

    # Act - Create
    created_user = repo.create(user_data)
    db_session.commit()

    # Assert - Retrieve
    retrieved_user = repo.get_by_id(created_user.id)
    assert retrieved_user.email == user_data["email"]
    assert retrieved_user.name == user_data["name"]

def test_transaction_rollback_on_error(db_session):
    """Test that database transaction rolls back on error."""
    # Arrange
    repo = UserRepository(db_session)

    # Act & Assert
    with pytest.raises(IntegrityError):
        repo.create({"email": None, "name": "Invalid"})  # Email is required

    db_session.rollback()

    # Verify no user was created
    assert db_session.query(User).count() == 0
```

```javascript
// JavaScript
describe('UserRepository', () => {
  it('should create and retrieve user from database', async () => {
    // Arrange
    const repo = new UserRepository(db);
    const userData = { email: 'bob@example.com', name: 'Bob' };

    // Act - Create
    const createdUser = await repo.create(userData);

    // Assert - Retrieve
    const retrievedUser = await repo.getById(createdUser.id);
    expect(retrievedUser.email).toBe(userData.email);
    expect(retrievedUser.name).toBe(userData.name);
  });

  it('should rollback transaction on error', async () => {
    // Arrange
    const repo = new UserRepository(db);

    // Act & Assert
    await expect(
      repo.create({ email: null, name: 'Invalid' })
    ).rejects.toThrow();

    // Verify no user was created
    const count = await db.query('SELECT COUNT(*) FROM users');
    expect(count).toBe(0);
  });
});
```

### 2. API Endpoint Tests (Full Request/Response Cycle)

```python
# Python
def test_get_user_by_id_returns_user_data(client, db_session):
    """Test GET /users/{id} returns user data."""
    # Arrange - Create user in database
    user = User(email="charlie@example.com", name="Charlie")
    db_session.add(user)
    db_session.commit()

    # Act
    response = client.get(f"/users/{user.id}")

    # Assert
    assert response.status_code == 200
    assert response.json()["id"] == user.id
    assert response.json()["email"] == user.email

def test_get_nonexistent_user_returns_404(client):
    """Test GET /users/{id} returns 404 for nonexistent user."""
    # Act
    response = client.get("/users/99999")

    # Assert
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()
```

```javascript
// JavaScript
describe('GET /users/:id', () => {
  it('should return user data when user exists', async () => {
    // Arrange - Create user in database
    const user = await db.insert('users', {
      email: 'charlie@example.com',
      name: 'Charlie'
    });

    // Act
    const response = await request(app).get(`/users/${user.id}`);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.id).toBe(user.id);
    expect(response.body.email).toBe(user.email);
  });

  it('should return 404 when user does not exist', async () => {
    // Act
    const response = await request(app).get('/users/99999');

    // Assert
    expect(response.status).toBe(404);
    expect(response.body.message).toMatch(/not found/i);
  });
});
```

### 3. Authentication & Authorization Tests

```python
# Python
def test_protected_endpoint_requires_authentication(client):
    """Test that protected endpoint returns 401 without token."""
    # Act
    response = client.get("/api/protected")

    # Assert
    assert response.status_code == 401

def test_protected_endpoint_allows_authenticated_user(client, auth_token):
    """Test that protected endpoint allows access with valid token."""
    # Act
    response = client.get(
        "/api/protected",
        headers={"Authorization": f"Bearer {auth_token}"}
    )

    # Assert
    assert response.status_code == 200

def test_admin_endpoint_denies_regular_user(client, regular_user_token):
    """Test that admin endpoint denies access to regular users."""
    # Act
    response = client.delete(
        "/api/admin/users/123",
        headers={"Authorization": f"Bearer {regular_user_token}"}
    )

    # Assert
    assert response.status_code == 403
```

### 4. External Service Integration (with Mocks)

```python
# Python
@pytest.fixture
def mock_payment_gateway(mocker):
    """Mock external payment gateway."""
    mock = mocker.patch('app.services.payment_gateway.PaymentGateway')
    mock.charge.return_value = {"transaction_id": "txn_123", "status": "success"}
    return mock

def test_checkout_processes_payment(client, db_session, mock_payment_gateway):
    """Test POST /checkout processes payment via gateway."""
    # Arrange
    order_data = {"items": [{"id": 1, "quantity": 2}], "total": 100.00}

    # Act
    response = client.post("/checkout", json=order_data)

    # Assert
    assert response.status_code == 200
    assert response.json()["status"] == "success"

    # Verify payment gateway was called
    mock_payment_gateway.charge.assert_called_once_with(
        amount=100.00,
        currency="USD"
    )

    # Verify order was created in database
    order = db_session.query(Order).first()
    assert order.total == 100.00
    assert order.status == "paid"
```

```javascript
// JavaScript
import { vi } from 'vitest';

describe('POST /checkout', () => {
  it('should process payment via gateway', async () => {
    // Arrange
    const mockPaymentGateway = vi.fn().mockResolvedValue({
      transactionId: 'txn_123',
      status: 'success'
    });

    // Inject mock
    app.set('paymentGateway', mockPaymentGateway);

    const orderData = {
      items: [{ id: 1, quantity: 2 }],
      total: 100.00
    };

    // Act
    const response = await request(app)
      .post('/checkout')
      .send(orderData);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('success');

    // Verify payment gateway was called
    expect(mockPaymentGateway).toHaveBeenCalledWith({
      amount: 100.00,
      currency: 'USD'
    });

    // Verify order in database
    const order = await db.query('SELECT * FROM orders LIMIT 1');
    expect(order.total).toBe(100.00);
    expect(order.status).toBe('paid');
  });
});
```

### 5. Multi-Step Workflow Tests

```python
# Python
def test_user_registration_workflow(client, db_session):
    """Test complete user registration workflow."""
    # Step 1: Register user
    registration_data = {
        "email": "newuser@example.com",
        "password": "securepass123",
        "name": "New User"
    }
    register_response = client.post("/auth/register", json=registration_data)
    assert register_response.status_code == 201
    user_id = register_response.json()["id"]

    # Step 2: Verify email token was created
    token = db_session.query(EmailVerificationToken).filter_by(
        user_id=user_id
    ).first()
    assert token is not None

    # Step 3: Verify email
    verify_response = client.post(f"/auth/verify/{token.token}")
    assert verify_response.status_code == 200

    # Step 4: Login with verified account
    login_data = {
        "email": registration_data["email"],
        "password": registration_data["password"]
    }
    login_response = client.post("/auth/login", json=login_data)
    assert login_response.status_code == 200
    assert "access_token" in login_response.json()

    # Step 5: Verify user is marked as verified in database
    user = db_session.query(User).get(user_id)
    assert user.email_verified is True
```

---

## Database Testing Strategies

### 1. Test Database Isolation

```python
# Python - Pytest fixture for isolated test database
@pytest.fixture(scope="function")
def db_session():
    """Create isolated database session for each test."""
    # Create test database
    engine = create_engine("postgresql://localhost/test_db")
    Base.metadata.create_all(engine)

    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()

    yield session

    # Rollback and cleanup
    session.rollback()
    session.close()
    Base.metadata.drop_all(engine)
```

```javascript
// JavaScript - Test database setup
export async function createTestDatabase() {
  const db = await createConnection({
    type: 'sqlite',
    database: ':memory:', // In-memory database
    synchronize: true
  });
  return db;
}

export async function dropTestDatabase(db) {
  await db.dropDatabase();
  await db.close();
}
```

### 2. Transaction Rollback Strategy

```python
# Python - Rollback after each test
@pytest.fixture
def db_session(db_engine):
    """Session that rolls back after test."""
    connection = db_engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()
```

### 3. Fixture Data Loading

```python
# Python
@pytest.fixture
def seed_users(db_session):
    """Load seed users for testing."""
    users = [
        User(email="user1@example.com", name="User 1"),
        User(email="user2@example.com", name="User 2"),
        User(email="user3@example.com", name="User 3"),
    ]
    db_session.add_all(users)
    db_session.commit()
    return users
```

---

## API Testing Best Practices

### 1. Test All HTTP Methods

```python
# CRUD operations for a resource
def test_create_resource(client):
    response = client.post("/resources", json={"name": "Test"})
    assert response.status_code == 201

def test_read_resource(client, resource_id):
    response = client.get(f"/resources/{resource_id}")
    assert response.status_code == 200

def test_update_resource(client, resource_id):
    response = client.put(f"/resources/{resource_id}", json={"name": "Updated"})
    assert response.status_code == 200

def test_delete_resource(client, resource_id):
    response = client.delete(f"/resources/{resource_id}")
    assert response.status_code == 204
```

### 2. Test Request Validation

```python
# Python
def test_create_user_rejects_invalid_email(client):
    """Test that invalid email format is rejected."""
    response = client.post("/users", json={
        "email": "not-an-email",
        "name": "Test User"
    })
    assert response.status_code == 422
    assert "email" in response.json()["detail"][0]["loc"]

def test_create_user_rejects_missing_required_field(client):
    """Test that missing required field is rejected."""
    response = client.post("/users", json={"name": "Test User"})
    assert response.status_code == 422
    assert "email" in str(response.json())
```

### 3. Test Response Formats

```python
# Python
def test_list_users_returns_paginated_response(client, seed_users):
    """Test GET /users returns paginated structure."""
    response = client.get("/users?page=1&limit=10")

    assert response.status_code == 200
    data = response.json()

    # Verify pagination structure
    assert "items" in data
    assert "total" in data
    assert "page" in data
    assert "limit" in data
    assert isinstance(data["items"], list)
```

---

## Docker-Based Integration Testing

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  test-db:
    image: postgres:15
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    ports:
      - "5433:5432"

  test-redis:
    image: redis:7
    ports:
      - "6380:6379"
```

```python
# Python - Using Docker services in tests
@pytest.fixture(scope="session")
def docker_compose():
    """Start Docker Compose services for testing."""
    subprocess.run(["docker-compose", "-f", "docker-compose.test.yml", "up", "-d"])
    time.sleep(5)  # Wait for services to be ready

    yield

    subprocess.run(["docker-compose", "-f", "docker-compose.test.yml", "down"])
```

---

## Common Assertions for Integration Tests

```python
# HTTP Response Assertions
assert response.status_code == 200
assert response.json()["key"] == "expected_value"
assert "field" in response.json()

# Database State Assertions
assert db_session.query(Model).count() == expected_count
assert db_session.query(Model).filter_by(id=1).first() is not None

# Relationship Assertions
user = db_session.query(User).first()
assert len(user.posts) == 3
assert user.profile is not None
```

---

## Integration Testing Anti-Patterns

### ❌ Testing Too Many Layers at Once

```python
# BAD - Testing UI, API, service, and database in one test
def test_entire_application():
    # Opens browser, clicks buttons, checks database
    # If this fails, where is the bug?
    pass

# GOOD - Integration test focuses on 2-3 layers
def test_api_and_database_integration(client, db_session):
    # Tests API → Database interaction only
    pass
```

### ❌ Not Cleaning Up Test Data

```python
# BAD - Leaves test data in database
def test_create_user(client):
    client.post("/users", json={"email": "test@example.com"})
    # Data persists, affects other tests

# GOOD - Cleans up after each test
@pytest.fixture(autouse=True)
def cleanup(db_session):
    yield
    db_session.query(User).delete()
    db_session.commit()
```

---

## Quick Reference

| Operation | Python (FastAPI) | JavaScript (Express) |
|-----------|------------------|----------------------|
| Test client | `TestClient(app)` | `supertest(app)` |
| Database fixture | `@pytest.fixture` + `create_engine()` | `beforeEach()` + `createConnection()` |
| HTTP GET | `client.get("/path")` | `request(app).get("/path")` |
| HTTP POST | `client.post("/path", json=data)` | `request(app).post("/path").send(data)` |
| Assert status | `assert response.status_code == 200` | `expect(response.status).toBe(200)` |
| Assert JSON | `assert response.json()["key"] == value` | `expect(response.body.key).toBe(value)` |

---

## Related Templates

- **unit-test-template.md** - For testing individual functions/classes
- **e2e-test-template.md** - For testing complete user workflows with UI
- **test-data-template.md** - For creating fixtures and seed data
- **testing-strategies.md** - Choosing between unit, integration, and E2E tests
