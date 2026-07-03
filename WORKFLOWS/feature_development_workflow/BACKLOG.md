# Backlog - Feature Development Workflow

Tasks and enhancements to implement later for this workflow.

---

## Future Enhancements

- [ ] **Apply lesson 2026-06-27-web-vs-tui-decision.md:** Add "UI Delivery Medium" checklist item to requirements-agent or scientific-method skill to probe terminal vs browser vs desktop app early. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Apply lesson 2026-06-28-subagent-hangs-after-done.md:** Add to orchestrator error handling: after a subagent abort, check if expected output files exist on disk before assuming failure. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Add workflow-completion-validator agent:** Separate agent (not the orchestrator) that verifies all expected orchestrator outputs exist before marking workflow complete (Jidoka — built-in quality, not self-grading). (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Investigate T7, T12, T13 rework causes:** 3 tasks required iteration 2 but root causes not documented in lessons or review files. Review iteration-2 review files to determine if these were preventable (design/requirements gaps) or one-time accidents. (Filed 2026-07-03 by workflow-monitor-agent audit of stats_dashboard_tui instance)
- [ ] **Apply lesson "Extension Must Be Symlinked After Delivery"** (bundled as the 2nd lesson inside `2026-06-28-subagent-no-exit.md` in the `stats_dashboard_tui` instance - found via human spot-check of the original audit, which missed it entirely): add a "Symlink extension" step to the Phase 8 sign-off checklist specifically for Pi extension deliverables. (Filed 2026-07-03, corrected audit of stats_dashboard_tui instance)
