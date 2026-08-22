# Bug Report: {Title}

## Basic Information
**Report ID**: {Auto-generated or ticket system ID}
**Reported By**: {Your name}
**Date**: {YYYY-MM-DD}
**Priority**: Critical | High | Medium | Low
**Component**: {Module/Service affected}
**Version**: {Software version where bug occurs}

## Summary
{One-sentence description of the bug - what's broken}

## Steps to Reproduce
{Provide clear, numbered steps that anyone can follow}

1. {Action 1 - be specific about UI clicks, API calls, commands}
2. {Action 2 - include relevant data/inputs}
3. {Action 3 - describe expected interaction}
4. {Action 4 - note when bug manifests}

**Frequency**: Always | Sometimes (X%) | Once
**Reproducible**: Yes | No | Intermittent

## Expected Behavior
{What should happen when following the steps above}

Example:
- Expected response code: 200
- Expected data: `{"status": "success", "user_id": 123}`
- Expected UI state: User redirected to dashboard

## Actual Behavior
{What actually happens - be precise and factual}

Example:
- Actual response code: 500
- Actual error: `{"error": "NoneType has no attribute 'id'"}`
- Actual UI state: White screen, no error message displayed

## Screenshots/Videos
{If applicable - attach or link to visual evidence}

**Before (Expected)**:
![Expected state](link-to-image)

**After (Actual)**:
![Broken state](link-to-image)

**Video**: [Link to screen recording if behavior is dynamic]

## Error Messages

### Console/Terminal Output
```
{Paste complete error message with stack trace}
{Include timestamps if available}
```

### Browser Console (if web application)
```javascript
{Paste JavaScript errors from browser DevTools}
```

### Log Files
```
{Paste relevant log entries - include context lines}
{Indicate which log file: application.log, error.log, etc.}
```

## Environment Details

### System Information
- **Operating System**: {macOS 14.1, Ubuntu 22.04, Windows 11, etc.}
- **Browser** (if applicable): {Chrome 120, Firefox 121, Safari 17}
- **Device**: {Desktop, Mobile - iPhone 14, Android Pixel 7}
- **Screen Resolution**: {1920x1080, etc.}

### Software Versions
- **Application Version**: {v2.3.1, commit SHA: abc123}
- **Runtime**: {Python 3.11.5, Node.js 20.10.0}
- **Database**: {PostgreSQL 15.4}
- **Dependencies**: {List critical library versions}
  - `requests==2.31.0`
  - `flask==3.0.0`

### Configuration
{Any relevant config settings that might affect the bug}
```yaml
# config.yaml (sanitized - no secrets)
debug: false
timeout: 30
max_connections: 100
```

## Data/Inputs

### Sample Data
{Provide minimal data needed to reproduce}

```json
{
  "user_id": 12345,
  "email": "test@example.com",
  "preferences": null  // Note: null value may be relevant
}
```

**Data characteristics**:
- Size: {100 records, 5MB file}
- Special characters: {Unicode, emojis, SQL quotes}
- Edge cases: {Empty strings, null values, very long strings}

## Network Information (if applicable)

### Request Details
```http
POST /api/users HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer {token}

{"email": "test@example.com"}
```

### Response Details
```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{"error": "NoneType object has no attribute 'id'"}
```

## Impact Assessment

### Severity Justification
{Why you assigned this priority level}

**User Impact**:
- {Number/percentage of users affected}
- {What functionality is broken}
- {Is there a workaround?}

**Business Impact**:
- {Revenue impact}
- {Compliance/legal issues}
- {Reputation damage}

**Urgency**:
- {Is production down?}
- {Can users complete critical workflows?}
- {Is data at risk?}

## Context

### What Changed?
{Did this work before? What's different now?}
- Recent deployment: {version, date}
- Configuration change: {what was changed}
- Data migration: {when it occurred}
- External dependency update: {which service}

### Related Issues
- Similar to: #{issue number}
- Possibly related to: #{issue number}
- Duplicate of: #{issue number} (if applicable)

## Attempted Solutions

### What I've Tried
1. **{Solution attempt 1}**
   - Result: {What happened}

2. **{Solution attempt 2}**
   - Result: {What happened}

### Workarounds
{Temporary workaround if any exists}

Example:
- Workaround: Manually set `preferences` to `{}` instead of `null`
- Limitation: Requires manual intervention for each user

## Additional Information

### Diagnostic Information
{Any additional debugging you've done}

**Debugging steps taken**:
- Checked logs: {What you found}
- Tested in dev environment: {Result}
- Ran debugger: {Observations}

### Hypotheses
{Your theories about what might be causing this}

1. {Hypothesis 1} - Because {reasoning}
2. {Hypothesis 2} - Because {reasoning}

## Attachments
- [ ] Log files: {filename.log}
- [ ] Screenshots: {screenshot.png}
- [ ] Sample data: {sample-data.json}
- [ ] Configuration: {config.yaml}
- [ ] Network trace: {network-trace.har}

## Checklist
{Verify you've included all necessary information}

- [ ] Clear steps to reproduce
- [ ] Expected vs actual behavior described
- [ ] Environment details provided
- [ ] Error messages included (full stack trace)
- [ ] Screenshots/videos attached (if applicable)
- [ ] Severity justification provided
- [ ] Attempted solutions documented

---

**For Developers**:
{Space for developers to add investigation notes}

**Status**: New | Investigating | In Progress | Resolved | Won't Fix
**Assigned To**: {Developer name}
**Root Cause**: {To be filled during investigation}
**Fix Version**: {Target version for fix}
