# Git Branching Strategies

## Overview

A branching strategy defines how your team uses git branches to organize work, releases, and collaboration. The right strategy depends on your team size, release frequency, and deployment process.

---

## Strategy Comparison

| Strategy | Best For | Complexity | Release Frequency | Team Size |
|----------|----------|------------|-------------------|-----------|
| **GitHub Flow** | Continuous deployment | Low | Continuous | Small-Medium |
| **Git Flow** | Scheduled releases | High | Periodic (weeks/months) | Medium-Large |
| **GitLab Flow** | Environment-based deployment | Medium | Flexible | Medium |
| **Trunk-Based** | Rapid iteration | Low | Continuous/Daily | Any (with discipline) |
| **Release Branching** | Version maintenance | Medium | Multiple versions | Medium-Large |

---

## 1. GitHub Flow

### Overview
Simple, lightweight strategy focused on continuous deployment. Main branch is always deployable.

### Branch Structure
```
main (production)
  └── feature/add-login
  └── fix/payment-bug
  └── feature/dashboard
```

### Workflow

```bash
# 1. Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/add-user-dashboard

# 2. Work on feature, commit regularly
git add .
git commit -m "feat: add dashboard widget framework"
git push -u origin feature/add-user-dashboard

# 3. Create Pull Request to main
gh pr create --base main

# 4. After review and CI passes, merge to main
gh pr merge --squash

# 5. Deploy main to production
# (Automatic via CI/CD)
```

### Key Principles
- **Main is always deployable** - Every commit to main goes to production
- **Short-lived branches** - Feature branches last hours/days, not weeks
- **Deploy frequently** - Multiple deploys per day
- **CI/CD required** - Automated testing and deployment critical

### Pros
✅ Simple and easy to understand
✅ Fast feedback loop
✅ Encourages small, incremental changes
✅ Minimal overhead

### Cons
❌ No staging between develop and production
❌ Difficult for scheduled releases
❌ Hotfixes need discipline
❌ Requires mature CI/CD pipeline

### Best For
- SaaS applications with continuous deployment
- Internal tools
- Projects with single production environment
- Teams that can deploy frequently

---

## 2. Git Flow

### Overview
Structured strategy with multiple long-lived branches for development, releases, and production.

### Branch Structure
```
master (production)
  └── hotfix/critical-bug
develop (integration)
  └── feature/add-login
  └── feature/dashboard
  └── release/v1.2.0
```

### Branch Types

**Long-Lived Branches**:
- `master` - Production-ready code (tagged with versions)
- `develop` - Integration branch for next release

**Short-Lived Branches**:
- `feature/*` - New features (branch from `develop`)
- `release/*` - Release preparation (branch from `develop`)
- `hotfix/*` - Emergency production fixes (branch from `master`)

### Workflow

#### Feature Development
```bash
# Branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/add-dashboard

# Work and commit
git commit -m "feat: add dashboard component"

# Merge back to develop
git checkout develop
git merge --no-ff feature/add-dashboard
git push origin develop
```

#### Release Process
```bash
# Create release branch from develop
git checkout develop
git checkout -b release/v1.2.0

# Finalize version (bump version, update changelog)
vim package.json CHANGELOG.md
git commit -m "chore: bump version to 1.2.0"

# Merge to master and tag
git checkout master
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"

# Merge back to develop
git checkout develop
git merge --no-ff release/v1.2.0

# Delete release branch
git branch -d release/v1.2.0
```

#### Hotfix Process
```bash
# Branch from master
git checkout master
git checkout -b hotfix/critical-login-bug

# Fix bug
git commit -m "hotfix: fix null pointer in login"

# Merge to master and tag
git checkout master
git merge --no-ff hotfix/critical-login-bug
git tag -a v1.2.1 -m "Hotfix v1.2.1"

# Merge to develop
git checkout develop
git merge --no-ff hotfix/critical-login-bug

# Delete hotfix branch
git branch -d hotfix/critical-login-bug
```

### Pros
✅ Clear separation of concerns
✅ Supports multiple releases in parallel
✅ Well-documented and widely adopted
✅ Good for scheduled releases

### Cons
❌ Complex with many branches
❌ Merge overhead (multiple merges for hotfixes)
❌ Not suitable for continuous deployment
❌ Can become confusing for large teams

### Best For
- Scheduled releases (weekly, monthly, quarterly)
- Software with multiple versions (desktop apps, mobile apps)
- Teams needing clear release process
- Projects with long release cycles

---

## 3. GitLab Flow

### Overview
Combines simplicity of GitHub Flow with environment-based deployment branches.

### Branch Structure
```
main (development)
  └── feature/add-login
  └── feature/dashboard
pre-production (staging)
production (production)
```

### Workflow

```bash
# 1. Feature development (same as GitHub Flow)
git checkout main
git checkout -b feature/add-dashboard
git commit -m "feat: add dashboard"
gh pr create --base main

# 2. Merge to main (triggers deploy to dev environment)
gh pr merge --squash

# 3. Promote to pre-production
git checkout pre-production
git merge main
git push origin pre-production
# (Triggers deploy to staging)

# 4. Test on staging, then promote to production
git checkout production
git merge pre-production
git push origin production
# (Triggers deploy to production)
```

### Environment Branches
- `main` → Development environment
- `pre-production` → Staging environment
- `production` → Production environment

### Hotfix Process
```bash
# Create from production branch
git checkout production
git checkout -b hotfix/critical-bug
git commit -m "hotfix: fix critical bug"

# Merge to production
git checkout production
git merge hotfix/critical-bug
git push origin production

# Merge back to pre-production and main
git checkout pre-production
git merge production

git checkout main
git merge pre-production
```

### Pros
✅ Simple like GitHub Flow
✅ Clear environment promotion path
✅ Suitable for continuous deployment with staging
✅ Easy to understand

### Cons
❌ Can have merge conflicts when promoting
❌ Hotfixes need to be merged to multiple branches
❌ Requires discipline to not skip environments

### Best For
- Applications with multiple environments (dev, staging, prod)
- Teams doing continuous deployment with staging
- Organizations requiring approval gates between environments

---

## 4. Trunk-Based Development

### Overview
Everyone commits to a single branch (trunk/main), with very short-lived feature branches (< 1 day) or direct commits.

### Branch Structure
```
main (trunk)
  └── (optional) feature/small-change  # Lives < 1 day
```

### Workflow

**Option 1: Feature Flags**
```bash
# Commit directly to main
git checkout main
git pull origin main

# Work on feature (hidden behind flag)
vim src/feature.py
git commit -m "feat: add dashboard (behind FEATURE_DASHBOARD flag)"
git push origin main

# Feature goes to production but is disabled
# Enable when ready via configuration
```

**Option 2: Very Short Branches**
```bash
# Small feature branch
git checkout main
git checkout -b add-button

# 2-3 commits, < 4 hours of work
git commit -m "feat: add dashboard button"

# Merge same day
git checkout main
git merge add-button
git push origin main
```

### Key Practices
- **Feature flags** - Hide incomplete features in production
- **Small commits** - Commit frequently (multiple times per day)
- **Automated testing** - Comprehensive CI required
- **Pair programming** - Code review happens during development
- **Continuous integration** - Every commit tested

### Pros
✅ Simplest possible branching model
✅ Reduces merge conflicts
✅ Encourages small, incremental changes
✅ Fast feedback

### Cons
❌ Requires mature engineering practices
❌ Feature flags add complexity
❌ Incomplete features in production (hidden)
❌ Requires excellent automated testing

### Best For
- High-performing teams
- Organizations practicing continuous delivery
- Teams comfortable with feature flags
- Projects where main is always releasable

---

## 5. Release Branching

### Overview
Long-lived release branches for maintaining multiple versions simultaneously.

### Branch Structure
```
main (development)
  └── feature/new-feature
release/v1.0 (maintained)
release/v1.1 (maintained)
release/v2.0 (current)
```

### Workflow

```bash
# Create release branch when feature complete
git checkout main
git checkout -b release/v2.0

# Finalize release
vim VERSION CHANGELOG.md
git commit -m "chore: prepare v2.0 release"
git tag v2.0.0

# Bug fixes go to release branch
git checkout release/v2.0
git checkout -b fix/critical-bug
git commit -m "fix: critical bug"
git checkout release/v2.0
git merge fix/critical-bug
git tag v2.0.1

# Cherry-pick important fixes to older releases
git checkout release/v1.1
git cherry-pick <commit-hash>
git tag v1.1.5
```

### Pros
✅ Supports multiple active versions
✅ Can provide patches to older versions
✅ Clear version history
✅ Good for enterprise software

### Cons
❌ Complexity of maintaining multiple branches
❌ Cherry-picking fixes can be error-prone
❌ Resource intensive (multiple versions to test)

### Best For
- Enterprise software with SLAs
- Products with customers on different versions
- Long-term support (LTS) releases
- Desktop/mobile apps with slow update adoption

---

## Choosing a Strategy

### Decision Tree

```
Do you deploy continuously (multiple times per day)?
├─ YES → GitHub Flow or Trunk-Based Development
│   └─ Do you need staging environment?
│       ├─ YES → GitLab Flow
│       └─ NO → GitHub Flow
│
└─ NO → Scheduled releases?
    ├─ YES → Git Flow or Release Branching
    │   └─ Multiple versions in production?
    │       ├─ YES → Release Branching
    │       └─ NO → Git Flow
    │
    └─ FLEXIBLE → GitLab Flow
```

### By Team Size

**Small Team (1-5 developers)**:
- **Best**: GitHub Flow
- **Alternative**: Trunk-Based Development
- **Reason**: Simplicity, minimal overhead

**Medium Team (5-20 developers)**:
- **Best**: GitLab Flow or GitHub Flow
- **Alternative**: Git Flow (if scheduled releases)
- **Reason**: Balance between structure and simplicity

**Large Team (20+ developers)**:
- **Best**: Trunk-Based Development (if mature) or Git Flow
- **Alternative**: Release Branching (if multiple versions)
- **Reason**: Need clear process, potentially multiple versions

### By Deployment Frequency

**Continuous (Multiple per day)**:
- GitHub Flow, Trunk-Based Development

**Daily**:
- GitLab Flow, GitHub Flow

**Weekly/Sprint-based**:
- Git Flow, GitLab Flow

**Monthly/Quarterly**:
- Git Flow, Release Branching

---

## Best Practices (All Strategies)

### 1. Keep Main Stable
- Main/master branch should always be deployable
- Run CI on every commit
- Require PR review before merging
- Automated tests must pass

### 2. Small, Frequent Merges
- Keep feature branches short-lived (< 1 week)
- Merge to main frequently
- Reduces merge conflicts
- Faster feedback

### 3. Clear Branch Naming
```bash
# Good
feature/RAE-123-user-authentication
fix/login-timeout-error
hotfix/payment-critical-bug

# Bad
my-branch
fixes
temp
johns-work
```

### 4. Protect Important Branches
```bash
# GitHub branch protection rules
- Require pull request before merging
- Require status checks to pass
- Require conversation resolution
- Restrict who can push
```

### 5. Automate Everything
- Automated tests on every PR
- Automated deployment on merge
- Automated version bumping
- Automated changelog generation

### 6. Document Your Strategy
```markdown
# CONTRIBUTING.md

## Branching Strategy

We use GitHub Flow:
1. Branch from `main` for all changes
2. Name branches: `type/description`
3. Create PR when ready
4. Merge after approval and CI passes
5. `main` automatically deploys to production
```

---

## Migration Between Strategies

### From No Strategy → GitHub Flow

```bash
# 1. Clean up branches
git branch | grep -v "main" | xargs git branch -D

# 2. Update documentation
echo "We use GitHub Flow. See CONTRIBUTING.md" > BRANCHING.md

# 3. Set up branch protection on main
# (Via GitHub settings)

# 4. Set up CI/CD
# (GitHub Actions, etc.)
```

### From GitHub Flow → Git Flow

```bash
# 1. Create develop branch from main
git checkout main
git checkout -b develop
git push -u origin develop

# 2. Update branch protection (protect main and develop)

# 3. Update documentation
# "We now use Git Flow..."

# 4. Train team on new workflow
```

### From Git Flow → Trunk-Based

```bash
# 1. Merge all feature branches to main
git checkout main
git merge develop

# 2. Delete develop branch
git branch -D develop
git push origin --delete develop

# 3. Set up feature flags

# 4. Update CI/CD for continuous deployment

# 5. Train team on new practices
```

---

## Common Pitfalls

### 1. Long-Lived Feature Branches
**Problem**: Branches live for weeks, causing merge hell

**Solution**: Break features into smaller pieces, merge frequently

### 2. Skipping Code Review
**Problem**: Direct commits to main without review

**Solution**: Branch protection rules, require PR approval

### 3. Inconsistent Naming
**Problem**: Branches named randomly

**Solution**: Documented naming convention, enforce with CI

### 4. Merging Without Testing
**Problem**: Broken code in main

**Solution**: Require CI to pass before merging

### 5. No Clear Strategy
**Problem**: Team doesn't know which branch to use

**Solution**: Document strategy, train team, enforce with tooling

---

## Tools & Automation

### Branch Protection (GitHub)
```yaml
# .github/branch-protection.yml (conceptual)
main:
  required_pull_request:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
  required_status_checks:
    - ci/tests
    - ci/linting
  restrictions:
    users: []
    teams: ['core-team']
```

### Automated Branching (Git Hooks)
```bash
# .git/hooks/post-checkout
#!/bin/bash
# Automatically name branches with ticket ID

BRANCH_NAME=$(git symbolic-ref --short HEAD)
if [[ ! $BRANCH_NAME =~ ^(feature|fix|hotfix)/ ]]; then
  echo "Branch name must start with feature/, fix/, or hotfix/"
  exit 1
fi
```

### CI/CD Integration (GitHub Actions)
```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:
    branches: [main, develop]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      - run: npm run lint
```

---

## Summary

| Strategy | Complexity | Best For | Key Benefit |
|----------|-----------|----------|-------------|
| **GitHub Flow** | ⭐ | Continuous deployment | Simplicity |
| **Git Flow** | ⭐⭐⭐ | Scheduled releases | Structure |
| **GitLab Flow** | ⭐⭐ | Environment-based deployment | Environment control |
| **Trunk-Based** | ⭐ | High-performing teams | Speed |
| **Release Branching** | ⭐⭐⭐ | Multiple versions | Version support |

**Recommendation**: Start simple (GitHub Flow), add complexity only when needed.
