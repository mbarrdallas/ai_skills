# LLM Wiki Workflow

## Overview

A workflow for building and maintaining a personal "second brain" — a
persistent, LLM-curated markdown wiki that sits between a human and their raw
source documents. Unlike RAG (retrieve chunks, re-derive an answer every
query, nothing accumulates), this workflow has the LLM **incrementally build
and maintain a compounding wiki**: source summaries, entity/concept pages,
syntheses, cross-references, and an evolving picture that gets richer with
every source ingested and every question asked.

This workflow is **domain-agnostic** and repo-agnostic. It can be applied to
any topic — personal knowledge, a research area, a business, a book, course
notes, due diligence, trip planning, hobby deep-dives. Each consuming repo
defines its own specifics (domains, page taxonomy, frontmatter schema) in its
own `AGENTS.md` at the repo root; this workflow supplies the general
procedure and the agent/skill that execute it.

**Original source of this pattern:** Andrej Karpathy's
["LLM Wiki" gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
(2026). This workflow is a concrete instantiation of the pattern he
describes — his gist is the design doc; this directory is the reusable
implementation of it.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      LLM WIKI WORKFLOW                           │
└─────────────────────────────────────────────────────────────────┘

  raw/<domain>/<source>          Human question              (periodic)
         │                             │                           │
         ▼                             ▼                           ▼
  ┌─────────────┐              ┌─────────────┐            ┌─────────────┐
  │   INGEST    │              │    QUERY    │            │    LINT     │
  └──────┬──────┘              └──────┬──────┘            └──────┬──────┘
         │                             │                           │
  1. Read source fully           1. Read domain index(es)    1. Enumerate pages
  2. Discuss takeaways           2. Drill into pages          & cross-refs
     with human first            3. Synthesize answer,       2. Check for:
  3. Write/update a                 cited                       contradictions
     sources/ page                4. Offer to file back          stale claims
  4. Update entity/                 novel synthesis as           orphan pages
     concept/synthesis               a new page                  missing pages
     pages; flag                  5. Log non-trivial query        missing links
     contradictions                                            3. Fix safe items,
     explicitly                                                    flag the rest
  5. Promote durable                                          4. Log findings
     ideas to new pages
  6. Update domain index
  7. Log entry
  8. Commit
         │                             │                           │
         └─────────────────────────────┴───────────────────────────┘
                                        │
                                        ▼
                          wiki/ keeps compounding —
                     richer with every ingest and query
```

## Agent

This workflow is executed by a single, lightweight, **inline** agent — not an
async multi-agent pipeline. Ingest/query/lint are meant to happen in one
conversation with the human staying involved (per the pattern's own
recommendation: "personally I prefer to ingest sources one at a time and
stay involved").

| Agent | Role | Skills |
|-------|------|--------|
| Knowledge Ingest Agent | Ingest sources, answer queries, lint the wiki | wiki-maintenance |

See `agents/knowledge_ingest_agent.md` (symlink to
`../../../AGENTS/knowledge_ingest_agent.md`).

## Skill Required

| Skill | Used By | Purpose |
|-------|---------|---------|
| wiki-maintenance | Knowledge Ingest Agent | Domain-agnostic ingest/query/lint procedure, frontmatter/index/log conventions |

## Repo Requirements

A repo using this workflow must have:

```
<repo>/
├── AGENTS.md          # Repo-specific schema: domains, page taxonomy,
│                       #   frontmatter fields. References this workflow
│                       #   as the kickoff point for ingest/query/lint.
├── raw/<domain>/       # Immutable source documents, never edited
└── wiki/
    ├── index.md        # Root catalog (or wiki/<domain>/index.md per domain)
    ├── log.md          # Chronological, append-only, greppable log
    └── <domain>/       # Per-domain wiki pages (sources, concepts, entities, ...)
```

See the `wiki-maintenance` skill for the full frontmatter/index/log
conventions, and `templates/` in this directory for starter page templates.

**Non-text sources (PDF, docx, etc.):** convert to markdown with
[`markitdown`](https://github.com/microsoft/markitdown) and discard the
original — `raw/` should stay uniformly plain-text/markdown. See the
`wiki-maintenance` skill's "Non-text source formats" section for the full
convention.

## Operations

### Ingest
Trigger: human drops/points to a new source and asks for it to be added to
the wiki.
Output: a `sources/` page, updated entity/concept/synthesis pages, updated
domain index, a `wiki/log.md` entry, a git commit.

### Query
Trigger: human asks a question the wiki should be able to answer.
Output: a cited, synthesized answer; optionally a new wiki page if the
answer is novel synthesis; a `wiki/log.md` entry for non-trivial queries.

### Lint
Trigger: human asks for a health-check, or a domain has grown noticeably.
Output: a findings report, direct fixes for safe issues, a `wiki/log.md`
entry.

Full step-by-step procedure for all three operations lives in the
`wiki-maintenance` skill (loaded by the agent) — this file describes the
workflow shape; the skill describes the mechanics.

## Getting Started (for a new repo)

1. Create `raw/<domain>/` and `wiki/<domain>/` folders for each domain.
2. Write the repo's `AGENTS.md`, referencing this workflow
   (`ai_skills/WORKFLOWS/llm_wiki_workflow`) as the kickoff point, and
   defining: domain list, page taxonomy per domain, frontmatter schema.
3. Create `wiki/index.md` and `wiki/log.md` starter files.
4. (Optional) Set up an Obsidian vault at the repo root for graph
   view/backlinks.
5. Start ingesting: point the agent at a source and go.

## Consuming This Workflow From Another Repo

Recommended pattern (used by `mariamas_brain`):

```
<repo>/
├── EXTERNALS/
│   └── ai_skills/          # git submodule -> this ai_skills repo
└── WORKFLOWS/
    └── llm_wiki_workflow -> ../EXTERNALS/ai_skills/WORKFLOWS/llm_wiki_workflow
```

This pins the exact version of the workflow/skill/agent in the consuming
repo's git history (via the submodule commit) while keeping a single shared,
editable source of truth in `ai_skills`.

## Lessons Learned

Capture lessons in this workflow's own notes (or via the `lesson-capture`
skill) when the generic procedure doesn't fit a domain well — that's a
signal either the repo's `AGENTS.md` needs a repo-specific override, or this
shared workflow/skill needs to evolve.
