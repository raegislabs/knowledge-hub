# Dockerfile Template

## Overview

Production-ready Dockerfile template with multi-stage builds, security best practices, and optimization for minimal image size.

## Multi-Stage Python Dockerfile

```dockerfile
# =============================================================================
# Stage 1: Builder
# Purpose: Compile dependencies and build artifacts
# =============================================================================
FROM python:3.11-slim AS builder

# Set build arguments
ARG APP_NAME=myapp
ARG APP_VERSION=1.0.0

# Set environment variables for build
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /build

# Copy dependency files first (leverage Docker layer caching)
COPY requirements.txt requirements-prod.txt ./

# Install Python dependencies to a local directory
RUN pip install --user --no-warn-script-location \
    -r requirements-prod.txt

# Copy application code
COPY . .

# Build application (if needed)
RUN python setup.py build

# =============================================================================
# Stage 2: Runtime
# Purpose: Minimal runtime image with only necessary files
# =============================================================================
FROM python:3.11-slim AS runtime

# Set labels for metadata
LABEL maintainer="your-email@example.com" \
      version="${APP_VERSION}" \
      description="Production container for ${APP_NAME}"

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/appuser/.local/bin:$PATH" \
    APP_HOME=/app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory with proper permissions
WORKDIR ${APP_HOME}
RUN chown -R appuser:appuser ${APP_HOME}

# Copy Python dependencies from builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Multi-Stage Node.js Dockerfile

```dockerfile
# =============================================================================
# Stage 1: Dependencies
# =============================================================================
FROM node:18-alpine AS deps

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# =============================================================================
# Stage 2: Builder
# =============================================================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and install all dependencies (including dev)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# =============================================================================
# Stage 3: Runtime
# =============================================================================
FROM node:18-alpine AS runtime

# Set labels
LABEL maintainer="your-email@example.com"

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy production dependencies
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

## Best Practices

### 1. Use Multi-Stage Builds
- Separate build and runtime stages
- Reduces final image size by 50-90%
- Excludes build tools from production

### 2. Minimize Layers
```dockerfile
# ❌ Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget

# ✅ Good: Single layer
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*
```

### 3. Leverage Build Cache
```dockerfile
# Copy dependency files first
COPY package.json package-lock.json ./
RUN npm install

# Copy source code last (changes frequently)
COPY . .
```

### 4. Use Specific Base Images
```dockerfile
# ❌ Avoid: latest tag
FROM python:latest

# ✅ Prefer: Specific version + slim variant
FROM python:3.11-slim

# ✅ Best: Exact digest for reproducibility
FROM python:3.11-slim@sha256:abc123...
```

### 5. Run as Non-Root User
```dockerfile
RUN adduser --disabled-password --gecos '' appuser
USER appuser
```

### 6. Include Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

### 7. Use .dockerignore
Create `.dockerignore`:
```
.git
.gitignore
node_modules
npm-debug.log
__pycache__
*.pyc
.pytest_cache
.env
.env.local
.DS_Store
README.md
docs/
tests/
*.md
```

## Security Best Practices

### 1. Scan for Vulnerabilities
```bash
docker scan myimage:latest
trivy image myimage:latest
```

### 2. Use Minimal Base Images
```dockerfile
# Alpine is smallest (5MB)
FROM python:3.11-alpine

# Slim is small (40MB) with better compatibility
FROM python:3.11-slim

# Distroless has minimal attack surface
FROM gcr.io/distroless/python3
```

### 3. Don't Store Secrets
```dockerfile
# ❌ Never do this
ENV API_KEY="secret123"

# ✅ Use build arguments or runtime env vars
ARG API_KEY
# Or mount secrets at runtime
```

### 4. Update Packages
```dockerfile
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*
```

## Optimization Tips

### 1. Layer Ordering
```dockerfile
# Static layers first (change rarely)
FROM python:3.11-slim
RUN apt-get update && apt-get install -y ...

# Dependency layers next
COPY requirements.txt .
RUN pip install -r requirements.txt

# Application code last (changes frequently)
COPY . .
```

### 2. Use BuildKit
```bash
# Enable BuildKit for faster builds
DOCKER_BUILDKIT=1 docker build -t myimage .
```

### 3. Parallel Builds
```dockerfile
# BuildKit allows parallel stage execution
FROM base AS stage1
FROM base AS stage2
FROM stage1 AS final
COPY --from=stage2 ...
```

## Example: Full-Stack Application

```dockerfile
# =============================================================================
# Frontend Builder
# =============================================================================
FROM node:18-alpine AS frontend-builder

WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# =============================================================================
# Backend Builder
# =============================================================================
FROM python:3.11-slim AS backend-builder

WORKDIR /backend
COPY backend/requirements.txt ./
RUN pip install --user -r requirements.txt
COPY backend/ ./

# =============================================================================
# Production Runtime
# =============================================================================
FROM python:3.11-slim

RUN adduser --disabled-password --gecos '' appuser

WORKDIR /app

# Copy backend
COPY --from=backend-builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --from=backend-builder --chown=appuser:appuser /backend ./backend

# Copy frontend build
COPY --from=frontend-builder --chown=appuser:appuser /frontend/dist ./frontend/dist

USER appuser

ENV PATH="/home/appuser/.local/bin:$PATH"

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0"]
```

## Build Commands

```bash
# Standard build
docker build -t myapp:latest .

# With build arguments
docker build --build-arg APP_VERSION=1.2.3 -t myapp:1.2.3 .

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .

# Build specific stage
docker build --target builder -t myapp:builder .

# No cache build
docker build --no-cache -t myapp:latest .
```

## Related Templates

- `docker-compose-template.md` - Multi-container orchestration
- `kubernetes-deployment-template.md` - Kubernetes deployment
