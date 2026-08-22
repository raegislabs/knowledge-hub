# CI/CD Best Practices

## Overview

Comprehensive guide to continuous integration and deployment best practices, covering pipeline design, testing strategies, deployment patterns, and operational excellence.

## Core Principles

### 1. Automate Everything
- **Build Process**: Automated, reproducible builds
- **Testing**: Comprehensive automated test suites
- **Deployment**: One-click or automatic deployments
- **Rollback**: Automated rollback on failure

### 2. Fail Fast
- Run fastest tests first
- Fail builds on first error
- Provide immediate feedback
- Surface issues early in pipeline

### 3. Keep Pipelines Fast
- Target: < 10 minutes for full pipeline
- Parallelize independent jobs
- Use caching strategically
- Optimize test execution

### 4. Make Pipelines Reliable
- Eliminate flaky tests
- Use consistent environments
- Handle transient failures gracefully
- Monitor pipeline health

### 5. Security First
- Scan for vulnerabilities early
- Never commit secrets
- Use short-lived credentials
- Audit all deployments

## Pipeline Design Patterns

### Basic Pipeline Structure

```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│  Build  │ → │  Test   │ → │ Package │ → │ Deploy  │
└─────────┘   └─────────┘   └─────────┘   └─────────┘
```

### Advanced Pipeline (Multi-Stage)

```
┌──────────────┐
│ Code Quality │ (lint, format, type check)
└──────┬───────┘
       │
┌──────▼───────┐
│    Build     │ (compile, bundle)
└──────┬───────┘
       │
┌──────▼───────┬──────────────┬───────────────┐
│  Unit Tests  │ Integration  │ Security Scan │
└──────┬───────┴──────┬───────┴───────┬───────┘
       │              │               │
┌──────▼──────────────▼───────────────▼───────┐
│           Package & Publish                 │
└──────┬──────────────────────────────────────┘
       │
┌──────▼───────┬──────────────┬───────────────┐
│ Deploy Dev   │ Deploy Stage │ Deploy Prod   │
└──────────────┴──────────────┴───────────────┘
```

### Fan-Out/Fan-In Pattern

```
           ┌─── Unit Tests ───┐
Build ────┼─── Integration ──┼──── Package ──── Deploy
           └─── E2E Tests ────┘
```

## Testing Strategy

### Test Pyramid

```
       ┌───────────┐
       │    E2E    │  (Few, slow, high confidence)
       ├───────────┤
       │Integration│  (Some, medium speed)
       ├───────────┤
       │   Unit    │  (Many, fast, focused)
       └───────────┘
```

### Test Categories

**Unit Tests (70%)**
- Fast (< 1s per test)
- Isolated (no external dependencies)
- Deterministic (same result every time)
- Comprehensive (high code coverage)

**Integration Tests (20%)**
- Test component interactions
- Use real databases/services (or containers)
- Slower but more realistic
- Focus on critical paths

**End-to-End Tests (10%)**
- Full user workflows
- Production-like environment
- Slowest but highest confidence
- Focus on happy paths + critical failures

### Test Execution Strategy

```yaml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python: ['3.9', '3.10', '3.11']
    steps:
      - run: pytest tests/unit/ -n auto

  integration-tests:
    needs: unit-tests
    services:
      postgres: {...}
      redis: {...}
    steps:
      - run: pytest tests/integration/

  e2e-tests:
    needs: integration-tests
    steps:
      - run: pytest tests/e2e/ --headed
```

## Deployment Strategies

### 1. Blue-Green Deployment

**Concept**: Two identical environments, switch traffic between them

**Pros:**
- Zero downtime
- Easy rollback (switch back)
- Full environment testing before cutover

**Cons:**
- Requires 2x infrastructure
- Database migrations can be complex

**When to Use:**
- Production deployments
- When zero downtime is critical
- When you can afford duplicate infrastructure

### 2. Canary Deployment

**Concept**: Gradually roll out to subset of users

**Phases:**
1. Deploy to 10% of traffic
2. Monitor metrics for 10 minutes
3. If healthy, increase to 50%
4. Monitor for 10 minutes
5. If healthy, increase to 100%

**Pros:**
- Reduced blast radius
- Early issue detection
- Gradual confidence building

**Cons:**
- More complex routing
- Requires good monitoring
- Slower than immediate rollout

**When to Use:**
- High-traffic applications
- When monitoring is robust
- Risk-averse deployments

### 3. Rolling Deployment

**Concept**: Update instances one-at-a-time

**Kubernetes Example:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Add 1 new pod before removing old
    maxUnavailable: 0  # Keep all pods available during update
```

**Pros:**
- No additional infrastructure
- Gradual rollout
- Can pause/resume

**Cons:**
- Mixed versions during rollout
- Slower than immediate
- Requires backward compatibility

**When to Use:**
- Standard deployments
- Resource-constrained environments
- When mixed versions are acceptable

### 4. Feature Flags

**Concept**: Deploy code but enable features selectively

**Example:**
```python
if feature_flag('new_checkout_flow', user_id):
    return new_checkout()
else:
    return old_checkout()
```

**Pros:**
- Decouple deployment from release
- Test in production safely
- Instant rollback (disable flag)
- A/B testing capability

**Cons:**
- Code complexity
- Technical debt if not cleaned up
- Requires flag management system

**When to Use:**
- Risky features
- Gradual rollouts
- A/B testing
- Beta programs

## Branching Strategies

### Trunk-Based Development (Recommended)

```
main ─●─●─●─●─●─●─●─●─●─●─●→
       │   │   │   │
       feature branches
       (short-lived, < 1 day)
```

**Rules:**
- All work on `main` or short-lived branches
- Merge to `main` multiple times per day
- Use feature flags for incomplete features
- Deploy from `main` frequently

**Benefits:**
- Simple workflow
- Encourages small changes
- Reduces merge conflicts
- Faster feedback

### GitFlow (For Complex Release Cycles)

```
main     ─●───────●────────●→ (production)
          │       │        │
develop  ─●─●─●─●─●─●─●─●─●─●→ (integration)
           │     │      │
           feature   feature
           branches  branches
```

**When to Use:**
- Scheduled releases
- Multiple versions in production
- Complex integration needs

## Environment Strategy

### Standard Environments

1. **Development** - Developer workstations + shared dev
2. **Staging** - Production replica for testing
3. **Production** - Live customer-facing system

### Environment Parity

**Goal**: Make environments as similar as possible

**Key Principles:**
- Same OS, runtime versions
- Same infrastructure (scaled down for lower envs)
- Same configuration management
- Anonymized production data in staging

**Differences to Allow:**
- Resource limits (staging can be smaller)
- External service endpoints
- Monitoring/logging verbosity
- Feature flags

## Secrets Management

### Never Commit Secrets

```bash
# .gitignore
.env
.env.local
*.key
*.pem
secrets/
```

### Use Secret Management Tools

**Options:**
- **Vault** (HashiCorp) - Full secret management
- **AWS Secrets Manager** - Cloud-native
- **Doppler** - Developer-friendly
- **SOPS** - Encrypted files in Git

**Example (GitHub Actions):**
```yaml
- name: Deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    API_KEY: ${{ secrets.API_KEY }}
  run: ./deploy.sh
```

### Rotate Secrets Regularly

```bash
# Automated secret rotation
0 0 1 * * /usr/local/bin/rotate-secrets.sh
```

## Build Optimization

### Use Caching

**Dependencies:**
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

**Build Artifacts:**
```yaml
- uses: actions/cache@v4
  with:
    path: ./dist
    key: build-${{ github.sha }}
```

### Parallelize Jobs

```yaml
jobs:
  test:
    strategy:
      matrix:
        python: ['3.9', '3.10', '3.11']
        os: [ubuntu, macos, windows]
    # Runs 9 jobs in parallel
```

### Optimize Docker Builds

```dockerfile
# Copy dependencies first (cached layer)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source last (changes frequently)
COPY . .
```

## Monitoring & Observability

### Key Metrics to Track

**Pipeline Metrics:**
- Build success rate
- Build duration (p50, p95, p99)
- Deployment frequency
- Time to recovery

**Application Metrics:**
- Error rate
- Response time
- Traffic volume
- Saturation

### Deployment Tracking

```yaml
- name: Report deployment
  run: |
    curl -X POST https://api.monitoring.com/deployments \
      -d '{
        "version": "${{ github.sha }}",
        "environment": "production",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      }'
```

## Error Handling & Rollback

### Automatic Rollback

```yaml
deploy:
  steps:
    - name: Deploy
      id: deploy
      run: ./deploy.sh

    - name: Health Check
      id: health
      run: ./health-check.sh
      timeout-minutes: 5

    - name: Rollback on Failure
      if: failure() && steps.deploy.outcome == 'success'
      run: ./rollback.sh
```

### Manual Rollback Process

```bash
# Quick rollback to previous version
kubectl rollout undo deployment/myapp

# Rollback to specific version
kubectl rollout undo deployment/myapp --to-revision=3

# Docker rollback
docker service update --rollback myapp
```

## Documentation

### Pipeline Documentation

**README.md should include:**
- How to run locally
- How to run tests
- Deployment process
- Rollback procedure
- Troubleshooting guide

**Example:**
```markdown
## CI/CD Pipeline

### Running Locally
```bash
make test
make build
make deploy-dev
```

### Pipeline Stages
1. **Lint** - Code quality checks (2min)
2. **Test** - Unit + integration tests (5min)
3. **Build** - Docker image build (3min)
4. **Deploy** - Rolling deployment (2min)

### Rollback
```bash
./scripts/rollback.sh <version>
```

## Anti-Patterns to Avoid

### ❌ Manual Deployments
- Use CI/CD for all deployments
- "Quick fix" deployments create inconsistency

### ❌ Ignoring Broken Builds
- Fix broken main immediately
- Don't merge PRs when main is broken

### ❌ Long-Lived Feature Branches
- Merge to main daily
- Use feature flags instead

### ❌ No Rollback Plan
- Test rollback procedure regularly
- Document rollback steps

### ❌ Skipping Tests
- Never skip tests to "save time"
- If tests are slow, optimize them

### ❌ Deploying on Fridays
- Avoid Friday deployments
- If you must, have on-call coverage

## Checklist for Production-Ready Pipelines

**Code Quality:**
- [ ] Automated linting
- [ ] Code formatting enforcement
- [ ] Type checking (if applicable)
- [ ] Security scanning

**Testing:**
- [ ] Unit tests (> 70% coverage)
- [ ] Integration tests
- [ ] E2E tests (critical paths)
- [ ] Performance tests

**Build:**
- [ ] Reproducible builds
- [ ] Dependency caching
- [ ] Build artifact storage
- [ ] Version tagging

**Deployment:**
- [ ] Automated deployment
- [ ] Health checks
- [ ] Rollback procedure
- [ ] Deployment notifications

**Security:**
- [ ] No secrets in code
- [ ] Vulnerability scanning
- [ ] Dependency updates
- [ ] Access controls

**Monitoring:**
- [ ] Deployment tracking
- [ ] Error alerting
- [ ] Performance monitoring
- [ ] Log aggregation

## Resources

- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-using-github-actions)
- [GitLab CI/CD Best Practices](https://docs.gitlab.com/ee/ci/pipelines/pipeline_efficiency.html)
- [Continuous Delivery Book](https://continuousdelivery.com/)
- [Google SRE Book - Release Engineering](https://sre.google/sre-book/release-engineering/)
