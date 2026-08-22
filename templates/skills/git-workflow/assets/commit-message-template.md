# Commit Message Template

## Conventional Commits Format

### Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Components

**Type** (required): Nature of the change
**Scope** (optional): Area affected (module, component, etc.)
**Subject** (required): Short summary (50 chars or less)
**Body** (optional): Detailed explanation of what and why
**Footer** (optional): Breaking changes, issue references

---

## Type Values

### Primary Types

| Type | Description | When to Use |
|------|-------------|-------------|
| `feat` | New feature | Adding new functionality |
| `fix` | Bug fix | Fixing a bug |
| `docs` | Documentation | README, comments, docstrings only |
| `style` | Formatting | Code style, whitespace, formatting |
| `refactor` | Code improvement | Neither fixes bug nor adds feature |
| `perf` | Performance | Improves performance |
| `test` | Tests | Adding or updating tests |
| `chore` | Maintenance | Build, deps, config, tooling |

### Additional Types

| Type | Description | When to Use |
|------|-------------|-------------|
| `build` | Build system | Webpack, npm, docker, CI/CD |
| `ci` | CI configuration | GitHub Actions, CircleCI, Jenkins |
| `revert` | Revert commit | Reverting previous commit |
| `security` | Security fix | Fixing security vulnerability |
| `deps` | Dependencies | Updating dependencies |
| `config` | Configuration | Changing config files |
| `i18n` | Internationalization | Translations, localization |
| `a11y` | Accessibility | Accessibility improvements |

---

## Examples by Type

### feat (Feature)

```git
feat(auth): implement JWT authentication middleware

- Add JWT token generation and validation
- Implement authentication middleware for FastAPI
- Add token refresh endpoint
- Include comprehensive error handling

Closes RAE-123
```

```git
feat: add user profile page

Users can now view and edit their profile information including
name, email, bio, and avatar. Profile changes are validated on
both client and server side.

Closes RAE-456
```

```git
feat(api): add pagination to user list endpoint

- Support page and limit query parameters
- Return total count in response headers
- Add prev/next links in response body
- Default to 20 items per page

Breaking Change: Response format changed from array to object
Migration: Update clients to use response.data instead of response

Closes RAE-789
```

### fix (Bug Fix)

```git
fix(auth): prevent token refresh infinite loop

Fixed issue where expired tokens would cause infinite refresh
attempts. Now properly handles token expiration and redirects
to login after max retry attempts.

Fixes RAE-234
```

```git
fix: correct calculation of tax amount

Tax calculation was using pre-discount price instead of final
price, causing incorrect tax amounts for discounted items.

Fixes RAE-567
```

```git
fix(db): handle null values in user preferences

Added null checks before accessing user.preferences object to
prevent TypeError when preferences not yet set for new users.

Fixes RAE-890
```

### docs (Documentation)

```git
docs: add API authentication guide

- Document JWT token acquisition process
- Add example requests with curl and Python
- Include common error responses
- Add troubleshooting section
```

```git
docs(readme): update installation instructions

Updated installation section to include Python 3.11 requirement
and added troubleshooting for common M1 Mac issues.
```

```git
docs: fix typo in contributing guide

Changed "seperate" to "separate" in CONTRIBUTING.md
```

### style (Code Style)

```git
style: format code with Black

Ran Black formatter on entire codebase. No functional changes.
```

```git
style(api): fix linting errors

- Remove unused imports
- Fix line length violations
- Add missing trailing commas
```

```git
style: standardize quote usage to double quotes

Changed all single quotes to double quotes for consistency
with project style guide.
```

### refactor (Code Improvement)

```git
refactor(auth): extract validation logic to separate module

Moved JWT validation logic from middleware to auth/validators.py
for better separation of concerns and easier testing.
```

```git
refactor: simplify user service API

- Combine create_user and send_welcome_email into single method
- Remove redundant validation (now handled by models)
- Improve error messages for better debugging
```

```git
refactor(db): replace raw SQL with SQLAlchemy ORM

Converted all raw SQL queries in user repository to use
SQLAlchemy ORM for better type safety and maintainability.
```

### perf (Performance)

```git
perf(db): add index on user email column

Added database index on users.email to improve login query
performance. Reduced average query time from 150ms to 5ms.
```

```git
perf: lazy load user avatars

Changed avatar loading to on-demand instead of eager loading
all avatars. Reduces initial page load by 60%.
```

```git
perf(api): implement response caching

Added Redis caching layer for frequently accessed endpoints.
Cache TTL set to 5 minutes. Reduces database load by 70%.
```

### test (Tests)

```git
test(auth): add integration tests for login flow

- Test successful login with valid credentials
- Test failed login with invalid credentials
- Test account lockout after failed attempts
- Test session expiration
```

```git
test: increase coverage for user service

Added tests for edge cases in user creation, update, and
deletion flows. Coverage increased from 75% to 95%.
```

```git
test(e2e): add Playwright tests for checkout flow

Added end-to-end tests covering complete purchase journey
from cart to payment confirmation.
```

### chore (Maintenance)

```git
chore: update dependencies to latest versions

- fastapi 0.95.0 -> 0.100.0
- pydantic 1.10.7 -> 2.0.0
- pytest 7.3.1 -> 7.4.0

Note: Pydantic 2.0 includes breaking changes, updated code accordingly.
```

```git
chore(ci): add automated dependency updates

Configured Dependabot to check for dependency updates weekly
and create PRs automatically.
```

```git
chore: clean up deprecated feature flags

Removed feature flags for features now fully rolled out:
- NEW_DASHBOARD (launched 6 months ago)
- BETA_SEARCH (launched 3 months ago)
```

---

## Scope Examples

### By Layer/Component

```git
feat(api): add new endpoint
feat(db): add migration
feat(ui): add dashboard component
feat(auth): implement OAuth
feat(email): add welcome template
feat(payment): integrate Stripe
```

### By Feature Area

```git
fix(checkout): handle payment errors
refactor(profile): simplify edit form
test(inventory): add stock tests
docs(analytics): document metrics
```

### By File/Module

```git
style(user-service): fix linting
perf(product-repository): optimize query
refactor(validation-utils): simplify regex
```

---

## Subject Line Best Practices

### ✅ Good Subject Lines

```git
feat: add user authentication
fix: prevent SQL injection in search
docs: update API documentation
refactor: simplify error handling
```

### ❌ Bad Subject Lines

```git
feat: Added user authentication  # Don't use past tense
fix: Fixes bug  # Too vague
docs: Updated docs and fixed some stuff  # Multiple concerns
refactor: refactoring  # Redundant
```

### Rules

1. **Use imperative mood** ("add" not "added" or "adds")
2. **Start with lowercase** (after type and scope)
3. **No period at end**
4. **Keep under 50 characters** (GitHub truncates at 72)
5. **Be specific** ("fix login bug" not "fix bug")

---

## Body Best Practices

### When to Include Body

Include body when:
- Change is non-trivial (more than 10 lines)
- Need to explain WHY not just WHAT
- Multiple related changes in one commit
- Breaking changes or deprecations
- Migration steps needed

### Body Format

```git
<type>(<scope>): <subject>
                           ← Blank line required
<body paragraph 1>
                           ← Blank line between paragraphs
<body paragraph 2>
                           ← Blank line before footer
<footer>
```

### ✅ Good Body Examples

```git
feat(api): add rate limiting to public endpoints

Implemented token bucket rate limiting to prevent API abuse.
Default limits: 100 requests/hour for authenticated users,
10 requests/hour for unauthenticated. Limits configurable
via environment variables.

Rate limit headers included in all responses:
- X-RateLimit-Limit
- X-RateLimit-Remaining
- X-RateLimit-Reset

Closes RAE-123
```

```git
refactor(db): migrate from MongoDB to PostgreSQL

Migrated user and product data from MongoDB to PostgreSQL
for better ACID compliance and relational integrity.

Migration steps performed:
1. Export MongoDB data to JSON
2. Transform to PostgreSQL schema
3. Import via SQLAlchemy bulk operations
4. Verify data integrity
5. Update application code
6. Deploy with feature flag

Breaking Change: Database connection string format changed
Migration: Update DATABASE_URL environment variable

Closes RAE-456
```

### ❌ Bad Body Examples

```git
fix: update code

Fixed some bugs and updated some files.
# Too vague - what bugs? which files?
```

```git
feat: new feature

Added the new feature that was requested.
# Doesn't explain what feature or why needed
```

---

## Footer Best Practices

### Issue References

```git
# Close single issue
Closes RAE-123

# Close multiple issues
Closes RAE-123, RAE-456, RAE-789

# Reference without closing
Related to RAE-100
See RAE-200 for context

# Fix issue (synonym for Closes)
Fixes #123
Resolves #456
```

### Breaking Changes

```git
BREAKING CHANGE: Database schema updated

User.preferences field changed from JSON string to JSONB.
Migration required before deploying this version.

Migration command:
  python manage.py migrate_preferences
```

```git
BREAKING CHANGE: API response format changed

All API responses now wrapped in { data, meta, errors } object.

Before: GET /users returns [{ id: 1, ... }]
After: GET /users returns { data: [{ id: 1, ... }], meta: { ... } }

Migration: Update client code to access response.data
```

### Deprecations

```git
DEPRECATED: User.legacy_id field will be removed in v3.0

Use User.id instead. legacy_id maintained for backward
compatibility until v3.0 release (planned March 2024).
```

### Co-authors

```git
Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>
```

---

## Complete Examples

### Example 1: Simple Feature

```git
feat(search): add autocomplete to search bar

Closes RAE-234
```

### Example 2: Complex Feature

```git
feat(notifications): implement real-time notification system

Added WebSocket-based notification system for real-time updates.
Supports multiple notification types (info, warning, error, success)
with configurable display duration and positioning.

Features:
- WebSocket connection management with auto-reconnect
- Notification queue with priority handling
- User notification preferences (opt-in/out per type)
- Persistence layer for notification history
- Mark as read/unread functionality

Technical details:
- Used Socket.IO for WebSocket implementation
- Redis for pub/sub between server instances
- PostgreSQL for notification history
- React context for client-side state management

Closes RAE-567
Related to RAE-500 (real-time features epic)
```

### Example 3: Bug Fix with Breaking Change

```git
fix(auth): correct token expiration validation

Fixed critical bug where expired tokens were still accepted due
to incorrect timezone handling in validation logic. Token
expiration was being compared in local time instead of UTC.

Security Impact: Medium
Expired tokens could be used for up to 24 hours past expiration
depending on server timezone.

Breaking Change: Token validation now strictly enforces UTC
Migration: Ensure all servers use UTC timezone (already recommended)

Fixes RAE-890
Security Advisory: SA-2024-001
```

### Example 4: Performance Improvement

```git
perf(dashboard): optimize initial data loading

Reduced dashboard load time from 3.5s to 0.8s (77% improvement).

Optimizations:
- Implemented query result caching (Redis, 5min TTL)
- Added database indexes on frequently queried fields
- Replaced N+1 queries with eager loading
- Lazy load non-critical widgets
- Implemented pagination for large datasets

Before: 15 database queries, 3.5s load time
After: 3 database queries (12 from cache), 0.8s load time

Closes RAE-345
```

### Example 5: Refactoring

```git
refactor(api): consolidate error handling

Centralized error handling across all API endpoints for consistency
and reduced code duplication.

Changes:
- Created custom exception hierarchy (APIError, ValidationError, etc.)
- Implemented global error handler middleware
- Standardized error response format
- Added error logging with request context
- Removed 200+ lines of duplicated error handling code

Error Response Format:
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": { field-specific errors },
    "request_id": "uuid"
  }
}

No breaking changes - response format unchanged
```

---

## Quick Reference

### Minimal Commit
```git
feat: add user login
```

### Standard Commit
```git
feat(auth): implement JWT authentication

- Add token generation and validation
- Add refresh token endpoint
- Include error handling

Closes RAE-123
```

### Complete Commit
```git
feat(auth): implement JWT authentication middleware

Implemented comprehensive JWT authentication system for API security.
Tokens expire after 15 minutes with refresh tokens valid for 7 days.
Supports token revocation and blacklisting.

Features:
- JWT token generation with RS256 algorithm
- Token validation middleware for protected routes
- Refresh token rotation for security
- Token blacklist for logout/revocation
- Comprehensive error responses

Technical Details:
- Used PyJWT library for token operations
- Redis for token blacklist storage
- RSA key pair for signing/verification
- Middleware integrated with FastAPI dependency injection

Breaking Change: All protected endpoints now require Authorization header
Migration: Update API clients to include "Bearer <token>" header

Closes RAE-123
Related to RAE-100 (authentication epic)
Security: Implements OWASP JWT best practices
```

---

## Tools & Validation

### Git Hooks (commitlint)

```bash
# Install commitlint
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Configure .commitlintrc.json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [2, "always", [
      "feat", "fix", "docs", "style", "refactor",
      "perf", "test", "chore", "revert"
    ]],
    "subject-case": [2, "always", "lower-case"],
    "subject-max-length": [2, "always", 50],
    "body-max-line-length": [2, "always", 72]
  }
}
```

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/commit-msg

npx commitlint --edit $1
```

### Commit Template

```bash
# Set global commit template
git config --global commit.template ~/.gitmessage

# ~/.gitmessage
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Types: feat, fix, docs, style, refactor, perf, test, chore
# Scope: component/module affected
# Subject: imperative mood, no period, < 50 chars
# Body: explain what and why (optional)
# Footer: Closes #123, BREAKING CHANGE (optional)
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Vague Messages
```git
fix: bug fix
chore: updates
feat: changes
```

### ✅ Correct
```git
fix(login): prevent timeout on slow networks
chore(deps): update FastAPI to 0.100.0
feat(dashboard): add sales chart widget
```

### ❌ Mistake 2: Multiple Concerns
```git
feat: add login page and fix navbar bug and update dependencies
```

### ✅ Correct
```git
# Three separate commits
feat(auth): add login page
fix(nav): correct alignment issue in navbar
chore(deps): update React to 18.2.0
```

### ❌ Mistake 3: Past Tense
```git
feat: added user authentication
fix: fixed bug in login
```

### ✅ Correct
```git
feat: add user authentication
fix: prevent crash in login flow
```

### ❌ Mistake 4: Too Long Subject
```git
feat: add user authentication with JWT tokens and refresh token rotation and email verification
```

### ✅ Correct
```git
feat(auth): add JWT authentication with refresh tokens

Implemented complete authentication system including:
- JWT access tokens (15min expiry)
- Refresh token rotation (7 day expiry)
- Email verification flow
```

---

## Tips & Tricks

### Tip 1: Amend Last Commit Message
```bash
git commit --amend -m "new message"
```

### Tip 2: Interactive Rebase for Multiple Commits
```bash
git rebase -i HEAD~3  # Edit last 3 commits
# Change "pick" to "reword" to edit messages
```

### Tip 3: Use Editor for Long Messages
```bash
git commit  # Opens editor for full message
```

### Tip 4: Reference Multiple Issues
```bash
Closes RAE-123, RAE-456
Related to RAE-789
See RAE-100 for context
```

### Tip 5: Sign Commits
```bash
git commit -S -m "message"  # GPG sign
git config --global commit.gpgsign true  # Auto-sign all commits
```
