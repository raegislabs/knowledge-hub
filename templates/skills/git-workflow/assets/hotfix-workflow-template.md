# Hotfix Workflow Template

## When to Use Hotfix

### Hotfix Criteria

Use hotfix workflow when:
- ✅ **Production is down or degraded**
- ✅ **Data loss or corruption occurring**
- ✅ **Security vulnerability actively exploited**
- ✅ **Critical business process broken**
- ✅ **Regulatory/compliance issue**

Do NOT use hotfix for:
- ❌ Minor bugs with workarounds
- ❌ Feature requests
- ❌ Performance improvements (unless critical)
- ❌ Cosmetic issues
- ❌ Non-urgent security updates

### Severity Levels

| Severity | Description | Response Time | Approval Required |
|----------|-------------|---------------|-------------------|
| **P0 - Critical** | System down, data loss | Immediate | CTO or on-call lead |
| **P1 - High** | Major feature broken | < 2 hours | Engineering manager |
| **P2 - Medium** | Important but not critical | < 24 hours | Team lead |

---

## Hotfix Workflow

### Step 1: Identify and Assess (5 minutes)

```bash
# Document the issue
# 1. What is broken?
# 2. Who/what is affected?
# 3. When did it start?
# 4. What changed recently?
# 5. What's the business impact?

# Create incident issue
gh issue create \
  --title "HOTFIX: Production login failing with 500 error" \
  --label "hotfix,P0,incident" \
  --body "$(cat <<'EOF'
## Incident Summary
Login endpoint returning 500 errors for all users since 14:30 UTC

## Impact
- All users unable to log in
- ~5,000 users affected
- Business: Unable to process orders

## Timeline
- 14:30 UTC: Error rate spiked to 100%
- 14:32 UTC: First user reports
- 14:35 UTC: Incident declared
- 14:40 UTC: Investigation started

## Probable Cause
Deployed v1.3.0 at 14:25 UTC - likely related

## Immediate Actions
1. Investigate recent deploy
2. Check error logs
3. Prepare rollback if needed
4. Prepare hotfix if cause identified
EOF
)"
```

### Step 2: Immediate Triage (5-10 minutes)

```bash
# Check recent deploys
git log --oneline -10 main

# Check production logs
kubectl logs -f deployment/myapp --tail=100 | grep ERROR

# Check error tracking (Sentry, Rollbar, etc.)
# Look for spike in errors

# Quick diagnosis options:
# Option A: Immediate rollback if cause unknown
# Option B: Quick fix if cause obvious
# Option C: Investigate more if unclear
```

### Step 3A: Emergency Rollback (if needed)

```bash
# Rollback to previous version
kubectl set image deployment/myapp myapp=myapp:1.2.3

# Or use deployment tool
./scripts/deploy-production.sh v1.2.3

# Verify rollback successful
curl https://api.example.com/health

# Document rollback in incident issue
gh issue comment <issue-number> \
  --body "Rolled back to v1.2.3 at $(date -u +%H:%M) UTC. Service restored."

# Then proceed with hotfix on v1.2.3
```

### Step 3B: Create Hotfix Branch (if fix identified)

```bash
# Branch from production tag (NOT main)
git checkout v1.3.0  # Current production version
git checkout -b hotfix/fix-login-500-error

# Alternative: Branch from main if it's the production version
git checkout main
git pull origin main
git checkout -b hotfix/fix-login-500-error
```

### Step 4: Implement Fix (30-60 minutes)

```bash
# Make minimal fix - ONLY fix the critical issue
vim src/auth/login.py

# Example: Fix null pointer exception
# BEFORE:
# user_data = user.preferences.theme  # Crashes if preferences is None

# AFTER:
# user_data = user.preferences.theme if user.preferences else 'default'

# Stage changes
git add src/auth/login.py

# Commit with clear message
git commit -m "hotfix: prevent null pointer in login when user.preferences is None

Fixed null pointer exception when accessing user.preferences.theme
for users without preferences set (new users).

Added null check before accessing theme attribute.

Root cause: Migration didn't backfill preferences for existing users.

Fixes #789
Incident: INC-2024-001"

# Push hotfix branch
git push -u origin hotfix/fix-login-500-error
```

### Step 5: Fast-Track Testing (15-30 minutes)

```bash
# Run critical tests only
pytest tests/test_auth.py -v

# Test the specific failure case
pytest tests/test_auth.py::test_login_without_preferences -v

# Quick smoke test
./scripts/smoke-test.sh

# Deploy to staging for verification
./scripts/deploy-staging.sh hotfix/fix-login-500-error

# Manual verification on staging
curl -X POST https://staging.example.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "test"}'

# Test edge cases manually
# 1. New user without preferences ✅
# 2. Existing user with preferences ✅
# 3. User with null preferences ✅
```

### Step 6: Create Hotfix PR

```bash
# Create PR with hotfix template
gh pr create \
  --title "HOTFIX: Fix login 500 error for users without preferences" \
  --label "hotfix,P0" \
  --base main \
  --body "$(cat <<'EOF'
## HOTFIX - EXPEDITED REVIEW REQUESTED

### Issue
Production login failing with 500 error for users without preferences set.

### Impact
- **Severity**: P0 - Critical
- **Affected**: All new users (~500/day)
- **Duration**: 45 minutes (14:30-15:15 UTC)
- **Business Impact**: Unable to onboard new users

### Root Cause
Null pointer exception in login flow when accessing `user.preferences.theme`
for users without preferences. Migration 0123 didn't backfill preferences
for existing users.

### Fix
Added null check before accessing preferences.theme attribute.
Returns 'default' theme if preferences not set.

### Code Change
```python
# Before
user_data = user.preferences.theme

# After
user_data = user.preferences.theme if user.preferences else 'default'
```

### Testing
- [x] Unit test added for null preferences case
- [x] Existing tests pass
- [x] Manually tested on staging:
  - New user login ✅
  - User with preferences ✅
  - User with null preferences ✅
- [x] Staging deployment successful

### Deployment Plan
1. Merge PR (expedited review)
2. Deploy to production immediately
3. Monitor error rates for 30 minutes
4. Verify new user signups working

### Rollback Plan
Revert to v1.3.0 if any issues (unlikely - minimal change)

### Follow-up Tasks
- [ ] Backfill preferences for all users (INC-2024-001-FIX)
- [ ] Add monitoring for null pointer exceptions
- [ ] Update migration process to prevent similar issues

### Incident
Closes #789
Incident: INC-2024-001

### Approval
Reviewed by: @oncall-lead
Approved for immediate merge and deploy.
EOF
)"
```

### Step 7: Expedited Review and Merge

```bash
# Tag reviewers explicitly
gh pr edit <pr-number> --add-reviewer @oncall-lead,@team-lead

# Request expedited review (in PR or Slack)
# "HOTFIX PR ready - need expedited review for production issue"

# After approval, merge immediately
gh pr merge --squash

# Or if critical and approved verbally
# "Emergency merge approved by @oncall-lead via Slack"
git checkout main
git merge hotfix/fix-login-500-error
git push origin main
```

### Step 8: Create Hotfix Tag and Release

```bash
# Tag hotfix release (patch version bump)
git tag -a v1.3.1 -m "Hotfix v1.3.1

Critical fix for login 500 error affecting new users.

Fixed null pointer exception when accessing user preferences
for users without preferences set.

Incident: INC-2024-001
Severity: P0 - Critical
Affected: All new users (~500/day)
Duration: 45 minutes

Root Cause: Missing null check in login flow
Fix: Added null check before accessing preferences.theme

Follow-up: Backfill preferences for all users (INC-2024-001-FIX)"

# Push tag
git push origin v1.3.1

# Create GitHub release
gh release create v1.3.1 \
  --title "Hotfix v1.3.1" \
  --notes "Critical hotfix for login 500 error affecting new users. See tag message for details."
```

### Step 9: Deploy to Production

```bash
# Build and tag Docker image
docker build -t myapp:1.3.1 .
docker push myapp:1.3.1

# Deploy to production
kubectl set image deployment/myapp myapp=myapp:1.3.1

# Or use deployment script
./scripts/deploy-production.sh v1.3.1

# Verify deployment
kubectl rollout status deployment/myapp

# Smoke test production
curl https://api.example.com/health
```

### Step 10: Verify and Monitor (30-60 minutes)

```bash
# Monitor error rates
# Check Sentry/Rollbar for error rate drop

# Monitor key metrics
# - Login success rate
# - Response times
# - Error rates
# - User signups

# Test production manually
# - New user signup ✅
# - Existing user login ✅
# - Edge cases ✅

# Update incident issue
gh issue comment <issue-number> \
  --body "$(cat <<'EOF'
## Resolution

Hotfix v1.3.1 deployed at 15:45 UTC

### Verification
- Error rate returned to 0%
- Login success rate back to 99.8%
- 10 new user signups successful
- No regression in existing functionality

### Timeline
- 14:30 UTC: Incident detected
- 14:35 UTC: Investigation started
- 14:50 UTC: Root cause identified
- 15:00 UTC: Fix implemented
- 15:15 UTC: Staging testing complete
- 15:30 UTC: PR approved
- 15:40 UTC: Merged and tagged
- 15:45 UTC: Production deployment complete
- 15:50 UTC: Verification complete

**Total duration**: 80 minutes (detection to resolution)

### Follow-up
Tracking in INC-2024-001-FIX:
- Backfill user preferences
- Add monitoring
- Update migration process
EOF
)"

# Close incident issue
gh issue close <issue-number> --comment "Resolved with hotfix v1.3.1"
```

### Step 11: Backport to Development Branch (if needed)

```bash
# Ensure fix is in develop branch (for next release)
git checkout develop
git pull origin develop

# Cherry-pick hotfix commit
git cherry-pick <hotfix-commit-sha>

# Or merge hotfix branch
git merge hotfix/fix-login-500-error

# Push to develop
git push origin develop

# Delete hotfix branch
git branch -d hotfix/fix-login-500-error
git push origin --delete hotfix/fix-login-500-error
```

### Step 12: Post-Incident Review

```bash
# Schedule post-incident review (within 48 hours)
# Document in incident issue

# Key questions:
# 1. What happened?
# 2. Why did it happen?
# 3. How did we detect it?
# 4. How did we respond?
# 5. What went well?
# 6. What could be improved?
# 7. What are the action items?

# Create follow-up tasks
gh issue create \
  --title "Post-Incident: Backfill user preferences" \
  --label "incident-followup,P1" \
  --body "Follow-up from INC-2024-001..."
```

---

## Hotfix Templates

### Hotfix Branch Naming

```bash
hotfix/<version>-<short-description>
hotfix/v1.3.1-fix-login-error
hotfix/v2.0.1-security-patch
hotfix/PROD-123-payment-bug
```

### Hotfix Commit Message

```git
hotfix: <short description>

<Detailed explanation of the fix>

Root cause: <Why did this happen?>
Impact: <Who/what was affected?>
Fix: <What changed?>

Incident: INC-YYYY-NNN
Severity: P0|P1|P2
Fixes #<issue-number>
```

### Hotfix PR Template

```markdown
## HOTFIX - EXPEDITED REVIEW REQUESTED

### Issue
[What is broken in production?]

### Impact
- **Severity**: P0|P1|P2
- **Affected**: [Who/what is impacted?]
- **Duration**: [How long has this been happening?]
- **Business Impact**: [Revenue, users, compliance, etc.]

### Root Cause
[Why did this happen?]

### Fix
[What changed to fix it?]

### Code Change
```[language]
[Show the actual code change]
```

### Testing
- [ ] Tests pass
- [ ] Manually tested on staging
- [ ] Verified fix addresses root cause
- [ ] No regression

### Deployment Plan
[How will this be deployed?]

### Rollback Plan
[How to rollback if issues?]

### Follow-up Tasks
- [ ] [Preventive measure 1]
- [ ] [Preventive measure 2]

### Incident
Closes #[incident-number]
Incident: INC-YYYY-NNN
```

---

## Emergency Procedures

### Production is Down

```bash
# IMMEDIATE ACTIONS (< 5 minutes)

# 1. Declare incident
gh issue create --title "INCIDENT: Production down" --label "incident,P0"

# 2. Notify team
# Slack: "@channel INCIDENT: Production down. War room in #incident-response"

# 3. Triage
# - Is it infrastructure or code?
# - When did it start?
# - What changed?

# 4. Quick decision
# Option A: Rollback (if recent deploy)
kubectl set image deployment/myapp myapp=myapp:1.2.3

# Option B: Scale up (if resource issue)
kubectl scale deployment/myapp --replicas=10

# Option C: Hotfix (if known code issue)
# Follow hotfix workflow above

# 5. Communicate status
# Update status page, Twitter, etc.
```

### Data Loss Detected

```bash
# IMMEDIATE ACTIONS (< 5 minutes)

# 1. STOP - Don't make it worse
# - Disable affected endpoints
# - Stop background jobs
# - Prevent further writes

# 2. Assess scope
# - How much data lost?
# - Can it be recovered?
# - Is data being corrupted?

# 3. Restore if possible
# - From backups
# - From audit logs
# - From replicas

# 4. Prevent recurrence
# - Hotfix the bug
# - Add validation
# - Improve monitoring

# 5. Communicate
# - Notify affected users
# - Document data loss extent
# - Provide recovery timeline
```

### Security Breach

```bash
# IMMEDIATE ACTIONS (< 5 minutes)

# 1. Contain the breach
# - Revoke compromised credentials
# - Block malicious IPs
# - Disable vulnerable endpoints

# 2. Assess impact
# - What data was accessed?
# - What systems compromised?
# - Are attackers still active?

# 3. Apply hotfix
# - Patch vulnerability
# - Deploy immediately
# - Verify fix effective

# 4. Incident response
# - Follow security incident plan
# - Notify security team
# - Document everything
# - Consider legal/compliance

# 5. Communication
# - Internal: Security team, legal
# - External: Affected users (if data breach)
# - Regulatory: If required by law
```

---

## Hotfix Best Practices

### DO

✅ **Keep changes minimal** - Only fix the critical issue
✅ **Test thoroughly** - Even under time pressure
✅ **Document everything** - Timeline, root cause, fix
✅ **Communicate clearly** - Keep stakeholders informed
✅ **Follow up** - Address underlying issues
✅ **Learn and improve** - Post-incident review

### DON'T

❌ **Skip testing** - Hotfix that breaks more things is worse
❌ **Add features** - Hotfix is not the time for improvements
❌ **Rush blindly** - Take time to understand root cause
❌ **Panic** - Stay calm, follow process
❌ **Blame** - Focus on fix first, learn later
❌ **Ignore follow-up** - Prevent recurrence

---

## Hotfix Checklist

### Pre-Hotfix
- [ ] Incident declared and documented
- [ ] Severity assessed (P0/P1/P2)
- [ ] Stakeholders notified
- [ ] Root cause identified
- [ ] Fix approach determined
- [ ] Rollback plan documented

### During Hotfix
- [ ] Hotfix branch created from production tag
- [ ] Minimal fix implemented
- [ ] Tests added/updated
- [ ] Staging testing completed
- [ ] PR created with hotfix template
- [ ] Expedited review obtained
- [ ] Approval documented

### Deployment
- [ ] Version tagged
- [ ] GitHub release created
- [ ] Production deployment completed
- [ ] Smoke tests passed
- [ ] Monitoring shows healthy metrics
- [ ] Fix verified in production

### Post-Hotfix
- [ ] Incident issue updated
- [ ] Stakeholders notified of resolution
- [ ] Hotfix backported to develop
- [ ] Hotfix branch deleted
- [ ] Post-incident review scheduled
- [ ] Follow-up tasks created
- [ ] Documentation updated

---

## Communication Templates

### Incident Declaration

```
@channel INCIDENT DECLARED

**Severity**: P0 - Critical
**Issue**: Production login failing with 500 errors
**Impact**: All users unable to log in (~5,000 affected)
**Started**: 14:30 UTC
**War Room**: #incident-response
**Incident Manager**: @john
**Status Page**: https://status.example.com
```

### Status Update

```
INCIDENT UPDATE (15:00 UTC)

**Status**: Hotfix in progress
**Root Cause**: Null pointer in login flow for new users
**Fix**: Implemented, testing on staging
**ETA**: Deploy by 15:30 UTC
**Next Update**: 15:15 UTC or when deployed
```

### Resolution Notice

```
INCIDENT RESOLVED (15:50 UTC)

**Issue**: Production login 500 errors
**Resolution**: Hotfix v1.3.1 deployed
**Duration**: 80 minutes (14:30-15:50 UTC)
**Impact**: ~500 new users unable to sign up
**Root Cause**: Missing null check in login flow
**Follow-up**: Post-incident review scheduled for tomorrow
**Status**: All systems normal

Thank you for your patience.
```

---

## Tips & Tricks

### Tip 1: Have Runbooks Ready
Prepare runbooks for common incidents ahead of time.

### Tip 2: Practice Hotfixes
Run incident simulations to practice the process.

### Tip 3: Automate Rollback
One-command rollback to previous version.

### Tip 4: Monitor Closely
Watch metrics for 1-2 hours after hotfix.

### Tip 5: Document as You Go
Don't wait until end to document timeline.

### Tip 6: Communicate Often
Over-communicate rather than under-communicate.

### Tip 7: Learn from Every Incident
Post-incident reviews are critical for improvement.

### Tip 8: Keep Team Calm
Panic makes things worse - stay methodical.

### Tip 9: Empower On-Call
On-call engineer should have authority to act quickly.

### Tip 10: Prevention > Response
Invest in preventing incidents (monitoring, testing, etc.).
