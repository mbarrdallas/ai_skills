# Workflow Monitor Workflow

**Primarily** audits a REAL, RUN workflow instance under
`~/WORKSPACE/active_workflows/<name>/` — lessons captured, review-iteration/
rework rates, orchestrator logs/state, missing expected outputs — for TPS-
style waste that actually occurred, and critically, whether captured
lessons' recommended fixes actually made it back into the shared `ai_skills`
definitions or silently went unaddressed. **Secondarily**, can also audit a
static workflow *definition* (`WORKFLOW.md` + its agents + skills, in
`ai_skills` itself) for the same concerns at the design level. Runs
**inline and human-in-the-loop**, in a single conversation, like
`llm_wiki_workflow` and `research_workflow` — no orchestrator, no worktrees.

(This scope split — real instances as primary, static definitions as
secondary — was a correction made the same day this workflow shipped, after
testing against a real completed run revealed the original design only
covered definitions. See `SELF_IMPROVEMENT_LOG.md`.)

## Why this exists

`scripts/validate_*.sh` already catches **structural/syntactic** issues
(missing frontmatter fields, broken symlinks, naming mismatches) — but it
can't catch **process quality and semantic correctness**: redundant checks
duplicated across two agents, unclear handoffs, an agent's assumptions
about another agent's contract that don't actually hold, missing
Kaizen/Jidoka mechanisms. That's exactly the kind of thing a design-agent
grilling critique pass found by hand in `research_workflow` (12 substantive
issues — see `WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md`). This
workflow makes that kind of audit a repeatable, on-demand role instead of
an ad hoc one-off.

Distinct from `knowledge-lint-agent`, which audits wiki *content* — a
different artifact type entirely (markdown knowledge pages vs. workflow/
agent/skill definitions or run instances).

## Why real instances matter more than definitions alone

A workflow definition can look correct on paper and still produce real
waste in practice — or a captured lesson from a real run can correctly
diagnose a symptom while missing the true root cause, get a plausible-
looking fix applied, and the actual defect silently persists (a concrete
example: `stats_dashboard_tui`'s `lessons/2026-06-28-subagent-no-exit.md`
attributed subagent hangs to agent Completion-section wording and marked
itself "Fix Applied" — the real root cause, found independently days
later, was `pi-agent-dashboard`'s bridge extension leaving un-`unref()`'d
timers open, unrelated to agent instruction wording at all). Auditing only
definitions would never catch that a "fixed" lesson didn't actually fix
anything — you need the real run evidence.

## Diagram

```
Human: "audit ~/WORKSPACE/active_workflows/<name>"     (PRIMARY)
   or: "audit workflow <name>"  (definition, SECONDARY)
        │
        ▼
┌─────────────────────────┐
│  workflow-monitor-agent  │
├──────────────────────────┤
PRIMARY (real instance):
│ 1. Confirm it's a real   │  has REQUIREMENTS.md/GOAL.md + orchestrator/
│    instance, not empty   │  or lessons/
│ 2. Read every lessons/   │  highest-value input - each is a real,
│    file in full          │  already-diagnosed incident
│ 3. Verify each lesson's  │  search ai_skills' real definitions - was the
│    fix actually applied  │  fix actually made? verified, not just claimed?
│ 4. Compute rework rate   │  count tasks with -iteration2+ review files
│    from reviews/         │  vs total tasks
│ 5. Check orchestrator/   │  IMPLEMENTATION_LOG.md, missing expected
│    logs + missing outputs│  outputs (BUDGET.md/METRICS.md/ERRORS.md/...)
│                          │
SECONDARY (definition):
│ 1. Prerequisite (Jidoka) │  scripts/validate_workflow.sh <name>
│    - FAIL → STOP, BLOCKED
│    - WARN → proceed, carry forward as context
│ 2. Read definition fully │  WORKFLOW.md, agents, skills it uses
│ 3. Apply TPS checklist   │  toyota-production-system's 7 waste types +
│    + redundancy detection│  Jidoka + Kaizen (inline in the agent)
│                          │
BOTH MODES:
│ 4. Write audit report    │  WORKFLOWS/workflow_monitor_workflow/audits/
│                          │  <date>_<name>.md or ..._<name>-instance.md
│ 5. Fix what's unambiguous│  Direct fix + SELF_IMPROVEMENT_LOG.md entry on
│    (definition only);    │  the relevant DEFINITION (never rewrite a real
│    file the rest         │  instance's historical record); else BACKLOG.md
└──────────────────────────┘
```

## Agents & Skills

| Role | Agent | Skills used |
|------|-------|-------------|
| Audit (both modes) | `workflow-monitor-agent` | `toyota-production-system`, `workflow-conventions` |

Only one agent role, covering both modes — the TPS-lens checklist and
redundancy-detection procedure (secondary mode) and the lesson-verification
procedure (primary mode) all live directly inline in
`workflow_monitor_agent.md` rather than a separate skill (no second agent
needs to reuse them, unlike `wiki-maintenance` which genuinely serves two
agents in `llm_wiki_workflow` — a dedicated skill would just be overhead
here, per the design review that shaped this workflow before
implementation).

## Why No Separate Validator Agent

Per `workflow-conventions`' "Separate the main workflow agent(s) from the
validator/linter agent", workflows should keep primary-work and validation
roles distinct. **This workflow *is itself* the validation role** — it
audits other workflows' quality; there's no separate "primary work" of its
own to self-grade. This mirrors `knowledge-lint-agent`'s position within
`llm_wiki_workflow`: it exists to validate artifacts another agent
produced, not to produce-then-self-grade its own output. The same logic
applies one level up here: `workflow-monitor-agent` validates *other*
workflows' artifacts (their `WORKFLOW.md`/agents/skills), not its own
primary work product.

(This workflow's own design was itself put through a grilling critique
before implementation, and it will be auditable by its own agent like any
other workflow — including auditing itself, with no maturity-bar exemption.
See `SELF_IMPROVEMENT_LOG.md`.)

## Operations

### Primary: real instance audit

Given a path under `~/WORKSPACE/active_workflows/<name>/`,
`workflow-monitor-agent` reads every `lessons/*.md` file (the highest-value
input) and, for each one, actually verifies against the real shared
`ai_skills` definitions whether the recommended fix was made — not just
whether the lesson *claims* it was fixed. It also computes a rework rate
from `reviews/*.md` iteration file-naming, and checks `orchestrator/` logs
and expected-but-possibly-missing outputs (`BUDGET.md`, `METRICS.md`,
`ERRORS.md`, `SIGN_OFF.md`, `COMPLETION_REPORT.md`).

### Secondary: definition audit (Jidoka prerequisite + TPS checklist)

Given a path under `ai_skills/WORKFLOWS/<name>/`, runs
`scripts/validate_workflow.sh <target>` first — a `FAIL` stops the audit
immediately (`BLOCKED`); `WARN`s don't block but get carried into the
findings. Then applies the 7 Muda waste types, Jidoka/quality-built-in
checks, and Kaizen checks (`BACKLOG.md`/`SELF_IMPROVEMENT_LOG.md` presence
*and actual use*) — see `workflow_monitor_agent.md`'s full checklist,
including the **Redundancy Detection procedure** for Over-processing
findings.

### Report and remediate (both modes)

Findings go to a persistent audit report
(`WORKFLOWS/workflow_monitor_workflow/audits/<date>_<name>.md`, or
`..._<name>-instance.md` for a real-instance audit, per
`templates/AUDIT_REPORT_TEMPLATE.md`) — not left to evaporate in
conversation. Unambiguous fixes are applied directly to a *definition*
(never to a real instance's historical record) and logged to that
definition's own `SELF_IMPROVEMENT_LOG.md`; everything else is filed as a
checkbox item in the relevant definition's own `BACKLOG.md` (never this
monitor workflow's own `BACKLOG.md`, which is reserved for the monitor's
own future work).

## Getting Started

**For a real completed/in-progress run:** ask *"audit
~/WORKSPACE/active_workflows/\<name>"* or *"did we actually learn from the
lessons in \<name>"* — this is the primary, higher-value use case.

**For a workflow's definition:** ask *"audit workflow \<name>"* or *"check
\<workflow>'s design for TPS inefficiencies"*.

Avoid "lint" (reserved for `knowledge-lint-agent`/wiki content) and
"validate" (reserved for `scripts/validate_*.sh`) as trigger words for this
workflow, to keep the three roles distinguishable.

## See also

- `toyota-production-system` skill — the general TPS vocabulary this
  workflow applies concretely to workflow definitions.
- `workflow-conventions` skill — the structural standard `validate_*.sh`
  mechanically checks, and the design principles (validator/author
  separation, Tier-0 orchestrator rules, artifact placement,
  self-improvement logging) this workflow checks are actually being
  *followed*, not just present.
- `WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md` — a worked example
  of the category of semantic/design issue this workflow looks for
  (produced by a manual grilling pass, before this workflow existed to do
  it repeatably).
