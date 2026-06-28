# Feature Development Workflow Agents

Agents used in this workflow and their roles.

## Workflow Sequence

```
Phase 1: Context     → context-agent (existing projects only)
Phase 2: Requirements → requirements-agent
Phase 3: Design      → design-agent
Phase 4: Planning    → planning-agent
Phase 5: Implementation → Per task: test-agent → coder-agent → reviewer-agent
Phase 6: Documentation → documentation-agent
Phase 7: Sign-off    → orchestrator reviews
```

## Agent Roles

### Orchestrator (Private)
**Location:** `PRIVATE/AGENTS/orchestrator_agent.md`
**Model:** Opus
**Role:** Coordinate entire workflow, manage parallel tasks, track state and budget.
**Spawns:** All other agents

### Context Agent
**Model:** Sonnet
**Role:** Analyze existing codebase before modifications.
**Inputs:** Code repository path
**Outputs:** `PROJECT_CONTEXT.md`

### Requirements Agent
**Model:** Sonnet
**Role:** Gather requirements from human, ask clarifying questions.
**Inputs:** GOAL.md
**Outputs:** `REQUIREMENTS.md`

### Design Agent
**Model:** Opus
**Role:** Create technical design documents.
**Inputs:** REQUIREMENTS.md, PROJECT_CONTEXT.md (if exists)
**Outputs:** `design/ARCHITECTURE.md`, `design/DATA_MODEL.md`, `design/API_SPEC.md`, `design/FILE_STRUCTURE.md`, `design/IMPLEMENTATION_PLAN.md`

### Planning Agent
**Model:** Opus
**Role:** Break design into implementable tasks.
**Inputs:** design/ folder
**Outputs:** `planning/TASK_PLAN.md`

### Test Agent
**Model:** Sonnet
**Role:** Write tests before implementation (TDD).
**Inputs:** Task from TASK_PLAN.md, design docs
**Outputs:** Test files in code repo

### Coder Agent
**Model:** Sonnet
**Role:** Implement code that passes tests.
**Inputs:** Task, tests, design docs
**Outputs:** Implementation files in code repo

### Reviewer Agent
**Model:** Opus
**Role:** Review code quality, verify acceptance criteria.
**Inputs:** Implementation, tests, task acceptance criteria
**Outputs:** `reviews/{task}-review.md`
**Returns:** DONE, CHANGES_REQUESTED, or BLOCKED

### Documentation Agent
**Model:** Sonnet
**Role:** Write user-facing documentation.
**Inputs:** Completed implementation, design docs
**Outputs:** `docs/` folder, README updates

## TDD Cycle

For each implementation task:
```
1. test-agent writes tests (tests fail)
2. coder-agent implements (tests pass)
3. reviewer-agent reviews
   - DONE → task complete
   - CHANGES_REQUESTED → back to coder-agent (max 3 iterations)
   - BLOCKED → escalate to orchestrator
```

## Parallel Execution

Tasks with no dependencies can run in parallel using git worktrees:
- Each parallel task gets its own worktree
- Orchestrator manages worktree lifecycle
- Merge to feature branch after review passes

## Skills Used

| Agent | Skills |
|-------|--------|
| orchestrator | git-workflow, task-breakdown, lesson-capture, toyota-production-system |
| context-agent | codebase-analysis |
| requirements-agent | scientific-method |
| design-agent | api-design, codebase-analysis |
| planning-agent | task-breakdown |
| test-agent | coding-conventions |
| coder-agent | coding-conventions, git-workflow |
| reviewer-agent | coding-conventions, codebase-analysis |
| documentation-agent | doc-creator |
