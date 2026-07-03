# Research Workflow

Scope and conduct a research effort, then route any durable findings into
the appropriate personal LLM wiki ("second brain") — rather than answering
once in conversation and letting the work evaporate. Runs **inline and
human-in-the-loop**, in a single conversation, much like `llm_wiki_workflow`
— there's no orchestrator, no worktrees, no async multi-agent pipeline.

## Why this exists

Ad hoc research (open a browser, look some things up, answer the question)
has two recurring failures this workflow addresses directly:
1. **Re-deriving what's already known.** Without checking existing
   knowledge first, research effort gets spent re-answering things a prior
   research pass or ingested source already covered.
2. **Findings evaporate.** A good answer given once in conversation is
   gone the next session unless it's deliberately preserved somewhere
   durable.

## Diagram

```
Human: "research X"
        │
        ▼
┌───────────────────┐
│  research-agent    │
├────────────────────┤
│ 1. Scope           │  research-methodology + scientific-method skills
│    (objective,     │  - falsifiable objective statement
│     evidence type,  │  - metrics vs. stories vs. subjective opinions
│     depth)          │  - depth vs. time/budget/subject-access
│                     │
│ 2. Pick target wiki │  ~/WORKSPACE/AGENTS.md "Known LLM Wikis" registry,
│                     │  unless explicitly instructed which wiki to use
│                     │
│ 3. Check existing   │──spawn──▶ knowledge-ingest-agent (Query op)
│    coverage         │
│                     │
│ 4. Gather new data  │  fills the gap Step 3 didn't already cover
│    (the actual      │
│     research work)  │
│                     │
│ 5. Ingest findings  │──spawn──▶ knowledge-ingest-agent (Ingest op)
└────────────────────┘         via trigger-llm-wiki-workflow skill
```

## Agents & Skills

| Role | Agent | Skills used | Spawns |
|------|-------|-------------|--------|
| Research | `research-agent` | `research-methodology`, `scientific-method`, `trigger-llm-wiki-workflow` | `knowledge-ingest-agent` |
| Wiki query/ingest | `knowledge-ingest-agent` | `wiki-maintenance` (private, workflow-scoped to `llm_wiki_workflow`) | none |

Only one new agent role exists for this workflow (`research-agent`) — the
wiki-facing half of the work is deliberately **not** reimplemented here; it
delegates straight to `llm_wiki_workflow`'s existing `knowledge-ingest-agent`
rather than duplicating ingest/query mechanics.

There is no separate lint/review role in this workflow — wiki health
checking is still `knowledge-lint-agent`'s job (`llm_wiki_workflow`), run
independently of any specific research effort, not per-research.

## Operations

### Scope

`research-agent` clarifies the objective, evidence type, and depth with the
human before anything else happens. See `research-methodology` skill for
the full procedure (Steps 1-3). This step ends with an explicit, agreed
scope statement — not an assumption.

### Target wiki selection

`research-agent` determines which wiki findings should ultimately go into:
1. Explicit instruction (from the human, or whichever agent/workflow
   triggered this research effort) always wins.
2. Otherwise, `research-agent` consults `~/WORKSPACE/AGENTS.md`'s "Known
   LLM Wikis" registry and matches the objective's topic against each
   wiki's listed domains.
3. Ambiguous or no match → ask the human (don't guess, and don't force a
   fit into the wrong domain).

Currently only one wiki is registered (`mariamas_brain`), but this workflow
is designed to generalize as more wikis get added to that registry — it
does not hardcode a single target.

### Check existing coverage

Before gathering anything new, `research-agent` spawns
`knowledge-ingest-agent` to run its **Query** operation against the target
wiki for the scoped objective. Findings from this step are reported back to
the human explicitly as "already known" vs. left as the genuine gap to
research next.

### Gather new data

The actual research legwork, calibrated to the evidence type and depth
agreed in Scope. Genuinely open-ended — no fixed procedure beyond staying
disciplined to the agreed scope (see `research-methodology`'s
anti-patterns for common ways this drifts).

### Ingest findings

For findings worth preserving durably, `research-agent` applies the
`trigger-llm-wiki-workflow` skill and spawns `knowledge-ingest-agent` to run
its **Ingest** operation against the target wiki, exactly as it would for
any other new source. If nothing fits any existing registered wiki, that's
surfaced to the human explicitly (with the option to scaffold a new one via
`trigger-llm-wiki-workflow` Case B) rather than silently dropped.

## Getting Started

Just ask: *"research \<topic/question>"* or *"find out whether \<X>"*. If
you already know which wiki the findings should land in, say so up front
("...and put findings in \<wiki>") — otherwise `research-agent` will work
it out from the topic, or ask if it's ambiguous.

## See also

- `research-methodology` skill — the scoping procedure in full detail.
- `llm_wiki_workflow` — the wiki-facing half this workflow delegates to;
  read its `WORKFLOW.md` for ingest/query mechanics.
- `workflow-conventions` skill — structural standard this workflow follows.
