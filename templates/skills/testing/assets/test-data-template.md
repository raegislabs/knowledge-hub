# Test Data Template

## Overview

Test data management involves creating reusable, maintainable test fixtures, factories, and builders for consistent test scenarios. Well-structured test data makes tests more readable and reduces duplication.

**Use this template when:**
- Creating reusable test fixtures
- Building complex test objects
- Seeding databases for integration/E2E tests
- Managing test data across multiple tests
- Ensuring consistent test scenarios

---

## Fixture Patterns

### 1. Simple Fixtures (Static Data)

```python
# Python (pytest)
import pytest

@pytest.fixture
def sample_user():
    """Provide a sample user dictionary."""
    return {
        "id": 1,
        "email": "alice@example.com",
        "name": "Alice Smith",
        "role": "user"
    }

@pytest.fixture
def admin_user():
    """Provide an admin user dictionary."""
    return {
        "id": 2,
        "email": "admin@example.com",
        "name": "Admin User",
        "role": "admin"
    }

def test_user_has_email(sample_user):
    """Test that user fixture has email."""
    assert "email" in sample_user
    assert sample_user["email"] == "alice@example.com"
```

```javascript
// JavaScript (Vitest)
import { describe, it, expect } from 'vitest';

export const sampleUser = {
  id: 1,
  email: 'alice@example.com',
  name: 'Alice Smith',
  role: 'user'
};

export const adminUser = {
  id: 2,
  email: 'admin@example.com',
  name: 'Admin User',
  role: 'admin'
};

describe('User tests', () => {
  it('should have email', () => {
    expect(sampleUser.email).toBe('alice@example.com');
  });
});
```

### 2. Database Fixtures (Persisted Data)

```python
# Python (pytest + SQLAlchemy)
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import User, Post, Base

@pytest.fixture(scope="function")
def db_session():
    """Create isolated database session for each test."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()

    yield session

    session.close()

@pytest.fixture
def db_user(db_session):
    """Create and persist a user in the database."""
    user = User(
        email="test@example.com",
        name="Test User",
        hashed_password="hashed_pass"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

@pytest.fixture
def db_user_with_posts(db_session, db_user):
    """Create user with associated posts."""
    posts = [
        Post(title="Post 1", content="Content 1", user_id=db_user.id),
        Post(title="Post 2", content="Content 2", user_id=db_user.id),
    ]
    db_session.add_all(posts)
    db_session.commit()
    return db_user

def test_user_has_posts(db_user_with_posts, db_session):
    """Test that user fixture has posts."""
    user = db_session.query(User).filter_by(id=db_user_with_posts.id).first()
    assert len(user.posts) == 2
```

```javascript
// JavaScript (Vitest + Prisma)
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Database fixtures', () => {
  let testUser;

  beforeEach(async () => {
    // Create test user
    testUser = await prisma.user.create({
      data: {
        email: 'test@example.com',
        name: 'Test User',
        posts: {
          create: [
            { title: 'Post 1', content: 'Content 1' },
            { title: 'Post 2', content: 'Content 2' },
          ],
        },
      },
      include: { posts: true },
    });
  });

  afterEach(async () => {
    // Cleanup
    await prisma.post.deleteMany();
    await prisma.user.deleteMany();
  });

  it('should have posts', () => {
    expect(testUser.posts).toHaveLength(2);
  });
});
```

---

## Factory Pattern

### 1. Factory Functions

```python
# Python - Factory functions
def create_user(**overrides):
    """Factory function to create user with defaults."""
    defaults = {
        "email": "default@example.com",
        "name": "Default User",
        "role": "user",
        "active": True
    }
    return {**defaults, **overrides}

# Usage
def test_user_factory():
    # Use defaults
    user1 = create_user()
    assert user1["email"] == "default@example.com"

    # Override specific fields
    user2 = create_user(email="custom@example.com", role="admin")
    assert user2["email"] == "custom@example.com"
    assert user2["role"] == "admin"
    assert user2["name"] == "Default User"  # Still uses default
```

```javascript
// JavaScript - Factory functions
export function createUser(overrides = {}) {
  const defaults = {
    email: 'default@example.com',
    name: 'Default User',
    role: 'user',
    active: true
  };
  return { ...defaults, ...overrides };
}

// Usage
describe('User factory', () => {
  it('should create user with defaults', () => {
    const user = createUser();
    expect(user.email).toBe('default@example.com');
  });

  it('should override specific fields', () => {
    const user = createUser({ email: 'custom@example.com', role: 'admin' });
    expect(user.email).toBe('custom@example.com');
    expect(user.role).toBe('admin');
    expect(user.name).toBe('Default User');
  });
});
```

### 2. Factory Classes (Advanced)

```python
# Python - Factory with sequences and relationships
class UserFactory:
    """Factory for creating test users with sequences."""
    _counter = 0

    @classmethod
    def create(cls, **overrides):
        """Create user with unique email."""
        cls._counter += 1
        defaults = {
            "id": cls._counter,
            "email": f"user{cls._counter}@example.com",
            "name": f"User {cls._counter}",
            "role": "user"
        }
        return {**defaults, **overrides}

    @classmethod
    def create_batch(cls, count, **overrides):
        """Create multiple users."""
        return [cls.create(**overrides) for _ in range(count)]

    @classmethod
    def reset(cls):
        """Reset counter."""
        cls._counter = 0

# Usage
def test_user_factory_sequences():
    UserFactory.reset()

    user1 = UserFactory.create()
    user2 = UserFactory.create()
    user3 = UserFactory.create(role="admin")

    assert user1["email"] == "user1@example.com"
    assert user2["email"] == "user2@example.com"
    assert user3["email"] == "user3@example.com"
    assert user3["role"] == "admin"

def test_batch_creation():
    UserFactory.reset()
    users = UserFactory.create_batch(5)

    assert len(users) == 5
    assert users[0]["email"] == "user1@example.com"
    assert users[4]["email"] == "user5@example.com"
```

### 3. Database Factory (with ORM)

```python
# Python - Using factory_boy for SQLAlchemy
import factory
from factory.alchemy import SQLAlchemyModelFactory
from models import User, Post

class UserFactory(SQLAlchemyModelFactory):
    """Factory for User model."""
    class Meta:
        model = User
        sqlalchemy_session = None  # Set in conftest.py

    id = factory.Sequence(lambda n: n)
    email = factory.Sequence(lambda n: f"user{n}@example.com")
    name = factory.Faker('name')
    role = "user"

class PostFactory(SQLAlchemyModelFactory):
    """Factory for Post model."""
    class Meta:
        model = Post
        sqlalchemy_session = None

    id = factory.Sequence(lambda n: n)
    title = factory.Faker('sentence')
    content = factory.Faker('text')
    user = factory.SubFactory(UserFactory)

# conftest.py
@pytest.fixture
def db_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()

    # Set session for factories
    UserFactory._meta.sqlalchemy_session = session
    PostFactory._meta.sqlalchemy_session = session

    yield session

    session.close()

# Usage
def test_user_factory_with_db(db_session):
    # Create user
    user = UserFactory.create(role="admin")
    assert user.id is not None
    assert user.role == "admin"

    # Create user with posts
    user_with_posts = UserFactory.create()
    PostFactory.create_batch(3, user=user_with_posts)

    assert len(user_with_posts.posts) == 3
```

---

## Builder Pattern

```javascript
// JavaScript - Builder pattern for complex objects
class UserBuilder {
  constructor() {
    this.user = {
      email: 'default@example.com',
      name: 'Default User',
      role: 'user',
      active: true,
      profile: null,
      settings: {}
    };
  }

  withEmail(email) {
    this.user.email = email;
    return this;
  }

  withName(name) {
    this.user.name = name;
    return this;
  }

  asAdmin() {
    this.user.role = 'admin';
    return this;
  }

  withProfile(profile) {
    this.user.profile = profile;
    return this;
  }

  withSettings(settings) {
    this.user.settings = { ...this.user.settings, ...settings };
    return this;
  }

  inactive() {
    this.user.active = false;
    return this;
  }

  build() {
    return { ...this.user };
  }
}

// Usage
describe('User builder', () => {
  it('should build user with fluent API', () => {
    const user = new UserBuilder()
      .withEmail('admin@example.com')
      .withName('Admin User')
      .asAdmin()
      .withSettings({ theme: 'dark' })
      .build();

    expect(user.email).toBe('admin@example.com');
    expect(user.role).toBe('admin');
    expect(user.settings.theme).toBe('dark');
  });

  it('should build inactive user', () => {
    const user = new UserBuilder()
      .withEmail('inactive@example.com')
      .inactive()
      .build();

    expect(user.active).toBe(false);
  });
});
```

---

## Test Data Files

### 1. JSON Fixtures

```json
// tests/fixtures/users.json
{
  "users": [
    {
      "id": 1,
      "email": "alice@example.com",
      "name": "Alice Smith",
      "role": "user"
    },
    {
      "id": 2,
      "email": "bob@example.com",
      "name": "Bob Johnson",
      "role": "admin"
    }
  ]
}
```

```javascript
// Loading JSON fixtures
import usersFixture from './fixtures/users.json';

describe('User tests', () => {
  it('should load users from fixture', () => {
    const users = usersFixture.users;
    expect(users).toHaveLength(2);
    expect(users[0].email).toBe('alice@example.com');
  });
});
```

### 2. CSV/SQL Seed Files

```sql
-- tests/fixtures/seed.sql
INSERT INTO users (id, email, name, role) VALUES
  (1, 'alice@example.com', 'Alice Smith', 'user'),
  (2, 'bob@example.com', 'Bob Johnson', 'admin'),
  (3, 'charlie@example.com', 'Charlie Brown', 'user');

INSERT INTO posts (id, title, content, user_id) VALUES
  (1, 'First Post', 'Content of first post', 1),
  (2, 'Second Post', 'Content of second post', 1),
  (3, 'Admin Post', 'Content from admin', 2);
```

```python
# Loading SQL seed file
@pytest.fixture
def seeded_db(db_session):
    """Load seed data from SQL file."""
    with open('tests/fixtures/seed.sql', 'r') as f:
        sql = f.read()
    db_session.execute(sql)
    db_session.commit()
    return db_session
```

---

## Faker for Random Data

```python
# Python
from faker import Faker

fake = Faker()

def create_random_user():
    """Create user with realistic random data."""
    return {
        "email": fake.email(),
        "name": fake.name(),
        "phone": fake.phone_number(),
        "address": fake.address(),
        "company": fake.company(),
        "birthdate": fake.date_of_birth(minimum_age=18, maximum_age=80)
    }

def test_random_users():
    users = [create_random_user() for _ in range(10)]
    assert len(users) == 10
    # Each user has unique data
    emails = [u["email"] for u in users]
    assert len(set(emails)) == 10  # All unique
```

```javascript
// JavaScript (using @faker-js/faker)
import { faker } from '@faker-js/faker';

export function createRandomUser() {
  return {
    email: faker.internet.email(),
    name: faker.person.fullName(),
    phone: faker.phone.number(),
    address: faker.location.streetAddress(),
    company: faker.company.name(),
    birthdate: faker.date.birthdate({ min: 18, max: 80 })
  };
}

describe('Random users', () => {
  it('should create unique users', () => {
    const users = Array.from({ length: 10 }, () => createRandomUser());
    expect(users).toHaveLength(10);

    // All emails should be unique
    const emails = users.map(u => u.email);
    const uniqueEmails = new Set(emails);
    expect(uniqueEmails.size).toBe(10);
  });
});
```

---

## Common Test Data Patterns

### 1. Valid/Invalid Data Sets

```python
# Python - Parameterized validation tests
import pytest

VALID_EMAILS = [
    "user@example.com",
    "test.user@example.com",
    "user+tag@example.com",
    "user@subdomain.example.com"
]

INVALID_EMAILS = [
    "notanemail",
    "@example.com",
    "user@",
    "user @example.com",
    ""
]

@pytest.mark.parametrize("email", VALID_EMAILS)
def test_valid_emails_accepted(email):
    assert is_valid_email(email) is True

@pytest.mark.parametrize("email", INVALID_EMAILS)
def test_invalid_emails_rejected(email):
    assert is_valid_email(email) is False
```

### 2. Edge Case Data

```javascript
// JavaScript - Edge cases
export const edgeCaseStrings = [
  '',                           // Empty
  ' ',                          // Whitespace
  'a',                          // Single character
  'a'.repeat(1000),            // Very long
  '🔥💯',                        // Emojis
  '<script>alert("xss")</script>', // XSS attempt
  'null',                       // String "null"
  'undefined',                  // String "undefined"
  '  whitespace  '             // Leading/trailing whitespace
];

export const edgeCaseNumbers = [
  0,                            // Zero
  -1,                           // Negative
  Infinity,                     // Infinity
  -Infinity,                    // Negative infinity
  NaN,                          // Not a number
  Number.MAX_SAFE_INTEGER,      // Max safe integer
  Number.MIN_SAFE_INTEGER,      // Min safe integer
  0.1 + 0.2                    // Floating point precision issue
];

describe.each(edgeCaseStrings)('Edge case strings: %s', (input) => {
  it('should handle edge case gracefully', () => {
    expect(() => processString(input)).not.toThrow();
  });
});
```

### 3. Relationship Data

```python
# Python - Related entities
@pytest.fixture
def user_with_relationships(db_session):
    """Create user with all relationships."""
    user = User(email="user@example.com", name="User")
    db_session.add(user)

    # Profile (one-to-one)
    profile = Profile(bio="User bio", avatar_url="http://example.com/avatar.jpg")
    user.profile = profile

    # Posts (one-to-many)
    posts = [
        Post(title=f"Post {i}", content=f"Content {i}")
        for i in range(3)
    ]
    user.posts = posts

    # Groups (many-to-many)
    groups = [
        Group(name="Group 1"),
        Group(name="Group 2")
    ]
    user.groups = groups

    db_session.commit()
    return user
```

---

## Test Data Best Practices

### 1. Use Descriptive Names

```python
# Good - Clear what data represents
def create_expired_subscription():
    return Subscription(
        status="expired",
        end_date=datetime.now() - timedelta(days=1)
    )

# Bad - Unclear what data represents
def create_sub():
    return Subscription(status="x", end_date=None)
```

### 2. Minimize Test Data

```python
# Good - Only necessary fields
def test_user_email_validation():
    user = {"email": "test@example.com"}  # Only what's needed
    assert validate_email(user["email"])

# Bad - Unnecessary data
def test_user_email_validation():
    user = {
        "id": 1,
        "email": "test@example.com",
        "name": "Test",
        "address": "123 Main St",
        "phone": "555-1234",
        # ... 20 more fields
    }
    assert validate_email(user["email"])
```

### 3. Make Test Data Obvious

```python
# Good - Clear intent
def test_admin_can_delete_user():
    admin = create_user(role="admin")
    regular_user = create_user(role="user")
    assert can_delete(admin, regular_user) is True

# Bad - Ambiguous data
def test_admin_can_delete_user():
    user1 = create_user()
    user2 = create_user()
    assert can_delete(user1, user2) is True  # Which is admin?
```

---

## Quick Reference

| Pattern | Use When | Example |
|---------|----------|---------|
| **Simple Fixture** | Static, reusable data | `@pytest.fixture def sample_user()` |
| **Database Fixture** | Persisted data needed | `@pytest.fixture def db_user(db_session)` |
| **Factory Function** | Customizable defaults | `create_user(email="custom@example.com")` |
| **Factory Class** | Sequences and relationships | `UserFactory.create_batch(10)` |
| **Builder Pattern** | Complex, fluent API | `new UserBuilder().asAdmin().build()` |
| **Faker** | Realistic random data | `faker.email()` |
| **JSON Files** | Large, static datasets | `import data from './fixtures/data.json'` |

---

## Related Templates

- **unit-test-template.md** - Using test data in unit tests
- **integration-test-template.md** - Database fixtures for integration tests
- **e2e-test-template.md** - Seeding data for E2E tests
- **testing-strategies.md** - When to use different test data approaches
