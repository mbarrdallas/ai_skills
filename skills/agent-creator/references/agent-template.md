# Agent Template

Copy this template when creating a new agent definition.

---

# [Agent Name] Agent

## Purpose
[One or two sentences: what transformation does this agent perform? What value does it add?]

## When Used
- [Condition 1 that triggers this agent]
- [Condition 2]
- [Prerequisites that must be met]

## Skills Required
- `skill-name` - [why needed]

## Inputs
- [Input 1] (from [source])
- [Input 2]
- `LOCATIONS.md` for paths

## Outputs
- [Output 1] → [destination]
- [Output 2]

## Output Format: [FILENAME.md]

```markdown
# [Document Title]

## Section 1
[What goes here]

## Section 2
[What goes here]
```

## Permissions
- **File Access:** [Read/Write to specific paths]
- **Git Access:** [None / Read only / Specific operations]
- **External Access:** [None / List specific tools/APIs]

## Behavior Guidelines
1. [How to handle the primary task]
2. [Quality standards to maintain]
3. [How to handle ambiguity/uncertainty]
4. [What to do when errors occur]
5. [What the agent should NEVER do]
