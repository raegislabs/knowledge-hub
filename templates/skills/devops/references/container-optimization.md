# Container Optimization Guide

## Overview

Best practices for optimizing Docker containers for size, security, performance, and reliability in production environments.

## Image Size Optimization

### 1. Choose the Right Base Image

**Size Comparison:**
```
Full Python:       1.0 GB
Python slim:       150 MB  ✅ Recommended
Python alpine:     50 MB   ⚠️ Compatibility issues
Distroless:        80 MB   ✅ Security-focused
```

**Recommendations:**
- **Development**: Use full images for debugging tools
- **Production**: Use slim or distroless
- **Avoid**: `latest` tag (use specific versions)

### 2. Multi-Stage Builds

**Before (950 MB):**
```dockerfile
FROM python:3.11
RUN apt-get update && apt-get install -y build-essential gcc
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

**After (150 MB):**
```dockerfile
# Builder stage
FROM python:3.11 AS builder
RUN apt-get update && apt-get install -y build-essential
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
CMD ["python", "app.py"]
```

**Savings: 800 MB (84% reduction)**

### 3. Layer Optimization

**❌ Bad (Creates many layers):**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*
```

**✅ Good (Single layer):**
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
```

### 4. Use .dockerignore

```
# .dockerignore
.git
.gitignore
.env
.env.*
node_modules
__pycache__
*.pyc
.pytest_cache
.coverage
*.log
README.md
docs/
tests/
.DS_Store
```

**Impact**: Reduces build context from 500MB → 10MB

### 5. Order Layers by Change Frequency

```dockerfile
# ✅ Static layers first
FROM python:3.11-slim
RUN apt-get update && apt-get install -y libpq5

# Dependencies (change occasionally)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Source code (changes frequently) - last
COPY . .
```

## Security Hardening

### 1. Run as Non-Root User

```dockerfile
# Create user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set ownership
WORKDIR /app
RUN chown -R appuser:appuser /app

# Switch user
USER appuser
```

### 2. Use Read-Only Root Filesystem

```dockerfile
# Dockerfile
USER appuser

# docker-compose.yml
services:
  app:
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
```

### 3. Drop Capabilities

```yaml
# docker-compose.yml
services:
  app:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed
```

### 4. Scan for Vulnerabilities

```bash
# Trivy
trivy image myapp:latest

# Docker scan
docker scan myapp:latest

# Anchore Grype
grype myapp:latest
```

### 5. Use Specific Tags

```dockerfile
# ❌ Never use latest
FROM python:latest

# ✅ Use specific version
FROM python:3.11.5-slim

# ✅ Best: Use digest for immutability
FROM python:3.11-slim@sha256:abc123...
```

## Performance Optimization

### 1. Minimize Layers

**Before (15 layers):**
```dockerfile
FROM ubuntu
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y pip
COPY file1.py .
COPY file2.py .
COPY file3.py .
```

**After (5 layers):**
```dockerfile
FROM python:3.11-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg && \
    rm -rf /var/lib/apt/lists/*
COPY *.py .
```

### 2. Use BuildKit

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1
docker build -t myapp .

# Or in docker-compose.yml
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build
```

**Benefits:**
- Parallel layer building
- Better caching
- Faster builds (up to 2x)

### 3. Cache Dependencies

```dockerfile
# ✅ Copy only dependency files first
COPY package.json package-lock.json ./
RUN npm ci --only=production

# ✅ Copy source after (better caching)
COPY . .
```

### 4. Use Build Caching

```yaml
# GitHub Actions
- name: Build image
  uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Resource Management

### 1. Set Resource Limits

```yaml
# docker-compose.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
```

```yaml
# Kubernetes
resources:
  requests:
    cpu: 250m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 2Gi
```

### 2. Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

```yaml
# docker-compose.yml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### 3. Graceful Shutdown

```python
# Python example
import signal
import sys

def signal_handler(sig, frame):
    print('Shutting down gracefully...')
    # Close connections, flush buffers, etc.
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)
```

```dockerfile
# Set STOPSIGNAL
STOPSIGNAL SIGTERM

# Ensure PID 1 handles signals correctly
ENTRYPOINT ["dumb-init", "--"]
CMD ["python", "app.py"]
```

## Logging Best Practices

### 1. Log to STDOUT/STDERR

```python
# ✅ Good - logs to stdout
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
```

### 2. Structured Logging

```python
import structlog

log = structlog.get_logger()

log.info("user_login", user_id=123, ip="192.168.1.1")
# Output: {"event": "user_login", "user_id": 123, "ip": "192.168.1.1"}
```

### 3. Configure Log Drivers

```yaml
# docker-compose.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Common Patterns

### Python Application

```dockerfile
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-warn-script-location -r requirements.txt

FROM python:3.11-slim

# Security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Application
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

USER appuser
ENV PATH="/home/appuser/.local/bin:$PATH"

EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1

CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
```

### Node.js Application

```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine

RUN apk add --no-cache dumb-init
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist

USER nodejs
EXPOSE 3000

HEALTHCHECK CMD node healthcheck.js

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

## Troubleshooting

### Large Image Size

**Diagnose:**
```bash
# Analyze layers
docker history myapp:latest

# Interactive exploration
docker run --rm -it myapp:latest sh
du -sh /*
```

**Common causes:**
- Build dependencies in final image
- Cached package managers
- Log files
- Test files

**Fix:**
- Use multi-stage builds
- Clean up in same layer
- Use .dockerignore

### Slow Build Times

**Diagnose:**
```bash
# Build with timing
DOCKER_BUILDKIT=1 docker build --progress=plain -t myapp .
```

**Common causes:**
- No caching
- Large build context
- Downloading dependencies every time

**Fix:**
- Order layers correctly
- Use BuildKit
- Cache dependencies layer

### Container Crashes

**Diagnose:**
```bash
# View logs
docker logs container-name

# Check exit code
docker inspect container-name --format='{{.State.ExitCode}}'

# Check resource usage
docker stats
```

**Common causes:**
- OOM (exit code 137)
- Application error (exit code 1)
- Missing dependencies

## Best Practices Checklist

**Image Size:**
- [ ] Use slim/alpine base images
- [ ] Multi-stage builds implemented
- [ ] .dockerignore configured
- [ ] Layers optimized (combined RUN commands)

**Security:**
- [ ] Run as non-root user
- [ ] No secrets in image
- [ ] Vulnerability scanning enabled
- [ ] Specific version tags (no `latest`)
- [ ] Read-only root filesystem

**Performance:**
- [ ] BuildKit enabled
- [ ] Layer caching optimized
- [ ] Build context minimized
- [ ] Health checks implemented

**Operations:**
- [ ] Resource limits set
- [ ] Logging to stdout
- [ ] Graceful shutdown handling
- [ ] Metadata labels added

**Reliability:**
- [ ] Health checks configured
- [ ] Restart policy defined
- [ ] Signal handling implemented
- [ ] Dependency versions pinned

## Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Google Cloud - Container Best Practices](https://cloud.google.com/architecture/best-practices-for-building-containers)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
