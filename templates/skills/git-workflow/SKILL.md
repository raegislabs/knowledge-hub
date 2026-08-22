# ---
name: git-workflow-templates
description: Comprehensive templates and best practices for git workflows, commits, branches, PRs, releases, and code reviews. Use when managing git operations, creating commits, reviewing code, or preparing releases. Provides workflow templates, best practices references, and complete examples for all git operations.
---

# Git Workflow Templates

## Overview

This skill provides production-ready templates and comprehensive best practices for all git workflow operations. It complements the @git-steward agent by providing standardized formats, workflow patterns, and proven practices for branching, committing, code review, and release management.

**When to use this skill:**
- Creating feature branches and following branching workflows
- Writing conventional commit messages
- Preparing pull requests with comprehensive descriptions
- Managing release processes (major, minor, patch, hotfix)
- Conducting thorough code reviews
- Resolving merge conflicts and choosing merge strategies
- Implementing git workflows (GitHub Flow, Git Flow, Trunk-Based, etc.)

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive workflow documentation.

---

## Available Templates

This skill provides 6 production-ready templates in `assets/`:

### 1. Feature Branch Workflow Template
**File:** `assets/feature-branch-template.md`

Complete feature development workflow including:
- Branch naming conventions (type/ticket-description)
- 8-step workflow (create, work, update, test, PR, review, merge, cleanup)
- Pre-PR checklist (code quality, docs, testing, commits, branch)
- Pull request creation with GitHub CLI
- Common scenarios (wrong branch, mid-work switch, squashing, conflicts)
- Best practices (commit often, keep branches short, rebase for clean history)
- CI/CD integration examples
- Troubleshooting guide

**Use when:** Starting new feature work, preparing branches for PR, or following standard feature development workflow.

**Example usage:**
```bash
# Create feature branch following template
git checkout main
git pull origin main
git checkout -b feature/RAE-123-user-authentication

# Work and commit following template guidance
git commit -m "feat(auth): implement JWT authentication middleware"

# Follow pre-PR checklist before creating PR
# Then create PR using template structure
```

### 2. Commit Message Template
**File:** `assets/commit-message-template.md`

Conventional Commits format with comprehensive examples:
- Complete structure (type, scope, subject, body, footer)
- 12 commit types with descriptions and use cases
- 50+ real-world examples by type (feat, fix, docs, refactor, etc.)
- Scope examples (by layer, feature, module)
- Subject line best practices (imperative mood, length limits)
- Body formatting guidelines with good/bad examples
- Footer best practices (issue references, breaking changes, deprecations)
- Complete examples (simple, standard, complex commits)
- Validation tools (commitlint, pre-commit hooks)
- Common mistakes to avoid

**Use when:** Writing commit messages, setting up commit standards, or training team on conventional commits.

**Example usage:**
```git
feat(auth): implement JWT authentication middleware

Implemented comprehensive JWT authentication system for API security.
Tokens expire after 15 minutes with refresh tokens valid for 7 days.

Features:
- JWT token generation with RS256 algorithm
- Token validation middleware for protected routes
- Refresh token rotation for security
- Comprehensive error responses

Closes RAE-123
Related to RAE-100
```

### 3. Pull Request Template
**File:** `assets/pull-request-template.md`

Comprehensive PR description format with:
- Standard PR structure (Summary, Changes, Testing, Screenshots, Checklist, Related Issues)
- 4 complete PR examples (feature, bug fix, refactoring, documentation)
- PR description checklist (all sections properly filled)
- Review guidelines for authors (self-review, quality checks, testing evidence)
- Code review checklist for reviewers (high-level, code quality, testing, documentation)
- 5 types of review comments (blocking, important, suggestion, question, praise)
- Common issues to check (security, performance, error handling, code quality, testing)
- GitHub PR templates for repository configuration
- Tips and best practices (small PRs, draft PRs, context for reviewers)

**Use when:** Creating pull requests, reviewing code, or establishing PR standards.

**Example usage:**
```markdown
## Summary
Implements JWT-based authentication middleware for the FastAPI application.

## Changes
- **Authentication Utilities** - JWT token generation using RS256
- **Middleware** - FastAPI dependency for route protection
- **Endpoints** - Login, refresh, logout endpoints
- **Tests** - 100% coverage for auth module

## Testing
- [x] Unit tests pass (27/27)
- [x] Integration tests pass (12/12)
- [x] Manual testing completed with Postman

## Checklist
- [x] Tests pass
- [x] Linters pass
- [x] Documentation updated
- [x] Security review completed

## Related Issues
Closes RAE-123
```

### 4. Release Workflow Template
**File:** `assets/release-workflow-template.md`

Complete release process documentation with:
- Semantic versioning (major, minor, patch, pre-release)
- 10-step release workflow (prepare, version, changelog, docs, tests, PR, tag, release, deploy, post-release)
- Pre-release workflow (alpha, beta, RC)
- Release automation (semantic-release, standard-version, GitHub Actions)
- Rollback procedures (immediate rollback, database rollback, communication)
- Release checklist (pre-release, release, deployment, post-release)
- CHANGELOG.md format with examples
- Release notes template
- GitHub release creation
- Tips and best practices

**Use when:** Preparing releases, creating version tags, or establishing release processes.

**Example usage:**
```bash
# Create release branch
git checkout -b release/v1.3.0

# Update version and changelog
vim package.json CHANGELOG.md
git commit -m "chore(release): bump version to 1.3.0"

# Create tag
git tag -a v1.3.0 -m "Release version 1.3.0"

# Create GitHub release
gh release create v1.3.0 --title "Release v1.3.0" --notes-file RELEASE_NOTES.md
```

### 5. Hotfix Workflow Template
**File:** `assets/hotfix-workflow-template.md`

Emergency fix process with:
- Hotfix criteria (when to use vs regular fixes)
- Severity levels (P0-Critical, P1-High, P2-Medium)
- 12-step hotfix workflow (identify, triage, rollback/fix, implement, test, PR, review, tag, deploy, verify, backport, post-incident)
- Emergency procedures (production down, data loss, security breach)
- Hotfix templates (branch naming, commit messages, PR template)
- Communication templates (incident declaration, status updates, resolution notices)
- Best practices (DO: minimal changes, document everything; DON'T: skip testing, panic)
- Hotfix checklist
- Tips for incident response

**Use when:** Handling production incidents, creating emergency fixes, or establishing incident response processes.

**Example usage:**
```bash
# Branch from production tag
git checkout v1.3.0
git checkout -b hotfix/fix-login-500-error

# Implement minimal fix
git commit -m "hotfix: prevent null pointer in login when user.preferences is None"

# Fast-track testing and expedited review
# Tag hotfix release
git tag -a v1.3.1 -m "Hotfix v1.3.1 - Critical login fix"

# Deploy immediately
./scripts/deploy-production.sh v1.3.1
```

### 6. Code Review Checklist Template
**File:** `assets/code-review-checklist-template.md`

Thorough code review guidance with:
- Review process (high-level, code review, testing review, documentation review)
- Detailed review checklist (code quality, correctness, security, performance, testing)
- 5 types of review comments with examples (blocking, important, suggestion, question, praise)
- Code smell identification (complexity, duplication, naming, structure)
- Review anti-patterns to avoid (nitpicker, rewriter, blocker, ghost, late reviewer)
- Response guidelines for authors (good/poor responses, handling disagreements)
- Review timeline expectations
- Tools for code review
- Complete example review demonstrating best practices

**Use when:** Reviewing pull requests, providing feedback, or training team on code review practices.

**Example usage:**
```markdown
## Overall
Nice work on the authentication feature! Code is clean and well-tested.

One security concern to address before merging.

## Critical Issues
🚨 **BLOCKING**: Password comparison vulnerable to timing attack (line 45)
Use secrets.compare_digest() instead of == operator.

## Important Suggestions
⚠️ **IMPORTANT**: Consider more specific error messages (line 67)
Distinguish between expired, invalid, and missing tokens.

## Positive Feedback
✅ **EXCELLENT**: Test coverage is outstanding!
Edge cases, error conditions, and rate limiting all tested.
```

---

## Reference Guides

This skill provides 4 comprehensive reference guides in `references/`:

### 1. Git Branching Strategies
**File:** `references/git-branching-strategies.md`

Systematic comparison of branching strategies:

**5 Major Strategies Covered:**
1. **GitHub Flow** - Simple continuous deployment (main + feature branches)
2. **Git Flow** - Structured releases (main, develop, feature, release, hotfix branches)
3. **GitLab Flow** - Environment-based (main, pre-production, production branches)
4. **Trunk-Based Development** - Continuous integration (main + very short branches)
5. **Release Branching** - Multiple versions (main + long-lived release branches)

**For Each Strategy:**
- Branch structure diagrams
- Complete workflow examples with commands
- Pros and cons
- Best use cases (team size, deployment frequency)
- Real-world examples

**Additional Topics:**
- Strategy comparison table (complexity, release frequency, team size)
- Decision tree for choosing strategy
- Best practices (all strategies)
- Migration between strategies
- Common pitfalls and solutions
- Tools and automation examples

**Use when:** Establishing branching strategy, migrating workflows, or understanding different approaches.

### 2. Commit Best Practices
**File:** `references/commit-best-practices.md`

The art of creating excellent commits:

**Core Concepts:**
- **Atomic Commits** - One logical change per commit (why and how)
- **Commit Messages** - Anatomy of good messages (subject, body, footer)
- **When to Commit** - Frequency, triggers, WIP strategies
- **Testing Before Committing** - Pre-commit checks, automated hooks
- **What to Commit** - Include/exclude guidelines, .gitignore best practices

**Commit History Hygiene:**
- Cleaning up history (squash, reword, reorder)
- Interactive rebase techniques
- Fixup commits
- Amending commits
- Cherry-picking

**Advanced Topics:**
- Common commit patterns (feature, bug fix, refactor, dependency update)
- Advanced techniques (fixup commits, amending, cherry-picking)
- Commit anti-patterns to avoid
- Commit checklist
- Tools and automation (commitlint, Husky, git aliases)

**Use when:** Writing commits, reviewing commit history, or training on commit standards.

### 3. Merge Strategies
**File:** `references/merge-strategies.md`

Comprehensive guide to integrating changes:

**4 Merge Strategies:**
1. **Merge Commit (--no-ff)** - Preserves history, creates merge commit
2. **Squash Merge (--squash)** - Combines commits into one
3. **Rebase** - Linear history, replays commits
4. **Fast-Forward** - Simple pointer move (when possible)

**For Each Strategy:**
- Visual diagrams (before/after)
- Command examples
- Pros and cons
- When to use
- Real-world examples

**Conflict Resolution:**
- Understanding conflicts (when and why)
- Resolution process (identify, resolve, mark, complete)
- Conflict resolution tools (mergetool, vimdiff, etc.)
- Preventing conflicts

**Decision Making:**
- Decision tree for choosing strategy
- By workflow (GitHub Flow, Git Flow, Trunk-Based)
- By team preferences
- Best practices (never rewrite shared history, test after merge, etc.)

**Common Scenarios:**
- Feature branch behind main
- Unwanted merge commit
- Undoing merged features
- Squashing after regular merge

**Use when:** Merging branches, resolving conflicts, or deciding on merge approach.

### 4. Code Review Guidelines
**File:** `references/code-review-guidelines.md`

Professional code review practices:

**Review Process:**
- Timing expectations (24 hours standard, 2 hours hotfixes)
- Review allocation by PR size
- Providing effective feedback (5 types: blocking, important, suggestion, question, praise)
- Writing effective comments (specific, explain why, suggest solution, be kind)

**Receiving Feedback:**
- Good vs poor responses
- Handling disagreements gracefully
- When to escalate
- Healthy escalation paths

**Review Checklist:**
- High-level review (understand problem, verify approach)
- Code quality (correctness, security, performance, maintainability)
- Testing review (coverage, edge cases, test quality)
- Documentation review

**Special Cases:**
- Reviewing hotfixes (faster, focus on critical aspects)
- Reviewing junior developer code (mentorship focus)
- Reviewing senior developer code (still thorough, learn from)

**Best Practices:**
- For reviewers (10 principles: timely, specific, kind, etc.)
- For authors (10 principles: self-review, small PRs, context, etc.)
- Handling disagreements
- Review metrics (healthy vs unhealthy)
- Tools and integrations

**Complete Example Review** demonstrating all best practices

**Use when:** Reviewing code, providing feedback, or establishing code review culture.

---

## Usage Patterns

### Pattern 1: Feature Development (Start to Finish)

**Scenario:** Implementing new user authentication feature

**Process:**
1. Read `git-branching-strategies.md` → Understand team's strategy (e.g., GitHub Flow)
2. Use `feature-branch-template.md` → Create properly named branch
3. Use `commit-best-practices.md` → Write atomic commits with good messages
4. Use `commit-message-template.md` → Format commit messages conventionally
5. Use `merge-strategies.md` → Keep branch updated (rebase or merge)
6. Use `pull-request-template.md` → Create comprehensive PR
7. Use `code-review-checklist-template.md` → Self-review before requesting
8. Use `code-review-guidelines.md` → Respond to reviewer feedback professionally

**Time:** 1-2 weeks for feature development + 1-2 days for review

### Pattern 2: Release Preparation

**Scenario:** Preparing v1.3.0 release with new features and bug fixes

**Process:**
1. Read `release-workflow-template.md` → Understand release process
2. Follow 10-step workflow:
   - Create release branch from main
   - Update version numbers
   - Generate changelog from commits
   - Update documentation
   - Run full test suite
   - Create release PR
   - Tag release
   - Create GitHub release
   - Deploy to production
   - Post-release tasks

**Time:** 2-4 hours for release preparation

### Pattern 3: Emergency Hotfix

**Scenario:** Critical production bug affecting users (P0 incident)

**Process:**
1. Read `hotfix-workflow-template.md` → Emergency procedures
2. Follow 12-step hotfix workflow:
   - Identify and assess (5 minutes)
   - Triage (5-10 minutes)
   - Implement fix (30-60 minutes)
   - Fast-track testing (15-30 minutes)
   - Create hotfix PR with template
   - Expedited review
   - Tag hotfix release
   - Deploy to production
   - Verify and monitor (30-60 minutes)
   - Backport to develop
   - Post-incident review

**Time:** 1-3 hours from incident to resolution

### Pattern 4: Code Review

**Scenario:** Reviewing teammate's pull request

**Process:**
1. Read `code-review-guidelines.md` → Review principles
2. Use `code-review-checklist-template.md` → Systematic review
3. Follow review process:
   - High-level review (understand what/why)
   - Detailed code review (correctness, security, performance)
   - Testing review (coverage, quality)
   - Documentation review
4. Provide feedback using 5 comment types (blocking, important, suggestion, question, praise)
5. Write constructive comments (specific, explain why, suggest solution)

**Time:** 20-40 minutes for standard PR

### Pattern 5: Setting Up Git Workflow

**Scenario:** New project or team adopting git standards

**Process:**
1. Read `git-branching-strategies.md` → Choose strategy
2. Read `commit-best-practices.md` → Establish commit standards
3. Use `commit-message-template.md` → Configure commitlint
4. Use `pull-request-template.md` → Create `.github/PULL_REQUEST_TEMPLATE.md`
5. Use `code-review-checklist-template.md` → Train team on review
6. Use `release-workflow-template.md` → Document release process
7. Use `hotfix-workflow-template.md` → Establish incident response

**Time:** 1 day for setup + ongoing refinement

---

## Integration with @git-steward

This skill is designed to complement the @git-steward agent:

**Agent's Role:**
- Execute git operations based on user requests
- Guide through workflows and decision points
- Apply git hygiene and best practices
- Coordinate with other stewards (tests, docs, specs)

**Skill's Role:**
- Provide standardized templates for consistency
- Offer comprehensive workflow documentation
- Ensure best practices are followed
- Give examples and guidance for all scenarios

**Workflow:**
```markdown
User: "@git-steward, help me prepare this feature for PR"

Agent:
1. Loads git-workflow-templates skill
2. Reads feature-branch-template.md for pre-PR checklist
3. Verifies tests pass, linters pass, docs updated
4. Reads commit-message-template.md to validate commit messages
5. Reads pull-request-template.md for PR structure
6. Creates comprehensive PR using template format
7. Reads code-review-checklist-template.md for self-review guidance
```

---

## Best Practices

### 1. Start with Strategy
Always understand your team's branching strategy before creating branches. Read `git-branching-strategies.md` first.

### 2. Atomic Commits Always
Use `commit-best-practices.md` guidance to keep commits focused. One logical change per commit.

### 3. Conventional Commits
Use `commit-message-template.md` for consistent formatting. Benefits: automated changelogs, clear history.

### 4. Comprehensive PRs
Use `pull-request-template.md` to include all necessary information. Help reviewers understand context.

### 5. Thorough Reviews
Use `code-review-checklist-template.md` systematically. Don't skip steps.

### 6. Professional Feedback
Use `code-review-guidelines.md` for constructive, specific comments. Be kind.

### 7. Proper Merge Strategy
Use `merge-strategies.md` decision tree. Choose based on workflow and situation.

### 8. Document Releases
Use `release-workflow-template.md` for complete documentation. Changelogs, release notes, tags.

### 9. Prepared for Incidents
Use `hotfix-workflow-template.md` before emergencies. Practice the process.

### 10. Continuous Improvement
Adapt templates to your team's needs. Templates are starting points, not rigid rules.

---

## Resources

### assets/
Template files designed to be followed as workflows:

- **feature-branch-template.md** - Complete feature development workflow
- **commit-message-template.md** - Conventional commit format with examples
- **pull-request-template.md** - Comprehensive PR description format
- **release-workflow-template.md** - Complete release process
- **hotfix-workflow-template.md** - Emergency fix process
- **code-review-checklist-template.md** - Thorough review guidance

**Usage:** Follow template steps, adapt to specific situation, customize as needed.

### references/
Comprehensive reference guides for deep understanding:

- **git-branching-strategies.md** - 5 strategies with comparisons, workflows, decision tree
- **commit-best-practices.md** - Atomic commits, message format, history hygiene
- **merge-strategies.md** - 4 strategies with conflict resolution, decision making
- **code-review-guidelines.md** - Professional review practices, feedback types, examples

**Usage:** Read relevant sections to inform decisions and understand best practices.

---

## Examples

### Example 1: Feature Branch to PR

```bash
# Following feature-branch-template.md

# 1. Create branch
git checkout main
git pull origin main
git checkout -b feature/RAE-123-user-dashboard

# 2. Work with atomic commits (commit-best-practices.md)
git add src/dashboard/widget.py
git commit -m "feat(dashboard): add widget framework"

git add src/dashboard/layout.py
git commit -m "feat(dashboard): add responsive layout"

git add tests/test_dashboard.py
git commit -m "test(dashboard): add widget tests"

# 3. Keep updated (merge-strategies.md)
git fetch origin main
git rebase origin/main

# 4. Pre-PR checklist (feature-branch-template.md)
pytest  # Tests pass ✓
black . # Linting pass ✓
# Documentation updated ✓

# 5. Create PR (pull-request-template.md)
gh pr create --title "feat: Customizable user dashboard" \
  --body "## Summary
Implements customizable dashboard with drag-and-drop widgets.

## Changes
- Widget framework with 5 widget types
- Responsive grid layout
- User preferences persistence
- Comprehensive tests (95% coverage)

## Testing
- [x] Unit tests pass (47/47)
- [x] Manual testing completed

## Checklist
- [x] Tests pass
- [x] Linters pass
- [x] Documentation updated

## Related Issues
Closes RAE-123"
```

### Example 2: Hotfix Response

```bash
# Following hotfix-workflow-template.md

# 1. Incident declared: Production login failing (P0)

# 2. Quick diagnosis: null pointer in user.preferences

# 3. Create hotfix branch from production tag
git checkout v1.3.0
git checkout -b hotfix/fix-login-null-pointer

# 4. Minimal fix (commit-message-template.md)
vim src/auth/login.py
git commit -m "hotfix: prevent null pointer in login when user.preferences is None

Fixed null pointer exception when accessing user.preferences.theme
for users without preferences set (new users).

Root cause: Migration didn't backfill preferences.

Fixes #789
Incident: INC-2024-001
Severity: P0"

# 5. Fast-track testing
pytest tests/test_auth.py  # Pass
./scripts/smoke-test.sh    # Pass

# 6. Expedited PR (hotfix-workflow-template.md)
gh pr create --label "hotfix,P0" \
  --title "HOTFIX: Fix login null pointer for new users" \
  --body "[Hotfix PR template content]"

# 7. Tag and deploy
git tag -a v1.3.1 -m "Hotfix v1.3.1 - Critical login fix"
git push origin v1.3.1
./scripts/deploy-production.sh v1.3.1

# 8. Verify resolution
# Error rate: 100% → 0% ✓
# Login success rate: back to 99.8% ✓

# 9. Post-incident review scheduled
```

### Example 3: Code Review

```markdown
# Following code-review-guidelines.md and code-review-checklist-template.md

## Overall (High-Level Review - 5min)
Nice work implementing JWT authentication! The approach is solid and
tests are comprehensive.

I have one security concern (blocking) and a few suggestions for improvement.

---

## Critical Issues (Code Quality Review - 20min)

### src/auth/jwt_utils.py:45
🚨 **BLOCKING**: Password comparison vulnerable to timing attack

Current code:
```python
if user.password_hash == hash_password(input_password):
    return True
```

This allows timing attacks. Use constant-time comparison:
```python
from secrets import compare_digest
if compare_digest(user.password_hash, hash_password(input_password)):
    return True
```

Reference: https://owasp.org/www-community/attacks/Timing_attack

---

## Important Suggestions

### src/auth/middleware.py:67
⚠️ **IMPORTANT**: Error messages could be more specific

Currently returns generic "Unauthorized" for all failures. Consider:
- Token expired → "Token expired. Please refresh."
- Invalid signature → "Invalid authentication token."
- Missing token → "Authentication required."

Helps clients handle errors appropriately.

---

### tests/test_auth.py (Testing Review - 10min)
💡 **SUGGESTION**: Add test for concurrent login attempts

Current tests cover single requests well. Consider adding test for
rapid concurrent attempts to verify rate limiting works correctly.

---

## Positive Feedback

### tests/test_auth.py (overall)
✅ **EXCELLENT**: Test coverage is outstanding!

You've tested:
- ✓ Happy path (valid credentials)
- ✓ Invalid credentials
- ✓ Missing credentials
- ✓ Expired tokens
- ✓ Token refresh flow
- ✓ Rate limiting

This is exactly how authentication should be tested. Great work!

---

## Summary

**Must fix before merge**:
- Password comparison (security vulnerability)

**Strongly recommend**:
- More specific error messages

**Nice to have**:
- Concurrent request test

Overall excellent implementation! Let me know if questions on feedback.
```

---

## Tips & Tricks

### Tip 1: Bookmark Templates
Keep links to frequently used templates (commit-message, pull-request) easily accessible.

### Tip 2: Create Git Aliases
```bash
# ~/.gitconfig
[alias]
  cm = commit -m
  prf = "!gh pr create --fill"  # Use PR template
  rb = rebase -i
```

### Tip 3: Automate Checks
Use pre-commit hooks from `commit-best-practices.md` to enforce standards automatically.

### Tip 4: Template Customization
Adapt templates to your team's specific needs. Add project-specific sections.

### Tip 5: Practice Hotfix
Run through `hotfix-workflow-template.md` in staging environment before real incident.

### Tip 6: Review Together
Pair review for complex PRs using `code-review-checklist-template.md` as guide.

### Tip 7: Document Decisions
When deviating from templates, document why in PR or commit message.

### Tip 8: Progressive Adoption
Start with one template (e.g., commit messages), then add more over time.

### Tip 9: Share Examples
Keep repository of good commit messages, PRs, reviews as team examples.

### Tip 10: Regular Retrospectives
Review git workflow effectiveness monthly. Adjust templates as needed.

---

**Related Skills:**
- None currently (standalone skill)

**Related Agents:**
- @git-steward - Primary consumer of this skill's templates and workflows
- @qa-engineer - Uses code review checklist for test review
- @docs-steward - Uses PR template for documentation changes
