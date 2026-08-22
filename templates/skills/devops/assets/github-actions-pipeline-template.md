# GitHub Actions CI/CD Pipeline Template

## Overview

This template provides comprehensive GitHub Actions workflows for continuous integration and deployment, including testing, linting, building, and deploying applications across multiple environments.

## Template

```yaml
name: {Application Name} CI/CD

on:
  push:
    branches:
      - main
      - develop
      - 'release/**'
  pull_request:
    branches:
      - main
      - develop
  workflow_dispatch:  # Manual trigger
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        type: choice
        options:
          - development
          - staging
          - production

# Environment variables available to all jobs
env:
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.11'
  CACHE_VERSION: v1

jobs:
  #===========================================================================
  # CODE QUALITY CHECKS
  #===========================================================================

  lint:
    name: Lint Code
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better analysis

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install linting tools
        run: |
          python -m pip install --upgrade pip
          pip install flake8 black isort mypy pylint

      - name: Run Flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --max-complexity=10 --max-line-length=100 --statistics

      - name: Check code formatting (Black)
        run: black --check --diff .

      - name: Check import sorting (isort)
        run: isort --check-only --diff .

      - name: Type checking (mypy)
        run: mypy . --ignore-missing-imports

      - name: Run Pylint
        run: pylint **/*.py --fail-under=8.0
        continue-on-error: true  # Don't fail build on warnings

  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    timeout-minutes: 10
    permissions:
      security-events: write
      actions: read
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Run Bandit security linter
        run: |
          pip install bandit
          bandit -r . -f json -o bandit-report.json
        continue-on-error: true

      - name: Upload Bandit results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: bandit-report
          path: bandit-report.json

  #===========================================================================
  # TESTING
  #===========================================================================

  test:
    name: Test (Python ${{ matrix.python-version }})
    runs-on: ${{ matrix.os }}
    timeout-minutes: 20

    strategy:
      fail-fast: false  # Continue testing other versions if one fails
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ['3.9', '3.10', '3.11', '3.12']
        exclude:
          # Optionally exclude certain combinations
          - os: macos-latest
            python-version: '3.9'
          - os: windows-latest
            python-version: '3.9'

    services:
      # Example: PostgreSQL service container
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      # Example: Redis service container
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
          pip install pytest pytest-cov pytest-xdist

      - name: Set up environment
        run: |
          cp .env.example .env
          echo "DATABASE_URL=postgresql://postgres:postgres@localhost:5432/test_db" >> .env
          echo "REDIS_URL=redis://localhost:6379" >> .env

      - name: Run unit tests
        run: |
          pytest tests/unit/ -v \
            --cov=src \
            --cov-report=xml \
            --cov-report=html \
            --cov-report=term-missing \
            --junitxml=test-results-unit.xml \
            -n auto

      - name: Run integration tests
        run: |
          pytest tests/integration/ -v \
            --junitxml=test-results-integration.xml \
            -n auto

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        if: matrix.python-version == '3.11' && matrix.os == 'ubuntu-latest'
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-${{ matrix.python-version }}
          fail_ci_if_error: false

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results-${{ matrix.os }}-${{ matrix.python-version }}
          path: test-results-*.xml

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        if: matrix.python-version == '3.11' && matrix.os == 'ubuntu-latest'
        with:
          name: coverage-report
          path: htmlcov/

  #===========================================================================
  # BUILD
  #===========================================================================

  build:
    name: Build Application
    runs-on: ubuntu-latest
    needs: [lint, test]
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install build tools
        run: |
          python -m pip install --upgrade pip
          pip install build twine wheel

      - name: Build package
        run: python -m build

      - name: Check package
        run: twine check dist/*

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: python-package
          path: dist/
          retention-days: 7

  build-docker:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: [lint, test]
    timeout-minutes: 20

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/{image-name}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64

  #===========================================================================
  # DEPLOYMENT
  #===========================================================================

  deploy-development:
    name: Deploy to Development
    runs-on: ubuntu-latest
    needs: [build, build-docker]
    if: github.ref == 'refs/heads/develop'
    environment:
      name: development
      url: https://dev.{your-domain}.com
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: python-package
          path: dist/

      - name: Deploy to development
        run: |
          # Add deployment commands here
          echo "Deploying to development environment..."
          # ./scripts/deploy.sh development

      - name: Run smoke tests
        run: |
          # Add smoke test commands
          curl -f https://dev.{your-domain}.com/health || exit 1

      - name: Notify deployment
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Development deployment ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: [build, build-docker, security-scan]
    if: startsWith(github.ref, 'refs/heads/release/')
    environment:
      name: staging
      url: https://staging.{your-domain}.com
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: python-package
          path: dist/

      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment..."
          # ./scripts/deploy.sh staging

      - name: Run smoke tests
        run: |
          curl -f https://staging.{your-domain}.com/health || exit 1

      - name: Run E2E tests
        run: |
          # Add E2E test commands
          # npm run test:e2e:staging
          echo "Running E2E tests..."

      - name: Notify deployment
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Staging deployment ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build, build-docker, security-scan]
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://{your-domain}.com
    timeout-minutes: 20

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: python-package
          path: dist/

      - name: Create deployment backup
        run: |
          echo "Creating backup before deployment..."
          # Add backup commands

      - name: Deploy to production (canary)
        run: |
          echo "Deploying canary release..."
          # ./scripts/deploy.sh production --strategy canary --percentage 10

      - name: Monitor canary metrics
        run: |
          echo "Monitoring canary metrics for 5 minutes..."
          sleep 300
          # Add metric checking logic

      - name: Full production rollout
        run: |
          echo "Rolling out to 100%..."
          # ./scripts/deploy.sh production --strategy rolling --percentage 100

      - name: Run smoke tests
        run: |
          curl -f https://{your-domain}.com/health || exit 1

      - name: Create release tag
        if: success()
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git tag -a "v$(date +%Y%m%d-%H%M%S)" -m "Production deployment"
          git push origin --tags

      - name: Notify deployment
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Production deployment ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

      - name: Rollback on failure
        if: failure()
        run: |
          echo "Deployment failed, rolling back..."
          # ./scripts/rollback.sh production

  #===========================================================================
  # RELEASE
  #===========================================================================

  create-release:
    name: Create GitHub Release
    runs-on: ubuntu-latest
    needs: [deploy-production]
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: python-package
          path: dist/

      - name: Generate changelog
        id: changelog
        run: |
          # Generate changelog from commits since last tag
          PREVIOUS_TAG=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1) 2>/dev/null || echo "")
          if [ -z "$PREVIOUS_TAG" ]; then
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" --no-merges)
          else
            CHANGELOG=$(git log ${PREVIOUS_TAG}..HEAD --pretty=format:"- %s (%h)" --no-merges)
          fi
          echo "CHANGELOG<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ github.run_number }}
          name: Release v${{ github.run_number }}
          body: |
            ## Changes
            ${{ steps.changelog.outputs.CHANGELOG }}

            ## Deployment
            - Development: ✅ Deployed
            - Staging: ✅ Deployed
            - Production: ✅ Deployed
          files: dist/*
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Configuration Guide

### 1. Secrets Configuration

Add these secrets to your GitHub repository (`Settings → Secrets and variables → Actions`):

```
DOCKER_USERNAME        # Docker Hub username
DOCKER_PASSWORD        # Docker Hub password or token
SLACK_WEBHOOK         # Slack webhook URL for notifications
# Add cloud provider credentials as needed
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
GCP_SERVICE_ACCOUNT_KEY
```

### 2. Environment Setup

Configure environments in GitHub (`Settings → Environments`):

**Development:**
- No approval required
- URL: https://dev.{your-domain}.com

**Staging:**
- Optional: Require approval from team leads
- URL: https://staging.{your-domain}.com

**Production:**
- Required: Approval from 2+ reviewers
- Protection rules: Only from main branch
- URL: https://{your-domain}.com

### 3. Branch Protection

Configure branch protection rules:

**Main branch:**
- Require pull request reviews (2 approvals)
- Require status checks (lint, test, security-scan)
- Require branches to be up to date
- Include administrators

**Develop branch:**
- Require pull request reviews (1 approval)
- Require status checks

### 4. Customization

Replace these placeholders:
- `{Application Name}` - Your app name
- `{image-name}` - Docker image name
- `{your-domain}` - Your domain name
- Update Python/Node versions as needed
- Modify test commands for your framework
- Update deployment scripts paths

## Advanced Features

### Caching Strategy

```yaml
- name: Cache dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.cache/pip
      ~/.npm
      node_modules
    key: ${{ runner.os }}-deps-${{ hashFiles('**/requirements.txt', '**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

### Matrix Testing

Test across multiple configurations:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    python-version: ['3.9', '3.10', '3.11']
    database: [postgresql, mysql, sqlite]
```

### Conditional Jobs

```yaml
deploy-hotfix:
  if: contains(github.event.head_commit.message, '[hotfix]')
  runs-on: ubuntu-latest
  steps:
    - name: Deploy hotfix
      run: ./scripts/deploy-hotfix.sh
```

### Reusable Workflows

Create `.github/workflows/test.yml`:

```yaml
name: Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: true
        type: string
```

Use in main workflow:

```yaml
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      python-version: '3.11'
```

## Best Practices

1. **Use Caching**: Cache dependencies to speed up workflows
2. **Parallel Jobs**: Run independent jobs in parallel
3. **Timeout Limits**: Set reasonable timeouts to avoid hanging
4. **Artifact Management**: Upload build artifacts for debugging
5. **Environment Protection**: Require approvals for production
6. **Security Scanning**: Include security checks in pipeline
7. **Notifications**: Alert team on deployment status
8. **Rollback Strategy**: Implement automatic rollback on failure

## Monitoring & Observability

### Job Status Badges

Add to README.md:

```markdown
![CI/CD](https://github.com/{owner}/{repo}/workflows/{workflow-name}/badge.svg)
```

### Deployment Tracking

Use deployment API for tracking:

```yaml
- name: Create deployment
  uses: chrnorm/deployment-action@v2
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    environment: production
```

## Troubleshooting

### Common Issues

**Issue: Tests failing on specific OS**
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    exclude:
      - os: macos-latest  # Temporarily exclude
```

**Issue: Timeout on long-running tests**
```yaml
timeout-minutes: 30  # Increase timeout
```

**Issue: Insufficient permissions**
```yaml
permissions:
  contents: write
  packages: write
  security-events: write
```

## Related Templates

- `deployment-script-template.md` - Deployment automation
- `docker-compose-template.md` - Container orchestration
- `kubernetes-deployment-template.md` - Kubernetes deployment
