# Project Operations Templates

---
name: project-ops-templates
description: Comprehensive templates and frameworks for project coordination, sprint planning, risk management, and stakeholder communication. Use when coordinating projects, planning sprints, tracking progress, managing risks, or communicating with stakeholders. Provides standardized formats for kickoffs, standups, retrospectives, status reports, and milestone tracking.
---

## Overview

This skill provides production-ready templates and systematic frameworks for project operations and coordination. It complements the @project-ops agent by providing standardized formats, proven methodologies, and best practices for managing software projects throughout their lifecycle.

**When to use this skill:**
- Coordinating project kickoffs and initial planning
- Planning and tracking sprints
- Running daily standups and retrospectives
- Reporting project status to stakeholders
- Managing risks and dependencies
- Tracking milestones and deliverables
- Improving team velocity and throughput
- Communicating with diverse stakeholder groups

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive methodologies.

---

## Available Templates

This skill provides 6 production-ready templates in `assets/`:

### 1. Project Kickoff Template
**File:** `assets/project-kickoff-template.md`

Complete project initialization format including:
- Executive summary and context
- Stakeholder alignment matrix
- Success criteria (must-have, should-have, nice-to-have)
- Scope definition (in scope, out of scope, deferred)
- High-level roadmap and phases
- Team roles and responsibilities
- Risk assessment matrix
- Technical overview
- Workflow and processes
- Initial backlog and priorities

**Use when:** Starting new projects or major features requiring formal kickoff.

**Example usage:**
```markdown
# Project Kickoff: Customer Analytics Dashboard

## Executive Summary
**Problem Statement:** Marketing team lacks visibility into customer behavior

**Solution Overview:** Build real-time dashboard showing customer segments, behavior patterns, and conversion metrics

**Success Criteria:**
- Dashboard loads in <2 seconds
- Tracks 10+ key metrics
- Used by 20+ marketing team members daily
```

### 2. Sprint Planning Template
**File:** `assets/sprint-planning-template.md`

Comprehensive sprint setup format with:
- Sprint goal and success criteria
- Team capacity calculation
- Historical context and velocity
- Sprint backlog with priorities (P0/P1/P2)
- Story breakdown with tasks and acceptance criteria
- Dependencies and external blockers
- Risk assessment for the sprint
- Sprint ceremonies schedule
- Scope change protocol

**Use when:** Planning each sprint or iteration.

**Example usage:**
```markdown
# Sprint Planning: Sprint 12

**Sprint Duration:** 2024-03-01 to 2024-03-14 (10 days)
**Sprint Goal:** Complete user authentication MVP

**Team Capacity:**
- 5 team members × 10 days - 2 PTO days = 48 working days
- 48 days × 6 productive hours = 288 hours
- Historical velocity: 28 points → Commit to 25-30 points

**P0 Stories (Must Complete):**
- RAE-156: User login/logout (8 points)
- RAE-157: Password reset flow (5 points)
- RAE-158: Session management (5 points)
```

### 3. Daily Standup Template
**File:** `assets/daily-standup-template.md`

Quick daily sync format with:
- Team updates (yesterday, today, blockers)
- Sprint progress tracking
- Active blocker management
- Dependency tracking
- Action items and follow-ups
- Parking lot for deeper discussions
- Timeboxing guidance (15 minutes max)

**Use when:** Running daily team standups (sync or async).

**Example usage:**
```markdown
# Daily Standup - 2024-03-05

**Sprint Progress:** 12/28 points completed (Day 4 of 10)
**Blockers:** 1 critical (API access), 2 medium

**Alice (Frontend):**
- Yesterday: Completed login UI
- Today: Working on password reset UI
- Blockers: Waiting on API endpoints from backend

**Action Items:**
- Bob: Provide API spec to Alice by EOD
```

### 4. Retrospective Template
**File:** `assets/retrospective-template.md`

Team improvement session format with:
- Sprint metrics (velocity, quality, team health)
- What went well (successes to repeat)
- What didn't go well (challenges to address)
- What to try next (experiments and improvements)
- Action items with owners and metrics
- Start/Stop/Continue framework
- Deep dive analysis for key issues
- Process improvement tracking

**Use when:** End of each sprint for team reflection.

**Example usage:**
```markdown
# Sprint Retrospective: Sprint 12

**Sprint Goal Achievement:** ✅ Achieved

**Velocity:** 28 points completed (target: 25-30) 🟢

**What Went Well:**
1. **Pair programming on complex feature**
   - Impact: Faster development, fewer bugs
   - Why it worked: Knowledge sharing, real-time review
   - Action: Continue pairing on complex work

**Action Items:**
- Start: Code review SLA of 4 hours (Owner: Tech Lead)
- Stop: Accepting stories without test plans (Owner: QA)
```

### 5. Project Status Report Template
**File:** `assets/project-status-report-template.md`

Comprehensive status communication format with:
- Executive summary with one-line status
- Project health dashboard (schedule, scope, quality, budget, team)
- Progress this period (completed work, metrics)
- In-progress work with completion percentages
- Blockers and issues (critical, medium, resolved)
- Risk assessment and mitigation
- Scope changes and pending decisions
- Quality and technical health metrics
- Budget and resource status

**Use when:** Providing weekly, bi-weekly, or monthly stakeholder updates.

**Example usage:**
```markdown
# Project Status Report: Customer Analytics Dashboard

**Reporting Period:** March 1-14, 2024
**Overall Status:** 🟢 On Track

**Key Highlights:**
- Sprint 12 completed successfully (28 points)
- User authentication MVP delivered on time
- 1 critical risk mitigated (alternative API identified)

**Progress:** 45% complete, on track for June 1 launch

**Top Risk:** Payment API integration uncertainty (🟡 Medium)
- Mitigation: Built POC, identified backup vendor
```

### 6. Milestone Tracking Template
**File:** `assets/milestone-tracking-template.md`

Project timeline and deliverable tracking with:
- All milestones summary table
- Active milestone detailed breakdown
- Completed milestone retrospectives
- Upcoming milestone planning
- Critical path analysis
- Dependency mapping
- Schedule variance tracking
- Resource allocation
- Milestone health indicators
- Stakeholder communication plan

**Use when:** Tracking multi-milestone projects, reporting on long-term progress.

**Example usage:**
```markdown
# Milestone Tracking: Customer Analytics Dashboard

**M3: Authentication MVP** (Active)
- Target: March 14, 2024
- Progress: 75% complete
- Confidence: 🟢 High

**Deliverables:**
- ✅ Login/logout functionality
- ✅ Password reset flow
- 🔄 Session management (85% complete)
- 📋 Two-factor authentication (next sprint)

**Critical Path:** M3 → M5 → M7 → Launch
```

---

## Reference Guides

This skill provides 5 comprehensive reference guides in `references/`:

### 1. Agile Workflows Guide
**File:** `references/agile-workflows.md`

Systematic guidance for implementing agile methodologies with:

**Scrum Framework:**
- Roles (Product Owner, Scrum Master, Development Team)
- Events (Sprint Planning, Daily Standup, Review, Retrospective)
- Artifacts (Product Backlog, Sprint Backlog, Increment)
- Best practices and anti-patterns

**Kanban Method:**
- Board structure and WIP limits
- Metrics (lead time, cycle time, throughput)
- Flow optimization
- When to use Kanban vs Scrum

**Backlog Management:**
- User story format (As a... I want... So that...)
- Acceptance criteria (Given-When-Then)
- Definition of Ready and Definition of Done
- Story sizing techniques (Planning Poker, T-Shirt Sizing)

**Additional Topics:**
- Scrum vs Kanban comparison matrix
- Hybrid (Scrumban) approach
- Common agile anti-patterns (Cargo Cult, Water-Scrum-Fall)
- Velocity and capacity planning

**Use when:** Need systematic framework for agile ceremonies and workflows.

### 2. Risk Management Guide
**File:** `references/risk-management.md`

How to identify, assess, and mitigate project risks:

**Risk Identification:**
- Common project risks (technical, schedule, resource, business, external)
- Identification techniques (brainstorming, checklist, assumption analysis, SWOT, historical review)

**Risk Assessment:**
- Probability estimation (High 70-100%, Medium 30-70%, Low 0-30%)
- Impact estimation (High/Medium/Low across schedule, budget, scope, quality)
- Risk scoring matrix
- Quantitative assessment (Expected Monetary Value)

**Risk Response Strategies:**
1. **Avoid:** Eliminate risk by changing plan
2. **Mitigate:** Reduce probability or impact
3. **Transfer:** Shift to third party (insurance, vendors)
4. **Accept:** Acknowledge with or without contingency plan
5. **Exploit:** Ensure positive risks (opportunities) are realized

**Risk Monitoring:**
- Risk register template
- Review cadence (daily, weekly, monthly)
- Early warning indicators
- Escalation protocols

**Additional Topics:**
- Pre-mortem exercise (imagine project failed, why?)
- Risk burndown chart
- Case study with real mitigation examples

**Use when:** Need to systematically manage project uncertainties and threats.

### 3. Stakeholder Communication Guide
**File:** `references/stakeholder-communication.md`

Frameworks for effective communication across stakeholder groups:

**Stakeholder Analysis:**
- Power/Interest matrix (Manage Closely, Keep Satisfied, Keep Informed, Monitor)
- Communication strategy by quadrant
- Stakeholder communication matrix

**Communication Planning:**
- Channel selection (sync vs async, when to use each)
- Communication cadence (weekly, bi-weekly, monthly)
- Weekly update template
- Executive summary template (1-page, 2-3 minutes to read)
- Monthly demo format

**Managing Expectations:**
- SMART commitments
- Underpromise, overdeliver strategy
- Saying "no" effectively (acknowledge, explain, offer options)

**Difficult Conversations:**
- Delivering bad news (issue, impact, root cause, recovery plan)
- Managing scope creep (clarify, analyze, discuss trade-offs)
- Handling conflicts (understand positions, find common ground)

**Communication Styles by Audience:**
- **Executives:** ROI, timelines, risks, brief, quantified
- **Product Owners:** Features, quality, trade-offs, user-focused
- **Technical Teams:** Architecture, tech debt, detailed
- **End Users:** Benefits, ease of use, simple language

**Additional Topics:**
- Decision request template
- Blocker escalation template
- Change request template
- Measuring communication effectiveness

**Use when:** Need to tailor communication to different stakeholder groups or handle challenging conversations.

### 4. Dependency Management Guide
**File:** `references/dependency-management.md`

Systematic approaches for managing cross-team and external dependencies:

**Dependency Types:**
- Finish-to-Start (A finishes → B starts) - Most common
- Start-to-Start (A starts → B starts)
- Finish-to-Finish (A finishes → B finishes)
- Start-to-Finish (rare)

**Dependency Categories:**
- Internal (team, task, resource dependencies)
- External (vendor, organizational, regulatory)

**Identification Techniques:**
- Work backward from goal
- Stakeholder interviews
- Dependency mapping workshop

**Dependency Tracking:**
- Dependency register template
- Dependency diagram visualization
- Critical path analysis (longest path = zero slack)

**Managing Dependencies:**
- Dependency ownership (consumer vs provider)
- Review cadence (daily, weekly, monthly)
- Risk reduction strategies (parallel work, buffer time, alternatives, early engagement)

**Handling Delays:**
- Assess impact (critical path?)
- Explore options (workaround, parallel work, escalate)
- Escalation process (4 levels with templates)

**Cross-Team Dependencies:**
- API dependencies (contract-first, mocks/stubs)
- Data dependencies (sample data, incremental migration)
- Infrastructure dependencies (self-service, early provisioning)

**Additional Topics:**
- Dependency anti-patterns (hidden, circular, long chains)
- PERT chart visualization
- Case study with real dependency management

**Use when:** Need to coordinate work across teams or manage external dependencies.

### 5. Team Velocity Tracking Guide
**File:** `references/team-velocity-tracking.md`

Methods for measuring and improving team performance:

**Velocity Fundamentals:**
- Definition: Average story points completed per sprint
- What velocity is (planning tool, forecasting)
- What velocity is NOT (individual metric, comparable across teams, quality measure)

**Story Point Estimation:**
- Fibonacci scale (1, 2, 3, 5, 8, 13, 21)
- Reference stories for each size
- Estimation techniques (Planning Poker, T-Shirt Sizing, Affinity Estimation)

**Measuring Velocity:**
- Calculation methods (simple average, weighted average, exclude outliers)
- What to include/exclude
- Velocity stability patterns

**Velocity Patterns:**
- Healthy: Stable ±20% variation
- Unstable: High variation (over-committing, capacity issues)
- Declining: Technical debt, burnout, complexity
- False Inflation: Story point gaming

**Forecasting:**
- Release planning (Sprints = Remaining Points / Velocity)
- Feature forecasting with confidence levels
- Adding buffer (10% optimistic, 25% realistic, 50% conservative)

**Burndown Charts:**
- Sprint burndown (daily progress)
- Release burndown (multi-sprint tracking)
- Reading patterns (ahead, behind, flat line, scope changes)

**Alternative Metrics:**
- Throughput (count of items completed)
- Cycle Time (time from start to done)
- Lead Time (time from request to delivery)

**Improving Velocity:**
- Sustainable improvements (reduce tech debt, improve estimation, remove blockers)
- Unsustainable approaches to avoid (inflating points, cutting quality, overtime)

**Additional Topics:**
- Velocity for new teams (sprints 1-3 volatile, 7+ stable)
- Impact of team changes
- Best practices (trends > single sprints, velocity is not a goal)
- Common pitfalls (inflation, partial credit, ignoring capacity)

**Use when:** Need to plan sprints, forecast delivery, or track team performance.

---

## Usage Patterns

### Pattern 1: New Project Kickoff

**Scenario:** Starting a new project or major initiative requiring structured planning.

**Process:**
1. Read `agile-workflows.md` → Choose Scrum vs Kanban
2. Use `project-kickoff-template.md` to plan project
3. Read `stakeholder-communication.md` → Set up communication plan
4. Read `risk-management.md` → Initial risk assessment
5. Read `dependency-management.md` → Map dependencies
6. Use `milestone-tracking-template.md` for timeline

**Time:** 1-2 days for comprehensive kickoff

**Outputs:**
- Project kickoff document
- Stakeholder communication matrix
- Risk register
- Dependency map
- Milestone timeline

### Pattern 2: Sprint Planning & Execution

**Scenario:** Regular sprint planning and execution for agile team.

**Process:**
1. Read `agile-workflows.md` → Sprint Planning section
2. Read `team-velocity-tracking.md` → Calculate velocity, plan capacity
3. Use `sprint-planning-template.md` for sprint setup
4. Use `daily-standup-template.md` for daily coordination
5. Read `dependency-management.md` → Track sprint dependencies
6. Use `retrospective-template.md` at sprint end

**Time:** Ongoing (2-week sprint cycle)

**Outputs:**
- Sprint backlog with committed stories
- Daily standup notes
- Sprint retrospective with action items

### Pattern 3: Stakeholder Status Reporting

**Scenario:** Providing regular status updates to diverse stakeholder groups.

**Process:**
1. Read `stakeholder-communication.md` → Identify stakeholder needs
2. Use `project-status-report-template.md` for comprehensive update
3. Tailor report based on audience (executives vs technical teams)
4. Read `risk-management.md` → Update risk section
5. Use `milestone-tracking-template.md` → Report on milestones

**Time:** 1-2 hours weekly for status report

**Outputs:**
- Weekly status report
- Executive summary (1-pager)
- Risk updates
- Milestone progress

### Pattern 4: Risk & Dependency Management

**Scenario:** Managing complex project with many risks and cross-team dependencies.

**Process:**
1. Read `risk-management.md` completely
2. Read `dependency-management.md` completely
3. Create risk register and dependency register
4. Weekly review of both registers
5. Use escalation templates when issues arise
6. Report in `project-status-report-template.md`

**Time:** 2-4 hours for initial setup, 30 minutes weekly for review

**Outputs:**
- Risk register with mitigation plans
- Dependency register with owners
- Critical path analysis
- Weekly status updates

### Pattern 5: Team Performance Optimization

**Scenario:** Team wants to improve velocity, reduce cycle time, optimize flow.

**Process:**
1. Read `team-velocity-tracking.md` → Measure baseline
2. Read `agile-workflows.md` → Identify process improvements
3. Use `retrospective-template.md` → Identify bottlenecks
4. Implement improvements (reduce WIP, improve estimation, etc.)
5. Track metrics over 3-5 sprints
6. Iterate based on data

**Time:** Ongoing improvement (3-6 months to see significant change)

**Outputs:**
- Velocity trend chart
- Cycle time analysis
- Process improvements with measured impact
- Retrospective action items

### Pattern 6: Handling Project Crisis

**Scenario:** Critical blocker, timeline at risk, need to communicate and recover.

**Process:**
1. Read `risk-management.md` → Blocker escalation
2. Read `stakeholder-communication.md` → Delivering bad news
3. Use blocker escalation template
4. Read `dependency-management.md` → Explore alternatives
5. Update `project-status-report-template.md` with recovery plan
6. Communicate to stakeholders immediately

**Time:** Immediate response (same day)

**Outputs:**
- Blocker escalation email
- Impact analysis
- Recovery plan with revised timeline
- Stakeholder communication

---

## Integration with @project-ops

This skill is designed to complement the @project-ops agent:

**Agent's Role:**
- Coordinates projects and teams
- Makes judgment calls on priorities
- Manages Linear backlog and workflow
- Facilitates communication
- Tracks progress and reports status

**Skill's Role:**
- Provides standardized templates for consistency
- Offers proven methodologies and frameworks
- Ensures best practices are followed
- Gives reference guides for decision-making

**Workflow:**
```markdown
User: "@project-ops, plan sprint 15 and create status report"

Agent:
1. Loads project-ops-templates skill
2. Queries Linear (linctl): linctl issue list --state "In Progress" --json
3. Reads team-velocity-tracking.md for velocity calculation
4. Uses sprint-planning-template.md to structure planning
5. Reads agile-workflows.md for best practices
6. Creates sprint plan with capacity, stories, dependencies
7. Updates Linear (linctl): linctl issue update RAE-123 --state "In Progress"
8. Uses project-status-report-template.md for status update
9. Reads stakeholder-communication.md to tailor for audience
10. Delivers sprint plan + status report
```

---

## Linear Tooling Best Practices

**Critical for @project-ops**: Use linctl CLI for all Linear operations. Prefer `--json` for reads in automations.

### linctl Commands

```bash
# Create issue
linctl issue create --title "Issue title" --team "$LINEAR_TEAM" --priority 3 --description "Detailed description"

# Update issue status
linctl issue update RAE-123 --state "Done"

# Add comment
linctl comment create RAE-123 --body "Status update text"

# Common state transitions
linctl issue update RAE-123 --state "In Progress"
linctl issue update RAE-123 --state "In Review"
linctl issue update RAE-123 --state "Done"
linctl issue update RAE-123 --state "Canceled"
```

### Reads for Agents (JSON)

```bash
# Query issues
linctl issue list --assignee me --state "In Progress" --json
linctl issue list --team "$LINEAR_TEAM" --json

# Get issue details
linctl issue get RAE-123 --json

# List comments
linctl comment list RAE-123 --json
```

### Configuration Requirements

```bash
# Environment variable (required)
export LINEAR_API_KEY="lin_api_..."

# Global config (optional): ~/.claude/linear-config.json
{
  "teamId": "b8ff8916-3e03-435d-809f-9d45ef4199c8",
  "projectId": "d6e10d04-319c-4339-8f5f-f1f1d0b3090e"
}

# Project config (optional): .specify/linear-config.json
{
  "team": {
    "id": "b8ff8916-3e03-435d-809f-9d45ef4199c8",
    "name": "Raegis Labs"
  },
  "defaultProject": {
    "id": "d6e10d04-319c-4339-8f5f-f1f1d0b3090e",
    "name": "Agent Orchestration Framework"
  }
}
```

### Complete Workflow Example

```bash
# 1. Query current issues
linctl issue list --assignee me --state "Backlog" --json

# 2. Get issue details
linctl issue get RAE-125 --json

# 3. Update status to In Progress with comment
linctl issue update RAE-125 --state "In Progress"
linctl comment create RAE-125 --body "Starting implementation"

# 4. Create new issue
linctl issue create --title "Implement user dashboard" --team "$LINEAR_TEAM" --priority 2 --assignee me --description "Build dashboard showing user activity metrics"

# 5. Mark complete
linctl issue update RAE-125 --state "Done"
```

**Reference**: See `docs/linear-mcp-guidance.md` in the repository for complete documentation.

---

## Best Practices

### 1. Start with Templates, Customize as Needed
Templates are starting points - adapt to your project's specific needs. Delete irrelevant sections, add project-specific criteria.

### 2. Use Appropriate Template for Context
- Quick sprint update → Daily standup template
- Comprehensive project status → Project status report template
- New project → Project kickoff template
- End of sprint → Retrospective template

### 3. Refer to Guides for Methodology
When making decisions, consult reference guides:
- Choosing workflow → Agile workflows guide
- Assessing risk → Risk management guide
- Planning communication → Stakeholder communication guide

### 4. Maintain Consistency
Use same templates and formats throughout project for stakeholder predictability.

### 5. Tailor Communication to Audience
Read stakeholder communication guide to adapt messages:
- Executives: Brief, quantified, high-level
- Product: Features, trade-offs, user impact
- Technical: Architecture, debt, details

### 6. Track Dependencies Proactively
Don't wait for blockers - use dependency management guide to identify and track early.

### 7. Use Metrics to Drive Improvement
Velocity, cycle time, and throughput are tools for improvement, not performance ratings.

### 8. Document Decisions and Learnings
Use retrospective and status report templates to capture lessons learned for future reference.

---

## Resources

### assets/
Template files designed to be copied and customized:

- **project-kickoff-template.md** - Comprehensive project initialization
- **sprint-planning-template.md** - Sprint setup with capacity and backlog
- **daily-standup-template.md** - Daily team sync format
- **retrospective-template.md** - Sprint reflection and improvement
- **project-status-report-template.md** - Stakeholder status communication
- **milestone-tracking-template.md** - Long-term progress and deliverables

**Usage:** Copy template, fill in sections with project details, customize as needed.

### references/
Comprehensive reference guides loaded into context:

- **agile-workflows.md** - Scrum, Kanban, backlog management, velocity planning
- **risk-management.md** - Risk identification, assessment, mitigation, monitoring
- **stakeholder-communication.md** - Communication planning, expectation management, audience tailoring
- **dependency-management.md** - Dependency tracking, critical path, cross-team coordination
- **team-velocity-tracking.md** - Estimation, velocity measurement, forecasting, burndown charts

**Usage:** Read relevant sections to inform project coordination and decision-making.

---

## Examples

### Example 1: Planning Sprint 10

```markdown
User: "@project-ops, plan sprint 10 for authentication feature"

Process:
1. Load project-ops-templates skill
2. Read team-velocity-tracking.md → Historical velocity = 27 points
3. Read agile-workflows.md → Sprint Planning best practices
4. Check team capacity: 5 people × 10 days - 2 PTO days = 48 productive days
5. Use sprint-planning-template.md to structure:
   - Sprint goal: "Complete user authentication MVP"
   - P0 stories: Login (8pts), Password reset (5pts), Sessions (5pts) = 18pts
   - P1 stories: Email verification (5pts), Profile page (3pts) = 8pts
   - Total: 26 points (within velocity 27 ± 3)
6. Document dependencies: API spec from backend team
7. Identify risks: Email delivery reliability (medium risk)

Output:
- Sprint 10 plan with goal, backlog, capacity analysis, dependencies, risks
- Sprint backlog created in Linear
- Team notified of sprint plan
```

### Example 2: Handling Critical Blocker

```markdown
User: "@project-ops, vendor API is down, sprint is blocked"

Process:
1. Load project-ops-templates skill
2. Read risk-management.md → Escalation process
3. Read dependency-management.md → Handling dependency delays
4. Assess impact: Blocks 2 stories (12 points), 40% of sprint commitment
5. Explore options:
   - Workaround: Use mock API temporarily (2 hours to implement)
   - Parallel work: Pull in other stories from backlog
   - Escalate: Contact vendor account manager
6. Use blocker escalation template from stakeholder-communication.md
7. Update project-status-report-template.md with impact and recovery plan

Output:
- Blocker escalation email sent to vendor + internal stakeholders
- Implemented mock API workaround (team unblocked in 2 hours)
- Pulled 2 additional stories (10 points) into sprint
- Updated status report: Sprint at risk → On track (with mitigation)
```

### Example 3: Quarterly Stakeholder Review

```markdown
User: "@project-ops, prepare Q1 review for exec team"

Process:
1. Load project-ops-templates skill
2. Read stakeholder-communication.md → Executives communication style
3. Use project-status-report-template.md as base
4. Read milestone-tracking-template.md → Pull milestone progress
5. Tailor for executive audience:
   - Lead with: Overall status 🟢, 60% complete, on track for June launch
   - Quantify: $180k of $300k spent (60% budget, 75% timeline)
   - Highlight: 4 of 6 milestones complete, authentication MVP delivered
   - Top 3 risks with mitigation: Payment integration (POC complete), Vendor delays (backup identified)
   - Decision needed: Approve $20k for additional storage capacity
6. Create 1-page executive summary (2-3 minutes to read)
7. Prepare demo of working features for review meeting

Output:
- Executive status report (1-page, quantified, scannable)
- Demo script for live review
- Decision request for storage capacity
- Q2 roadmap preview
```

---

## Tips & Tricks

### Tip 1: Batch Template Updates
When running multiple sprints, copy sprint-planning-template.md and retrospective-template.md once, then update for each sprint. Save time by reusing structure.

### Tip 2: Create Project-Specific Variants
For long projects, create customized versions of templates with project-specific sections pre-filled (team names, stakeholders, etc.).

### Tip 3: Reference Guides are Progressive
Don't read all reference guides upfront. Start with what you need (e.g., agile-workflows for sprint planning), load others as needed.

### Tip 4: Use Templates for Async Communication
Daily standup and status report templates work great for async teams - post updates in Slack/Linear instead of meetings.

### Tip 5: Combine Templates
Major milestones = milestone tracking + status report + risk management. Use multiple templates together for comprehensive communication.

### Tip 6: Archive Completed Documents
Store filled-out templates in `docs/projects/[project-name]/` for historical reference and pattern identification.

### Tip 7: Track Template Effectiveness
If stakeholders repeatedly ask for same information, update template to include that information proactively.

### Tip 8: Velocity is Team-Specific
Never compare velocity across teams. Use velocity guides only for that team's planning and improvement.

---

**Related Skills:**
- research-templates - Use when evaluating technologies or tools for the project
- technical-researcher (agent) - Complements with deep technical investigation

**Related Agents:**
- @project-ops - Primary consumer of this skill's templates and frameworks
- @architect - May use kickoff and planning templates for technical initiatives
- @qa-engineer - May use test planning sections of templates

---

**Last Updated:** 2024-10-24
**Version:** 1.0
