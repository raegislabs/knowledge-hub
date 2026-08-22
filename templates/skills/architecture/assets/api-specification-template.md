# {API Name} Specification

**Version:** 1.0.0
**Date:** YYYY-MM-DD
**Base URL:** `https://api.example.com/v1`
**Protocol:** REST / gRPC / GraphQL

## Overview

### Purpose

[Brief description of what this API does and who it's for]

**Example:** This API provides programmatic access to user notification services, allowing applications to send email, SMS, and push notifications with delivery tracking.

### Key Features

- [Feature 1, e.g., "Multi-channel notification delivery"]
- [Feature 2, e.g., "Template-based messaging"]
- [Feature 3, e.g., "Delivery status tracking"]
- [Feature 4, e.g., "Batch processing support"]

### Design Principles

- **RESTful Design:** Follows REST conventions for resource-based URLs
- **JSON-First:** All requests and responses use JSON
- **Idempotency:** POST/PUT/PATCH operations support idempotency keys
- **Versioning:** API version in URL path (`/v1/`)
- **Pagination:** Cursor-based pagination for list endpoints
- **Rate Limiting:** 1000 requests/hour per API key

## Authentication

### API Keys

All requests require authentication via API key in the Authorization header:

```http
Authorization: Bearer sk_live_abc123def456
```

**API Key Types:**
- `sk_test_*` - Test mode (sandbox environment)
- `sk_live_*` - Production mode

**Security:**
- Store keys securely (environment variables, secrets manager)
- Never commit keys to version control
- Rotate keys every 90 days
- Use separate keys per environment

### OAuth 2.0 (Optional)

For user-delegated access:

```http
Authorization: Bearer {oauth_access_token}
```

**Supported Flows:**
- Authorization Code (for web apps)
- Client Credentials (for server-to-server)

**Scopes:**
- `notifications:read` - Read notification status
- `notifications:write` - Create and send notifications
- `notifications:admin` - Full access including deletion

## Endpoints

### Notifications

#### Create Notification

Send a single notification to a user.

```http
POST /v1/notifications
Content-Type: application/json
Authorization: Bearer {api_key}
Idempotency-Key: {unique_request_id}

{
  "user_id": "usr_abc123",
  "channel": "email",
  "template_id": "welcome_email",
  "data": {
    "user_name": "John Doe",
    "action_url": "https://example.com/verify"
  },
  "metadata": {
    "campaign_id": "onboarding_2024"
  }
}
```

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | Yes | Unique user identifier |
| `channel` | string | Yes | Delivery channel: `email`, `sms`, `push` |
| `template_id` | string | Yes | Template to use for message |
| `data` | object | Yes | Template variables |
| `metadata` | object | No | Custom metadata (max 10 keys) |
| `scheduled_at` | string | No | ISO 8601 timestamp for scheduled delivery |
| `priority` | string | No | `high`, `normal`, `low` (default: `normal`) |

**Response 201 Created:**

```json
{
  "id": "ntf_xyz789",
  "user_id": "usr_abc123",
  "channel": "email",
  "status": "queued",
  "created_at": "2024-10-24T10:30:00Z",
  "scheduled_at": null,
  "metadata": {
    "campaign_id": "onboarding_2024"
  }
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique notification identifier |
| `user_id` | string | User who receives notification |
| `channel` | string | Delivery channel |
| `status` | string | Current status (see [Status Values](#status-values)) |
| `created_at` | string | ISO 8601 creation timestamp |
| `scheduled_at` | string | ISO 8601 scheduled send time (null if immediate) |
| `metadata` | object | Custom metadata from request |

**Errors:**

| Code | Status | Description | Resolution |
|------|--------|-------------|------------|
| `invalid_channel` | 400 | Unsupported channel type | Use: `email`, `sms`, or `push` |
| `template_not_found` | 404 | Template ID doesn't exist | Check template ID or create template first |
| `user_not_found` | 404 | User ID doesn't exist | Verify user ID or create user |
| `rate_limit_exceeded` | 429 | Too many requests | Wait and retry after `Retry-After` header |
| `unauthorized` | 401 | Invalid API key | Check API key is correct |

#### Get Notification

Retrieve details and status of a notification.

```http
GET /v1/notifications/{notification_id}
Authorization: Bearer {api_key}
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `notification_id` | string | Notification ID (e.g., `ntf_xyz789`) |

**Response 200 OK:**

```json
{
  "id": "ntf_xyz789",
  "user_id": "usr_abc123",
  "channel": "email",
  "template_id": "welcome_email",
  "status": "delivered",
  "created_at": "2024-10-24T10:30:00Z",
  "sent_at": "2024-10-24T10:30:15Z",
  "delivered_at": "2024-10-24T10:30:18Z",
  "attempts": 1,
  "last_attempt_at": "2024-10-24T10:30:15Z",
  "metadata": {
    "campaign_id": "onboarding_2024"
  },
  "delivery_details": {
    "recipient": "user@example.com",
    "provider": "sendgrid",
    "provider_id": "sg_msg_123"
  }
}
```

**Additional Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `sent_at` | string | Timestamp when notification was sent (null if not sent) |
| `delivered_at` | string | Timestamp when delivery confirmed (null if not delivered) |
| `failed_at` | string | Timestamp of last failure (null if no failures) |
| `attempts` | integer | Number of delivery attempts |
| `last_attempt_at` | string | Timestamp of most recent attempt |
| `delivery_details` | object | Provider-specific delivery information |

#### List Notifications

List all notifications with filtering and pagination.

```http
GET /v1/notifications?user_id={user_id}&status={status}&limit={limit}&cursor={cursor}
Authorization: Bearer {api_key}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter by user ID |
| `channel` | string | No | Filter by channel (`email`, `sms`, `push`) |
| `status` | string | No | Filter by status (see [Status Values](#status-values)) |
| `created_after` | string | No | ISO 8601 timestamp (inclusive) |
| `created_before` | string | No | ISO 8601 timestamp (exclusive) |
| `limit` | integer | No | Results per page (default: 20, max: 100) |
| `cursor` | string | No | Pagination cursor from previous response |

**Response 200 OK:**

```json
{
  "data": [
    {
      "id": "ntf_xyz789",
      "user_id": "usr_abc123",
      "channel": "email",
      "status": "delivered",
      "created_at": "2024-10-24T10:30:00Z"
    }
  ],
  "has_more": true,
  "next_cursor": "cursor_abc123"
}
```

**Pagination:**
- Use `cursor` from `next_cursor` in subsequent requests
- `has_more` indicates if more results exist
- Cursors are opaque strings, don't parse or construct manually

#### Batch Create Notifications

Send multiple notifications in a single request.

```http
POST /v1/notifications/batch
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "notifications": [
    {
      "user_id": "usr_1",
      "channel": "email",
      "template_id": "welcome_email",
      "data": { ... }
    },
    {
      "user_id": "usr_2",
      "channel": "sms",
      "template_id": "verification_sms",
      "data": { ... }
    }
  ]
}
```

**Limits:**
- Max 100 notifications per batch
- All notifications processed atomically (all succeed or all fail)

**Response 201 Created:**

```json
{
  "notifications": [
    {
      "id": "ntf_1",
      "status": "queued"
    },
    {
      "id": "ntf_2",
      "status": "queued"
    }
  ],
  "total": 2
}
```

### Templates

#### List Templates

```http
GET /v1/templates?channel={channel}&limit={limit}
Authorization: Bearer {api_key}
```

**Response 200 OK:**

```json
{
  "data": [
    {
      "id": "welcome_email",
      "name": "Welcome Email",
      "channel": "email",
      "subject": "Welcome to {{app_name}}!",
      "variables": ["app_name", "user_name", "action_url"],
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "has_more": false
}
```

## Data Models

### Notification Object

```typescript
interface Notification {
  id: string;                    // Unique identifier (ntf_*)
  user_id: string;               // User identifier
  channel: 'email' | 'sms' | 'push';
  template_id: string;           // Template used
  status: NotificationStatus;    // Current status
  created_at: string;            // ISO 8601 timestamp
  sent_at: string | null;        // When sent (null if not sent)
  delivered_at: string | null;   // When delivered (null if not delivered)
  failed_at: string | null;      // Last failure timestamp
  attempts: number;              // Delivery attempt count
  last_attempt_at: string | null;
  metadata: Record<string, any>; // Custom metadata
  delivery_details?: {           // Provider-specific details
    recipient: string;
    provider: string;
    provider_id: string;
  };
}
```

### Status Values

| Status | Description |
|--------|-------------|
| `queued` | Notification queued for sending |
| `sending` | Currently being sent to provider |
| `sent` | Sent to provider (delivery not confirmed) |
| `delivered` | Delivery confirmed by provider |
| `failed` | Delivery failed (will retry based on policy) |
| `bounced` | Permanently failed (invalid recipient) |
| `cancelled` | Cancelled before sending |

### Template Object

```typescript
interface Template {
  id: string;                    // Unique identifier
  name: string;                  // Human-readable name
  channel: 'email' | 'sms' | 'push';
  subject?: string;              // Email subject (email only)
  body: string;                  // Message body with variables
  variables: string[];           // Required variable names
  created_at: string;
  updated_at: string;
}
```

## Error Handling

### Error Response Format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "invalid_request",
    "message": "The 'channel' field is required",
    "param": "channel",
    "type": "validation_error"
  }
}
```

**Error Object Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | Machine-readable error code |
| `message` | string | Human-readable error message |
| `param` | string | Parameter that caused error (if applicable) |
| `type` | string | Error category |

### Error Types

| Type | HTTP Status | Description |
|------|-------------|-------------|
| `authentication_error` | 401 | Invalid or missing API key |
| `authorization_error` | 403 | Valid API key but insufficient permissions |
| `validation_error` | 400 | Invalid request parameters |
| `not_found_error` | 404 | Requested resource doesn't exist |
| `rate_limit_error` | 429 | Too many requests |
| `server_error` | 500 | Internal server error (retry with backoff) |

### Retry Logic

**Recommended Retry Strategy:**

```python
import time
from typing import Optional

def make_api_request_with_retry(
    request_func,
    max_retries: int = 3,
    backoff_factor: float = 2.0
) -> Optional[dict]:
    """Retry API requests with exponential backoff."""
    for attempt in range(max_retries):
        try:
            response = request_func()
            if response.status_code == 429:
                # Rate limited - use Retry-After header
                retry_after = int(response.headers.get('Retry-After', 60))
                time.sleep(retry_after)
                continue
            elif response.status_code >= 500:
                # Server error - exponential backoff
                if attempt < max_retries - 1:
                    time.sleep(backoff_factor ** attempt)
                    continue
            return response.json()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(backoff_factor ** attempt)
    return None
```

**Retry Guidelines:**
- ✅ **DO** retry: 429 (rate limit), 500 (server error), network errors
- ❌ **DON'T** retry: 400 (validation), 401 (auth), 404 (not found)
- Use exponential backoff: 1s, 2s, 4s, 8s, ...
- Respect `Retry-After` header for 429 responses
- Set reasonable timeout (10-30 seconds)

## Rate Limiting

**Limits:**
- 1000 requests/hour per API key (test mode)
- 10,000 requests/hour per API key (production mode)
- 100 requests/minute per IP address

**Rate Limit Headers:**

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 742
X-RateLimit-Reset: 1698163200
```

**When Rate Limited:**

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1698163200

{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Rate limit exceeded. Retry after 3600 seconds.",
    "type": "rate_limit_error"
  }
}
```

## Webhooks

Subscribe to events via webhooks to receive real-time updates.

### Webhook Events

| Event | Description |
|-------|-------------|
| `notification.queued` | Notification queued for delivery |
| `notification.sent` | Notification sent to provider |
| `notification.delivered` | Delivery confirmed |
| `notification.failed` | Delivery failed |
| `notification.bounced` | Permanent delivery failure |

### Webhook Payload

```http
POST {your_webhook_url}
Content-Type: application/json
X-Webhook-Signature: sha256=abc123...

{
  "id": "evt_abc123",
  "type": "notification.delivered",
  "created_at": "2024-10-24T10:30:00Z",
  "data": {
    "notification": {
      "id": "ntf_xyz789",
      "user_id": "usr_abc123",
      "status": "delivered",
      "delivered_at": "2024-10-24T10:30:18Z"
    }
  }
}
```

### Webhook Signature Verification

Verify webhook authenticity using HMAC SHA256:

```python
import hmac
import hashlib

def verify_webhook_signature(
    payload: bytes,
    signature: str,
    secret: str
) -> bool:
    """Verify webhook signature."""
    expected = hmac.new(
        secret.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)
```

## Idempotency

Prevent duplicate operations by providing an idempotency key:

```http
POST /v1/notifications
Idempotency-Key: unique_request_id_123
```

**Behavior:**
- Same idempotency key within 24 hours → returns cached response
- Different parameters with same key → returns 400 error
- Keys expire after 24 hours

**Best Practices:**
- Use UUIDs or unique transaction IDs
- Store idempotency keys with request parameters
- Retry failed requests with same key

## Versioning

**Current Version:** v1

**Version Strategy:**
- API version in URL path: `/v1/`, `/v2/`
- Breaking changes trigger new major version
- Non-breaking changes (new fields, endpoints) added to current version
- Old versions supported for 12 months after new version release

**Deprecation Process:**
1. New version announced 6 months in advance
2. Deprecation warnings added to responses
3. Old version maintained for 12 months
4. Old version sunset after grace period

## Code Examples

### Python

```python
import requests
import os

API_KEY = os.getenv("API_KEY")
BASE_URL = "https://api.example.com/v1"

def send_notification(user_id: str, template_id: str, data: dict):
    """Send a notification."""
    response = requests.post(
        f"{BASE_URL}/notifications",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        },
        json={
            "user_id": user_id,
            "channel": "email",
            "template_id": template_id,
            "data": data
        }
    )
    response.raise_for_status()
    return response.json()

# Usage
notification = send_notification(
    user_id="usr_123",
    template_id="welcome_email",
    data={"user_name": "John Doe"}
)
print(f"Notification ID: {notification['id']}")
```

### JavaScript/TypeScript

```typescript
const API_KEY = process.env.API_KEY;
const BASE_URL = "https://api.example.com/v1";

async function sendNotification(
  userId: string,
  templateId: string,
  data: Record<string, any>
) {
  const response = await fetch(`${BASE_URL}/notifications`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      user_id: userId,
      channel: "email",
      template_id: templateId,
      data
    })
  });

  if (!response.ok) {
    throw new Error(`API error: ${response.statusText}`);
  }

  return await response.json();
}

// Usage
const notification = await sendNotification(
  "usr_123",
  "welcome_email",
  { user_name: "John Doe" }
);
console.log(`Notification ID: ${notification.id}`);
```

## Testing

### Test Mode

Use test API keys (`sk_test_*`) to access sandbox environment:

- No actual notifications sent
- Simulates delivery with configurable delays
- All API features available
- Separate data from production

### Test Cards

Use special user IDs to simulate different scenarios:

| User ID | Behavior |
|---------|----------|
| `usr_test_success` | Always delivers successfully |
| `usr_test_fail` | Always fails delivery |
| `usr_test_bounce` | Always bounces (invalid recipient) |
| `usr_test_slow` | Simulates slow delivery (30s delay) |

## Support & Resources

**Documentation:** https://docs.example.com
**API Reference:** https://api.example.com/docs
**Support:** support@example.com
**Status Page:** https://status.example.com

**SDKs:**
- Python: `pip install example-notifications`
- Node.js: `npm install @example/notifications`
- Ruby: `gem install example-notifications`

---

**Specification Version:** 1.0.0
**Last Updated:** 2024-10-24
**Next Review:** 2025-01-24
