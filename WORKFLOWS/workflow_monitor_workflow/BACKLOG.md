# Backlog - Workflow Monitor Workflow

Tasks and enhancements to implement later for this workflow itself (not to
be confused with an *audited* workflow's own `BACKLOG.md`, which is where
this workflow files its actual audit findings).

---

## Future Enhancements

- [ ] Decide whether `workflow-monitor-agent` should also be able to audit
  a *consuming* repo's own workflow-shaped content (not just `ai_skills`'
  own `WORKFLOWS/`), if that pattern ever emerges elsewhere.
- [ ] Consider whether audit cadence should ever become scheduled/automatic
  rather than purely on-demand, once there are enough workflows that manual
  triggering risks some going unaudited for a long time.
- [ ] Revisit whether a dedicated `workflow-audit` skill becomes justified
  if a second agent ever needs the same TPS-lens checklist (currently
  inlined in `workflow_monitor_agent.md` per the design review's
  recommendation — see `SELF_IMPROVEMENT_LOG.md`).

## Audit Findings (from self-audit 2026-07-03)

- [x] Consider rephrasing the Jidoka bullet about Tier-0 orchestrators (in
  `workflow_monitor_agent.md`) to make it clearer that both checks are
  needed (frontmatter listing AND applying in practice). (done: rephrased
  to explicit "Check **both**: ... **and** ..." construction. See
  `WORKFLOWS/workflow_monitor_workflow/audits/2026-07-03_workflow-monitor-workflow.md`
  for the original finding.)
