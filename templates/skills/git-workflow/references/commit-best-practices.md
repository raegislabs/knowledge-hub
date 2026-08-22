# Commit Best Practices

## The Art of Good Commits

Good commits are:
- **Atomic** - One logical change per commit
- **Complete** - Include all related changes
- **Tested** - Tests pass after the commit
- **Documented** - Clear message explaining what and why
- **Reversible** - Can be reverted without breaking things

---

## Atomic Commits

### What is an Atomic Commit?

An atomic commit contains **one logical change** and nothing more.

**✅ Good (Atomic)**:
```bash
# Commit 1: Add user model
git commit -m "feat(models): add User model with authentication fields"

# Commit 2: Add user repository
git commit -m "feat(db): add UserRepository for database operations"

# Commit 3: Add user service
git commit -m "feat(services): add UserService for business logic"
```

**❌ Bad (Not Atomic)**:
```bash
# One huge commit with everything
git commit -m "Add user feature

- Added User model
- Added UserRepository
- Added UserService
- Fixed bug in login
- Updated dependencies
- Reformatted files"
```

### Why Atomic Commits Matter

**Benefits**:
1. **Easier to review** - Small, focused changes
2. **Easier to revert** - Can undo specific changes
3. **Easier to debug** - `git bisect` works better
4. **Better history** - Clear progression of changes
5. **Easier to cherry-pick** - Port specific changes

**Example: Debugging with Bisect**:
```bash
# Find which commit introduced bug
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Git will binary search through commits
# Atomic commits make it easy to identify the exact change
```

### How to Keep Commits Atomic

**During Development**:
```bash
# Stage changes selectively
git add src/models/user.py        # Only user model
git commit -m "feat: add User model"

git add src/repositories/user.py  # Only repository
git commit -m "feat: add UserRepository"

# Don't use git add . unless you're sure
```

**Interactive Staging**:
```bash
# Stage partial file changes
git add -p src/auth/login.py

# Git will show hunks, press:
# y - stage this hunk
# n - don't stage this hunk
# s - split into smaller hunks
# e - manually edit hunk
```

**Splitting Existing Commits**:
```bash
# Split last commit into multiple
git reset HEAD~1

# Stage and commit parts separately
git add src/models/user.py
git commit -m "feat: add User model"

git add src/repositories/user.py
git commit -m "feat: add UserRepository"
```

---

## Commit Messages

### Anatomy of a Good Commit Message

```
<type>(<scope>): <subject>
                           ← blank line
<body>
                           ← blank line
<footer>
```

### Subject Line

**Rules**:
1. **50 characters or less**
2. **Imperative mood** ("add" not "added")
3. **Capitalize first letter**
4. **No period at end**
5. **Summarize WHAT changed**

**✅ Good**:
```
feat(auth): add JWT token generation
fix(api): prevent null pointer in user lookup
docs: update API authentication guide
refactor(db): extract query logic to repository
```

**❌ Bad**:
```
Added some stuff                    # Too vague
fix: fixed a bug                    # Not descriptive
feat(auth): Added JWT token generation and validation and refresh token rotation  # Too long
Update file                         # What file? What change?
```

### Body

**When to include**:
- Change is non-trivial (>10 lines)
- Need to explain WHY (not obvious from code)
- Breaking changes or deprecations
- Multiple related changes
- Performance implications

**Format**:
- Wrap at 72 characters
- Explain what and why, not how
- Use bullet points for multiple items
- Blank line before footer

**✅ Good**:
```
feat(auth): implement JWT authentication

Added JWT-based authentication to replace session cookies.
JWTs provide better scalability for our growing user base
and enable stateless authentication across multiple servers.

Implementation details:
- RS256 algorithm for asymmetric signing
- 15-minute access token expiry
- 7-day refresh token with rotation
- Token blacklist for logout/revocation

Performance impact: Reduces database queries by 60% for
authenticated requests (no session lookup required).

Closes #123
```

**❌ Bad**:
```
feat(auth): implement JWT authentication

Changed the authentication to use JWTs.
Used the PyJWT library.
Added some functions.
```

### Footer

**Use for**:
- Issue references (`Closes #123`, `Fixes #456`)
- Breaking changes (`BREAKING CHANGE:`)
- Co-authors (`Co-authored-by:`)
- Security advisories (`Security:`)

**Examples**:
```
Closes #123
Closes #123, #456, #789

Fixes #456
Resolves #789

Related to #100
See #200 for context

BREAKING CHANGE: API response format changed
Migration: Update clients to use response.data

Co-authored-by: Jane Doe <jane@example.com>

Security: Addresses CVE-2024-12345
```

---

## When to Commit

### Commit Frequency

**Commit Often**:
- ✅ After each logical unit of work
- ✅ When tests pass
- ✅ Before switching tasks
- ✅ End of work session

**Don't Commit**:
- ❌ Broken code (unless using WIP strategy)
- ❌ Incomplete features (unless behind feature flag)
- ❌ Code that doesn't compile
- ❌ Commented-out code

### Commit Triggers

**Good Times to Commit**:
```bash
# Completed a function
git commit -m "feat: add user validation function"

# Fixed a bug
git commit -m "fix: correct date calculation in reports"

# Refactored code
git commit -m "refactor: extract payment logic to service"

# Updated tests
git commit -m "test: add edge cases for user creation"

# Updated docs
git commit -m "docs: add API usage examples"
```

### WIP (Work in Progress) Commits

**When to Use**:
- End of day (backup your work)
- Switching tasks temporarily
- Want to share progress with team

**How to Use**:
```bash
# Create WIP commit
git add .
git commit -m "WIP: implementing user dashboard"
git push

# Later, clean up before PR
git rebase -i HEAD~3
# Squash WIP commits into proper commits
```

**Alternative: Stash**:
```bash
# Instead of WIP commit
git stash save "Working on dashboard widgets"

# Later, restore
git stash pop
```

---

## Testing Before Committing

### Pre-Commit Checks

**Minimum**:
```bash
# Run tests
npm test  # or pytest, cargo test, etc.

# Run linters
npm run lint

# Type checking
npm run type-check

# Then commit
git commit -m "feat: add dashboard"
```

**Automated with Git Hooks**:
```bash
# .git/hooks/pre-commit
#!/bin/bash
npm test || exit 1
npm run lint || exit 1
echo "✅ Tests and linters passed"
```

### Commit-Specific Testing

**Test only what changed**:
```bash
# Run tests for changed files only (faster)
pytest tests/test_auth.py  # If auth.py changed
npm test -- --findRelatedTests src/auth.js
```

**Full test suite**:
```bash
# Before pushing (not every commit)
npm test
npm run test:integration
npm run test:e2e
```

---

## What to Commit

### Include in Commits

**✅ Always Include**:
- Source code changes
- Test changes
- Documentation changes (related to code)
- Configuration changes (if needed for feature)

**✅ Sometimes Include**:
- Dependency updates (if part of feature)
- Database migrations (if tied to code change)
- Build configuration (if needed for feature)

**❌ Never Include**:
- Generated files (build output, compiled code)
- Dependencies (node_modules, venv, target)
- IDE files (.vscode, .idea unless shared)
- OS files (.DS_Store, Thumbs.db)
- Secrets (API keys, passwords, tokens)
- Log files
- Temporary files

### .gitignore Best Practices

```bash
# Dependencies
node_modules/
venv/
target/

# Build output
dist/
build/
*.pyc
__pycache__/

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Secrets
.env
.env.local
secrets.json
*.key
*.pem

# Logs
*.log
npm-debug.log*
```

---

## Commit History Hygiene

### Clean Commit History

**✅ Good History**:
```
* feat(api): add pagination to user endpoint
* test(api): add pagination tests
* docs: update API documentation
* feat(db): add user indexing for performance
* fix(auth): correct token expiration handling
```

**❌ Messy History**:
```
* fix typo
* WIP
* more changes
* Update file.py
* fix build
* fix tests
* actually fix tests
* forgot to commit this
```

### Cleaning Up History

**Squash Multiple Commits**:
```bash
# Before PR, squash related commits
git rebase -i HEAD~5

# In editor, change:
pick abc1234 feat: add user model
pick def5678 fix tests
pick ghi9012 fix linting
pick jkl3456 add docs

# To:
pick abc1234 feat: add user model
squash def5678 fix tests
squash ghi9012 fix linting
squash jkl3456 add docs

# Results in single commit:
# "feat: add user model"
```

**Reword Commit Messages**:
```bash
# Change commit message
git rebase -i HEAD~3

# In editor, change:
pick abc1234 feat: add user model

# To:
reword abc1234 feat: add user model

# Git will prompt for new message
```

**Reorder Commits**:
```bash
git rebase -i HEAD~3

# In editor, reorder lines:
pick abc1234 docs: update README
pick def5678 feat: add user model
pick ghi9012 test: add user tests

# To:
pick def5678 feat: add user model
pick ghi9012 test: add user tests
pick abc1234 docs: update README
```

---

## Common Commit Patterns

### 1. Feature Implementation

```bash
# Step 1: Add model/data layer
git commit -m "feat(models): add User model with validation"

# Step 2: Add business logic
git commit -m "feat(services): add UserService for user operations"

# Step 3: Add API endpoint
git commit -m "feat(api): add user CRUD endpoints"

# Step 4: Add tests
git commit -m "test(api): add user endpoint tests"

# Step 5: Add documentation
git commit -m "docs(api): document user endpoints"
```

### 2. Bug Fix

```bash
# Step 1: Add failing test
git commit -m "test(auth): add test for token expiration bug"

# Step 2: Fix the bug
git commit -m "fix(auth): correct token expiration check

Fixed timezone comparison bug where expired tokens were
accepted due to local time vs UTC mismatch.

Fixes #789"

# Step 3: Update docs if needed
git commit -m "docs(auth): clarify token expiration behavior"
```

### 3. Refactoring

```bash
# Step 1: Extract function
git commit -m "refactor(auth): extract validation logic to function"

# Step 2: Simplify calling code
git commit -m "refactor(auth): simplify login flow using extracted validator"

# Step 3: Remove duplication
git commit -m "refactor(auth): remove duplicated validation in signup"
```

### 4. Dependency Update

```bash
# Update single dependency
git commit -m "chore(deps): update FastAPI to 0.100.0

Updated FastAPI to fix security vulnerability CVE-2024-12345.
No breaking changes, all tests pass.

Security: Addresses CVE-2024-12345"

# Bulk dependency update
git commit -m "chore(deps): update all non-breaking dependencies

- fastapi: 0.95.0 → 0.100.0
- pydantic: 1.10.7 → 1.10.9
- pytest: 7.3.1 → 7.4.0

All tests passing, no breaking changes."
```

---

## Advanced Techniques

### Fixup Commits

**Purpose**: Mark commits that should be squashed later

```bash
# Original commit
git commit -m "feat: add dashboard"

# Oops, forgot something
git add forgotten-file.py
git commit --fixup HEAD  # Creates "fixup! feat: add dashboard"

# When ready to clean up
git rebase -i --autosquash HEAD~5
# Automatically squashes fixup commits
```

### Amending Commits

**Last commit only**:
```bash
# Add to last commit
git add forgotten-file.py
git commit --amend --no-edit

# Change last commit message
git commit --amend -m "new message"
```

**⚠️ Warning**: Only amend commits not yet pushed (or force push needed)

### Cherry-Picking

**Apply specific commit to another branch**:
```bash
# Get commit from feature branch to main
git checkout main
git cherry-pick abc1234

# Cherry-pick with changes
git cherry-pick -n abc1234  # Don't commit yet
# Make adjustments
git commit -m "feat: cherry-picked and adapted from feature branch"
```

---

## Commit Anti-Patterns

### ❌ The Mega Commit
```bash
# 50 files changed, 2000+ lines
git commit -m "Implement user feature"
```
**Problem**: Impossible to review, hard to revert, unclear what changed

**Solution**: Break into atomic commits

### ❌ The Meaningless Message
```bash
git commit -m "Update"
git commit -m "Fix"
git commit -m "Changes"
```
**Problem**: No context, useless history

**Solution**: Descriptive messages

### ❌ The Broken Commit
```bash
git commit -m "feat: add dashboard (tests failing)"
```
**Problem**: Breaks git bisect, CI fails

**Solution**: Only commit working code

### ❌ The WIP Graveyard
```bash
git log
WIP
WIP
WIP
more WIP
actually WIP
```
**Problem**: Polluted history

**Solution**: Squash before merging

---

## Commit Checklist

Before committing, verify:

- [ ] **Code compiles/runs** - No syntax errors
- [ ] **Tests pass** - At least affected tests
- [ ] **Linters pass** - Code style consistent
- [ ] **Changes are atomic** - One logical change
- [ ] **Message is clear** - Explains what and why
- [ ] **No debug code** - No console.log, print statements
- [ ] **No commented code** - Remove or uncomment
- [ ] **No secrets** - No API keys, passwords
- [ ] **Related changes included** - Tests, docs updated

---

## Tools & Automation

### Commitlint

```bash
# Install
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Configure .commitlintrc.json
{
  "extends": ["@commitlint/config-conventional"]
}

# Add to .git/hooks/commit-msg
#!/bin/bash
npx commitlint --edit $1
```

### Husky (Git Hooks)

```bash
# Install
npm install --save-dev husky

# Setup
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm test"
npx husky add .husky/pre-commit "npm run lint"

# Add commit-msg hook
npx husky add .husky/commit-msg 'npx commitlint --edit $1'
```

### Git Aliases

```bash
# ~/.gitconfig
[alias]
  # Quick commit with message
  cm = commit -m

  # Amend last commit
  amend = commit --amend --no-edit

  # Fixup last commit
  fixup = commit --fixup HEAD

  # Interactive rebase
  rb = rebase -i

  # Squash last N commits
  squash = "!f() { git reset --soft HEAD~$1 && git commit; }; f"

  # Show last commit
  last = log -1 HEAD --stat
```

---

## Summary

**The Five Rules of Good Commits**:

1. **Atomic** - One logical change per commit
2. **Tested** - Tests pass after commit
3. **Documented** - Clear, descriptive message
4. **Complete** - All related changes included
5. **Clean** - No debug code, secrets, or generated files

**Remember**: Commits are for your future self and teammates. Make them helpful!
