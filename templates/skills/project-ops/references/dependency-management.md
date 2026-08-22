# Dependency Management Reference Guide

## Overview

This guide provides systematic approaches for identifying, tracking, and managing project dependencies. Use when planning work, coordinating across teams, or resolving blockers.

---

## Dependency Fundamentals

### What is a Dependency?

**Definition:** A relationship where one task, team, or system relies on another to complete work.

**Dependency Pattern:**
```
Task A depends on Task B
= Task A cannot start/finish until Task B is complete
```

### Types of Dependencies

#### 1. Finish-to-Start (FS) - Most Common
**Pattern:** B cannot start until A finishes

**Example:**
- Design mockups (A) must finish → Development (B) can start

**Notation:** `Design → Development`

#### 2. Start-to-Start (SS)
**Pattern:** B cannot start until A starts

**Example:**
- Backend API development (A) starts → Frontend development (B) can start (in parallel)

**Notation:** `Backend API ⇉ Frontend`

#### 3. Finish-to-Finish (FF)
**Pattern:** B cannot finish until A finishes

**Example:**
- Testing (B) cannot finish until all features (A) are complete

**Notation:** `Features ⇛ Testing`

#### 4. Start-to-Finish (SF) - Rare
**Pattern:** B cannot finish until A starts

**Example:**
- Old system (B) must run until new system (A) starts

---

## Dependency Categories

### Internal Dependencies

**Team Dependencies:**
- One team waiting on another team
- Example: Frontend team waiting for backend API

**Task Dependencies:**
- Sequential work within a team
- Example: Database schema must be created before migrations

**Resource Dependencies:**
- Shared resources (people, tools, environments)
- Example: Only one staging environment for testing

### External Dependencies

**Vendor/Third-Party:**
- Waiting on external provider
- Example: OAuth integration waiting on vendor API access

**Organizational:**
- Waiting on other departments
- Example: Legal approval for terms of service

**Regulatory/Compliance:**
- Waiting on regulatory approval
- Example: Security audit completion before launch

---

## Identifying Dependencies

### During Planning

**Ask These Questions:**

1. **What must be done before this work can start?**
   - List all prerequisites
   - Identify if they're complete or in progress

2. **What information, decisions, or resources are needed?**
   - Approvals, documentation, access to systems
   - Who provides these?

3. **Who else is this work blocked by or blocking?**
   - Other teams, stakeholders, vendors
   - Map the dependency chain

4. **What could prevent this work from starting or finishing?**
   - External factors, resource constraints, approvals

### Dependency Discovery Techniques

#### 1. Work Backward from Goal

**Process:**
1. Start with end goal (e.g., "Launch feature")
2. Ask: "What must be true immediately before this?"
3. Repeat for each prerequisite
4. Build dependency chain backward

**Example:**
```
Launch Feature
  ↑ requires
Deploy to Production
  ↑ requires
Pass QA Testing
  ↑ requires
Complete Development
  ↑ requires
API Design Approved
  ↑ requires
Architecture Review
```

#### 2. Stakeholder Interviews

**Questions to Ask:**
- "What do you need from us, and when?"
- "What are you providing to us, and when?"
- "What could block your work?"
- "Who else are you dependent on?"

#### 3. Dependency Mapping Workshop

**Process:**
1. Gather all teams involved
2. Each team writes their deliverables on sticky notes
3. Each team writes what they need from others
4. Map connections on whiteboard
5. Identify critical dependencies
6. Assign owners to manage each dependency

---

## Dependency Tracking

### Dependency Register

**Purpose:** Centralized tracking of all project dependencies

**Format:**

| ID | Dependent Item | Depends On | Type | Owner | Provider | Status | Due Date | Risk |
|----|---------------|------------|------|-------|----------|--------|----------|------|
| D1 | Frontend dev | API spec | FS | Alice | Bob | In Progress | 2024-03-15 | 🟢 |
| D2 | Integration test | Vendor API access | FS | Bob | Vendor | Blocked | 2024-03-20 | 🔴 |
| D3 | Deploy | Security audit | FS | Charlie | InfoSec | Not Started | 2024-04-01 | 🟡 |

**Status Values:**
- **Not Started:** Dependency provider hasn't started
- **In Progress:** Dependency being worked on
- **Complete:** Dependency delivered
- **Blocked:** Dependency provider is blocked
- **At Risk:** May not be delivered on time

**Risk Levels:**
- 🟢 **Green:** On track, no concerns
- 🟡 **Yellow:** Potential delay, monitoring
- 🔴 **Red:** Critical, immediate attention needed

### Dependency Diagram

**Simple Chain:**
```
A → B → C → D
```

**Complex with Parallel Work:**
```
    ┌─→ B ─┐
A ──┤      ├─→ E → F
    └─→ C ─┘
         ↓
         D
```

**Critical Path Highlighted:**
```
    ┌─→ B ─┐
A ==┤      ╞══> E ==> F  (== critical path)
    └─→ C ─┘
         ↓
         D
```

### Critical Path Analysis

**Definition:** Longest sequence of dependent tasks; any delay impacts project end date.

**How to Identify:**
1. Map all dependencies
2. Calculate duration of each path from start to finish
3. Longest path = critical path
4. Tasks on critical path have zero slack (no buffer)

**Example:**
```
Path 1: A → B → E → F = 4 + 3 + 2 + 1 = 10 days
Path 2: A → C → E → F = 4 + 5 + 2 + 1 = 12 days ← Critical path
Path 3: D = 2 days (not connected to finish)
```

**Path 2 is critical: Any delay in A, C, E, or F delays project**

**Management Focus:**
- Monitor critical path tasks closely
- Allocate best resources to critical path
- Mitigate risks on critical path
- Non-critical path tasks can slip without impacting deadline

---

## Managing Dependencies

### Dependency Ownership

**Dependency Owner (Consumer):**
- **Responsibility:** Ensure dependency is tracked and delivered
- **Actions:**
  - Communicate need clearly to provider
  - Set expectations on timeline and quality
  - Follow up regularly
  - Escalate if at risk
  - Have contingency plan

**Dependency Provider:**
- **Responsibility:** Deliver what's needed, when it's needed
- **Actions:**
  - Confirm understanding of requirement
  - Commit to realistic date
  - Communicate progress
  - Flag issues early
  - Deliver on time

### Dependency Review Cadence

**Daily (Standup):**
- Are any dependencies blocking work today?
- Any new dependencies identified?
- Any dependency status changes?

**Weekly (Dependency Review):**
- Review dependency register
- Check status of all dependencies
- Follow up on at-risk dependencies
- Update timeline estimates
- Identify new dependencies

**Sprint/Monthly:**
- Comprehensive dependency audit
- Update dependency diagram
- Assess critical path
- Report to stakeholders

### Reducing Dependency Risk

#### 1. Parallel Work (Decouple)

**Before (Sequential):**
```
A → B → C (12 days total)
```

**After (Parallel):**
```
A → C (7 days)
↓
B (5 days, parallel with C)
```

**Techniques:**
- API contracts/mocks (frontend doesn't wait for backend)
- Feature flags (deploy independently, enable when ready)
- Stub implementations (use placeholder until real version ready)

#### 2. Buffer Time

**Add buffer to dependent tasks:**
```
If Task B depends on Task A:
- A estimated: 5 days
- Add 20% buffer: 6 days
- Schedule B to start after 6 days (not 5)
```

**Buffer sizing:**
- Low-risk dependency: 10-20% buffer
- Medium-risk: 20-30% buffer
- High-risk (external vendor): 30-50% buffer

#### 3. Alternative Options

**Identify backup plans:**
- **Primary:** Vendor A's API (preferred)
- **Fallback:** Vendor B's API (if Vendor A delays)
- **Last Resort:** Build it ourselves (if both vendors fail)

**Trigger points:**
- If dependency not ready by [date], activate fallback

#### 4. Early Engagement

**Don't wait:**
- Engage dependency provider early (weeks, not days before needed)
- Build relationship before you need something
- Regular check-ins prevent surprises

---

## Handling Dependency Delays

### When Dependency is Late

**Immediate Actions:**

1. **Assess Impact:**
   - How does this delay affect our timeline?
   - Is this on the critical path?
   - Can we work around it?

2. **Communicate:**
   - Inform stakeholders immediately
   - Explain impact and options
   - Be transparent about revised timeline

3. **Explore Options:**
   - **Workaround:** Can we proceed with mock/stub?
   - **Parallel work:** Can we do other work while waiting?
   - **Escalate:** Can we get dependency prioritized?
   - **Alternate:** Can we use different approach?

4. **Update Plans:**
   - Revise timeline
   - Re-prioritize work
   - Update dependency register

### Escalation Process

**When to Escalate:**
- Dependency overdue by >2 days with no update
- Dependency provider not responding
- Dependency critical to project success
- No workaround available

**Escalation Levels:**

1. **Level 1:** Direct communication with dependency provider
   - Email or message: "We need [X] by [date] to stay on track"

2. **Level 2:** Escalate to dependency provider's manager
   - CC their manager: "Flagging this dependency is critical for [project]"

3. **Level 3:** Escalate to your manager + their manager
   - Request leadership intervention

4. **Level 4:** Executive escalation
   - CTO, VP, or executive sponsor gets involved

**Escalation Email Template:**

```markdown
**Subject:** Dependency Escalation: [Dependency description]

**Dependency:**
[What we need]

**From:** [Provider team/person]
**Due Date:** [Original date]
**Current Status:** [Overdue by X days / At risk]

**Impact:**
- Blocks: [Our work items]
- Timeline risk: [X days/weeks delay to project]
- Affects: [Milestone, launch date, etc.]

**What We've Tried:**
- [Communication attempt 1]
- [Communication attempt 2]
- [Workaround explored]

**Requesting:**
[Specific action needed - e.g., prioritize this work, assign additional resources, etc.]

**Urgency:** [Critical / High / Medium]
```

---

## Cross-Team Dependencies

### API Dependencies

**Best Practices:**

1. **API Contract First:**
   - Define API contract (endpoints, request/response) before implementation
   - Both teams agree on contract
   - Consumer can build against contract while provider implements

2. **Mocks/Stubs:**
   - Provider creates mock API immediately
   - Consumer develops against mock
   - Swap to real API when ready

3. **Versioning:**
   - Version APIs to avoid breaking consumers
   - Deprecation policy (e.g., 3 months notice before removal)

**Example Workflow:**
```
Week 1: Define API contract (both teams)
Week 1-2: Provider creates mock API, consumer starts development
Week 2-4: Provider implements real API
Week 4: Swap mock for real API, integration testing
Week 5: Production deployment
```

### Data Dependencies

**Common Scenarios:**
- Waiting for database migration
- Waiting for data import/export
- Waiting for data transformation

**Best Practices:**

1. **Sample Data:**
   - Use sample/synthetic data for development
   - Don't wait for production data

2. **Incremental Migration:**
   - Migrate in phases, not all at once
   - Allows parallel work

3. **Data Contracts:**
   - Define schema/format early
   - Both teams agree on data structure

### Infrastructure Dependencies

**Common Scenarios:**
- Waiting for environment provisioning
- Waiting for access/permissions
- Waiting for deployment pipeline

**Best Practices:**

1. **Self-Service:**
   - Automate provisioning (Terraform, CloudFormation)
   - Developers can create environments on-demand

2. **Early Provisioning:**
   - Set up environments in sprint 0
   - Don't wait until you need them

3. **Parallel Environments:**
   - Each team has their own dev/staging environment
   - Reduces contention

---

## Dependency Anti-Patterns

### 1. Hidden Dependencies

**Problem:** Dependencies not documented or communicated

**Impact:** Surprise delays, miscommunication, missed deadlines

**Solution:**
- Maintain dependency register
- Make dependencies visible on boards
- Discuss dependencies in planning

### 2. Circular Dependencies

**Problem:** A depends on B, B depends on A (deadlock)

**Example:**
- Frontend needs backend API (A → B)
- Backend needs frontend mockups to understand requirements (B → A)

**Solution:**
- Break the cycle (define API contract without mockups)
- Sequence properly (mockups first, then API)

### 3. Long Dependency Chains

**Problem:** A → B → C → D → E (fragile, delays cascade)

**Impact:** Any delay amplified through chain

**Solution:**
- Shorten chains (can A go directly to D?)
- Parallelize work where possible
- Add buffers

### 4. Single Point of Failure

**Problem:** Everything depends on one person/team/system

**Impact:** Bottleneck, delays if that person unavailable

**Solution:**
- Cross-train team members
- Distribute expertise
- Document knowledge

### 5. Late Discovery

**Problem:** Dependencies identified mid-sprint or late in project

**Impact:** Unplanned delays, scope/timeline impact

**Solution:**
- Thorough planning upfront
- Regular dependency reviews
- Encourage team to surface dependencies early

---

## Best Practices

### 1. Make Dependencies Visible
- Document in issue tracker (Linear, Jira)
- Visualize on dependency diagram
- Discuss in standups and planning

### 2. Own Your Dependencies
- Assign owner to each dependency
- Owner responsible for tracking and communication
- Don't assume someone else is handling it

### 3. Communicate Early and Often
- Tell providers what you need and when
- Check in regularly on status
- Surface issues immediately

### 4. Build in Buffer
- Add time buffer for external dependencies
- Critical path tasks get extra attention
- Expect some delays

### 5. Have Backup Plans
- Identify alternatives before you need them
- Know your escalation path
- Can you build it yourself if vendor fails?

### 6. Reduce Dependencies When Possible
- Decouple work (API contracts, feature flags)
- Parallel work streams
- Self-service tooling (less dependency on ops)

### 7. Learn from History
- Track which dependencies cause delays
- Identify patterns
- Improve process for next project

---

## Tools & Techniques

### Dependency Visualization Tools

**Simple (Good for small projects):**
- Spreadsheet (dependency register)
- Miro/Mural (visual mapping)
- Linear/Jira relationships

**Advanced (Good for complex projects):**
- Microsoft Project (Gantt charts with dependencies)
- Smartsheet (collaborative Gantt)
- Monday.com (dependency tracking)

### PERT Chart

**Purpose:** Visualize dependencies and critical path

**Components:**
- Nodes: Tasks/milestones
- Arrows: Dependencies
- Numbers: Duration

**Example:**
```
    ┌─→ B (3d) ─┐
    │           ↓
A (4d)         E (2d) → F (1d)
    │           ↑
    └─→ C (5d) ─┘
         ↓
       D (2d)

Critical Path: A → C → E → F (12 days)
```

### Dependency Matrix

**Purpose:** Track many-to-many dependencies between teams

**Format:**

|  | Team A | Team B | Team C | Team D |
|--|--------|--------|--------|--------|
| **Team A** | - | A needs API from B | - | - |
| **Team B** | B needs design from A | - | B needs infra from C | - |
| **Team C** | - | - | - | C needs data from D |
| **Team D** | - | - | D needs deploy pipeline from C | - |

**Use:** Identify cross-team dependencies, plan collaboration

---

## Case Study

### Scenario: E-commerce Platform Launch

**Teams:**
- Frontend (React app)
- Backend (API)
- DevOps (infrastructure)
- Design (UX/UI)

**Dependencies Identified:**

1. **Frontend depends on Backend:**
   - API endpoints for product catalog, cart, checkout
   - **Solution:** API contract week 1, mock API week 2, real API week 4

2. **Backend depends on Design:**
   - Product data model (what fields?)
   - **Solution:** Design delivers data model in sprint 0

3. **Frontend depends on Design:**
   - Mockups and design system
   - **Solution:** Design delivers mockups sprint 1, components sprint 2

4. **All teams depend on DevOps:**
   - CI/CD pipeline, staging environment
   - **Solution:** DevOps provisions in sprint 0 (before teams need it)

5. **Launch depends on External:**
   - Payment gateway integration
   - **Solution:** Start vendor onboarding in sprint 1 (not sprint 5), 30% buffer on timeline

**Critical Path:**
```
Design (sprint 0) → Backend API (sprints 1-3) → Integration Testing (sprint 4) → Launch (sprint 5)
```

**Result:**
- All dependencies tracked in register
- Weekly cross-team sync to review dependencies
- Payment vendor delayed 1 week, but buffer absorbed it
- Launched on time

---

## Resources & Further Reading

- "The Mythical Man-Month" by Fred Brooks (dependency and coordination costs)
- "Project Management Body of Knowledge (PMBOK)" - Dependency management chapter
- "Accelerate" by Nicole Forsgren (reducing dependencies in software delivery)

---

**Last Updated:** 2024-10-24
**Version:** 1.0
