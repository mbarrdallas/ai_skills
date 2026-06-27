---
name: agent-creator
description: Create reusable agent definition files that specify an agent's purpose, inputs, outputs, skills, permissions, and behavior. Use when users want to create a new agent, define agent roles for workflows, design multi-agent systems, or standardize agent specifications. Trigger on phrases like "create an agent", "define an agent", "agent definition", "agent spec", "new agent for", or when discussing agent responsibilities and handoffs.
---

# Agent Creator

A skill for creating well-structured, reusable agent definition files.

## Understanding Agents vs Skills

Before creating an agent, understand the distinction:

| Aspect | Agent | Skill |
|--------|-------|-------|
| **What it is** | Autonomous entity that performs tasks | Capability/knowledge package |
| **Behavior** | Makes decisions, orchestrates work | Provides instructions/tools |
| **State** | Can track progress, manage context | Stateless reference material |
| **Uses** | Skills, tools, other agents' outputs | Nothing - it IS what's used |
| **Analogy** | A worker with a job description | A manual or toolbox |

An agent USES skills. A skill INFORMS an agent.

## When to Create an Agent

Create an agent when you need:
- An autonomous entity to perform a specific role
- Clear boundaries between responsibilities in a workflow  
- Defined handoffs between processing stages
- Explicit permissions and constraints on behavior
- Reusable role definitions across multiple workflows

Do NOT create an agent when:
- A skill would suffice (just need instructions/knowledge)
- The task is a one-off, not a reusable role
- There's no clear input→output transformation

## Agent Design Principles

### 1. Single Responsibility
Each agent should do ONE thing well. If you're listing multiple unrelated responsibilities, split into multiple agents.

**Bad:** "Handles requirements, design, and testing"
**Good:** "Transforms requirements into technical design documents"

### 2. Workflow Independence
Agents should be reusable across different workflows. Avoid hardcoding:
- Specific file paths (use LOCATIONS.md)
- Workflow-specific logic (that belongs in orchestrators)
- Other agent names (reference by role, not name)

**Exception:** Orchestrator agents CAN be workflow-specific.

### 3. Clear Boundaries
Define exactly:
- What inputs the agent expects
- What outputs the agent produces
- What the agent is NOT responsible for

### 4. Least Privilege Permissions
Grant only the minimum permissions needed:
- File access: Read-only where possible, write only to specific locations
- Git access: Most agents need none; only orchestrators need write
- External access: Explicitly list any external tools/APIs needed

### 5. Explicit Behavior Guidelines
Tell the agent HOW to behave, not just WHAT to do:
- Decision-making principles
- Error handling approach
- Quality standards
- Communication style

## Agent Definition Structure

Every agent definition file follows this structure:

```markdown
# [Agent Name]

## Purpose
One or two sentences explaining what this agent does and why it exists.
Focus on the transformation: what goes in, what comes out, what value is added.

## When Used
- Bullet points describing when this agent is invoked
- What triggers its use in a workflow
- Prerequisites that must be met

## Skills Required
- `skill-name-1` - brief note on why needed
- `skill-name-2`

## Inputs
- Input 1 (from where/whom)
- Input 2
- Reference to LOCATIONS.md for paths

## Outputs
- Output 1 → where it goes
- Output 2

## Output Format: [filename]

\```markdown
# Template showing exact structure of output

## Section 1
What goes here and why

## Section 2
...
\```

(Include multiple Output Format sections if agent produces multiple files)

## Permissions
- **File Access:** [Read/Write permissions with specific paths]
- **Git Access:** [None / Read only / Specific operations]
- **External Access:** [None / Specific tools or APIs]

## Behavior Guidelines
1. Numbered guidelines for how the agent should behave
2. Decision-making principles
3. Quality standards
4. Error handling approach
5. What to do when uncertain
```

## Creating an Agent: Step by Step

### Step 1: Define the Role

Ask yourself:
- What transformation does this agent perform?
- What would this agent's job title be if it were human?
- What's the ONE thing this agent is responsible for?

Write a one-sentence purpose statement.

### Step 2: Map Inputs and Outputs

Draw the data flow:
```
[Input A] ──┐
            ├──→ [AGENT] ──→ [Output X]
[Input B] ──┘            ──→ [Output Y]
```

Be specific about:
- File formats (markdown, JSON, code)
- Where inputs come from (other agents, human, files)
- Where outputs go (files, other agents, human review)

### Step 3: Define Output Templates

For each output, create an exact template showing:
- Document structure
- Required sections
- Example content
- Format requirements

This is critical - downstream agents depend on consistent output formats.

### Step 4: Determine Skills Needed

List skills the agent needs to do its job:
- What knowledge domains are required?
- What tools/capabilities are needed?
- What conventions must be followed?

Map each skill to why it's needed.

### Step 5: Set Permissions (Least Privilege)

For each permission type, ask:
- Does the agent NEED this? Or just WANT it?
- What's the minimum access that still works?
- What damage could occur if this permission is abused?

Default to restrictive, expand only when justified.

### Step 6: Write Behavior Guidelines

Consider:
- How should the agent handle ambiguity?
- What quality standards apply?
- How should errors be handled?
- What should the agent NEVER do?
- How should it communicate with humans?

### Step 7: Validate Independence

Check that the agent:
- [ ] Has no hardcoded paths (uses LOCATIONS.md)
- [ ] Doesn't reference specific workflow names
- [ ] Could be used in a different workflow
- [ ] Doesn't duplicate another agent's responsibility

## Common Agent Patterns

### Analyzer Agent
Reads input, produces structured analysis.
- Inputs: Raw material (code, docs, data)
- Outputs: Analysis document with findings
- Permissions: Read-only
- Example: Context Agent, Requirements Agent

### Transformer Agent  
Converts one format/structure to another.
- Inputs: Source format
- Outputs: Target format
- Permissions: Read source, write target location only
- Example: Design Agent, Documentation Agent

### Validator Agent
Checks work against criteria, approves or rejects.
- Inputs: Work product + criteria
- Outputs: Validation report with pass/fail
- Permissions: Read-only (writes only to review location)
- Example: Reviewer Agent

### Creator Agent
Produces new artifacts from specifications.
- Inputs: Specifications, requirements
- Outputs: New files/code/content
- Permissions: Write to designated output location
- Example: Coder Agent, Test Agent

### Orchestrator Agent
Coordinates other agents, manages workflow state.
- Inputs: Plan, agent outputs
- Outputs: State tracking, coordination signals
- Permissions: Broader access (workflow-specific)
- Example: Orchestrator Agent
- Note: These CAN be workflow-specific

## Anti-Patterns to Avoid

### The Kitchen Sink Agent
**Problem:** Agent does too many unrelated things.
**Fix:** Split into focused agents with single responsibilities.

### The Hardcoded Agent
**Problem:** Paths, names, workflow logic baked in.
**Fix:** Use LOCATIONS.md, make workflow-independent.

### The God Agent
**Problem:** Agent has permissions to everything.
**Fix:** Apply least privilege, justify each permission.

### The Vague Agent
**Problem:** Unclear what agent does or produces.
**Fix:** Define explicit I/O formats and templates.

### The Dependent Agent
**Problem:** Agent only works with specific other agents.
**Fix:** Define interfaces, not implementations.

## Example: Creating a Review Agent

Let's walk through creating a code review agent:

**Step 1: Define Role**
"Validates code against design requirements, coding standards, and test coverage."

**Step 2: Map I/O**
```
[Code files] ────┐
[Test files] ────┼──→ [Reviewer] ──→ [Review Report]
[Design docs] ───┤                ──→ [Pass/Fail Signal]
[Task spec] ─────┘
```

**Step 3: Output Template**
```markdown
# Code Review: [Task ID]

## Summary
- **Status:** Pass / Fail / Pass with Comments
- **Files Reviewed:** X
- **Issues Found:** Y

## Design Compliance
- [ ] Implements requirements from design
- [ ] Follows architecture patterns
...

## Issues
### Issue 1: [Title]
- **Severity:** High/Medium/Low
- **File:** path/to/file
- **Line:** XX
- **Description:** What's wrong
- **Suggestion:** How to fix
```

**Step 4: Skills**
- `coding-conventions` - to check style
- `codebase-analysis` - to understand context

**Step 5: Permissions**
- File Access: Read all, write to `reviews/` only
- Git Access: Read only
- External Access: Linting tools

**Step 6: Behavior Guidelines**
1. Review objectively against defined criteria
2. Provide actionable feedback, not just criticism
3. Distinguish blocking issues from suggestions
4. If uncertain about a convention, check the standard
5. Be thorough but not pedantic

## Validating Your Agent Definition

Before finalizing, verify:

- [ ] Purpose is one clear sentence
- [ ] Single responsibility (not doing too much)
- [ ] All inputs explicitly listed
- [ ] All outputs have format templates
- [ ] Skills mapped with justification
- [ ] Permissions follow least privilege
- [ ] Behavior guidelines are actionable
- [ ] No hardcoded paths or workflow specifics
- [ ] Could be reused in different workflow

## Next Steps After Creating an Agent

1. **Review with stakeholders** - Does this role make sense?
2. **Test in isolation** - Can the agent produce valid output given sample input?
3. **Integrate into workflow** - Create symlinks, update orchestrator
4. **Iterate** - Refine based on actual usage
5. **Document lessons** - Capture what works and what doesn't
