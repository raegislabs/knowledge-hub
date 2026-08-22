# Component Design: {Component Name}

**Version:** 1.0
**Date:** YYYY-MM-DD
**Author:** [Name/Team]
**Status:** [Draft | In Review | Approved | Implemented]

## Overview

### Purpose

[What does this component do? What problem does it solve?]

**Example:** The NotificationService component is responsible for orchestrating the delivery of notifications across multiple channels (email, SMS, push). It handles template rendering, provider routing, retry logic, and delivery tracking.

### Scope

**Responsibilities:**
- [Primary responsibility 1]
- [Primary responsibility 2]
- [Primary responsibility 3]

**Not Responsible For:**
- [What this component explicitly doesn't do]
- [Responsibilities that belong elsewhere]

### Position in System

```
[ASCII diagram showing where this component fits in the overall architecture]

Example:
┌─────────────────┐
│   API Gateway   │
└────────┬────────┘
         │
         v
┌─────────────────┐      ┌──────────────┐
│ NotificationSvc │─────▶│  Providers   │
└────────┬────────┘      └──────────────┘
         │
         v
┌─────────────────┐
│    Database     │
└─────────────────┘
```

## Component Details

### Inputs

**Primary Input: NotificationRequest**

```python
@dataclass
class NotificationRequest:
    user_id: str
    channel: NotificationChannel  # email, sms, push
    template_id: str
    data: Dict[str, Any]
    priority: Priority = Priority.NORMAL
    scheduled_at: Optional[datetime] = None
    metadata: Optional[Dict[str, Any]] = None
```

**Description:** [Explain what this input represents and where it comes from]

**Validation Rules:**
- `user_id`: Must be valid UUID
- `channel`: Must be one of supported channels
- `template_id`: Must exist in template registry
- `data`: Must contain all required template variables
- `priority`: Determines queue and retry behavior

**Additional Inputs:**

**Input: StatusQuery**
```python
@dataclass
class StatusQuery:
    notification_id: str
    include_attempts: bool = False
```

### Outputs

**Primary Output: NotificationResult**

```python
@dataclass
class NotificationResult:
    id: str
    status: NotificationStatus
    created_at: datetime
    queued_at: Optional[datetime]
    sent_at: Optional[datetime]
    delivered_at: Optional[datetime]
    attempts: int
    error: Optional[NotificationError] = None
```

**Description:** [Explain what this output represents and who consumes it]

**Status Values:**
- `QUEUED`: Accepted and queued for processing
- `SENDING`: Currently being sent to provider
- `SENT`: Sent to provider (delivery pending)
- `DELIVERED`: Confirmed delivery
- `FAILED`: Failed after all retries
- `BOUNCED`: Permanently failed (invalid recipient)

**Additional Outputs:**

**Side Effects:**
- Writes to `notifications` database table
- Publishes events to message queue
- Updates metrics/monitoring systems

### Interfaces

#### Public Interface

**Method 1: send()**

```python
def send(
    self,
    request: NotificationRequest
) -> NotificationResult:
    """
    Send a notification immediately or schedule for future delivery.

    Args:
        request: Notification details and configuration

    Returns:
        NotificationResult with status and tracking ID

    Raises:
        InvalidTemplateError: Template doesn't exist or invalid
        InvalidUserError: User ID doesn't exist
        RateLimitError: User has exceeded rate limit
        ProviderError: All providers failed
    """
```

**Method 2: get_status()**

```python
def get_status(
    self,
    notification_id: str,
    include_attempts: bool = False
) -> NotificationResult:
    """
    Get current status of a notification.

    Args:
        notification_id: Unique notification identifier
        include_attempts: Include detailed attempt history

    Returns:
        Current notification status and metadata

    Raises:
        NotFoundError: Notification doesn't exist
    """
```

**Method 3: cancel()**

```python
def cancel(self, notification_id: str) -> bool:
    """
    Cancel a scheduled notification before it's sent.

    Args:
        notification_id: Unique notification identifier

    Returns:
        True if cancelled, False if already sent

    Raises:
        NotFoundError: Notification doesn't exist
    """
```

#### Internal Interface

**Method: _render_template()**

```python
def _render_template(
    self,
    template_id: str,
    data: Dict[str, Any]
) -> RenderedTemplate:
    """Render template with provided data."""
```

**Method: _select_provider()**

```python
def _select_provider(
    self,
    channel: NotificationChannel,
    priority: Priority
) -> NotificationProvider:
    """Select appropriate provider based on channel and priority."""
```

**Method: _retry_with_backoff()**

```python
def _retry_with_backoff(
    self,
    operation: Callable,
    max_attempts: int = 3
) -> Any:
    """Retry failed operations with exponential backoff."""
```

### Dependencies

#### External Dependencies

**Dependency 1: TemplateRegistry**
- **Purpose:** Retrieve and validate notification templates
- **Interface:** `TemplateRegistry.get(template_id: str) -> Template`
- **Error Handling:** Raises `TemplateNotFoundError` if template missing
- **Caching:** Templates cached for 5 minutes
- **Fallback:** Return error if template unavailable

**Dependency 2: NotificationProvider (Interface)**
- **Purpose:** Abstract interface for delivery providers (SendGrid, Twilio, etc.)
- **Interface:**
  ```python
  class NotificationProvider(Protocol):
      def send(self, recipient: str, content: str) -> ProviderResult: ...
  ```
- **Implementations:** `EmailProvider`, `SMSProvider`, `PushProvider`
- **Error Handling:** Catch provider exceptions, log, and retry
- **Circuit Breaker:** Skip provider if 50% failure rate in last 5 minutes

**Dependency 3: NotificationRepository**
- **Purpose:** Persist notification records and status
- **Interface:**
  ```python
  class NotificationRepository:
      def create(self, notification: Notification) -> str: ...
      def update_status(self, id: str, status: NotificationStatus): ...
      def get_by_id(self, id: str) -> Optional[Notification]: ...
  ```
- **Error Handling:** Database errors bubble up as `DatabaseError`

**Dependency 4: EventPublisher**
- **Purpose:** Publish notification lifecycle events
- **Interface:** `EventPublisher.publish(event: NotificationEvent)`
- **Events:** `notification.queued`, `notification.sent`, `notification.delivered`, `notification.failed`
- **Error Handling:** Best-effort delivery (log if publish fails, don't block)

#### Configuration Dependencies

**Config: NotificationConfig**
```python
@dataclass
class NotificationConfig:
    max_retries: int = 3
    retry_backoff_seconds: int = 2
    default_priority: Priority = Priority.NORMAL
    rate_limit_per_user: int = 100  # per hour
    provider_timeout_seconds: int = 30
```

### State Management

**Stateless Design:**
- Component has no internal state
- All state persisted in database via NotificationRepository
- Each method call is independent

**State Lifecycle:**

```
1. CREATED (constructor) → Component initialized with dependencies
2. PROCESSING (send call) → Validates, renders, routes, persists
3. COMPLETE (return) → Result returned, no state retained
```

**Concurrency Considerations:**
- Thread-safe: No shared mutable state
- Multiple instances can run in parallel
- Database handles concurrency via transactions

## Implementation Design

### Class Structure

```python
from typing import Protocol, Optional, Dict, Any
from dataclasses import dataclass
from datetime import datetime

class NotificationService:
    """
    Orchestrates notification delivery across multiple channels.

    This service handles template rendering, provider routing, retry logic,
    and status tracking for email, SMS, and push notifications.
    """

    def __init__(
        self,
        template_registry: TemplateRegistry,
        providers: Dict[NotificationChannel, NotificationProvider],
        repository: NotificationRepository,
        event_publisher: EventPublisher,
        config: NotificationConfig
    ):
        """
        Initialize notification service with dependencies.

        Args:
            template_registry: Template retrieval service
            providers: Map of channel to provider implementation
            repository: Database persistence layer
            event_publisher: Event publishing for monitoring
            config: Service configuration
        """
        self._template_registry = template_registry
        self._providers = providers
        self._repository = repository
        self._event_publisher = event_publisher
        self._config = config

    def send(self, request: NotificationRequest) -> NotificationResult:
        """Send notification (see interface above for details)."""
        # 1. Validate request
        self._validate_request(request)

        # 2. Check rate limits
        if self._is_rate_limited(request.user_id):
            raise RateLimitError(f"User {request.user_id} rate limited")

        # 3. Render template
        rendered = self._render_template(request.template_id, request.data)

        # 4. Create notification record
        notification_id = self._repository.create(
            Notification(
                user_id=request.user_id,
                channel=request.channel,
                template_id=request.template_id,
                status=NotificationStatus.QUEUED,
                created_at=datetime.utcnow()
            )
        )

        # 5. Publish queued event
        self._event_publisher.publish(
            NotificationEvent(type="notification.queued", id=notification_id)
        )

        # 6. Route to provider and send
        try:
            provider = self._select_provider(request.channel, request.priority)
            result = self._send_with_retry(provider, rendered, notification_id)
            return result
        except Exception as e:
            self._handle_send_failure(notification_id, e)
            raise

    def get_status(
        self,
        notification_id: str,
        include_attempts: bool = False
    ) -> NotificationResult:
        """Get notification status (see interface above)."""
        notification = self._repository.get_by_id(notification_id)
        if not notification:
            raise NotFoundError(f"Notification {notification_id} not found")

        return NotificationResult(
            id=notification.id,
            status=notification.status,
            created_at=notification.created_at,
            sent_at=notification.sent_at,
            delivered_at=notification.delivered_at,
            attempts=notification.attempts
        )

    # Private methods
    def _validate_request(self, request: NotificationRequest) -> None:
        """Validate notification request."""
        pass

    def _render_template(
        self,
        template_id: str,
        data: Dict[str, Any]
    ) -> RenderedTemplate:
        """Render template with data."""
        pass

    def _select_provider(
        self,
        channel: NotificationChannel,
        priority: Priority
    ) -> NotificationProvider:
        """Select provider for channel."""
        pass

    def _send_with_retry(
        self,
        provider: NotificationProvider,
        content: RenderedTemplate,
        notification_id: str
    ) -> NotificationResult:
        """Send via provider with retry logic."""
        pass
```

### Error Handling

**Error Hierarchy:**

```python
class NotificationError(Exception):
    """Base exception for notification errors."""
    pass

class InvalidRequestError(NotificationError):
    """Request validation failed."""
    pass

class InvalidTemplateError(InvalidRequestError):
    """Template doesn't exist or is invalid."""
    pass

class InvalidUserError(InvalidRequestError):
    """User doesn't exist."""
    pass

class RateLimitError(NotificationError):
    """Rate limit exceeded."""
    pass

class ProviderError(NotificationError):
    """Provider failed to deliver."""
    pass

class DatabaseError(NotificationError):
    """Database operation failed."""
    pass
```

**Error Handling Strategy:**

| Error Type | Handling | Recovery |
|------------|----------|----------|
| `InvalidRequestError` | Return 400 to client | Client must fix request |
| `RateLimitError` | Return 429 to client | Wait and retry |
| `ProviderError` | Retry with backoff | Try alternate provider |
| `DatabaseError` | Log and return 500 | Operations team investigates |

**Retry Logic:**

```python
def _send_with_retry(
    self,
    provider: NotificationProvider,
    content: RenderedTemplate,
    notification_id: str
) -> NotificationResult:
    """Send with exponential backoff retry."""
    max_attempts = self._config.max_retries
    backoff = self._config.retry_backoff_seconds

    for attempt in range(1, max_attempts + 1):
        try:
            result = provider.send(content.recipient, content.body)

            # Success
            self._repository.update_status(
                notification_id,
                NotificationStatus.SENT
            )
            return NotificationResult(
                id=notification_id,
                status=NotificationStatus.SENT,
                attempts=attempt
            )
        except ProviderError as e:
            if attempt == max_attempts:
                # Final attempt failed
                self._repository.update_status(
                    notification_id,
                    NotificationStatus.FAILED
                )
                raise

            # Retry with backoff
            sleep_time = backoff * (2 ** (attempt - 1))
            time.sleep(sleep_time)
```

### Performance Considerations

**Optimization 1: Template Caching**
- Cache rendered templates for 5 minutes
- Reduces template registry calls by 80%
- Cache key: `{template_id}:{hash(data)}`

**Optimization 2: Connection Pooling**
- Reuse database connections (pool size: 10)
- Reuse HTTP connections to providers
- Reduces connection overhead by 60%

**Optimization 3: Async Processing**
- Send operation is synchronous but queues async work
- Background workers process retry attempts
- Reduces API response time from 2s to 50ms

**Metrics:**
- Target: 50ms p95 latency for `send()`
- Target: 10ms p95 latency for `get_status()`
- Target: 10k notifications/minute throughput

## Testing Strategy

### Unit Tests

**Test 1: Successful Notification Send**

```python
def test_send_notification_success():
    # Arrange
    mock_provider = Mock(spec=NotificationProvider)
    mock_provider.send.return_value = ProviderResult(success=True)

    service = NotificationService(
        template_registry=mock_template_registry,
        providers={"email": mock_provider},
        repository=mock_repository,
        event_publisher=mock_event_publisher,
        config=default_config
    )

    request = NotificationRequest(
        user_id="usr_123",
        channel=NotificationChannel.EMAIL,
        template_id="welcome",
        data={"name": "John"}
    )

    # Act
    result = service.send(request)

    # Assert
    assert result.status == NotificationStatus.QUEUED
    assert mock_provider.send.called
    assert mock_repository.create.called
```

**Test 2: Rate Limiting**

```python
def test_send_notification_rate_limited():
    service = NotificationService(...)

    # Exceed rate limit
    for _ in range(101):
        service.send(NotificationRequest(...))

    # Next request should fail
    with pytest.raises(RateLimitError):
        service.send(NotificationRequest(...))
```

**Test 3: Provider Failure with Retry**

```python
def test_send_retries_on_provider_failure():
    mock_provider = Mock(spec=NotificationProvider)
    mock_provider.send.side_effect = [
        ProviderError("Timeout"),  # Attempt 1
        ProviderError("Timeout"),  # Attempt 2
        ProviderResult(success=True)  # Attempt 3
    ]

    service = NotificationService(...)
    result = service.send(NotificationRequest(...))

    assert result.attempts == 3
    assert mock_provider.send.call_count == 3
```

**Test Coverage Target:** 85%

### Integration Tests

**Test 1: End-to-End Notification Flow**

```python
@pytest.mark.integration
def test_e2e_notification_delivery(test_db, test_providers):
    service = NotificationService(
        template_registry=real_template_registry,
        providers=test_providers,
        repository=real_repository(test_db),
        event_publisher=test_event_publisher,
        config=default_config
    )

    request = NotificationRequest(...)
    result = service.send(request)

    # Verify database record
    notification = test_db.query(Notification).get(result.id)
    assert notification.status == NotificationStatus.QUEUED

    # Verify event published
    assert "notification.queued" in test_event_publisher.events
```

**Test 2: Database Failure Handling**

```python
@pytest.mark.integration
def test_handles_database_failure(test_db):
    # Simulate database outage
    test_db.force_disconnect()

    service = NotificationService(...)

    with pytest.raises(DatabaseError):
        service.send(NotificationRequest(...))
```

## Deployment Considerations

### Configuration

**Environment Variables:**
```bash
NOTIFICATION_MAX_RETRIES=3
NOTIFICATION_RETRY_BACKOFF_SECONDS=2
NOTIFICATION_RATE_LIMIT_PER_USER=100
NOTIFICATION_PROVIDER_TIMEOUT=30
```

**Feature Flags:**
- `enable_sms_channel`: Enable/disable SMS notifications
- `use_backup_provider`: Use backup provider if primary fails

### Monitoring

**Key Metrics:**
- `notification.send.duration` (histogram): Time to send notification
- `notification.send.success` (counter): Successful sends
- `notification.send.failure` (counter): Failed sends
- `notification.retry.count` (counter): Retry attempts
- `provider.circuit_breaker.open` (gauge): Circuit breaker state

**Alerts:**
- Error rate >5% for 5 minutes
- P95 latency >500ms for 5 minutes
- Provider circuit breaker open

**Logs:**
```python
logger.info(
    "Notification sent",
    extra={
        "notification_id": notification_id,
        "user_id": request.user_id,
        "channel": request.channel,
        "attempts": attempts
    }
)
```

### Scaling

**Horizontal Scaling:**
- Component is stateless, scale to N instances
- Use load balancer for request distribution
- No shared state between instances

**Vertical Scaling:**
- Increase worker threads for concurrent sends
- Increase database connection pool size

**Bottlenecks:**
- Provider API rate limits (mitigate with multiple providers)
- Database write throughput (mitigate with write replicas)

## Open Questions

- [ ] How to handle provider-specific features (e.g., email tracking pixels)?
- [ ] Should we support A/B testing of templates?
- [ ] What's the retention policy for notification records?

## References

- [ADR: Notification Architecture](/docs/adr/003-notification-architecture.md)
- [API Specification](/docs/api/notifications.md)
- [Provider Integration Guide](/docs/guides/provider-integration.md)

---

**Document Version:** 1.0
**Last Updated:** 2024-10-24
**Next Review:** 2024-11-24
