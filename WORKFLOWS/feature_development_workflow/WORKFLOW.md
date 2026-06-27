# Feature Development Workflow

## Overview

A comprehensive workflow for developing software features from goal to implementation. Supports both greenfield projects and existing codebases, with parallel task execution, test-driven development, and quality gates.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FEATURE DEVELOPMENT WORKFLOW                         │
└─────────────────────────────────────────────────────────────────────────────┘

Human Goal Statement
        │
        ▼
┌───────────────────┐
│  Scout (Haiku)    │◄──── (Optional, if use_scout: true)
│  Fast recon       │
└────────┬──────────┘
         │ Scout findings
         ▼
┌───────────────────┐
│  Context Agent    │◄──── (Existing projects only)
│  Deep analysis    │
└────────┬──────────┘
         │ PROJECT_CONTEXT.md
         ▼
┌───────────────────┐
│ Requirements Agent│
│ Clarify & document│
└────────┬──────────┘
         │ REQUIREMENTS.md
         ▼
    ◆ CHECKPOINT ◆ ◄──── Human approves requirements (interactive mode)
         │
         ▼
┌───────────────────┐
│   Design Agent    │
│ Architecture/APIs │
└────────┬──────────┘
         │ design/ folder
         ▼
    ◆ CHECKPOINT ◆ ◄──── Human approves design (interactive mode)
         │
         ▼
┌───────────────────┐
│  Planning Agent   │
│ Task breakdown    │
└────────┬──────────┘
         │ TASK_PLAN.md
         ▼
┌───────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR AGENT                         │
│  Manages parallel execution, worktrees, state, budget         │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              PER-TASK PIPELINE (parallel)               │ │
│  │                                                         │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        │ │
│  │  │ Test Agent │─▶│Coder Agent │─▶│Reviewer    │        │ │
│  │  │Write tests │  │Implement   │  │Agent       │        │ │
│  │  └────────────┘  └────────────┘  └─────┬──────┘        │ │
│  │                                        │               │ │
│  │                         ┌──────────────┴───────────┐   │ │
│  │                         ▼                          ▼   │ │
│  │                      PASS                        FAIL  │ │
│  │                        │                          │    │ │
│  │                        ▼                          │    │ │
│  │                   Task Complete            ◄──────┘    │ │
│  │                                        (retry loop     │ │
│  │                                         max 3x)        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
└───────────────────────────────────────────────────────────────┘
         │
         │ All tasks complete
         ▼
┌───────────────────┐
│ Documentation     │
│ Agent             │
└────────┬──────────┘
         │ docs/ folder
         ▼
┌───────────────────┐
│ SIGN_OFF.md       │
│ COMPLETION_REPORT │
└────────┬──────────┘
         │
         ▼
    ◆ CHECKPOINT ◆ ◄──── Human sign-off
         │
         ▼
┌───────────────────┐
│ Orchestrator      │
│ Merge to develop  │
└────────┬──────────┘
         │
         ▼
    Human merges to main (manual)
```

## Modes

### Interactive Mode (Default)
- Pauses at checkpoints for human approval
- Human reviews requirements, design, and final output
- Recommended for important features or learning

### Autonomous Mode
- Skips all checkpoints
- Runs end-to-end without human intervention
- Human reviews COMPLETION_REPORT.md at the end
- Triggered by saying "run autonomously" or similar

## Phases

### Phase 1: Context Analysis (Existing Projects Only)
**Agent:** Context Agent
**Trigger:** Project path provided for existing codebase
**Input:** Project path from LOCATIONS.md
**Output:** `PROJECT_CONTEXT.md`
**Purpose:** Understand existing architecture, patterns, conventions

### Phase 2: Requirements Gathering
**Agent:** Requirements Agent
**Input:** Human goal statement, PROJECT_CONTEXT.md (if exists)
**Output:** `REQUIREMENTS.md`
**Checkpoint:** Human approval (interactive mode)
**Purpose:** Transform goal into structured, comprehensive requirements

### Phase 3: Design
**Agent:** Design Agent
**Input:** REQUIREMENTS.md, PROJECT_CONTEXT.md (if exists)
**Output:** `design/` folder
  - ARCHITECTURE.md
  - DATA_MODEL.md
  - API_SPEC.md
  - IMPLEMENTATION_PLAN.md
  - FILE_STRUCTURE.md
**Checkpoint:** Human approval (interactive mode)
**Purpose:** Create technical blueprint for implementation

### Phase 4: Planning
**Agent:** Planning Agent
**Input:** REQUIREMENTS.md, design/ folder
**Output:** `planning/TASK_PLAN.md`
**Purpose:** Break design into implementable tasks with dependencies

### Phase 5: Implementation
**Agent:** Orchestrator Agent (coordinates)
**Sub-agents:** Test Agent → Coder Agent → Reviewer Agent
**Input:** TASK_PLAN.md
**Output:** 
  - `src/` - implementation code
  - `tests/` - unit tests
  - `reviews/` - review documents
  - `orchestrator/` - state and logs
**Purpose:** Execute tasks in parallel, TDD approach, quality validation

### Phase 6: Documentation
**Agent:** Documentation Agent
**Input:** All artifacts (code, design, requirements)
**Output:** `docs/` folder
  - README.md
  - API.md
  - DEVELOPER_GUIDE.md
  - CHANGELOG.md
**Purpose:** Generate comprehensive documentation

### Phase 7: Sign-off
**Agent:** Orchestrator Agent
**Output:** 
  - `SIGN_OFF.md` - approval package
  - `COMPLETION_REPORT.md` - summary
**Checkpoint:** Human approval
**Purpose:** Final review and approval

### Phase 8: Merge
**Agent:** Orchestrator Agent
**Action:** Merge feature branch to development
**Note:** Human merges to main manually

## Agents

| Agent | Role | Skills |
|-------|------|--------|
| Context Agent | Analyze existing codebase | codebase-analysis |
| Requirements Agent | Gather and document requirements | scientific-method |
| Design Agent | Create technical design | api-design, codebase-analysis, scientific-method |
| Planning Agent | Break down into tasks | task-breakdown |
| Orchestrator Agent | Coordinate execution | git-workflow, task-breakdown |
| Test Agent | Write unit tests (TDD) | coding-conventions |
| Coder Agent | Implement code | coding-conventions, git-workflow |
| Reviewer Agent | Validate code quality | coding-conventions, codebase-analysis |
| Documentation Agent | Generate documentation | doc-creator |

## Skills Required

| Skill | Used By | Purpose |
|-------|---------|---------|
| codebase-analysis | Context, Design, Reviewer | Understand existing code |
| scientific-method | Requirements, Design | Systematic analysis |
| api-design | Design | Design APIs and interfaces |
| task-breakdown | Planning, Orchestrator | Decompose work |
| coding-conventions | Test, Coder, Reviewer | Code standards |
| git-workflow | Orchestrator, Coder | Version control |
| doc-creator | Documentation | Generate docs |
| lesson-capture | All (via Orchestrator) | Learn from mistakes |
| agent-creator | Meta (workflow design) | Define agents |

## File Structure

See `FOLDER_STRUCTURE.md` for the complete workspace structure.

## Configuration

See `CONFIG_TEMPLATE.md` for workflow configuration options.

## Locations

See `LOCATIONS_TEMPLATE.md` for path configuration.

## Getting Started

1. **State your goal:** Tell the agent what you want to build
2. **Specify project type:** Greenfield or existing codebase
3. **Choose mode:** Interactive (default) or autonomous
4. **Provide paths:** Code repository location, etc.

Example:
```
"I want to build a user authentication system with JWT tokens. 
The code should go in my existing project at ~/projects/myapp.
Run interactively so I can review the design."
```

## Error Handling

- Agent failures: Retry up to 3 times, then escalate
- Blocked tasks: Continue other work, alert human
- Budget constraints: Prioritize quality over new code
- Merge conflicts: Attempt auto-resolve, escalate if complex

## Lessons Learned

The workflow captures lessons in `lessons/*.md` for continuous improvement.
Use the `lesson-capture` skill to document what worked and what didn't.
