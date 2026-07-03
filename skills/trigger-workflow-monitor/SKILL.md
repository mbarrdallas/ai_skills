---
name: trigger-workflow-monitor
description: Detect when the user wants to audit, health-check, or review a workflow's design (as distinct from wiki content or code) for process waste, inefficiency, or correctness issues, and route to workflow_monitor_workflow. Use whenever the user says things like "audit workflow X", "check this workflow for inefficiencies", "review this workflow's design", "is this workflow well-designed", "find TPS waste in this workflow", "this workflow feels inefficient/redundant", or asks to health-check/lint/improve a workflow, agent, or skill definition itself (not wiki content, not application code). Make sure to trigger this even if the user doesn't say "audit" explicitly - phrases like "this workflow has some overlap/redundancy", "clean up this workflow", or "is this workflow set up well" should also route here.
---

# Trigger: Workflow Monitor Workflow

A lightweight **routing skill**, built with the `skill-creator` skill. Its
only job is to recognize when someone wants a *workflow's design* audited
(TPS-style waste, missing quality/improvement mechanisms, semantic
correctness) and point to `workflow_monitor_workflow` — it does not itself
carry the audit checklist. That procedure lives directly in
`AGENTS/workflow_monitor_agent.md` (inlined there rather than a separate
skill, per that workflow's own design review — see its
`SELF_IMPROVEMENT_LOG.md`).

## When this triggers

- The user wants a **workflow's own definition** reviewed for quality —
  not its output, not wiki content, not application code. Distinguish
  carefully:
  - "audit `research_workflow` for redundancy" → **this workflow** (a
    workflow *definition*).
  - "lint my wiki" / "check the wiki for contradictions" → **NOT this** —
    that's `knowledge-lint-agent` / `llm_wiki_workflow` (wiki *content*,
    a different artifact type).
  - "validate this skill's frontmatter" / "does this pass validation" →
    **NOT this** — that's `scripts/validate_*.sh` (structural/syntactic
    correctness, mechanical). This workflow builds on top of that, not
    instead of it.
  - "review my code" / "check this PR" → **NOT this** — that's
    `reviewer-agent` (application code, not a workflow definition).
- The user describes symptoms even without naming "audit" explicitly:
  redundancy/overlap between agents, an unclear handoff, a workflow that
  "feels" inefficient or bloated, wanting to know if a workflow follows
  good practice, or wanting a workflow health-checked/reviewed/cleaned up.
- The user references TPS/Lean concepts (waste, Muda, Jidoka, Kaizen, WIP,
  "stop the line") in the context of a workflow's design specifically.

## What to do when triggered

1. Read `WORKFLOWS/workflow_monitor_workflow/WORKFLOW.md` for the full
   operation.
2. Identify the target workflow directory (`WORKFLOWS/<name>/`) — ask the
   human if it's ambiguous which workflow they mean, or if they want all
   workflows audited.
3. Proceed as the `workflow-monitor-agent` role describes
   (`AGENTS/workflow_monitor_agent.md`) — including its Jidoka prerequisite
   (`scripts/validate_workflow.sh <target>` must not `FAIL` before a
   design/TPS audit is useful).

## Reference

- Workflow: `WORKFLOWS/workflow_monitor_workflow/WORKFLOW.md`
- Agent: `AGENTS/workflow_monitor_agent.md` (TPS checklist inlined here —
  no separate mechanics skill, unlike `llm_wiki_workflow`'s
  `wiki-maintenance`)
- Report template: `WORKFLOWS/workflow_monitor_workflow/templates/AUDIT_REPORT_TEMPLATE.md`
- Audit history: `WORKFLOWS/workflow_monitor_workflow/audits/`
- Repo/skill/workflow structural conventions: `workflow-conventions` skill
- Sibling routing skill for the other inline workflow in this repo:
  `trigger-llm-wiki-workflow` (wiki content, not workflow definitions —
  don't confuse the two; see "When this triggers" above)
