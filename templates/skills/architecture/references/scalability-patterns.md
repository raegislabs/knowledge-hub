# Scalability Patterns Reference

Patterns and strategies for building systems that scale to handle increased load.

## Table of Contents

1. [Caching Strategies](#caching-strategies)
2. [Load Balancing](#load-balancing)
3. [Database Scaling](#database-scaling)
4. [Asynchronous Processing](#asynchronous-processing)
5. [Content Delivery](#content-delivery)
6. [Rate Limiting](#rate-limiting)

---

## Caching Strategies

### 1. Cache-Aside (Lazy Loading)

**Pattern:** Application checks cache first, loads from database on miss, then populates cache.

```python
def get_user(user_id):
    # Try cache first
    user = cache.get(f"user:{user_id}")
    if user:
        return user

    # Cache miss - load from database
    user = db.query(User).get(user_id)

    # Populate cache
    cache.set(f"user:{user_id}", user, ttl=3600)
    return user
```

**When to Use:**
- Read-heavy workloads
- Data doesn't change frequently
- Cache misses acceptable

**Advantages:**
- Only requested data cached
- Cache failures don't break system

**Disadvantages:**
- Initial request slow (cache miss)
- Potential for stale data

---

### 2. Write-Through Cache

**Pattern:** Write to cache and database simultaneously.

```python
def update_user(user_id, data):
    user = User(**data)

    # Write to database
    db.save(user)

    # Write to cache
    cache.set(f"user:{user_id}", user, ttl=3600)

    return user
```

**When to Use:**
- Data consistency critical
- Acceptable write latency increase
- Read-heavy after writes

**Advantages:**
- Cache always up-to-date
- Consistent data

**Disadvantages:**
- Higher write latency
- Caches data that may never be read

---

### 3. Write-Behind Cache (Write-Back)

**Pattern:** Write to cache immediately, asynchronously write to database later.

```python
def update_user(user_id, data):
    user = User(**data)

    # Write to cache immediately
    cache.set(f"user:{user_id}", user)

    # Queue for async database write
    queue.enqueue("write_user", user)

    return user
```

**When to Use:**
- Write-heavy workloads
- Low write latency critical
- Acceptable data loss risk

**Advantages:**
- Fast writes
- Reduced database load

**Disadvantages:**
- Data loss risk if cache fails
- Complex consistency management

---

### 4. Cache Invalidation Strategies

**Time-To-Live (TTL):**
```python
cache.set("user:123", user, ttl=3600)  # Expires in 1 hour
```

**Event-Based Invalidation:**
```python
@event_bus.subscribe("user.updated")
def invalidate_user_cache(event):
    cache.delete(f"user:{event['user_id']}")
```

**Cache Stampede Prevention:**
```python
import threading

locks = {}

def get_user_safe(user_id):
    cache_key = f"user:{user_id}"

    # Check cache
    user = cache.get(cache_key)
    if user:
        return user

    # Acquire lock to prevent stampede
    lock = locks.setdefault(user_id, threading.Lock())

    with lock:
        # Double-check after acquiring lock
        user = cache.get(cache_key)
        if user:
            return user

        # Load from database
        user = db.query(User).get(user_id)
        cache.set(cache_key, user, ttl=3600)
        return user
```

---

## Load Balancing

### 5. Load Balancing Algorithms

**Round Robin:**
```
Request 1 → Server A
Request 2 → Server B
Request 3 → Server C
Request 4 → Server A
...
```

**When to Use:** Servers have equal capacity

---

**Least Connections:**
```
Server A: 10 connections
Server B: 5 connections ← Route here
Server C: 8 connections
```

**When to Use:** Requests have varying durations

---

**IP Hash (Sticky Sessions):**
```
hash(client_ip) % num_servers → Server
```

**When to Use:** Session affinity required

---

**Weighted Round Robin:**
```
Server A (weight 3): Gets 3/6 requests
Server B (weight 2): Gets 2/6 requests
Server C (weight 1): Gets 1/6 requests
```

**When to Use:** Servers have different capacities

---

### 6. Health Checks

```python
@app.get("/health")
def health_check():
    # Check database
    try:
        db.execute("SELECT 1")
    except:
        return {"status": "unhealthy"}, 503

    # Check cache
    try:
        cache.ping()
    except:
        return {"status": "degraded"}, 200

    return {"status": "healthy"}, 200
```

**Load Balancer Configuration:**
- Check interval: 5-30 seconds
- Timeout: 2-5 seconds
- Unhealthy threshold: 2-3 failures
- Healthy threshold: 2-3 successes

---

## Database Scaling

### 7. Read Replicas

**Pattern:** Route reads to replicas, writes to primary.

```python
class DatabaseRouter:
    def get_connection(self, operation):
        if operation == "read":
            # Round-robin across replicas
            return replica_pool.get_connection()
        else:  # write
            return primary_connection
```

**Replication Lag Management:**
```python
def get_user_with_consistency(user_id, max_lag_seconds=5):
    # For critical reads, check replication lag
    replica = get_replica_connection()

    lag = replica.execute("SELECT EXTRACT(EPOCH FROM NOW() - pg_last_xact_replay_timestamp())").scalar()

    if lag > max_lag_seconds:
        # Lag too high, read from primary
        return primary.query(User).get(user_id)
    else:
        return replica.query(User).get(user_id)
```

---

### 8. Sharding (Horizontal Partitioning)

**Shard Key Selection:**

**Good Shard Keys:**
- ✅ Even distribution (user_id hash)
- ✅ Frequently queried (user_id for user data)
- ✅ Immutable (don't change after creation)

**Bad Shard Keys:**
- ❌ Monotonic (auto-increment ID) - creates hotspots
- ❌ Rarely queried (requires cross-shard queries)
- ❌ Skewed distribution (most users in one shard)

**Implementation:**
```python
def get_shard_for_user(user_id: str) -> Database:
    shard_index = hash(user_id) % NUM_SHARDS
    return shards[shard_index]

def get_user(user_id: str):
    shard = get_shard_for_user(user_id)
    return shard.query(User).filter_by(id=user_id).first()
```

**Cross-Shard Queries:**
```python
def search_users(name: str):
    results = []
    # Query all shards in parallel
    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(shard.query(User).filter_by(name=name).all())
                   for shard in shards]
        for future in futures:
            results.extend(future.result())
    return results
```

---

### 9. Partitioning

**Range Partitioning:**
```sql
CREATE TABLE orders (
    order_id BIGINT,
    created_at TIMESTAMP,
    ...
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
```

**List Partitioning:**
```sql
CREATE TABLE users (
    user_id BIGINT,
    country VARCHAR(2),
    ...
) PARTITION BY LIST (country);

CREATE TABLE users_us PARTITION OF users
    FOR VALUES IN ('US');

CREATE TABLE users_eu PARTITION OF users
    FOR VALUES IN ('UK', 'DE', 'FR');
```

**Hash Partitioning:**
```sql
CREATE TABLE events (
    event_id BIGINT,
    ...
) PARTITION BY HASH (event_id);

CREATE TABLE events_p0 PARTITION OF events
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE events_p1 PARTITION OF events
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
```

---

## Asynchronous Processing

### 10. Message Queues

**Pattern:** Decouple producers from consumers using queue.

```python
# Producer
def create_order(order_data):
    order = Order(**order_data)
    db.save(order)

    # Queue async work
    queue.enqueue("send_confirmation_email", order.id)
    queue.enqueue("update_inventory", order.id)
    queue.enqueue("notify_warehouse", order.id)

    return order

# Consumer
@queue.worker("send_confirmation_email")
def send_confirmation(order_id):
    order = db.query(Order).get(order_id)
    email_service.send_confirmation(order.user.email, order)
```

**Benefits:**
- Improved response time
- Better fault tolerance
- Easy to scale workers

**Queue Technologies:**
- Redis (simple, fast)
- RabbitMQ (feature-rich, reliable)
- AWS SQS (managed, scalable)
- Apache Kafka (high-throughput, streaming)

---

### 11. Worker Pools

```python
from concurrent.futures import ThreadPoolExecutor

# Fixed pool of workers
executor = ThreadPoolExecutor(max_workers=10)

def process_orders():
    orders = get_pending_orders()

    # Process in parallel
    futures = [executor.submit(process_order, order)
               for order in orders]

    # Wait for completion
    for future in futures:
        future.result()
```

**Scaling Workers:**
- Monitor queue depth
- Scale workers based on load
- Use auto-scaling groups

---

## Content Delivery

### 12. CDN (Content Delivery Network)

**Pattern:** Serve static content from edge locations near users.

```
User in Tokyo → CDN Edge (Tokyo) → Origin Server (US)
                    ↑
                   Cache
```

**What to Cache:**
- ✅ Static assets (images, CSS, JS)
- ✅ Videos
- ✅ PDFs, downloads
- ✅ API responses (with short TTL)

**What NOT to Cache:**
- ❌ Personalized content
- ❌ Frequently changing data
- ❌ Authenticated content (without care)

**Cache Control Headers:**
```python
@app.get("/api/products")
def get_products():
    products = db.query(Product).all()

    return Response(
        content=products,
        headers={
            "Cache-Control": "public, max-age=300",  # Cache 5 minutes
            "ETag": generate_etag(products)
        }
    )
```

---

### 13. Static Asset Optimization

**Compression:**
```nginx
# Nginx config
gzip on;
gzip_types text/plain text/css application/json application/javascript;
gzip_min_length 1000;
```

**Versioned Assets:**
```html
<!-- Cache forever with versioned URLs -->
<link rel="stylesheet" href="/static/style.abc123.css">
<script src="/static/app.def456.js"></script>
```

**Image Optimization:**
- Use modern formats (WebP, AVIF)
- Responsive images (srcset)
- Lazy loading

---

## Rate Limiting

### 14. Token Bucket Algorithm

```python
import time
from collections import defaultdict

class TokenBucket:
    def __init__(self, rate, capacity):
        self.rate = rate  # tokens per second
        self.capacity = capacity
        self.tokens = defaultdict(lambda: capacity)
        self.last_update = defaultdict(time.time)

    def allow(self, key):
        now = time.time()

        # Add tokens based on elapsed time
        elapsed = now - self.last_update[key]
        self.tokens[key] = min(
            self.capacity,
            self.tokens[key] + elapsed * self.rate
        )
        self.last_update[key] = now

        # Try to consume token
        if self.tokens[key] >= 1:
            self.tokens[key] -= 1
            return True
        return False

# Usage
limiter = TokenBucket(rate=10, capacity=100)  # 10 req/sec, burst 100

@app.get("/api/data")
def get_data(request):
    client_ip = request.client.host

    if not limiter.allow(client_ip):
        return {"error": "Rate limit exceeded"}, 429

    return {"data": "..."}
```

---

### 15. Distributed Rate Limiting

```python
import redis

class RedisRateLimiter:
    def __init__(self, redis_client, limit, window):
        self.redis = redis_client
        self.limit = limit
        self.window = window

    def allow(self, key):
        # Use sliding window with Redis
        now = time.time()
        window_key = f"rate_limit:{key}"

        # Remove old entries
        self.redis.zremrangebyscore(window_key, 0, now - self.window)

        # Count requests in window
        count = self.redis.zcard(window_key)

        if count < self.limit:
            # Add new request
            self.redis.zadd(window_key, {str(now): now})
            self.redis.expire(window_key, self.window)
            return True

        return False

# Usage
limiter = RedisRateLimiter(redis_client, limit=100, window=60)  # 100 req/min
```

---

## Scalability Checklist

### Application Layer
- [ ] Stateless design
- [ ] Horizontal scaling supported
- [ ] Load balancer configured
- [ ] Health checks implemented
- [ ] Graceful shutdown

### Database Layer
- [ ] Indexes on frequently queried columns
- [ ] Query optimization
- [ ] Connection pooling
- [ ] Read replicas for read-heavy workloads
- [ ] Sharding strategy for large datasets

### Caching Layer
- [ ] Cache frequently accessed data
- [ ] TTL configured appropriately
- [ ] Cache invalidation strategy
- [ ] Cache stampede prevention
- [ ] Multiple cache levels (app, CDN)

### Asynchronous Processing
- [ ] Background jobs for slow operations
- [ ] Message queue for async work
- [ ] Worker auto-scaling
- [ ] Dead letter queue for failures

### Monitoring
- [ ] Performance metrics tracked
- [ ] Bottlenecks identified
- [ ] Alerts for degradation
- [ ] Load testing performed

---

**Related References:**
- [Architectural Patterns](architectural-patterns.md)
- [Design Principles](design-principles.md)
- [Security Architecture](security-architecture.md)
