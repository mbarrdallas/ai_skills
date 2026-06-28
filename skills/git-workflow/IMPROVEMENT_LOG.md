# Git Workflow Skill - Improvement Log

Track improvements made to this skill based on real-world usage.

## 2026-06-28: Worktrees never enforced in practice

**Issue:** During stats_dashboard_tui workflow, coder-agents committed directly to `develop` on every task instead of using feature branches and worktrees as specified.

**Root Cause:** The orchestrator's task instructions to coder-agents never included the branch name or working directory. Agents defaulted to whatever branch they were on (develop).

**Learning:** Specifying worktrees in the orchestrator spec is not enough — the orchestrator must actively create the worktree AND pass it explicitly in every coder-agent task instruction.

**Fix Applied:**
- Added rules #12 and #13 to orchestrator agent behavior
- Orchestrator must now create worktree before spawning coder-agent
- Coder-agent task instructions must always include `Git branch:` and `Working directory:`

**Coder-agent task template addition:**
```
Git branch: feature/<task-id>
Working directory: <worktree-path>
Commit your work to this branch only. Do not touch other branches.
```

**Related:** stats_dashboard_tui lesson 2026-06-28-feature-branches-not-used.md
