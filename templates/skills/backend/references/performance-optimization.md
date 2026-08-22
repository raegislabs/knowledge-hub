# Performance Optimization

Comprehensive guide to caching strategies, query optimization, asynchronous processing, and backend performance tuning.

## Table of Contents
1. [Caching Strategies](#caching-strategies)
2. [Database Query Optimization](#database-query-optimization)
3. [Connection Pooling](#connection-pooling)
4. [Async Processing](#async-processing)
5. [API Response Optimization](#api-response-optimization)
6. [Load Balancing](#load-balancing)
7. [Profiling & Monitoring](#profiling--monitoring)
8. [Common Performance Patterns](#common-performance-patterns)

---

## Caching Strategies

### Redis Caching

**Setup:**
```python
import redis.asyncio as redis
from typing import Optional, Any
import json

redis_client = redis.Redis(
    host='localhost',
    port=6379,
    db=0,
    decode_responses=True
)


async def get_cache(key: str) -> Optional[Any]:
    """Get value from cache."""
    value = await redis_client.get(key)
    if value:
        return json.loads(value)
    return None


async def set_cache(
    key: str,
    value: Any,
    ttl: int = 3600
) -> None:
    """Set value in cache with TTL."""
    await redis_client.setex(
        key,
        ttl,
        json.dumps(value)
    )


async def delete_cache(key: str) -> None:
    """Delete value from cache."""
    await redis_client.delete(key)


async def get_or_set_cache(
    key: str,
    fetch_func,
    ttl: int = 3600
):
    """
    Get from cache or fetch and cache.

    Args:
        key: Cache key
        fetch_func: Async function to fetch data if not cached
        ttl: Time to live in seconds

    Returns:
        Cached or fetched data
    """
    # Try cache first
    cached = await get_cache(key)
    if cached is not None:
        return cached

    # Fetch data
    data = await fetch_func()

    # Cache for next time
    await set_cache(key, data, ttl)

    return data
```

**Usage in Endpoints:**
```python
@router.get("/users/{user_id}")
async def get_user(user_id: int):
    """Get user with caching."""
    cache_key = f"user:{user_id}"

    return await get_or_set_cache(
        cache_key,
        lambda: user_service.get_by_id(user_id),
        ttl=300  # 5 minutes
    )


@router.patch("/users/{user_id}")
async def update_user(user_id: int, update_data: UserUpdate):
    """Update user and invalidate cache."""
    user = await user_service.update(user_id, update_data)

    # Invalidate cache
    await delete_cache(f"user:{user_id}")

    return user
```

### Cache-Aside Pattern

```python
async def get_user_with_cache_aside(user_id: int) -> dict:
    """
    Cache-aside pattern implementation.

    1. Check cache
    2. If miss, fetch from DB
    3. Store in cache
    4. Return data
    """
    cache_key = f"user:{user_id}"

    # 1. Check cache
    cached_user = await get_cache(cache_key)
    if cached_user:
        logger.debug(f"Cache hit: {cache_key}")
        return cached_user

    logger.debug(f"Cache miss: {cache_key}")

    # 2. Fetch from database
    user = await db.fetchrow(
        "SELECT * FROM users WHERE id = $1",
        user_id
    )

    if not user:
        return None

    # 3. Store in cache
    await set_cache(cache_key, dict(user), ttl=300)

    # 4. Return data
    return dict(user)
```

### Write-Through Cache

```python
async def update_user_write_through(
    user_id: int,
    update_data: dict
) -> dict:
    """
    Write-through caching pattern.

    1. Update database
    2. Update cache
    3. Return data
    """
    # 1. Update database
    updated_user = await db.fetchrow("""
        UPDATE users
        SET name = $2, email = $3, updated_at = NOW()
        WHERE id = $1
        RETURNING *
    """, user_id, update_data['name'], update_data['email'])

    # 2. Update cache
    cache_key = f"user:{user_id}"
    await set_cache(cache_key, dict(updated_user), ttl=300)

    # 3. Return data
    return dict(updated_user)
```

### Cache Invalidation Strategies

**1. Time-Based (TTL)**
```python
# Short TTL for frequently changing data
await set_cache("stock_price:AAPL", price, ttl=60)  # 1 minute

# Long TTL for stable data
await set_cache("user_profile:123", profile, ttl=3600)  # 1 hour
```

**2. Event-Based**
```python
async def delete_user(user_id: int):
    """Delete user and invalidate all related caches."""
    # Delete from database
    await db.execute("DELETE FROM users WHERE id = $1", user_id)

    # Invalidate all related caches
    await redis_client.delete(
        f"user:{user_id}",
        f"user:{user_id}:orders",
        f"user:{user_id}:preferences"
    )
```

**3. Pattern-Based**
```python
async def invalidate_user_caches(user_id: int):
    """Invalidate all caches matching pattern."""
    pattern = f"user:{user_id}:*"

    # Find all matching keys
    keys = []
    async for key in redis_client.scan_iter(match=pattern):
        keys.append(key)

    # Delete all matching keys
    if keys:
        await redis_client.delete(*keys)
```

### Multi-Level Caching

```python
from functools import lru_cache

# L1: In-memory cache (fast, limited size)
@lru_cache(maxsize=1000)
def get_config(key: str) -> str:
    """In-memory cache for config values."""
    return config_dict.get(key)


# L2: Redis cache (medium speed, larger size)
async def get_user_l2(user_id: int) -> Optional[dict]:
    """Redis cache for user data."""
    return await get_cache(f"user:{user_id}")


# L3: Database (slow, unlimited size)
async def get_user_l3(user_id: int) -> Optional[dict]:
    """Database lookup for user data."""
    return await db.fetchrow("SELECT * FROM users WHERE id = $1", user_id)


# Combined multi-level lookup
async def get_user_multilevel(user_id: int) -> Optional[dict]:
    """Get user with multi-level caching."""
    # L1: In-memory (not shown for simplicity)

    # L2: Redis
    user = await get_user_l2(user_id)
    if user:
        return user

    # L3: Database
    user = await get_user_l3(user_id)
    if user:
        # Populate L2 cache
        await set_cache(f"user:{user_id}", user, ttl=300)

    return user
```

---

## Database Query Optimization

### N+1 Query Problem

```python
# ❌ BAD - N+1 queries
async def get_users_with_orders_bad():
    """Fetches users, then queries orders for each (N+1 problem)."""
    users = await db.fetch("SELECT * FROM users")

    result = []
    for user in users:
        # N additional queries!
        orders = await db.fetch(
            "SELECT * FROM orders WHERE user_id = $1",
            user['id']
        )
        result.append({
            'user': user,
            'orders': orders
        })

    return result


# ✅ GOOD - Single query with JOIN
async def get_users_with_orders_good():
    """Fetches users and orders in single query."""
    rows = await db.fetch("""
        SELECT
            u.id as user_id,
            u.email,
            u.name,
            o.id as order_id,
            o.total,
            o.created_at as order_created_at
        FROM users u
        LEFT JOIN orders o ON u.id = o.user_id
        ORDER BY u.id, o.created_at DESC
    """)

    # Group by user
    users_dict = {}
    for row in rows:
        user_id = row['user_id']

        if user_id not in users_dict:
            users_dict[user_id] = {
                'id': user_id,
                'email': row['email'],
                'name': row['name'],
                'orders': []
            }

        if row['order_id']:
            users_dict[user_id]['orders'].append({
                'id': row['order_id'],
                'total': row['total'],
                'created_at': row['order_created_at']
            })

    return list(users_dict.values())


# ✅ GOOD - Using ORM eager loading (SQLAlchemy)
from sqlalchemy.orm import selectinload

async def get_users_with_orders_orm():
    """ORM with eager loading."""
    users = await db.execute(
        select(User).options(selectinload(User.orders))
    )
    return users.scalars().all()
```

### Query Optimization Techniques

**1. Use Indexes**
```sql
-- Before: Slow query
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';

-- Add composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Query now fast
```

**2. Select Only Needed Columns**
```python
# ❌ BAD - Fetching all columns
users = await db.fetch("SELECT * FROM users")

# ✅ GOOD - Only needed columns
users = await db.fetch("SELECT id, email, name FROM users")
```

**3. Use LIMIT**
```python
# ❌ BAD - Fetching all rows
all_orders = await db.fetch("SELECT * FROM orders")

# ✅ GOOD - Limit results
recent_orders = await db.fetch("""
    SELECT * FROM orders
    ORDER BY created_at DESC
    LIMIT 100
""")
```

**4. Batch Operations**
```python
# ❌ BAD - Individual inserts
for user in users:
    await db.execute(
        "INSERT INTO users (email, name) VALUES ($1, $2)",
        user['email'], user['name']
    )

# ✅ GOOD - Bulk insert
await db.executemany(
    "INSERT INTO users (email, name) VALUES ($1, $2)",
    [(u['email'], u['name']) for u in users]
)
```

**5. Use Query Analysis**
```sql
-- Analyze query performance
EXPLAIN ANALYZE
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- Look for:
-- - Seq Scan (add index if needed)
-- - High cost numbers
-- - Unexpected row counts
```

---

## Connection Pooling

### Database Connection Pool

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

# Configure connection pool
engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,           # Persistent connections
    max_overflow=20,        # Additional connections when needed
    pool_timeout=30,        # Wait 30s for connection
    pool_recycle=3600,      # Recycle connections after 1 hour
    pool_pre_ping=True      # Verify connections before use
)


# Using asyncpg (async PostgreSQL)
import asyncpg

pool = await asyncpg.create_pool(
    DATABASE_URL,
    min_size=10,            # Minimum pool size
    max_size=20,            # Maximum pool size
    max_queries=50000,      # Max queries per connection before recycling
    max_inactive_connection_lifetime=300  # Close idle connections after 5min
)


async def get_user(user_id: int):
    """Get user using connection pool."""
    async with pool.acquire() as conn:
        return await conn.fetchrow(
            "SELECT * FROM users WHERE id = $1",
            user_id
        )
```

### Redis Connection Pool

```python
import redis.asyncio as redis

redis_pool = redis.ConnectionPool(
    host='localhost',
    port=6379,
    db=0,
    max_connections=50,
    decode_responses=True
)

redis_client = redis.Redis(connection_pool=redis_pool)
```

---

## Async Processing

### Background Tasks

```python
from fastapi import BackgroundTasks


async def send_welcome_email(user_email: str):
    """Send welcome email (slow operation)."""
    await email_service.send(
        to=user_email,
        subject="Welcome!",
        body="Welcome to our platform"
    )


@router.post("/users", status_code=201)
async def create_user(
    user_data: UserCreate,
    background_tasks: BackgroundTasks
):
    """Create user and send welcome email in background."""
    # Create user (fast)
    user = await user_service.create(user_data)

    # Schedule email sending in background (doesn't block response)
    background_tasks.add_task(send_welcome_email, user.email)

    return user
```

### Task Queues (Celery)

```python
from celery import Celery

celery_app = Celery(
    'tasks',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/1'
)


@celery_app.task
def process_large_file(file_path: str):
    """Process large file asynchronously."""
    # Long-running task
    data = read_file(file_path)
    results = analyze_data(data)
    save_results(results)
    return results


@router.post("/upload")
async def upload_file(file: UploadFile):
    """Upload file and process asynchronously."""
    # Save file
    file_path = await save_uploaded_file(file)

    # Queue processing task
    task = process_large_file.delay(file_path)

    return {
        "task_id": task.id,
        "status": "processing"
    }


@router.get("/tasks/{task_id}")
async def get_task_status(task_id: str):
    """Check task status."""
    task = celery_app.AsyncResult(task_id)

    return {
        "task_id": task_id,
        "status": task.status,
        "result": task.result if task.ready() else None
    }
```

### Async Endpoints

```python
import httpx


# ❌ SLOW - Synchronous external API call
@router.get("/weather")
def get_weather_sync(city: str):
    """Blocks entire thread during API call."""
    response = requests.get(f"https://api.weather.com/{city}")
    return response.json()


# ✅ FAST - Asynchronous external API call
@router.get("/weather")
async def get_weather_async(city: str):
    """Non-blocking API call."""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.weather.com/{city}")
        return response.json()


# ✅ FAST - Parallel requests
@router.get("/dashboard")
async def get_dashboard():
    """Fetch multiple resources in parallel."""
    async with httpx.AsyncClient() as client:
        # All requests happen concurrently
        users_task = client.get("/api/users")
        orders_task = client.get("/api/orders")
        stats_task = client.get("/api/stats")

        # Wait for all to complete
        users_resp, orders_resp, stats_resp = await asyncio.gather(
            users_task,
            orders_task,
            stats_task
        )

        return {
            "users": users_resp.json(),
            "orders": orders_resp.json(),
            "stats": stats_resp.json()
        }
```

---

## API Response Optimization

### Pagination

```python
from typing import Generic, TypeVar, List
from pydantic import BaseModel

T = TypeVar('T')


class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response."""
    items: List[T]
    total: int
    page: int
    page_size: int
    total_pages: int


async def paginate(
    query: str,
    page: int = 1,
    page_size: int = 20,
    *params
) -> PaginatedResponse:
    """
    Paginate database query.

    Args:
        query: SQL query (must include ORDER BY)
        page: Page number (1-indexed)
        page_size: Items per page
        params: Query parameters

    Returns:
        Paginated response
    """
    # Ensure valid pagination
    page = max(1, page)
    page_size = min(100, max(1, page_size))

    # Get total count
    count_query = f"SELECT COUNT(*) FROM ({query}) as count_query"
    total = await db.fetchval(count_query, *params)

    # Get paginated results
    offset = (page - 1) * page_size
    paginated_query = f"{query} LIMIT {page_size} OFFSET {offset}"
    items = await db.fetch(paginated_query, *params)

    return PaginatedResponse(
        items=[dict(item) for item in items],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size
    )


@router.get("/users")
async def list_users(page: int = 1, page_size: int = 20):
    """List users with pagination."""
    return await paginate(
        "SELECT id, email, name FROM users ORDER BY created_at DESC",
        page,
        page_size
    )
```

### Response Compression

```python
from fastapi.middleware.gzip import GZipMiddleware

# Enable gzip compression
app.add_middleware(GZipMiddleware, minimum_size=1000)
```

### Field Selection

```python
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,
    fields: Optional[str] = None
):
    """
    Get user with optional field selection.

    ?fields=id,email,name
    """
    if fields:
        # Parse requested fields
        requested_fields = [f.strip() for f in fields.split(',')]
        allowed_fields = {'id', 'email', 'name', 'created_at'}
        selected_fields = allowed_fields.intersection(requested_fields)

        # Query only requested fields
        fields_str = ', '.join(selected_fields)
        query = f"SELECT {fields_str} FROM users WHERE id = $1"
    else:
        # Default: all fields
        query = "SELECT * FROM users WHERE id = $1"

    user = await db.fetchrow(query, user_id)
    return dict(user) if user else None
```

---

## Profiling & Monitoring

### Query Timing Middleware

```python
import time
from starlette.middleware.base import BaseHTTPMiddleware


class QueryTimingMiddleware(BaseHTTPMiddleware):
    """Log slow queries."""

    async def dispatch(self, request, call_next):
        start_time = time.time()

        response = await call_next(request)

        duration = time.time() - start_time

        # Log slow requests
        if duration > 1.0:  # 1 second
            logger.warning(
                f"Slow request: {request.method} {request.url.path} "
                f"took {duration:.2f}s"
            )

        # Add timing header
        response.headers["X-Process-Time"] = str(duration)

        return response


app.add_middleware(QueryTimingMiddleware)
```

### Database Query Logging

```python
import logging
from sqlalchemy import event
from sqlalchemy.engine import Engine

# Log all SQL queries
logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)


# Log slow queries only
@event.listens_for(Engine, "before_cursor_execute")
def receive_before_cursor_execute(conn, cursor, statement, params, context, executemany):
    context._query_start_time = time.time()


@event.listens_for(Engine, "after_cursor_execute")
def receive_after_cursor_execute(conn, cursor, statement, params, context, executemany):
    duration = time.time() - context._query_start_time

    if duration > 0.5:  # 500ms
        logger.warning(
            f"Slow query ({duration:.2f}s): {statement[:200]}"
        )
```

### APM Integration

```python
# Using New Relic
import newrelic.agent

newrelic.agent.initialize('newrelic.ini')
app = newrelic.agent.WSGIApplicationWrapper(app)


# Using Sentry
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1  # Sample 10% of requests
)
```

---

## Common Performance Patterns

### Lazy Loading vs Eager Loading

```python
# Lazy loading - Load related data only when accessed
user = await User.query.get(123)
orders = await user.orders  # Separate query

# Eager loading - Load related data upfront
user = await User.query.options(joinedload(User.orders)).get(123)
# Orders already loaded, no additional query
```

### Caching Expensive Computations

```python
from functools import lru_cache


@lru_cache(maxsize=1000)
def calculate_expensive_metric(data: str) -> float:
    """Cache expensive calculation results."""
    # Complex calculation
    result = complex_algorithm(data)
    return result


# Clear cache when data changes
calculate_expensive_metric.cache_clear()
```

### Database Read Replicas

```python
# Write to primary
await primary_db.execute(
    "INSERT INTO users (email, name) VALUES ($1, $2)",
    email, name
)

# Read from replica
users = await replica_db.fetch(
    "SELECT * FROM users WHERE created_at > $1",
    datetime.utcnow() - timedelta(days=7)
)
```

### Performance Checklist

- [ ] Database queries use indexes
- [ ] N+1 queries eliminated
- [ ] Connection pooling configured
- [ ] Caching implemented for frequently accessed data
- [ ] Async endpoints for I/O operations
- [ ] Response pagination for large datasets
- [ ] Background tasks for slow operations
- [ ] Query timeouts configured
- [ ] Slow query logging enabled
- [ ] Monitoring/APM integrated
- [ ] Database connection limits set
- [ ] Response compression enabled
