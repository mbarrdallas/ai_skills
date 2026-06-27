---
name: lesson-capture
description: Document lessons learned from mistakes, issues, and discoveries to prevent recurrence and improve processes. Use when something goes wrong, when discovering a better approach, when completing a project retrospective, or any time there's valuable learning to preserve. Triggers on "lesson learned", "what went wrong", "how to prevent", "retrospective", "post-mortem", or when an issue reveals something worth remembering.
---

# Lesson Capture

Systematically document lessons learned to build institutional knowledge and prevent repeated mistakes. This skill helps turn problems into improvements.

## Why Capture Lessons

- **Prevent recurrence:** Same mistake shouldn't happen twice
- **Build knowledge:** Individual learning becomes team knowledge
- **Improve processes:** Patterns reveal systemic issues
- **Onboard faster:** New team members learn from history
- **Enable iteration:** Can't improve what you don't measure

## When to Capture Lessons

### Always Capture
- Production incidents
- Significant bugs (especially those that slipped through)
- Missed requirements discovered late
- Surprising behavior that wasn't obvious
- Time sinks (spent way longer than expected)
- Near misses (almost went wrong)

### Consider Capturing
- Better approaches discovered mid-project
- Useful patterns worth reusing
- Tool/library gotchas
- Integration surprises
- Performance discoveries

### Immediately After
- Don't wait - capture while fresh
- Include context that seems obvious now (it won't be later)
- Link to relevant tickets/PRs/commits

## Lesson Structure

### Essential Elements

```markdown
# Lesson: [Brief, Descriptive Title]

## Date
[When this was captured]

## Context
[Where did this happen? What were you trying to do?]

## What Happened
[Factual description of the issue or discovery]

## Root Cause
[Why did this happen? Dig past symptoms to causes]

## Impact
[What was the effect? Time lost, bugs shipped, etc.]

## Resolution
[How was it fixed/addressed?]

## Prevention
[How do we prevent this in the future?]

## Tags
[Categories for finding this later]
```

### Template

```markdown
# Lesson: [Title]

## Date
YYYY-MM-DD

## Context
- **Project/Feature:** [name]
- **Phase:** [requirements | design | implementation | testing | production]
- **Area:** [component or system affected]

## What Happened
[Describe what occurred. Be specific. Include timeline if relevant.]

## Root Cause Analysis

### Surface Cause
[The immediate trigger]

### Contributing Factors
- [Factor 1]
- [Factor 2]

### Root Cause
[The underlying reason this was possible]

## Impact
- **Severity:** Critical | High | Medium | Low
- **Time Lost:** [estimate]
- **Users Affected:** [number or scope]
- **Other Impact:** [reputation, data, etc.]

## Resolution
[What was done to fix it]

## Prevention

### Immediate Actions
- [ ] [Action 1]
- [ ] [Action 2]

### Process Changes
- [Change to prevent recurrence]

### Automation Opportunities
- [Tests, checks, or tools to add]

## Related
- [Links to tickets, PRs, docs]

## Tags
#[tag1] #[tag2] #[tag3]
```

## Root Cause Analysis

### The 5 Whys

Keep asking "why" until you reach the root:

```
Problem: Production database crashed

Why? → Disk was full
Why? → Log files grew too large
Why? → Log rotation wasn't configured
Why? → No standard for log configuration
Why? → No checklist for production setup

Root cause: Missing production deployment checklist
Fix: Create and require checklist for all deployments
```

### Categories of Root Causes

**Process Issues:**
- Missing or unclear process
- Process not followed
- Wrong process for situation

**Knowledge Issues:**
- Didn't know about X
- Misunderstood how Y works
- Assumption was wrong

**Tool Issues:**
- Tool limitation
- Tool misconfiguration
- Missing tool/automation

**Communication Issues:**
- Requirement miscommunicated
- Change not propagated
- Assumption not validated

**Design Issues:**
- Design didn't account for X
- Edge case not considered
- Complexity too high

## Writing Good Lessons

### Be Specific

```markdown
❌ "The API broke"
✅ "The /users endpoint returned 500 errors when user.profile was null,
   which happened for users created before profile migration"
```

### Focus on Systems, Not Blame

```markdown
❌ "John forgot to add the null check"
✅ "No validation exists for null profiles in the user endpoint.
   This wasn't caught because test data always has profiles."
```

### Include Context

```markdown
❌ "Always check for null"
✅ "Users created before 2024-01-01 may have null profiles due to
   the profile migration (JIRA-456). Any code accessing user.profile
   should handle this case until full migration is complete."
```

### Make Prevention Actionable

```markdown
❌ "Be more careful"
✅ "Add required null-check test case to user endpoint test suite.
   Add profile null-check to code review checklist."
```

## Lesson Categories

### By Type
- **Bug:** Defects in code
- **Incident:** Production issues
- **Process:** Workflow problems
- **Design:** Architectural issues
- **Tool:** Tooling problems
- **Integration:** Third-party issues

### By Area
- **Frontend**
- **Backend**
- **Database**
- **Infrastructure**
- **Security**
- **Performance**

### By Phase
- **Requirements**
- **Design**
- **Implementation**
- **Testing**
- **Deployment**
- **Production**

## Reviewing Lessons

### Individual Review
- After each project/sprint, scan recent lessons
- Look for patterns in your work
- Identify skills to develop

### Team Review
- Periodic review of accumulated lessons
- Identify systemic issues
- Update processes based on patterns
- Share knowledge across team

### Pattern Recognition

Ask:
- Is this the first time or a pattern?
- Do multiple lessons point to same root cause?
- What process would have prevented multiple issues?

## Integration with Workflow

### During Development
- When something takes longer than expected, note why
- When you discover a gotcha, document it
- When tests catch something, note what and why

### After Issues
- Post-incident review → lesson capture
- Bug found in production → analyze how it escaped
- Requirement missed → trace back to where/why

### Project Completion
- What went well (capture to repeat)
- What didn't (capture to prevent)
- What surprised us (capture for next time)

## Example Lesson

```markdown
# Lesson: OAuth Token Refresh Race Condition

## Date
2024-01-15

## Context
- **Project:** User Authentication System
- **Phase:** Production
- **Area:** Auth service, token management

## What Happened
Users reported intermittent logouts during active sessions. 
Investigation revealed a race condition in token refresh:
1. Token expiring soon, refresh triggered
2. Second request arrives before refresh completes
3. Second request also triggers refresh
4. Both requests get new tokens
5. One token invalidates the other
6. User appears logged out

## Root Cause Analysis

### Surface Cause
Two concurrent requests both refreshing the same token

### Contributing Factors
- No mutex/lock on token refresh
- Refresh window (5 min before expiry) was too long
- High-traffic pages made multiple API calls simultaneously

### Root Cause
Token refresh logic assumed single-threaded access,
but browser can make parallel requests.

## Impact
- **Severity:** Medium
- **Time Lost:** 3 days debugging
- **Users Affected:** ~5% of active users experiencing random logouts

## Resolution
1. Added refresh-in-progress flag with timestamp
2. Concurrent requests wait for in-progress refresh
3. Reduced refresh window from 5 min to 1 min
4. Added jitter to prevent thundering herd

## Prevention

### Immediate Actions
- [x] Deploy fix to production
- [x] Add monitoring for refresh race conditions
- [x] Update token refresh documentation

### Process Changes
- Auth changes require concurrent request testing
- Add race condition scenarios to test plan template

### Automation Opportunities
- Add load test that simulates concurrent requests with expiring token
- Add alert for multiple refresh requests within 1 second

## Related
- PR #234: Fix token refresh race condition
- JIRA-789: Investigate random logouts
- Monitoring dashboard: auth-service

## Tags
#auth #race-condition #production-incident #token-management
```

## Lesson File Organization

```
lessons/
├── 2024-01-15-oauth-token-race-condition.md
├── 2024-01-10-missing-null-check-user-profile.md
├── 2024-01-05-database-migration-ordering.md
└── INDEX.md  # Optional: categorized list of all lessons
```

### Naming Convention
`YYYY-MM-DD-brief-description.md`

Keep names:
- Dated for chronology
- Descriptive enough to identify without opening
- Lowercase with hyphens
