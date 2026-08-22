# Architectural Patterns Reference

This guide covers common architectural patterns for system design, when to use them, and their trade-offs.

## Pattern Categories

1. [Structural Patterns](#structural-patterns) - How to organize system components
2. [Communication Patterns](#communication-patterns) - How components interact
3. [Data Patterns](#data-patterns) - How to manage and flow data
4. [Scalability Patterns](#scalability-patterns) - How to handle growth
5. [Resilience Patterns](#resilience-patterns) - How to handle failures

---

## Structural Patterns

### 1. Layered Architecture (N-Tier)

**Description:** Organize system into horizontal layers, each with specific responsibilities. Each layer depends only on layers below it.

**Common Layers:**
```
┌─────────────────────────┐
│  Presentation Layer     │ ← UI, API endpoints
├─────────────────────────┤
│  Business Logic Layer   │ ← Core domain logic
├─────────────────────────┤
│  Data Access Layer      │ ← Database, repositories
├─────────────────────────┤
│  Database Layer         │ ← Persistent storage
└─────────────────────────┘
```

**When to Use:**
- ✅ Traditional web applications
- ✅ Monolithic systems with clear separation of concerns
- ✅ Teams familiar with MVC/MVVM patterns
- ✅ Applications with straightforward data flow

**Advantages:**
- Simple to understand and implement
- Clear separation of concerns
- Easy to test each layer independently
- Well-suited for small to medium applications

**Disadvantages:**
- Can become rigid as complexity grows
- Entire system deployed as single unit
- Changes ripple across layers
- Can lead to "god objects" in business layer

**Example (Python/FastAPI):**
```python
# Presentation Layer
@app.post("/api/users")
async def create_user(user: UserCreate):
    return await user_service.create(user)

# Business Logic Layer
class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    async def create(self, user_data: UserCreate) -> User:
        # Business logic here
        user = User(**user_data.dict())
        return await self.repository.save(user)

# Data Access Layer
class UserRepository:
    async def save(self, user: User) -> User:
        # Database operations
        return await db.users.insert_one(user.dict())
```

---

### 2. Microservices Architecture

**Description:** Decompose application into small, independent services that communicate over network. Each service owns its data and business logic.

```
┌────────────┐    ┌────────────┐    ┌────────────┐
│  User      │    │  Order     │    │  Payment   │
│  Service   │◄──►│  Service   │◄──►│  Service   │
└──────┬─────┘    └──────┬─────┘    └──────┬─────┘
       │                 │                  │
   ┌───▼────┐       ┌───▼────┐        ┌───▼────┐
   │User DB │       │Order DB│        │Pay DB  │
   └────────┘       └────────┘        └────────┘
```

**When to Use:**
- ✅ Large, complex applications
- ✅ Multiple teams working independently
- ✅ Different parts need to scale independently
- ✅ Polyglot technology requirements (different services, different tech)

**Advantages:**
- Independent deployment and scaling
- Technology diversity
- Fault isolation (one service failure doesn't crash all)
- Team autonomy

**Disadvantages:**
- Increased operational complexity
- Network latency between services
- Distributed system challenges (consistency, debugging)
- More infrastructure overhead

**Best Practices:**
- Keep services focused (single business capability)
- Use API gateway for client access
- Implement distributed tracing
- Design for failure (circuit breakers, retries)
- Use event-driven communication where appropriate

---

### 3. Hexagonal Architecture (Ports & Adapters)

**Description:** Isolate core business logic from external concerns (UI, database, APIs). Core defines "ports" (interfaces), adapters implement them.

```
        ┌─────────────────────────┐
        │   REST API Adapter      │
        └──────────┬──────────────┘
                   │
     ┌─────────────▼──────────────┐
     │     Application Core       │
     │   (Business Logic)         │
     └─────────────┬──────────────┘
                   │
        ┌──────────▼──────────────┐
        │  Database Adapter       │
        └─────────────────────────┘
```

**When to Use:**
- ✅ Domain-driven design (DDD) projects
- ✅ Applications that need to swap infrastructure (e.g., different databases)
- ✅ Long-lived systems requiring flexibility
- ✅ Test-heavy development (easy to mock ports)

**Advantages:**
- Core business logic completely isolated
- Easy to test (mock adapters)
- Swap implementations without changing core
- Clear boundaries between concerns

**Disadvantages:**
- More upfront design work
- Can feel over-engineered for simple apps
- More interfaces/abstractions to manage

**Example:**
```python
# Port (interface)
class UserRepository(Protocol):
    def save(self, user: User) -> User: ...
    def find_by_id(self, id: str) -> Optional[User]: ...

# Core business logic (depends on port)
class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    def create_user(self, data: dict) -> User:
        user = User(**data)
        return self.repository.save(user)

# Adapter (implementation)
class PostgresUserRepository:
    def save(self, user: User) -> User:
        # Postgres-specific implementation
        pass

    def find_by_id(self, id: str) -> Optional[User]:
        # Postgres-specific implementation
        pass
```

---

### 4. Event-Driven Architecture

**Description:** Components communicate by producing and consuming events. Producers don't know about consumers.

```
┌──────────┐    event    ┌────────────┐    event    ┌──────────┐
│Producer 1│────────────►│Event Queue │────────────►│Consumer 1│
└──────────┘             └────────────┘             └──────────┘
                              │
                              ▼
                         ┌──────────┐
                         │Consumer 2│
                         └──────────┘
```

**When to Use:**
- ✅ Asynchronous workflows (order processing, notifications)
- ✅ Systems with multiple consumers of same data
- ✅ Real-time data processing
- ✅ Decoupling producers from consumers

**Advantages:**
- Loose coupling between components
- Easy to add new consumers without changing producers
- Natural fit for async operations
- Scales well for high-throughput systems

**Disadvantages:**
- Debugging is harder (distributed trace needed)
- Eventual consistency (not immediate)
- Message queue becomes critical dependency
- Complexity in error handling and retries

**Event Types:**
- **Event Notification:** "User registered" (minimal data)
- **Event-Carried State Transfer:** "User registered" + full user data
- **Event Sourcing:** Store all state changes as events

**Example:**
```python
# Producer
class OrderService:
    def create_order(self, order_data: dict):
        order = Order(**order_data)
        db.save(order)

        # Publish event
        event_bus.publish("order.created", {
            "order_id": order.id,
            "user_id": order.user_id,
            "total": order.total
        })

# Consumer 1: Send confirmation email
@event_bus.subscribe("order.created")
async def send_order_confirmation(event: dict):
    await email_service.send_confirmation(event["user_id"])

# Consumer 2: Update inventory
@event_bus.subscribe("order.created")
async def update_inventory(event: dict):
    await inventory_service.decrement(event["order_id"])
```

---

### 5. CQRS (Command Query Responsibility Segregation)

**Description:** Separate read operations (queries) from write operations (commands). Often uses different data models for each.

```
Commands (Write)          Queries (Read)
┌──────────┐             ┌──────────┐
│ Write    │   events    │ Read     │
│ Model    │────────────►│ Model    │
└────┬─────┘             └────┬─────┘
     │                        │
┌────▼─────┐             ┌───▼──────┐
│ Write DB │             │ Read DB  │
└──────────┘             └──────────┘
```

**When to Use:**
- ✅ Complex business logic with simple reads
- ✅ Different scalability needs for reads vs writes
- ✅ Read and write data models differ significantly
- ✅ Event sourcing architectures

**Advantages:**
- Optimize reads and writes independently
- Scale read and write sides separately
- Simplified query models (denormalized for performance)
- Clear separation of business logic

**Disadvantages:**
- Increased complexity
- Eventual consistency between read and write models
- Code duplication risk
- More infrastructure to manage

**Example:**
```python
# Command (Write)
class CreateUserCommand:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

class UserCommandHandler:
    def handle(self, cmd: CreateUserCommand):
        user = User(name=cmd.name, email=cmd.email)
        write_db.save(user)

        # Publish event to sync read model
        event_bus.publish("user.created", user.to_dict())

# Query (Read)
class UserQuery:
    def get_user_by_id(self, user_id: str):
        # Read from optimized read model (e.g., Redis, Elasticsearch)
        return read_db.get(user_id)

    def search_users(self, query: str):
        # Fast search on denormalized read model
        return search_index.query(query)

# Event handler syncs read model
@event_bus.subscribe("user.created")
def sync_read_model(event: dict):
    # Update denormalized read model
    read_db.set(event["id"], event)
    search_index.index(event)
```

---

## Communication Patterns

### 6. API Gateway

**Description:** Single entry point for all clients. Routes requests to appropriate microservices.

```
┌────────┐
│ Client │
└───┬────┘
    │
┌───▼────────────┐
│  API Gateway   │  (Auth, Rate Limiting, Routing)
└───┬────────────┘
    │
    ├─────────►  Service A
    ├─────────►  Service B
    └─────────►  Service C
```

**Responsibilities:**
- Request routing
- Authentication/authorization
- Rate limiting
- Request/response transformation
- Caching
- Logging/monitoring

**When to Use:**
- ✅ Microservices architecture
- ✅ Multiple backend services
- ✅ Need centralized cross-cutting concerns
- ✅ Mobile/web clients with different needs

**Advantages:**
- Single entry point simplifies client code
- Centralized auth, logging, rate limiting
- Can aggregate multiple service calls
- Can provide different APIs for different clients

**Disadvantages:**
- Single point of failure (mitigate with HA setup)
- Can become bottleneck (mitigate with caching, scaling)
- Risk of becoming monolithic "god gateway"

**Technologies:**
- Kong, AWS API Gateway, Azure API Management
- NGINX, Traefik, Envoy

---

### 7. Service Mesh

**Description:** Infrastructure layer handling service-to-service communication in microservices. Uses sidecar proxies.

```
Service A                Service B
┌─────────┐             ┌─────────┐
│  App    │             │  App    │
└────┬────┘             └────┬────┘
     │                       │
┌────▼────┐    mesh    ┌────▼────┐
│ Sidecar │◄──────────►│ Sidecar │
└─────────┘             └─────────┘
```

**Features:**
- Service discovery
- Load balancing
- Circuit breaking
- Retries and timeouts
- Mutual TLS (mTLS)
- Observability (tracing, metrics)

**When to Use:**
- ✅ Large microservices deployments (10+ services)
- ✅ Need advanced networking features (mTLS, retries)
- ✅ Polyglot architecture (different languages)
- ✅ Security requirements (service-to-service encryption)

**Advantages:**
- Cross-cutting concerns handled outside application code
- Consistent networking features across all services
- Enhanced observability
- Zero-trust security model

**Disadvantages:**
- Complexity overhead
- Latency (extra hop through sidecar)
- Learning curve
- Resource overhead (sidecar per service instance)

**Technologies:**
- Istio, Linkerd, Consul Connect

---

## Data Patterns

### 8. Database per Service

**Description:** Each microservice has its own database. No shared databases.

**When to Use:**
- ✅ Microservices architecture
- ✅ Different services need different database types
- ✅ Team autonomy important
- ✅ Independent scaling required

**Advantages:**
- Services are loosely coupled
- Each service can use optimal database type
- Independent scaling and deployment
- Clear ownership

**Disadvantages:**
- Data consistency challenges
- Transactions across services complex (Saga pattern)
- Data duplication across services
- Queries spanning services difficult

**Patterns for Data Consistency:**
- **Saga Pattern:** Coordinate distributed transactions
- **Event Sourcing:** Rebuild state from events
- **CQRS:** Separate read/write models

---

### 9. Event Sourcing

**Description:** Store all changes to application state as sequence of events. Current state is derived by replaying events.

```
Event Store:
1. UserCreated(id=1, name="John")
2. UserEmailUpdated(id=1, email="john@example.com")
3. UserDeleted(id=1)

Current State: Replay events 1→2→3
Result: User deleted
```

**When to Use:**
- ✅ Audit trail critical (financial, healthcare)
- ✅ Need to reconstruct past states
- ✅ Complex domain logic
- ✅ Event-driven architecture

**Advantages:**
- Complete audit history
- Time travel (reconstruct any past state)
- Events are immutable (append-only)
- Natural fit for event-driven systems

**Disadvantages:**
- Complexity (learning curve)
- Event schema evolution challenges
- Querying current state slower (need projections)
- Storage grows continuously

**Best Practices:**
- Use snapshots for performance (every N events)
- Version events for schema evolution
- Use projections for queries (CQRS read model)

---

## Scalability Patterns

### 10. Sharding (Horizontal Partitioning)

**Description:** Split database across multiple servers based on shard key.

```
Shard Key: user_id % 3

Shard 0: users 0, 3, 6, 9...
Shard 1: users 1, 4, 7, 10...
Shard 2: users 2, 5, 8, 11...
```

**When to Use:**
- ✅ Single database can't handle load
- ✅ Data volume exceeds single server capacity
- ✅ Need horizontal scaling

**Shard Key Selection:**
- **Good keys:** Evenly distributed, immutable, frequently queried
- **Bad keys:** Monotonically increasing (hotspots), rarely used

**Challenges:**
- Queries across shards slow
- Resharding difficult
- Transactions across shards complex

---

### 11. Read Replicas

**Description:** Maintain read-only copies of database to distribute read load.

```
┌──────────┐     replication    ┌──────────┐
│ Primary  │───────────────────►│ Replica 1│
│ (Write)  │                    └──────────┘
└──────────┘                    ┌──────────┐
                                │ Replica 2│
                                └──────────┘
```

**When to Use:**
- ✅ Read-heavy workloads (95%+ reads)
- ✅ Write load manageable, read load high
- ✅ Eventual consistency acceptable

**Considerations:**
- Replication lag (eventual consistency)
- Write operations only to primary
- Read-after-write consistency issues

---

## Resilience Patterns

### 12. Circuit Breaker

**Description:** Prevent cascading failures by stopping calls to failing service.

```
States:
CLOSED ──[failures > threshold]──► OPEN
   ▲                                  │
   │                                  │
   └──[successes > threshold]──── HALF-OPEN
                                      ▲
                                      │
                              [timeout expires]
```

**When to Use:**
- ✅ Calls to external services/APIs
- ✅ Prevent cascade failures
- ✅ Microservices communication

**Implementation:**
```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=60)
def call_external_api():
    return requests.get("https://api.example.com/data")
```

---

### 13. Retry with Exponential Backoff

**Description:** Retry failed operations with increasing delays.

**When to Use:**
- ✅ Transient failures (network glitches, rate limits)
- ✅ External API calls
- ✅ Database connection failures

**Example:**
```python
import time

def retry_with_backoff(func, max_retries=3, backoff_factor=2):
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            sleep_time = backoff_factor ** attempt
            time.sleep(sleep_time)
```

---

## Pattern Selection Guide

| Requirement | Recommended Pattern |
|-------------|-------------------|
| Simple web app | Layered Architecture |
| Large, complex system | Microservices |
| Domain-driven design | Hexagonal Architecture |
| Async workflows | Event-Driven Architecture |
| Different read/write needs | CQRS |
| Audit trail critical | Event Sourcing |
| Multiple microservices | API Gateway + Service Mesh |
| High read load | Read Replicas |
| Large data volume | Sharding |
| External service calls | Circuit Breaker + Retry |

---

## Anti-Patterns to Avoid

### 1. Distributed Monolith
- **Problem:** Microservices that are tightly coupled, deployed together
- **Solution:** Ensure services are truly independent

### 2. God Service
- **Problem:** One service doing too much
- **Solution:** Split by business capability

### 3. Chatty Services
- **Problem:** Too many network calls between services
- **Solution:** Coarser-grained APIs, consider aggregation

### 4. Shared Database
- **Problem:** Multiple services accessing same database
- **Solution:** Database per service, use events for sync

### 5. Lack of API Versioning
- **Problem:** Breaking changes break clients
- **Solution:** Version APIs from day 1

---

**Related References:**
- [Design Principles](design-principles.md)
- [Scalability Patterns](scalability-patterns.md)
- [Security Architecture](security-architecture.md)
