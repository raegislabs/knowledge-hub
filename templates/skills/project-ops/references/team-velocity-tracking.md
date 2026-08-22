# Team Velocity Tracking Reference Guide

## Overview

This guide provides comprehensive methods for measuring, tracking, and improving team velocity and throughput. Use when planning sprints, forecasting delivery, or optimizing team performance.

---

## Velocity Fundamentals

### What is Velocity?

**Definition:** The average amount of work a team completes per sprint, measured in story points.

**Formula:**
```
Velocity = Average(Story points completed in last 3-5 sprints)
```

**Example:**
- Sprint 1: 23 points
- Sprint 2: 27 points
- Sprint 3: 25 points
- **Average Velocity: 25 points**

**Purpose:**
- **Planning:** How much work to commit to in next sprint
- **Forecasting:** How many sprints to complete remaining backlog
- **Tracking:** Is team capacity increasing, stable, or declining?

### What Velocity is NOT

**Common Misconceptions:**

❌ **NOT a measure of individual productivity**
- Velocity is team metric, not individual metric
- Don't compare team members by story points

❌ **NOT comparable across teams**
- Team A's "5 points" ≠ Team B's "5 points"
- Each team has own estimation scale

❌ **NOT a quality metric**
- Completing 30 points of buggy code < 20 points of solid code
- Velocity + quality = what matters

❌ **NOT a constant**
- Velocity changes with team composition, technical debt, complexity
- Expect variation ±20%

✅ **Velocity IS:**
- Planning tool for team
- Forecasting mechanism
- Relative measure of team capacity over time

---

## Story Point Estimation

### Story Points Explained

**Story points measure:**
- **Complexity:** How hard is this?
- **Effort:** How much work?
- **Uncertainty:** How much don't we know?

**Story points DO NOT measure:**
- Hours (3 points ≠ 3 hours)
- Calendar time (3 points could be 1 day or 3 days depending on complexity)

### Fibonacci Scale

**Common scale:** 1, 2, 3, 5, 8, 13, 21

**Why Fibonacci?**
- Forces choice between significantly different sizes
- Harder to estimate large things precisely (13 vs 15 is meaningless)
- Uncertainty increases with size

**Reference Stories:**

**1 point - Trivial:**
- Fix typo in UI
- Update configuration value
- ~1 hour, no complexity

**2 points - Simple:**
- Add new field to form
- Basic CRUD operation
- ~2-4 hours, low complexity

**3 points - Small:**
- Add validation to existing feature
- Simple API endpoint
- ~0.5-1 day, some complexity

**5 points - Medium:**
- New feature with frontend + backend
- Integration with existing system
- ~1-2 days, moderate complexity

**8 points - Large:**
- Complex feature across multiple components
- Significant uncertainty
- ~2-3 days, high complexity

**13 points - Very Large:**
- Major feature or epic component
- Consider breaking down
- ~3-5 days, very high complexity

**21+ points - Too Large:**
- Break down into smaller stories
- Too much uncertainty to estimate reliably

### Estimation Techniques

#### Planning Poker

**Process:**
1. Product Owner reads user story
2. Team discusses and asks questions
3. Each person selects a card (1, 2, 3, 5, 8, 13, 21) in secret
4. Everyone reveals simultaneously
5. If consensus (or close), that's the estimate
6. If divergence, highest and lowest explain reasoning
7. Repeat until consensus

**Why it works:**
- Prevents anchoring (first person biasing others)
- Surfaces different perspectives
- Encourages discussion

**Example:**
- Story: "Add password reset via email"
- Reveals: 3, 3, 5, 8
- Person who said 8: "We need to build email template, configure SMTP, test deliverability"
- Person who said 3: "Oh, I forgot about email configuration. I agree with 8"
- Re-vote: 8, 8, 8, 5
- Settled at 8 points

#### T-Shirt Sizing (Quick Estimation)

**Scale:** XS, S, M, L, XL

**Use when:**
- High-level backlog grooming
- Many items to estimate quickly
- Early planning phase

**Convert to points:**
- XS = 1-2 points
- S = 3 points
- M = 5 points
- L = 8 points
- XL = 13+ points (break down)

#### Affinity Estimation (Bulk Estimation)

**Process:**
1. Write each story on card
2. Team silently sorts cards into size categories (Small, Medium, Large)
3. Discuss items where there's disagreement
4. Assign point values to categories

**Use when:** Estimating many stories at once (20+ backlog items)

---

## Measuring Velocity

### Velocity Calculation

**Method 1: Simple Average (Last 3 Sprints)**
```
Sprint 1: 25 points
Sprint 2: 30 points
Sprint 3: 28 points

Velocity = (25 + 30 + 28) / 3 = 27.7 ≈ 28 points
```

**Method 2: Weighted Average (More Recent = More Weight)**
```
Sprint 1 (oldest): 25 points × 1 = 25
Sprint 2: 30 points × 2 = 60
Sprint 3 (most recent): 28 points × 3 = 84

Velocity = (25 + 60 + 84) / (1 + 2 + 3) = 169 / 6 = 28.2 points
```

**Method 3: Exclude Outliers**
```
Sprint 1: 25 points
Sprint 2: 15 points (outlier - 2 people on vacation)
Sprint 3: 28 points
Sprint 4: 27 points
Sprint 5: 26 points

Velocity = (25 + 28 + 27 + 26) / 4 = 26.5 points
(Exclude sprint 2 because of known capacity issue)
```

### What to Include in Velocity

**Include:**
- ✅ User stories completed and accepted
- ✅ Bug fixes (if estimated in points)
- ✅ Technical debt work (if estimated in points)
- ✅ Spikes (research stories, if time-boxed and estimated)

**Exclude:**
- ❌ Work not completed (carry over to next sprint)
- ❌ Work completed but not accepted by Product Owner
- ❌ Non-sprint work (support, meetings)
- ❌ Work done outside the sprint

**Example:**
- Committed: 30 points
- Completed & accepted: 25 points
- Completed but not accepted: 3 points (UI issues)
- Carried over: 2 points

**Velocity for this sprint:** 25 points (not 28, not 30)

---

## Velocity Stability

### Healthy Velocity Pattern

**Ideal velocity over time:**
```
Sprint:  1   2   3   4   5   6   7   8
Points: 20  25  24  26  25  27  26  25
Trend:  ─────────────────────────────→ Stable

Average: 25 ± 2 points (stable)
```

**Characteristics:**
- Variation within ±20%
- No clear upward or downward trend
- Predictable capacity

### Unstable Velocity (Red Flags)

**Pattern 1: High Variation**
```
Sprint:  1   2   3   4   5   6
Points: 30  15  28  10  32  18
Trend:  ∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿∿→ Unstable

Issue: Inconsistent estimation or capacity planning
```

**Causes:**
- Over-committing in some sprints
- Team capacity not accounted for (PTO, meetings)
- Story sizes too large (breaking down inconsistently)

**Fix:**
- Use historical velocity for planning (don't over-commit)
- Account for capacity (PTO, holidays, non-sprint work)
- Break stories into consistent sizes (most stories 3-5 points)

**Pattern 2: Declining Velocity**
```
Sprint:  1   2   3   4   5   6
Points: 30  28  25  22  20  18
Trend:  ↘︎ ↘︎ ↘︎ ↘︎ ↘︎ ↘︎ ↘︎ ↘︎ ↘︎→ Declining

Issue: Team slowing down
```

**Causes:**
- Accumulating technical debt (code harder to change)
- Team burnout
- Increasing complexity
- Losing team members

**Fix:**
- Allocate 10-20% capacity to technical debt each sprint
- Address team morale and burnout
- Simplify architecture where possible
- Stabilize team composition

**Pattern 3: False Inflation**
```
Sprint:  1   2   3   4   5   6
Points: 20  25  30  35  40  45
Trend:  ↗︎ ↗︎ ↗︎ ↗︎ ↗︎ ↗︎ ↗︎ ↗︎ ↗︎→ Inflating

Issue: Story point inflation (not real improvement)
```

**Causes:**
- Team inflating estimates to look more productive
- Pressure to increase velocity
- Misunderstanding of velocity purpose

**Fix:**
- Emphasize velocity is NOT a performance metric
- Focus on value delivered, not points
- Re-baseline estimation against reference stories

---

## Forecasting with Velocity

### Release Planning

**Question:** "How many sprints to complete remaining backlog?"

**Formula:**
```
Sprints Needed = Remaining Story Points / Average Velocity
```

**Example:**
- Remaining backlog: 150 points
- Average velocity: 25 points/sprint
- Sprints needed: 150 / 25 = 6 sprints

**Add buffer:**
- Optimistic (10% buffer): 6.6 ≈ 7 sprints
- Realistic (25% buffer): 7.5 ≈ 8 sprints
- Conservative (50% buffer): 9 sprints

**Recommendation:** Use realistic (25%) for internal planning, conservative (50%) for external commitments

### Feature Forecasting

**Question:** "When will feature X be complete?"

**Process:**
1. Estimate feature in story points (break down into stories)
2. Divide by team velocity
3. Add to current date

**Example:**
- Feature: User authentication (40 points)
- Team velocity: 25 points/sprint
- Sprints needed: 40 / 25 = 1.6 ≈ 2 sprints
- Current sprint ends: March 15
- Forecast completion: April 12 (2 sprints later)

**Confidence levels:**
- 50% confidence: Use average velocity
- 70% confidence: Use average velocity - 10%
- 90% confidence: Use average velocity - 25%

---

## Burndown Charts

### Sprint Burndown

**Purpose:** Track progress toward sprint goal

**Axes:**
- X-axis: Days in sprint
- Y-axis: Story points remaining

**Ideal burndown:**
```
Points
  30 ┤╲
     │ ╲
  20 │  ╲
     │   ╲
  10 │    ╲
     │     ╲
   0 └──────╲───→ Days
     0  2  4  6  8 10
```

**Reading the chart:**

**Ahead of schedule:**
```
  30 ┤╲
     │ ╲╲  ← Actual ahead of ideal
  20 │   ╲╲
     │    ╲╲
  10 │     ╲╲
     │      ╲╲
   0 └───────╲╲→
```
**Good sign:** Team may finish early or pull in stretch goals

**Behind schedule:**
```
  30 ┤╲
     │ ╲
  20 │  ╲  ← Actual behind ideal
     │   ╲╲
  10 │    ╲╲
     │     ╲╲
   0 └──────╲╲→
```
**Warning sign:** May not complete sprint commitment

**Flat line (no progress):**
```
  30 ┤╲
     │ ╲
  20 │  ───────  ← No change for 3 days
     │   ╲
  10 │    ╲
     │     ╲
   0 └──────╲→
```
**Red flag:** Team stuck or working on non-sprint work

### Release Burndown

**Purpose:** Track progress toward release goal over multiple sprints

**Axes:**
- X-axis: Sprints
- Y-axis: Story points remaining in release backlog

**Example:**
```
Points
 200 ┤╲
     │ ╲
 150 │  ╲
     │   ╲
 100 │    ╲
     │     ╲
  50 │      ╲
     │       ╲
   0 └────────╲───→ Sprints
     0  1  2  3  4  5  6
```

**Adding scope mid-release:**
```
Points
 200 ┤╲
     │ ╲
 150 │  ╲  ↗︎ ← Scope added
     │   ╱
 100 │  ╱
     │ ╱
  50 │╱
     │
   0 └─────────────→ Sprints
```

---

## Alternative Metrics

### Throughput (Kanban)

**Definition:** Number of items completed per time period

**Measurement:**
- Count of stories completed per week/month
- Doesn't use story points

**When to use:**
- Kanban teams (no sprints)
- Stories are consistently sized
- Simplicity preferred over story points

**Example:**
- Week 1: 8 stories completed
- Week 2: 7 stories completed
- Week 3: 9 stories completed
- **Average throughput:** 8 stories/week

### Cycle Time

**Definition:** Time from when work starts to when it's complete

**Measurement:**
```
Cycle Time = Date work entered "In Progress" → Date work reached "Done"
```

**Example:**
- Story entered "In Progress": March 1
- Story marked "Done": March 5
- **Cycle Time:** 4 days

**Use for:**
- Identifying bottlenecks (which stories take longest?)
- Setting SLAs ("We'll complete work within 5 days")
- Improving flow

**Target:** Minimize and stabilize cycle time

### Lead Time

**Definition:** Time from when work is requested to when it's delivered

**Measurement:**
```
Lead Time = Date story created → Date story marked "Done"
```

**Example:**
- Story created: February 15
- Story marked "Done": March 5
- **Lead Time:** 18 days

**Difference from Cycle Time:**
- Lead time includes time waiting in backlog
- Cycle time only measures active work

---

## Improving Velocity

### Sustainable Improvements

**1. Reduce Technical Debt**
- Allocate 10-20% capacity to refactoring
- Pay down debt before it slows you down
- Measure: Does velocity increase after debt reduction?

**2. Improve Estimation Accuracy**
- Calibrate against reference stories
- Retrospect on estimation misses
- Break down large stories (most stories 3-5 points)

**3. Remove Blockers Faster**
- Track blocker resolution time
- Escalate blockers >1 day
- Reduce external dependencies

**4. Increase Focus Time**
- Reduce meetings and interruptions
- Protect 4-hour blocks for deep work
- Minimize context switching

**5. Automate Repetitive Work**
- Automated testing (reduce manual QA time)
- CI/CD pipelines (reduce deploy time)
- Code generation (reduce boilerplate)

**6. Cross-Train Team**
- Pair programming
- Knowledge sharing sessions
- Reduce single points of failure (any team member can work on anything)

### Unsustainable "Improvements" (Avoid)

❌ **Inflating story points**
- Makes velocity meaningless
- Doesn't deliver more value

❌ **Cutting quality**
- Faster short-term, slower long-term (bugs, debt)
- Not sustainable

❌ **Working overtime**
- Burnout
- Velocity will crash later

❌ **Pressure to "hit velocity"**
- Velocity is forecast tool, not performance metric
- Pressure leads to gaming the system

---

## Velocity for New Teams

### Establishing Baseline Velocity

**Sprints 1-3: Volatile**
- Velocity will vary widely
- Team learning to estimate
- Don't rely on velocity for planning yet

**Sprints 4-6: Stabilizing**
- Velocity starts to stabilize
- Can use for rough planning
- Still expect ±30% variation

**Sprints 7+: Stable**
- Velocity predictable within ±20%
- Reliable for planning and forecasting

**Recommendation:**
- First 3 sprints: Plan conservatively, focus on learning
- Sprints 4-6: Use velocity but add 30% buffer
- Sprints 7+: Use velocity with 20% buffer

### When Team Changes

**Team member leaves:**
- Expect velocity drop proportional to team size
- 5-person team loses 1 = ~20% velocity drop
- Recalculate velocity after 2-3 sprints

**Team member joins:**
- Initially slows team down (ramp-up time)
- Expect velocity increase after 2-3 sprints

**Major skill change:**
- Team switches to new tech stack
- Velocity drops 30-50% initially
- Recovers over 4-6 sprints as team learns

---

## Best Practices

### 1. Focus on Trends, Not Single Sprints
- One sprint's velocity doesn't mean much
- Look at average over 3-5 sprints
- Identify trends (stable, increasing, decreasing)

### 2. Don't Compare Teams
- Each team's point scale is unique
- Team A's velocity > Team B's doesn't mean Team A is better
- Compare team to itself over time

### 3. Velocity is Not a Goal
- Don't set "increase velocity by 20%" as goal
- Velocity is outcome, not objective
- Focus on delivering value, removing blockers, improving quality

### 4. Account for Capacity Variations
- Track PTO, holidays, training
- Adjust planning based on available capacity
- Don't commit 30 points if 20% of team is out

### 5. Keep Stories Consistent Size
- Most stories 3-5 points
- Outliers (1, 8, 13) are ok occasionally
- Break down 21+ point stories

### 6. Complete Work Before Starting New Work
- Better to complete 20 points than start 30 and finish 15
- Velocity based on completed points
- Finish what you start

### 7. Review and Adapt
- Retrospect on velocity patterns
- What's causing variation?
- What can we improve?

---

## Common Pitfalls

### 1. Story Point Inflation
**Problem:** Team increases estimates without increasing effort

**Why it happens:** Pressure to show velocity growth

**Fix:** Re-baseline against reference stories, emphasize velocity is not a performance metric

### 2. Partial Credit
**Problem:** Counting incomplete stories toward velocity

**Fix:** Velocity = completed & accepted points only

### 3. Ignoring Capacity
**Problem:** Committing to 30 points when 2 of 5 people are on PTO

**Fix:** Adjust commitment based on available capacity

### 4. Velocity as Performance Metric
**Problem:** Judging team/individuals by velocity

**Fix:** Velocity is planning tool, not performance review metric

---

## Resources & Further Reading

- "Agile Estimating and Planning" by Mike Cohn
- "Scrum Guide" by Ken Schwaber and Jeff Sutherland
- "Actionable Agile Metrics" by Daniel Vacanti
- "The Lean Startup" by Eric Ries (validated learning over velocity)

---

**Last Updated:** 2024-10-24
**Version:** 1.0
