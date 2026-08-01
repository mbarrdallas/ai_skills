# Backlog - Research Workflow

Tasks and enhancements to implement later for this workflow. Not to be
confused with a consuming wiki repo's own root `BACKLOG.md` (wiki-content
findings), or `llm_wiki_workflow/BACKLOG.md` (that workflow's own future
work) — this file is specifically about the research workflow itself.

---

## Future Enhancements

- [ ] A `RESEARCH_SCOPE_TEMPLATE.md` for writing down the agreed objective/
  evidence-type/depth from the Scope step, for research efforts substantial
  enough to warrant a written record before gathering data (today this is
  handled conversationally, which is fine for lightweight requests but may
  not scale to larger efforts).
- [ ] Guidance for when a research effort is big enough to warrant
  upgrading from this inline/single-agent shape to an async, orchestrated
  shape (parallel research threads, similar to `feature_development_workflow`'s
  worktree-based parallelism) — not needed yet at current scale.
- [x] Decide how `research-agent` should behave when the "Known LLM Wikis"
  registry (`~/WORKSPACE/AGENTS.md`) is stale relative to a wiki's own
  `AGENTS.md` domain list. (done: `research_agent.md`'s "Deciding which wiki
  to target" step 4 now mandates always reading the target wiki's actual
  `AGENTS.md` domain list before proceeding, never trusting the registry
  cache alone - found via grilling critique, 2026-07-03.)
- [ ] Automate the registry staleness check itself (e.g. a periodic script
  that diffs `~/WORKSPACE/AGENTS.md`'s "Known LLM Wikis" table against each
  listed wiki's actual `AGENTS.md` domain list and flags drift) - the fix
  above is a per-invocation behavioral safeguard, not a proactive check.
- [ ] Consider a public `trigger-research-workflow` routing skill. This
  workflow currently has no trigger skill, so "research X" / "find out about
  X" / "look into X" don't auto-route to it the way
  `trigger-llm-wiki-workflow` and `trigger-workflow-monitor` route to their
  workflows. Note `research-agent` already carries
  `trigger-llm-wiki-workflow`, but that routes findings *into* a wiki - a
  different concern from routing an incoming request *into* research. If
  added, follow `trigger-feature-development-workflow`'s pattern of
  documenting explicit *non*-triggers (a quick factual lookup shouldn't
  spin up a scoped research effort). (found via: adding
  `trigger-feature-development-workflow`, 2026-08-01)
