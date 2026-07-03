# Workflow Audit — stats_dashboard_tui (Instance) — 2026-07-03

Mode: PRIMARY - real run instance

> **Correction (2026-07-03, same day, added after human spot-check):** The
> agent-generated audit below missed two real things, caught by manually
> re-checking its work — itself a Jidoka finding about the audit's own
> rigor, logged in `SELF_IMPROVEMENT_LOG.md` and fixed in
> `workflow_monitor_agent.md` for future runs:
> 1. `2026-06-28-subagent-no-exit.md` actually bundles **two** distinct
>    lessons in one file (two `# Lesson` sections separated by `---`) —
>    the audit evaluated only the first ("Agents Must Exit Immediately")
>    and never noticed the second ("Extension Must Be Symlinked After
>    Delivery"), whose action item was genuinely never applied. See the
>    added row/section below.
> 2. The first lesson's classification ("Applied and verified") was
>    **wrong** by the audit's own stated standard. Its own instructions
>    (and this workflow's `WORKFLOW.md`) name this *exact* incident as the
>    canonical example of a fix that addresses a symptom (agent
>    Completion-section wording) while missing the real, structural root
>    cause (`pi-agent-dashboard`'s un-`unref()`'d timers, found
>    independently the same day, unrelated to instruction wording at all).
>    The correct classification is **Applied but incorrect / did not
>    address the true root cause** — corrected below.

## Summary

Audited the completed stats_dashboard_tui feature_development_workflow
instance. 11 lessons (10 files, one file bundling 2 lessons — see
correction above). 8 applied and verified, 1 applied but addressing the
wrong root cause (corrected), 2 not applied. Rework rate: 23.5% (4 of 17
tasks required iteration 2). Critical finding: orchestrator produced only
2 of 7 documented outputs (IMPLEMENTATION_LOG.md and ORCHESTRATOR_STATE.md
present, but BUDGET.md, METRICS.md, ERRORS.md, SIGN_OFF.md,
COMPLETION_REPORT.md all missing) — a significant Inventory (在庫) gap,
not just a process deviation. Most lessons' fixes were successfully
upstreamed to feature_development_workflow's definition, but three
(after correction) remain genuinely unaddressed or misdiagnosed.

---

## Lesson Verification

| Lesson file | Root cause claimed | Fix claimed | Verified applied? |
|---|---|---|---|
| `2026-06-27-budget-monitoring-failure.md` | Orchestrator protocol lacks concrete budget monitoring implementation | Add budget tracking protocol, BUDGET.md template, pre-flight checks | **Applied and verified** |
| `2026-06-27-orchestrator-discipline.md` | Orchestrator didn't follow its own protocol (skipped reviews, state updates) | Added explicit "After Each Task Completes" checklist and behavior rules | **Applied and verified** |
| `2026-06-27-orchestrator-paraphrasing-error.md` | Orchestrator paraphrased acceptance criteria instead of directing agents to source | Add behavior rule: never paraphrase, always direct to source document | **Applied and verified** |
| `2026-06-27-web-vs-tui-decision.md` | Requirements didn't specify UI delivery medium (terminal vs browser) | Add "UI Delivery Medium" to requirements gathering checklist | **Not applied** |
| `2026-06-28-feature-branches-not-used.md` | Task instructions didn't specify branch, orchestrator didn't create worktrees | Orchestrator must create worktree before spawning coder-agent, include branch/directory in task | **Applied and verified** |
| `2026-06-28-missing-integration-testing.md` | Workflow only included unit tests, no phase to run actual target runtime | Add Phase 6: Integration Testing before documentation | **Applied and verified** |
| `2026-06-28-pi-extension-factory-format.md` | Wrong export format (activate/deactivate vs factory function) | Always read Pi extension docs before implementing | **Applied and verified** |
| `2026-06-28-pi-extension-symlink-resolution.md` | Extension imports broke under symlink loading (../../../lib paths) | Extension must be self-contained, covered by doc discovery pattern | **Applied and verified** |
| `2026-06-28-subagent-hangs-after-done.md` | Subagents complete work but don't terminate cleanly | Always check for output files after an abort before assuming failure | **Not applied** |
| `2026-06-28-subagent-no-exit.md` (lesson 1 of 2 in this file) | Agents continued processing after printing status | Update agent completion sections to say "status must be last line, stop immediately" | **Applied, but WRONG ROOT CAUSE** (see correction below) |
| `2026-06-28-subagent-no-exit.md` (lesson 2 of 2 in this file, "Extension Must Be Symlinked After Delivery") | Extension built/merged but never symlinked into `~/.pi/agent/extensions/`, so never actually loaded | Symlink after delivery; add "Symlink extension" as a sign-off checklist step for Pi extensions | **Not applied** |

### 2026-06-27-web-vs-tui-decision.md: Not applied

**What the lesson claimed:** Requirements gathering should include a checklist item for "UI Delivery Medium" to clarify early whether the user wants terminal/TUI, browser/web, desktop app, mobile, or API-only.

**What I found:** Searched `requirements_agent.md` and the `scientific-method` skill (which requirements-agent loads) for any mention of "UI Delivery Medium", "terminal vs browser", or similar checklist items. Found none.

**Root cause still unaddressed:** This was a symptom of a broader gap — requirements gathering doesn't have an explicit checklist of non-functional concerns to probe. The lesson's specific recommendation (add "UI Delivery Medium" as a checklist item) was never applied.

**Resolution:** Filed to `WORKFLOWS/feature_development_workflow/BACKLOG.md`.

### 2026-06-28-subagent-no-exit.md (lesson 1, Completion-section wording): Applied, but wrong root cause

**What the lesson claimed:** Root cause was agent `## Completion` sections
not explicitly saying "stop immediately" after printing status; fix was to
add that wording, and the lesson marked itself "Fix Applied".

**What I actually found (via human spot-check, not the original audit
pass):** The wording fix was made and does exist in agent files today. But
the *actual* root cause of subagents hanging after DONE — found completely
independently, the same day as this audit — was `pi-agent-dashboard`'s
bridge extension leaving `heartbeatTimer`/`gitPollTimer`/`processScanTimer`/
a WebSocket connection un-`unref()`'d, so a one-shot (`--print`/subagent)
process had nothing else keeping it alive after finishing real work and
hung until force-killed — completely unrelated to Completion-section
wording. Confirmed via direct reproduction earlier this same session
(three `subagent` tool calls aborted in a row, including a trivial
single-file-read task, before the real fix). Fixed in `pi-agent-dashboard`
commit `bc315a19`.

**Root cause still unaddressed at the time this lesson was written**
(now fixed, but not because of this lesson's recommended action — the
wording change was a plausible-looking but incorrect diagnosis that
happened not to cause active harm, it just didn't fix anything either).

**Resolution:** No further action needed now that the real fix is in
place (`pi-agent-dashboard` `bc315a19`) — but flagging this as a process
finding: **`workflow_monitor_agent.md`'s own lesson-verification procedure
needs a stronger bar than "a plausible-sounding change exists in the
definition"** — see `SELF_IMPROVEMENT_LOG.md` for the fix applied to the
agent's own instructions as a result.

### 2026-06-28-subagent-no-exit.md (lesson 2, "Extension Must Be Symlinked After Delivery"): Not applied

**What the lesson claimed:** After delivering a Pi extension, it must be
symlinked into `~/.pi/agent/extensions/<name>` or it's never actually
loaded. Recommended action: add "Symlink extension" as a final sign-off
checklist step specifically for Pi extension work in
`feature_development_workflow`.

**What I found:** Grepped `feature_development_workflow`'s `WORKFLOW.md`
and `orchestrator_agent.md` for "symlink" — zero matches. The sign-off
phase (Phase 8) makes no mention of extension symlinking.

**Resolution:** Filed to `WORKFLOWS/feature_development_workflow/BACKLOG.md`.

### 2026-06-28-subagent-hangs-after-done.md: Not applied

**What the lesson claimed:** After a subagent is aborted, the orchestrator should check if expected output files were actually created on disk before assuming the work failed (pattern observed: subagent completes work and prints DONE but doesn't exit cleanly, Pi aborts it, but files exist).

**What I found:** Searched `orchestrator_agent.md` for any mention of "abort", "check output files", "check if files exist", etc. Found none. The orchestrator's error handling section covers retries and escalation but not the specific "check for artifacts after an abort" pattern.

**Root cause still unaddressed:** This is a workaround for an underlying Pi harness issue (subagents not exiting cleanly), but the workaround itself is valid and reusable until the harness issue is fixed. The orchestrator doesn't currently know to check for output files after an abort.

**Resolution:** Filed to `WORKFLOWS/feature_development_workflow/BACKLOG.md`.

## Rework Rate

4 of 17 tasks required a review iteration beyond the first (23.5% rework rate). Tasks:
- **T7**: Dashboard Component Shell — likely related to API misunderstanding (pre-integration testing)
- **T12**: Tab Switching — reason not clear from review file naming alone
- **T13**: Status Bar — reason not clear from review file naming alone
- **T14**: Orchestrator paraphrased acceptance criteria (lesson 2026-06-27-orchestrator-paraphrasing-error.md directly links to this task) — test-agent and coder-agent both implemented the wrong requirements, requiring full rework in iteration 2

**Finding:** T14's rework was entirely preventable (orchestrator error, now fixed). The other 3 tasks' rework causes are not documented in lessons or review files, so it's unclear whether they were one-time accidents or symptoms of deeper gaps.

## Missing Expected Outputs

Per `orchestrator_agent.md` "Your Outputs" section:
- **Present:** `orchestrator/IMPLEMENTATION_LOG.md`, `orchestrator/ORCHESTRATOR_STATE.md`
- **Missing:** `orchestrator/BUDGET.md`, `orchestrator/METRICS.md`, `orchestrator/ERRORS.md`, `SIGN_OFF.md`, `COMPLETION_REPORT.md`

**Assessment:** This is not an "intentional skip" (e.g. run ended early) — `ORCHESTRATOR_STATE.md` shows "Current Phase: Documentation → Sign-off" and "17/17 tasks complete (100%)", indicating the workflow reached completion. The orchestrator simply didn't produce 5 of its 7 documented outputs.

**Inventory (在庫) gap:** These aren't optional artifacts — they're explicitly listed in the orchestrator's contract. Without them:
- **BUDGET.md**: No record of actual spend vs. budget, can't verify if lesson 2026-06-27-budget-monitoring-failure.md's fix actually worked in practice
- **METRICS.md**: No performance data for this run (task duration, agent retries, etc.)
- **ERRORS.md**: No structured error log
- **SIGN_OFF.md**: No final sign-off checklist/approval record
- **COMPLETION_REPORT.md**: No workflow summary

**Resolution:** This is a Jidoka failure — the orchestrator's own protocol wasn't followed, and there's no built-in check that would have caught it. Filed to `WORKFLOWS/feature_development_workflow/BACKLOG.md`.

---

## TPS Findings

### Overproduction (作りすぎ)
- **T14 rework:** Test-agent wrote 44 tests for the wrong requirements (orchestrator paraphrased acceptance criteria). Coder-agent then implemented those wrong tests. All work discarded in iteration 2. Estimated waste: ~$1-2 + human review time. **Root cause fixed** (orchestrator behavior rule #11 now prohibits paraphrasing).

### Waiting (待ち)
- **Budget depletion during T7:** Lesson 2026-06-27-budget-monitoring-failure.md documents work stopping mid-task due to depleted API credits, requiring human intervention to add credits and restart. No automated warning before depletion. **Root cause fixed** (budget monitoring protocol added to orchestrator).

### Defects (不良)
- **23.5% rework rate:** 4 of 17 tasks required iteration 2. One task (T14) directly attributed to orchestrator error (paraphrasing, now fixed). Other 3 tasks' rework causes not documented, so cannot verify if they were preventable or one-time accidents.
- **Missing integration testing (caught post-merge):** Lesson 2026-06-28-missing-integration-testing.md documents that the extension passed all 1118 unit tests but failed twice when actually loaded by Pi (wrong export format, broken module resolution). Both failures would have been caught by a single integration test. **Root cause fixed** (Phase 6: Integration Testing added to workflow).
- **2 lessons not applied upstream:** web-vs-tui-decision.md and subagent-hangs-after-done.md remain unaddressed. These are live defect risks — the same root causes could recur in a future run.

### Inventory (在庫)
- **5 of 7 orchestrator outputs missing:** See "Missing Expected Outputs" section above. This is the most significant Inventory finding — the orchestrator's own documented contract wasn't fulfilled, and these artifacts would provide valuable data for continuous improvement (budget tracking, metrics, error patterns).

### Motion (動作)
- **Lessons reference each other but not consistently:** Lesson 2026-06-28-subagent-no-exit.md says "Related: 2026-06-28-subagent-hangs-after-done.md (same root cause, earlier observation)" but the earlier lesson doesn't forward-reference the later one. Makes it harder to understand the full narrative when reading lessons chronologically.

---

## Jidoka / Quality-Built-In Findings

- **Orchestrator protocol violation (self-grading):** The orchestrator's own documented outputs (BUDGET.md, METRICS.md, etc.) were not produced, and nothing caught this — the orchestrator self-graded its own completion as successful without verifying all deliverables exist. Per workflow-conventions skill: "Separate the main workflow agent(s) from the validator/linter agent". The orchestrator is both the executor and the validator of its own work, which violated this principle in practice.
- **Recommendation:** Consider adding a workflow-completion-validator agent (separate from the orchestrator) that runs at the end and verifies all expected orchestrator outputs exist before marking the workflow as complete. This would be a true Jidoka check (built-in quality, not self-grading).

## Kaizen / Continuous-Improvement Findings

- **Lessons captured and upstream fixes mostly applied:** 8 of 10 lessons resulted in verified upstream fixes to the feature_development_workflow definition. This is strong Kaizen practice — most captured learnings actually fed back into the process.
- **SELF_IMPROVEMENT_LOG.md actively used:** The workflow's SELF_IMPROVEMENT_LOG.md shows real, dated entries documenting the fixes from this run. Good evidence of continuous improvement.
- **Gap: 2 lessons not applied:** web-vs-tui-decision.md and subagent-hangs-after-done.md remain unaddressed. These should either be applied or explicitly rejected with reasoning (don't let them silently decay in the lessons/ folder).

## Semantic / Correctness Findings

- **T14 orchestrator paraphrasing:** This was a clear semantic failure — the orchestrator summarized requirements instead of directing agents to the source document, causing test-agent and coder-agent to implement the wrong feature. The lesson and fix are both correct. This is covered above in Overproduction/Defects sections.

---

## Fixes applied directly this pass

None (this is a historical instance record, not a live definition to fix).

## BACKLOG.md changes this pass

Filed to `~/WORKSPACE/REPOS/ai_skills/WORKFLOWS/feature_development_workflow/BACKLOG.md`:

- [ ] **Apply lesson 2026-06-27-web-vs-tui-decision.md:** Add "UI Delivery Medium" checklist item to requirements-agent or scientific-method skill to probe terminal vs browser vs desktop app early. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Apply lesson 2026-06-28-subagent-hangs-after-done.md:** Add to orchestrator error handling: after a subagent abort, check if expected output files exist on disk before assuming failure. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Add workflow-completion-validator agent:** Separate agent (not the orchestrator) that verifies all expected orchestrator outputs exist before marking workflow complete (Jidoka — built-in quality, not self-grading). (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Investigate T7, T12, T13 rework causes:** 3 tasks required iteration 2 but root causes not documented in lessons or review files. Review iteration-2 review files to determine if these were preventable (design/requirements gaps) or one-time accidents. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)

## SELF_IMPROVEMENT_LOG.md entry

Not applicable — this is an instance audit, not a fix to the workflow_monitor_workflow definition itself. The feature_development_workflow's SELF_IMPROVEMENT_LOG.md already contains entries for the lessons that were applied.
