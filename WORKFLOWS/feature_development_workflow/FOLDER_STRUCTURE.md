# Workflow Folder Structure

## Workflow Definition Structure

The workflow definition lives in:
```
~/WORKSPACE/REPOS/ai_skills/WORKFLOWS/feature_development_workflow/
├── WORKFLOW.md                     # Main workflow definition
├── BACKLOG.md                      # Workflow-specific future work
├── FOLDER_STRUCTURE.md             # This file
├── CONFIG_TEMPLATE.md              # Configuration template
├── LOCATIONS_TEMPLATE.md           # Locations template
├── agents/                         # Symlinks to agents used by this workflow
│   ├── context_agent.md → ../../../AGENTS/context_agent.md
│   ├── requirements_agent.md → ../../../AGENTS/requirements_agent.md
│   ├── design_agent.md → ../../../AGENTS/design_agent.md
│   ├── planning_agent.md → ../../../AGENTS/planning_agent.md
│   ├── test_agent.md → ../../../AGENTS/test_agent.md
│   ├── coder_agent.md → ../../../AGENTS/coder_agent.md
│   ├── reviewer_agent.md → ../../../AGENTS/reviewer_agent.md
│   ├── documentation_agent.md → ../../../AGENTS/documentation_agent.md
│   └── orchestrator_agent.md → ../PRIVATE/AGENTS/orchestrator_agent.md
├── templates/                      # Document templates
│   ├── REQUIREMENTS_TEMPLATE.md
│   └── LESSON_TEMPLATE.md
└── PRIVATE/                        # Workflow-specific (not shared)
    ├── AGENTS/
    │   └── orchestrator_agent.md   # Workflow-specific orchestrator
    └── SKILLS/                     # Workflow-specific skills (if any)
```

## Active Workflow Location

All workflow outputs are stored in:
```
~/WORKSPACE/active_workflows/<workflow_name>/
```

Code is written to the actual repository specified in LOCATIONS.md.

## Complete Structure

```
~/WORKSPACE/active_workflows/
└── <workflow_name>/                    # e.g., user-authentication/
    │
    ├── LOCATIONS.md                    # Paths to code repo, skills, etc.
    ├── WORKFLOW_CONFIG.md              # Mode, settings, budget
    │
    ├── PROJECT_CONTEXT.md              # (Existing projects) Codebase analysis
    ├── REQUIREMENTS.md                 # Structured requirements
    │
    ├── design/                         # Technical design documents
    │   ├── ARCHITECTURE.md             # System architecture
    │   ├── DATA_MODEL.md               # Database/data structures
    │   ├── API_SPEC.md                 # API definitions
    │   ├── IMPLEMENTATION_PLAN.md      # Technical approach
    │   └── FILE_STRUCTURE.md           # Proposed file layout
    │
    ├── planning/                       # Task planning
    │   └── TASK_PLAN.md                # Tasks with dependencies
    │
    ├── orchestrator/                   # Workflow state and logs
    │   ├── ORCHESTRATOR_STATE.md       # Current state snapshot
    │   ├── IMPLEMENTATION_LOG.md       # Chronological event log
    │   ├── ERRORS.md                   # Error tracking
    │   ├── BUDGET.md                   # Token/cost tracking
    │   └── METRICS.md                  # Performance metrics
    │
    ├── reviews/                        # Code review documents
    │   ├── task_T1_review.md
    │   ├── task_T2_review.md
    │   └── ...
    │
    ├── docs/                           # Generated documentation
    │   ├── README.md                   # Feature overview
    │   ├── API.md                      # API documentation
    │   ├── DEVELOPER_GUIDE.md          # Technical guide
    │   └── CHANGELOG.md                # What changed
    │
    ├── lessons/                        # Lessons learned
    │   └── *.md                        # Individual lesson files
    │
    ├── SIGN_OFF.md                     # Final approval package
    └── COMPLETION_REPORT.md            # Workflow summary
```

## Code Repository Structure

Code is written to the repository specified in `LOCATIONS.md`:

```
<code_repo>/                            # Actual project repository
├── src/                                # Implementation code
│   └── <feature>/                      # Feature-specific code
├── tests/                              # Test files
│   └── <feature>/                      # Feature-specific tests
└── ...                                 # Existing project structure
```

## Worktree Structure

For parallel task execution:

```
<worktrees_dir>/                        # From LOCATIONS.md
└── <workflow_name>/                    # Workflow-specific worktrees
    ├── task-T1-<name>/                 # Worktree for task T1
    │   ├── src/
    │   ├── tests/
    │   └── ...
    ├── task-T2-<name>/                 # Worktree for task T2
    └── ...
```

## File Purposes

### Root Level
| File | Purpose | Created By |
|------|---------|------------|
| LOCATIONS.md | Path configuration | Workflow init |
| WORKFLOW_CONFIG.md | Mode and settings | Workflow init |
| PROJECT_CONTEXT.md | Codebase analysis | Context Agent |
| REQUIREMENTS.md | Structured requirements | Requirements Agent |
| SIGN_OFF.md | Approval package | Orchestrator |
| COMPLETION_REPORT.md | Final summary | Orchestrator |

### design/
| File | Purpose | Created By |
|------|---------|------------|
| ARCHITECTURE.md | System design | Design Agent |
| DATA_MODEL.md | Data structures | Design Agent |
| API_SPEC.md | API definitions | Design Agent |
| IMPLEMENTATION_PLAN.md | Technical approach | Design Agent |
| FILE_STRUCTURE.md | File layout | Design Agent |

### planning/
| File | Purpose | Created By |
|------|---------|------------|
| TASK_PLAN.md | Task breakdown | Planning Agent |

### orchestrator/
| File | Purpose | Created By |
|------|---------|------------|
| ORCHESTRATOR_STATE.md | Current state | Orchestrator |
| IMPLEMENTATION_LOG.md | Event history | Orchestrator |
| ERRORS.md | Error tracking | Orchestrator |
| BUDGET.md | Resource tracking | Orchestrator |
| METRICS.md | Performance data | Orchestrator |

### reviews/
| File | Purpose | Created By |
|------|---------|------------|
| task_*_review.md | Code review results | Reviewer Agent |

### docs/
| File | Purpose | Created By |
|------|---------|------------|
| README.md | Feature overview | Documentation Agent |
| API.md | API reference | Documentation Agent |
| DEVELOPER_GUIDE.md | Technical guide | Documentation Agent |
| CHANGELOG.md | Change history | Documentation Agent |

### lessons/
| File | Purpose | Created By |
|------|---------|------------|
| *.md | Individual lessons | Any agent via lesson-capture |

## Initialization

When a workflow starts, the Orchestrator creates:

1. Workflow directory under `~/WORKSPACE/active_workflows/`
2. LOCATIONS.md with configured paths
3. WORKFLOW_CONFIG.md with settings
4. Empty subdirectories: design/, planning/, orchestrator/, reviews/, docs/, lessons/

## Cleanup

After workflow completion:
- Worktrees are removed after successful merge
- Workflow directory remains for reference
- Archive old workflows periodically if needed
