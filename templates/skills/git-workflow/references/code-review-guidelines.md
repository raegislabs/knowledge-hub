# Code Review Guidelines

## Purpose

Code reviews serve multiple purposes:
- **Quality Assurance** - Catch bugs before production
- **Knowledge Sharing** - Team learns from each other
- **Mentorship** - Senior developers guide juniors
- **Code Consistency** - Maintain standards across codebase
- **Design Feedback** - Improve architecture decisions
- **Security** - Catch vulnerabilities

---

## Review Process

### Timing
- **Ideal**: Review within 24 hours of PR creation
- **Maximum**: Within 48 hours
- **Hotfixes**: Within 2 hours

### Review Allocation
- **Small PRs** (<100 lines): 1 reviewer
- **Medium PRs** (100-400 lines): 1-2 reviewers
- **Large PRs** (>400 lines): 2+ reviewers or split PR

---

## Providing Feedback

### Feedback Types

**1. Blocking (🚨)** - MUST be fixed before merge
```markdown
🚨 **BLOCKING**: SQL injection vulnerability
```
Use for:
- Security issues
- Critical bugs
- Data loss potential

**2. Important (⚠️)** - SHOULD be addressed
```markdown
⚠️ **IMPORTANT**: Function doing too much, consider extracting
```
Use for:
- Design issues
- Maintainability concerns
- Non-critical bugs

**3. Suggestion (💡)** - Nice to have
```markdown
💡 **SUGGESTION**: Could use list comprehension here
```
Use for:
- Style improvements
- Minor optimizations
- Alternative approaches

**4. Question (❓)** - Seeking clarification
```markdown
❓ **QUESTION**: Why exponential backoff here?
```
Use for:
- Understanding intent
- Learning from approach
- Checking if intentional

**5. Praise (✅)** - Positive feedback
```markdown
✅ **NICE**: Excellent error handling!
```
Use for:
- Acknowledging good work
- Reinforcing best practices
- Building morale

### Writing Effective Comments

**✅ Good Feedback**:
```markdown
⚠️ **IMPORTANT**: This function has O(n²) complexity

The nested loop on lines 45-52 will be slow for large datasets.
Consider using a hash map to reduce to O(n):

```python
# Instead of:
for item in list1:
    for item2 in list2:
        if item.id == item2.id:
            ...

# Use:
map2 = {item.id: item for item in list2}
for item in list1:
    if item.id in map2:
        ...
```

This will improve performance from ~10s to ~100ms for 10k items.
```

**❌ Poor Feedback**:
```markdown
This is slow. Fix it.
```

**Key Principles**:
- **Be specific** - Point to exact lines/issues
- **Explain why** - Help author learn
- **Suggest solution** - Show how to fix
- **Be kind** - Critique code, not person
- **Provide context** - Why it matters

---

## Receiving Feedback

### For Authors

**Responding to Comments**:

**✅ Good Responses**:
```markdown
"Great catch! Fixed in commit abc123"
"Good point. I extracted the function as suggested"
"I chose this approach because X. Open to alternatives though - thoughts?"
```

**❌ Poor Responses**:
```markdown
"No, my way is fine"
"That's how I always do it"
"Whatever, I'll change it"
[No response]
```

**When You Disagree**:
```markdown
I see your point about extracting this function. I kept it inline because:
1. It's only used once
2. Extracting makes the flow harder to follow
3. The function is only 5 lines

Happy to reconsider if you feel strongly. What do you think?
```

**Key Principles**:
- **Be open** - Feedback helps you improve
- **Explain reasoning** - Help reviewer understand
- **Be willing to compromise** - Perfect is enemy of good
- **Respond promptly** - Don't leave reviewers waiting
- **Thank reviewers** - Appreciate their time

---

## Review Checklist

### High-Level (5 minutes)

- [ ] Understand problem and solution
- [ ] Verify approach makes sense
- [ ] Check PR size appropriate
- [ ] Verify all changes necessary

### Code Quality (20-30 minutes)

**Correctness**:
- [ ] Logic is sound
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] No obvious bugs

**Security**:
- [ ] No SQL injection
- [ ] No XSS vulnerabilities
- [ ] Input validation present
- [ ] No secrets in code
- [ ] Authentication/authorization correct

**Performance**:
- [ ] No N+1 queries
- [ ] Efficient algorithms
- [ ] Appropriate data structures
- [ ] Caching used where appropriate

**Maintainability**:
- [ ] Code is readable
- [ ] Clear naming
- [ ] Appropriate comments
- [ ] DRY principle followed
- [ ] Single responsibility

### Testing (10 minutes)

- [ ] Tests exist for new functionality
- [ ] Edge cases tested
- [ ] Error cases tested
- [ ] Tests are clear and maintainable
- [ ] CI passes

### Documentation (5 minutes)

- [ ] Code comments appropriate
- [ ] README updated if needed
- [ ] API docs updated if needed
- [ ] Migration guide for breaking changes

---

## Review Anti-Patterns

### ❌ The Nitpicker
Focuses on trivial style issues instead of logic.

**Problem**:
```markdown
"Missing period at end of comment"
"This could be 2 spaces instead of 3"
```

**Solution**: Use automated linters for style, focus on important issues.

### ❌ The Rewriter
Insists on rewriting code their way.

**Problem**:
```markdown
"I would have done this completely differently.
Here's my 200-line alternative..."
```

**Solution**: Only suggest if significantly better. Accept multiple valid approaches.

### ❌ The Ghost
Approves without leaving any comments or learning.

**Problem**: No feedback, no knowledge sharing.

**Solution**: Leave at least 1-2 comments (positive or constructive).

### ❌ The Blocker
Blocks PRs for non-critical issues.

**Problem**:
```markdown
"BLOCKING: Variable name should be more descriptive"
```

**Solution**: Reserve "blocking" for critical issues. Use suggestions for preferences.

### ❌ The Late Reviewer
Reviews after PR has been waiting for days/weeks.

**Problem**: Frustrates author, delays delivery.

**Solution**: Review within 24 hours. If can't, communicate delay.

---

## Best Practices

### For Reviewers

**1. Review Promptly**
- Within 24 hours for normal PRs
- Within 2 hours for hotfixes
- Communicate if delay expected

**2. Start with Positives**
```markdown
Great job on the test coverage! The edge cases are well thought out.

A few suggestions below...
```

**3. Be Specific**
```markdown
# ❌ Vague
"This function is bad"

# ✅ Specific
"This function has 3 responsibilities. Consider extracting validation
to validateInput() and database operations to saveToDb()"
```

**4. Explain Why**
```markdown
This will cause performance issues with large datasets because...
```

**5. Suggest, Don't Demand**
```markdown
# ❌ Demanding
"Change this to use a map"

# ✅ Suggesting
"Consider using a map here for O(1) lookup instead of O(n)"
```

**6. Ask Questions**
```markdown
"Why did you choose approach X over Y? Trying to understand the trade-offs."
```

**7. Approve Generously**
- Perfect is enemy of good
- Minor issues can be follow-up tasks
- Trust teammates

**8. Focus on Important Issues**
- Security, correctness, performance
- Not: "I prefer single quotes"

**9. Test Locally for Complex Changes**
```bash
git fetch origin
git checkout pr/123
npm install
npm test
npm start
```

**10. Review Your Own Comments Before Submitting**
- Are they constructive?
- Are they specific?
- Are they kind?

### For Authors

**1. Self-Review First**
```bash
# Review your own diff on GitHub
# Catch obvious issues before requesting review
```

**2. Keep PRs Small**
- Aim for <400 lines changed
- Break large features into smaller PRs
- Easier to review = faster merge

**3. Write Good Descriptions**
```markdown
## Summary
Clear explanation of what and why

## Changes
Detailed breakdown

## Testing
How it was tested

## Screenshots
For UI changes
```

**4. Add Context**
```markdown
## Why This Approach
I chose X over Y because of performance considerations
with our expected data volume.
```

**5. Respond Promptly**
- Address feedback within 24 hours
- If waiting on something, communicate

**6. Be Open to Feedback**
- Reviews help you improve
- Different perspectives valuable
- Don't take criticism personally

**7. Ask for Clarification**
```markdown
"Could you clarify what you mean by 'extract this logic'?
Do you mean to a separate function or separate file?"
```

**8. Thank Reviewers**
```markdown
"Thanks for the thorough review! The performance suggestion
was especially helpful."
```

**9. Address All Comments**
```markdown
# For each comment:
"Fixed in commit abc123"
"Added issue #456 to track this"
"I respectfully disagree because... Thoughts?"
```

**10. Update PR Description**
- Document decisions made during review
- Update testing notes
- Add follow-up tasks

---

## Handling Disagreements

### Healthy Disagreement
```markdown
Author: "I chose X because of performance"
Reviewer: "I see. Have you measured? Y might be faster for this case."
Author: "Good point, let me benchmark both"
[Benchmarks]
Author: "You were right, Y is 2x faster. Changed in commit abc123"
```

### When to Escalate
- Fundamental disagreement on approach
- Security/compliance concerns
- Architecture decisions

**Escalation Path**:
1. **Discuss in PR comments** (async)
2. **Schedule quick sync** (5-10 min call)
3. **Bring in tech lead** (if needed)
4. **Document decision** (ADR if significant)

---

## Review Metrics (Don't Overoptimize)

### Healthy Metrics
- **Time to first review**: <24 hours
- **Time to merge**: 1-3 days (depends on size)
- **Comments per PR**: 3-10 (varies by size)
- **Approval rate**: >80% (shows good code quality)

### Unhealthy Metrics
- ❌ **Lines reviewed per hour** (encourages rushed reviews)
- ❌ **Number of comments** (encourages nitpicking)
- ❌ **Rejection rate** (encourages overly critical reviews)

---

## Tools

### GitHub/GitLab Features
- **Request changes** vs **Comment** vs **Approve**
- **Suggestions** (propose code changes inline)
- **Review threads** (track conversation)
- **Resolve conversations** (mark as addressed)

### Browser Extensions
- **Refined GitHub** - Enhanced PR interface
- **Octotree** - File tree sidebar
- **GitHub Code Review** - Review helper tools

### IDE Integration
- **VSCode GitHub PR** - Review in editor
- **JetBrains Code With Me** - Pair review

---

## Special Cases

### Reviewing Hotfixes
- **Faster review required** (within 2 hours)
- **Focus on critical aspects**:
  - Does it fix the issue?
  - Is it safe?
  - Are there side effects?
- **Skip nice-to-haves**
- **Can approve with follow-up tasks**

### Reviewing Junior Developer Code
- **More mentorship focus**
- **Explain principles, not just fix**
- **Point to resources**
- **Celebrate good practices**
- **Be encouraging**

```markdown
✅ Great job adding tests! That shows good discipline.

One suggestion: Consider edge cases like empty input or null values.
Here's a good resource on test-driven development: [link]
```

### Reviewing Senior Developer Code
- **Still review thoroughly** (everyone makes mistakes)
- **Focus on design and architecture**
- **Ask questions to learn**
- **Challenge assumptions respectfully**

```markdown
❓ Interesting approach with the caching layer. Have you considered
race conditions when cache is invalidated? Curious how you're handling that.
```

---

## Example Review

```markdown
## Overall

Nice work on the authentication feature! The code is clean and well-tested.

I have one security concern that should be addressed before merging,
and a few suggestions for improvement.

---

## Critical Issues

### src/auth/login.py:45

🚨 **BLOCKING**: Password comparison vulnerable to timing attack

Current:
```python
if user.password == input_password:
```

This allows timing attacks. Use constant-time comparison:
```python
from secrets import compare_digest
if compare_digest(user.password, input_password):
```

Reference: https://security.example.com/timing-attacks

---

## Important Suggestions

### src/auth/middleware.py:67

⚠️ **IMPORTANT**: Consider more specific error messages

Currently returns generic "Unauthorized" for all auth failures.
Consider distinguishing:
- Token expired → "Token expired, please refresh"
- Invalid token → "Invalid authentication token"
- Missing token → "Authentication required"

This helps clients handle errors appropriately.

---

## Minor Suggestions

### tests/test_auth.py:120

💡 **SUGGESTION**: Add test for concurrent login attempts

Current tests cover single logins well. Consider adding test for
rapid concurrent attempts to verify rate limiting works correctly.

Not blocking, but would increase confidence in rate limiter.

---

## Positive Feedback

### tests/test_auth.py (general)

✅ **EXCELLENT**: Test coverage is outstanding!

Love that you're testing:
- Happy path
- Invalid credentials
- Missing credentials
- Expired tokens
- Rate limiting

This is how tests should be written!

---

## Summary

**Must fix**:
- Password comparison (security)

**Strongly recommend**:
- Improve error messages

**Consider**:
- Concurrent login test

Overall great work! Let me know if you have questions on the feedback.
```

---

## Summary

**The Five Principles of Good Code Review**:

1. **Timely** - Review within 24 hours
2. **Constructive** - Help, don't criticize
3. **Specific** - Point to exact issues with solutions
4. **Balanced** - Include positive feedback
5. **Collaborative** - Work together toward best solution

**Remember**: Code review is about improving code AND improving developers.
