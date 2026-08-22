# API Documentation Template

Use this template for documenting RESTful API endpoints with clear examples and error handling.

## Document Header

```markdown
# {API Name} API Documentation

## Overview
{Brief description of the API and its purpose}

**Version:** {version}
**Base URL:** `{base_url}`
**Authentication:** {auth_method}

## Table of Contents
- [Authentication](#authentication)
- [Rate Limiting](#rate-limiting)
- [Error Handling](#error-handling)
- [Endpoints](#endpoints)
  - [{Resource} Operations](#resource-operations)
```

## Authentication Section

```markdown
## Authentication

All API endpoints require authentication via JWT tokens.

### Obtaining a Token

**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### Using the Token

Include the token in the `Authorization` header for all requests:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Refresh

**POST** `/auth/refresh`

**Headers:**
```
Authorization: Bearer <refresh_token>
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```
```

## Rate Limiting Section

```markdown
## Rate Limiting

API requests are rate limited to ensure fair usage.

**Limits:**
- **Authenticated requests:** 100 requests per minute
- **Unauthenticated requests:** 20 requests per minute

**Rate Limit Headers:**

All responses include rate limit information:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

**Rate Limit Exceeded Response** (429 Too Many Requests):
```json
{
  "detail": "Rate limit exceeded. Try again in 45 seconds.",
  "status_code": 429
}
```
```

## Error Handling Section

```markdown
## Error Handling

The API uses standard HTTP status codes and returns errors in a consistent JSON format.

### Error Response Format

```json
{
  "detail": "Human-readable error message",
  "status_code": 400,
  "error_code": "VALIDATION_ERROR",
  "field_errors": {
    "email": ["Email is required", "Invalid email format"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request succeeded, no content returned |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict (duplicate, constraint violation) |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Common Error Codes

| Error Code | Description |
|------------|-------------|
| `VALIDATION_ERROR` | Input validation failed |
| `AUTHENTICATION_FAILED` | Invalid credentials |
| `PERMISSION_DENIED` | Insufficient permissions |
| `RESOURCE_NOT_FOUND` | Requested resource not found |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `INTEGRITY_ERROR` | Database constraint violation |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
```

## Endpoint Documentation Template

```markdown
## Endpoints

### {Resource} Operations

#### Create {Resource}

**POST** `/api/v1/{resources}`

Create a new {resource}.

**Authentication:** Required
**Permission:** {permission_level}

**Request Body:**
```json
{
  "name": "Example Resource",
  "description": "Optional description",
  "is_active": true,
  "category_id": 1
}
```

**Field Descriptions:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `name` | string | Yes | 1-100 chars | Resource name |
| `description` | string | No | max 500 chars | Optional description |
| `is_active` | boolean | No | default: true | Active status |
| `category_id` | integer | Yes | Must exist | Category ID |

**Success Response** (201 Created):
```json
{
  "id": 123,
  "name": "Example Resource",
  "description": "Optional description",
  "is_active": true,
  "category_id": 1,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": null
}
```

**Error Responses:**

- **400 Bad Request** - Invalid input data
  ```json
  {
    "detail": "Validation error",
    "status_code": 400,
    "field_errors": {
      "name": ["Name is required", "Name must be 1-100 characters"]
    }
  }
  ```

- **401 Unauthorized** - Missing or invalid authentication
  ```json
  {
    "detail": "Missing or invalid authentication token",
    "status_code": 401
  }
  ```

- **409 Conflict** - Resource already exists
  ```json
  {
    "detail": "Resource with this name already exists",
    "status_code": 409
  }
  ```

**cURL Example:**
```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Example Resource",
    "description": "Optional description",
    "is_active": true,
    "category_id": 1
  }'
```

**Python Example:**
```python
import requests

url = "https://api.example.com/v1/resources"
headers = {
    "Authorization": "Bearer <token>",
    "Content-Type": "application/json"
}
data = {
    "name": "Example Resource",
    "description": "Optional description",
    "is_active": True,
    "category_id": 1
}

response = requests.post(url, headers=headers, json=data)
print(response.json())
```

---

#### Get {Resource}

**GET** `/api/v1/{resources}/{id}`

Retrieve a specific {resource} by ID.

**Authentication:** Required
**Permission:** Read access to {resource}

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Resource ID |

**Success Response** (200 OK):
```json
{
  "id": 123,
  "name": "Example Resource",
  "description": "Optional description",
  "is_active": true,
  "category_id": 1,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-16T14:20:00Z"
}
```

**Error Responses:**

- **401 Unauthorized** - Missing or invalid authentication
- **403 Forbidden** - Insufficient permissions
- **404 Not Found** - Resource not found

**cURL Example:**
```bash
curl -X GET https://api.example.com/v1/resources/123 \
  -H "Authorization: Bearer <token>"
```

---

#### List {Resources}

**GET** `/api/v1/{resources}`

List {resources} with pagination and filtering.

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number (1-indexed) |
| `page_size` | integer | No | 20 | Items per page (max: 100) |
| `search` | string | No | - | Search term (searches name, description) |
| `is_active` | boolean | No | - | Filter by active status |
| `category_id` | integer | No | - | Filter by category |
| `sort_by` | string | No | created_at | Sort field (created_at, name, updated_at) |
| `sort_order` | string | No | desc | Sort order (asc, desc) |

**Success Response** (200 OK):
```json
{
  "items": [
    {
      "id": 123,
      "name": "Example Resource",
      "description": "Optional description",
      "is_active": true,
      "category_id": 1,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": null
    }
  ],
  "total": 45,
  "page": 1,
  "page_size": 20,
  "total_pages": 3
}
```

**cURL Example:**
```bash
curl -X GET "https://api.example.com/v1/resources?page=1&page_size=20&search=example&is_active=true" \
  -H "Authorization: Bearer <token>"
```

---

#### Update {Resource}

**PATCH** `/api/v1/{resources}/{id}`

Update an existing {resource}. Only provided fields will be updated.

**Authentication:** Required
**Permission:** Write access to {resource}

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Resource ID |

**Request Body:**
```json
{
  "name": "Updated Name",
  "description": "Updated description"
}
```

**Note:** All fields are optional. Only include fields you want to update.

**Success Response** (200 OK):
```json
{
  "id": 123,
  "name": "Updated Name",
  "description": "Updated description",
  "is_active": true,
  "category_id": 1,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-16T14:20:00Z"
}
```

**Error Responses:**

- **400 Bad Request** - Invalid input data
- **401 Unauthorized** - Missing or invalid authentication
- **403 Forbidden** - Insufficient permissions
- **404 Not Found** - Resource not found
- **409 Conflict** - Update would create duplicate

**cURL Example:**
```bash
curl -X PATCH https://api.example.com/v1/resources/123 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "description": "Updated description"
  }'
```

---

#### Delete {Resource}

**DELETE** `/api/v1/{resources}/{id}`

Delete a {resource}.

**Authentication:** Required
**Permission:** Delete access to {resource}

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Resource ID |

**Success Response** (204 No Content):

No response body.

**Error Responses:**

- **401 Unauthorized** - Missing or invalid authentication
- **403 Forbidden** - Insufficient permissions
- **404 Not Found** - Resource not found
- **409 Conflict** - Cannot delete (has dependencies)

**cURL Example:**
```bash
curl -X DELETE https://api.example.com/v1/resources/123 \
  -H "Authorization: Bearer <token>"
```
```

## Pagination Section

```markdown
## Pagination

List endpoints support cursor-based or offset-based pagination.

### Offset-Based Pagination

Use `page` and `page_size` query parameters:

```bash
GET /api/v1/resources?page=2&page_size=20
```

**Response includes:**
- `items` - Array of resources
- `total` - Total number of items
- `page` - Current page number
- `page_size` - Items per page
- `total_pages` - Total number of pages

### Cursor-Based Pagination

Use `cursor` and `limit` query parameters:

```bash
GET /api/v1/resources?cursor=eyJpZCI6MTIzfQ&limit=20
```

**Response includes:**
- `items` - Array of resources
- `next_cursor` - Cursor for next page (null if last page)
- `has_more` - Boolean indicating more pages exist
```

## Webhooks Section

```markdown
## Webhooks

Subscribe to events for real-time updates.

### Available Events

| Event | Description | Payload |
|-------|-------------|---------|
| `resource.created` | New resource created | {Resource}Response |
| `resource.updated` | Resource updated | {Resource}Response |
| `resource.deleted` | Resource deleted | `{"id": 123}` |

### Webhook Payload Format

```json
{
  "event": "resource.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": 123,
    "name": "Example Resource",
    "...": "..."
  }
}
```

### Webhook Signatures

All webhook requests include an `X-Webhook-Signature` header for verification:

```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
```
```

## Usage Instructions

1. **Copy this template** for each major API resource
2. **Replace placeholders**:
   - `{API Name}` - Name of the API
   - `{resource}` / `{resources}` - Singular/plural resource names
   - `{Resource}` - Capitalized resource name
   - `{base_url}` - API base URL
   - `{auth_method}` - Authentication method
   - `{permission_level}` - Required permission
3. **Document all endpoints** - Include all CRUD operations
4. **Add examples** - Include cURL and Python examples
5. **Document errors** - Include all possible error responses
6. **Keep updated** - Update when API changes

## Checklist

- [ ] All endpoints documented with HTTP method and path
- [ ] Request/response examples provided for each endpoint
- [ ] Field descriptions include type, constraints, requirements
- [ ] All error responses documented with status codes
- [ ] cURL examples provided for all endpoints
- [ ] Python examples provided for common operations
- [ ] Authentication clearly explained
- [ ] Rate limiting documented
- [ ] Pagination explained
- [ ] Webhooks documented if applicable
- [ ] Version number included
- [ ] Base URL specified
- [ ] Table of contents for easy navigation
