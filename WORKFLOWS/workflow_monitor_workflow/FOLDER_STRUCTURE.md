# Workflow Folder Structure

## Workflow Definition Structure

```
~/WORKSPACE/REPOS/ai_skills/WORKFLOWS/workflow_monitor_workflow/
├── WORKFLOW.md                # Main workflow definition
├── BACKLOG.md                 # This workflow's own future work
├── FOLDER_STRUCTURE.md         # This file
├── SELF_IMPROVEMENT_LOG.md     # This workflow's own self-improvement history
├── agents/
│   └── workflow_monitor_agent.md → ../../../AGENTS/workflow_monitor_agent.md
├── templates/
│   └── AUDIT_REPORT_TEMPLATE.md   # Structure for every audit report
└── audits/                     # Persistent audit history (not ephemeral
                                #   conversation output) - one file per
                                #   audit run, named <date>_<workflow>.md
    └── .gitkeep
```

No `PRIVATE/SKILLS/` — the TPS-lens checklist and redundancy-detection
procedure live directly inline in `workflow_monitor_agent.md` rather than a
separate skill. A design review (see `SELF_IMPROVEMENT_LOG.md`)
recommended against a dedicated skill here: unlike `wiki-maintenance`
(genuinely shared by two agents in `llm_wiki_workflow`), nothing else in
this workflow would ever load a `workflow-audit` skill, so a separate file
would be pure maintenance overhead with no reuse benefit. Revisit only if a
second agent ever needs the same checklist (tracked in `BACKLOG.md`).

## Where session artifacts go

Like `llm_wiki_workflow` and `research_workflow`, this workflow runs
inline/human-in-the-loop with no orchestrator or worktrees, so it does
**not** use `~/WORKSPACE/active_workflows/<workflow_name>/` (see
`workflow-conventions` skill's "Where running workflow session artifacts
go" — that convention applies specifically to orchestrator/worktree-based
workflows).

The durable output of this workflow is its own `audits/` directory
(persistent findings history) plus whatever fixes/`BACKLOG.md`/
`SELF_IMPROVEMENT_LOG.md` entries it makes in the *audited* workflow.
