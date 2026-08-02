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

## 2026-08-01: Three defects escaped a 115-test autonomous run

**Issue:** The `wiki_tool` run self-reported `DONE` with 115 passing tests, a
clean linter, and a reviewer-agent approval. Human verification afterwards found
three real defects: unreachable dead code (a blanket `WARNING` guard made a
repair branch below it unreachable), a data-loss bug (any index repair triggered
full regeneration, overwriting every human-written summary with
`<placeholder summary>` and re-sorting a curated order), and output that failed
the tool's own validator (`update` wrote a log entry `validate` rejected).

**Learning:** Each escape maps to a *specific gap in the agent definitions*, not
to carelessness:

1. **"No data loss risk" was already in reviewer-agent's Must-Pass list** and did
   not work, because it was too abstract to act on. An abstract checklist item
   gets rubber-stamped. It needed to name the concrete patterns: regenerating a
   whole artifact to fix one derived field, placeholders overwriting populated
   fields, missing `--dry-run`, fixtures whose fields are empty.
2. **Structural review passes on unreachable code.** The D4 check used
   `inspect.getsource()` to confirm shared detection code — and `getsource()`
   succeeds happily on a branch that never executes. Reachability has to be
   asserted directly.
3. **A "0 findings" test asserted against live data is a trap.** It cannot
   distinguish "clean" from "detection is broken", it passed *because* of the
   dead code, and it then *resisted* the fix by failing once the bug was
   corrected.
4. **Synthetic fixtures with empty fields cannot express preservation.** If a
   fixture's summary is `""`, no assertion can detect that the code destroyed it.
5. **The orchestrator had no `## Completion` section at all** — so a `DONE` had
   no defined meaning beyond "the phases ran". It is the agent that interprets
   every other agent's status code, and it had no contract of its own.

**Improvement:**
- `reviewer-agent`: added "No unreachable / dead code" to Must Pass, plus two new
  sections — **"Checking for dead code"** (with the real guard/branch example and
  what to actually inspect: early guards vs. later branches, enum filters read
  against the *producer*, uncovered branches, and accounting invariants) and
  **"Checking destructive code paths"** (turning "no data loss risk" into five
  concrete block conditions).
- `test-agent`: new **"Mandatory test patterns"** section with the three rules —
  never a bare zero-findings assertion (always pair with a positive
  detector-fires test), test destructive paths against distinctive greppable
  content and assert it survives verbatim, and round-trip anything that both
  writes and validates a format. Plus Behavior rules 10–11, including "verify
  each new test fails for the *right reason*".
- `feature-development-orchestrator`: added a `## Completion` section requiring
  artifact-existence checks, gates verified by *running* them rather than
  trusting sub-agent claims, no tasks left retrying, lessons captured, and
  merge-target read from config (it is not always `develop`). States outright
  that "a `DONE` that is only accurate about what you thought to measure is how
  defects escape", and requires unverified paths to be declared in
  `COMPLETION_REPORT.md`.
- Renamed `orchestrator_agent.md` → `feature_development_orchestrator.md` to
  match its frontmatter `name:`, clearing the last two validator warnings. All
  five references updated; `install_agents.sh --prune` correctly detected and
  repaired the broken harness symlink the rename caused — the first real use of
  that flag.

**Result:** `validate_all.sh` now reports **0 warnings** across skills, agents
and workflows (previously 2 agent + 4 workflow warnings, longstanding).

**Related:** `~/WORKSPACE/active_workflows/wiki_tool/lessons/index-regeneration-data-loss.md`,
`mariamas_brain` commits c68628c and 39f8255.
