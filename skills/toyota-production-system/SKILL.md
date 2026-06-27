---
name: toyota-production-system
description: Apply Toyota Production System (TPS) and lean principles to workflow orchestration. Use for managing work-in-progress, eliminating waste, ensuring quality, and optimizing flow. Triggers on "reduce waste", "improve flow", "bottleneck", "WIP limit", "stop the line", "root cause", "5 whys", "TPS", "lean", or when orchestrating workflows and managing task execution.
---

# Toyota Production System (TPS) for Orchestrators

Apply lean manufacturing principles to software workflow orchestration. TPS focuses on eliminating waste, ensuring quality, and optimizing flow.

## Core Philosophy

**Two Pillars of TPS:**
1. **Jidoka (自働化)** - Automation with a human touch; stop and fix problems immediately
2. **Just-in-Time (ジャストインタイム)** - Produce only what is needed, when needed, in the amount needed

**Goal:** Continuous flow of value with zero waste.

---

## Muda (無駄) - Waste Elimination

The 7 wastes, mapped to software orchestration:

### 1. Overproduction (作りすぎ)
**Traditional:** Making more than needed
**Software:** Building features not requested, over-engineering, premature optimization

**Orchestrator action:**
- Only assign tasks that trace to requirements
- Stop work that doesn't deliver value
- Question scope creep

### 2. Waiting (待ち)
**Traditional:** Idle time waiting for next step
**Software:** Blocked tasks, agents waiting for dependencies, waiting for approvals

**Orchestrator action:**
- Track blocked tasks explicitly
- Identify and resolve blockers quickly
- Parallelize independent work
- Minimize approval queues in autonomous mode

### 3. Transport (運搬)
**Traditional:** Unnecessary movement of materials
**Software:** Excessive handoffs between agents, moving data between systems unnecessarily

**Orchestrator action:**
- Minimize agent handoffs where possible
- Keep related work together
- Reduce coordination overhead

### 4. Over-processing (加工)
**Traditional:** More work than necessary
**Software:** Gold-plating, excessive documentation, premature abstraction, over-testing low-risk code

**Orchestrator action:**
- Match effort to value
- "Good enough" over perfect
- Focus testing on high-risk areas

### 5. Inventory (在庫)
**Traditional:** Excess materials waiting
**Software:** Partially done work, unmerged branches, features waiting for release

**Orchestrator action:**
- Limit work-in-progress
- Finish before starting new
- Merge completed work promptly
- Small batches over large batches

### 6. Motion (動作)
**Traditional:** Unnecessary movement of people
**Software:** Context switching, searching for information, navigating complex systems

**Orchestrator action:**
- Provide agents clear, complete context
- Keep related tasks together
- Reduce back-and-forth clarifications

### 7. Defects (不良)
**Traditional:** Rework and scrap
**Software:** Bugs, failed reviews, rework cycles

**Orchestrator action:**
- Build quality in (TDD approach)
- Don't pass defects downstream
- Fix root causes, not symptoms

---

## Just-in-Time (JIT) / Pull-Based Flow

### Principles

**Push vs Pull:**
- **Push (bad):** Assign all tasks immediately, overwhelm agents
- **Pull (good):** Agent completes task, pulls next from queue

**Orchestrator implementation:**
```
1. Maintain prioritized backlog of ready tasks
2. Only assign task when agent signals capacity
3. Don't pre-assign—let work be pulled
4. Match assignment rate to completion rate
```

### Small Batches
- Break large tasks into smaller ones
- Deliver incrementally
- Faster feedback, less waste if direction changes

### Takt Time (タクト)
The rhythm of work. In software:
- How fast do tasks need to complete to meet deadline?
- Are we ahead or behind pace?
- Adjust WIP if falling behind

---

## Jidoka (自働化) - Stop and Fix

### The Andon Cord
In Toyota factories, anyone can pull the cord to stop the line when they see a problem.

**Orchestrator implementation:**
```
When quality issue detected:
1. STOP - Don't continue producing defects
2. ALERT - Log the issue clearly
3. FIX - Address root cause, not just symptom
4. PREVENT - Add check to catch this earlier next time
```

### Don't Pass Defects Downstream
- Test Agent finds issue → Stop, don't pass to Coder
- Reviewer rejects → Stop, fix before continuing
- Never "fix it later"

### Build Quality In
Quality is not inspected in at the end—it's built in at every step:
- Test-first development (TDD)
- Reviews at each stage
- Clear acceptance criteria upfront

---

## WIP Limits (Work-in-Progress)

### Why Limit WIP?
- **Little's Law:** Lead Time = WIP / Throughput
- Lower WIP = Faster delivery
- High WIP = Context switching, longer lead times, more inventory waste

### Setting WIP Limits
```
Factors to consider:
- Number of parallel worktrees manageable
- Agent capacity
- Merge conflict risk (more parallel = more conflict)
- Dependency density

Starting point:
- 2-3 parallel tasks for tightly coupled work
- 4-5 for loosely coupled work
- Adjust based on flow metrics
```

### Enforcing WIP Limits
```
Before starting new task:
1. Count in-progress tasks
2. If at WIP limit, wait for completion
3. Only pull new work when below limit
4. Exception: blocked work doesn't count against limit (but track separately)
```

---

## 5 Whys (なぜなぜ分析)

Root cause analysis technique. Keep asking "why" until you reach the actionable root cause.

### Example
```
Problem: Task failed review 3 times

Why? → Code didn't match design
Why? → Coder misunderstood the design doc
Why? → Design doc was ambiguous about edge cases
Why? → Design review didn't include edge case scenarios
Why? → Design review checklist doesn't cover edge cases

Root cause: Incomplete design review process
Action: Add edge case section to design template
```

### Guidelines
- Usually 5 whys is enough, sometimes fewer, sometimes more
- Stop when you reach something actionable
- Avoid blame—focus on process/system
- Multiple root causes are possible (use branching)

---

## Heijunka (平準化) - Load Leveling

### Avoid Peaks and Valleys
**Problem:** Burst of work → overwhelm → waiting → burst again
**Solution:** Smooth flow, consistent pace

### Orchestrator Application
```
Instead of:
- Start all tasks Monday
- Rush to finish Friday

Do:
- Steady stream of task starts
- Consistent completion rate
- Plan for sustainable pace
```

### Mixed Workload
- Interleave different types of work
- Don't batch all tests, then all coding
- Smoother flow, faster feedback

---

## Poka-yoke (ポカヨケ) - Error Proofing

Make errors impossible or immediately obvious.

### Types
1. **Prevention:** Make the error impossible
2. **Detection:** Make the error immediately visible

### Software Examples
```
Prevention:
- Type systems catch type errors
- Required fields prevent incomplete data
- Branch protection prevents direct main commits

Detection:
- Linting catches style issues
- Tests catch regressions
- Pre-commit hooks catch secrets
```

### Orchestrator Application
- Validate task inputs before assigning
- Check dependencies are met before starting
- Verify outputs before marking complete
- Automated checks over manual review where possible

---

## Genchi Genbutsu (現地現物) - Go and See

"Go to the actual place and see the actual thing."

### Don't Just Trust Reports
- Metrics can hide problems
- Summaries lose detail
- Actual observation reveals truth

### Orchestrator Application
```
Instead of only checking status:
- Look at actual code produced
- Read actual test output
- Examine actual error messages

When things seem stuck:
- Don't just retry
- Investigate what's actually happening
- Observe the actual work, not just the status
```

---

## Flow Metrics (General Guidance)

Measure to identify bottlenecks and waste. Specific metrics depend on workflow.

### Key Concepts

**Lead Time**
- Time from request to delivery
- Includes all waiting time
- Customer perspective

**Cycle Time**
- Time actually working on item
- Excludes waiting
- Process efficiency

**Throughput**
- Items completed per time period
- Measures capacity
- Track trends, not absolutes

**WIP**
- Items currently in progress
- Leading indicator
- Lower is usually better

### Using Metrics
```
High lead time + low cycle time = Too much waiting (waste #2)
High WIP + low throughput = Bottleneck exists
Throughput dropping = Investigate cause
Cycle time increasing = Tasks too large or unclear
```

### Caution
- Metrics inform, don't dictate
- Optimize for flow, not individual metrics
- Context matters—don't compare across different work types

---

## Applying TPS as Orchestrator

### Before Starting Work
- [ ] Is this work actually needed? (avoid overproduction)
- [ ] Are dependencies ready? (avoid waiting)
- [ ] Is there WIP capacity? (enforce limits)
- [ ] Are inputs valid? (poka-yoke)

### During Execution
- [ ] Is work flowing or stuck? (genchi genbutsu)
- [ ] Any quality issues? Stop and fix (jidoka)
- [ ] Anyone waiting? (remove blockers)
- [ ] At WIP limit? (don't start new)

### After Completion
- [ ] Merge promptly (avoid inventory)
- [ ] What waste occurred? (muda)
- [ ] What went wrong? 5 whys on failures
- [ ] What can we improve? (kaizen)

### Continuous Improvement (Kaizen 改善)
TPS is not a one-time implementation—it's continuous improvement:
- Small, incremental improvements
- Everyone identifies waste
- Every failure is a learning opportunity
- Process evolves over time
