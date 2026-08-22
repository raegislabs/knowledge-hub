# QA Checklist: {Feature Name}

## Feature Information

**Feature**: {Feature Name}
**Version**: vX.Y.Z
**QA Engineer**: {Name}
**Test Date**: YYYY-MM-DD
**Status**: In Progress / Complete

---

## 1. Functional Testing

### Core Functionality
- [ ] All primary features work as specified
- [ ] Feature meets acceptance criteria
- [ ] Business logic correctly implemented
- [ ] Data validation working correctly
- [ ] Required fields enforced
- [ ] Optional fields handled properly

### Input Validation
- [ ] Valid inputs accepted
- [ ] Invalid inputs rejected with appropriate errors
- [ ] Boundary values tested (min/max)
- [ ] Empty input handled correctly
- [ ] Null/None values handled
- [ ] Special characters handled (if applicable)
- [ ] SQL injection prevention (if database involved)
- [ ] XSS prevention (if user input displayed)

### Output Validation
- [ ] Correct data returned
- [ ] Data format correct (JSON, XML, etc.)
- [ ] Response codes correct (200, 400, 500, etc.)
- [ ] Error messages clear and actionable
- [ ] Success messages displayed when appropriate

### Edge Cases
- [ ] Empty dataset handling
- [ ] Single item handling
- [ ] Large dataset handling
- [ ] Concurrent operations
- [ ] Timeout scenarios
- [ ] Rate limiting (if applicable)

---

## 2. User Interface Testing

### Visual Design
- [ ] Layout matches design specifications
- [ ] Responsive design works on all screen sizes
- [ ] Mobile viewport tested (if applicable)
- [ ] Tablet viewport tested (if applicable)
- [ ] Desktop viewport tested
- [ ] Colors match brand guidelines
- [ ] Fonts and typography correct
- [ ] Icons displayed correctly
- [ ] Images load correctly

### Usability
- [ ] Navigation intuitive and clear
- [ ] Forms easy to complete
- [ ] Error messages helpful
- [ ] Loading states displayed
- [ ] Progress indicators shown (if applicable)
- [ ] Tooltips/help text present where needed
- [ ] Keyboard navigation works
- [ ] Focus indicators visible

### Accessibility (WCAG 2.1 AA)
- [ ] Color contrast ratio ≥ 4.5:1
- [ ] All images have alt text
- [ ] Forms have proper labels
- [ ] ARIA labels used appropriately
- [ ] Keyboard-only navigation possible
- [ ] Screen reader compatible
- [ ] No keyboard traps
- [ ] Skip navigation links present

### Browser Compatibility
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

---

## 3. Performance Testing

### Load Time
- [ ] Page load time < 3 seconds
- [ ] API response time < 1 second
- [ ] Database queries optimized
- [ ] Images optimized and compressed
- [ ] CSS/JS minified and bundled

### Resource Usage
- [ ] Memory usage acceptable
- [ ] CPU usage reasonable
- [ ] Network requests minimized
- [ ] No memory leaks detected
- [ ] Lazy loading implemented (where appropriate)

### Scalability
- [ ] Handles expected user load
- [ ] Graceful degradation under heavy load
- [ ] Connection pooling configured correctly
- [ ] Caching implemented where beneficial

---

## 4. Security Testing

### Authentication
- [ ] Login functionality secure
- [ ] Password requirements enforced
- [ ] Password hashing implemented (bcrypt/Argon2)
- [ ] Session management secure
- [ ] Logout functionality works
- [ ] Session timeout configured
- [ ] Multi-factor authentication (if applicable)

### Authorization
- [ ] Role-based access control works
- [ ] Users can only access permitted resources
- [ ] Admin functions protected
- [ ] API endpoints require authentication
- [ ] Token-based auth working (JWT, etc.)

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] No sensitive data in logs
- [ ] No sensitive data in URLs
- [ ] PII handled according to regulations
- [ ] SQL injection prevention verified
- [ ] XSS prevention verified
- [ ] CSRF protection implemented

### API Security
- [ ] API keys secured
- [ ] Rate limiting implemented
- [ ] Input sanitization working
- [ ] CORS configured correctly
- [ ] API versioning in place

---

## 5. Integration Testing

### Database Integration
- [ ] Database connections stable
- [ ] CRUD operations work correctly
- [ ] Transactions handled properly
- [ ] Rollback functionality works
- [ ] Foreign key constraints enforced
- [ ] Indexes created for performance

### External APIs
- [ ] API calls successful
- [ ] Error handling for API failures
- [ ] Timeout handling implemented
- [ ] Retry logic working (if applicable)
- [ ] API rate limits respected
- [ ] Fallback behavior defined

### Third-Party Services
- [ ] Payment gateway integration (if applicable)
- [ ] Email service integration
- [ ] Cloud storage integration (if applicable)
- [ ] Analytics tracking working
- [ ] Monitoring/logging configured

---

## 6. Data Testing

### Data Integrity
- [ ] Data saved correctly
- [ ] Data retrieved correctly
- [ ] Data updated correctly
- [ ] Data deleted correctly
- [ ] No data corruption
- [ ] Referential integrity maintained

### Data Migration
- [ ] Migration scripts tested
- [ ] Data migrated without loss
- [ ] Backward compatibility maintained
- [ ] Rollback plan tested

### Data Validation
- [ ] Schema validation working
- [ ] Data type validation correct
- [ ] Business rule validation implemented
- [ ] Duplicate prevention working

---

## 7. Error Handling

### Error Detection
- [ ] Errors detected correctly
- [ ] Appropriate error messages shown
- [ ] Errors logged properly
- [ ] Stack traces not exposed to users
- [ ] Error codes documented

### Error Recovery
- [ ] Graceful degradation on error
- [ ] User can recover from error
- [ ] System returns to stable state
- [ ] Partial failures handled
- [ ] Retry mechanisms work

### Logging
- [ ] All errors logged
- [ ] Log levels appropriate (DEBUG, INFO, ERROR)
- [ ] Log format consistent
- [ ] Sensitive data not logged
- [ ] Logs rotated/archived properly

---

## 8. Test Coverage

### Unit Tests
- [ ] All functions have unit tests
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Code coverage ≥ 90%
- [ ] All tests passing

### Integration Tests
- [ ] Component interactions tested
- [ ] Database integration tested
- [ ] API integration tested
- [ ] All integration tests passing

### Regression Tests
- [ ] Existing functionality still works
- [ ] No new bugs introduced
- [ ] Critical paths verified
- [ ] Smoke tests passing

---

## 9. Documentation

### Code Documentation
- [ ] Functions have docstrings
- [ ] Complex logic commented
- [ ] API endpoints documented
- [ ] Type hints present (Python)
- [ ] README updated

### User Documentation
- [ ] User guide updated
- [ ] Feature documentation written
- [ ] Screenshots/videos included (if applicable)
- [ ] FAQ updated
- [ ] Release notes prepared

### Technical Documentation
- [ ] Architecture documented
- [ ] Database schema documented
- [ ] API documentation updated
- [ ] Configuration documented
- [ ] Deployment guide updated

---

## 10. Deployment Readiness

### Environment Configuration
- [ ] Environment variables documented
- [ ] Configuration files correct
- [ ] Secrets/keys secured
- [ ] Database migrations ready
- [ ] Feature flags configured (if applicable)

### Deployment Validation
- [ ] Staging environment tested
- [ ] Production deployment plan reviewed
- [ ] Rollback plan documented
- [ ] Monitoring configured
- [ ] Alerts configured

### Post-Deployment
- [ ] Smoke tests defined
- [ ] Monitoring dashboard ready
- [ ] Incident response plan documented
- [ ] Support team briefed

---

## Issues Found

| Issue ID | Severity | Description | Status |
|----------|----------|-------------|--------|
| BUG-XXX | High | Description of issue | Open |
|  |  |  |  |

---

## Test Summary

**Total Checks**: X
**Passed**: X
**Failed**: X
**Blocked**: X
**Not Applicable**: X

**Overall Status**: Pass / Fail / Conditional Pass

**Conditional Pass Criteria**:
- All critical and high severity issues resolved
- Medium/low severity issues documented and acceptable

---

## Sign-Off

**QA Engineer**: _____________________ Date: _____
**Tech Lead**: _____________________ Date: _____
**Product Owner**: _____________________ Date: _____

**Approved for Release**: Yes / No / Conditional

**Conditions** (if conditional):
-
-

---

## Notes

Additional observations, recommendations, or context:

-
-
