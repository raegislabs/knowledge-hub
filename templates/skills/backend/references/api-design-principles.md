# API Design Principles

Comprehensive guide to RESTful API design, HTTP conventions, versioning strategies, and best practices.

## Table of Contents
1. [RESTful Principles](#restful-principles)
2. [Resource Naming](#resource-naming)
3. [HTTP Methods](#http-methods)
4. [HTTP Status Codes](#http-status-codes)
5. [Request/Response Design](#requestresponse-design)
6. [Pagination](#pagination)
7. [Filtering & Sorting](#filtering--sorting)
8. [API Versioning](#api-versioning)
9. [Error Handling](#error-handling)
10. [Security Best Practices](#security-best-practices)

---

## RESTful Principles

### Core REST Concepts

**1. Resource-Based URLs**
- URLs represent resources (nouns), not actions (verbs)
- ✅ Good: `GET /users/123`
- ❌ Bad: `GET /getUser?id=123`

**2. HTTP Methods Define Actions**
- Use HTTP methods to specify operations
- ✅ Good: `DELETE /users/123`
- ❌ Bad: `POST /users/123/delete`

**3. Stateless Communication**
- Each request contains all information needed
- No session state on server
- Use tokens (JWT) for authentication

**4. Uniform Interface**
- Consistent naming conventions
- Standard response formats
- Predictable behavior across endpoints

**5. HATEOAS (Optional)**
- Hypermedia As The Engine Of Application State
- Include links to related resources in responses

---

## Resource Naming

### URL Structure

```
https://api.example.com/v1/resources/123/sub-resources/456
└──────┬────────────┘ └─┬─┘ └────┬────┘ └─┬─┘ └──────┬──────┘ └─┬─┘
   Base URL          Version Collection ID   Sub-Collection   ID
```

### Naming Conventions

**1. Use Plural Nouns for Collections**
```
✅ /users
✅ /products
✅ /orders
❌ /user
❌ /getUsers
```

**2. Use Lowercase with Hyphens**
```
✅ /order-items
✅ /user-preferences
❌ /orderItems (camelCase)
❌ /order_items (snake_case in URLs)
```

**3. Resource Hierarchies**
```
✅ /users/123/orders           # User's orders
✅ /orders/456/items           # Order's items
✅ /categories/789/products    # Category's products
```

**4. Avoid Deep Nesting (Max 2 Levels)**
```
✅ /users/123/orders
❌ /users/123/orders/456/items/789/options
   └─ Instead: /order-items/789/options
```

**5. Use Query Parameters for Non-Resource Operations**
```
✅ /users?search=john&role=admin&sort=created_at
✅ /products?category=electronics&in_stock=true
❌ /users/search/john
```

---

## HTTP Methods

### Standard CRUD Operations

| HTTP Method | Operation | URL Example | Request Body | Response | Idempotent |
|-------------|-----------|-------------|--------------|----------|------------|
| `GET` | Read (retrieve) | `/users/123` | None | Resource or list | Yes |
| `POST` | Create | `/users` | New resource | Created resource | No |
| `PUT` | Replace (full update) | `/users/123` | Complete resource | Updated resource | Yes |
| `PATCH` | Update (partial) | `/users/123` | Partial resource | Updated resource | No* |
| `DELETE` | Delete | `/users/123` | None | None (204) | Yes |

*PATCH can be designed to be idempotent

### Method Details

**GET - Retrieve Resources**
```http
# Get single resource
GET /users/123

# Get collection
GET /users

# Get nested resource
GET /users/123/orders
```

**Properties:**
- No request body
- Safe (doesn't modify data)
- Idempotent (multiple calls = same result)
- Cacheable

**POST - Create New Resource**
```http
POST /users
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "John Doe"
}
```

**Response:**
```http
HTTP/1.1 201 Created
Location: /users/456
Content-Type: application/json

{
  "id": 456,
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Properties:**
- Includes request body
- Not idempotent (creates new resource each time)
- Returns 201 Created with Location header

**PUT - Replace Resource**
```http
PUT /users/123
Content-Type: application/json

{
  "email": "newemail@example.com",
  "name": "John Updated",
  "bio": "New bio"
}
```

**Properties:**
- Replaces entire resource
- Idempotent (same PUT = same result)
- All fields required (omitted fields set to null/default)

**PATCH - Partial Update**
```http
PATCH /users/123
Content-Type: application/json

{
  "name": "John Updated"
}
```

**Properties:**
- Updates only provided fields
- Other fields unchanged
- Preferred over PUT for updates

**DELETE - Remove Resource**
```http
DELETE /users/123
```

**Response:**
```http
HTTP/1.1 204 No Content
```

**Properties:**
- No request body
- No response body (204)
- Idempotent (deleting twice = same result)

---

## HTTP Status Codes

### Success Codes (2xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| **200 OK** | Success | GET, PATCH, PUT succeeded |
| **201 Created** | Resource created | POST succeeded |
| **204 No Content** | Success, no content | DELETE, PUT succeeded |

### Client Error Codes (4xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| **400 Bad Request** | Invalid request | Malformed JSON, missing required fields |
| **401 Unauthorized** | Authentication failed | Missing/invalid token |
| **403 Forbidden** | Insufficient permissions | Valid auth, but not allowed |
| **404 Not Found** | Resource not found | Resource doesn't exist |
| **409 Conflict** | Conflict with current state | Duplicate resource, version conflict |
| **422 Unprocessable Entity** | Validation error | Valid JSON, but business rule violated |
| **429 Too Many Requests** | Rate limit exceeded | Too many requests |

### Server Error Codes (5xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| **500 Internal Server Error** | Server error | Unexpected error |
| **503 Service Unavailable** | Service down | Maintenance, overload |

### Status Code Selection Matrix

| Operation | Success | Not Found | Permission | Duplicate | Validation Error |
|-----------|---------|-----------|------------|-----------|------------------|
| **GET** | 200 | 404 | 403 | - | - |
| **POST** | 201 | - | 403 | 409 | 400/422 |
| **PUT/PATCH** | 200 | 404 | 403 | 409 | 400/422 |
| **DELETE** | 204 | 404 | 403 | - | - |

---

## Request/Response Design

### Request Body Format

**JSON Request (Preferred)**
```http
POST /users
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "John Doe",
  "preferences": {
    "theme": "dark",
    "notifications": true
  }
}
```

**Conventions:**
- Use `camelCase` or `snake_case` consistently (prefer camelCase for JSON)
- Include only necessary fields
- Use nested objects for related data
- Use arrays for collections

### Response Format

**Single Resource Response**
```json
{
  "id": 123,
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-16T14:20:00Z"
}
```

**Collection Response**
```json
{
  "items": [
    {"id": 1, "name": "Item 1"},
    {"id": 2, "name": "Item 2"}
  ],
  "total": 45,
  "page": 1,
  "page_size": 20
}
```

**Error Response**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  }
}
```

---

## Pagination

### Offset-Based Pagination (Simple)

**Request:**
```http
GET /users?page=2&page_size=20
```

**Response:**
```json
{
  "items": [...],
  "total": 150,
  "page": 2,
  "page_size": 20,
  "total_pages": 8
}
```

**Pros:**
- Simple to implement
- Can jump to any page
- Shows total count

**Cons:**
- Performance degrades with large offsets
- Inconsistent results if data changes during pagination

### Cursor-Based Pagination (Scalable)

**Request:**
```http
GET /users?cursor=eyJpZCI6MTAwfQ&limit=20
```

**Response:**
```json
{
  "items": [...],
  "next_cursor": "eyJpZCI6MTIwfQ",
  "has_more": true
}
```

**Pros:**
- Consistent performance regardless of position
- Handles real-time data changes
- Works well for infinite scroll

**Cons:**
- Cannot jump to arbitrary page
- No total count (expensive to compute)

### Pagination Best Practices

1. **Set Maximum Page Size**
   ```python
   page_size = min(request.page_size, MAX_PAGE_SIZE)  # e.g., 100
   ```

2. **Default Page Size**
   ```python
   page_size = request.page_size or DEFAULT_PAGE_SIZE  # e.g., 20
   ```

3. **Include Pagination Metadata**
   ```json
   {
     "items": [...],
     "pagination": {
       "total": 150,
       "page": 2,
       "page_size": 20,
       "total_pages": 8
     }
   }
   ```

---

## Filtering & Sorting

### Filtering

**Query Parameter Filtering**
```http
GET /users?role=admin&is_active=true&created_after=2024-01-01
```

**Conventions:**
- Use query parameters for simple filters
- Support common operators via suffixes:
  - `?price_gt=100` (greater than)
  - `?price_gte=100` (greater than or equal)
  - `?price_lt=100` (less than)
  - `?price_lte=100` (less than or equal)
  - `?name_contains=john` (substring search)
  - `?tags_in=python,javascript` (IN operator)

**Complex Filtering (Advanced)**
```http
POST /users/search
Content-Type: application/json

{
  "filters": [
    {"field": "role", "operator": "eq", "value": "admin"},
    {"field": "created_at", "operator": "gte", "value": "2024-01-01"}
  ],
  "logic": "AND"
}
```

### Sorting

**Single Field Sort**
```http
GET /users?sort_by=created_at&sort_order=desc
```

**Multiple Field Sort**
```http
GET /users?sort=name:asc,created_at:desc
```

**Conventions:**
- Default sort order: descending for timestamps, ascending for names
- Support common sort fields out of the box
- Validate sort fields (prevent SQL injection)

### Search

**Full-Text Search**
```http
GET /products?search=laptop&category=electronics
```

**Implementation:**
- Use database full-text search (PostgreSQL: `tsvector`)
- Or integrate with Elasticsearch/Meilisearch for advanced search
- Return relevance scores for ranking

---

## API Versioning

### URL Path Versioning (Recommended)

```http
GET /v1/users/123
GET /v2/users/123
```

**Pros:**
- Simple, visible in URL
- Easy to route/cache
- Clear separation

**Cons:**
- URL changes on version update

### Header Versioning

```http
GET /users/123
Accept: application/vnd.example.v2+json
```

**Pros:**
- Clean URLs
- Fine-grained control

**Cons:**
- Less visible
- Harder to test (need to set headers)

### Versioning Best Practices

1. **Start with v1** - Don't use v0 or no version
2. **Don't over-version** - Only increment for breaking changes
3. **Support Multiple Versions** - Maintain at least 2 versions
4. **Deprecation Policy** - Give 6-12 months notice
5. **Document Changes** - Maintain changelog

**Breaking vs Non-Breaking Changes:**

**Breaking (requires new version):**
- Removing fields
- Renaming fields
- Changing field types
- Changing status code semantics
- Removing endpoints

**Non-Breaking (can stay in same version):**
- Adding new fields (optional)
- Adding new endpoints
- Adding new optional query parameters
- Fixing bugs

---

## Error Handling

### Error Response Structure

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "code": "INVALID_FORMAT"
      }
    ],
    "request_id": "abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Standard Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `VALIDATION_ERROR` | 400/422 | Input validation failed |
| `AUTHENTICATION_FAILED` | 401 | Invalid credentials |
| `PERMISSION_DENIED` | 403 | Insufficient permissions |
| `RESOURCE_NOT_FOUND` | 404 | Resource doesn't exist |
| `DUPLICATE_RESOURCE` | 409 | Resource already exists |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

### Error Handling Best Practices

1. **Be Specific**
   ```json
   ❌ "An error occurred"
   ✅ "Email format is invalid. Expected: user@domain.com"
   ```

2. **Include Field-Level Errors**
   ```json
   {
     "error": {
       "message": "Validation failed",
       "details": [
         {"field": "email", "message": "Email is required"},
         {"field": "password", "message": "Password must be at least 8 characters"}
       ]
     }
   }
   ```

3. **Include Request ID** (for debugging)
   ```json
   {"error": {"request_id": "abc123"}}
   ```

4. **Don't Expose Internals**
   ```json
   ❌ "SQL error: SELECT * FROM users WHERE id = 123"
   ✅ "Unable to retrieve user"
   ```

---

## Security Best Practices

### 1. Authentication

**Use JWT Tokens**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Best Practices:**
- Short expiration (15-60 minutes for access tokens)
- Refresh tokens for renewal
- Secure storage (httpOnly cookies or secure storage)
- Validate on every request

### 2. HTTPS Only

- ✅ Always use HTTPS in production
- ❌ Never send credentials over HTTP
- Redirect HTTP to HTTPS

### 3. Input Validation

**Validate All Inputs**
```python
from pydantic import BaseModel, Field, validator

class UserCreate(BaseModel):
    email: str = Field(..., max_length=255)
    password: str = Field(..., min_length=8, max_length=128)

    @validator('email')
    def validate_email(cls, v):
        if not is_valid_email(v):
            raise ValueError('Invalid email format')
        return v.lower()
```

### 4. Rate Limiting

**Implement Rate Limits**
```python
# Example limits
RATE_LIMITS = {
    'authenticated': '100/minute',
    'anonymous': '20/minute',
    'login': '5/minute'  # Stricter for auth endpoints
}
```

**Rate Limit Headers**
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

### 5. CORS Configuration

**Restrict Origins**
```python
ALLOWED_ORIGINS = [
    'https://example.com',
    'https://app.example.com'
]

# Never use: ALLOWED_ORIGINS = ['*']
```

### 6. SQL Injection Prevention

**Use Parameterized Queries**
```python
✅ db.execute("SELECT * FROM users WHERE id = ?", (user_id,))
❌ db.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

**Use ORMs**
```python
✅ User.query.filter_by(id=user_id).first()
```

### 7. Authorization

**Check Permissions on Every Request**
```python
async def get_resource(resource_id: int, current_user: User):
    resource = await get_resource_by_id(resource_id)

    if not resource:
        raise HTTPException(status_code=404)

    # Check permission
    if resource.owner_id != current_user.id and not current_user.is_admin:
        raise HTTPException(status_code=403)

    return resource
```

### 8. Audit Logging

**Log Security Events**
```python
logger.info(f"User {user_id} accessed resource {resource_id}", extra={
    'event': 'resource_access',
    'user_id': user_id,
    'resource_id': resource_id,
    'ip_address': request.client.host
})
```

### Security Checklist

- [ ] HTTPS enforced
- [ ] Authentication on all endpoints (except public)
- [ ] Authorization checks implemented
- [ ] Input validation with schemas
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] SQL injection prevention (parameterized queries)
- [ ] Sensitive data not logged
- [ ] Error messages don't leak internals
- [ ] Audit logging for security events
