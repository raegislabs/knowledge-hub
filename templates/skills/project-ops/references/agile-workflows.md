# Agile Workflows Reference Guide

## Overview

This guide provides comprehensive guidance on implementing agile workflows, with focus on Scrum and Kanban methodologies. Use this when coordinating projects, selecting workflows, or optimizing team processes.

---

## Agile Fundamentals

### Core Agile Values (Agile Manifesto)

1. **Individuals and interactions** over processes and tools
2. **Working software** over comprehensive documentation
3. **Customer collaboration** over contract negotiation
4. **Responding to change** over following a plan

### Agile Principles

**Delivery & Feedback:**
- Deliver working software frequently (weeks, not months)
- Welcome changing requirements, even late in development
- Business people and developers work together daily
- Face-to-face conversation is best communication

**Quality & Excellence:**
- Continuous attention to technical excellence and good design
- Simplicity—the art of maximizing work not done
- Self-organizing teams produce best architectures and designs

**Sustainability & Reflection:**
- Maintain constant, sustainable pace indefinitely
- Reflect and adjust behavior regularly

---

## Scrum Framework

### Overview

**Best for:**
- New or evolving products
- Complex problem domains
- Teams learning agile
- Need for regular inspection and adaptation

**Not ideal for:**
- Operational/maintenance work (use Kanban)
- Solo developers (overhead too high)
- Extremely predictable, repetitive work

### Scrum Roles

#### Product Owner
**Responsibilities:**
- Maximize value of product and work of team
- Manage product backlog (ordering, clarity, visibility)
- Ensure backlog transparent and understood
- Make final decisions on priority and scope

**Key Activities:**
- Define user stories with acceptance criteria
- Prioritize backlog based on business value
- Accept or reject completed work
- Communicate vision to team and stakeholders

**Anti-patterns:**
- Micromanaging team ("how" instead of "what")
- Skipping sprint planning/review
- Changing sprint goal mid-sprint
- Acting as project manager (Scrum has no PM role)

#### Scrum Master
**Responsibilities:**
- Facilitate Scrum events
- Remove impediments
- Coach team on agile practices
- Shield team from external interruptions

**Key Activities:**
- Facilitate daily standups, planning, review, retrospective
- Track and escalate blockers
- Help team improve velocity and quality
- Ensure Scrum values and rules followed

**Not responsible for:**
- Task assignment (team self-organizes)
- Performance reviews (not a manager)
- Technical decisions (team decides)

#### Development Team
**Responsibilities:**
- Deliver potentially shippable increment each sprint
- Self-organize to accomplish sprint goal
- Estimate work and commit to sprint backlog
- Maintain quality standards

**Team Characteristics:**
- Cross-functional (all skills to complete work)
- Self-organizing (no sub-teams or titles)
- 3-9 members (smaller = more communication)
- Collectively accountable for sprint success

### Scrum Events (Ceremonies)

#### Sprint
**Duration:** 1-4 weeks (2 weeks most common)
**Purpose:** Time-box for completing planned work
**Output:** Potentially shippable product increment

**Sprint Rules:**
- No changes that endanger sprint goal
- Quality does not decrease
- Scope can be clarified/renegotiated with Product Owner
- Sprint can be cancelled (rare - only Product Owner)

#### Sprint Planning
**When:** Start of every sprint
**Duration:** 2 hours per week of sprint (4 hours for 2-week sprint)
**Attendees:** Product Owner, Scrum Master, Development Team

**Purpose:** Plan the work for upcoming sprint

**Agenda:**
1. **Part 1 (What):** What can be delivered this sprint?
   - Product Owner presents highest priority backlog items
   - Team discusses and asks questions
   - Team forecasts what they can complete
   - Team crafts sprint goal

2. **Part 2 (How):** How will chosen work be done?
   - Team breaks user stories into tasks
   - Team estimates tasks
   - Team creates sprint backlog

**Outputs:**
- Sprint goal (one-sentence objective)
- Sprint backlog (committed user stories + tasks)
- Team understanding of work

**Best Practices:**
- Prepare backlog before planning (grooming)
- Use historical velocity for forecasting
- Include testing/deployment tasks
- Confirm team capacity (PTO, holidays, etc.)

#### Daily Standup (Daily Scrum)
**When:** Same time every day
**Duration:** 15 minutes (strict timebox)
**Attendees:** Development Team (Scrum Master facilitates, Product Owner optional)

**Purpose:** Synchronize work and plan next 24 hours

**Format Option 1 (Classic 3 Questions):**
Each team member answers:
1. What did I do yesterday toward sprint goal?
2. What will I do today toward sprint goal?
3. Any impediments blocking me?

**Format Option 2 (Walk the Board):**
Go through each In Progress item on board
- Who's working on it?
- What's the status?
- Any blockers?

**Best Practices:**
- Same time and place daily
- Stand up (keeps meeting short)
- Focus on work, not people
- Identify blockers, solve them after standup
- Update board during or after standup
- Scrum Master takes notes on blockers

**Anti-patterns:**
- Status report to manager (it's team sync)
- Solving problems in standup (parking lot)
- People arrive late (disrespectful)
- Standup >15 minutes (lose focus)

#### Sprint Review (Demo)
**When:** End of every sprint
**Duration:** 1 hour per week of sprint (2 hours for 2-week sprint)
**Attendees:** Scrum Team + stakeholders

**Purpose:** Inspect increment and adapt backlog

**Agenda:**
1. Product Owner explains what was Done vs. not Done
2. Development Team demonstrates working software
3. Development Team discusses what went well, problems, solutions
4. Product Owner discusses backlog, likely target/delivery dates
5. Entire group collaborates on what to do next
6. Review marketplace changes, timeline, budget, capabilities

**Outputs:**
- Stakeholder feedback
- Revised product backlog
- Adjusted priorities

**Best Practices:**
- Demonstrate in production-like environment
- Show real user scenarios, not features
- Get actual stakeholder feedback
- Keep it informal (working session, not report)

**Anti-patterns:**
- Demoing unfinished work ("it's almost done")
- Accepting work that doesn't meet Definition of Done
- PowerPoint instead of working software
- No stakeholders attend

#### Sprint Retrospective
**When:** After sprint review, before next planning
**Duration:** 45 min per week of sprint (1.5 hours for 2-week sprint)
**Attendees:** Scrum Team only (private)

**Purpose:** Inspect team and processes, create improvement plan

**Agenda:**
1. Set the stage (create safe environment)
2. Gather data (what happened this sprint?)
3. Generate insights (why did it happen?)
4. Decide what to do (actionable improvements)
5. Close (appreciate team, confirm actions)

**Common Formats:**
- Start/Stop/Continue
- What went well / What didn't / What to try
- 4Ls: Liked, Learned, Lacked, Longed For
- Sailboat: Wind (good), Anchors (bad), Island (goal), Rocks (risks)

**Outputs:**
- 1-3 actionable improvements with owners
- Plan to implement improvements next sprint

**Best Practices:**
- Blame-free, psychological safety
- Focus on process, not people
- Create specific actions (not vague wishes)
- Review previous retro actions
- Rotate facilitator and format

---

## Kanban Method

### Overview

**Best for:**
- Operational/maintenance work
- Continuous flow, no sprints
- Support teams
- Teams with highly variable work
- Mature teams optimizing flow

**Not ideal for:**
- Teams new to agile (Scrum provides more structure)
- Long-term project planning (no sprint boundaries)

### Kanban Principles

**Core Practices:**
1. **Visualize workflow** - Make work visible on board
2. **Limit WIP** - Limit work in progress to reduce context switching
3. **Manage flow** - Monitor and optimize flow of work
4. **Make policies explicit** - Clear rules visible to all
5. **Implement feedback loops** - Regular review and adaptation
6. **Improve collaboratively** - Evolve experimentally using models

### Kanban Board

**Basic Board Structure:**
```
| Backlog | To Do | In Progress | Review | Done |
|---------|-------|-------------|--------|------|
|  [...]  | [...]  |    [...]   | [...]  | [...] |
```

**Advanced Board Structure:**
```
| Backlog | Ready | Dev (3) | Code Review (2) | Test (2) | Deploy (1) | Done |
|---------|-------|---------|-----------------|----------|------------|------|
|         |       | WIP=3   | WIP=2           | WIP=2    | WIP=1      |      |
```

**Column Types:**
- **Backlog:** Unrefined work
- **Ready:** Refined, ready to start
- **In Progress:** Active work (may have sub-columns)
- **Review/QA:** Quality gates
- **Done:** Completed and delivered

### Work in Progress (WIP) Limits

**Purpose:** Reduce multitasking, expose bottlenecks, improve flow

**How to Set WIP Limits:**
1. Start with: `WIP Limit = Number of Team Members × 1.5`
2. Apply to each in-progress column
3. Adjust based on observed flow

**Example:**
- Team of 4 people
- Initial WIP limit: 4 × 1.5 = 6
- If work piles up in "In Progress": Reduce to 5
- If team frequently blocked: Increase to 7

**When WIP Limit Reached:**
1. Cannot pull new work into that column
2. Team swarms to clear bottleneck
3. Help upstream or downstream to keep flow moving

### Kanban Metrics

#### Lead Time
**Definition:** Time from work entering system to completion
**Formula:** `Lead Time = Time work enters "To Do" → Time work reaches "Done"`
**Target:** Minimize and stabilize
**Use:** Customer-facing SLA, predictability

#### Cycle Time
**Definition:** Time from starting work to completion
**Formula:** `Cycle Time = Time work enters "In Progress" → Time work reaches "Done"`
**Target:** Minimize and stabilize
**Use:** Internal efficiency, team performance

#### Throughput
**Definition:** Number of items completed per time period
**Formula:** `Throughput = Items completed / Time period (e.g., week)`
**Target:** Increase over time
**Use:** Capacity planning, forecasting

#### Cumulative Flow Diagram (CFD)
**Purpose:** Visualize work distribution across columns over time

**How to Read CFD:**
- **Width of band:** Amount of work in each stage
- **Flat line:** No work entering or leaving (stagnation)
- **Widening band:** Work accumulating (bottleneck)
- **Narrowing band:** Work being cleared

### Kanban Events

#### Daily Standup
- Walk the board from right to left (focus on finishing)
- Identify blockers
- Check WIP limits
- 15 minutes max

#### Replenishment Meeting
- **When:** Weekly or as needed
- **Purpose:** Pull work from backlog to "Ready"
- **Attendees:** Product Owner, team representatives
- **Activities:** Prioritize backlog, refine items, pull to ready queue

#### Kanban Review
- **When:** Weekly or bi-weekly
- **Purpose:** Review completed work, metrics, stakeholder feedback
- **Attendees:** Team + stakeholders
- **Activities:** Demo completed work, review throughput/lead time

#### Retrospective
- **When:** Monthly or as needed
- **Purpose:** Improve process
- **Activities:** Review metrics, identify bottlenecks, experiment with improvements

---

## Scrum vs Kanban Comparison

| Aspect | Scrum | Kanban |
|--------|-------|--------|
| **Work Cadence** | Fixed sprints (1-4 weeks) | Continuous flow |
| **Roles** | Product Owner, Scrum Master, Team | No prescribed roles |
| **Planning** | Sprint planning every sprint | Continuous, just-in-time |
| **Changes** | No mid-sprint scope changes | Can add work anytime (if WIP allows) |
| **Metrics** | Velocity (story points/sprint) | Lead time, cycle time, throughput |
| **Board** | Reset each sprint | Persistent, continuous |
| **WIP Limits** | Implicit (sprint backlog) | Explicit per column |
| **Estimation** | Required (story points) | Optional |
| **Ceremonies** | 4 required ceremonies | Fewer, more flexible |
| **Best For** | Product development, new teams | Operations, mature teams |

---

## Choosing Between Scrum and Kanban

### Use Scrum When:
- Building new products or features
- Need regular planning and reflection cycles
- Team is new to agile
- Stakeholders want predictable delivery dates
- Work can be batched into time-boxed iterations
- Team wants structure and defined roles

**Example Scenarios:**
- Developing new web application
- Building mobile app with quarterly releases
- Cross-functional team creating new product line

### Use Kanban When:
- Operational or maintenance work
- Work arrives unpredictably
- Team is experienced with agile
- Need continuous delivery
- Work varies greatly in size
- Want minimal process overhead

**Example Scenarios:**
- DevOps/SRE team handling incidents
- Customer support team
- Marketing team with continuous campaign work
- Bug fixing / maintenance team

### Hybrid: Scrumban
**Combines:**
- Scrum's structure (sprints, roles, ceremonies)
- Kanban's visualization and WIP limits

**Use When:**
- Team does both project work and operational work
- Want sprint boundaries but continuous flow
- Transitioning from Scrum to Kanban

---

## Backlog Management

### User Story Format

**Template:**
```
As a [user type],
I want to [action],
So that [benefit].
```

**Example:**
```
As a customer,
I want to reset my password via email,
So that I can regain access if I forget my password.
```

### Acceptance Criteria

**Format: Given-When-Then**
```
Given [precondition],
When [action],
Then [expected result].
```

**Example:**
```
Given I am on the login page,
When I click "Forgot Password" and enter my email,
Then I receive a password reset link within 5 minutes.
```

### Definition of Ready (DoR)

Story is ready to be worked on when:
- [ ] User story clearly written
- [ ] Acceptance criteria defined
- [ ] Dependencies identified
- [ ] Testable
- [ ] Estimated (if using estimates)
- [ ] Small enough to complete in one sprint
- [ ] Prioritized by Product Owner

### Definition of Done (DoD)

Story is done when:
- [ ] Code complete and follows standards
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Deployed to staging and verified
- [ ] Product Owner accepts work

### Story Sizing

**T-Shirt Sizes:**
- XS: < 1 day
- S: 1-2 days
- M: 3-5 days
- L: 1-2 weeks
- XL: > 2 weeks (too big, break down)

**Story Points (Fibonacci):**
- 1, 2, 3, 5, 8, 13, 21
- Relative sizing (2 is twice the effort of 1)
- Consider complexity, effort, uncertainty

**Estimation Techniques:**
- **Planning Poker:** Team plays cards simultaneously
- **T-Shirt Sizing:** Quick, high-level estimation
- **Affinity Estimation:** Group similar-sized stories

---

## Velocity and Capacity Planning

### Velocity (Scrum)

**Definition:** Average story points completed per sprint

**Calculation:**
```
Velocity = Avg(Story points completed in last 3-5 sprints)
```

**Example:**
- Sprint 1: 25 points
- Sprint 2: 30 points
- Sprint 3: 28 points
- **Average Velocity:** 27.7 points → Plan ~28 points next sprint

**Uses:**
- Sprint planning (how much to commit)
- Release planning (how many sprints to complete epic)
- Forecasting delivery dates

**Important:**
- Velocity is team-specific (don't compare teams)
- Recalculate when team composition changes
- Expect 2-3 sprints to stabilize for new teams

### Capacity Planning

**Factors:**
- Team size
- Sprint duration
- Holidays / PTO
- Non-sprint work (support, meetings, etc.)

**Calculation:**
```
Capacity = (Team members × Days in sprint - PTO days) × Productive hours per day
```

**Example:**
- 5 team members
- 10-day sprint
- 1 person on PTO for 2 days
- 6 productive hours/day (after meetings, breaks)

```
Capacity = (5 × 10 - 2) × 6 = 48 × 6 = 288 hours
```

---

## Common Agile Anti-Patterns

### Process Anti-Patterns

**Cargo Cult Agile:**
- Following ceremonies without understanding purpose
- **Fix:** Focus on agile values, not just rituals

**Water-Scrum-Fall:**
- Scrum in development, waterfall before/after
- **Fix:** Extend agile practices to entire delivery pipeline

**Scrum Master as Project Manager:**
- Scrum Master assigning tasks, tracking hours
- **Fix:** Team self-organizes, Scrum Master facilitates

**No Retrospectives:**
- Skipping retros when "too busy"
- **Fix:** Retros are how you get less busy (improve efficiency)

### Team Anti-Patterns

**Hero Culture:**
- One person does all critical work
- **Fix:** Knowledge sharing, pair programming, cross-training

**Lack of Ownership:**
- "That's not my job" mentality
- **Fix:** Cross-functional teams, collective ownership

**Zombie Scrum:**
- Going through motions, no energy or improvement
- **Fix:** Re-engage with agile values, meaningful retrospectives

### Technical Anti-Patterns

**No Definition of Done:**
- Work "done" but not shippable
- **Fix:** Create and enforce DoD

**Accumulating Technical Debt:**
- Never addressing tech debt
- **Fix:** Allocate 10-20% capacity to tech debt each sprint

**No Automated Testing:**
- Manual regression every sprint
- **Fix:** Invest in test automation

---

## Best Practices

### 1. Start Simple, Iterate
- Begin with basic Scrum or Kanban
- Add complexity only when needed
- Evolve based on retrospective insights

### 2. Focus on Outcomes, Not Output
- Measure value delivered, not story points completed
- Business outcomes > velocity

### 3. Visualize Everything
- Make work, progress, blockers visible
- Physical or digital board everyone can see

### 4. Limit Work in Progress
- Finish work before starting new work
- Reduces context switching, improves flow

### 5. Optimize for Learning
- Run experiments
- Measure results
- Adapt based on data

### 6. Protect Team Time
- Limit meetings and interruptions
- Dedicated focus time for development
- Say no to non-sprint work (in Scrum)

### 7. Continuous Improvement
- Every retrospective = 1-3 concrete improvements
- Track improvement impact
- Celebrate wins

---

## Resources & Further Reading

**Scrum:**
- Scrum Guide (official, ~20 pages)
- "Scrum: The Art of Doing Twice the Work in Half the Time" by Jeff Sutherland
- "User Stories Applied" by Mike Cohn

**Kanban:**
- "Kanban: Successful Evolutionary Change for Your Technology Business" by David Anderson
- "The Phoenix Project" by Gene Kim (DevOps + Kanban novel)

**General Agile:**
- Agile Manifesto (original, 4 values + 12 principles)
- "The Lean Startup" by Eric Ries
- "Continuous Delivery" by Jez Humble

---

**Last Updated:** 2024-10-24
**Version:** 1.0
