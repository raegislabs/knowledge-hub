# Pull Request Template

## Standard PR Description Format

```markdown
## Summary
<!-- Brief overview of what this PR does and why -->

## Changes
<!-- Detailed list of changes made -->

## Testing
<!-- How was this tested? What should reviewers test? -->

## Screenshots/Videos
<!-- If UI changes, include before/after screenshots -->

## Checklist
<!-- Mark completed items with [x] -->
- [ ] Tests pass
- [ ] Linters pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented if present)
- [ ] Reviewed my own code

## Related Issues
<!-- Link to related issues/tickets -->
Closes #123
Related to #456
```

---

## Complete PR Template Examples

### Example 1: Feature Implementation

```markdown
## Summary
Implements JWT-based authentication middleware for the FastAPI application. Users can now authenticate using access tokens and refresh tokens, with automatic token rotation for security.

## Changes
- **Authentication Utilities** (`src/auth/jwt_utils.py`)
  - JWT token generation using RS256 algorithm
  - Token validation with expiration checking
  - Refresh token rotation logic

- **Middleware** (`src/auth/middleware.py`)
  - FastAPI dependency for route protection
  - Automatic token extraction from Authorization header
  - Comprehensive error responses for invalid/expired tokens

- **Endpoints** (`src/api/auth.py`)
  - POST `/auth/login` - User login with credentials
  - POST `/auth/refresh` - Refresh access token
  - POST `/auth/logout` - Token revocation

- **Database** (`migrations/001_add_tokens.sql`)
  - Token blacklist table for logout/revocation
  - Indexes for performance

- **Tests** (`tests/test_auth.py`)
  - Unit tests for JWT utilities (100% coverage)
  - Integration tests for protected endpoints
  - Edge case testing (expired tokens, invalid signatures, etc.)

## Testing

### Unit Tests
```bash
pytest tests/test_auth.py -v
# All 27 tests passing
```

### Integration Tests
```bash
pytest tests/integration/test_auth_flow.py -v
# All 12 tests passing
```

### Manual Testing
Tested complete authentication flow with Postman:
1. ✅ Login with valid credentials → Returns access + refresh tokens
2. ✅ Access protected endpoint with token → Success
3. ✅ Access protected endpoint without token → 401 Unauthorized
4. ✅ Access protected endpoint with expired token → 401 Unauthorized
5. ✅ Refresh token → Returns new access token
6. ✅ Logout → Tokens revoked successfully
7. ✅ Attempt to use revoked token → 401 Unauthorized

Postman collection: [Link to collection]

### Performance Testing
- Token generation: ~2ms per token
- Token validation: <1ms per request
- Database queries optimized with indexes

## Screenshots/Videos
N/A - Backend API only, no UI changes

## Checklist
- [x] Tests pass (100% coverage for auth module)
- [x] Linters pass (Black, isort, Pylint all passing)
- [x] Type checking passes (mypy strict mode)
- [x] Documentation updated (API docs, README)
- [x] No breaking changes
- [x] Reviewed my own code
- [x] Security review completed (follows OWASP JWT best practices)
- [x] Migration tested (database migration runs successfully)

## Related Issues
Closes RAE-123
Related to RAE-100 (Authentication Epic)

## Migration Notes
Database migration required before deployment:
```bash
python manage.py migrate
```

## Security Considerations
- Implements OWASP JWT best practices
- RS256 signing algorithm (asymmetric)
- Refresh token rotation prevents token reuse
- Token blacklist for secure logout
- Short access token expiry (15 minutes)

## Deployment Notes
Required environment variables:
- `JWT_PRIVATE_KEY` - RSA private key for signing
- `JWT_PUBLIC_KEY` - RSA public key for verification
- `JWT_ACCESS_TOKEN_EXPIRE_MINUTES` - Default: 15
- `JWT_REFRESH_TOKEN_EXPIRE_DAYS` - Default: 7

## Reviewer Notes
Please pay special attention to:
1. Token validation logic in `jwt_utils.py` (lines 45-78)
2. Error handling in middleware (lines 23-56)
3. Database migration for token blacklist table

## Follow-up Tasks
- [ ] Add rate limiting to auth endpoints (RAE-124)
- [ ] Implement OAuth providers (Google, GitHub) (RAE-125)
- [ ] Add audit logging for authentication events (RAE-126)
```

### Example 2: Bug Fix

```markdown
## Summary
Fixes critical bug where expired JWT tokens were still accepted due to incorrect timezone handling. Token expiration was being compared in local time instead of UTC, allowing expired tokens to be valid for up to 24 hours past expiration.

## Changes
- **JWT Validation** (`src/auth/jwt_utils.py`)
  - Changed expiration check to use UTC consistently
  - Added explicit timezone conversion
  - Added comprehensive logging for debugging

- **Tests** (`tests/test_auth.py`)
  - Added test cases for timezone edge cases
  - Added test for tokens expired in different timezones
  - Increased coverage from 92% to 98%

## Testing

### Reproduction of Bug
```python
# Before fix: This token would be accepted for up to 24 hours past expiry
token_expires_utc = "2024-01-01 12:00:00 UTC"
server_time_pst = "2024-01-01 20:00:00 PST"  # 8 hours later
# Bug: Token still valid because 20:00 PST = 04:00 UTC (next day)
```

### Verification of Fix
```bash
# All timezone tests now passing
pytest tests/test_auth.py::test_token_expiration_timezone -v
pytest tests/test_auth.py::test_expired_token_rejected -v
```

### Manual Testing
1. Created token with 1-minute expiry
2. Waited 2 minutes
3. Attempted to use token → ✅ Correctly rejected
4. Tested on servers in different timezones (UTC, PST, JST) → ✅ All consistent

## Screenshots/Videos
N/A - Backend bug fix

## Checklist
- [x] Tests pass (including new timezone tests)
- [x] Linters pass
- [x] Documentation updated (added timezone note to README)
- [x] No breaking changes
- [x] Reviewed my own code
- [x] Security team notified (medium severity)

## Related Issues
Fixes RAE-890
Security Advisory: SA-2024-001

## Security Impact
**Severity**: Medium
**Impact**: Expired tokens could be used for up to 24 hours past expiration depending on server timezone
**Affected Versions**: 1.0.0 - 1.2.3
**Fixed Version**: 1.2.4

## Migration Notes
No database migration required. Deploy immediately.

## Deployment Priority
**URGENT** - Security fix, should be deployed ASAP

## Reviewer Notes
Please verify:
1. All datetime comparisons now use UTC (grep for `datetime.now()`)
2. Test coverage for timezone edge cases
3. No other timezone-related bugs in codebase
```

### Example 3: Refactoring

```markdown
## Summary
Consolidates error handling across all API endpoints for consistency and maintainability. Removes ~200 lines of duplicated error handling code and implements a standardized error response format.

## Changes
- **Error Classes** (`src/api/errors.py` - NEW)
  - Custom exception hierarchy (APIError, ValidationError, NotFoundError, etc.)
  - Automatic HTTP status code mapping
  - Structured error response format

- **Error Middleware** (`src/api/middleware/error_handler.py` - NEW)
  - Global exception handler for FastAPI
  - Automatic error logging with request context
  - Consistent error response formatting

- **Refactored Endpoints** (20+ files)
  - Replaced try/except blocks with custom exceptions
  - Removed duplicated error response formatting
  - Simplified controller logic

- **Tests** (`tests/test_errors.py` - NEW)
  - Unit tests for error classes
  - Integration tests for error middleware
  - Tests for all error types

## Testing

### Before vs After

**Before** (Inconsistent error responses):
```json
// Some endpoints
{"error": "User not found"}

// Other endpoints
{"message": "Not found", "status": 404}

// Yet others
{"detail": [{"msg": "User not found", "type": "not_found"}]}
```

**After** (Consistent format):
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "details": {},
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

### Test Results
```bash
pytest tests/test_errors.py -v
# All 45 tests passing

pytest tests/integration/ -v
# All 120 integration tests passing (updated for new format)
```

### Metrics
- **Code Reduction**: 1,245 lines → 1,042 lines (-16%)
- **Duplication**: Removed 203 lines of duplicated error handling
- **Consistency**: 100% of endpoints now use same error format
- **Test Coverage**: Error handling coverage 95% → 98%

## Screenshots/Videos
N/A - Backend refactoring only

## Checklist
- [x] Tests pass (all existing + 45 new error tests)
- [x] Linters pass
- [x] Documentation updated (API error responses documented)
- [x] No breaking changes (response format unchanged for successful requests)
- [x] Reviewed my own code
- [x] Performance tested (no measurable overhead from middleware)

## Related Issues
Closes RAE-345
Related to RAE-300 (Code quality improvements epic)

## Breaking Changes
⚠️ **Error response format has changed**

**Impact**: API clients parsing error responses need updates

**Migration Guide**:

Before:
```python
# Client code parsing old format
if response.status_code != 200:
    error_msg = response.json().get("error") or response.json().get("message")
```

After:
```python
# Client code parsing new format
if response.status_code != 200:
    error_data = response.json()["error"]
    error_msg = error_data["message"]
    error_code = error_data["code"]
    request_id = error_data["request_id"]
```

**Timeline**:
- v1.3.0 (this version): New format only
- v1.2.x: Old format (deprecated, critical fixes only)

## Deployment Notes
No special deployment steps required. Recommend deploying with client updates to handle new error format.

## Reviewer Notes
Please review:
1. **Error hierarchy** (`src/api/errors.py`) - Is it comprehensive?
2. **Middleware logic** (`src/api/middleware/error_handler.py`) - Any edge cases missed?
3. **Migration guide** - Clear enough for frontend team?

**Files with most changes**:
- `src/api/users.py` (30 lines removed)
- `src/api/products.py` (25 lines removed)
- `src/api/orders.py` (40 lines removed)

## Performance Impact
Measured error handling overhead:
- Before: ~0.5ms per error response
- After: ~0.6ms per error response
- Overhead: +0.1ms (negligible, <1% of total request time)

## Follow-up Tasks
- [ ] Update frontend to use new error format (RAE-346)
- [ ] Add error code documentation to API docs (RAE-347)
- [ ] Implement error monitoring dashboard (RAE-348)
```

### Example 4: Documentation

```markdown
## Summary
Adds comprehensive API authentication documentation including quick start guide, detailed authentication flow, code examples in multiple languages, and troubleshooting guide.

## Changes
- **New Documentation** (`docs/api/authentication.md`)
  - Quick start guide (5-minute setup)
  - Detailed authentication flow diagrams
  - Code examples (Python, JavaScript, curl)
  - Common error responses
  - Troubleshooting guide
  - Best practices

- **Updated README** (`README.md`)
  - Added link to authentication docs
  - Updated "Getting Started" section

- **API Reference** (`docs/api/reference.md`)
  - Documented all auth endpoints
  - Added request/response examples
  - Added error code reference

## Testing
- [x] All links work (no 404s)
- [x] Code examples tested and verified working
- [x] Diagrams render correctly in GitHub
- [x] Reviewed for clarity with non-technical colleague

## Screenshots/Videos
### Before
![No auth docs](before.png)

### After
![Comprehensive auth guide](after.png)

## Checklist
- [x] Spelling/grammar checked (Grammarly)
- [x] Links validated (markdown-link-check)
- [x] Code examples tested
- [x] Diagrams render correctly
- [x] Reviewed by technical writer

## Related Issues
Closes RAE-567
Related to RAE-123 (Auth implementation)

## Reviewer Notes
Please verify:
1. Code examples are accurate (especially token format)
2. Diagrams are clear and helpful
3. No security anti-patterns in examples
```

---

## PR Description Checklist

### Summary Section
- [ ] Clear one-sentence description
- [ ] Explains WHAT and WHY
- [ ] Readable by non-technical stakeholders

### Changes Section
- [ ] Organized by file or component
- [ ] Includes new, modified, deleted files
- [ ] Notes any architectural changes
- [ ] Highlights important code sections

### Testing Section
- [ ] Unit test results included
- [ ] Integration test results included
- [ ] Manual testing steps documented
- [ ] Performance impact measured (if relevant)

### Screenshots/Videos Section
- [ ] Before/after screenshots for UI changes
- [ ] Videos for complex interactions
- [ ] Annotations if helpful
- [ ] N/A stated if not applicable

### Checklist Section
- [ ] All items relevant to project
- [ ] Honestly marked (not all checked by default)
- [ ] Includes security review if needed
- [ ] Includes performance review if needed

### Related Issues Section
- [ ] Uses proper keywords (Closes, Fixes, Resolves)
- [ ] Links to all related issues
- [ ] References parent epic if applicable

### Additional Sections (when needed)
- [ ] Breaking Changes - Clear migration guide
- [ ] Deployment Notes - Special deployment steps
- [ ] Security Considerations - Security implications
- [ ] Performance Impact - Benchmarks and metrics
- [ ] Migration Notes - Database or config changes
- [ ] Reviewer Notes - Areas needing special attention
- [ ] Follow-up Tasks - Future improvements

---

## Review Guidelines for Authors

### Before Creating PR

1. **Self-Review**
   - [ ] Read your own diff completely
   - [ ] Remove debug code, console.logs, commented code
   - [ ] Check for accidental file inclusions
   - [ ] Verify commit messages follow conventions
   - [ ] Run tests locally one more time

2. **Code Quality**
   - [ ] All tests pass
   - [ ] Linters pass (no warnings)
   - [ ] Type checking passes
   - [ ] Code coverage maintained or improved
   - [ ] No security vulnerabilities (npm audit, safety check)

3. **Documentation**
   - [ ] README updated if needed
   - [ ] API docs updated if endpoints changed
   - [ ] Code comments added for complex logic
   - [ ] CHANGELOG updated (if using)

4. **Testing Evidence**
   - [ ] Test results available (CI or screenshots)
   - [ ] Manual testing completed
   - [ ] Edge cases tested
   - [ ] Error cases tested

### After Creating PR

1. **Initial Review**
   - [ ] Check PR diff on GitHub (different view reveals issues)
   - [ ] Verify CI passes
   - [ ] Add any missed details to description
   - [ ] Assign reviewers
   - [ ] Add labels (if using)

2. **During Review**
   - [ ] Respond to comments promptly
   - [ ] Ask questions if feedback unclear
   - [ ] Make requested changes
   - [ ] Re-request review after changes
   - [ ] Mark conversations as resolved

3. **Before Merging**
   - [ ] All reviewers approved
   - [ ] All CI checks passing
   - [ ] All conversations resolved
   - [ ] Branch up-to-date with base
   - [ ] Final self-review of changes

---

## Code Review Checklist for Reviewers

### Review Process

1. **High-Level Review** (5 minutes)
   - [ ] Read PR description completely
   - [ ] Understand the why (business need)
   - [ ] Review changed files list
   - [ ] Check overall approach makes sense

2. **Code Review** (20-30 minutes)
   - [ ] Read code changes in detail
   - [ ] Check for logic errors
   - [ ] Verify error handling
   - [ ] Check for security issues
   - [ ] Verify tests are adequate
   - [ ] Check performance implications
   - [ ] Look for code duplication
   - [ ] Verify naming conventions

3. **Testing Review** (10 minutes)
   - [ ] Verify tests cover main scenarios
   - [ ] Check edge cases tested
   - [ ] Review test quality (clear, maintainable)
   - [ ] Verify CI results
   - [ ] Consider manual testing if needed

4. **Documentation Review** (5 minutes)
   - [ ] Code comments appropriate
   - [ ] README updated if needed
   - [ ] API docs updated if needed
   - [ ] Migration notes clear

### Review Comments

**Types of Comments**:

1. **Blocking** - Must be addressed before merge
   ```markdown
   🚨 **BLOCKING**: This SQL query is vulnerable to injection.
   Must use parameterized queries.
   ```

2. **Important** - Should be addressed, but negotiable
   ```markdown
   ⚠️ **IMPORTANT**: This function is doing too much.
   Consider extracting validation logic to separate function.
   ```

3. **Suggestion** - Nice to have, optional
   ```markdown
   💡 **SUGGESTION**: Could simplify this with a list comprehension:
   `users = [u for u in all_users if u.active]`
   ```

4. **Question** - Asking for clarification
   ```markdown
   ❓ **QUESTION**: Why are we using exponential backoff here?
   Is this a new requirement or addressing specific issue?
   ```

5. **Praise** - Positive feedback
   ```markdown
   ✅ **NICE**: Great error handling here! Very thorough.
   ```

### Common Issues to Check

**Security**:
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets or keys
- [ ] Input validation present
- [ ] Authentication/authorization correct

**Performance**:
- [ ] No N+1 database queries
- [ ] Appropriate use of indexes
- [ ] No unnecessary loops
- [ ] Caching used where appropriate
- [ ] Large datasets handled efficiently

**Error Handling**:
- [ ] All errors caught and handled
- [ ] Errors logged appropriately
- [ ] User-friendly error messages
- [ ] No silent failures
- [ ] Edge cases considered

**Code Quality**:
- [ ] DRY principle followed
- [ ] Functions are focused (single responsibility)
- [ ] Clear variable/function names
- [ ] Appropriate comments
- [ ] No dead code
- [ ] Consistent style

**Testing**:
- [ ] Tests exist for new functionality
- [ ] Tests are clear and maintainable
- [ ] Edge cases tested
- [ ] Error cases tested
- [ ] Tests are deterministic (no flaky tests)

---

## PR Templates for GitHub

### Configure Repository Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary
<!-- Brief overview of changes -->

## Changes
<!-- Detailed list of changes -->
-
-

## Testing
<!-- How was this tested? -->
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots
<!-- If UI changes, add screenshots -->

## Checklist
- [ ] Tests pass
- [ ] Linters pass
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Reviewed my own code

## Related Issues
<!-- Link related issues -->
Closes #
```

### Multiple Templates

Create `.github/PULL_REQUEST_TEMPLATE/` directory:

**feature.md**:
```markdown
## Feature Summary
<!-- What feature does this add? -->

## User Benefit
<!-- How does this help users? -->

## Implementation
<!-- Technical details -->

## Testing
<!-- Test coverage -->

## Screenshots
<!-- UI changes -->
```

**bugfix.md**:
```markdown
## Bug Description
<!-- What was broken? -->

## Root Cause
<!-- Why was it broken? -->

## Fix
<!-- How is it fixed? -->

## Testing
<!-- How verified? -->

## Reproduction
<!-- Steps to reproduce original bug -->
```

**hotfix.md**:
```markdown
## Issue
<!-- Critical issue being fixed -->

## Impact
<!-- Who/what is affected? -->

## Fix
<!-- What changed? -->

## Verification
<!-- How verified in production? -->

## Rollback Plan
<!-- If fix fails, how to rollback? -->
```

Use with query parameter:
```
https://github.com/user/repo/compare/main...branch?template=bugfix.md
```

---

## Tips & Best Practices

### Tip 1: Write PR Description Before Coding
Writing the PR description first clarifies what you're building and why.

### Tip 2: Keep PRs Small
- Aim for <400 lines changed
- Easier to review
- Faster to merge
- Less risky

### Tip 3: Use Draft PRs
Mark as draft while working, convert to ready when complete.

### Tip 4: Link Issues Early
Link issues immediately so they show up in issue timeline.

### Tip 5: Update PR as You Go
Add notes about decisions made during implementation.

### Tip 6: Add Context for Reviewers
Help reviewers focus on important areas.

### Tip 7: Include Performance Numbers
If performance-related, include before/after benchmarks.

### Tip 8: Document Breaking Changes Clearly
Include migration guide with examples.

### Tip 9: Use GitHub Keywords
`Closes`, `Fixes`, `Resolves` auto-close issues on merge.

### Tip 10: Respond to All Comments
Even if just acknowledging receipt.
