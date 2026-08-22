# ---
name: architecture-patterns
description: Comprehensive templates and methodologies for software architecture and system design. Use when designing new systems, creating technical specifications, documenting architectural decisions, or reviewing designs. Provides structured templates for ADRs, system design documents, API specifications, component designs, and architecture reviews.
---

# Architecture Patterns

## Overview

This skill provides production-ready templates and systematic methodologies for software architecture and system design. It complements the @architect agent by providing standardized formats, design patterns, evaluation frameworks, and best practices for creating maintainable, scalable systems.

**When to use this skill:**
- Designing new systems or features
- Creating architecture decision records (ADRs)
- Writing technical specifications and design documents
- Designing APIs (REST, GraphQL, gRPC)
- Documenting component interfaces and responsibilities
- Conducting architecture reviews
- Evaluating trade-offs between architectural patterns
- Ensuring security, scalability, and reliability in designs

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive design methodologies.

## Available Templates

This skill provides 5 production-ready templates in `assets/`:

### 1. Architecture Decision Record Template
**File:** `assets/architecture-decision-record-template.md`

Formal template for documenting significant architectural decisions including:
- Context and problem statement
- Decision drivers (requirements that influence decision)
- Options considered (with pros/cons analysis)
- Decision outcome and rationale
- Consequences (positive, negative, risks)
- Detailed analysis of each option
- Implementation plan with phases
- Validation metrics and review triggers

**Use when:** Making significant architectural choices (database selection, framework choice, deployment strategy, architectural pattern, integration approach).

**Example usage:**
```markdown
# ADR-003: Use PostgreSQL for Primary Database

**Status:** Accepted
**Date:** 2024-10-24

## Context
Need relational database for e-commerce platform with ACID requirements, complex queries, and 1M+ users.

## Decision Drivers
- Must support ACID transactions (payment processing)
- Team has 3 years PostgreSQL experience
- Need complex joins and aggregations
- Budget constraint: $500/month database costs
- Must scale to 10M transactions/month

## Considered Options
1. PostgreSQL - Mature RDBMS with excellent features
2. MySQL - Popular alternative
3. MongoDB - NoSQL document database

## Decision: PostgreSQL

**Rationale:**
- Full ACID compliance critical for financial data
- Advanced features (JSON columns, full-text search)
- Strong ecosystem (SQLAlchemy, psycopg3)
- Team expertise reduces risk and learning curve
- AWS RDS managed service fits budget

[Continue with template sections...]
```

---

### 2. System Design Document Template
**File:** `assets/system-design-document-template.md`

Complete system design documentation format with:
- Executive summary and table of contents
- Requirements (functional, non-functional, constraints)
- Architecture design (high-level, component design, data flow)
- Technology choices with rationale
- Code organization and module structure
- API design (endpoints, data models, error handling)
- Testing strategy (unit, integration, e2e, performance)
- Risks & mitigations
- Implementation plan with phases and timeline
- Deployment considerations (environments, monitoring, rollout)

**Use when:** Designing new systems, major features, or significant refactors requiring comprehensive technical planning.

**Example usage:**
```markdown
# Real-Time Notification System Design

**Version:** 1.0
**Status:** Approved

## Executive Summary
This document describes the architecture for a multi-channel notification system delivering email, SMS, and push notifications at 10k/minute with guaranteed delivery.

## Requirements

### Functional Requirements
**FR1: Multi-Channel Delivery**
- Support: Email (SendGrid), SMS (Twilio), Push (FCM)
- Priority: Critical
- Acceptance: Successfully send via any channel

**FR2: Template Management**
- Dynamic templates with variable substitution
- Preview before send
- Version control

### Non-Functional Requirements
**Performance:**
- Process 10k notifications/minute
- API response <50ms (P95)
- End-to-end delivery <5 seconds

**Scalability:**
- Scale to 100k notifications/minute (10x headroom)
- Support 1M users at launch

[Continue with remaining sections...]
```

---

### 3. API Specification Template
**File:** `assets/api-specification-template.md`

Comprehensive API documentation format including:
- Overview (purpose, features, design principles)
- Authentication (API keys, OAuth 2.0, JWT)
- Endpoints (detailed request/response specs)
- Data models (TypeScript interfaces, schemas)
- Error handling (error formats, types, retry logic)
- Rate limiting (limits, headers, strategies)
- Webhooks (events, payloads, signature verification)
- Idempotency patterns
- Versioning strategy
- Code examples (Python, JavaScript, cURL)
- Testing guidance (test mode, test data)

**Use when:** Designing REST APIs, GraphQL schemas, gRPC services, or documenting existing APIs.

**Example usage:**
```markdown
# User Management API Specification

**Version:** 1.0.0
**Base URL:** `https://api.example.com/v1`
**Protocol:** REST

## Authentication
All requests require Bearer token:
```http
Authorization: Bearer sk_live_abc123def456
```

## Endpoints

### Create User
**POST /v1/users**

Creates a new user account.

```http
POST /v1/users
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user"
}

Response 201 Created:
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user",
  "created_at": "2024-10-24T10:30:00Z"
}
```

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address |
| name | string | Yes | User's full name |
| role | string | No | User role (default: "user") |

**Errors:**
| Code | Status | Description |
|------|--------|-------------|
| email_exists | 400 | Email already registered |
| invalid_email | 400 | Email format invalid |

[Continue with more endpoints...]
```

---

### 4. Component Design Template
**File:** `assets/component-design-template.md`

Detailed component specification format with:
- Overview (purpose, scope, position in system)
- Component details (inputs, outputs, interfaces)
- Dependencies (external deps, config, state management)
- Implementation design (class structure, error handling, performance)
- Testing strategy (unit tests, integration tests, coverage targets)
- Deployment considerations (configuration, monitoring, scaling)

**Use when:** Designing individual services, classes, modules, or libraries requiring detailed specification.

**Example usage:**
```markdown
# Component Design: NotificationService

**Version:** 1.0
**Status:** Approved

## Overview

### Purpose
Orchestrates delivery of notifications across email, SMS, and push channels with template rendering, retry logic, and delivery tracking.

### Responsibilities
- Validate notification requests
- Render templates with user data
- Route to appropriate provider (SendGrid, Twilio, FCM)
- Handle retries with exponential backoff
- Track delivery status
- Publish lifecycle events

### NOT Responsible For
- Template creation (TemplateService)
- User management (UserService)
- Provider implementation (EmailProvider, SMSProvider)

## Inputs

**NotificationRequest:**
```python
@dataclass
class NotificationRequest:
    user_id: str
    channel: NotificationChannel  # email, sms, push
    template_id: str
    data: Dict[str, Any]
    priority: Priority = Priority.NORMAL
    scheduled_at: Optional[datetime] = None
```

**Validation Rules:**
- user_id: Must be valid UUID
- channel: Must be supported (email|sms|push)
- template_id: Must exist in template registry
- data: Must contain all required template variables

## Interfaces

### Public Methods

**send(request: NotificationRequest) -> NotificationResult**
```python
def send(self, request: NotificationRequest) -> NotificationResult:
    """
    Send notification immediately or schedule for future.

    Args:
        request: Notification configuration

    Returns:
        NotificationResult with status and ID

    Raises:
        InvalidTemplateError: Template missing/invalid
        RateLimitError: User rate limit exceeded
        ProviderError: All providers failed
    """
```

[Continue with implementation details...]
```

---

### 5. Architecture Review Checklist Template
**File:** `assets/architecture-review-checklist-template.md`

Systematic review checklist covering:
- Requirements & scope (clarity, completeness)
- Architecture design (components, patterns, design quality)
- Scalability (horizontal scaling, performance, data volume)
- Reliability (error handling, data integrity, fault tolerance)
- Security (auth/authz, data protection, input validation)
- Maintainability (code organization, testability, documentation)
- Observability (logging, monitoring, alerting, tracing)
- Technology choices (justification, dependencies, data storage)
- Integration & APIs (design, external deps, compatibility)
- Deployment & operations (strategy, configuration, infrastructure)
- Risks & mitigations (assessment, assumptions, constraints)
- Compliance & standards (regulatory, internal standards)

**Use when:** Conducting formal architecture reviews, validating designs before implementation, ensuring quality standards.

**Example usage:**
```markdown
# Architecture Review: Real-Time Chat System

**Date:** 2024-10-24
**Reviewer:** Senior Architect
**Status:** In Progress

## 2. Architecture Design

### 2.1 High-Level Design
- [✅] System components clearly identified
- [✅] Component responsibilities well-defined
- [✅] Data flow documented
- [⚠️] Integration points need more detail
- [✅] Architecture diagram provided

**Rating:** ⚠️ Needs Improvement

**Notes:** Integration with existing auth system needs clarification. How does WebSocket auth work with current JWT tokens?

### 2.2 Component Design
- [✅] Single responsibility per component
- [✅] Interfaces well-defined
- [❌] State management approach unclear
- [✅] Error handling defined

**Rating:** ❌ Insufficient

**Notes:** CRITICAL: How is WebSocket connection state managed? What happens on server restart? Need reconnection strategy and state recovery plan.

[Continue reviewing all sections...]

## Summary

**Overall:** ⚠️ Needs Improvement
**Readiness:** Ready with minor changes

### Critical Issues (Must Fix)
1. Define WebSocket state management and recovery strategy
2. Specify message ordering guarantees
3. Add load testing plan for 10k concurrent connections

### Recommended Improvements
1. Add circuit breaker for database calls
2. Consider Redis Pub/Sub for horizontal scaling
3. Add metrics for message delivery latency
```

---

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. Architectural Patterns Guide
**File:** `references/architectural-patterns.md`

Comprehensive coverage of common architectural patterns organized by category:

**Structural Patterns:**
- **Layered Architecture (N-Tier):** Traditional presentation/business/data layers with clear separation
- **Microservices:** Independent services with own databases, communicating via APIs/events
- **Hexagonal Architecture (Ports & Adapters):** Isolate core business logic from external concerns
- **Event-Driven Architecture:** Components communicate via events, loose coupling, async workflows
- **CQRS (Command Query Responsibility Segregation):** Separate read/write models for optimization

**Communication Patterns:**
- **API Gateway:** Single entry point for clients, handles routing, auth, rate limiting
- **Service Mesh:** Infrastructure layer for service-to-service communication (Istio, Linkerd)

**Data Patterns:**
- **Database per Service:** Each microservice owns its database for independence
- **Event Sourcing:** Store all state changes as events, rebuild state by replaying

**Scalability Patterns:**
- **Sharding:** Horizontal database partitioning by shard key
- **Read Replicas:** Distribute read load across multiple database copies

**Resilience Patterns:**
- **Circuit Breaker:** Prevent cascade failures by stopping calls to failing services
- **Retry with Exponential Backoff:** Retry transient failures with increasing delays

**Pattern Selection Guide:**
| Need | Pattern |
|------|---------|
| Simple web app | Layered Architecture |
| Large complex system | Microservices |
| Domain-driven design | Hexagonal Architecture |
| Async workflows | Event-Driven |
| Different read/write needs | CQRS |

**Use when:** Choosing architectural pattern, evaluating alternatives, understanding pattern trade-offs.

---

### 2. Design Principles Guide
**File:** `references/design-principles.md`

Core principles for maintainable, scalable software with detailed explanations and examples:

**SOLID Principles:**
1. **Single Responsibility (SRP):** One reason to change per class/module
2. **Open/Closed (OCP):** Open for extension, closed for modification
3. **Liskov Substitution (LSP):** Subtypes substitutable for base types
4. **Interface Segregation (ISP):** Focused interfaces, no unused methods
5. **Dependency Inversion (DIP):** Depend on abstractions, not implementations

**General Principles:**
- **DRY (Don't Repeat Yourself):** Single representation of knowledge
- **KISS (Keep It Simple):** Simple over clever solutions
- **YAGNI (You Aren't Gonna Need It):** Implement only current requirements
- **Separation of Concerns:** Divide into distinct features with minimal overlap
- **Law of Demeter:** Don't talk to strangers, avoid chaining

**Microservices Principles:**
- **Domain-Driven Design (DDD):** Bounded contexts, ubiquitous language, aggregates
- **Service Boundaries:** Business capabilities over technical layers

**API Design Principles:**
- **RESTful Design:** Resources over actions, proper HTTP verbs and status codes
- **API Versioning:** Version from day 1, manage breaking changes
- **Idempotency:** Multiple identical requests = same effect as single request

**Database Principles:**
- **Normalization:** Reduce redundancy (1NF, 2NF, 3NF)
- **Database per Service:** Each microservice owns its database

**Anti-Patterns:**
- God Object, Tight Coupling, Premature Optimization, Over-Engineering, Golden Hammer

**Use when:** Reviewing design quality, making architectural decisions, evaluating code organization.

---

### 3. Scalability Patterns Guide
**File:** `references/scalability-patterns.md`

Patterns for handling increased load with implementation examples:

**Caching Strategies:**
- **Cache-Aside (Lazy Loading):** Check cache → miss → load from DB → populate cache
- **Write-Through:** Write to cache and DB simultaneously
- **Write-Behind (Write-Back):** Write to cache immediately, async DB write
- **Cache Invalidation:** TTL, event-based, stampede prevention

**Load Balancing:**
- **Algorithms:** Round Robin, Least Connections, IP Hash (sticky), Weighted Round Robin
- **Health Checks:** Check interval, timeout, threshold configuration

**Database Scaling:**
- **Read Replicas:** Route reads to replicas, writes to primary, manage replication lag
- **Sharding:** Horizontal partitioning, shard key selection (even distribution, frequently queried, immutable)
- **Partitioning:** Range, List, Hash partitioning strategies

**Asynchronous Processing:**
- **Message Queues:** Decouple producers/consumers (Redis, RabbitMQ, SQS, Kafka)
- **Worker Pools:** Parallel processing with thread/process pools

**Content Delivery:**
- **CDN:** Edge caching for static assets near users
- **Static Asset Optimization:** Compression, versioning, image optimization

**Rate Limiting:**
- **Token Bucket Algorithm:** Tokens refill at rate, consume on request
- **Distributed Rate Limiting:** Redis-based for multi-instance systems

**Scalability Checklist:**
- Application: Stateless, horizontal scaling, load balancer, health checks
- Database: Indexes, query optimization, connection pooling, read replicas, sharding
- Caching: Frequent data cached, TTL configured, invalidation strategy
- Async: Background jobs, message queues, worker auto-scaling
- Monitoring: Metrics tracked, bottlenecks identified, alerts configured

**Use when:** Designing for scale, optimizing performance, handling increased load.

---

### 4. Security Architecture Guide
**File:** `references/security-architecture.md`

Essential security patterns and best practices:

**Defense in Depth:** Multiple security layers (network, auth, validation, encryption, logging)

**Authentication Patterns:**
- **JWT (JSON Web Tokens):** Stateless tokens with expiration, refresh token pattern
- **OAuth 2.0:** Authorization code flow for third-party integrations

**Authorization Patterns:**
- **RBAC (Role-Based Access Control):** Users assigned roles with permissions
- **ABAC (Attribute-Based Access Control):** Fine-grained policies based on attributes

**Data Protection:**
- **Encryption at Rest:** Encrypt PII, use strong algorithms (AES-256), store keys in vault
- **Encryption in Transit:** Force HTTPS, TLS 1.3, security headers (HSTS, CSP, X-Frame-Options)

**Input Validation:**
- **SQL Injection Prevention:** Parameterized queries, ORM usage
- **XSS Prevention:** Escape output, Content Security Policy
- **CSRF Protection:** CSRF tokens, custom headers for APIs

**Secrets Management:**
- **Environment Variables:** Never hardcode secrets
- **Secrets Vault:** HashiCorp Vault, AWS Secrets Manager, Azure Key Vault

**Audit & Compliance:**
- **Audit Logging:** Log auth attempts, authz failures, data access, modifications
- **What NOT to Log:** Passwords, tokens, PII in logs

**Security Checklist:**
- Auth/Authz: Strong passwords, MFA, account lockout, least privilege
- Data Protection: PII encrypted, TLS enforced, secrets in vault, key rotation
- Input Validation: Parameterized queries, output encoding, CSRF tokens, rate limiting
- Dependencies: Regular updates, vulnerability scanning, minimal deps
- Monitoring: Audit logs, security alerts, incident response plan

**Use when:** Designing secure systems, conducting security reviews, implementing authentication.

---

### 5. System Design Methodology Guide
**File:** `references/system-design-methodology.md`

Systematic 4-phase approach to designing software architectures:

**Phase 1: Understand Requirements (30%)**
- **Clarify Functional Requirements:** Core features, user personas, workflows
- **Define Non-Functional Requirements:** Performance, scalability, reliability, security targets
- **Identify Constraints:** Technical, business, regulatory limitations
- **Define Success Criteria:** SMART metrics for launch and scale milestones

**Phase 2: Design Solution (40%)**
- **High-Level Architecture:** Components, data flow, integration points
- **Component Design:** Responsibilities, interfaces, dependencies for each component
- **Data Model Design:** Entity relationships, schemas, indexes
- **API Design:** Endpoints, request/response formats, error handling
- **Technology Selection:** Framework, database, libraries with rationale

**Phase 3: Evaluate Design (20%)**
- **Capacity Planning:** Storage, database, compute calculations and cost estimates
- **Identify Bottlenecks:** Database writes, network bandwidth, search performance
- **Failure Mode Analysis:** What can fail, probability, impact, mitigation
- **Security Review:** Auth, encryption, input validation, audit logging

**Phase 4: Document Design (10%)**
- **Architecture Document:** Use system-design-document-template.md
- **Architecture Decision Records:** Use architecture-decision-record-template.md for major decisions

**Common Pitfalls:**
- Skipping requirements phase (spend 30% here)
- Over-engineering (design for 10x, not 1000x)
- Under-specifying non-functionals (use specific metrics)
- Ignoring constraints (design within constraints)
- No capacity planning (calculate before building)
- Weak failure analysis (document each mode)

**Design Review:** Use architecture-review-checklist-template.md

**Use when:** Designing new systems from scratch, creating comprehensive technical plans.

---

## Usage Patterns

### Pattern 1: Quick Architectural Decision

**Scenario:** Need to document database choice for new feature.

**Process:**
1. Use `architecture-decision-record-template.md`
2. Fill in context, drivers, options (3+ alternatives)
3. Read `architectural-patterns.md` for relevant patterns
4. Justify decision with pros/cons from `design-principles.md`
5. Document consequences and implementation plan

**Time:** 1-2 hours

**Output:** Formal ADR for team and future reference

---

### Pattern 2: New Feature Design

**Scenario:** Designing notification system for application.

**Process:**
1. Read `system-design-methodology.md` → Standard Design section
2. Use `system-design-document-template.md` as structure
3. Define requirements (functional, non-functional, constraints)
4. Read `architectural-patterns.md` → Event-Driven Architecture
5. Design components using `component-design-template.md` for key services
6. Design API using `api-specification-template.md`
7. Read `scalability-patterns.md` for caching and async processing
8. Read `security-architecture.md` for auth and data protection
9. Evaluate with capacity planning and failure analysis
10. Document ADRs for major decisions

**Time:** 1-2 days

**Output:** Complete system design with ADRs and component specs

---

### Pattern 3: API Design

**Scenario:** Creating REST API for mobile app.

**Process:**
1. Use `api-specification-template.md`
2. Read `design-principles.md` → API Design Principles (RESTful, versioning, idempotency)
3. Define endpoints with request/response formats
4. Read `security-architecture.md` → Authentication (JWT/OAuth)
5. Add error handling, rate limiting, webhooks
6. Include code examples and testing guidance

**Time:** 4-8 hours

**Output:** Complete API specification ready for implementation

---

### Pattern 4: Component Design

**Scenario:** Designing payment processing service.

**Process:**
1. Use `component-design-template.md`
2. Read `design-principles.md` → SOLID (SRP, DIP)
3. Define inputs, outputs, interfaces clearly
4. List dependencies (payment gateway, database, event bus)
5. Read `scalability-patterns.md` → Retry patterns, circuit breakers
6. Read `security-architecture.md` → PCI compliance, encryption
7. Define testing strategy (unit, integration, mocks)

**Time:** 3-6 hours

**Output:** Detailed component specification ready for implementation

---

### Pattern 5: Architecture Review

**Scenario:** Reviewing microservices design before implementation.

**Process:**
1. Use `architecture-review-checklist-template.md`
2. Read `architectural-patterns.md` → Microservices section
3. Review each checklist section (requirements, design, scalability, security, etc.)
4. Read `design-principles.md` → Service Boundaries, DDD
5. Read `scalability-patterns.md` → Verify scaling strategy
6. Read `security-architecture.md` → Verify security measures
7. Document issues (Critical, Recommended, Optional)
8. Provide sign-off or request changes

**Time:** 2-4 hours

**Output:** Comprehensive review with actionable feedback

---

### Pattern 6: System Design from Scratch

**Scenario:** Designing e-commerce platform from zero.

**Process:**
1. Read `system-design-methodology.md` completely
2. **Phase 1:** Gather requirements (functional, non-functional, constraints, success criteria)
3. **Phase 2:** Design solution
   - Read `architectural-patterns.md` → Choose pattern (likely Microservices)
   - Use `system-design-document-template.md` for structure
   - Design components with `component-design-template.md`
   - Design APIs with `api-specification-template.md`
   - Read `design-principles.md` for SOLID and DDD guidance
4. **Phase 3:** Evaluate design
   - Capacity planning calculations
   - Read `scalability-patterns.md` → Implement caching, sharding, async
   - Failure mode analysis
   - Read `security-architecture.md` → Security review
5. **Phase 4:** Document
   - Complete system design document
   - Create ADRs for major decisions (database, architecture pattern, payment gateway)
   - Use `architecture-review-checklist-template.md` for self-review

**Time:** 3-5 days

**Output:** Production-ready architecture with complete documentation

---

## Integration with @architect

This skill is designed to complement the @architect agent:

**Agent's Role:**
- Analyzes requirements and constraints
- Makes architectural decisions based on trade-offs
- Applies domain expertise and judgment
- Creates design documents

**Skill's Role:**
- Provides standardized templates for consistency
- Offers reference patterns and best practices
- Ensures quality standards are met
- Prevents common pitfalls

**Workflow:**
```markdown
User: "@architect, design a real-time notification system"

Agent:
1. Loads architecture-patterns skill
2. Reads system-design-methodology.md for systematic process
3. Reads architectural-patterns.md for event-driven and microservices patterns
4. Reads scalability-patterns.md for async processing and message queues
5. Reads security-architecture.md for auth and encryption
6. Uses system-design-document-template.md to structure output
7. Creates component designs using component-design-template.md
8. Documents key decisions using architecture-decision-record-template.md
9. Delivers complete, high-quality architecture design
```

---

## Best Practices

### 1. Start with Methodology
Always read `system-design-methodology.md` first to understand the systematic 4-phase process (Understand, Design, Evaluate, Document).

### 2. Use Appropriate Template
- Quick decision → `architecture-decision-record-template.md`
- Component design → `component-design-template.md`
- API design → `api-specification-template.md`
- Full system → `system-design-document-template.md`
- Review → `architecture-review-checklist-template.md`

### 3. Justify Technology Choices
Use `architectural-patterns.md` and `design-principles.md` to justify every major decision. Document alternatives considered.

### 4. Design for 10x, Not 1000x
Avoid over-engineering. Design for 10x current scale with clear path to 100x if needed.

### 5. Document Decisions with ADRs
Create ADR for every significant architectural decision (database, framework, architecture pattern, third-party service). Future you will thank you.

### 6. Security from Day 1
Read `security-architecture.md` during design phase, not after implementation. Security is hard to retrofit.

### 7. Evaluate with Numbers
Use capacity planning from `system-design-methodology.md`. Calculate storage, compute, cost before building.

### 8. Review Before Implementation
Use `architecture-review-checklist-template.md` for self-review or peer review. Catch issues early.

### 9. Consider Failure Modes
Read `scalability-patterns.md` → Resilience patterns. Every external dependency needs retry logic and circuit breaker.

### 10. Keep It Simple
Apply KISS and YAGNI from `design-principles.md`. Simple solutions are easier to implement, test, and maintain.

---

## Resources

### assets/
Template files designed to be copied and customized:

- **architecture-decision-record-template.md** - Formal ADR format with context, decision, consequences
- **system-design-document-template.md** - Complete system design documentation
- **api-specification-template.md** - Comprehensive API documentation (REST/GraphQL/gRPC)
- **component-design-template.md** - Detailed component specification
- **architecture-review-checklist-template.md** - Systematic design review checklist

**Usage:** Copy template, fill sections with design details, customize as needed for project.

### references/
Comprehensive reference guides loaded into context:

- **architectural-patterns.md** - Structural, communication, data, scalability, resilience patterns with selection guide
- **design-principles.md** - SOLID, general principles (DRY, KISS, YAGNI), microservices, API, database principles
- **scalability-patterns.md** - Caching, load balancing, database scaling, async processing, CDN, rate limiting
- **security-architecture.md** - Defense in depth, authentication, authorization, data protection, input validation, secrets, audit
- **system-design-methodology.md** - 4-phase systematic approach (Understand, Design, Evaluate, Document)

**Usage:** Read relevant sections to inform design decisions and ensure best practices.

---

## Examples

### Example 1: Documenting Database Decision

```markdown
User: "Help me decide between PostgreSQL and MongoDB for user data"

Process:
1. Use architecture-decision-record-template.md
2. Read architectural-patterns.md → Database per Service pattern
3. Read design-principles.md → Database Design Principles (normalization)
4. Analyze requirements:
   - Need: Relational data (users, orders, payments)
   - Scale: 100k users, 1M transactions
   - Constraints: Team knows PostgreSQL, ACID required
5. Evaluate options:
   - PostgreSQL: ACID, relations, team expertise
   - MongoDB: Flexible schema, horizontal scaling, learning curve
6. Create ADR documenting decision

Output:
# ADR-002: PostgreSQL for User Database

**Decision:** PostgreSQL

**Rationale:**
- ACID compliance required for payment transactions
- Relational model fits user/order/payment relationships
- Team has 2 years PostgreSQL experience
- Advanced features (JSON columns, full-text search)
- Managed RDS within budget ($200/month)

**Alternatives:**
- MongoDB: Better horizontal scaling but no ACID, team unfamiliar
- MySQL: Similar to PostgreSQL but fewer advanced features

**Consequences:**
+ Strong data consistency
+ Proven at scale (Instagram, Uber)
- Vertical scaling limits (mitigate with read replicas)
```

---

### Example 2: Designing Microservices Architecture

```markdown
User: "Design microservices for e-commerce platform"

Process:
1. Read system-design-methodology.md → Phase 1 (Requirements)
2. Read architectural-patterns.md → Microservices pattern
3. Read design-principles.md → Service Boundaries, DDD
4. Define services by business capability:
   - User Service (auth, profiles)
   - Product Catalog (inventory, search)
   - Order Service (cart, checkout, fulfillment)
   - Payment Service (processing, refunds)
   - Notification Service (email, SMS)
5. Use system-design-document-template.md for documentation
6. Create component-design-template.md for Order Service
7. Read scalability-patterns.md → Message queues for async orders
8. Read security-architecture.md → Auth (OAuth), PCI compliance
9. Create ADRs for:
   - ADR-001: Microservices architecture
   - ADR-002: Event-driven communication (Kafka)
   - ADR-003: Database per service pattern
   - ADR-004: API Gateway (Kong)

Output:
- Complete system design document with architecture diagram
- 5 microservices with clear boundaries
- Event-driven async workflows
- API Gateway for client access
- Security strategy (OAuth, encryption, audit logs)
- Scalability plan (horizontal scaling, caching, sharding)
- 4 ADRs documenting major decisions
```

---

### Example 3: API Design for Mobile App

```markdown
User: "Design REST API for mobile banking app"

Process:
1. Use api-specification-template.md
2. Read design-principles.md → RESTful Design, Versioning, Idempotency
3. Read security-architecture.md → JWT Authentication, Encryption
4. Design endpoints:
   - POST /v1/auth/login
   - GET /v1/accounts
   - GET /v1/accounts/{id}/transactions
   - POST /v1/transfers (idempotent)
   - GET /v1/transfers/{id}
5. Add security:
   - JWT tokens (15min expiration)
   - Refresh tokens (30 days)
   - Rate limiting (100 req/hour per user)
   - TLS 1.3 required
6. Add error handling, webhooks, versioning
7. Include Python and JavaScript code examples

Output:
# Banking API Specification v1.0

**Base URL:** https://api.bank.com/v1
**Auth:** JWT Bearer tokens

## Endpoints

### POST /v1/transfers
Transfer money between accounts.

**Idempotency:** Use `Idempotency-Key` header to prevent duplicate transfers

Request:
{
  "from_account": "acc_123",
  "to_account": "acc_456",
  "amount": 100.00,
  "currency": "USD"
}

Response 201:
{
  "id": "txn_789",
  "status": "pending",
  "created_at": "2024-10-24T10:30:00Z"
}

Errors:
- insufficient_funds (400)
- invalid_account (404)
- rate_limit_exceeded (429)

[Complete spec with all endpoints, security, examples]
```

---

## Tips & Tricks

### Tip 1: Create ADR Repository
Store all ADRs in `docs/adr/` directory numbered sequentially (001, 002, 003). They're invaluable for onboarding and debugging decisions.

### Tip 2: Diagram Tools
- Simple diagrams: ASCII art in markdown (works everywhere)
- Professional diagrams: draw.io, Excalidraw (free, version controllable)
- Auto-generated: Mermaid, PlantUML (code-based diagrams)

### Tip 3: Design Incrementally
Don't design entire system upfront. Design MVP, get feedback, iterate. Use YAGNI principle.

### Tip 4: Capacity Planning Spreadsheet
Create Google Sheets with formulas for storage, compute, cost calculations. Reuse across projects.

### Tip 5: Review Existing Systems
Before designing new system, read ADRs and design docs from similar systems. Learn from past decisions.

### Tip 6: Pattern Language
Use consistent terminology from `architectural-patterns.md`. Entire team should speak same language.

### Tip 7: Security Checklist
Print `security-architecture.md` checklist and use for every design review. Security is too important to skip.

### Tip 8: API-First Design
Design API before implementation using `api-specification-template.md`. Frontend and backend can work in parallel with mocks.

### Tip 9: Failure Testing
For every component, ask "What if this fails?" and design mitigation. Read `scalability-patterns.md` resilience section.

### Tip 10: Review Schedule
Schedule architecture reviews at key milestones: after design, after MVP, after launch, every 6 months. Use `architecture-review-checklist-template.md`.

---

**Related Skills:**
- research-templates - For evaluating technology choices

**Related Agents:**
- @architect - Primary consumer of these templates and methodologies
- @technical-researcher - For researching technology alternatives before decisions
