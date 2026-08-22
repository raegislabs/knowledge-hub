---
name: backend-templates
description: Production-ready templates for backend development including RESTful API endpoints, database models, API documentation, and comprehensive reference guides for security, performance optimization, and best practices. Use when implementing backend features, designing APIs, or creating database schemas.
---

# Backend Templates

## Overview

This skill provides production-ready templates and comprehensive reference guides for backend development. It complements the @backend-implementation-specialist agent by providing standardized patterns, security best practices, and performance optimization techniques for building robust, scalable backend systems.

**When to use this skill:**
- Implementing RESTful API endpoints with FastAPI or similar frameworks
- Designing database schemas with SQLAlchemy ORM
- Creating API documentation for client developers
- Implementing authentication and authorization
- Optimizing database queries and API performance
- Adding caching, rate limiting, or security features
- Following backend best practices and security patterns

**Skill Structure:** Template and reference-based with production-ready code patterns and comprehensive guides.

## Available Templates

This skill provides 3 production-ready templates in `assets/`:

### 1. API Endpoint Template
**File:** `assets/api-endpoint-template.md`

Complete FastAPI endpoint implementation with:
- Module header with imports and router setup
- Pydantic request/response schemas with validation
- CRUD operations (Create, Read, List, Update, Delete)
- Pagination for list endpoints
- Comprehensive error handling with proper HTTP status codes
- Authentication and authorization dependencies
- Logging for debugging and monitoring
- Full docstrings for API documentation

**Use when:** Implementing new REST API endpoints for resources.

**Example usage:**
```python
# After copying template and replacing placeholders:

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

router = APIRouter(prefix="/api/v1/products", tags=["products"])


class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    price: Decimal = Field(..., gt=0)
    description: Optional[str] = Field(None, max_length=500)


@router.post("/products", response_model=ProductResponse, status_code=201)
async def create_product(
    product: ProductCreate,
    current_user: dict = Depends(get_current_user)
):
    """Create a new product with validation and auth."""
    # Implementation from template
```

### 2. Database Model Template
**File:** `assets/database-model-template.md`

SQLAlchemy model implementation with:
- Basic model structure with proper column types
- One-to-many, many-to-many, self-referential relationships
- Foreign keys with cascade behaviors
- Composite indexes for query optimization
- Unique constraints and check constraints
- Hybrid properties for computed fields
- Polymorphic models (single table inheritance)
- Soft delete pattern with mixins
- Audit trail pattern with timestamps
- Index strategy guide and relationship loading strategies

**Use when:** Creating database models for new resources or refactoring existing schemas.

**Example usage:**
```python
# After copying template and replacing placeholders:

from sqlalchemy import Column, Integer, String, ForeignKey, Index
from sqlalchemy.orm import relationship

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)

    # Relationship with eager loading
    category = relationship("Category", back_populates="products", lazy="joined")

    # Composite index for common queries
    __table_args__ = (
        Index('idx_products_category_name', 'category_id', 'name'),
    )
```

### 3. API Documentation Template
**File:** `assets/api-documentation-template.md`

Complete API documentation format with:
- Document header with version and base URL
- Authentication section with token examples
- Rate limiting documentation with headers
- Error handling section with standard codes
- Endpoint documentation for all CRUD operations
- Field descriptions with types and constraints
- Success and error response examples
- cURL and Python code examples
- Pagination, filtering, and webhooks documentation

**Use when:** Creating or updating API documentation for client developers.

**Example usage:**
```markdown
# Products API Documentation

## Overview
RESTful API for managing products in the e-commerce platform.

**Version:** v1
**Base URL:** `https://api.example.com/v1`
**Authentication:** JWT Bearer Token

## Authentication
All endpoints require JWT authentication:
```bash
Authorization: Bearer eyJhbGci...
```

## Endpoints

### Create Product
**POST** `/products`

Creates a new product.

**Request Body:**
```json
{
  "name": "Laptop",
  "price": 999.99,
  "category_id": 5
}
```

**Response** (201 Created):
```json
{
  "id": 123,
  "name": "Laptop",
  "price": 999.99,
  "created_at": "2024-01-15T10:30:00Z"
}
```
```

## Reference Guides

This skill provides 4 comprehensive reference guides in `references/`:

### 1. API Design Principles
**File:** `references/api-design-principles.md`

Complete guide to RESTful API design covering:

**Core Topics:**
- **RESTful Principles** - Resource-based URLs, HTTP methods, stateless communication, HATEOAS
- **Resource Naming** - URL structure, naming conventions, hierarchies, avoiding deep nesting
- **HTTP Methods** - GET, POST, PUT, PATCH, DELETE with detailed examples and properties
- **HTTP Status Codes** - Success (2xx), client error (4xx), server error (5xx) with usage guide
- **Request/Response Design** - JSON conventions, single vs collection responses, error formats
- **Pagination** - Offset-based vs cursor-based pagination with pros/cons
- **Filtering & Sorting** - Query parameters, operators, search implementation
- **API Versioning** - URL path vs header versioning, breaking vs non-breaking changes
- **Error Handling** - Error response structure, standard codes, best practices
- **Security Best Practices** - Authentication, HTTPS, input validation, rate limiting, CORS, audit logging

**Use when:** Designing new APIs, making architectural decisions, or establishing API standards.

**Key Sections:**
- Status code selection matrix for different operations
- Pagination comparison (offset vs cursor)
- Versioning strategies and deprecation policies
- Security checklist with 10+ items

### 2. Database Best Practices
**File:** `references/database-best-practices.md`

Comprehensive database design and optimization guide:

**Core Topics:**
- **Schema Design Principles** - Planning for growth, choosing data types, adding constraints, audit timestamps
- **Normalization** - 1NF, 2NF, 3NF with examples, when to denormalize strategically
- **Data Types** - PostgreSQL type guide, selection matrix for common use cases
- **Indexing Strategies** - When to index, B-tree/Hash/GIN/BRIN indexes, composite indexes, partial indexes, covering indexes
- **Relationships & Foreign Keys** - One-to-many, many-to-many, self-referential, ON DELETE options
- **Migrations** - Best practices, safe schema changes, zero-downtime migrations
- **Query Optimization** - EXPLAIN ANALYZE, avoiding N+1 queries, limiting results, batch operations
- **Transactions & Concurrency** - ACID properties, isolation levels, handling deadlocks
- **Performance Tuning** - Database configuration, vacuum/analyze, monitoring bloat
- **Common Patterns** - Soft delete, audit trail, optimistic locking

**Use when:** Designing database schemas, optimizing queries, or troubleshooting performance issues.

**Key Sections:**
- Index strategy guide (when to/not to add indexes)
- N+1 query problem with solutions
- Zero-downtime migration strategies
- Connection pooling configuration

### 3. Security Patterns
**File:** `references/security-patterns.md`

Complete security implementation guide:

**Core Topics:**
- **Authentication** - JWT token-based auth, session-based auth, token creation/validation, refresh tokens
- **Authorization** - Role-Based Access Control (RBAC), permission checking, resource-based authorization
- **Input Validation** - Pydantic validators, email/password/URL validation, cross-field validation
- **Password Security** - Bcrypt hashing, verification, password reset flow with tokens
- **SQL Injection Prevention** - Parameterized queries, ORM usage, safe practices
- **XSS Prevention** - Input sanitization, output encoding
- **CSRF Protection** - Token-based protection for cookie auth
- **Rate Limiting** - slowapi implementation, custom Redis-based limiter
- **Secure Configuration** - Environment variables, Pydantic settings, secrets management
- **Common Vulnerabilities** - OWASP Top 10 prevention with code examples

**Use when:** Implementing authentication/authorization, securing APIs, or conducting security reviews.

**Key Sections:**
- Complete JWT auth implementation (login, refresh, logout)
- RBAC with database schema and permission decorators
- Password reset flow with secure tokens
- Security checklist with 15+ items

### 4. Performance Optimization
**File:** `references/performance-optimization.md`

Performance tuning and optimization guide:

**Core Topics:**
- **Caching Strategies** - Redis setup, cache-aside pattern, write-through cache, invalidation strategies, multi-level caching
- **Database Query Optimization** - N+1 query solutions, indexing, selecting columns, batch operations, EXPLAIN ANALYZE
- **Connection Pooling** - Database pool configuration, Redis connection pooling
- **Async Processing** - Background tasks (FastAPI), task queues (Celery), async endpoints with concurrent requests
- **API Response Optimization** - Pagination implementation, response compression, field selection
- **Load Balancing** - Read replicas, horizontal scaling
- **Profiling & Monitoring** - Query timing middleware, slow query logging, APM integration
- **Common Performance Patterns** - Lazy vs eager loading, caching computations, read replicas

**Use when:** Optimizing API performance, reducing latency, or scaling backend systems.

**Key Sections:**
- Cache invalidation strategies (time-based, event-based, pattern-based)
- N+1 query problem with ORM solutions
- Background task implementation (FastAPI + Celery)
- Performance checklist with 12+ items

## Usage Patterns

### Pattern 1: Implementing a New API Resource

**Scenario:** Need to add a new REST API resource with full CRUD operations.

**Process:**
1. Read `api-design-principles.md` → Resource Naming & HTTP Methods sections
2. Use `database-model-template.md` to create database model
3. Use `api-endpoint-template.md` for endpoint implementation
4. Read `security-patterns.md` → Authorization section for permission checks
5. Use `api-documentation-template.md` to document endpoints

**Time:** 2-4 hours for complete implementation

**Example:**
```python
# 1. Create database model
class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    # ... from database-model-template.md

# 2. Create API endpoints
@router.post("/orders", response_model=OrderResponse)
async def create_order(order: OrderCreate, user: dict = Depends(get_current_user)):
    # ... from api-endpoint-template.md

# 3. Add authorization
@require_permission("orders:write")
async def create_order(...):
    # ... from security-patterns.md

# 4. Document in docs/api/orders.md using api-documentation-template.md
```

### Pattern 2: Optimizing Slow Endpoints

**Scenario:** API endpoints responding slowly, need to improve performance.

**Process:**
1. Read `performance-optimization.md` → Profiling & Monitoring section
2. Identify slow queries with query timing middleware
3. Read `database-best-practices.md` → Query Optimization section
4. Add indexes or optimize N+1 queries
5. Read `performance-optimization.md` → Caching Strategies section
6. Implement Redis caching for frequently accessed data
7. Monitor improvements with APM

**Time:** 4-8 hours depending on complexity

**Example:**
```python
# Before: Slow endpoint with N+1 queries
@router.get("/users")
async def list_users():
    users = await User.query.all()
    for user in users:
        user.orders = await Order.query.filter_by(user_id=user.id).all()  # N+1!

# After: Optimized with eager loading and caching
@router.get("/users")
async def list_users():
    cache_key = "users:list"
    cached = await get_cache(cache_key)
    if cached:
        return cached

    # Single query with JOIN
    users = await User.query.options(selectinload(User.orders)).all()

    # Cache for 5 minutes
    await set_cache(cache_key, users, ttl=300)
    return users
```

### Pattern 3: Implementing Authentication & Authorization

**Scenario:** Need to add JWT authentication and role-based access control.

**Process:**
1. Read `security-patterns.md` → Authentication section completely
2. Implement JWT token creation and validation
3. Create login and refresh endpoints
4. Read `security-patterns.md` → Authorization section
5. Create roles and permissions database schema
6. Implement permission decorators
7. Add authentication to all protected endpoints
8. Read `security-patterns.md` → Common Vulnerabilities checklist

**Time:** 1-2 days for complete auth system

**Example:**
```python
# 1. Create JWT tokens (from security-patterns.md)
def create_access_token(data: dict) -> str:
    expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode = data.copy()
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm="HS256")

# 2. Login endpoint
@router.post("/login")
async def login(credentials: LoginRequest):
    user = await authenticate_user(credentials.email, credentials.password)
    if not user:
        raise HTTPException(status_code=401)
    return {"access_token": create_access_token({"sub": str(user.id)})}

# 3. Protected endpoint with role check
@router.delete("/users/{user_id}")
@require_role("admin")
async def delete_user(user_id: int, current_user = Depends(get_current_user)):
    await user_service.delete(user_id)
```

### Pattern 4: Designing a New Database Schema

**Scenario:** Need to design database schema for a new feature with complex relationships.

**Process:**
1. Read `database-best-practices.md` → Schema Design Principles section
2. Read `database-best-practices.md` → Normalization section
3. Identify entities and relationships
4. Use `database-model-template.md` for each model
5. Read `database-best-practices.md` → Indexing Strategies section
6. Add appropriate indexes
7. Create Alembic migration
8. Read `database-best-practices.md` → Migrations section for safety

**Time:** 2-4 hours for complete schema design

**Example:**
```python
# E-commerce order system with relationships

# Order model (one-to-many with OrderItem)
class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    __table_args__ = (Index('idx_orders_user_created', 'user_id', 'created_at'),)

# OrderItem model (many-to-one with Order and Product)
class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    order = relationship("Order", back_populates="items")
    product = relationship("Product")

# Product model (many-to-many with Category via junction table)
class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True)
    categories = relationship("Category", secondary=product_categories)
```

### Pattern 5: Security Audit & Hardening

**Scenario:** Need to audit existing API for security vulnerabilities.

**Process:**
1. Read `security-patterns.md` → Common Vulnerabilities (OWASP Top 10) section
2. Check all endpoints for broken access control
3. Verify input validation using Pydantic schemas
4. Review `security-patterns.md` → SQL Injection Prevention section
5. Ensure parameterized queries everywhere
6. Read `security-patterns.md` → Rate Limiting section
7. Implement rate limiting on auth endpoints
8. Review `api-design-principles.md` → Security Best Practices checklist
9. Complete security checklist from `security-patterns.md`

**Time:** 4-8 hours for full audit

**Example audit checklist:**
```markdown
- [x] HTTPS enforced (no HTTP in production)
- [x] Passwords hashed with bcrypt (not plain text)
- [x] JWT tokens validated on all protected endpoints
- [x] Authorization checks on resource access
- [x] Input validation with Pydantic schemas
- [x] SQL injection prevention (parameterized queries only)
- [ ] XSS prevention (need to sanitize HTML in content fields)
- [x] Rate limiting on login endpoint
- [x] Secrets in environment variables (not hardcoded)
- [ ] CORS origins restricted (currently allows all)
- [x] Error messages don't leak stack traces
- [x] Audit logging for security events
```

## Integration with @backend-implementation-specialist

This skill is designed to complement the @backend-implementation-specialist agent:

**Agent's Role:**
- Implements features according to specifications
- Applies domain expertise and judgment
- Makes architectural decisions
- Handles edge cases and business logic

**Skill's Role:**
- Provides standardized templates for consistency
- Offers best practices and security patterns
- Ensures production-ready code quality
- Provides comprehensive reference documentation

**Workflow:**
```markdown
User: "@backend-implementation-specialist, implement a products API with authentication"

Agent:
1. Loads backend-templates skill
2. Reads api-design-principles.md for REST conventions
3. Uses database-model-template.md to create Product model
4. Uses api-endpoint-template.md for CRUD endpoints
5. Reads security-patterns.md for JWT auth implementation
6. Adds permission checks using RBAC pattern
7. Reads performance-optimization.md for caching strategy
8. Uses api-documentation-template.md for docs
9. Implements with production-ready patterns
```

## Best Practices

### 1. Start with Design Principles
Always read `api-design-principles.md` before implementing APIs to ensure RESTful conventions and proper resource naming.

### 2. Use Appropriate Template
- New API endpoint → `api-endpoint-template.md`
- New database model → `database-model-template.md`
- API documentation → `api-documentation-template.md`

### 3. Security First
Read `security-patterns.md` early in development. Authentication, authorization, and input validation should be implemented from the start, not added later.

### 4. Optimize Proactively
Review `performance-optimization.md` during design phase. Adding indexes, caching, and connection pooling is easier early than retrofitting later.

### 5. Follow Database Best Practices
Use `database-best-practices.md` for schema design. Proper normalization, indexes, and constraints prevent future performance and data integrity issues.

### 6. Document as You Build
Use `api-documentation-template.md` while implementing endpoints. Documentation is more accurate when written alongside code.

### 7. Complete Checklists
Every template includes a checklist. Complete these to ensure production readiness:
- API endpoints checklist (authentication, error handling, logging)
- Database models checklist (indexes, constraints, relationships)
- Security checklist (HTTPS, validation, rate limiting)
- Performance checklist (caching, connection pooling, monitoring)

## Resources

### assets/
Template files designed to be copied and customized:

- **api-endpoint-template.md** - Complete REST API endpoint implementation with FastAPI
- **database-model-template.md** - SQLAlchemy models with relationships and best practices
- **api-documentation-template.md** - Comprehensive API documentation format

**Usage:** Copy template, replace placeholders ({resource}, {ModelName}, etc.), customize for domain.

### references/
Comprehensive reference guides loaded into context:

- **api-design-principles.md** - RESTful design, HTTP methods/status codes, versioning, pagination, security
- **database-best-practices.md** - Schema design, normalization, indexing, query optimization, migrations
- **security-patterns.md** - Authentication (JWT), authorization (RBAC), input validation, OWASP Top 10 prevention
- **performance-optimization.md** - Caching (Redis), async processing, connection pooling, profiling

**Usage:** Read relevant sections to inform implementation decisions and ensure best practices.

## Examples

### Example 1: Building a Blog API

```markdown
User: "Implement a blog API with posts, comments, and user authentication"

Process:
1. Read api-design-principles.md → Resource hierarchies section
2. Design URLs:
   - /users (user management)
   - /posts (blog posts)
   - /posts/{id}/comments (nested comments)
3. Use database-model-template.md for models:
   - User (with password hashing from security-patterns.md)
   - Post (with indexes from database-best-practices.md)
   - Comment (self-referential for threading)
4. Use api-endpoint-template.md for all endpoints
5. Read security-patterns.md → JWT Authentication section
6. Implement login, register, token refresh
7. Add permission checks (post author can edit/delete)
8. Read performance-optimization.md → Caching section
9. Cache post listings with Redis (5 min TTL)
10. Use api-documentation-template.md for complete docs

Result:
- 15 endpoints (auth + CRUD for posts/comments)
- JWT authentication with refresh tokens
- Role-based permissions (author, commenter, admin)
- Redis caching for post listings
- Complete API documentation
- Production-ready with error handling and logging
```

### Example 2: Optimizing E-commerce Checkout

```markdown
User: "Checkout endpoint is slow, optimize it"

Process:
1. Read performance-optimization.md → Profiling section
2. Add query timing middleware
3. Identify slow query: Fetching cart items with N+1 problem
4. Read database-best-practices.md → N+1 Query Problem section
5. Fix with eager loading:
   ```python
   cart = await Cart.query.options(
       selectinload(Cart.items).selectinload(CartItem.product)
   ).get(cart_id)
   ```
6. Read database-best-practices.md → Indexing section
7. Add composite index on cart_items(cart_id, product_id)
8. Read performance-optimization.md → Caching section
9. Cache cart data with 5-minute TTL:
   ```python
   cache_key = f"cart:{cart_id}"
   cart = await get_or_set_cache(
       cache_key,
       lambda: fetch_cart_with_items(cart_id),
       ttl=300
   )
   ```
10. Read performance-optimization.md → Async Processing section
11. Move inventory check to background task
12. Verify improvements with query timing

Result:
- Query time reduced from 850ms to 45ms
- N+1 queries eliminated (20 queries → 1 query)
- Cart caching reduces DB load
- Async inventory check improves UX
- Added monitoring for future optimization
```

### Example 3: Implementing Multi-Tenant SaaS

```markdown
User: "Add multi-tenancy to existing API with tenant isolation"

Process:
1. Read database-best-practices.md → Schema Design section
2. Add tenant_id to all tenant-scoped tables
3. Use database-model-template.md for tenant models:
   ```python
   class Organization(Base):
       __tablename__ = "organizations"
       id = Column(Integer, primary_key=True)
       name = Column(String(100), unique=True)

   class Product(Base):
       __tablename__ = "products"
       id = Column(Integer, primary_key=True)
       tenant_id = Column(Integer, ForeignKey("organizations.id"))
       # Composite index for tenant queries
       __table_args__ = (Index('idx_products_tenant', 'tenant_id'),)
   ```
4. Read security-patterns.md → Authorization section
5. Implement tenant isolation middleware:
   ```python
   async def get_current_tenant(user = Depends(get_current_user)):
       return await get_user_tenant(user.id)

   @router.get("/products")
   async def list_products(tenant = Depends(get_current_tenant)):
       return await Product.query.filter_by(tenant_id=tenant.id).all()
   ```
6. Read api-design-principles.md → Security section
7. Add tenant validation to all endpoints
8. Read database-best-practices.md → Migrations section
9. Create zero-downtime migration for tenant_id column
10. Add unique constraints per tenant

Result:
- Complete tenant isolation
- Performance maintained with proper indexes
- Security enforced at middleware level
- Backward compatible migration
- Scalable multi-tenant architecture
```

## Tips & Tricks

### Tip 1: Customize Templates Incrementally
Don't implement all template features at once. Start with basic CRUD, then add pagination, filtering, and advanced features as needed.

### Tip 2: Use Checklists as Code Review Guide
Template checklists make excellent code review criteria. Share with team to ensure consistency.

### Tip 3: Combine Patterns
Mix patterns from different references. For example: Soft delete (database-best-practices.md) + Audit logging (security-patterns.md) + Caching (performance-optimization.md).

### Tip 4: Start with Security Checklist
Run through `security-patterns.md` checklist before any production deployment. Security is easier to build in than bolt on.

### Tip 5: Profile Before Optimizing
Use profiling middleware from `performance-optimization.md` to identify actual bottlenecks. Don't optimize based on assumptions.

### Tip 6: Version Your API from Day 1
Even if you don't plan breaking changes, include `/v1/` in URLs from the start. Easier than retrofitting later.

### Tip 7: Generate OpenAPI Spec
FastAPI auto-generates OpenAPI docs from code. Use `api-documentation-template.md` for extended docs beyond auto-generated.

### Tip 8: Use Template Comments as TODOs
Templates include `# TODO` comments for customization points. Use these to track implementation progress.

---

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @backend-implementation-specialist - Primary consumer of templates and reference guides
- @developer - May use templates for general backend development
- @devops-engineer - May reference performance and security patterns for infrastructure

**Extracted From:**
- Source: `templates/agents/backend-implementation-specialist.yaml`
- Total lines extracted: ~280 from agent YAML
- Templates created: 3 (API endpoint, database model, API docs)
- References created: 4 (API design, database, security, performance)
- Total documentation: ~2,000+ lines across all files
