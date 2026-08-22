# Feature Branch Workflow Template

## Branch Naming Convention

### Format
```
<type>/<ticket-id>-<short-description>
```

### Types
- `feature/` - New functionality
- `fix/` - Bug fixes
- `hotfix/` - Emergency production fixes
- `refactor/` - Code improvements without behavior change
- `docs/` - Documentation only
- `test/` - Test additions or fixes
- `chore/` - Maintenance tasks (deps, config, etc.)

### Examples
```bash
feature/RAE-123-user-authentication
fix/RAE-456-login-timeout
hotfix/PROD-789-payment-crash
refactor/RAE-234-clean-api-layer
docs/RAE-567-api-documentation
test/RAE-890-add-integration-tests
chore/RAE-345-upgrade-dependencies
```

---

## Workflow Steps

### 1. Create Feature Branch

```bash
# Always branch from latest main/master
git checkout main
git pull origin main

# Create and switch to feature branch
git checkout -b feature/RAE-123-user-authentication

# Push branch to remote (sets upstream tracking)
git push -u origin feature/RAE-123-user-authentication
```

### 2. Work on Feature

```bash
# Make changes to files
# Stage changes in logical groups
git add src/auth/login.py src/auth/middleware.py

# Commit with conventional commit message
git commit -m "feat(auth): implement JWT authentication middleware

- Add JWT token generation and validation
- Implement authentication middleware for FastAPI
- Add token refresh endpoint
- Include comprehensive error handling

Closes RAE-123"

# Push to remote regularly (backup + collaboration)
git push
```

### 3. Keep Branch Updated

```bash
# Fetch latest changes from main
git fetch origin main

# Rebase onto main (keeps history linear)
git rebase origin/main

# If conflicts occur, resolve and continue
# [fix conflicts in files]
git add <resolved-files>
git rebase --continue

# Force push after rebase (rewrites history)
git push --force-with-lease
```

### 4. Pre-PR Checklist

Before creating pull request, verify:

**Code Quality:**
- [ ] All tests pass (`pytest`, `npm test`, etc.)
- [ ] Linters pass (ESLint, Pylint, Black, etc.)
- [ ] Type checking passes (TypeScript, mypy, etc.)
- [ ] No commented-out code or debug statements
- [ ] No secrets or sensitive data in commits

**Documentation:**
- [ ] Code comments added for complex logic
- [ ] Docstrings updated for modified functions
- [ ] README updated if public API changed
- [ ] Migration guide added if breaking changes

**Testing:**
- [ ] Unit tests added for new functionality
- [ ] Integration tests updated if needed
- [ ] Edge cases covered
- [ ] Error handling tested

**Commits:**
- [ ] Commit messages follow Conventional Commits
- [ ] Commits are logical and atomic
- [ ] No "WIP" or "fix typo" commits (squash if needed)
- [ ] Sensitive data not in commit history

**Branch:**
- [ ] Branch is up-to-date with main
- [ ] No merge conflicts
- [ ] CI/CD pipeline passes on branch

### 5. Create Pull Request

```bash
# Push final changes
git push

# Use GitHub CLI to create PR (or web interface)
gh pr create \
  --title "feat: Implement JWT authentication middleware" \
  --body "$(cat <<'EOF'
## Summary
Implements JWT-based authentication middleware for FastAPI application.

## Changes
- Added JWT token generation and validation utilities
- Implemented FastAPI middleware for automatic authentication
- Added token refresh endpoint
- Comprehensive error handling for invalid/expired tokens

## Testing
- Unit tests for JWT utilities (100% coverage)
- Integration tests for protected endpoints
- Manual testing with Postman collection

## Screenshots
[If UI changes, add screenshots]

## Checklist
- [x] Tests pass
- [x] Linters pass
- [x] Documentation updated
- [x] No breaking changes
- [ ] Reviewed by security team (required for auth changes)

## Related Issues
Closes RAE-123
Related to RAE-100 (authentication epic)
EOF
)" \
  --base main \
  --head feature/RAE-123-user-authentication
```

### 6. Address Review Feedback

```bash
# Make requested changes
vim src/auth/middleware.py

# Commit with reference to review
git add src/auth/middleware.py
git commit -m "refactor(auth): address PR feedback

- Extract token validation to separate function
- Add type hints as requested by reviewer
- Improve error messages

Addresses review comments in PR #123"

# Push updates
git push
```

### 7. Merge

```bash
# After approval, merge via GitHub interface or CLI
# Squash merge (recommended for feature branches)
gh pr merge --squash --delete-branch

# Or rebase merge (keeps individual commits)
gh pr merge --rebase --delete-branch

# Or standard merge (creates merge commit)
gh pr merge --merge --delete-branch
```

### 8. Clean Up

```bash
# Switch to main
git checkout main

# Pull merged changes
git pull origin main

# Delete local branch
git branch -d feature/RAE-123-user-authentication

# Verify remote branch deleted (should auto-delete on merge)
git branch -r | grep RAE-123
```

---

## Quick Reference Commands

### Branch Operations
```bash
# List all branches
git branch -a

# Switch to existing branch
git checkout <branch-name>

# Create and switch to new branch
git checkout -b <branch-name>

# Rename current branch
git branch -m <new-name>

# Delete local branch
git branch -d <branch-name>

# Delete remote branch
git push origin --delete <branch-name>
```

### Syncing with Main
```bash
# Rebase (recommended - linear history)
git fetch origin main
git rebase origin/main

# Merge (alternative - preserves branch history)
git fetch origin main
git merge origin/main
```

### Undoing Changes
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Amend last commit message
git commit --amend -m "new message"

# Amend last commit (add forgotten files)
git add forgotten-file.py
git commit --amend --no-edit
```

---

## Common Scenarios

### Scenario 1: Forgot to Branch from Main

```bash
# Currently on feature/old-feature, want to branch from main
git checkout main
git pull origin main
git checkout -b feature/new-feature
```

### Scenario 2: Need to Switch Branches Mid-Work

```bash
# Save work in progress
git stash save "WIP: implementing login"

# Switch to other branch
git checkout other-branch
# [do work on other branch]

# Return to original branch
git checkout feature/RAE-123-user-authentication
git stash pop
```

### Scenario 3: Made Changes on Wrong Branch

```bash
# Currently on main, should be on feature branch
git stash save "Changes for feature branch"
git checkout -b feature/RAE-123-correct-branch
git stash pop
```

### Scenario 4: Need to Squash Multiple Commits

```bash
# Squash last 3 commits
git rebase -i HEAD~3

# In editor, change "pick" to "squash" for commits to combine
# Edit combined commit message
# Save and exit

# Force push (only if not yet in PR, or after approval)
git push --force-with-lease
```

### Scenario 5: Resolve Merge Conflicts

```bash
# Attempt rebase
git rebase origin/main

# Conflicts detected - fix in files
vim <conflicted-file>

# Stage resolved files
git add <conflicted-file>

# Continue rebase
git rebase --continue

# If too complex, abort and try merge instead
git rebase --abort
git merge origin/main
```

---

## Best Practices

### 1. Commit Often, Push Regularly
- Commit logical units of work (one feature/fix per commit)
- Push to remote at least daily (backup + visibility)
- Small commits easier to review and revert

### 2. Keep Branches Short-Lived
- Aim for 1-3 days per feature branch
- Longer branches = more conflicts
- Break large features into smaller PRs

### 3. Rebase to Keep History Clean
- Rebase instead of merge when syncing with main
- Creates linear history (easier to understand)
- Use `--force-with-lease` not `--force` (safer)

### 4. Write Descriptive Commit Messages
- Use Conventional Commits format
- Explain WHY not just WHAT
- Include ticket references

### 5. Review Your Own PR First
- Check diff before submitting
- Test locally one more time
- Ensure CI passes

### 6. Delete Merged Branches
- Keeps branch list clean
- Reduces confusion
- Enable auto-delete on GitHub

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
# .github/workflows/feature-branch.yml
name: Feature Branch CI

on:
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          npm install
          npm test
      - name: Run Linters
        run: npm run lint
      - name: Type Check
        run: npm run type-check
```

### Branch Protection Rules

Recommended settings:
- ✅ Require pull request before merging
- ✅ Require status checks to pass (tests, linters)
- ✅ Require conversation resolution before merging
- ✅ Require linear history (rebase/squash only)
- ✅ Delete head branches automatically
- ❌ Allow force pushes (except for admins)
- ❌ Allow deletions

---

## Troubleshooting

### Issue: "Branch is behind main"
```bash
git fetch origin main
git rebase origin/main
git push --force-with-lease
```

### Issue: "Divergent branches" after rebase
```bash
# Normal after rebase - use force push
git push --force-with-lease
```

### Issue: "Merge conflicts" during rebase
```bash
# Option 1: Fix conflicts manually
git status  # see conflicted files
vim <file>  # fix conflicts
git add <file>
git rebase --continue

# Option 2: Abort and use merge instead
git rebase --abort
git merge origin/main
```

### Issue: Accidentally committed to main
```bash
# Move commit to feature branch
git branch feature/RAE-123-new-branch
git reset --hard origin/main  # reset main to remote state
git checkout feature/RAE-123-new-branch
```

### Issue: Need to update PR after force push
```bash
# GitHub automatically updates PR after force push
# Just push with --force-with-lease
git push --force-with-lease
```
