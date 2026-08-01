# Backlog - Feature Development Workflow

Tasks and enhancements to implement later for this workflow.

---

## Future Enhancements

- [ ] **Apply lesson 2026-06-27-web-vs-tui-decision.md:** Add "UI Delivery Medium" checklist item to requirements-agent or scientific-method skill to probe terminal vs browser vs desktop app early. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Apply lesson 2026-06-28-subagent-hangs-after-done.md:** Add to orchestrator error handling: after a subagent abort, check if expected output files exist on disk before assuming failure. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Add workflow-completion-validator agent:** Separate agent (not the orchestrator) that verifies all expected orchestrator outputs exist before marking workflow complete (Jidoka — built-in quality, not self-grading). (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Investigate T7, T12, T13 rework causes:** 3 tasks required iteration 2 but root causes not documented in lessons or review files. Review iteration-2 review files to determine if these were preventable (design/requirements gaps) or one-time accidents. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Apply lesson "Extension Must Be Symlinked After Delivery"** (bundled as the 2nd lesson inside `2026-06-28-subagent-no-exit.md` in the `stats_dashboard_tui` instance - found via human spot-check of the original audit, which missed it entirely): add a "Symlink extension" step to the Phase 8 sign-off checklist specifically for Pi extension deliverables. (Filed 2026-07-03, corrected audit of stats_dashboard_tui instance)

## Filed 2026-08-01 (from the wiki_tool run)

- [ ] **Resolve the 2 persistent `orchestrator_agent.md` validator warnings.**
  `validate_agent.sh` has warned on both for a while and they are now the only
  warnings left in the repo (they surface 3x because the file is reachable via
  `PRIVATE/AGENTS/` and the `agents/` symlink):
  - filename `orchestrator_agent.md` doesn't match the snake_case of its
    frontmatter `name:` (`feature-development-orchestrator`). Either rename the
    file or rename the agent - note `install_agents.sh` already links it under
    the frontmatter name, so the filename is the odd one out.
  - no `## Completion` section, so it has no documented status-code contract
    even though every other agent does and the orchestrator is what interprets
    those codes from the agents it spawns.

- [ ] **reviewer-agent should be required to check for unreachable/dead code.**
  In the wiki_tool run, `compute_index_repairs` opened with a blanket
  `if severity == WARNING: continue` that made a whole repair branch below it
  unreachable. reviewer-agent passed it: its D4 check used
  `inspect.getsource()`, which succeeds happily on code that never executes.
  115 tests also passed. See `lessons/index-regeneration-data-loss.md` in the
  run instance.

- [ ] **test-agent should be required to write a positive test alongside any
  "zero findings" assertion.** The run produced
  `test_update_dry_run_zero_changes`, asserting 0 repairs against the live
  wiki - which passed only BECAUSE the repair path was dead code. A
  "0 findings" assertion cannot distinguish "clean" from "detection is broken",
  and this one would have actively resisted the fix. Pair every such assertion
  with a known-bad fixture proving the detector fires.

- [ ] **test-agent should test destructive/mutating code paths against content
  that has something to lose.** All repair tests used synthetic fixtures with
  empty summary fields, so "preserves the human-written summary" was not even
  expressible - and the tool wiped real curated summaries on its first live
  invocation.

- [ ] **Add a round-trip property test convention for tools that both write and
  validate a format.** wiki_tool's `update` wrote a log entry that its own
  `validate` rejected as malformed. "Everything this tool emits must pass its
  own validator" is a cheap, high-value invariant that would have caught it.

- [ ] **Audit this run instance with `workflow_monitor_workflow`.** Three
  defects escaped an autonomous run that self-reported DONE with 115 passing
  tests, and all were found only by human-directed verification afterwards.
  That is exactly the "were the captured lessons actually fixed upstream?"
  question that workflow proposes to answer. Instance:
  `~/WORKSPACE/active_workflows/wiki_tool/`.
