# Logging Strategies Reference

## Overview
Best practices for effective logging that aids debugging without overwhelming systems or developers. This guide covers what to log, how to log, and how to make logs actionable.

---

## Logging Principles

### 1. Log for Future Debuggers
Your future self (or teammates) will debug this code. Log information that answers:
- **What happened?** (Event)
- **When?** (Timestamp - automatic)
- **Where?** (Component, function, line)
- **Why?** (Context, inputs)
- **Who?** (User, request ID, session)

### 2. Signal vs Noise Ratio
**Good logging** provides useful information when needed.
**Bad logging** buries important information in noise.

**Balance**:
- Too little logging → Can't debug production issues
- Too much logging → Can't find relevant information

### 3. Structured Over Unstructured
```python
# Bad: Unstructured string
logger.info("User John (ID: 123) purchased 3 items for $45.99 at 2024-01-15 10:30:00")

# Good: Structured data
logger.info(
    "Purchase completed",
    extra={
        "user_id": 123,
        "user_name": "John",
        "item_count": 3,
        "total_amount": 45.99,
        "currency": "USD",
        "timestamp": "2024-01-15T10:30:00Z"
    }
)
```

**Benefits of structured logging**:
- Easy to query: "All purchases > $100"
- Easy to aggregate: "Average order value"
- Easy to alert: "Alert when error_rate > 5%"

### 4. Context is King
Include enough context to understand what's happening:

```python
# Bad: Missing context
logger.error("User not found")

# Good: Includes context
logger.error(
    "User not found during checkout",
    extra={
        "user_id": user_id,
        "cart_id": cart_id,
        "checkout_step": "payment_processing",
        "request_id": request_id
    }
)
```

---

## Log Levels

### ERROR - Something Failed
**Use when**: Operation failed and requires attention.

**Examples**:
```python
# System errors
logger.error("Database connection failed", exc_info=True)

# Business logic errors that need investigation
logger.error(
    "Payment processing failed",
    extra={
        "user_id": user_id,
        "amount": amount,
        "error": str(e)
    }
)

# External service failures
logger.error(
    "Third-party API call failed",
    extra={
        "api": "stripe",
        "endpoint": "/charges",
        "status_code": 500
    }
)
```

**Include**:
- What failed
- Why it failed (exception message)
- Impact (what couldn't be completed)
- Context (user, request, transaction)
- Stack trace (`exc_info=True` in Python)

### WARNING - Something Unexpected
**Use when**: Something unusual happened but operation continued.

**Examples**:
```python
# Deprecated feature usage
logger.warning(
    "Using deprecated API endpoint",
    extra={"endpoint": "/api/v1/users", "user_id": user_id}
)

# Fallback behavior
logger.warning(
    "Cache miss, falling back to database",
    extra={"cache_key": cache_key}
)

# Approaching limits
logger.warning(
    "Disk space low",
    extra={"disk_usage_percent": 85, "threshold": 80}
)

# Invalid but recoverable input
logger.warning(
    "Invalid email format, using default",
    extra={"provided_email": email, "default": "noreply@example.com"}
)
```

**Include**:
- What was unexpected
- What fallback action was taken
- Potential impact if continues

### INFO - Important Events
**Use when**: Recording significant business events.

**Examples**:
```python
# User actions
logger.info(
    "User registered",
    extra={"user_id": user.id, "email": user.email}
)

# System state changes
logger.info(
    "Server started",
    extra={"port": 8000, "environment": "production"}
)

# Important operations
logger.info(
    "Batch job completed",
    extra={
        "job_name": "daily_report",
        "records_processed": 10000,
        "duration_seconds": 45.2
    }
)

# External integrations
logger.info(
    "Email sent",
    extra={"to": recipient, "subject": subject, "template": template_name}
)
```

**Include**:
- What happened (business event)
- Key identifiers (user, order, transaction)
- Outcome (success, count, duration)

### DEBUG - Detailed Diagnostic
**Use when**: Detailed information useful for debugging (disabled in production).

**Examples**:
```python
# Function entry/exit
logger.debug(
    "Function called",
    extra={"function": "process_order", "args": args, "kwargs": kwargs}
)

# Variable state
logger.debug(
    "Computed values",
    extra={"subtotal": subtotal, "tax": tax, "total": total}
)

# Control flow
logger.debug(
    "Taking discount path",
    extra={"discount_code": code, "discount_amount": discount}
)

# External calls
logger.debug(
    "API request",
    extra={"url": url, "method": "POST", "headers": headers}
)
```

**Include**:
- Detailed state information
- Control flow decisions
- Variable values
- External interactions

### TRACE - Very Detailed (if available)
**Use when**: Extremely detailed debugging (rarely enabled).

**Examples**:
```python
# Every loop iteration
logger.trace(f"Processing item {i}/{total}")

# Every state change
logger.trace(f"State transition: {old_state} -> {new_state}")
```

---

## What to Log

### Always Log

#### 1. Errors and Exceptions
```python
try:
    result = risky_operation()
except Exception as e:
    logger.error(
        "Operation failed",
        exc_info=True,  # Include stack trace
        extra={
            "operation": "risky_operation",
            "inputs": inputs,
            "error_type": type(e).__name__
        }
    )
```

#### 2. Security Events
```python
# Authentication
logger.info(
    "Login successful",
    extra={"user_id": user.id, "ip": request.ip}
)

logger.warning(
    "Failed login attempt",
    extra={"username": username, "ip": request.ip, "attempt_count": count}
)

# Authorization
logger.warning(
    "Unauthorized access attempt",
    extra={"user_id": user.id, "resource": resource, "action": action}
)

# Data access
logger.info(
    "Sensitive data accessed",
    extra={"user_id": user.id, "record_type": "user_profile", "record_id": profile.id}
)
```

#### 3. External System Interactions
```python
# Before external call
logger.info(
    "Calling external API",
    extra={"service": "payment_gateway", "operation": "charge", "amount": amount}
)

# After external call
logger.info(
    "External API response",
    extra={
        "service": "payment_gateway",
        "status_code": response.status_code,
        "duration_ms": duration
    }
)
```

#### 4. State Changes
```python
# Order status changes
logger.info(
    "Order status updated",
    extra={
        "order_id": order.id,
        "old_status": old_status,
        "new_status": new_status,
        "changed_by": user.id
    }
)

# Configuration changes
logger.info(
    "Configuration updated",
    extra={"key": config_key, "old_value": old_value, "new_value": new_value}
)
```

### Often Log

#### 5. Business Events
```python
# User lifecycle
logger.info("User created", extra={"user_id": user.id})
logger.info("User deactivated", extra={"user_id": user.id})

# Transactions
logger.info(
    "Order placed",
    extra={"order_id": order.id, "user_id": user.id, "total": total}
)

# Conversions
logger.info(
    "Subscription started",
    extra={"user_id": user.id, "plan": plan, "price": price}
)
```

#### 6. Performance Metrics
```python
# Slow operations
@log_timing
def slow_operation():
    start = time.time()
    try:
        result = do_work()
        return result
    finally:
        duration = (time.time() - start) * 1000
        logger.info(
            "Operation completed",
            extra={"operation": "slow_operation", "duration_ms": duration}
        )
```

#### 7. Resource Usage
```python
# Memory usage
logger.info(
    "Memory usage",
    extra={
        "process_memory_mb": process.memory_info().rss / 1024 / 1024,
        "threshold_mb": threshold
    }
)

# Connection pools
logger.debug(
    "Connection pool status",
    extra={"active": pool.active_count, "idle": pool.idle_count, "max": pool.max}
)
```

### Sometimes Log

#### 8. Debug Information
```python
# Only in development or when debugging
if logger.isEnabledFor(logging.DEBUG):
    logger.debug(
        "Variable state",
        extra={"var1": var1, "var2": var2, "var3": var3}
    )
```

### Never Log

#### Sensitive Data
```python
# Never log passwords
logger.info("User login", extra={"username": username})  # OK
logger.info("User login", extra={"password": password})  # NEVER!

# Never log full credit card numbers
logger.info("Payment", extra={"card_last_four": "4242"})  # OK
logger.info("Payment", extra={"card_number": "4242..."})  # NEVER!

# Never log API keys/tokens
logger.info("API call", extra={"service": "stripe"})  # OK
logger.info("API call", extra={"api_key": api_key})  # NEVER!

# Never log PII without consent/need
logger.info("User", extra={"user_id": user.id})  # OK
logger.info("User", extra={"ssn": ssn, "dob": dob})  # NEVER (unless required)!
```

---

## Logging Patterns

### Pattern 1: Request Logging
```python
import uuid

def process_request(request):
    # Generate request ID for correlation
    request_id = str(uuid.uuid4())

    # Log request start
    logger.info(
        "Request started",
        extra={
            "request_id": request_id,
            "method": request.method,
            "path": request.path,
            "user_id": request.user.id if request.user else None
        }
    )

    try:
        # Process request
        result = handle_request(request)

        # Log success
        logger.info(
            "Request completed",
            extra={
                "request_id": request_id,
                "status": "success",
                "duration_ms": duration
            }
        )
        return result

    except Exception as e:
        # Log failure
        logger.error(
            "Request failed",
            exc_info=True,
            extra={
                "request_id": request_id,
                "error": str(e)
            }
        )
        raise
```

### Pattern 2: Transaction Logging
```python
def process_payment(order_id, amount):
    logger.info(
        "Payment processing started",
        extra={"order_id": order_id, "amount": amount}
    )

    try:
        # Step 1
        logger.debug("Validating payment details", extra={"order_id": order_id})
        validate_payment(order_id)

        # Step 2
        logger.debug("Calling payment gateway", extra={"order_id": order_id})
        transaction_id = gateway.charge(amount)

        # Step 3
        logger.debug("Updating order status", extra={"order_id": order_id})
        update_order_status(order_id, "paid")

        # Success
        logger.info(
            "Payment successful",
            extra={
                "order_id": order_id,
                "transaction_id": transaction_id,
                "amount": amount
            }
        )
        return transaction_id

    except PaymentError as e:
        logger.error(
            "Payment failed",
            extra={"order_id": order_id, "reason": str(e)},
            exc_info=True
        )
        raise
```

### Pattern 3: Background Job Logging
```python
def run_batch_job(job_name, items):
    logger.info(
        "Batch job started",
        extra={"job_name": job_name, "item_count": len(items)}
    )

    success_count = 0
    error_count = 0
    errors = []

    for i, item in enumerate(items):
        try:
            process_item(item)
            success_count += 1

            # Log progress periodically
            if (i + 1) % 100 == 0:
                logger.info(
                    "Batch job progress",
                    extra={
                        "job_name": job_name,
                        "processed": i + 1,
                        "total": len(items),
                        "success": success_count,
                        "errors": error_count
                    }
                )

        except Exception as e:
            error_count += 1
            errors.append({"item": item.id, "error": str(e)})
            logger.error(
                "Item processing failed",
                extra={"job_name": job_name, "item_id": item.id, "error": str(e)}
            )

    # Final summary
    logger.info(
        "Batch job completed",
        extra={
            "job_name": job_name,
            "total": len(items),
            "success": success_count,
            "errors": error_count,
            "error_details": errors[:10]  # First 10 errors
        }
    )
```

### Pattern 4: Audit Logging
```python
def audit_log(action, user_id, resource_type, resource_id, **extra):
    """Audit log for compliance/security."""
    logger.info(
        "Audit event",
        extra={
            "audit_action": action,
            "user_id": user_id,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "timestamp": datetime.utcnow().isoformat(),
            "ip_address": get_client_ip(),
            **extra
        }
    )

# Usage
audit_log("DELETE", user.id, "user_profile", profile.id, reason="user_request")
audit_log("VIEW", user.id, "sensitive_data", record.id, justification="customer_support")
```

---

## Logging Configuration

### Python Logging Setup
```python
import logging
import sys
from pythonjsonlogger import jsonlogger

def setup_logging(log_level=logging.INFO):
    # Create logger
    logger = logging.getLogger()
    logger.setLevel(log_level)

    # Console handler with JSON format
    handler = logging.StreamHandler(sys.stdout)
    formatter = jsonlogger.JsonFormatter(
        '%(timestamp)s %(level)s %(name)s %(message)s',
        timestamp=True
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger

# Usage
logger = setup_logging(
    log_level=logging.DEBUG if DEBUG else logging.INFO
)
```

### Log Rotation
```python
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler(
    'app.log',
    maxBytes=10*1024*1024,  # 10MB
    backupCount=5  # Keep 5 old files
)
logger.addHandler(handler)
```

---

## Best Practices

### 1. Use Correlation IDs
```python
import threading

# Thread-local storage for request context
_request_context = threading.local()

def set_request_id(request_id):
    _request_context.request_id = request_id

def get_request_id():
    return getattr(_request_context, 'request_id', None)

# Include in all logs
logger.info(
    "Event occurred",
    extra={"request_id": get_request_id(), ...}
)
```

### 2. Log Timing Information
```python
import time
from functools import wraps

def log_timing(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        try:
            result = func(*args, **kwargs)
            return result
        finally:
            duration = (time.time() - start) * 1000
            logger.info(
                f"{func.__name__} completed",
                extra={"duration_ms": duration}
            )
    return wrapper

@log_timing
def slow_operation():
    # ...
    pass
```

### 3. Aggregate Logs Centrally
Use log aggregation tools:
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Splunk
- Datadog
- CloudWatch Logs

### 4. Alert on Patterns
```python
# Error rate threshold
if error_count > threshold:
    logger.critical(
        "High error rate detected",
        extra={"error_count": error_count, "threshold": threshold}
    )
    send_alert(...)
```

### 5. Sample High-Volume Logs
```python
import random

# Only log 1% of debug messages in production
if logger.isEnabledFor(logging.DEBUG) or random.random() < 0.01:
    logger.debug("High-frequency event")
```

---

## Common Pitfalls

### Pitfall 1: Logging in Loops
```python
# Bad: Log every iteration
for item in items:  # Could be 1 million items!
    logger.debug(f"Processing {item}")
    process(item)

# Good: Log periodically
for i, item in enumerate(items):
    process(item)
    if (i + 1) % 1000 == 0:
        logger.info(f"Processed {i + 1}/{len(items)} items")
```

### Pitfall 2: Expensive Log Calls
```python
# Bad: Expensive operation even if logging disabled
logger.debug(f"Data: {expensive_serialization(data)}")

# Good: Only serialize if logging enabled
if logger.isEnabledFor(logging.DEBUG):
    logger.debug(f"Data: {expensive_serialization(data)}")
```

### Pitfall 3: No Context
```python
# Bad: No context
logger.error("Validation failed")

# Good: Include context
logger.error(
    "Validation failed",
    extra={
        "field": "email",
        "value": value,
        "rule": "must_be_valid_email"
    }
)
```

---

## Logging Checklist

- [ ] Use appropriate log levels
- [ ] Include sufficient context
- [ ] Use structured logging
- [ ] Don't log sensitive data
- [ ] Use correlation IDs
- [ ] Log errors with stack traces
- [ ] Configure log rotation
- [ ] Aggregate logs centrally
- [ ] Set up alerts for critical patterns
- [ ] Sample high-volume logs
