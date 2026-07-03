# Self-Improvement Log - Workflow Monitor Workflow

Append-only, chronological log of self-improvements to this workflow's own
definition — see `workflow-conventions` skill's "Self-improvement logging"
for the entry format and what counts as an entry vs. routine work.

---

## 2026-07-03: Design reviewed and revised before any implementation

**Issue:** An initial design draft proposed: a dedicated private
`workflow-audit` skill for the TPS-lens checklist; loading both
`workflow-conventions` and running `validate_*.sh` (unclear division of
labor between the two); no findings-report persistence location; no
explicit stop-the-line behavior if structural validation fails first; no
concrete procedure for detecting redundant checks between agents (the
category of issue this very workflow exists to catch); no "not your job"
scope boundary; ambiguous trigger phrasing risking collision with
"lint"/"validate" (already reserved for `knowledge-lint-agent` and
`scripts/validate_*.sh` respectively).

**Learning:** Grilling a design *before* writing any files is cheaper than
grilling an implementation after — several of these (the missing
persistence location, the missing stop-the-line behavior, the trigger-word
collision) would have been just as real as findings in
`research_workflow`'s post-implementation grilling pass, but catching them
pre-implementation meant zero throwaway/rewritten files. This validates
doing design-then-grill-then-implement as the default sequence for new
workflows going forward, not just for this one.

**Improvement:**
- Dropped the dedicated `workflow-audit` skill — inlined the TPS checklist
  and redundancy-detection procedure directly into
  `AGENTS/workflow_monitor_agent.md` (no second agent needs to reuse it,
  unlike `wiki-maintenance`'s genuine two-agent reuse in
  `llm_wiki_workflow` — a separate skill file would be pure overhead).
- Kept `workflow-conventions` as a loaded skill (partial override of the
  design review's recommendation to drop it entirely) but scoped its
  purpose precisely: not for re-deriving what `validate_*.sh` already
  checks mechanically, but for the design judgment behind those same
  conventions that a shell script can't verify (is validator/author
  separation *actually* respected in spirit, is a Tier-0 orchestrator
  *actually* loading the skill, are artifacts *actually* landing in
  `active_workflows/`). See `AGENTS/workflow_monitor_agent.md`'s skill-
  loading section for the exact reasoning.
- Added a Jidoka prerequisite: run `validate_workflow.sh` first, `BLOCKED`
  immediately on any `FAIL`, proceed (carrying warnings forward as
  context) on `WARN`-only results.
- Added a concrete Redundancy Detection procedure (enumerate skills loaded
  per-agent, check for overlapping operations; compare agent scope
  boundaries pairwise) rather than an aspirational "check for redundancy"
  instruction.
- Added persistent audit-report storage
  (`WORKFLOWS/workflow_monitor_workflow/audits/<date>_<workflow>.md`, via
  a new `templates/AUDIT_REPORT_TEMPLATE.md`) instead of leaving findings
  to evaporate in conversation.
- Added an explicit "Not your job" section and clarified trigger phrasing
  ("audit", not "lint"/"validate") to keep the three roles
  (`workflow-monitor-agent`, `knowledge-lint-agent`, `validate_*.sh`)
  clearly distinguishable.
- Confirmed no maturity bar: this workflow (and any brand-new workflow) is
  auditable from day one, including auditing itself.

**Related:** Design draft reviewed at (ephemeral, not committed)
`/tmp/workflow_monitor_workflow_DESIGN_DRAFT.md`, critiqued via the
`subagent` tool (design-agent role). See
`AGENTS/SELF_IMPROVEMENT_LOG.md` for `research_agent.md`'s
analogous grilling-driven entries, and `WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md`
for the post-implementation grilling precedent this workflow's
pre-implementation grilling was modeled on.

## 2026-07-03: First real dogfood run - self-audit found one phrasing ambiguity

**Issue:** Ran `workflow-monitor-agent` against this workflow itself (via
the `subagent` tool) as the first real end-to-end test, not just a design
review. It found one genuine ambiguity: the Jidoka checklist's bullet about
Tier-0 orchestrators ("check the frontmatter `skills:` field directly, not
just whether the workflow seems to follow the convention in spirit") used
a "not just X" construction readable two ways - "X is insufficient, need
both" or "don't do X, do Y instead". Correctly judged not unambiguous
enough to fix on its own initiative; filed to `BACKLOG.md` instead exactly
as its own instructions require.

**Learning:** The design/mechanics held up on first real use - prerequisite
check ran correctly, report went to the right path, the fix-vs-file
judgment call was applied correctly (a phrasing improvement with multiple
valid rewordings is editorial, not unambiguous). This is a good sign the
design review before implementation actually worked, not just that it
looked plausible on paper.

**Improvement:** Rephrased the flagged bullet to an explicit "Check
**both**: ... **and** ..." construction, removing the ambiguity. Checked
off the corresponding `BACKLOG.md` item.

**Related:** `audits/2026-07-03_workflow-monitor-workflow.md` (the audit
report itself); `BACKLOG.md`'s now-checked-off "Audit Findings" entry.
