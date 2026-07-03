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

## 2026-07-03: Scope correction - real run instances are the primary mode, not just static definitions

**Issue:** The initial design and implementation only covered auditing
static workflow *definitions* (`WORKFLOW.md` + agents + skills, on paper).
The human corrected this directly: the actual primary purpose should be
analyzing **real, run workflow instances** under
`~/WORKSPACE/active_workflows/<name>/` - the real execution evidence
(`lessons/`, `reviews/` iteration counts, `orchestrator/` logs, missing
expected outputs) - with definition-auditing as a secondary, supplementary
capability, not the main point.

**Learning:** Real TPS analysis is about actual process *execution*, not
just process *design on paper* - a definition can look correct and still
produce real waste, and (more importantly) a captured lesson can
misdiagnose a root cause, get a plausible-looking fix applied, and the
real defect can silently persist with nothing to catch it except checking
against what actually happened later. Concrete proof this matters: reading
`~/WORKSPACE/active_workflows/stats_dashboard_tui/lessons/2026-06-28-subagent-no-exit.md`
showed it attributed subagent hangs to agent Completion-section wording
and marked itself "Fix Applied" - but the real root cause (found
independently, same day as this correction) was `pi-agent-dashboard`'s
bridge extension leaving timers/WebSocket un-`unref()`'d, completely
unrelated to instruction wording. A definition-only audit would never have
caught that this "fixed" lesson didn't actually fix anything. Also found,
same session: a third lesson's explicit action item ("add 'Symlink
extension' to the feature-development sign-off checklist") was never
actually applied to `feature_development_workflow`'s definition at all -
confirmed by grep before any tooling existed to catch it automatically.

**Improvement:** Restructured `workflow_monitor_agent.md` around two
explicit modes: **Primary** (real instance - reads every `lessons/*.md`
and actually verifies, against the real shared definitions, whether each
recommended fix was made and whether it addressed the true root cause vs.
a symptom; computes a real rework rate from `reviews/` iteration-file
naming; checks for missing expected orchestrator outputs) and **Secondary**
(static definition - the original TPS/Jidoka/Kaizen/semantic checklist,
kept as-is). Added a "Cross-Referencing the Two Modes" section connecting
them (an unaddressed instance lesson is a live Kaizen gap in the
definition). Updated `WORKFLOW.md`, `templates/AUDIT_REPORT_TEMPLATE.md`
(new Lesson Verification / Rework Rate / Missing Expected Outputs
sections), and `skills/trigger-workflow-monitor/SKILL.md` to lead with the
primary mode.

**Related:** Immediately re-tested against the real
`stats_dashboard_tui` instance after this correction - see the resulting
audit report in `audits/` for what it actually found.

## 2026-07-03: First real primary-mode run missed a bundled lesson and misjudged a root-cause fix

**Issue:** Ran `workflow-monitor-agent` in primary mode against the real
`stats_dashboard_tui` instance (first genuine test of the corrected
design). Human spot-checking the resulting report found two real gaps:
1. `lessons/2026-06-28-subagent-no-exit.md` actually bundles **two**
   distinct lessons in one file (two `# Lesson` sections separated by a
   `---` rule) - the audit evaluated only the first and never noticed the
   second ("Extension Must Be Symlinked After Delivery"), whose action
   item genuinely was never applied.
2. The first lesson's claimed fix ("agent Completion-section wording") was
   classified "Applied and verified" - but this is *precisely* the
   canonical case named in this very agent's own instructions and
   `WORKFLOW.md` as the example to watch for: a symptom-level fix
   (instruction wording) that doesn't explain a structural/runtime symptom
   (a process not exiting), while the true root cause
   (`pi-agent-dashboard`'s un-`unref()`'d timers) was found independently
   the same day, unrelated to wording at all. The agent didn't apply its
   own stated verification bar rigorously enough - it accepted the
   lesson's self-reported "Fix Applied" status without actually checking
   whether the fix's *mechanism* plausibly explained the symptom, or
   whether the same defect category had recurred since.

**Learning:** Real-world testing (not just design review) surfaces gaps a
design review can't - this is exactly the same lesson the earlier design
review already taught (grilling a design catches some things, but nothing
substitutes for running it against real, messy data). Two specific,
generalizable failure modes found: (a) naive one-file-equals-one-lesson
scanning misses content that doesn't fit the expected shape (same category
as `knowledge-lint-agent`'s multi-line-wikilink pitfall - worth watching
for this pattern anywhere a fixed-shape assumption is made over free-form
content), and (b) accepting a source's own self-reported status
("Fix Applied") without independently verifying it, which is exactly the
kind of thing a *lint/audit* role exists to catch rather than rubber-stamp.

**Improvement:** `AGENTS/workflow_monitor_agent.md`'s "core check" section
rewritten: (1) explicit instruction to check every lessons file for
multiple lesson sections before classifying anything, (2) a genuinely
stronger verification bar - does the fix's *mechanism* plausibly explain
the *mechanism* of the symptom, has the same defect category recurred or
been independently fixed again later (strong evidence of misdiagnosis),
is there actual positive evidence of non-recurrence - replacing what had
become "does a plausible-sounding change exist somewhere". Explicitly
stated: a lesson's own "Fix Applied" self-report is not authoritative.
Corrected the `stats_dashboard_tui` audit report itself to add the missed
lesson and fix the wrong classification, with a visible correction note
rather than silently editing history. Filed the missed lesson's action
item to `feature_development_workflow`'s `BACKLOG.md`.

**Related:** `audits/2026-07-03_stats_dashboard_tui-instance.md` (see its
correction note at the top); `WORKFLOWS/feature_development_workflow/BACKLOG.md`.
