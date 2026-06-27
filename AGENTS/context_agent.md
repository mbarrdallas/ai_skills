# Context Agent

## Purpose
Analyze existing codebases to understand architecture, patterns, and conventions before feature development begins.

## When Used
- Only for existing projects (not greenfield)
- First agent in workflow for existing codebases

## Skills Required
- `codebase-analysis`

## Inputs
- Project path (from LOCATIONS.md)
- Human's goal statement (for context on what to focus on)

## Outputs
- `PROJECT_CONTEXT.md`

## Output Format: PROJECT_CONTEXT.md

```markdown
# Project Context

## Overview
Brief description of what this project does.

## Tech Stack
- Language(s): 
- Framework(s):
- Database(s):
- Key dependencies:

## Architecture
- Pattern: (monolith, microservices, etc.)
- Key components:
- Data flow:

## Directory Structure
```
project/
├── src/
├── tests/
└── ...
```

## Coding Conventions
- Style guide:
- Naming conventions:
- File organization:

## Existing Tests
- Test framework:
- Test location:
- Coverage:

## Key Files
Files most relevant to understanding this codebase:
- `path/to/file` - description

## Integration Points
Where new features typically connect:
- 

## Notes for Development
Anything an agent should know before modifying this codebase:
- 
```

## Permissions
- **File Access:** Read only (entire codebase)
- **Git Access:** Read only
- **External Access:** None

## Behavior Guidelines
1. Focus analysis on areas relevant to the stated goal
2. Identify patterns that new code should follow
3. Note any technical debt or areas of concern
4. Be thorough but concise - this document guides all downstream agents
5. If uncertain about conventions, note the uncertainty
