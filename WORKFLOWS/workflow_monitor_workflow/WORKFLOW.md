# Workflow Monitor Workflow

Audits the *design* of other workflows — `WORKFLOW.md` + the agents they
use + the skills those agents load — for TPS-style process waste, missing
built-in quality/improvement mechanisms, and semantic/design-level
correctness issues. Runs **inline and human-in-the-loop**, in a single
conversation, like `llm_wiki_workflow` and `research_workflow` — no
orchestrator, no worktrees.

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
agent/skill definitions).

## Diagram

```
Human: "audit workflow <name>"
        │
        ▼
┌────────────────────────┐
│  workflow-monitor-agent │
├─────────────────────────┤
│ 1. Prerequisite (Jidoka)│  scripts/validate_workflow.sh <name>
│    - FAIL → STOP, BLOCKED
│    - WARN → proceed, carry forward as context
│                         │
│ 2. Read target's        │  WORKFLOW.md, BACKLOG.md, FOLDER_STRUCTURE.md,
│    definition fully     │  SELF_IMPROVEMENT_LOG.md, every agent + skill
│                         │  it actually uses
│                         │
│ 3. Apply TPS checklist  │  toyota-production-system skill's 7 waste
│    + redundancy         │  types + Jidoka + Kaizen, applied concretely
│    detection procedure  │  (inline in workflow-monitor-agent.md)
│                         │
│ 4. Write audit report   │  WORKFLOWS/workflow_monitor_workflow/audits/
│                         │  <date>_<workflow>.md (persistent, not
│                         │  conversation-ephemeral)
│                         │
│ 5. Fix what's           │  Direct fix + log to audited workflow's own
│    unambiguous;         │  SELF_IMPROVEMENT_LOG.md, OR file to audited
│    file the rest        │  workflow's own BACKLOG.md
└─────────────────────────┘
```

## Agents & Skills

| Role | Agent | Skills used |
|------|-------|-------------|
| Audit | `workflow-monitor-agent` | `toyota-production-system`, `workflow-conventions` |

Only one agent role — the TPS-lens checklist and redundancy-detection
procedure live directly inline in `workflow_monitor_agent.md` rather than a
separate skill (no second agent needs to reuse it, unlike `wiki-maintenance`
which genuinely serves two agents in `llm_wiki_workflow` — a dedicated
skill would just be overhead here, per the design review that shaped this
workflow before implementation).

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

### Prerequisite check (Jidoka)

`workflow-monitor-agent` always runs `scripts/validate_workflow.sh
<target>` first. A `FAIL` stops the audit immediately (`BLOCKED` status) —
auditing process quality on top of broken structural fundamentals isn't
useful. `WARN`s don't block, but get carried into the findings (a missing
`SELF_IMPROVEMENT_LOG.md` warning, for instance, is directly a Kaizen
finding, not a separate concern to re-derive).

### TPS + semantic audit

Applies the 7 Muda waste types (Overproduction, Waiting, Transport,
Over-processing, Inventory, Motion, Defects), Jidoka/quality-built-in
checks, and Kaizen/continuous-improvement checks (`BACKLOG.md`/
`SELF_IMPROVEMENT_LOG.md` presence *and actual use*, not just existence) —
see `workflow_monitor_agent.md`'s full checklist. Over-processing findings
specifically use a concrete **Redundancy Detection procedure**: enumerate
every skill loaded by every agent in the target workflow, and check for
overlapping operations between agents using the same skill, plus overlap
between agents' stated scopes ("your job"/"not your job" sections).

### Report and remediate

Findings go to a persistent audit report
(`WORKFLOWS/workflow_monitor_workflow/audits/<date>_<workflow>.md`, per
`templates/AUDIT_REPORT_TEMPLATE.md`) — not left to evaporate in
conversation. Unambiguous fixes are applied directly and logged to the
*audited* workflow's own `SELF_IMPROVEMENT_LOG.md`; everything else is
filed as a checkbox item in the *audited* workflow's own `BACKLOG.md`
(never this monitor workflow's `BACKLOG.md`, which is reserved for the
monitor's own future work).

## Getting Started

Ask: *"audit workflow \<name>"* or *"check \<workflow> for TPS
inefficiencies"*. Avoid "lint" (reserved for `knowledge-lint-agent`/wiki
content) and "validate" (reserved for `scripts/validate_*.sh`) as trigger
words for this workflow, to keep the three roles distinguishable.

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
