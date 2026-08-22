# Docker Compose Template

## Overview

Production-ready Docker Compose configuration for local development and deployment with multiple services, networking, volumes, and environment management.

## Full-Stack Application Template

```yaml
version: '3.8'

# =============================================================================
# Services Configuration
# =============================================================================
services:
  # ---------------------------------------------------------------------------
  # Application Service
  # ---------------------------------------------------------------------------
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: ${BUILD_TARGET:-production}
      args:
        - APP_VERSION=${APP_VERSION:-1.0.0}
        - BUILD_DATE=${BUILD_DATE:-2024-01-01}
    image: ${DOCKER_REGISTRY:-}myapp:${APP_VERSION:-latest}
    container_name: myapp
    restart: unless-stopped

    ports:
      - "${APP_PORT:-8000}:8000"

    environment:
      - ENVIRONMENT=${ENVIRONMENT:-development}
      - DEBUG=${DEBUG:-false}
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - DATABASE_URL=postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@postgres:5432/${POSTGRES_DB:-myapp}
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY:-changeme}

    env_file:
      - .env
      - .env.local  # Optional override file (gitignored)

    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

    volumes:
      # Application code (dev only)
      - ${DEV_MODE:+./src:/app/src}
      # Persistent data
      - app-data:/app/data
      # Logs
      - ./logs:/app/logs

    networks:
      - app-network

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

  # ---------------------------------------------------------------------------
  # PostgreSQL Database
  # ---------------------------------------------------------------------------
  postgres:
    image: postgres:15-alpine
    container_name: myapp-postgres
    restart: unless-stopped

    environment:
      - POSTGRES_USER=${POSTGRES_USER:-postgres}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
      - POSTGRES_DB=${POSTGRES_DB:-myapp}
      - POSTGRES_INITDB_ARGS=--encoding=UTF-8

    ports:
      - "${POSTGRES_PORT:-5432}:5432"

    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:ro

    networks:
      - app-network

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5

    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "3"

  # ---------------------------------------------------------------------------
  # Redis Cache
  # ---------------------------------------------------------------------------
  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    restart: unless-stopped

    command: >
      redis-server
      --appendonly yes
      --requirepass ${REDIS_PASSWORD:-}
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru

    ports:
      - "${REDIS_PORT:-6379}:6379"

    volumes:
      - redis-data:/data

    networks:
      - app-network

    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "3"

  # ---------------------------------------------------------------------------
  # Nginx Reverse Proxy
  # ---------------------------------------------------------------------------
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    restart: unless-stopped

    ports:
      - "${NGINX_HTTP_PORT:-80}:80"
      - "${NGINX_HTTPS_PORT:-443}:443"

    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./docker/nginx/conf.d:/etc/nginx/conf.d:ro
      - ./docker/nginx/ssl:/etc/nginx/ssl:ro
      - ./static:/usr/share/nginx/html/static:ro

    depends_on:
      - app

    networks:
      - app-network

    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ---------------------------------------------------------------------------
  # Worker/Background Jobs (Optional)
  # ---------------------------------------------------------------------------
  worker:
    build:
      context: .
      dockerfile: Dockerfile
      target: ${BUILD_TARGET:-production}
    image: ${DOCKER_REGISTRY:-}myapp:${APP_VERSION:-latest}
    container_name: myapp-worker
    restart: unless-stopped

    command: python -m celery -A app.celery worker --loglevel=info

    environment:
      - ENVIRONMENT=${ENVIRONMENT:-development}
      - DATABASE_URL=postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@postgres:5432/${POSTGRES_DB:-myapp}
      - REDIS_URL=redis://redis:6379/0

    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

    volumes:
      - ${DEV_MODE:+./src:/app/src}
      - worker-data:/app/data

    networks:
      - app-network

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

    deploy:
      replicas: ${WORKER_REPLICAS:-2}
      resources:
        limits:
          cpus: '1'
          memory: 1G

# =============================================================================
# Networks Configuration
# =============================================================================
networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

# =============================================================================
# Volumes Configuration
# =============================================================================
volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
  app-data:
    driver: local
  worker-data:
    driver: local
```

## Environment Variables (.env)

```bash
# =============================================================================
# Application Configuration
# =============================================================================
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug
APP_VERSION=1.0.0
BUILD_TARGET=development

# Application port
APP_PORT=8000

# Secret key (generate with: openssl rand -hex 32)
SECRET_KEY=your-secret-key-here

# =============================================================================
# Database Configuration
# =============================================================================
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=myapp
POSTGRES_PORT=5432

# =============================================================================
# Redis Configuration
# =============================================================================
REDIS_PASSWORD=
REDIS_PORT=6379

# =============================================================================
# Nginx Configuration
# =============================================================================
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# =============================================================================
# Worker Configuration
# =============================================================================
WORKER_REPLICAS=2

# =============================================================================
# Development Mode
# =============================================================================
# Set to any value to enable volume mounting for hot reload
DEV_MODE=1

# =============================================================================
# Docker Registry (for production)
# =============================================================================
DOCKER_REGISTRY=

# =============================================================================
# Build Metadata
# =============================================================================
BUILD_DATE=2024-01-01
```

## Development Override (docker-compose.dev.yml)

```yaml
version: '3.8'

services:
  app:
    build:
      target: development
    command: python -m uvicorn main:app --reload --host 0.0.0.0
    volumes:
      - ./src:/app/src:delegated
      - ./tests:/app/tests:delegated
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
    ports:
      - "8000:8000"
      - "5678:5678"  # Debugger port

  postgres:
    ports:
      - "5432:5432"  # Expose for local DB tools

  redis:
    ports:
      - "6379:6379"  # Expose for local Redis tools
```

## Production Override (docker-compose.prod.yml)

```yaml
version: '3.8'

services:
  app:
    build:
      target: production
    environment:
      - DEBUG=false
      - LOG_LEVEL=warning
    restart: always
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  postgres:
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}  # From secrets
    volumes:
      - /var/lib/postgresql/data:/var/lib/postgresql/data

  nginx:
    volumes:
      - /etc/letsencrypt:/etc/nginx/ssl:ro
```

## Usage Commands

```bash
# =============================================================================
# Development
# =============================================================================

# Start all services
docker-compose up

# Start in detached mode
docker-compose up -d

# Start with development overrides
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Rebuild and start
docker-compose up --build

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app

# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ DATA LOSS)
docker-compose down -v

# =============================================================================
# Production
# =============================================================================

# Start production stack
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Scale worker service
docker-compose up -d --scale worker=5

# Update service
docker-compose up -d --no-deps --build app

# =============================================================================
# Maintenance
# =============================================================================

# Execute command in container
docker-compose exec app python manage.py migrate

# Access container shell
docker-compose exec app /bin/bash

# View resource usage
docker-compose stats

# Validate configuration
docker-compose config

# Remove stopped containers
docker-compose rm

# =============================================================================
# Database Operations
# =============================================================================

# Create database backup
docker-compose exec postgres pg_dump -U postgres myapp > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres myapp < backup.sql

# Access PostgreSQL shell
docker-compose exec postgres psql -U postgres -d myapp

# Access Redis CLI
docker-compose exec redis redis-cli
```

## Best Practices

### 1. Use Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### 2. Implement Dependency Management
```yaml
depends_on:
  postgres:
    condition: service_healthy
```

### 3. Configure Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
```

### 4. Use Named Volumes
```yaml
volumes:
  postgres-data:
    driver: local
```

### 5. Separate Networks
```yaml
networks:
  frontend:
  backend:
```

### 6. Environment-Specific Overrides
```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## Security Considerations

### 1. Don't Commit Secrets
```bash
# .gitignore
.env
.env.local
.env.production
```

### 2. Use Docker Secrets (Swarm Mode)
```yaml
services:
  app:
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### 3. Limit Container Capabilities
```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

### 4. Read-Only Root Filesystem
```yaml
read_only: true
tmpfs:
  - /tmp
```

## Troubleshooting

### View Service Status
```bash
docker-compose ps
```

### Check Logs
```bash
docker-compose logs --tail=100 -f app
```

### Rebuild Service
```bash
docker-compose up -d --no-deps --build app
```

### Network Issues
```bash
docker-compose down
docker network prune
docker-compose up
```

## Related Templates

- `dockerfile-template.md` - Container image definition
- `kubernetes-deployment-template.md` - Kubernetes orchestration
- `nginx-config-template.md` - Nginx reverse proxy configuration
