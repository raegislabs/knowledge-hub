# Merge Strategies

## Overview

Git provides multiple ways to integrate changes from one branch to another. Each strategy has trade-offs in terms of history clarity, complexity, and risk.

---

## Strategy Comparison

| Strategy | History | Conflicts | Use Case | Reversibility |
|----------|---------|-----------|----------|---------------|
| **Merge Commit** | Non-linear | Resolved once | Long-running branches | Easy (revert merge) |
| **Squash Merge** | Linear | Resolved once | Feature branches | Moderate (revert commit) |
| **Rebase** | Linear | Per commit | Sync with upstream | Hard (force push) |
| **Fast-Forward** | Linear | None | Simple updates | Easy (reset) |

---

## 1. Merge Commit (--no-ff)

### What It Is
Creates a merge commit that combines two branches, preserving both histories.

### Diagram
```
Before:
main:     A---B---C
               \
feature:        D---E---F

After (git merge --no-ff feature):
main:     A---B---C-------M
               \         /
feature:        D---E---F
```

### Command
```bash
git checkout main
git merge --no-ff feature
# Creates merge commit M
```

### Pros
✅ **Preserves history** - Can see where features came from
✅ **Easy to revert** - Revert merge commit to undo entire feature
✅ **Clear feature boundaries** - Each feature has distinct merge point
✅ **No rewriting history** - Safe for shared branches

### Cons
❌ **Non-linear history** - Can be hard to follow
❌ **Cluttered log** - Many merge commits
❌ **Harder to bisect** - Extra commits complicate debugging

### When to Use
- Long-running feature branches
- Preserving feature context important
- Shared branches (never force push)
- Git Flow workflow

### Example
```bash
# Feature development
git checkout -b feature/user-auth
git commit -m "feat: add login endpoint"
git commit -m "feat: add JWT validation"
git commit -m "test: add auth tests"

# Merge to main
git checkout main
git merge --no-ff feature/user-auth
# Creates merge commit: "Merge branch 'feature/user-auth'"

# Result in log:
* Merge branch 'feature/user-auth'
|\
| * test: add auth tests
| * feat: add JWT validation
| * feat: add login endpoint
|/
* Previous commit on main
```

---

## 2. Squash Merge (--squash)

### What It Is
Combines all commits from feature branch into a single commit on target branch.

### Diagram
```
Before:
main:     A---B---C
               \
feature:        D---E---F

After (git merge --squash feature):
main:     A---B---C---S
               \
feature:        D---E---F (unchanged)

S = All changes from D+E+F in one commit
```

### Command
```bash
git checkout main
git merge --squash feature
git commit -m "feat: implement user authentication

Complete auth feature with login, JWT, and tests."
```

### Pros
✅ **Clean linear history** - One commit per feature
✅ **Easy to read log** - Simple progression
✅ **Good for PR workflow** - Especially GitHub/GitLab
✅ **Combines fixup commits** - WIP commits disappear

### Cons
❌ **Loses detailed history** - Can't see individual commits
❌ **Harder to debug** - Large commits harder to bisect
❌ **Manual commit needed** - Must write squash commit message

### When to Use
- Feature branches with many commits
- WIP commits that should be hidden
- GitHub/GitLab Flow
- Want clean main branch history

### Example
```bash
# Feature with messy commits
git log feature/user-auth
* WIP: more tests
* fix typo
* test: add auth tests
* fix linting
* feat: add JWT validation
* feat: add login endpoint

# Squash merge
git checkout main
git merge --squash feature/user-auth
git commit -m "feat(auth): implement JWT authentication

- Login endpoint with email/password
- JWT token generation and validation
- Comprehensive test coverage
- Error handling for invalid credentials

Closes #123"

# Result in log:
* feat(auth): implement JWT authentication
* Previous commit on main

# Clean! All 6 commits became 1
```

---

## 3. Rebase

### What It Is
Replays commits from one branch onto another, rewriting history.

### Diagram
```
Before:
main:     A---B---C
               \
feature:        D---E---F

After (git rebase main from feature):
main:     A---B---C
                   \
feature:            D'---E'---F'

D', E', F' are new commits (same changes, different SHAs)
```

### Command
```bash
# From feature branch
git checkout feature
git rebase main

# Or from main
git checkout main
git rebase feature  # Fast-forward
```

### Pros
✅ **Linear history** - No merge commits
✅ **Clean log** - Easy to follow
✅ **Better for bisect** - Each commit is independent
✅ **Keeps commits atomic** - Preserves individual commits (unlike squash)

### Cons
❌ **Rewrites history** - Changes commit SHAs
❌ **Conflicts per commit** - May resolve multiple times
❌ **Dangerous on shared branches** - Can cause problems for others
❌ **Requires force push** - If already pushed

### When to Use
- Syncing feature branch with main
- Cleaning up local commits before pushing
- Trunk-based development
- Private branches only

### Example
```bash
# Feature branch behind main
git log --oneline --all --graph
* main (ahead)
| * feature commit 2
| * feature commit 1
|/
* common base

# Rebase feature onto main
git checkout feature
git rebase main

# Resolve conflicts if any
# For each commit in feature:
#   - Apply commit
#   - If conflicts, fix and git rebase --continue
#   - Repeat for each commit

# After rebase:
* feature commit 2  (new SHA)
* feature commit 1  (new SHA)
* main (ahead)
* common base

# Push (requires force)
git push --force-with-lease
```

### Interactive Rebase

**Clean up commits before merging**:
```bash
git rebase -i HEAD~5

# In editor:
pick abc1234 feat: add login
pick def5678 fix tests
pick ghi9012 WIP
pick jkl3456 fix typo
pick mno7890 add docs

# Change to:
pick abc1234 feat: add login
squash def5678 fix tests
squash ghi9012 WIP
reword jkl3456 fix typo
squash mno7890 add docs

# Results in 2 clean commits instead of 5
```

**Actions**:
- `pick` - Keep commit as-is
- `reword` - Change commit message
- `edit` - Amend commit
- `squash` - Combine with previous commit
- `fixup` - Like squash but discard message
- `drop` - Remove commit

---

## 4. Fast-Forward Merge

### What It Is
Simply moves branch pointer forward when no divergent changes exist.

### Diagram
```
Before:
main:     A---B
                \
feature:         C---D

After (git merge feature):
main:     A---B---C---D
                \
feature:         C---D

No merge commit created - just moved pointer
```

### Command
```bash
git checkout main
git merge feature
# If possible, does fast-forward automatically

# Force fast-forward (fail if not possible)
git merge --ff-only feature
```

### Pros
✅ **Cleanest history** - No extra commits
✅ **Fast and simple** - No merge commit overhead
✅ **Easy to understand** - Linear progression

### Cons
❌ **Loses branch info** - Can't see where feature started/ended
❌ **Only works if no divergence** - Can't fast-forward if main has new commits

### When to Use
- Updating local main from remote
- Merging simple feature branches
- No commits on main since feature branch created

### Example
```bash
# Scenario: main hasn't changed since feature branch created
git checkout main
git log --oneline
abc1234 Initial commit

git checkout feature
git log --oneline
ghi9012 feat: add dashboard
def5678 feat: add user model
abc1234 Initial commit

# Merge (fast-forward)
git checkout main
git merge feature

# Result:
git log --oneline
ghi9012 feat: add dashboard
def5678 feat: add user model
abc1234 Initial commit

# No merge commit, just moved pointer
```

---

## Conflict Resolution

### Understanding Conflicts

**When conflicts occur**:
- Same line changed in both branches
- File deleted in one branch, modified in other
- File renamed in one branch, modified in other

**Conflict markers**:
```python
<<<<<<< HEAD (current branch)
user = User.query.get(user_id)
=======
user = db.session.query(User).filter_by(id=user_id).first()
>>>>>>> feature/new-orm (incoming branch)
```

### Resolution Process

**1. Identify conflicts**:
```bash
git merge feature
# Auto-merging file.py
# CONFLICT (content): Merge conflict in file.py
# Automatic merge failed; fix conflicts and then commit the result.

# List conflicted files
git status
# both modified:   src/auth/login.py
# both modified:   src/models/user.py
```

**2. Resolve each conflict**:
```bash
# Open conflicted file
vim src/auth/login.py

# See conflict markers:
<<<<<<< HEAD
user = User.query.get(user_id)
=======
user = db.session.query(User).filter_by(id=user_id).first()
>>>>>>> feature/new-orm

# Choose one or combine:
# Option 1: Keep HEAD (current branch)
user = User.query.get(user_id)

# Option 2: Keep incoming (feature branch)
user = db.session.query(User).filter_by(id=user_id).first()

# Option 3: Combine both (if makes sense)
user = User.query.get(user_id) or db.session.query(User).filter_by(id=user_id).first()

# Remove conflict markers
```

**3. Mark as resolved**:
```bash
git add src/auth/login.py
```

**4. Complete merge**:
```bash
# For merge commit
git commit
# (Uses default merge message or edit)

# For rebase
git rebase --continue
```

### Conflict Resolution Tools

**Use merge tool**:
```bash
# Configure (one-time)
git config --global merge.tool vimdiff
# Or: meld, kdiff3, p4merge, opendiff

# Use tool
git mergetool

# Shows 3-way merge:
# LOCAL (your changes) | BASE (common ancestor) | REMOTE (their changes)
#                      MERGED (result)
```

**Abort if too complex**:
```bash
# Abort merge
git merge --abort

# Abort rebase
git rebase --abort
```

### Preventing Conflicts

**1. Merge often**:
```bash
# Keep feature branch up-to-date
git checkout feature
git merge main
# Or: git rebase main
```

**2. Small, frequent commits**:
- Easier to resolve conflicts in small chunks
- Less overlap between branches

**3. Coordinate with team**:
- Communicate who's working on what
- Use feature flags to avoid same file edits

---

## Choosing a Strategy

### Decision Tree

```
Are you merging to main/production?
├─ YES → Squash merge (clean history)
│   └─ Unless feature context important → Merge commit
│
└─ NO → Syncing feature branch with main?
    ├─ YES → Rebase (keep history linear)
    │   └─ Unless shared branch → Merge commit
    │
    └─ NO → Simple update?
        └─ YES → Fast-forward if possible
```

### By Workflow

**GitHub Flow / GitLab Flow**:
```bash
# Feature branch to main
git checkout main
git merge --squash feature
git commit -m "feat: user authentication"
```

**Git Flow**:
```bash
# Feature to develop
git checkout develop
git merge --no-ff feature/user-auth

# Release to main
git checkout main
git merge --no-ff release/v1.2.0
```

**Trunk-Based Development**:
```bash
# Keep feature up-to-date with trunk
git checkout feature
git rebase main

# Merge to trunk (fast-forward)
git checkout main
git merge feature
```

### Team Preferences

**Prefer clean history** → Squash or Rebase
**Prefer context** → Merge commit
**Prefer safety** → Merge commit (no history rewriting)

---

## Best Practices

### 1. Never Rewrite Shared History
```bash
# ❌ DON'T: Rebase shared branch
git checkout main
git rebase feature  # Others have main, this breaks them

# ✅ DO: Merge instead
git merge feature
```

### 2. Use --force-with-lease, Not --force
```bash
# ❌ DON'T: Dangerous
git push --force

# ✅ DO: Safer (fails if remote changed)
git push --force-with-lease
```

### 3. Test After Merge/Rebase
```bash
# After merge
git merge feature
npm test  # or pytest, cargo test, etc.

# After rebase
git rebase main
npm test  # Ensure rebase didn't break anything
```

### 4. Write Good Merge Messages
```bash
# ❌ BAD
git merge feature
# Default: "Merge branch 'feature'"

# ✅ GOOD
git merge --no-ff feature -m "feat: user authentication system

Complete implementation of JWT-based authentication including
login, token refresh, and logout functionality.

Closes #123"
```

### 5. Keep Feature Branches Updated
```bash
# Regularly sync with main
git checkout feature
git rebase main  # Or: git merge main
git push --force-with-lease  # If already pushed
```

---

## Common Scenarios

### Scenario 1: Feature Branch Behind Main

**Problem**: Feature branch created weeks ago, main has moved forward

**Solution**:
```bash
git checkout feature
git rebase main  # Or: git merge main

# Resolve conflicts
git push --force-with-lease
```

### Scenario 2: Merge Commit You Didn't Want

**Problem**: Accidentally created merge commit

**Solution**:
```bash
# Undo merge (if not pushed)
git reset --hard HEAD~1

# Or: Rebase to remove merge commit
git rebase -i HEAD~2
# Delete merge commit line
```

### Scenario 3: Need to Undo Merged Feature

**Problem**: Feature was merged but has bugs, need to remove

**Solution**:
```bash
# Find merge commit
git log --merges

# Revert merge commit
git revert -m 1 <merge-commit-sha>

# -m 1 means "keep parent 1 (main), undo parent 2 (feature)"
```

### Scenario 4: Squash After Regular Merge

**Problem**: Merged with merge commit, want to squash instead

**Solution**:
```bash
# If not pushed, reset and squash merge
git reset --hard HEAD~1  # Undo merge
git merge --squash feature
git commit -m "feat: squashed feature"

# If pushed, create new squashed commit
git revert HEAD  # Undo merge
git merge --squash feature
git commit -m "feat: squashed feature (replaces previous merge)"
```

---

## Tools & Configuration

### Git Config

```bash
# Default to --no-ff (always create merge commit)
git config --global merge.ff false

# Default to fast-forward only (fail if can't ff)
git config --global merge.ff only

# Set default merge message
git config --global merge.defaultToUpstream true
```

### Git Aliases

```bash
# ~/.gitconfig
[alias]
  # Merge with no fast-forward
  merge-commit = merge --no-ff

  # Squash merge
  merge-squash = merge --squash

  # Rebase on main
  rb = rebase main

  # Interactive rebase
  rbi = rebase -i

  # Abort merge
  abort = merge --abort
```

---

## Summary

**Quick Reference**:

| Scenario | Recommended Strategy | Command |
|----------|---------------------|---------|
| Feature → main (clean history) | Squash merge | `git merge --squash` |
| Feature → main (preserve context) | Merge commit | `git merge --no-ff` |
| Sync feature with main (private) | Rebase | `git rebase main` |
| Sync feature with main (shared) | Merge commit | `git merge main` |
| Simple update | Fast-forward | `git merge` |

**Golden Rules**:
1. Never rewrite shared history
2. Test after merge/rebase
3. Use --force-with-lease, not --force
4. Keep feature branches updated
5. Choose strategy based on workflow
