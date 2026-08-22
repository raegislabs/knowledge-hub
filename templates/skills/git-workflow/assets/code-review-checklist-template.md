# Code Review Checklist Template

## Purpose of Code Review

Code review ensures:
- **Code Quality** - Readable, maintainable, follows standards
- **Correctness** - Logic is sound, edge cases handled
- **Security** - No vulnerabilities introduced
- **Performance** - No performance regressions
- **Knowledge Sharing** - Team learns from each other
- **Mentorship** - Less experienced developers improve

---

## Review Process

### Step 1: High-Level Review (5 minutes)

```markdown
Read PR description and understand:
- [ ] What problem does this solve?
- [ ] Why is this approach chosen?
- [ ] Are there alternative approaches?
- [ ] Does the solution match the description?
- [ ] Is the scope appropriate (not too large)?
```

### Step 2: Review Changes List (2 minutes)

```markdown
Check files changed:
- [ ] Are all changes necessary?
- [ ] Are there unexpected file changes?
- [ ] Is anything missing (tests, docs)?
- [ ] Should any files be split to separate PRs?
```

### Step 3: Detailed Code Review (20-30 minutes)

```markdown
Review each changed file:
- [ ] Read code top to bottom
- [ ] Understand the logic flow
- [ ] Check for potential bugs
- [ ] Verify error handling
- [ ] Check for security issues
- [ ] Consider performance
- [ ] Assess readability
```

### Step 4: Testing Review (10 minutes)

```markdown
Verify testing:
- [ ] Tests exist for new functionality
- [ ] Tests cover edge cases
- [ ] Tests are well-written
- [ ] CI passes
- [ ] Consider manual testing
```

### Step 5: Documentation Review (5 minutes)

```markdown
Check documentation:
- [ ] Code comments appropriate
- [ ] README updated if needed
- [ ] API docs updated if needed
- [ ] Migration guide if breaking changes
```

---

## Detailed Review Checklist

### Code Quality

#### Readability
- [ ] **Clear naming** - Variables, functions, classes have descriptive names
- [ ] **Consistent style** - Follows project style guide
- [ ] **Appropriate comments** - Explain WHY, not WHAT
- [ ] **Simple logic** - Not overly complex or clever
- [ ] **Proper formatting** - Indentation, spacing, line length

#### Structure
- [ ] **Single Responsibility** - Each function/class has one purpose
- [ ] **DRY Principle** - No unnecessary duplication
- [ ] **Appropriate abstraction** - Not over-engineered or under-engineered
- [ ] **Clear separation of concerns** - Business logic, data access, presentation separated
- [ ] **Consistent patterns** - Follows established patterns in codebase

#### Maintainability
- [ ] **Easy to change** - Future modifications won't require large refactors
- [ ] **No hardcoded values** - Uses constants or configuration
- [ ] **Extensible** - Open for extension, closed for modification
- [ ] **No dead code** - Removed unused functions, variables, imports
- [ ] **Clear dependencies** - Dependencies are explicit and well-managed

---

### Correctness

#### Logic
- [ ] **Correct algorithm** - Algorithm achieves the intended goal
- [ ] **Edge cases handled** - Null values, empty arrays, boundary conditions
- [ ] **Error cases handled** - Invalid input, network failures, timeouts
- [ ] **Concurrency safe** - Thread-safe if multi-threaded (locks, atomic operations)
- [ ] **State management correct** - State transitions are valid

#### Data Handling
- [ ] **Input validation** - All inputs validated before use
- [ ] **Output verification** - Outputs are in expected format
- [ ] **Type safety** - Types are correct (type hints, TypeScript types)
- [ ] **Null/undefined handling** - Checks before accessing properties
- [ ] **Data transformations correct** - Mappings, conversions are accurate

#### Business Logic
- [ ] **Requirements met** - Implements specified requirements
- [ ] **Business rules followed** - Follows domain rules and constraints
- [ ] **Calculations correct** - Math, tax, pricing calculations are accurate
- [ ] **State transitions valid** - Workflow states change correctly
- [ ] **Authorization correct** - Users can only do what they're allowed

---

### Security

#### Input Security
- [ ] **SQL injection prevention** - Uses parameterized queries or ORM
- [ ] **XSS prevention** - User input is sanitized/escaped
- [ ] **Command injection prevention** - No shell execution with user input
- [ ] **Path traversal prevention** - File paths are validated
- [ ] **Input size limits** - Large inputs don't cause DoS

#### Authentication & Authorization
- [ ] **Authentication checked** - Requires authentication where needed
- [ ] **Authorization enforced** - Permission checks before sensitive operations
- [ ] **Session management secure** - Sessions expire, tokens validated
- [ ] **Password handling secure** - Hashed, not logged, minimum requirements
- [ ] **Token security** - JWTs signed, secrets not exposed

#### Data Security
- [ ] **Sensitive data encrypted** - PII, passwords, tokens encrypted at rest
- [ ] **No secrets in code** - API keys, passwords in environment variables
- [ ] **No sensitive data in logs** - Passwords, tokens not logged
- [ ] **HTTPS enforced** - Sensitive data transmitted securely
- [ ] **Data access controlled** - Users can't access others' data

#### Dependencies
- [ ] **No vulnerable dependencies** - npm audit, safety check pass
- [ ] **Dependencies justified** - New dependencies are necessary
- [ ] **Trusted sources** - Dependencies from official registries
- [ ] **License compatible** - Dependency licenses compatible with project

---

### Performance

#### Algorithms & Data Structures
- [ ] **Efficient algorithm** - Appropriate time/space complexity
- [ ] **Appropriate data structures** - Arrays, maps, sets used correctly
- [ ] **No unnecessary iterations** - Loops are necessary and efficient
- [ ] **Lazy evaluation** - Don't compute if not needed
- [ ] **Caching used** - Results cached when appropriate

#### Database
- [ ] **No N+1 queries** - Eager loading or batch queries used
- [ ] **Indexes exist** - Queries on indexed columns
- [ ] **Query optimization** - Queries are efficient (EXPLAIN plan)
- [ ] **Pagination used** - Large result sets are paginated
- [ ] **Connection pooling** - Database connections reused

#### API & Network
- [ ] **Minimize API calls** - Batch or cache when possible
- [ ] **Async operations** - Network I/O is asynchronous
- [ ] **Timeout handling** - Requests have timeouts
- [ ] **Retry logic** - Transient failures are retried
- [ ] **Response compression** - Large responses compressed

#### Frontend
- [ ] **Bundle size reasonable** - No huge dependencies for small features
- [ ] **Code splitting** - Lazy load non-critical code
- [ ] **Image optimization** - Images compressed and appropriately sized
- [ ] **Render optimization** - Avoid unnecessary re-renders
- [ ] **Memory leaks prevented** - Event listeners cleaned up

---

### Testing

#### Test Coverage
- [ ] **Happy path tested** - Normal cases covered
- [ ] **Edge cases tested** - Boundary conditions, empty inputs
- [ ] **Error cases tested** - Invalid inputs, failures handled
- [ ] **Integration tested** - Components work together
- [ ] **Regression tests** - Prevents previously fixed bugs

#### Test Quality
- [ ] **Tests are clear** - Easy to understand what's being tested
- [ ] **Tests are isolated** - Don't depend on other tests
- [ ] **Tests are deterministic** - Same input = same output always
- [ ] **Tests are fast** - Unit tests run in milliseconds
- [ ] **Tests are maintainable** - Easy to update when code changes

#### Test Completeness
- [ ] **All code paths tested** - Branches, conditions covered
- [ ] **Mocks used appropriately** - External dependencies mocked
- [ ] **Assertions meaningful** - Tests verify correct behavior
- [ ] **Test data realistic** - Test cases represent real scenarios
- [ ] **Error messages helpful** - Failures explain what went wrong

---

### Documentation

#### Code Documentation
- [ ] **Complex logic commented** - WHY explained, not WHAT
- [ ] **Function docstrings** - Parameters, return values, exceptions documented
- [ ] **Type hints** - Python type hints, TypeScript types present
- [ ] **Examples provided** - Usage examples for public APIs
- [ ] **TODOs tracked** - No untracked TODOs left in code

#### External Documentation
- [ ] **README updated** - Installation, usage updated if needed
- [ ] **API docs updated** - Endpoints, parameters, responses documented
- [ ] **CHANGELOG updated** - Changes noted for release notes
- [ ] **Migration guide** - Breaking changes have migration steps
- [ ] **Architecture docs updated** - Major changes documented

---

## Review Comment Types

### 1. Blocking Issues 🚨

Issues that **MUST** be fixed before merge:

```markdown
🚨 **BLOCKING**: SQL injection vulnerability

This query is vulnerable to SQL injection:
```python
query = f"SELECT * FROM users WHERE id = {user_id}"
```

Fix:
```python
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```
```

**When to use**:
- Security vulnerabilities
- Critical bugs
- Data loss potential
- Major performance issues

### 2. Important Suggestions ⚠️

Issues that **SHOULD** be addressed:

```markdown
⚠️ **IMPORTANT**: This function is doing too much

`process_order()` is handling validation, payment, inventory, and email.
Consider extracting each concern to separate functions:
- `validate_order()`
- `process_payment()`
- `update_inventory()`
- `send_confirmation_email()`

This will improve testability and maintainability.
```

**When to use**:
- Code quality issues
- Maintainability concerns
- Non-critical bugs
- Design improvements

### 3. Suggestions 💡

Nice-to-have improvements:

```markdown
💡 **SUGGESTION**: Could simplify with list comprehension

Current:
```python
active_users = []
for user in all_users:
    if user.is_active:
        active_users.append(user)
```

Simpler:
```python
active_users = [u for u in all_users if u.is_active]
```

Not required, but more Pythonic.
```

**When to use**:
- Style improvements
- Minor optimizations
- Alternative approaches
- Nitpicks

### 4. Questions ❓

Asking for clarification:

```markdown
❓ **QUESTION**: Why exponential backoff here?

I see you're using exponential backoff with jitter. Is this because
of rate limiting on the external API, or for handling transient failures?

Understanding the reason will help with review.
```

**When to use**:
- Need clarification
- Don't understand approach
- Want to learn reasoning
- Checking if intentional

### 5. Praise ✅

Positive feedback:

```markdown
✅ **NICE**: Excellent error handling!

Love how you're handling all the edge cases here:
- Invalid input → 400 with clear message
- Database failure → 500 with retry logic
- Timeout → 504 with partial results

Very thorough!
```

**When to use**:
- Acknowledge good work
- Reinforce best practices
- Encourage good patterns
- Build team morale

---

## Common Code Smells

### Complexity Smells
- **Long functions** - >50 lines, doing too much
- **Long parameter lists** - >4 parameters
- **Deep nesting** - >3 levels of indentation
- **Complex conditionals** - Multiple AND/OR conditions
- **Switch statements** - Consider polymorphism

### Duplication Smells
- **Copy-pasted code** - Same logic in multiple places
- **Similar functions** - Could be generalized
- **Magic numbers** - Unexplained constants repeated

### Naming Smells
- **Vague names** - `data`, `result`, `temp`, `x`
- **Misleading names** - Name doesn't match behavior
- **Inconsistent naming** - `getUserData` vs `get_user_info`

### Structure Smells
- **God objects** - Class does everything
- **Feature envy** - Method uses another class's data heavily
- **Data clumps** - Same parameters passed together repeatedly
- **Inappropriate intimacy** - Classes too dependent on each other

---

## Review Anti-Patterns to Avoid

### ❌ The Nitpicker
```markdown
"Missing period at end of comment on line 47"
"Could indent 2 spaces instead of 3 here"
```
**Problem**: Wastes time on trivial issues
**Solution**: Use linter for style, focus on logic

### ❌ The Rewriter
```markdown
"I would have written this completely differently.
Here's my 200-line alternative implementation..."
```
**Problem**: Discourages author, derails PR
**Solution**: Suggest only if significantly better

### ❌ The Blocker
```markdown
"BLOCKING: I prefer tabs over spaces"
"MUST FIX: Variable name should be more descriptive"
```
**Problem**: Blocks PRs for non-critical issues
**Solution**: Reserve "blocking" for real issues

### ❌ The Ghost
```markdown
[Reviews PR, doesn't leave any comments, approves]
```
**Problem**: No feedback, no learning
**Solution**: Leave at least 1-2 comments (positive or constructive)

### ❌ The Late Reviewer
```markdown
[PR has 50 comments, weeks old, then adds 100 more comments]
```
**Problem**: Frustrates author after long wait
**Solution**: Review promptly (within 24 hours)

---

## Review Response Guidelines

### For Authors

#### Responding to Comments

**✅ Good Responses**:
```markdown
"Good catch! Fixed in 4f3a9b2"
"Great suggestion! I extracted that to a separate function"
"You're right, I'll add a test for that edge case"
"Interesting point. I chose this approach because... Does that make sense?"
```

**❌ Poor Responses**:
```markdown
"No, I think my way is fine"
"That's not how I learned it"
"Whatever, I'll change it"
[No response, just makes change]
```

#### When You Disagree

```markdown
"I see your point about extracting this function. I kept it inline because:
1. It's only used once
2. Extracting would make the flow harder to follow

However, if you feel strongly, I'm happy to change it. What do you think?"
```

**Key**: Be open to feedback, explain reasoning, be willing to compromise

### For Reviewers

#### Giving Constructive Feedback

**✅ Good Feedback**:
```markdown
"This function is hard to follow because it's handling too many concerns.
Consider extracting the validation logic to `validate_input()` and the
database operations to `save_to_db()`. This will improve testability."
```

**❌ Poor Feedback**:
```markdown
"This function is bad. Refactor it."
```

**Key**: Be specific, explain why, suggest solution

#### Balancing Praise and Critique

```markdown
✅ "Great job handling the edge cases!

One suggestion: the database query might have performance issues with
large datasets. Consider adding pagination. Otherwise looks good!"
```

**Key**: Acknowledge good work, frame suggestions constructively

---

## Review Timeline

### Initial Review
- **Ideal**: Within 24 hours of PR creation
- **Maximum**: Within 48 hours
- **Emergency**: Within 2 hours (hotfixes)

### Re-review After Changes
- **Ideal**: Within 4 hours of updates
- **Maximum**: Within 12 hours

### Final Approval
- **After**: All conversations resolved
- **Verify**: CI passing, tests added, docs updated

---

## Tools for Code Review

### Automated Checks
```yaml
# GitHub Actions example
- name: Automated Checks
  run: |
    npm run lint        # Code style
    npm run type-check  # Type safety
    npm test            # Tests
    npm run security    # Security scan
    npm run coverage    # Code coverage
```

### Review Tools
- **GitHub PR Review** - Built-in review interface
- **GitLab Merge Requests** - Built-in review interface
- **Reviewable** - Enhanced review interface
- **Crucible** - Enterprise code review
- **Gerrit** - Used by large projects (Android, Chrome)

### Browser Extensions
- **Refined GitHub** - Enhances GitHub UI
- **Octotree** - File tree for GitHub
- **GitHub Code Review** - Review helper

---

## Review Checklist Summary

### Before Approving
- [ ] Understand what and why
- [ ] Code is correct and handles edge cases
- [ ] No security vulnerabilities
- [ ] Performance is acceptable
- [ ] Tests are adequate
- [ ] Documentation is updated
- [ ] Style follows project standards
- [ ] All your comments addressed
- [ ] CI passes
- [ ] Author has responded to feedback

### Before Requesting Changes
- [ ] Issue is clearly explained
- [ ] Suggestion is specific
- [ ] Severity is appropriate (blocking vs suggestion)
- [ ] Alternative solution provided (if applicable)
- [ ] Tone is constructive, not critical

---

## Tips for Effective Reviews

### For Reviewers

1. **Review promptly** - Don't leave PRs waiting
2. **Start with positives** - Acknowledge good work
3. **Be specific** - "This is bad" → "This could be improved by..."
4. **Explain why** - Help author learn
5. **Suggest, don't demand** - Unless it's a blocker
6. **Ask questions** - Understand before criticizing
7. **Focus on important issues** - Not nitpicks
8. **Approve generously** - Perfect is enemy of good
9. **Test locally** - For complex changes
10. **Review your own comments** - Before submitting

### For Authors

1. **Self-review first** - Catch obvious issues
2. **Keep PRs small** - <400 lines ideal
3. **Write good descriptions** - Help reviewers understand
4. **Add context** - Explain non-obvious decisions
5. **Respond promptly** - Don't leave reviewers waiting
6. **Be open to feedback** - Reviews help you improve
7. **Ask for clarification** - If feedback unclear
8. **Thank reviewers** - Appreciate their time
9. **Address all comments** - Or explain why not
10. **Update PR description** - As changes are made

---

## Example Review

```markdown
## High-Level

Overall looks good! Nice work implementing the authentication flow.
The code is clean and well-tested.

I have a few suggestions around error handling and a security concern
that should be addressed before merging.

## Detailed Comments

### src/auth/login.py (Line 45)

🚨 **BLOCKING**: Password comparison should use constant-time comparison

Current code:
```python
if user.password == input_password:
```

This is vulnerable to timing attacks. Use:
```python
from secrets import compare_digest
if compare_digest(user.password, input_password):
```

---

### src/auth/middleware.py (Line 67)

⚠️ **IMPORTANT**: Token validation should handle expiration more gracefully

Currently returns generic "Unauthorized" for expired tokens. Consider:
```python
if token.is_expired():
    raise TokenExpiredError("Token expired. Please refresh.")
else:
    raise InvalidTokenError("Invalid token")
```

This helps clients know whether to refresh or re-authenticate.

---

### tests/test_auth.py (Line 120)

💡 **SUGGESTION**: Add test for concurrent login attempts

Current tests cover single login attempts well. Consider adding a test
for rapid concurrent attempts to verify rate limiting works correctly.

---

### docs/api/auth.md

✅ **NICE**: Great documentation!

The examples are really clear and the error response format is well
documented. This will help API consumers a lot.

---

## Summary

- Fix the password comparison (security issue)
- Consider improving token expiration error messages
- Otherwise looks great! 🎉

Excellent work on the comprehensive test coverage. Let me know if you
have questions on any of the feedback.
```

---

**Related Documents**:
- [Feature Branch Workflow](feature-branch-template.md)
- [Pull Request Template](pull-request-template.md)
- [Commit Message Guidelines](commit-message-template.md)
