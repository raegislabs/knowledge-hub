# Observability Guide

## Overview

Comprehensive guide to implementing observability through logging, metrics, tracing, and alerting.

## The Three Pillars

### 1. Logging (What happened)
- Application events
- Error messages
- Audit trails

### 2. Metrics (How much/how many)
- Performance indicators
- Resource usage
- Business metrics

### 3. Tracing (Where did time go)
- Request paths
- Service dependencies
- Performance bottlenecks

## Logging Best Practices

### Structured Logging
```python
# ❌ Unstructured
logger.info(f"User {user_id} logged in from {ip}")

# ✅ Structured
logger.info("user_login", extra={
    "user_id": user_id,
    "ip_address": ip,
    "timestamp": datetime.utcnow()
})
```

### Log Levels
- **DEBUG**: Detailed diagnostic information
- **INFO**: General informational messages
- **WARNING**: Potential issues
- **ERROR**: Error conditions
- **CRITICAL**: Severe failures

### What to Log
```python
# Request/Response
logger.info("http_request", extra={
    "method": request.method,
    "path": request.path,
    "status_code": response.status_code,
    "duration_ms": duration
})

# Business Events
logger.info("order_placed", extra={
    "order_id": order.id,
    "user_id": user.id,
    "amount": order.total
})

# Errors
logger.error("payment_failed", extra={
    "error": str(e),
    "order_id": order.id,
    "payment_method": method
}, exc_info=True)
```

## Metrics

### Key Metrics (RED Method)

**Rate**: Requests per second
```python
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)
```

**Errors**: Error rate
```python
ERROR_COUNT = Counter(
    'http_errors_total',
    'Total HTTP errors',
    ['method', 'endpoint', 'error_type']
)
```

**Duration**: Response time
```python
REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)
```

### USE Method (Resources)

**Utilization**: How busy
```python
CPU_USAGE = Gauge(
    'cpu_usage_percent',
    'CPU utilization percentage'
)
```

**Saturation**: Queue depth
```python
QUEUE_LENGTH = Gauge(
    'queue_length',
    'Current queue length'
)
```

**Errors**: Error count
```python
DATABASE_ERRORS = Counter(
    'database_errors_total',
    'Total database errors'
)
```

## Distributed Tracing

### OpenTelemetry Example
```python
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Initialize tracer
tracer = trace.get_tracer(__name__)

# Instrument FastAPI
FastAPIInstrumentor.instrument_app(app)

# Custom spans
@app.get("/orders/{order_id}")
async def get_order(order_id: str):
    with tracer.start_as_current_span("get_order") as span:
        span.set_attribute("order.id", order_id)

        # Database query span
        with tracer.start_as_current_span("db_query"):
            order = await db.get_order(order_id)

        # External API call span
        with tracer.start_as_current_span("payment_check"):
            payment = await payment_service.check(order_id)

        return order
```

## Alerting

### Alert Design Principles

1. **Alert on Symptoms, Not Causes**
```yaml
# ❌ Bad: Alert on cause
- alert: HighCPU
  expr: cpu_usage > 80

# ✅ Good: Alert on symptom
- alert: SlowResponseTime
  expr: http_request_duration_p95 > 1
```

2. **Actionable Alerts**
```yaml
- alert: HighErrorRate
  annotations:
    summary: "High error rate on {{ $labels.service }}"
    description: "Error rate is {{ $value }}% (threshold: 5%)"
    runbook: "https://wiki.company.com/runbooks/high-error-rate"
    action: "Check logs, rollback if needed"
```

3. **Avoid Alert Fatigue**
- Only alert on actionable issues
- Use appropriate thresholds
- Aggregate similar alerts
- Implement alert suppression

### Severity Levels

**Critical**: Immediate action required
- Production outage
- Data loss
- Security breach

**Warning**: Action needed soon
- Degraded performance
- Resource approaching limits
- Failed non-critical component

**Info**: For awareness
- Deployment completed
- Scaling event
- Configuration change

## Dashboards

### Key Metrics Dashboard

**Application Health:**
- Request rate (requests/sec)
- Error rate (%)
- Response time (p50, p95, p99)
- Active connections

**Infrastructure:**
- CPU usage
- Memory usage
- Disk I/O
- Network traffic

**Business:**
- Active users
- Transactions/hour
- Revenue
- Conversion rate

### Dashboard Best Practices

1. **Top-to-Bottom** - Most important first
2. **Time Alignment** - Same time range
3. **Color Coding** - Green=good, Yellow=warning, Red=critical
4. **Context** - Include thresholds and baselines
5. **Drill-Down** - Link to detailed views

## SLIs, SLOs, SLAs

### Service Level Indicators (SLIs)
Metrics that matter to users:
- Availability (uptime %)
- Latency (response time)
- Error rate
- Throughput

### Service Level Objectives (SLOs)
Internal targets:
- 99.9% availability (43 minutes downtime/month)
- p95 latency < 200ms
- Error rate < 0.1%

### Service Level Agreements (SLAs)
Customer commitments:
- 99.5% uptime guarantee
- Response time < 500ms
- Support response time < 1 hour

### Error Budget
```
Error Budget = 100% - SLO

If SLO = 99.9%:
Error Budget = 0.1% = 43 minutes/month

Uses:
- Release velocity decisions
- Risk assessment
- Feature vs reliability trade-offs
```

## Practical Implementation

### Application Instrumentation
```python
from prometheus_client import Counter, Histogram, Gauge

# Define metrics
http_requests = Counter('http_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
http_duration = Histogram('http_request_duration_seconds', 'Request duration', ['method', 'endpoint'])
active_users = Gauge('active_users', 'Active users')

# Middleware
@app.middleware("http")
async def metrics_middleware(request, call_next):
    start_time = time.time()

    response = await call_next(request)

    duration = time.time() - start_time
    http_requests.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()

    http_duration.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)

    return response
```

### Correlation IDs
```python
import uuid

@app.middleware("http")
async def correlation_id_middleware(request, call_next):
    correlation_id = request.headers.get('X-Correlation-ID', str(uuid.uuid4()))

    # Add to context
    with logger.contextualize(correlation_id=correlation_id):
        response = await call_next(request)
        response.headers['X-Correlation-ID'] = correlation_id
        return response
```

## Tools Comparison

### Logging
- **ELK Stack**: Powerful, complex
- **Loki**: Lightweight, Prometheus-like
- **CloudWatch Logs**: AWS native
- **Splunk**: Enterprise features

### Metrics
- **Prometheus**: Industry standard
- **Datadog**: SaaS, easy setup
- **New Relic**: Full-stack monitoring
- **CloudWatch**: AWS native

### Tracing
- **Jaeger**: Open source, CNCF
- **Zipkin**: Open source, Twitter
- **Datadog APM**: SaaS
- **AWS X-Ray**: AWS native

## Checklist

**Logging:**
- [ ] Structured logging implemented
- [ ] Log levels properly used
- [ ] Correlation IDs added
- [ ] Sensitive data redacted
- [ ] Log aggregation configured

**Metrics:**
- [ ] RED metrics instrumented
- [ ] Business metrics tracked
- [ ] Resource metrics collected
- [ ] Metrics retention configured

**Tracing:**
- [ ] Distributed tracing enabled
- [ ] Key operations instrumented
- [ ] Trace sampling configured
- [ ] Trace storage configured

**Alerting:**
- [ ] SLOs defined
- [ ] Alert rules created
- [ ] Runbooks documented
- [ ] On-call rotation configured
- [ ] Alert routing tested

## Resources

- [Google SRE Book](https://sre.google/books/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
