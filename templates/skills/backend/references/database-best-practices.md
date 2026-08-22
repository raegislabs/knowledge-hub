# Database Best Practices

Comprehensive guide to database schema design, migrations, indexing strategies, query optimization, and data integrity.

## Table of Contents
1. [Schema Design Principles](#schema-design-principles)
2. [Normalization](#normalization)
3. [Data Types](#data-types)
4. [Indexing Strategies](#indexing-strategies)
5. [Relationships & Foreign Keys](#relationships--foreign-keys)
6. [Migrations](#migrations)
7. [Query Optimization](#query-optimization)
8. [Transactions & Concurrency](#transactions--concurrency)
9. [Performance Tuning](#performance-tuning)
10. [Common Patterns](#common-patterns)

---

## Schema Design Principles

### 1. Plan for Growth

**Design for Scale:**
- Anticipate data volume growth (1M rows? 100M rows?)
- Consider partitioning for large tables
- Design indexes for query patterns

**Example - User Events Table:**
```sql
-- Will grow large, consider partitioning by date
CREATE TABLE user_events (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE user_events_2024_01 PARTITION OF user_events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### 2. Use Appropriate Data Types

**Choose the Right Type:**
- ✅ Use `INTEGER` for IDs, not `VARCHAR`
- ✅ Use `TIMESTAMP` for dates, not `VARCHAR`
- ✅ Use `BOOLEAN` for flags, not `INTEGER`
- ✅ Use `DECIMAL` for money, not `FLOAT`

**Examples:**
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY,                   -- ✅ Integer for IDs
    name VARCHAR(255) NOT NULL,               -- ✅ Sized string
    price DECIMAL(10, 2) NOT NULL,           -- ✅ Decimal for money
    in_stock BOOLEAN DEFAULT TRUE,           -- ✅ Boolean for flags
    created_at TIMESTAMP DEFAULT NOW()       -- ✅ Timestamp for dates
);

-- ❌ Bad example
CREATE TABLE products_bad (
    id VARCHAR(50) PRIMARY KEY,              -- ❌ String for ID
    price FLOAT,                             -- ❌ Float for money (precision issues)
    in_stock INTEGER,                        -- ❌ Integer for boolean
    created_at VARCHAR(50)                   -- ❌ String for date
);
```

### 3. Add Constraints

**Enforce Data Integrity:**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,

    -- Foreign key constraint
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    -- Check constraint
    CONSTRAINT ck_orders_total_positive
        CHECK (total_amount >= 0),

    -- Enum-like constraint
    CONSTRAINT ck_orders_status_valid
        CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'))
);
```

### 4. Add Timestamps

**Always Include Audit Timestamps:**
```sql
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,

    -- Audit timestamps
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP  -- For soft deletes
);

-- Trigger to auto-update updated_at
CREATE TRIGGER update_resources_updated_at
    BEFORE UPDATE ON resources
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## Normalization

### Normal Forms

**1NF (First Normal Form):**
- Atomic values (no arrays or multiple values in one column)
- Each column has unique name
- Order doesn't matter

```sql
-- ❌ Not 1NF - multiple phone numbers in one column
CREATE TABLE users_bad (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    phones VARCHAR(255)  -- "555-1234, 555-5678"
);

-- ✅ 1NF - separate table for phone numbers
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE user_phones (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    phone VARCHAR(20)
);
```

**2NF (Second Normal Form):**
- Must be in 1NF
- No partial dependencies (all non-key columns depend on entire primary key)

```sql
-- ❌ Not 2NF - category_name depends only on category_id
CREATE TABLE order_items_bad (
    order_id INTEGER,
    product_id INTEGER,
    category_id INTEGER,
    category_name VARCHAR(100),  -- Depends only on category_id
    PRIMARY KEY (order_id, product_id)
);

-- ✅ 2NF - category_name in separate table
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    category_id INTEGER,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100)
);
```

**3NF (Third Normal Form):**
- Must be in 2NF
- No transitive dependencies (non-key columns depend only on primary key)

```sql
-- ❌ Not 3NF - city depends on zip_code
CREATE TABLE users_bad (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    zip_code VARCHAR(10),
    city VARCHAR(100)  -- Depends on zip_code
);

-- ✅ 3NF - city in separate table
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    zip_code VARCHAR(10)
);

CREATE TABLE zip_codes (
    code VARCHAR(10) PRIMARY KEY,
    city VARCHAR(100)
);
```

### When to Denormalize

**Strategic Denormalization:**

1. **Read Performance** - Avoid expensive joins
   ```sql
   -- Store user name in orders for fast display
   CREATE TABLE orders (
       id SERIAL PRIMARY KEY,
       user_id INTEGER REFERENCES users(id),
       user_name VARCHAR(100),  -- Denormalized
       created_at TIMESTAMP
   );
   ```

2. **Aggregates** - Cache computed values
   ```sql
   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       email VARCHAR(255),
       total_orders INTEGER DEFAULT 0,  -- Denormalized count
       total_spent DECIMAL(10, 2) DEFAULT 0  -- Denormalized sum
   );
   ```

3. **Historical Data** - Preserve state
   ```sql
   -- Store product price at time of order
   CREATE TABLE order_items (
       id SERIAL PRIMARY KEY,
       order_id INTEGER,
       product_id INTEGER,
       price_at_order DECIMAL(10, 2)  -- Historical price
   );
   ```

**Denormalization Rules:**
- Only denormalize when performance demands it
- Keep denormalized data in sync (triggers, app logic)
- Document why denormalization was done

---

## Data Types

### PostgreSQL Data Type Guide

**Numeric Types:**
```sql
-- Integers
SMALLINT        -- -32,768 to 32,767 (2 bytes)
INTEGER         -- -2B to 2B (4 bytes) - most common
BIGINT          -- -9 quintillion to 9 quintillion (8 bytes)
SERIAL          -- Auto-incrementing INTEGER
BIGSERIAL       -- Auto-incrementing BIGINT

-- Decimals
DECIMAL(10, 2)  -- Fixed precision - use for money
NUMERIC(10, 2)  -- Same as DECIMAL
FLOAT           -- Approximate - avoid for money
REAL            -- 6 decimal digits precision
DOUBLE          -- 15 decimal digits precision
```

**String Types:**
```sql
CHAR(n)         -- Fixed length - rarely used
VARCHAR(n)      -- Variable length with limit - most common
TEXT            -- Unlimited length - use for large text
```

**Date/Time Types:**
```sql
DATE            -- Date only (no time)
TIME            -- Time only (no date)
TIMESTAMP       -- Date and time (no timezone)
TIMESTAMPTZ     -- Date and time WITH timezone - recommended
INTERVAL        -- Time duration
```

**Boolean:**
```sql
BOOLEAN         -- TRUE/FALSE/NULL
```

**JSON:**
```sql
JSON            -- Text-based JSON
JSONB           -- Binary JSON - faster, indexable - recommended
```

**Arrays:**
```sql
INTEGER[]       -- Array of integers
VARCHAR[]       -- Array of strings
```

### Data Type Selection Guide

| Use Case | Type | Example |
|----------|------|---------|
| Primary Key | `SERIAL` or `BIGSERIAL` | `id BIGSERIAL PRIMARY KEY` |
| Foreign Key | `INTEGER` or `BIGINT` | `user_id INTEGER REFERENCES users(id)` |
| Money | `DECIMAL(10, 2)` | `price DECIMAL(10, 2)` |
| Percentage | `DECIMAL(5, 2)` | `tax_rate DECIMAL(5, 2)` |
| Short string | `VARCHAR(n)` | `name VARCHAR(255)` |
| Long text | `TEXT` | `description TEXT` |
| Boolean flag | `BOOLEAN` | `is_active BOOLEAN DEFAULT TRUE` |
| Timestamp | `TIMESTAMPTZ` | `created_at TIMESTAMPTZ DEFAULT NOW()` |
| Flexible data | `JSONB` | `metadata JSONB` |
| Enum values | `VARCHAR` + CHECK | `status VARCHAR(20) CHECK (...)` |

---

## Indexing Strategies

### When to Add Indexes

**✅ Index These:**
- Primary keys (automatic)
- Foreign keys (manual)
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Columns with high cardinality

**❌ Don't Index These:**
- Small tables (<1000 rows)
- Columns rarely queried
- Low cardinality columns (true/false)
- Write-heavy tables (indexes slow writes)

### Index Types

**1. B-Tree Index (Default)**
```sql
-- Most common, supports equality and range queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_created ON orders(created_at);
```

**Use for:**
- Equality (`WHERE email = 'user@example.com'`)
- Range (`WHERE created_at > '2024-01-01'`)
- Sorting (`ORDER BY created_at`)
- Prefix matching (`WHERE name LIKE 'John%'`)

**2. Hash Index**
```sql
-- Only equality, slightly faster but rare
CREATE INDEX idx_users_api_key ON users USING HASH (api_key);
```

**Use for:**
- Equality only (`WHERE api_key = 'abc123'`)
- Not for range queries

**3. GIN Index (Generalized Inverted)**
```sql
-- For full-text search, JSONB, arrays
CREATE INDEX idx_products_tags ON products USING GIN (tags);
CREATE INDEX idx_documents_content ON documents USING GIN (to_tsvector('english', content));
```

**Use for:**
- JSONB queries
- Array containment
- Full-text search

**4. BRIN Index (Block Range)**
```sql
-- For very large tables with natural order
CREATE INDEX idx_events_created ON events USING BRIN (created_at);
```

**Use for:**
- Very large tables (millions of rows)
- Naturally ordered data (timestamps)
- Data inserted in order

### Composite Indexes

**Order Matters:**
```sql
-- Good for: WHERE user_id = X AND created_at > Y
-- Also good for: WHERE user_id = X
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at);

-- NOT good for: WHERE created_at > Y (without user_id)
```

**Multi-Column Index Rules:**
1. Most selective column first (usually)
2. Equality columns before range columns
3. Consider query patterns

**Example:**
```sql
-- Query: WHERE user_id = 123 AND status = 'active' AND created_at > '2024-01-01'
CREATE INDEX idx_orders_user_status_created ON orders(user_id, status, created_at);
```

### Partial Indexes

**Index Subset of Rows:**
```sql
-- Only index active users
CREATE INDEX idx_users_active_email ON users(email)
WHERE is_active = TRUE;

-- Only index recent orders
CREATE INDEX idx_orders_recent ON orders(created_at)
WHERE created_at > '2024-01-01';
```

**Benefits:**
- Smaller index size
- Faster updates
- Perfect for filtered queries

### Covering Indexes

**Include Extra Columns:**
```sql
-- PostgreSQL 11+
CREATE INDEX idx_orders_user_covering ON orders(user_id)
INCLUDE (total_amount, created_at);

-- Query can be satisfied entirely from index (no table lookup)
SELECT user_id, total_amount, created_at
FROM orders
WHERE user_id = 123;
```

### Index Maintenance

**Monitor Index Usage:**
```sql
-- Find unused indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY relname, indexrelname;
```

**Reindex Periodically:**
```sql
-- Rebuild bloated indexes
REINDEX INDEX idx_users_email;
REINDEX TABLE users;
```

---

## Relationships & Foreign Keys

### One-to-Many

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total DECIMAL(10, 2) NOT NULL,

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE  -- Delete orders when user deleted
);

-- Index foreign key
CREATE INDEX idx_orders_user ON orders(user_id);
```

### Many-to-Many

```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200)
);

-- Junction table
CREATE TABLE enrollments (
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrolled_at TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (student_id, course_id),

    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);

-- Indexes for both directions
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
```

### Self-Referential

```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INTEGER,

    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_id)
        REFERENCES categories(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_categories_parent ON categories(parent_id);
```

### ON DELETE Options

```sql
-- CASCADE - Delete related records
ON DELETE CASCADE

-- SET NULL - Set foreign key to NULL
ON DELETE SET NULL

-- RESTRICT - Prevent deletion (default)
ON DELETE RESTRICT

-- SET DEFAULT - Set to default value
ON DELETE SET DEFAULT

-- NO ACTION - Similar to RESTRICT
ON DELETE NO ACTION
```

**Choose Based on Requirements:**
- **CASCADE**: User deleted → Delete all their orders
- **SET NULL**: Manager deleted → Set department.manager_id = NULL
- **RESTRICT**: Category deleted → Prevent if has products

---

## Migrations

### Migration Best Practices

**1. Always Use Migrations**
```bash
# Never alter database directly in production
❌ psql production -c "ALTER TABLE users ADD COLUMN phone VARCHAR(20)"

# Always use migration tools
✅ alembic revision -m "Add phone to users"
✅ alembic upgrade head
```

**2. Make Migrations Reversible**
```python
# Alembic example
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(20)))

def downgrade():
    op.drop_column('users', 'phone')
```

**3. Test Migrations**
```bash
# Test up migration
alembic upgrade head

# Test down migration
alembic downgrade -1

# Test re-applying
alembic upgrade head
```

**4. Safe Schema Changes**

**Adding Columns (Safe):**
```sql
-- Safe - nullable column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Safe - with default
ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE;
```

**Changing Columns (Risky):**
```sql
-- Risky - may fail with existing data
ALTER TABLE users ALTER COLUMN email TYPE TEXT;

-- Safer - multi-step migration
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_new TEXT;

-- Step 2: Copy data
UPDATE users SET email_new = email;

-- Step 3: Drop old, rename new
ALTER TABLE users DROP COLUMN email;
ALTER TABLE users RENAME COLUMN email_new TO email;
```

**Removing Columns (Risky):**
```sql
-- Better: Soft delete (mark as deprecated first)
-- Migration 1: Add deprecation comment
COMMENT ON COLUMN users.old_field IS 'DEPRECATED - will be removed in v2.0';

-- Migration 2 (later): Remove after confirmed unused
ALTER TABLE users DROP COLUMN old_field;
```

### Zero-Downtime Migrations

**Strategy for Large Tables:**
```sql
-- Bad: Locks table for entire operation
ALTER TABLE large_table ADD COLUMN new_field INTEGER NOT NULL DEFAULT 0;

-- Good: Break into steps
-- Step 1: Add nullable column (fast, no lock)
ALTER TABLE large_table ADD COLUMN new_field INTEGER;

-- Step 2: Backfill in batches (no lock)
UPDATE large_table SET new_field = 0 WHERE id BETWEEN 0 AND 100000;
UPDATE large_table SET new_field = 0 WHERE id BETWEEN 100001 AND 200000;
-- ... continue in batches

-- Step 3: Add NOT NULL constraint (fast, no lock with check)
ALTER TABLE large_table ADD CONSTRAINT check_new_field_not_null
    CHECK (new_field IS NOT NULL) NOT VALID;

ALTER TABLE large_table VALIDATE CONSTRAINT check_new_field_not_null;

ALTER TABLE large_table ALTER COLUMN new_field SET NOT NULL;
```

---

## Query Optimization

### Use EXPLAIN ANALYZE

```sql
-- See query execution plan
EXPLAIN ANALYZE
SELECT u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email;
```

### Avoid N+1 Queries

```python
# ❌ Bad - N+1 queries
users = User.query.all()
for user in users:
    orders = Order.query.filter_by(user_id=user.id).all()  # N queries

# ✅ Good - Single query with join
users = User.query.options(joinedload(User.orders)).all()
```

### Limit Result Sets

```sql
-- Always use LIMIT for testing
SELECT * FROM large_table LIMIT 100;

-- Use pagination
SELECT * FROM orders
ORDER BY created_at DESC
LIMIT 20 OFFSET 0;
```

### Select Only Needed Columns

```sql
-- ❌ Bad - Fetching unnecessary data
SELECT * FROM users WHERE id = 123;

-- ✅ Good - Only needed columns
SELECT id, email, name FROM users WHERE id = 123;
```

### Use Connection Pooling

```python
# Configure connection pool
from sqlalchemy import create_engine

engine = create_engine(
    DATABASE_URL,
    pool_size=10,        # Number of persistent connections
    max_overflow=20,     # Max temporary connections
    pool_timeout=30,     # Timeout waiting for connection
    pool_recycle=3600    # Recycle connections after 1 hour
)
```

---

## Transactions & Concurrency

### ACID Properties

- **Atomicity**: All or nothing
- **Consistency**: Valid state to valid state
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data persists

### Transaction Isolation Levels

```sql
-- PostgreSQL default: Read Committed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Stronger isolation
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### Handling Deadlocks

```python
from sqlalchemy.exc import OperationalError

def transfer_funds(from_account, to_account, amount):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            with db.begin():
                # Always lock in consistent order to avoid deadlock
                accounts = sorted([from_account, to_account])
                for account_id in accounts:
                    account = Account.query.with_for_update().get(account_id)

                # Perform transfer
                from_acc.balance -= amount
                to_acc.balance += amount
            break
        except OperationalError as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(0.1 * (attempt + 1))  # Exponential backoff
```

---

## Performance Tuning

### Database Configuration

```sql
-- PostgreSQL configuration (postgresql.conf)
shared_buffers = 256MB          -- 25% of RAM
effective_cache_size = 1GB      -- 50% of RAM
maintenance_work_mem = 64MB
work_mem = 16MB
```

### Vacuum & Analyze

```sql
-- Regular maintenance
VACUUM ANALYZE users;

-- Auto-vacuum (enabled by default in PostgreSQL)
-- Monitor bloat
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Common Patterns

### Soft Delete

```sql
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_resources_not_deleted ON resources(id)
WHERE deleted_at IS NULL;

-- Query active records
SELECT * FROM resources WHERE deleted_at IS NULL;
```

### Audit Trail

```sql
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INTEGER,
    action VARCHAR(20),  -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    user_id INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Optimistic Locking

```sql
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    version INTEGER DEFAULT 1
);

-- Update with version check
UPDATE documents
SET content = 'new content', version = version + 1
WHERE id = 123 AND version = 5;
-- Returns 0 rows if version doesn't match (concurrent update detected)
```
