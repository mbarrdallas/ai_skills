---
name: trigger-workflow-monitor
description: Detect when the user wants to audit a REAL, RUN workflow instance under ~/WORKSPACE/active_workflows/<name>/ (did we actually learn from the lessons captured, what was the real rework rate, were expected outputs produced) - the PRIMARY use case - or, secondarily, a workflow's static design/definition (as distinct from wiki content or code) for process waste, inefficiency, or correctness issues, and route to workflow_monitor_workflow. Use whenever the user says things like "audit this workflow run/instance", "did we learn from the lessons in <name>", "check this completed workflow for waste", "audit workflow X's design", "check this workflow for inefficiencies", "is this workflow well-designed", "find TPS waste in this workflow", "this workflow feels inefficient/redundant", or asks to health-check/review/improve a workflow instance or definition itself (not wiki content, not application code). Make sure to trigger this even if the user doesn't say "audit" explicitly - phrases like "this workflow has some overlap/redundancy", "clean up this workflow", "is this workflow set up well", or "did we actually fix that" (in reference to a past lesson/incident) should also route here.
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

- **Primary case: a REAL run instance.** The user points at (or describes)
  something under `~/WORKSPACE/active_workflows/<name>/` — a completed or
  in-progress workflow run — and wants to know whether real waste
  occurred, whether captured `lessons/` were actually fixed upstream, what
  the real rework rate was, or similar. This is the higher-value case:
  "did we actually learn from `stats_dashboard_tui`", "audit this run",
  "check if that lesson ever got fixed".
- **Secondary case: a workflow's own definition.** The user wants
  `WORKFLOWS/<name>/` itself (in `ai_skills`) reviewed for quality — not
  its output, not wiki content, not application code: "audit
  `research_workflow` for redundancy".
- Distinguish carefully from adjacent roles:
  - "lint my wiki" / "check the wiki for contradictions" → **NOT this** —
    that's `knowledge-lint-agent` / `llm_wiki_workflow` (wiki *content*,
    a different artifact type).
  - "validate this skill's frontmatter" / "does this pass validation" →
    **NOT this** — that's `scripts/validate_*.sh` (structural/syntactic
    correctness, mechanical). This workflow builds on top of that, not
    instead of it.
  - "review my code" / "check this PR" → **NOT this** — that's
    `reviewer-agent` (application code, not a workflow instance/definition).
- The user describes symptoms even without naming "audit" explicitly:
  redundancy/overlap between agents, an unclear handoff, a workflow that
  "feels" inefficient or bloated, wondering if a past lesson/incident was
  ever actually resolved, or wanting a run/workflow health-checked/
  reviewed/cleaned up.
- The user references TPS/Lean concepts (waste, Muda, Jidoka, Kaizen, WIP,
  "stop the line") in the context of a workflow run or design.

## What to do when triggered

1. Read `WORKFLOWS/workflow_monitor_workflow/WORKFLOW.md` for the full
   operation (both modes).
2. Identify the target: a path under `~/WORKSPACE/active_workflows/<name>/`
   (primary/instance mode) or `ai_skills/WORKFLOWS/<name>/` (secondary/
   definition mode) — ask the human if ambiguous which they mean, or
   whether they want all instances/workflows audited.
3. Proceed as the `workflow-monitor-agent` role describes
   (`AGENTS/workflow_monitor_agent.md`) — primary mode reads every
   `lessons/*.md` and verifies fixes against the real definitions;
   secondary mode runs its Jidoka prerequisite
   (`scripts/validate_workflow.sh <target>` must not `FAIL`) before the
   TPS/semantic checklist.

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
