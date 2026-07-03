---
name: wiki-maintenance
description: Maintain a persistent, LLM-curated markdown knowledge wiki (a "second brain") built from a curated collection of raw source documents — ingesting new sources, answering queries against accumulated knowledge, and periodically linting the wiki for health. Use when a repo has a raw/ + wiki/ layout with a domain schema in AGENTS.md, when the user wants to "add this to the wiki", "ingest a source", "update my second brain", "query the wiki", or "lint/health-check the wiki". Based on the LLM Wiki pattern (persistent, compounding wiki vs. query-time RAG).
---

# Wiki Maintenance

Procedural knowledge for maintaining an **LLM Wiki**: a persistent,
interlinked collection of markdown pages that an LLM builds and keeps
current from a curated set of raw source documents — as opposed to RAG,
which re-derives an answer from raw chunks on every query with no
accumulation. See
[Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
for the original pattern description.

This skill is **domain-agnostic**. Every consuming repo defines its own
specifics (domains, page taxonomy, exact frontmatter fields) in its own
`AGENTS.md` at the repo root. Always read that repo-specific `AGENTS.md`
first — it overrides or extends anything generic described here.

## Three layers (expected in any repo using this skill)

1. **`raw/`** — source documents. Never edited or deleted once ingested. See
   "Non-text source formats" below for the convention on PDFs/docx/etc.
2. **`wiki/`** — LLM-owned markdown pages: source summaries, entity/concept
   pages, syntheses, an index, a log. The human reads this; the LLM writes
   it.
3. **`AGENTS.md`** (repo root) — the schema: domains, page taxonomy,
   frontmatter fields, any repo-specific conventions.

## Standard frontmatter (generic shape — exact enum values come from the repo's AGENTS.md)

```yaml
---
title: <page title>
domain: <repo-defined domain slug>
type: source | entity | concept | synthesis | index | <repo-defined types>
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [ ... ]
sources: [ raw/<domain>/<file>, ... ]
---
```

Update `updated:` whenever a page is materially changed.

## Navigation files

- **`wiki/<domain>/index.md`** (or `wiki/index.md` if single-domain) —
  content-oriented catalog: every page listed with a link, one-line summary,
  and type. Updated on every ingest. Read this first when answering a query
  — drill into specific pages after, rather than searching raw sources from
  scratch.
- **`wiki/log.md`** — chronological, append-only. Every entry uses a
  consistent, greppable prefix:
  ```
  ## [YYYY-MM-DD] ingest | <domain> | <Source Title>
  ## [YYYY-MM-DD] query  | <domain> | <short question>
  ## [YYYY-MM-DD] lint   | <domain or "all"> | <short summary of findings>
  ```
  `grep "^## \[" wiki/log.md | tail -5` shows the last 5 entries.

## Non-text source formats (PDF, docx, etc.)

Sources that aren't already plain text/markdown must be converted before
they can be read and ingested. Standard tool: **[`markitdown`](https://github.com/microsoft/markitdown)**
(Microsoft's file-to-markdown CLI/library — handles PDF, docx, pptx, xlsx,
images, audio, HTML, and more).

**Convention: always convert to markdown and discard the original.**

```bash
markitdown "<original file>" -o raw/<domain>/<slug>.md
```

- Save the markdown output directly into `raw/<domain>/` under a
  kebab-case slug of the original filename — this *is* the raw source going
  forward, not a derived companion file.
- Discard the original binary (PDF/docx/etc.) once the markdown conversion
  is confirmed readable and reasonably faithful to the source. Do not keep
  both.
- Note the conversion in the source page (which tool, and that the original
  was discarded) so provenance is clear to future readers.
- If `markitdown` produces a garbled or clearly incomplete conversion (e.g.
  a scanned/image-only PDF with no extractable text layer), flag this to
  the human rather than ingesting a broken conversion — OCR or another tool
  may be needed first.

This keeps `raw/` uniformly plain-text/markdown, which is what makes it
directly readable by any future agent session without re-running extraction
tooling or depending on PDF/docx libraries being installed.

## Operation: Ingest

1. A new file lands in `raw/<domain>/` (or is fetched/pasted in by the
   agent at the human's direction).
2. Read it fully. **Discuss key takeaways with the human before writing
   anything** — default posture is one source at a time, staying involved,
   not silently batch-processing. Confirm the takeaways list before
   proceeding to write pages.
3. Write/update a `sources/` page summarizing it (or the repo's equivalent
   location — check `AGENTS.md`).
4. Update relevant entity/concept/synthesis pages: note where new
   information confirms, extends, or **contradicts** existing pages.
   Contradictions must be surfaced explicitly in the page text, never
   silently overwritten.
5. Consider whether any point deserves a new standalone concept/entity page
   (durable, reusable idea) vs. staying folded into the source page
   (one-off detail). Promote generously — durable concept pages are what
   make the wiki compound.
6. Update the relevant domain index.
7. Append an `ingest` entry to the log.
8. Commit (see Git workflow section).

A single source touching 10-15 wiki pages is expected, not excessive.

## Operation: Query

1. Read the relevant domain index(es) first to find candidate pages.
2. Drill into the specific pages found; read them fully before answering.
3. Synthesize an answer with citations back to wiki pages (and raw sources
   where useful).
4. If the answer is itself novel synthesis (a comparison, an analysis, a
   connection not already captured) — not just a restatement of an existing
   page — offer to file it back into the wiki as a new page so explorations
   compound. Don't file back answers that just restate an existing page.
5. Append a `query` entry to the log for anything non-trivial.

## Operation: Lint

Run periodically (when asked, or when a domain has grown noticeably):

1. Enumerate all wiki pages and all `[[wikilink]]`-style cross-references
   between them.
2. Check for:
   - **Contradictions** between pages (same fact stated differently).
   - **Stale claims** superseded by a newer source but not yet updated.
   - **Orphan pages** — no inbound links from any other page.
   - **One-directional links** — page A links to B, but B doesn't link back
     where a reciprocal link would help navigation (not always required,
     but worth checking for closely related concept pages).
   - **Important concepts mentioned but lacking their own page.**
   - **Data gaps** that a web search or a new source could fill.
3. Fix what's safe to fix directly (e.g. adding a missing reciprocal link).
   Flag the rest to the human rather than guessing.
4. Append a `lint` entry to the log summarizing findings and fixes.

## Git workflow

- Auto-commit after every ingest, lint pass, or major wiki update, using
  scoped, greppable commit messages:
  - `ingest(<domain>): <source title>`
  - `lint(<domain>): wiki health check`
  - `query(<domain>): <short topic>` (only if it produced a new filed page)
- Respect the repo's own push/privacy conventions (check `AGENTS.md` — many
  second-brain repos are personal/local and should not be pushed without
  explicit instruction, especially if they contain sensitive domains like
  finance).

## Tips

- Use `[[wikilinks]]` for cross-references if the repo is set up as an
  Obsidian vault (check `AGENTS.md`/`.obsidian/` for confirmation).
- At small-to-moderate scale (~100 sources / hundreds of pages), the domain
  index is sufficient navigation — no embedding-based search needed. Revisit
  with a real search tool (e.g. [qmd](https://github.com/tobi/qmd)) only once
  index files stop scaling.
- The wiki is just a git repo of markdown — lean on `git log`/`git diff` to
  see how the wiki has evolved, not just `log.md`.
