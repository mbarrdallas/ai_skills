# Self-Improvement Log - Feature Development Workflow

Append-only, chronological log of self-improvements to this workflow's own
definition (`WORKFLOW.md`, `FOLDER_STRUCTURE.md`, `BACKLOG.md`, and the
agents/skills it owns) — see `workflow-conventions` skill's
"Self-improvement logging" for the entry format and what counts as an
entry vs. routine work. Backfilled below with real history from before
this log file existed (this workflow already had informal self-improvement
practice via `skills/coding-conventions/IMPROVEMENT_LOG.md` and
`skills/task-breakdown/IMPROVEMENT_LOG.md` — see commit `8e90d94`; this
file extends the same discipline to the workflow/agent level specifically).

---

## 2026-08-01: added `trigger-feature-development-workflow` routing skill

**Gap:** this workflow had **no public trigger skill**, so conversational
requests never auto-routed to it. `llm_wiki_workflow` has
`trigger-llm-wiki-workflow` and `workflow_monitor_workflow` has
`trigger-workflow-monitor`; a user saying "build me X" would *not* auto-engage
this workflow — it had to be invoked explicitly by name, which is exactly the
discoverability problem those trigger skills were created to solve.

**Also noted:** `research_workflow` has no trigger skill either (its
`research-agent` carries `trigger-llm-wiki-workflow` for routing findings
*into* a wiki, which is a different concern from routing requests *into*
research). Filed to that workflow's backlog rather than fixed here — out of
scope for this change.

**Change:** added `skills/trigger-feature-development-workflow/` (public,
symlinked into the harness skills dir at creation time per `AGENTS.md`), and
referenced it from `WORKFLOW.md`'s "Skills Required" table and "Getting
Started" section.

**Design note — negative triggers are the important half.** The skill devotes
as much space to *when not to trigger* as when to. Routing a one-line fix, a
debugging session, or a "how does this work?" question into an 8-phase
multi-agent pipeline is over-processing waste in TPS terms, and would make the
workflow feel heavyweight and get avoided. Explicit non-triggers: trivial
edits, debugging (→ `scientific-method`), code questions (→
`codebase-analysis`), wiki work (→ `trigger-llm-wiki-workflow`), research,
workflow auditing (→ `trigger-workflow-monitor`), and authoring
workflow/skill tooling (→ `workflow-conventions`). Borderline cases are told
to ask the human rather than silently pick.

## 2026-06-27: Agents must exit immediately after returning a status code

**Issue:** Agents sometimes continued producing output after their status
code, or the status code wasn't reliably the final line — breaking
automated parsing of completion state by the orchestrator.

**Improvement:** Standardized the `## Completion` section contract across
all agents: status code must be the absolute last line, nothing after it.

**Related:** commit `ee649b3`.

## 2026-06-27: Coder-agent must read integration docs before implementing

**Issue:** A Pi extension entry point was implemented with the wrong
export format (guessed from similar patterns instead of the actual API
docs), causing runtime failures unit tests couldn't catch.

**Learning:** When implementing against an external framework/platform
API, guessing the shape from similar-looking code leads to code that
passes unit tests but fails in the real runtime — the docs must actually
be read first.

**Improvement:** Added to `coder-agent`'s behavior rules: read relevant
documentation first. Added to orchestrator rules: include doc paths in
`coder-agent` task instructions explicitly.

**Related:** commit `e22698d`; `skills/coding-conventions/IMPROVEMENT_LOG.md`'s
2026-06-28 entry (same incident, skill-level fix).

## 2026-06-27: Orchestrator must consult design-agent on deviations, not decide unilaterally

**Issue:** The orchestrator sometimes made architectural judgment calls
mid-implementation without looping back to the agent whose job was
actually to make design decisions.

**Improvement:** Added an explicit deviation protocol: the orchestrator
consults `design-agent` when implementation reveals a design
deviation, and delegates the resulting fix to `coder-agent` rather than
deciding the design change itself.

**Related:** commit `98aafe9`.

## 2026-07-03: Workflow planning artifacts must live in `active_workflows/`, never the code repo

**Issue:** Workflow-planning artifacts (spec/plan/state files) had been
appearing inside the actual code repository being worked on, mixing
process bookkeeping with the codebase's real history.

**Improvement:** Documented explicitly (`git-workflow` skill, then
generalized into `workflow-conventions`' "Where running workflow session
artifacts go") that these belong under
`~/WORKSPACE/active_workflows/<workflow_name>/` — never the code repo.
Also added the general "Tier-0 orchestrators must load `workflow-conventions`"
rule, and applied it to `feature-development-orchestrator` itself.

**Related:** commits `d98486b` (ai_tools, the original symptom fix) and
`2c9ad29` (ai_skills, the generalized convention).
