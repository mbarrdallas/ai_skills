# Agent Self-Improvement Log

Shared, append-only, chronological log across all public agents in
`AGENTS/` — one entry per agent-definition change made *because* a flaw,
gap, ambiguity, or inefficiency was found in it (not routine feature
additions; see `workflow-conventions` skill's "Self-improvement logging"
for what counts). Same entry structure as the existing per-skill
`IMPROVEMENT_LOG.md` convention (see e.g.
`skills/coding-conventions/IMPROVEMENT_LOG.md`) — this just extends that
mechanism to agents.

Workflow-private agents (`WORKFLOWS/<workflow>/PRIVATE/AGENTS/`) log to
their owning workflow's own `SELF_IMPROVEMENT_LOG.md` instead of here.

Format:
```markdown
## YYYY-MM-DD: <agent-name> - <short title>

**Issue:** What was wrong.
**Learning:** What this revealed more generally.
**Improvement:** What actually changed, and where.
**Related:** Links/references.
```

---

## 2026-07-03: research-agent - spawn interface, wiki-registry edge cases, and findings-format contract made explicit

**Issue:** A grilling critique (design-agent, spawned via the `subagent`
tool) found the agent's spawn relationship to `knowledge-ingest-agent` was
underspecified in several ways: no concrete task-text template for the
Query/Ingest spawns (the `subagent` tool has no formal "operation"
parameter — the task text sent IS the interface), the `trigger-llm-wiki-workflow`
skill was being applied to the normal ingest path where it was actually
redundant, no handling for an empty/missing/stale "Known LLM Wikis"
registry, no format contract for how pre-synthesized research findings
should be handed to `knowledge-ingest-agent` (which normally expects a raw
source to summarize, not already-extracted content), no criteria for
whether findings are even worth ingesting, and duplicate contradiction-
checking responsibility overlapping with `knowledge-ingest-agent`.

**Learning:** When one agent spawns another via a free-text task prompt
(not a typed API), the spawning agent's own definition must spell out the
exact task text to send for each distinct operation — "spawn X to do Y" is
not enough on its own; a future instance has to guess the wording. Same
principle for any handoff format between two agents' inputs/outputs.

**Improvement:** `AGENTS/research_agent.md` — added explicit spawn-prompt
templates for both Query and Ingest, narrowed `trigger-llm-wiki-workflow`'s
role to Case-B-only (new wiki scaffolding), added registry validation
steps (empty/missing/stale), added a findings-format contract (cited
markdown, not raw source), added explicit "worth preserving" criteria and
an early-exit path when existing coverage is already sufficient, and
clarified the topical-overlap-only scope of research-agent's own
contradiction check (fine-grained claim checking stays with
`knowledge-ingest-agent`).

**Related:** `WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md` (the
corresponding workflow-level entry, same incident).

## 2026-07-03: knowledge-ingest-agent - clarified skill-path resolution and accepted pre-synthesized findings as an input type

**Issue:** Same grilling pass as above flagged that `wiki-maintenance`
skill's documented path ("relative to this file", or "from the ai_skills
repo root") doesn't obviously also resolve when a *different* agent
(`research-agent`) spawns `knowledge-ingest-agent` with its working
directory set to a consuming wiki repo, not the `ai_skills` repo. Also
flagged: `knowledge-ingest-agent`'s documented input types (file path, URL,
pasted text) don't explicitly cover pre-synthesized research findings,
which are semantically different from a raw source to summarize.

**Improvement:** `AGENTS/knowledge_ingest_agent.md` — clarified the
`wiki-maintenance` skill path resolves correctly from either the
`ai_skills` repo root *or* a consuming wiki repo's own root (both are valid
given the `WORKFLOWS/llm_wiki_workflow` symlink convention), with a `pwd`
check as a fallback if ambiguous. Added pre-synthesized findings as an
explicit input type: treat as already-extracted content to fold into
existing pages directly, rather than a raw document to summarize from
scratch.

**Related:** `WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md`.
