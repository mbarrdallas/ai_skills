# Workflow Folder Structure

## Workflow Definition Structure

The workflow definition lives in:
```
~/WORKSPACE/REPOS/ai_skills/WORKFLOWS/research_workflow/
├── WORKFLOW.md              # Main workflow definition
├── BACKLOG.md               # Workflow-specific future work
├── FOLDER_STRUCTURE.md       # This file
└── agents/                  # Symlinks to agents used by this workflow
    ├── research_agent.md        → ../../../AGENTS/research_agent.md
    └── knowledge_ingest_agent.md → ../../../AGENTS/knowledge_ingest_agent.md
        (symlinked here for traceability only - this agent is primarily
         owned by llm_wiki_workflow, not research_workflow. research_workflow
         is a consumer: it delegates wiki query/ingest mechanics to this
         existing agent rather than reimplementing them - see WORKFLOW.md's
         "Why this exists". Any change to knowledge-ingest-agent's contract
         should be coordinated with llm_wiki_workflow, since it's shared.)
```

No `templates/` or `PRIVATE/` directories yet — see `BACKLOG.md` for a
possible future `RESEARCH_SCOPE_TEMPLATE.md`, and this file's note below on
why there's no private orchestrator.

## Where session artifacts go

This workflow runs **inline, human-in-the-loop**, like `llm_wiki_workflow`
— not async/multi-agent-orchestrated like `feature_development_workflow`.
It has no orchestrator, no worktrees, and no `WORKFLOW_CONFIG.md`/
`ORCHESTRATOR_STATE.md`-style process artifacts, so it does **not** use
`~/WORKSPACE/active_workflows/<workflow_name>/` (see `workflow-conventions`
skill's "Where running workflow session artifacts go" — that convention
applies specifically to workflows with orchestrator/worktree machinery).

The only durable output is whatever lands in the target wiki repo itself
(via `knowledge-ingest-agent`, following that wiki's own `raw/`/`wiki/`
layout — see `llm_wiki_workflow/FOLDER_STRUCTURE.md`). Scoping discussion
and interim research notes stay in-conversation unless/until the backlog
item for a `RESEARCH_SCOPE_TEMPLATE.md` is picked up.

## Why no `PRIVATE/AGENTS/` orchestrator

`research-agent` coordinates a spawn to `knowledge-ingest-agent` but isn't a
Tier-0 orchestrator in the `workflow-conventions` sense — it doesn't manage
worktrees, parallel tasks, or process/state artifacts. If this workflow is
ever upgraded to support parallel research threads (see `BACKLOG.md`), that
upgrade would likely introduce a dedicated `PRIVATE/AGENTS/` orchestrator at
that point, following `feature_development_workflow`'s pattern.
