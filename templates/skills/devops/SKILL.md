---
name: devops-templates
description: Production-ready DevOps templates for deployment automation, CI/CD pipelines, containerization, Kubernetes orchestration, infrastructure as code, and monitoring. Use when setting up deployments, creating pipelines, configuring containers, deploying to Kubernetes, managing infrastructure with Terraform, or implementing observability.
---

# DevOps Templates

## Overview

This skill provides production-ready templates and comprehensive methodologies for DevOps practices. It complements the @devops-engineer agent by providing standardized formats, automation scripts, best practices, and reference guides for deployment, containerization, orchestration, infrastructure management, and observability.

**When to use this skill:**
- Automating deployment processes
- Creating CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins)
- Building and optimizing Docker containers
- Deploying applications to Kubernetes
- Managing infrastructure with Terraform
- Setting up monitoring and observability
- Documenting setup and installation procedures

**Skill Structure:** Template/Reference-based with production-ready templates and comprehensive best practices.

## Available Templates

This skill provides 8 production-ready templates in `assets/`:

### 1. Deployment Script Template
**File:** `assets/deployment-script-template.md`

Comprehensive bash deployment script with:
- Error handling and colored output
- Prerequisites checking
- Idempotent operations (safe to run multiple times)
- Progress reporting and logging
- Backup and rollback capabilities
- Multi-environment support (dev/staging/prod)
- Command-line arguments and environment variables
- Dry-run mode for testing

**Use when:** Automating application deployments, creating setup scripts, or implementing release automation.

**Example usage:**
```bash
# Deploy to production
./deploy.sh --environment production

# Dry run to staging
./deploy.sh -e staging --dry-run --verbose

# Rollback production
./deploy.sh -e production --rollback
```

### 2. Setup Guide Template
**File:** `assets/setup-guide-template.md`

Complete installation and configuration documentation with:
- Prerequisites checklist
- Quick start (5-minute setup)
- Detailed step-by-step installation
- Environment configuration
- Database setup
- Usage examples
- Troubleshooting common issues
- Update and uninstallation procedures
- Production deployment guidance

**Use when:** Creating onboarding documentation, writing installation guides, or documenting configuration.

**Example usage:**
```markdown
# MyApp Setup Guide

## Quick Start
```bash
git clone https://github.com/myorg/myapp
cd myapp
./scripts/setup.sh
```

## Prerequisites
- Python 3.11+
- PostgreSQL 15+
- Redis 7+
```

### 3. GitHub Actions Pipeline Template
**File:** `assets/github-actions-pipeline-template.md`

Enterprise-grade CI/CD pipeline featuring:
- Code quality checks (linting, formatting, type checking)
- Security scanning (Trivy, Bandit)
- Multi-version matrix testing
- Docker image building with caching
- Environment-specific deployments (dev/staging/prod)
- Horizontal Pod Autoscaling
- Deployment strategies (canary, rolling)
- Slack/PagerDuty notifications
- Automatic rollback on failure

**Use when:** Setting up GitHub Actions workflows, implementing CI/CD, or automating testing and deployment.

**Example sections:**
- Lint, test, security scan in parallel
- Build Python package and Docker image
- Deploy to dev/staging/prod with approvals
- Create GitHub releases with changelog

### 4. Dockerfile Template
**File:** `assets/dockerfile-template.md`

Multi-stage production Dockerfile with:
- Builder stage for compilation
- Runtime stage for minimal footprint
- Non-root user security
- Health checks
- Proper signal handling
- Layer optimization
- Security best practices
- Size optimization (50-90% reduction)

**Use when:** Creating Docker images, optimizing container size, or improving container security.

**Before/After:**
```
Before: 950 MB (single-stage)
After:  150 MB (multi-stage) - 84% reduction
```

### 5. Docker Compose Template
**File:** `assets/docker-compose-template.md`

Full-stack application orchestration with:
- Application, database, cache, worker services
- Nginx reverse proxy
- Health checks and dependencies
- Volume management
- Network configuration
- Resource limits
- Logging configuration
- Development and production overrides

**Use when:** Setting up local development, orchestrating multi-container apps, or creating reproducible environments.

**Services included:**
- Application (with hot reload for dev)
- PostgreSQL with initialization
- Redis with persistence
- Nginx with SSL
- Background workers (Celery example)

### 6. Kubernetes Deployment Template
**File:** `assets/kubernetes-deployment-template.md`

Complete Kubernetes manifests including:
- Namespace, ConfigMap, Secret
- Deployment with multi-container pods
- Service and Ingress
- Horizontal Pod Autoscaler
- PersistentVolumeClaim
- ServiceAccount with RBAC
- Health probes (liveness, readiness, startup)
- Resource limits and requests
- Security contexts
- Affinity/anti-affinity rules

**Use when:** Deploying to Kubernetes, creating production-ready manifests, or implementing auto-scaling.

**Deployment strategies covered:**
- Rolling updates (default)
- Blue-green deployments
- Canary releases

### 7. Terraform Module Template
**File:** `assets/terraform-module-template.md`

Infrastructure as Code module with:
- VPC with public/private subnets
- Internet Gateway and NAT Gateways
- Route tables and associations
- Security groups
- Variable validation
- Output values
- Data sources for dynamic configuration
- Local values for DRY principles
- Conditional resource creation

**Use when:** Creating reusable Terraform modules, provisioning cloud infrastructure, or managing infrastructure as code.

**Features:**
- Multi-AZ support
- Environment-specific configuration
- Tagged resources
- Modular design

### 8. Monitoring Setup Template
**File:** `assets/monitoring-setup-template.md`

Complete observability stack with:
- Prometheus for metrics collection
- Grafana for visualization
- Alertmanager for alert routing
- Loki for log aggregation
- Promtail for log shipping
- Node Exporter for host metrics
- cAdvisor for container metrics
- Alert rules for common issues
- Python instrumentation examples

**Use when:** Setting up monitoring, implementing observability, or creating dashboards and alerts.

**Metrics covered:**
- Application (requests, errors, latency)
- Infrastructure (CPU, memory, disk)
- Custom business metrics

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. CI/CD Best Practices
**File:** `references/cicd-best-practices.md`

Systematic approaches for continuous integration and deployment:

**Topics Covered:**
- **Core Principles**: Automate everything, fail fast, keep pipelines fast, make reliable, security first
- **Pipeline Design Patterns**: Basic, advanced multi-stage, fan-out/fan-in
- **Testing Strategy**: Test pyramid (70% unit, 20% integration, 10% E2E)
- **Deployment Strategies**: Blue-green, canary, rolling, feature flags
- **Branching Strategies**: Trunk-based development, GitFlow
- **Environment Strategy**: Dev/staging/production parity
- **Secrets Management**: Vault, AWS Secrets Manager, rotation
- **Build Optimization**: Caching, parallelization, Docker optimization
- **Monitoring & Observability**: Pipeline metrics, deployment tracking
- **Error Handling**: Automatic rollback, manual procedures
- **Anti-Patterns**: What to avoid (manual deployments, long-lived branches, Friday deploys)

**Use when:** Designing CI/CD pipelines, optimizing build times, or implementing deployment automation.

### 2. Container Optimization
**File:** `references/container-optimization.md`

Docker image optimization for size, security, and performance:

**Topics Covered:**
- **Image Size Optimization**: Base image selection, multi-stage builds, layer optimization, .dockerignore (84% size reduction examples)
- **Security Hardening**: Non-root users, read-only filesystem, capability dropping, vulnerability scanning
- **Performance Optimization**: Layer minimization, BuildKit, caching strategies
- **Resource Management**: CPU/memory limits, health checks, graceful shutdown
- **Logging Best Practices**: STDOUT/STDERR, structured logging, log drivers
- **Common Patterns**: Python, Node.js optimized Dockerfiles
- **Troubleshooting**: Large images, slow builds, container crashes

**Size Comparison:**
```
Full Python:    1.0 GB
Python slim:    150 MB ✅
Python alpine:   50 MB ⚠️
Distroless:      80 MB ✅
```

**Use when:** Optimizing Docker images, improving container security, or troubleshooting container issues.

### 3. Kubernetes Patterns
**File:** `references/kubernetes-patterns.md`

Common Kubernetes deployment and operational patterns:

**Topics Covered:**
- **Deployment Patterns**: Rolling update, recreate, blue-green
- **Health Check Patterns**: Liveness, readiness, startup probes
- **Resource Management**: Requests vs limits, QoS classes
- **Configuration Patterns**: ConfigMap, Secret, environment variables
- **Scaling Patterns**: HPA, Pod Disruption Budget
- **Storage Patterns**: StatefulSet, PersistentVolumeClaim
- **Networking Patterns**: Service types (ClusterIP, LoadBalancer, NodePort), Ingress
- **Security Patterns**: Pod security context, NetworkPolicy
- **Best Practices**: Labels, annotations, affinity rules

**Use when:** Deploying to Kubernetes, implementing auto-scaling, or troubleshooting Kubernetes applications.

### 4. Infrastructure as Code
**File:** `references/infrastructure-as-code.md`

Terraform best practices for maintainable infrastructure:

**Topics Covered:**
- **Core Principles**: Everything as code, DRY, immutable infrastructure
- **Module Structure**: Standard layout, single responsibility, versioning
- **State Management**: Remote state, locking, workspaces
- **Variable Management**: Hierarchy, environment-specific, sensitive variables
- **Naming Conventions**: Resources, variables, tags
- **Resource Management**: Lifecycle rules, dependencies, count vs for_each
- **Data Sources**: Dynamic configuration
- **Security Best Practices**: No secrets in code, least privilege, encryption
- **Testing**: Validation, automated testing (Terratest)
- **Workflow**: Standard workflow, CI/CD integration
- **Common Patterns**: Environment separation, shared state access
- **Troubleshooting**: State drift, stuck resources

**Use when:** Writing Terraform modules, managing cloud infrastructure, or implementing infrastructure as code.

### 5. Observability Guide
**File:** `references/observability-guide.md`

Implementing comprehensive observability:

**Topics Covered:**
- **Three Pillars**: Logging (what happened), Metrics (how much), Tracing (where did time go)
- **Logging Best Practices**: Structured logging, log levels, correlation IDs
- **Metrics**: RED method (Rate, Errors, Duration), USE method (Utilization, Saturation, Errors)
- **Distributed Tracing**: OpenTelemetry, custom spans
- **Alerting**: Alert design principles, severity levels, avoiding alert fatigue
- **Dashboards**: Key metrics, best practices
- **SLIs, SLOs, SLAs**: Definition, error budgets
- **Practical Implementation**: Application instrumentation, correlation IDs
- **Tools Comparison**: ELK vs Loki, Prometheus vs Datadog, Jaeger vs Zipkin

**Key Metrics:**
- Request rate, error rate, response time (RED)
- CPU, memory, disk, network (USE)
- Business metrics (active users, revenue)

**Use when:** Implementing monitoring, creating alerts, or setting up distributed tracing.

## Usage Patterns

### Pattern 1: New Application Deployment Setup

**Scenario:** Setting up complete deployment pipeline for a new application.

**Process:**
1. Read `cicd-best-practices.md` → Pipeline Design section
2. Use `github-actions-pipeline-template.md` for CI/CD workflow
3. Use `dockerfile-template.md` for container image
4. Use `docker-compose-template.md` for local development
5. Use `deployment-script-template.md` for automation
6. Use `setup-guide-template.md` for documentation

**Time:** 4-6 hours

**Deliverables:**
- CI/CD pipeline with testing and deployment
- Optimized Docker images
- Local development environment
- Deployment automation scripts
- Complete setup documentation

### Pattern 2: Kubernetes Migration

**Scenario:** Migrating existing application to Kubernetes.

**Process:**
1. Read `kubernetes-patterns.md` → Deployment Patterns section
2. Read `container-optimization.md` → Optimize existing images
3. Use `kubernetes-deployment-template.md` for manifests
4. Use `monitoring-setup-template.md` for observability
5. Read `observability-guide.md` → SLIs/SLOs section

**Time:** 1-2 days

**Deliverables:**
- Kubernetes manifests (Deployment, Service, Ingress, HPA)
- Optimized container images
- Monitoring and alerting
- Health checks and auto-scaling

### Pattern 3: Infrastructure as Code Setup

**Scenario:** Provisioning cloud infrastructure with Terraform.

**Process:**
1. Read `infrastructure-as-code.md` → Module Structure section
2. Use `terraform-module-template.md` for VPC/networking
3. Read `infrastructure-as-code.md` → State Management section
4. Read `cicd-best-practices.md` → CI/CD for Terraform
5. Use `github-actions-pipeline-template.md` → Terraform workflow

**Time:** 1-2 days

**Deliverables:**
- Reusable Terraform modules
- Remote state with locking
- CI/CD for infrastructure changes
- Documentation and examples

### Pattern 4: Monitoring and Observability Implementation

**Scenario:** Adding comprehensive monitoring to existing application.

**Process:**
1. Read `observability-guide.md` → Three Pillars section
2. Use `monitoring-setup-template.md` for Prometheus/Grafana stack
3. Read `observability-guide.md` → Metrics section for instrumentation
4. Read `observability-guide.md` → Alerting section
5. Read `observability-guide.md` → SLIs/SLOs for goal-setting

**Time:** 2-3 days

**Deliverables:**
- Prometheus/Grafana monitoring stack
- Application instrumentation (metrics, logs, traces)
- Alerting rules and runbooks
- Dashboards for application and infrastructure
- Defined SLOs and error budgets

### Pattern 5: CI/CD Pipeline Optimization

**Scenario:** Improving slow or unreliable CI/CD pipeline.

**Process:**
1. Read `cicd-best-practices.md` → Build Optimization section
2. Read `container-optimization.md` → Performance section
3. Update `github-actions-pipeline-template.md` with caching
4. Read `cicd-best-practices.md` → Testing Strategy for parallelization
5. Implement rollback from `deployment-script-template.md`

**Time:** 1 day

**Improvements:**
- 50-70% faster builds (caching, parallelization)
- More reliable (better error handling, retries)
- Safer (automated rollback, health checks)

### Pattern 6: Production Deployment Hardening

**Scenario:** Preparing application for production deployment.

**Process:**
1. Read `container-optimization.md` → Security Hardening section
2. Read `kubernetes-patterns.md` → Security Patterns section
3. Read `observability-guide.md` → Alerting section
4. Use `monitoring-setup-template.md` for production monitoring
5. Read `cicd-best-practices.md` → Deployment Strategies (canary/blue-green)

**Time:** 2-3 days

**Checklist:**
- Non-root containers with read-only filesystem
- Resource limits and health checks
- Monitoring, alerting, and SLOs
- Deployment automation with rollback
- Security scanning and secrets management

## Integration with @devops-engineer

This skill is designed to complement the @devops-engineer agent:

**Agent's Role:**
- Analyzes deployment requirements
- Customizes templates for specific use cases
- Implements automation logic
- Troubleshoots deployment issues

**Skill's Role:**
- Provides standardized templates
- Offers best practices and methodologies
- Ensures production-ready implementations
- Maintains consistency across projects

**Workflow:**
```markdown
User: "@devops-engineer, set up CI/CD for our Python API"

Agent:
1. Loads devops-templates skill
2. Reads cicd-best-practices.md for pipeline design
3. Uses github-actions-pipeline-template.md as base
4. Customizes for Python (pytest, black, mypy)
5. Uses dockerfile-template.md for containerization
6. Uses deployment-script-template.md for deployment automation
7. Uses setup-guide-template.md for documentation
8. Delivers complete, production-ready CI/CD pipeline
```

## Best Practices

### 1. Start with Reference Guides
Always read relevant reference guides before using templates to understand best practices and common pitfalls.

### 2. Customize Templates
Templates are starting points - adapt to your specific requirements. Remove irrelevant sections, add project-specific logic.

### 3. Version Control Everything
Store all infrastructure, deployment scripts, and configuration in version control. Use GitOps principles.

### 4. Test Before Production
- Use dry-run modes for deployment scripts
- Test Terraform plans before apply
- Use staging environments for validation

### 5. Document Everything
- Use setup-guide-template.md for installation
- Document runbooks in alert annotations
- Keep README up-to-date

### 6. Implement Observability Early
Don't wait until production issues arise. Implement monitoring, logging, and tracing from the start.

### 7. Automate Repetitive Tasks
Use deployment-script-template.md to automate manual processes. If you do it twice, script it.

### 8. Security First
- Scan containers for vulnerabilities
- Use secrets management (never commit secrets)
- Implement least privilege access
- Run as non-root users

### 9. Optimize for Fast Feedback
- Keep CI/CD pipelines fast (< 10 minutes)
- Parallelize independent tasks
- Cache dependencies
- Run fastest tests first

### 10. Plan for Failure
- Implement health checks
- Add automatic rollback
- Document recovery procedures
- Test disaster recovery

## Resources

### assets/
Template files designed to be copied and customized:

- **deployment-script-template.md** - Bash deployment automation (13KB, ~400 lines)
- **setup-guide-template.md** - Installation and configuration documentation (13KB, ~400 lines)
- **github-actions-pipeline-template.md** - CI/CD workflow configuration (18KB, ~600 lines)
- **dockerfile-template.md** - Multi-stage container image (9KB, ~300 lines)
- **docker-compose-template.md** - Multi-container orchestration (13KB, ~450 lines)
- **kubernetes-deployment-template.md** - K8s manifests (14KB, ~500 lines)
- **terraform-module-template.md** - Infrastructure as code module (16KB, ~550 lines)
- **monitoring-setup-template.md** - Observability stack (16KB, ~550 lines)

**Total**: 8 templates, ~3,750 lines of production-ready code

**Usage:** Copy template, customize placeholders, adapt to your stack, test thoroughly.

### references/
Comprehensive reference guides loaded into context:

- **cicd-best-practices.md** - Pipeline design, testing strategies, deployment patterns (12KB)
- **container-optimization.md** - Docker size, security, performance optimization (9KB)
- **kubernetes-patterns.md** - K8s deployment and operational patterns (7KB)
- **infrastructure-as-code.md** - Terraform best practices and workflows (8KB)
- **observability-guide.md** - Logging, metrics, tracing, alerting (8KB)

**Total**: 5 guides, ~44KB of best practices

**Usage:** Read relevant sections to inform implementation decisions and avoid common pitfalls.

## Examples

### Example 1: Complete Application Stack

```markdown
User: "Set up complete deployment for a Python FastAPI application with PostgreSQL database"

Process:
1. Read cicd-best-practices.md → Pipeline Design section
2. Use dockerfile-template.md → Customize for Python/FastAPI
3. Use docker-compose-template.md → Add FastAPI + PostgreSQL services
4. Use github-actions-pipeline-template.md → Add Python testing
5. Use kubernetes-deployment-template.md → Add K8s manifests
6. Use monitoring-setup-template.md → Add Prometheus instrumentation
7. Use setup-guide-template.md → Document setup process

Deliverables:
- Multi-stage Dockerfile (150MB final image, down from 1GB)
- docker-compose.yml with FastAPI, PostgreSQL, Redis
- GitHub Actions workflow (lint, test, security scan, deploy)
- Kubernetes manifests with HPA and health checks
- Prometheus/Grafana monitoring
- Complete setup documentation
```

### Example 2: Kubernetes Migration

```markdown
User: "Migrate Docker Compose application to Kubernetes"

Process:
1. Read kubernetes-patterns.md → Deployment Patterns
2. Read container-optimization.md → Optimize existing images
3. Use kubernetes-deployment-template.md → Convert services to K8s
4. Read kubernetes-patterns.md → Health Checks section
5. Use monitoring-setup-template.md → Add K8s monitoring
6. Read observability-guide.md → Define SLOs

Deliverables:
- Optimized Docker images (50% size reduction)
- K8s Deployment + Service + Ingress for each component
- HorizontalPodAutoscaler based on CPU and custom metrics
- Liveness, readiness, and startup probes
- Prometheus ServiceMonitor for metrics collection
- Defined SLOs (99.9% uptime, p95 < 200ms)
```

### Example 3: Infrastructure as Code

```markdown
User: "Create Terraform modules for AWS VPC and compute infrastructure"

Process:
1. Read infrastructure-as-code.md → Module Structure
2. Use terraform-module-template.md → Create VPC module
3. Read infrastructure-as-code.md → State Management
4. Use github-actions-pipeline-template.md → Add Terraform CI/CD
5. Read infrastructure-as-code.md → Testing section

Deliverables:
- VPC module (subnets, gateways, route tables)
- Compute module (EC2, autoscaling groups)
- S3 backend with DynamoDB locking
- GitHub Actions workflow (fmt, validate, plan, apply)
- Terratest integration tests
- Module documentation and examples
```

## Tips & Tricks

### Tip 1: Layer Your Deployments
Start with basic templates, then layer in complexity:
1. Basic Dockerfile → Multi-stage → Security hardening
2. Simple pipeline → Matrix testing → Multi-environment deployment
3. Single service → Multi-service → Monitoring/observability

### Tip 2: Use Feature Flags for Risk Mitigation
Deploy code to production with features disabled, then gradually enable:
```python
if feature_flag('new_checkout', user_id):
    return new_checkout_flow()
else:
    return legacy_checkout_flow()
```

### Tip 3: Implement Blue-Green for Critical Services
For zero-downtime deployments, use kubernetes-deployment-template.md blue-green pattern.

### Tip 4: Cache Everything
- Docker layer caching (BuildKit)
- CI/CD dependency caching
- Terraform provider plugins
- NPM/pip packages

**Impact:** 50-70% faster builds

### Tip 5: Automate Secret Rotation
Use deployment-script-template.md to implement automated secret rotation:
```bash
# Rotate database password
rotate_secret() {
    NEW_PASSWORD=$(generate_password)
    kubectl set secret db-secret password=$NEW_PASSWORD
    kubectl rollout restart deployment/app
}
```

### Tip 6: Monitor Deployment Metrics
Track DORA metrics:
- Deployment frequency
- Lead time for changes
- Mean time to recovery (MTTR)
- Change failure rate

### Tip 7: Use Canary Deployments for High-Risk Changes
Start with 10% traffic, monitor for 10 minutes, gradually increase to 100%.

### Tip 8: Implement Graceful Shutdown
Ensure containers handle SIGTERM properly for zero-downtime deployments:
```python
import signal

def graceful_shutdown(signum, frame):
    # Close connections, flush buffers
    sys.exit(0)

signal.signal(signal.SIGTERM, graceful_shutdown)
```

### Tip 9: Use Init Containers for Dependencies
Wait for database before starting application:
```yaml
initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z postgres 5432; do sleep 2; done']
```

### Tip 10: Implement Circuit Breakers
Prevent cascading failures in distributed systems:
```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=60)
def call_external_api():
    return requests.get('https://api.example.com/data')
```

---

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @devops-engineer - Primary consumer of this skill's templates and methodologies
- @developer - Uses templates for local development (Docker Compose)
- @architect - References patterns for system design decisions
