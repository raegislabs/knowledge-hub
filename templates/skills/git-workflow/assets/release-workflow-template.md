# Release Workflow Template

## Release Process Overview

### Release Types

| Type | Version Bump | When to Use | Example |
|------|--------------|-------------|---------|
| **Major** | x.0.0 | Breaking changes | 1.0.0 → 2.0.0 |
| **Minor** | 0.x.0 | New features (backward compatible) | 1.2.0 → 1.3.0 |
| **Patch** | 0.0.x | Bug fixes | 1.2.3 → 1.2.4 |
| **Pre-release** | x.y.z-alpha.n | Testing before release | 1.3.0-alpha.1 |

### Semantic Versioning (SemVer)

```
MAJOR.MINOR.PATCH-PRERELEASE+BUILD

Examples:
1.0.0           - Major release
1.2.0           - Minor release (new features)
1.2.3           - Patch release (bug fixes)
2.0.0-alpha.1   - Pre-release (alpha)
2.0.0-beta.2    - Pre-release (beta)
2.0.0-rc.1      - Release candidate
1.0.0+build.123 - Build metadata
```

---

## Standard Release Workflow

### Step 1: Prepare Release Branch

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Create release branch
git checkout -b release/v1.3.0

# Or for patch release from previous version
git checkout v1.2.3
git checkout -b release/v1.2.4
```

### Step 2: Update Version Numbers

**package.json** (Node.js):
```json
{
  "version": "1.3.0"
}
```

**pyproject.toml** (Python):
```toml
[tool.poetry]
version = "1.3.0"
```

**setup.py** (Python):
```python
setup(
    version="1.3.0"
)
```

**VERSION file**:
```
1.3.0
```

**Commit version bump**:
```bash
git add package.json  # or pyproject.toml, setup.py, VERSION
git commit -m "chore(release): bump version to 1.3.0"
```

### Step 3: Generate Changelog

**Automatic (from Conventional Commits)**:
```bash
# Using standard-version
npx standard-version

# Using semantic-release
npx semantic-release

# Manual changelog generation
git log v1.2.0..HEAD --pretty=format:"- %s (%h)" --no-merges > CHANGELOG_DRAFT.md
```

**Manual Changelog Format**:
```markdown
# Changelog

## [1.3.0] - 2024-01-15

### Added
- New user dashboard with customizable widgets (#123)
- Export data to CSV functionality (#145)
- Dark mode theme support (#167)

### Changed
- Improved search performance by 60% (#134)
- Updated authentication flow for better UX (#156)

### Fixed
- Fixed timezone bug in date picker (#178)
- Corrected calculation error in tax module (#189)
- Resolved memory leak in WebSocket connection (#190)

### Deprecated
- Old `/api/v1/users` endpoint (use `/api/v2/users`)

### Security
- Updated dependencies to patch CVE-2024-12345
- Implemented rate limiting on auth endpoints

[1.3.0]: https://github.com/user/repo/compare/v1.2.0...v1.3.0
```

**Commit changelog**:
```bash
git add CHANGELOG.md
git commit -m "docs(changelog): update for v1.3.0 release"
```

### Step 4: Update Documentation

```bash
# Update README version references
vim README.md

# Update API documentation
vim docs/api/README.md

# Update migration guide if breaking changes
vim docs/MIGRATION.md

# Commit documentation updates
git add README.md docs/
git commit -m "docs: update documentation for v1.3.0"
```

### Step 5: Run Release Tests

```bash
# Run full test suite
npm test          # or pytest, cargo test, etc.

# Run integration tests
npm run test:integration

# Run end-to-end tests
npm run test:e2e

# Build and test production bundle
npm run build
npm run test:build

# Security audit
npm audit         # or safety check (Python), cargo audit (Rust)

# License check
npm run license-check
```

### Step 6: Create Release PR

```bash
# Push release branch
git push -u origin release/v1.3.0

# Create PR to main
gh pr create \
  --title "Release v1.3.0" \
  --body "$(cat <<'EOF'
## Release v1.3.0

### Summary
Minor release including new dashboard features, performance improvements, and bug fixes.

### Changes
See [CHANGELOG.md](CHANGELOG.md) for complete list.

**Highlights**:
- New customizable user dashboard
- 60% improvement in search performance
- Dark mode support
- Multiple bug fixes and security updates

### Testing
- [x] All tests pass (unit, integration, e2e)
- [x] Build succeeds
- [x] Security audit clean
- [x] Manual testing completed
- [x] Staging deployment verified

### Deployment Checklist
- [x] Version bumped in all files
- [x] CHANGELOG.md updated
- [x] Documentation updated
- [x] Migration guide created (if needed)
- [x] Release notes drafted
- [ ] Stakeholders notified
- [ ] Staging deployment successful
- [ ] Production deployment planned

### Rollback Plan
If issues found post-deployment:
1. Revert to v1.2.3 using git tag
2. Deploy previous Docker image: `app:1.2.3`
3. Run database rollback: `python manage.py migrate auth 0012`

### Related Issues
Closes #123, #145, #167, #134, #156, #178, #189, #190
EOF
)" \
  --base main
```

### Step 7: Merge and Tag

```bash
# After PR approval, merge to main
gh pr merge --squash --delete-branch

# Switch to main and pull
git checkout main
git pull origin main

# Create annotated tag
git tag -a v1.3.0 -m "Release version 1.3.0

Features:
- Customizable user dashboard
- Dark mode support
- CSV export functionality

Improvements:
- 60% faster search performance
- Enhanced authentication UX

Bug Fixes:
- Fixed timezone handling
- Corrected tax calculations
- Resolved memory leak

See CHANGELOG.md for complete details."

# Push tag
git push origin v1.3.0
```

### Step 8: Create GitHub Release

```bash
# Using GitHub CLI
gh release create v1.3.0 \
  --title "Release v1.3.0" \
  --notes-file RELEASE_NOTES.md \
  --latest

# Or manually:
# 1. Go to https://github.com/user/repo/releases/new
# 2. Select tag: v1.3.0
# 3. Add title: "Release v1.3.0"
# 4. Add description (from CHANGELOG)
# 5. Attach build artifacts if needed
# 6. Mark as latest release
# 7. Publish
```

**RELEASE_NOTES.md** template:
```markdown
# Release v1.3.0

Released on January 15, 2024

## What's New

### 🎨 Customizable Dashboard
Users can now personalize their dashboard with drag-and-drop widgets. Choose from 15+ widget types including analytics, recent activity, and quick actions.

### 🌙 Dark Mode
Toggle between light and dark themes in user settings. System preference detection available.

### 📊 CSV Export
Export your data to CSV format for analysis in spreadsheet applications.

## Improvements

### ⚡ Search Performance
Search is now 60% faster thanks to database index optimization and caching layer.

### 🔐 Enhanced Authentication
Streamlined login flow with better error messages and password recovery.

## Bug Fixes

- Fixed timezone handling in date picker (#178)
- Corrected tax calculation rounding error (#189)
- Resolved WebSocket memory leak (#190)

## Security Updates

- Updated dependencies to patch CVE-2024-12345
- Implemented rate limiting on authentication endpoints

## Upgrade Guide

### For Users
No action required. Upgrade is seamless.

### For API Clients
The old `/api/v1/users` endpoint is now deprecated. Please migrate to `/api/v2/users` before v2.0.0 release.

### For Self-Hosted Installations
```bash
# Backup database
pg_dump mydb > backup_$(date +%Y%m%d).sql

# Update application
git pull
git checkout v1.3.0

# Install dependencies
npm install

# Run migrations
npm run migrate

# Restart application
npm run start
```

## Breaking Changes
None

## Deprecations
- `/api/v1/users` endpoint (use `/api/v2/users`)

## Full Changelog
[View all changes](https://github.com/user/repo/compare/v1.2.0...v1.3.0)

---

**Need help?** Check our [documentation](https://docs.example.com) or [open an issue](https://github.com/user/repo/issues/new).
```

### Step 9: Deploy to Production

```bash
# Tag Docker image
docker build -t myapp:1.3.0 -t myapp:latest .
docker push myapp:1.3.0
docker push myapp:latest

# Or trigger deployment pipeline
# (GitHub Actions, CircleCI, etc.)

# Kubernetes
kubectl set image deployment/myapp myapp=myapp:1.3.0

# Or use deployment script
./scripts/deploy-production.sh v1.3.0
```

### Step 10: Post-Release

```bash
# Update main branch version to next dev version
git checkout main

# Bump to next patch version with -dev suffix
# package.json: "version": "1.3.1-dev"
vim package.json

git add package.json
git commit -m "chore: bump version to 1.3.1-dev"
git push origin main

# Notify stakeholders
# - Send release announcement email
# - Post to Slack/Discord
# - Update status page
# - Tweet release (if public project)

# Monitor for issues
# - Check error tracking (Sentry, Rollbar)
# - Monitor logs
# - Watch support channels
# - Be ready to hotfix if needed
```

---

## Pre-Release Workflow

### Alpha Release (Internal Testing)

```bash
# Create alpha from develop branch
git checkout develop
git tag v1.3.0-alpha.1

# Deploy to alpha environment
./scripts/deploy-alpha.sh v1.3.0-alpha.1

# Announce to internal testers
# "Alpha v1.3.0-alpha.1 ready for testing on alpha.example.com"
```

### Beta Release (Limited External Testing)

```bash
# Create beta from release branch
git checkout release/v1.3.0
git tag v1.3.0-beta.1

# Deploy to beta environment
./scripts/deploy-beta.sh v1.3.0-beta.1

# Create pre-release on GitHub
gh release create v1.3.0-beta.1 \
  --title "Beta v1.3.0-beta.1" \
  --notes "Beta release for testing" \
  --prerelease

# Announce to beta testers
```

### Release Candidate (Final Testing)

```bash
# Create release candidate
git checkout release/v1.3.0
git tag v1.3.0-rc.1

# Deploy to staging (production-like environment)
./scripts/deploy-staging.sh v1.3.0-rc.1

# Create pre-release on GitHub
gh release create v1.3.0-rc.1 \
  --title "Release Candidate v1.3.0-rc.1" \
  --notes "Release candidate - final testing before production" \
  --prerelease

# Full regression testing
# - Automated test suite
# - Manual acceptance testing
# - Performance testing
# - Security testing
# - Load testing

# If issues found, fix and create rc.2, rc.3, etc.
# If no issues, promote to final release
```

### Promote RC to Final Release

```bash
# Tag final release (same commit as RC)
git checkout v1.3.0-rc.1
git tag v1.3.0 -m "Release v1.3.0"
git push origin v1.3.0

# Update RC to final release on GitHub
gh release edit v1.3.0-rc.1 \
  --tag v1.3.0 \
  --title "Release v1.3.0" \
  --latest \
  --prerelease=false
```

---

## Release Automation

### Using semantic-release (Node.js)

```bash
# Install
npm install --save-dev semantic-release

# Configure .releaserc.json
{
  "branches": ["main", "master"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    "@semantic-release/git"
  ]
}

# Run (usually in CI/CD)
npx semantic-release
```

### Using standard-version (Node.js)

```bash
# Install
npm install --save-dev standard-version

# Add script to package.json
"scripts": {
  "release": "standard-version",
  "release:minor": "standard-version --release-as minor",
  "release:major": "standard-version --release-as major"
}

# Run
npm run release          # Auto-determine version from commits
npm run release:minor    # Force minor version
npm run release:major    # Force major version
```

### Using GitHub Actions

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for changelog

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

      - name: Semantic Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx semantic-release
```

---

## Rollback Procedures

### Immediate Rollback (Critical Issues)

```bash
# Option 1: Deploy previous version
kubectl set image deployment/myapp myapp=myapp:1.2.3

# Option 2: Revert to previous tag
git checkout v1.2.3
./scripts/deploy-production.sh v1.2.3

# Option 3: Use load balancer to redirect to previous deployment
# (Blue-Green deployment)
```

### Database Rollback

```bash
# Revert database migrations
python manage.py migrate auth 0012  # Specific migration
./scripts/rollback-db.sh v1.2.3    # Automated rollback script

# Restore from backup if needed
pg_restore -d mydb backup_20240115.sql
```

### Rollback Communication

```bash
# Update status page
# "We've identified an issue with v1.3.0 and rolled back to v1.2.3"

# Notify team
# Slack: "@channel Rolled back to v1.2.3 due to [issue]. Investigating."

# Create hotfix plan
# Document issue, root cause, fix approach
```

---

## Release Checklist

### Pre-Release
- [ ] All features merged to main/develop
- [ ] Version bumped in all files
- [ ] CHANGELOG.md updated
- [ ] Documentation updated
- [ ] Migration guide created (if breaking changes)
- [ ] All tests pass (unit, integration, e2e)
- [ ] Security audit clean
- [ ] Performance benchmarks acceptable
- [ ] Code review completed
- [ ] Staging deployment successful

### Release
- [ ] Release branch created
- [ ] Release PR created and approved
- [ ] Tag created with annotated message
- [ ] GitHub release created
- [ ] Release notes published
- [ ] Build artifacts generated
- [ ] Docker images tagged and pushed

### Deployment
- [ ] Production deployment completed
- [ ] Database migrations successful
- [ ] Smoke tests passed
- [ ] Monitoring shows healthy metrics
- [ ] No error spikes in logs

### Post-Release
- [ ] Stakeholders notified
- [ ] Release announcement published
- [ ] Documentation site updated
- [ ] Support team briefed
- [ ] Next version planned
- [ ] Monitoring established

---

## Tips & Best Practices

### 1. Release on Low-Traffic Days
Schedule releases for Tuesday-Thursday, avoid Fridays and weekends.

### 2. Use Feature Flags
Enable/disable features without redeploying.

### 3. Automate Everything
Use semantic-release or similar for consistent releases.

### 4. Test on Production-Like Environment
Staging should mirror production exactly.

### 5. Have Rollback Plan Ready
Document rollback procedure before releasing.

### 6. Communicate Early and Often
Notify stakeholders before, during, and after release.

### 7. Monitor Closely After Release
Watch metrics for 1-2 hours post-deployment.

### 8. Keep Releases Small
Smaller releases = easier to debug issues.

### 9. Document Everything
Release notes, migration guides, rollback procedures.

### 10. Celebrate Releases
Acknowledge team effort, learn from issues.
