# AGENTS.md — Wiki Schema & Maintainer Instructions

This file tells you (the LLM agent) how this "second brain" is structured and
how to operate on it. This repo follows the **LLM Wiki Workflow**, defined at
`EXTERNALS/ai_skills/WORKFLOWS/llm_wiki_workflow/` (symlinked at
`WORKFLOWS/llm_wiki_workflow`), itself an implementation of Andrej
Karpathy's [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Read `WORKFLOWS/llm_wiki_workflow/WORKFLOW.md` and the `wiki-maintenance`
skill it references for the general ingest/query/lint procedure. **This file
defines what's specific to this repo**: domains, page taxonomy, and
frontmatter schema. Where this file and the generic workflow/skill
disagree, this file wins.

## Domains

| Domain slug | Subject |
|-------------|---------|
| `<slug>`    | <description> |

## Page taxonomy (per domain)

- `sources/` — one page per ingested source
- `concepts/` — durable concept pages
- `entities/` — (if applicable)
- `synthesis/` — (if applicable)

## Frontmatter

See `WORKFLOWS/llm_wiki_workflow/templates/` for starter page templates.
Standard fields: `title`, `domain`, `type`, `created`, `updated`, `tags`,
`sources`.

## Indexing and logging

- `wiki/index.md` — root catalog linking to each domain index.
- `wiki/<domain>/index.md` — per-domain catalog.
- `wiki/log.md` — shared, chronological, append-only log across all domains.

## Git workflow

<State this repo's push/privacy conventions here — many second-brain repos
are personal and should not be pushed without explicit instruction.>

## Obsidian

<State whether this repo is set up as an Obsidian vault.>
