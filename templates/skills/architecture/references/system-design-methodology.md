# System Design Methodology Reference

A systematic approach to designing software architectures from requirements to implementation.

## 4-Phase Design Process

```
1. Understand → 2. Design → 3. Evaluate → 4. Document
   (30%)         (40%)        (20%)         (10%)
```

---

## Phase 1: Understand Requirements (30%)

### Step 1.1: Clarify Functional Requirements

**Ask:**
- What does the system need to do?
- Who are the users?
- What are the core features?
- What are the user workflows?

**Template:**
```markdown
## Functional Requirements

### Core Features
- FR1: Users can create accounts (email/password)
- FR2: Users can upload files (max 100MB)
- FR3: Users can share files with other users
- FR4: Users can search their files

### User Personas
- End Users: Upload and share files
- Admins: Manage users and storage

### User Workflows
1. Sign up → Verify email → Upload file → Share link
2. Login → Search files → Download
```

---

### Step 1.2: Define Non-Functional Requirements

**Categories:**

**Performance:**
- Latency targets (e.g., API response <100ms)
- Throughput (e.g., 1000 requests/second)

**Scalability:**
- Expected load (e.g., 1M users, 10M files)
- Growth projections (e.g., 50% YoY)

**Reliability:**
- Uptime target (e.g., 99.9%)
- RTO/RPO (Recovery Time/Point Objectives)

**Security:**
- Authentication requirements
- Data encryption requirements
- Compliance (GDPR, HIPAA, etc.)

**Template:**
```markdown
## Non-Functional Requirements

### Performance
- API P95 latency <100ms
- File upload: 10MB/second minimum
- Search results in <500ms

### Scalability
- Support 1M users at launch
- 10M total files
- 100k concurrent users

### Reliability
- 99.9% uptime (43 minutes downtime/month)
- Zero data loss
- Automated backups every 6 hours

### Security
- OAuth 2.0 authentication
- Files encrypted at rest
- TLS 1.3 for all connections
- GDPR compliant
```

---

### Step 1.3: Identify Constraints

**Types:**

**Technical Constraints:**
- Must integrate with existing Auth0 system
- Must use Python 3.9+ (team expertise)
- Must run on AWS (existing infrastructure)

**Business Constraints:**
- Budget: $5k/month infrastructure
- Timeline: 3 months to MVP
- Team: 2 backend, 1 frontend engineer

**Regulatory Constraints:**
- GDPR compliance required
- Data residency in EU
- Audit logs for 7 years

**Template:**
```markdown
## Constraints

### Technical
- Use Python (FastAPI) for backend
- PostgreSQL for primary database
- Deploy on AWS ECS
- Integrate with Auth0

### Business
- Infrastructure budget: $5k/month
- Timeline: 3 months
- Team: 3 engineers

### Regulatory
- GDPR compliance
- EU data residency
- 7-year audit retention
```

---

### Step 1.4: Define Success Criteria

**SMART Criteria:**
- **Specific:** Clearly defined
- **Measurable:** Quantifiable metrics
- **Achievable:** Realistic targets
- **Relevant:** Aligned with business goals
- **Time-bound:** Specific timeframes

**Template:**
```markdown
## Success Criteria

### Launch (Month 3)
- [ ] Support 10k users
- [ ] Upload/download works 99% of time
- [ ] Search returns results <1 second
- [ ] Zero security incidents

### Scale (Month 6)
- [ ] Support 100k users
- [ ] 99.9% uptime
- [ ] P95 API latency <100ms
- [ ] Passed security audit
```

---

## Phase 2: Design Solution (40%)

### Step 2.1: High-Level Architecture

**Start with boxes and arrows:**

```
┌─────────┐     ┌──────────┐     ┌─────────┐
│ Client  │────▶│   API    │────▶│Database │
└─────────┘     │ Gateway  │     └─────────┘
                └────┬─────┘
                     │
                ┌────▼─────┐
                │ Storage  │
                │ (S3)     │
                └──────────┘
```

**Identify components:**
- Client (Web/Mobile app)
- API Gateway (Routing, auth)
- Application services (Business logic)
- Database (User data, metadata)
- Object storage (File storage)

---

### Step 2.2: Component Design

For each component, define:

**Responsibilities:**
- What does it do?
- What doesn't it do?

**Interfaces:**
- What are its inputs?
- What are its outputs?

**Dependencies:**
- What does it depend on?
- What depends on it?

**Example: File Upload Service**
```markdown
### File Upload Service

**Responsibilities:**
- Validate file (type, size)
- Generate unique file ID
- Upload to S3
- Create metadata record
- NOT responsible for: Auth (API Gateway), Virus scanning (separate service)

**Interfaces:**
- Input: File bytes, user ID, metadata
- Output: File ID, upload URL, status

**Dependencies:**
- S3 (file storage)
- Database (metadata storage)
- Auth service (user validation)
```

---

### Step 2.3: Data Model Design

**Entity-Relationship:**
```
User ─(1:N)─ File ─(N:M)─ SharedWith
```

**Schema:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE files (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    filename VARCHAR(255) NOT NULL,
    size_bytes BIGINT NOT NULL,
    s3_key VARCHAR(512) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    INDEX idx_user_created (user_id, created_at)
);

CREATE TABLE file_shares (
    file_id UUID REFERENCES files(id),
    shared_with_user_id UUID REFERENCES users(id),
    permission VARCHAR(20) NOT NULL,  -- read, write
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (file_id, shared_with_user_id)
);
```

---

### Step 2.4: API Design

**RESTful Endpoints:**
```
POST   /v1/files           - Upload file
GET    /v1/files/{id}      - Get file metadata
GET    /v1/files/{id}/download - Download file
DELETE /v1/files/{id}      - Delete file
POST   /v1/files/{id}/share    - Share file
GET    /v1/files?q={query} - Search files
```

**Example API Spec:**
```yaml
POST /v1/files
Content-Type: multipart/form-data

Request:
  file: binary
  filename: string
  metadata: { tags: [string] }

Response 201:
  {
    "id": "uuid",
    "filename": "document.pdf",
    "size_bytes": 1048576,
    "created_at": "2024-10-24T10:00:00Z"
  }

Errors:
  400: Invalid file type
  413: File too large (>100MB)
  429: Rate limit exceeded
```

---

### Step 2.5: Technology Selection

**Framework:**
```markdown
### Decision: FastAPI vs Flask vs Django

**Chosen:** FastAPI

**Rationale:**
- Async support (needed for file streaming)
- Auto-generated OpenAPI docs
- Type hints (better DX)
- Modern, active community

**Alternatives:**
- Flask: Too basic, manual async
- Django: Too heavy, unnecessary ORM overhead
```

**Database:**
```markdown
### Decision: PostgreSQL vs MongoDB

**Chosen:** PostgreSQL

**Rationale:**
- Strong ACID guarantees
- Relationships (users, files, shares)
- Team expertise
- Excellent JSON support (for metadata)

**Alternatives:**
- MongoDB: No strong consistency, less familiar to team
```

---

## Phase 3: Evaluate Design (20%)

### Step 3.1: Capacity Planning

**Storage:**
```
Users: 1M
Files per user (avg): 100
File size (avg): 10MB

Total storage: 1M × 100 × 10MB = 1 PB

AWS S3 cost: $0.023/GB/month
Monthly cost: 1,000,000 GB × $0.023 = $23,000/month
```

**Database:**
```
Metadata per file: ~1KB
Total metadata: 1M users × 100 files × 1KB = 100 GB

PostgreSQL RDS (db.r5.large): ~$200/month
Sufficient for 100GB + indexes
```

**Compute:**
```
Requests: 1M users × 10 requests/day = 10M requests/day
Avg: 116 requests/second
Peak (3x avg): 350 requests/second

ECS tasks (2 vCPU, 4GB): Handle ~50 req/sec each
Need: 350 / 50 = 7 tasks at peak
Auto-scale: 2-10 tasks
Cost: ~$500/month
```

---

### Step 3.2: Identify Bottlenecks

**Potential Bottlenecks:**
1. **Database writes** - File metadata creation
   - Mitigation: Write-through cache, async writes
2. **File uploads** - Network bandwidth
   - Mitigation: Direct S3 upload (presigned URLs)
3. **Search** - Full-text search on filenames
   - Mitigation: Elasticsearch for search index

---

### Step 3.3: Failure Mode Analysis

**What can fail:**

**S3 Outage:**
- Impact: Cannot upload/download files
- Probability: Low (99.99% SLA)
- Mitigation: Multi-region replication (future)

**Database Failure:**
- Impact: Cannot create/query file metadata
- Probability: Low (Multi-AZ RDS)
- Mitigation: Read replicas, automated backups

**API Service Crash:**
- Impact: Service unavailable
- Probability: Medium
- Mitigation: Auto-scaling, health checks, multiple instances

---

### Step 3.4: Security Review

**Checklist:**
- [ ] Authentication (OAuth 2.0 via Auth0)
- [ ] Authorization (file ownership checks)
- [ ] Input validation (file type, size)
- [ ] Encryption in transit (TLS)
- [ ] Encryption at rest (S3 encryption)
- [ ] SQL injection prevention (ORM)
- [ ] Rate limiting (per user)
- [ ] Audit logging (file access, modifications)

---

## Phase 4: Document Design (10%)

### Step 4.1: Architecture Document

**Use template:** `assets/system-design-document-template.md`

**Sections:**
1. Overview (purpose, scope, success criteria)
2. Requirements (functional, non-functional, constraints)
3. Architecture (components, data flow, integrations)
4. Technology choices (rationale for each)
5. API design (endpoints, data models)
6. Testing strategy (unit, integration, e2e)
7. Risks & mitigations
8. Implementation plan (phases, timeline)

---

### Step 4.2: Architecture Decision Records (ADRs)

**For each major decision, create ADR:**

**Use template:** `assets/architecture-decision-record-template.md`

**Example:**
```markdown
# ADR-001: Use S3 for File Storage

**Status:** Accepted
**Date:** 2024-10-24

## Context
Need object storage for user-uploaded files (images, documents).

## Decision
Use AWS S3 for file storage.

## Consequences
**Positive:**
- Highly durable (99.999999999%)
- Scales infinitely
- Integrated with AWS ecosystem
- Lifecycle policies for cost optimization

**Negative:**
- Vendor lock-in with AWS
- Data transfer costs
- Eventual consistency for list operations

## Alternatives Considered
- Azure Blob Storage: No AWS integration
- Self-hosted MinIO: Operational overhead
```

---

## Common Pitfalls

### 1. Skipping Requirements Phase
**Problem:** Jump straight to design without understanding needs
**Solution:** Spend 30% of time on requirements gathering

### 2. Over-Engineering
**Problem:** Design for 1B users when you have 100
**Solution:** Design for 10x current scale, not 1000x

### 3. Under-Specifying Non-Functionals
**Problem:** "Fast" and "scalable" without numbers
**Solution:** Specific metrics (e.g., <100ms P95, 1k req/sec)

### 4. Ignoring Constraints
**Problem:** Design requires tech team doesn't know
**Solution:** Acknowledge constraints upfront, design within them

### 5. No Capacity Planning
**Problem:** Launch, immediately hit scaling issues
**Solution:** Calculate storage, compute, cost before building

### 6. Weak Failure Analysis
**Problem:** "We'll use backups" without testing restore
**Solution:** Document each failure mode with mitigation

---

## Design Review Checklist

**Use template:** `assets/architecture-review-checklist-template.md`

**Key Areas:**
- [ ] Requirements clear and complete
- [ ] Architecture addresses all requirements
- [ ] Technology choices justified
- [ ] Scalability plan defined
- [ ] Security reviewed
- [ ] Failure modes analyzed
- [ ] Cost estimated
- [ ] Implementation plan realistic

---

## Resources

**Tools:**
- **Diagrams:** draw.io, Excalidraw, Mermaid
- **API Design:** Swagger/OpenAPI, Postman
- **Capacity Planning:** Back-of-envelope calculations
- **Collaboration:** Google Docs, Notion, Confluence

**Books:**
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "System Design Interview" by Alex Xu
- "Building Microservices" by Sam Newman

---

**Related References:**
- [Architectural Patterns](architectural-patterns.md)
- [Design Principles](design-principles.md)
- [Scalability Patterns](scalability-patterns.md)
- [Security Architecture](security-architecture.md)
