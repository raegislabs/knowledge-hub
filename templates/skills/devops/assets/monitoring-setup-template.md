# Monitoring Setup Template

## Overview

Complete monitoring and observability stack using Prometheus, Grafana, and logging solutions. Includes service monitoring, alerting, and visualization.

## Docker Compose Monitoring Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  # ---------------------------------------------------------------------------
  # Prometheus - Metrics Collection
  # ---------------------------------------------------------------------------
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped

    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
      - '--web.enable-lifecycle'

    ports:
      - "9090:9090"

    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alerts:/etc/prometheus/alerts:ro
      - prometheus-data:/prometheus

    networks:
      - monitoring

    depends_on:
      - cadvisor
      - node-exporter

  # ---------------------------------------------------------------------------
  # Grafana - Metrics Visualization
  # ---------------------------------------------------------------------------
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped

    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_ROOT_URL=http://localhost:3000
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource

    ports:
      - "3000:3000"

    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro

    networks:
      - monitoring

    depends_on:
      - prometheus

  # ---------------------------------------------------------------------------
  # Node Exporter - Host Metrics
  # ---------------------------------------------------------------------------
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped

    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'

    ports:
      - "9100:9100"

    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

    networks:
      - monitoring

  # ---------------------------------------------------------------------------
  # cAdvisor - Container Metrics
  # ---------------------------------------------------------------------------
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped

    privileged: true

    ports:
      - "8080:8080"

    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro

    networks:
      - monitoring

  # ---------------------------------------------------------------------------
  # Alertmanager - Alert Routing
  # ---------------------------------------------------------------------------
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    restart: unless-stopped

    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'

    ports:
      - "9093:9093"

    volumes:
      - ./alertmanager/config.yml:/etc/alertmanager/config.yml:ro
      - alertmanager-data:/alertmanager

    networks:
      - monitoring

  # ---------------------------------------------------------------------------
  # Loki - Log Aggregation
  # ---------------------------------------------------------------------------
  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: unless-stopped

    ports:
      - "3100:3100"

    command: -config.file=/etc/loki/local-config.yaml

    volumes:
      - ./loki/config.yml:/etc/loki/local-config.yaml:ro
      - loki-data:/loki

    networks:
      - monitoring

  # ---------------------------------------------------------------------------
  # Promtail - Log Shipper
  # ---------------------------------------------------------------------------
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    restart: unless-stopped

    volumes:
      - ./promtail/config.yml:/etc/promtail/config.yml:ro
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro

    command: -config.file=/etc/promtail/config.yml

    networks:
      - monitoring

    depends_on:
      - loki

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus-data:
  grafana-data:
  alertmanager-data:
  loki-data:
```

## Prometheus Configuration

```yaml
# prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'production'
    environment: 'prod'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

# Load rules
rule_files:
  - '/etc/prometheus/alerts/*.yml'

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter - Host metrics
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # cAdvisor - Container metrics
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Application metrics
  - job_name: 'myapp'
    static_configs:
      - targets: ['app:8000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  # PostgreSQL Exporter (if using)
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  # Redis Exporter (if using)
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  # Kubernetes (if applicable)
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https
```

## Alert Rules

```yaml
# prometheus/alerts/application.yml
groups:
  - name: application_alerts
    interval: 30s
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: |
          100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
          component: infrastructure
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% (current value: {{ $value }}%)"

      # High memory usage
      - alert: HighMemoryUsage
        expr: |
          (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
          component: infrastructure
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% (current value: {{ $value }}%)"

      # Disk space low
      - alert: DiskSpaceLow
        expr: |
          (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: warning
          component: infrastructure
        annotations:
          summary: "Disk space low on {{ $labels.instance }}"
          description: "Disk space is below 10% (current value: {{ $value }}%)"

      # Application down
      - alert: ApplicationDown
        expr: up{job="myapp"} == 0
        for: 1m
        labels:
          severity: critical
          component: application
        annotations:
          summary: "Application is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"

      # High error rate
      - alert: HighErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: warning
          component: application
        annotations:
          summary: "High error rate detected"
          description: "Error rate is above 5% (current value: {{ $value }})"

      # Slow response time
      - alert: SlowResponseTime
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
          component: application
        annotations:
          summary: "Slow response time detected"
          description: "95th percentile response time is above 1s (current value: {{ $value }}s)"

      # Database connection pool exhausted
      - alert: DatabaseConnectionPoolExhausted
        expr: |
          rate(database_connection_errors_total[5m]) > 0.1
        for: 2m
        labels:
          severity: critical
          component: database
        annotations:
          summary: "Database connection pool exhausted"
          description: "Connection errors are increasing (rate: {{ $value }}/s)"
```

## Alertmanager Configuration

```yaml
# alertmanager/config.yml
global:
  resolve_timeout: 5m
  slack_api_url: 'YOUR_SLACK_WEBHOOK_URL'

# Notification templates
templates:
  - '/etc/alertmanager/templates/*.tmpl'

# Routing tree
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'

  # Child routes
  routes:
    # Critical alerts to PagerDuty
    - match:
        severity: critical
      receiver: 'pagerduty'
      continue: true

    # Infrastructure alerts to infrastructure team
    - match:
        component: infrastructure
      receiver: 'infrastructure-team'

    # Application alerts to dev team
    - match:
        component: application
      receiver: 'dev-team'

# Inhibition rules
inhibit_rules:
  # Don't alert on low disk space if node is down
  - source_match:
      severity: 'critical'
      alertname: 'NodeDown'
    target_match:
      severity: 'warning'
      alertname: 'DiskSpaceLow'
    equal: ['instance']

# Receivers
receivers:
  - name: 'default'
    slack_configs:
      - channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'
        description: '{{ .GroupLabels.alertname }}'

  - name: 'infrastructure-team'
    slack_configs:
      - channel: '#infrastructure'
        title: 'Infrastructure Alert'

  - name: 'dev-team'
    slack_configs:
      - channel: '#development'
        title: 'Application Alert'
    email_configs:
      - to: 'dev-team@example.com'
        from: 'alerts@example.com'
        smarthost: 'smtp.example.com:587'
        auth_username: 'alerts@example.com'
        auth_password: 'password'
```

## Grafana Provisioning

```yaml
# grafana/provisioning/datasources/prometheus.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

```yaml
# grafana/provisioning/dashboards/default.yml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

## Application Instrumentation (Python Example)

```python
# app/metrics.py
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from prometheus_client import CONTENT_TYPE_LATEST
import time

# Define metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

ACTIVE_REQUESTS = Gauge(
    'http_requests_active',
    'Active HTTP requests',
    ['method', 'endpoint']
)

DATABASE_CONNECTIONS = Gauge(
    'database_connections_active',
    'Active database connections'
)

# Middleware example (FastAPI)
from fastapi import FastAPI, Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

class PrometheusMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        method = request.method
        path = request.url.path

        # Track active requests
        ACTIVE_REQUESTS.labels(method=method, endpoint=path).inc()

        # Measure request duration
        start_time = time.time()
        try:
            response = await call_next(request)
            status = response.status_code
        except Exception as e:
            status = 500
            raise
        finally:
            duration = time.time() - start_time

            # Record metrics
            REQUEST_COUNT.labels(
                method=method,
                endpoint=path,
                status=status
            ).inc()

            REQUEST_DURATION.labels(
                method=method,
                endpoint=path
            ).observe(duration)

            ACTIVE_REQUESTS.labels(method=method, endpoint=path).dec()

        return response

# Metrics endpoint
@app.get("/metrics")
async def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )
```

## Health Check Endpoints

```python
# app/health.py
from fastapi import APIRouter, status

router = APIRouter()

@router.get("/health/live")
async def liveness():
    """Liveness probe - is the app running?"""
    return {"status": "alive"}

@router.get("/health/ready")
async def readiness():
    """Readiness probe - can the app serve traffic?"""
    # Check database connection
    db_healthy = await check_database()

    # Check Redis connection
    redis_healthy = await check_redis()

    if db_healthy and redis_healthy:
        return {"status": "ready", "database": "ok", "redis": "ok"}
    else:
        return {
            "status": "not ready",
            "database": "ok" if db_healthy else "error",
            "redis": "ok" if redis_healthy else "error"
        }, status.HTTP_503_SERVICE_UNAVAILABLE

@router.get("/health/startup")
async def startup():
    """Startup probe - has the app finished starting?"""
    # Check if migrations complete
    migrations_done = await check_migrations()

    if migrations_done:
        return {"status": "started"}
    else:
        return {"status": "starting"}, status.HTTP_503_SERVICE_UNAVAILABLE
```

## Usage

```bash
# Start monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Access UIs
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
# Alertmanager: http://localhost:9093

# View logs
docker-compose -f docker-compose.monitoring.yml logs -f grafana

# Stop monitoring stack
docker-compose -f docker-compose.monitoring.yml down
```

## Best Practices

1. **Use Labels Wisely**: Keep cardinality low, avoid high-cardinality labels
2. **Set Appropriate Retention**: Balance storage cost vs historical data needs
3. **Create Meaningful Alerts**: Alert on symptoms, not causes
4. **Test Alerts**: Verify alert routing and notification
5. **Document Runbooks**: Include remediation steps in alert annotations
6. **Monitor the Monitors**: Ensure Prometheus itself is monitored

## Related Templates

- `deployment-script-template.md` - Deployment automation
- `docker-compose-template.md` - Application stack
- `kubernetes-deployment-template.md` - Kubernetes monitoring
