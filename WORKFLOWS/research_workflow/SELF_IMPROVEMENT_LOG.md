# Self-Improvement Log - Research Workflow

Append-only, chronological log of self-improvements to this workflow's own
definition (`WORKFLOW.md`, `FOLDER_STRUCTURE.md`, `BACKLOG.md`, and the
agents/skills it owns) — see `workflow-conventions` skill's
"Self-improvement logging" for the entry format and what counts as an
entry vs. routine work.

---

## 2026-07-03: Grilling critique resolved a full round of scoping/handoff gaps

**Issue:** A design-agent grilling pass (two rounds, via the `subagent`
tool) on the freshly-built workflow found 12 substantive issues spanning
`research_agent.md`, `knowledge_ingest_agent.md`, `WORKFLOW.md`,
`FOLDER_STRUCTURE.md`, and `BACKLOG.md`: an undefined spawn interface to
`knowledge-ingest-agent`, the `trigger-llm-wiki-workflow` skill being
applied where it was actually redundant, no fast path for research
requests that already pre-specify evidence type/depth, missing wiki-
registry edge cases (empty, malformed, or stale relative to the target
wiki's real domain list), no findings-format contract with
`knowledge-ingest-agent`, no criteria for whether findings are worth
ingesting at all, no early-exit when existing wiki coverage is already
sufficient, duplicate contradiction-checking responsibility between the
two agents, ambiguous symlink ownership in `FOLDER_STRUCTURE.md`, and a
cosmetic diagram inaccuracy in `WORKFLOW.md`.

**Learning:** A brand-new workflow, even one built with reasonable care,
benefits from an adversarial pass before being considered done — several
of these gaps (the spawn-prompt interface especially) are the kind of
thing that only becomes obvious when someone tries to imagine actually
executing the instructions literally, not when just reading them for
plausibility.

**Improvement:** All 12 issues resolved — see
`AGENTS/SELF_IMPROVEMENT_LOG.md`'s two entries (research-agent,
knowledge-ingest-agent) for the specific changes. `WORKFLOW.md` and
`FOLDER_STRUCTURE.md` updated to match. `BACKLOG.md`'s registry-staleness
item closed (replaced with a narrower follow-up: automating the staleness
*check* itself, since the immediate behavioral fix — always read the
target wiki's real `AGENTS.md` — is now in place). Second grilling round
confirmed all resolved, with one new cosmetic issue found and fixed in the
same pass.

**Related:** Investigation that unblocked the `subagent` tool itself
(`pi-agent-dashboard` commit `bc315a19`, "unref all timers so one-shot
sessions can exit") — the first two grilling attempts aborted before this
fix; the third attempt (post-fix) and the subsequent full grilling pass
worked correctly.
