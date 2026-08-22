# Architecture Review Checklist: {Feature/System Name}

**Date:** YYYY-MM-DD
**Reviewer(s):** [Names]
**Design Document:** [Link to design doc]
**Status:** [In Progress | Complete]

## Instructions

Use this checklist to systematically review architecture designs before implementation. Rate each criterion as:
- ✅ **Meets Standard** - No concerns
- ⚠️ **Needs Improvement** - Minor issues, should address before implementation
- ❌ **Insufficient** - Major issues, must address before proceeding
- N/A **Not Applicable** - Criterion doesn't apply to this design

## 1. Requirements & Scope

### 1.1 Requirements Clarity
- [ ] Functional requirements clearly documented
- [ ] Non-functional requirements specified (performance, scalability, reliability)
- [ ] Success criteria measurable and testable
- [ ] Edge cases and constraints identified

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**
[Comments on requirements quality]

### 1.2 Scope Management
- [ ] In-scope features clearly listed
- [ ] Out-of-scope items explicitly called out
- [ ] Future enhancements documented separately
- [ ] Dependencies on other systems identified

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 2. Architecture Design

### 2.1 High-Level Design
- [ ] System components clearly identified
- [ ] Component responsibilities well-defined
- [ ] Data flow documented and understandable
- [ ] Integration points specified
- [ ] Architecture diagram provided

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 2.2 Component Design
- [ ] Each component has single, clear responsibility
- [ ] Interfaces well-defined (inputs/outputs)
- [ ] Dependencies explicitly documented
- [ ] State management approach specified
- [ ] Error handling strategy defined

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 2.3 Design Patterns
- [ ] Appropriate design patterns selected
- [ ] Patterns applied consistently
- [ ] Trade-offs of pattern choices documented
- [ ] Anti-patterns avoided

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 3. Scalability

### 3.1 Horizontal Scalability
- [ ] Components can scale horizontally if needed
- [ ] No single points of failure
- [ ] Stateless design where appropriate
- [ ] Load balancing strategy defined
- [ ] Session management approach specified (if stateful)

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 3.2 Performance
- [ ] Performance targets specified (latency, throughput)
- [ ] Bottlenecks identified and addressed
- [ ] Caching strategy defined where appropriate
- [ ] Database indexing considered
- [ ] Query optimization addressed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 3.3 Data Volume Planning
- [ ] Expected data volumes documented
- [ ] Storage growth projections provided
- [ ] Data archival/retention strategy defined
- [ ] Database partitioning/sharding considered if needed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 4. Reliability

### 4.1 Error Handling
- [ ] Error scenarios identified
- [ ] Error handling strategy consistent across components
- [ ] Retry logic with backoff for transient failures
- [ ] Circuit breakers for external dependencies
- [ ] Graceful degradation defined

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 4.2 Data Integrity
- [ ] ACID requirements addressed
- [ ] Eventual consistency acceptable where used
- [ ] Data validation at boundaries
- [ ] Transaction boundaries defined
- [ ] Idempotency considerations addressed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 4.3 Fault Tolerance
- [ ] Single point of failure analysis conducted
- [ ] Redundancy strategy defined where needed
- [ ] Failover mechanism specified
- [ ] Data backup and recovery plan
- [ ] Disaster recovery considered

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 5. Security

### 5.1 Authentication & Authorization
- [ ] Authentication method specified
- [ ] Authorization model defined (RBAC, ABAC, etc.)
- [ ] Principle of least privilege applied
- [ ] Session management secure
- [ ] API key/token handling secure

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 5.2 Data Protection
- [ ] Sensitive data identified
- [ ] Encryption at rest where required
- [ ] Encryption in transit (TLS/HTTPS)
- [ ] PII handling compliant with regulations
- [ ] Data sanitization for logs/errors

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 5.3 Input Validation
- [ ] All inputs validated (API, UI, config)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention
- [ ] CSRF protection (for web apps)
- [ ] Rate limiting implemented

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 5.4 Security Best Practices
- [ ] Dependencies scanned for vulnerabilities
- [ ] Secrets management strategy (env vars, vault, etc.)
- [ ] Security headers configured
- [ ] Audit logging for sensitive operations
- [ ] Security review completed or scheduled

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 6. Maintainability

### 6.1 Code Organization
- [ ] Clear module/package structure
- [ ] Naming conventions defined and followed
- [ ] Separation of concerns maintained
- [ ] Dependencies managed explicitly
- [ ] Configuration externalized

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 6.2 Testability
- [ ] Unit testing strategy defined
- [ ] Integration testing approach specified
- [ ] Test coverage targets set (e.g., 80%)
- [ ] Mocking strategy for external dependencies
- [ ] Test data management approach

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 6.3 Documentation
- [ ] API documentation provided (if applicable)
- [ ] Component interfaces documented
- [ ] Configuration documented
- [ ] Deployment process documented
- [ ] Troubleshooting guide included

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 6.4 Code Quality
- [ ] Linting/formatting standards defined
- [ ] Code review process established
- [ ] Static analysis tools configured
- [ ] Complexity metrics considered
- [ ] Technical debt explicitly identified

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 7. Observability

### 7.1 Logging
- [ ] Logging strategy defined (what to log, where)
- [ ] Log levels used appropriately
- [ ] Structured logging (JSON) considered
- [ ] Sensitive data excluded from logs
- [ ] Log aggregation/centralization addressed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 7.2 Monitoring
- [ ] Key metrics identified (latency, throughput, errors)
- [ ] Monitoring tools/platform specified
- [ ] Dashboards planned or created
- [ ] SLIs/SLOs defined where appropriate
- [ ] Health check endpoints implemented

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 7.3 Alerting
- [ ] Alert conditions defined
- [ ] Alert thresholds specified
- [ ] Alert routing/escalation defined
- [ ] Runbooks for common alerts
- [ ] Alert fatigue mitigation considered

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 7.4 Tracing & Debugging
- [ ] Distributed tracing implemented (if microservices)
- [ ] Correlation IDs used across requests
- [ ] Debug modes available
- [ ] Performance profiling capability
- [ ] Error tracking service integrated

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 8. Technology Choices

### 8.1 Language & Framework
- [ ] Technology choices justified with rationale
- [ ] Team has expertise or can acquire it
- [ ] Technology is mature and maintained
- [ ] Community support available
- [ ] License compatible with project

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 8.2 Libraries & Dependencies
- [ ] Dependencies minimized
- [ ] All dependencies necessary and justified
- [ ] License compatibility verified
- [ ] Dependencies actively maintained
- [ ] Vulnerability scanning process defined

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 8.3 Data Storage
- [ ] Database choice appropriate for use case
- [ ] Data model designed and documented
- [ ] Indexing strategy defined
- [ ] Migration strategy defined
- [ ] Backup and restore tested

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 9. Integration & APIs

### 9.1 API Design
- [ ] API versioning strategy defined
- [ ] RESTful conventions followed (if REST)
- [ ] Request/response formats documented
- [ ] Error responses standardized
- [ ] Pagination implemented for list endpoints

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 9.2 External Dependencies
- [ ] All external services identified
- [ ] SLAs/availability understood
- [ ] Retry/timeout strategies defined
- [ ] Fallback behavior for outages
- [ ] Cost implications assessed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 9.3 Backwards Compatibility
- [ ] Breaking changes identified
- [ ] Migration path defined for breaking changes
- [ ] Deprecation strategy for old APIs
- [ ] Versioning approach supports transition period

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 10. Deployment & Operations

### 10.1 Deployment Strategy
- [ ] Deployment process documented
- [ ] CI/CD pipeline defined
- [ ] Blue-green or canary deployment considered
- [ ] Rollback procedure defined
- [ ] Database migration strategy specified

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 10.2 Configuration Management
- [ ] Configuration externalized (not hardcoded)
- [ ] Environment-specific configs managed
- [ ] Secrets management secure
- [ ] Feature flags implemented where appropriate
- [ ] Configuration validation on startup

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 10.3 Infrastructure
- [ ] Infrastructure as code used
- [ ] Resource requirements estimated (CPU, memory, storage)
- [ ] Auto-scaling configured if needed
- [ ] Network topology documented
- [ ] Cost estimation provided

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 10.4 Operational Readiness
- [ ] Runbooks created for common operations
- [ ] Troubleshooting guides available
- [ ] On-call procedures defined
- [ ] Incident response plan documented
- [ ] Post-mortem process established

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 11. Risks & Mitigations

### 11.1 Risk Assessment
- [ ] Technical risks identified
- [ ] Likelihood and impact assessed for each risk
- [ ] Mitigation strategies defined
- [ ] Fallback plans documented
- [ ] Risk owners assigned

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 11.2 Assumptions & Constraints
- [ ] Key assumptions documented
- [ ] Constraints clearly stated
- [ ] Dependency on assumptions acknowledged
- [ ] Plan for validating assumptions

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## 12. Compliance & Standards

### 12.1 Regulatory Compliance
- [ ] Applicable regulations identified (GDPR, HIPAA, etc.)
- [ ] Compliance requirements addressed
- [ ] Data residency requirements met
- [ ] Audit trail requirements satisfied
- [ ] Legal review completed if needed

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

### 12.2 Internal Standards
- [ ] Coding standards followed
- [ ] Architectural patterns consistent with org standards
- [ ] Technology choices align with approved stack
- [ ] Security policies complied with
- [ ] Documentation standards met

**Rating:** [✅ | ⚠️ | ❌ | N/A]

**Notes:**

## Summary

### Overall Assessment

**Architecture Quality:** [Excellent | Good | Needs Improvement | Insufficient]

**Readiness for Implementation:** [Ready | Ready with minor changes | Needs significant work | Not ready]

### Key Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

### Critical Issues (Must Fix)

1. [Issue 1 with recommended resolution]
2. [Issue 2 with recommended resolution]

### Recommended Improvements (Should Fix)

1. [Improvement 1]
2. [Improvement 2]
3. [Improvement 3]

### Optional Enhancements (Nice to Have)

1. [Enhancement 1]
2. [Enhancement 2]

### Follow-Up Actions

- [ ] [Action 1] - Owner: [Name] - Due: [Date]
- [ ] [Action 2] - Owner: [Name] - Due: [Date]
- [ ] [Action 3] - Owner: [Name] - Due: [Date]

### Sign-Off

**Architect:** [Name] - [Date] - [Approved | Approved with conditions | Not approved]

**Technical Lead:** [Name] - [Date] - [Approved | Approved with conditions | Not approved]

**Security Review:** [Name] - [Date] - [Approved | Approved with conditions | Not approved]

**Operations Review:** [Name] - [Date] - [Approved | Approved with conditions | Not approved]

---

**Checklist Version:** 1.0
**Last Updated:** 2024-10-24
