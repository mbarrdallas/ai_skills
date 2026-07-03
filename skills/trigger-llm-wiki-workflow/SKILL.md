---
name: trigger-llm-wiki-workflow
description: Detect when the user wants to build or maintain a personal "second brain" / LLM wiki (a persistent, LLM-curated, compounding markdown knowledge base built from ingested sources — distinct from query-time RAG) and route to the llm_wiki_workflow. Use when the user says things like "build me a second brain", "I want an LLM wiki", "help me build a knowledge base like Karpathy's LLM wiki pattern", "ingest this into my wiki", "set up a research/knowledge wiki", "add this to my wiki", mentions Karpathy's LLM Wiki gist, or when a repo already has a raw/ + wiki/ + AGENTS.md layout following this pattern and the user wants to ingest/query/lint it.
---

# Trigger: LLM Wiki Workflow

A lightweight **routing skill**. Its only job is to recognize the "LLM Wiki"
/ "second brain" pattern in conversation and point to the full workflow
definition — it does not itself carry the ingest/query/lint procedure. That
procedure lives in a workflow-private skill
(`WORKFLOWS/llm_wiki_workflow/PRIVATE/SKILLS/wiki-maintenance/`) that is
intentionally *not* globally auto-triggering, because it's only meaningful
in the context of a repo already set up for this workflow. This skill exists
so the *pattern itself* stays publicly discoverable even though its
mechanics are workflow-scoped.

## When this triggers

- The user describes wanting a persistent, compounding personal knowledge
  base — not a one-off Q&A, not a generic RAG upload-and-ask flow.
- The user references Karpathy's
  [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
  or describes its shape (raw sources → LLM-maintained wiki → schema file).
- The user is in a repo that already has `raw/` + `wiki/` + an `AGENTS.md`
  referencing this workflow, and wants to ingest a source, ask a question
  against the wiki, or run a health-check/lint.
- The user wants to add this pattern to a *new* repo ("set up a second
  brain for X").

## What to do when triggered

**Case A — repo already set up for `llm_wiki_workflow`** (has `AGENTS.md`
referencing it, `WORKFLOWS/llm_wiki_workflow` symlink, `raw/` + `wiki/`
folders):
1. Read `WORKFLOWS/llm_wiki_workflow/WORKFLOW.md`.
2. Read the private `wiki-maintenance` skill at
   `WORKFLOWS/llm_wiki_workflow/PRIVATE/SKILLS/wiki-maintenance/SKILL.md`
   for the ingest/query/lint mechanics.
3. Read the repo's own `AGENTS.md` for its specific schema (domains, page
   taxonomy, frontmatter fields) — it overrides the generic skill/workflow
   where they disagree.
4. Proceed as the `knowledge-ingest-agent` role describes
   (`AGENTS/knowledge_ingest_agent.md`).

**Case B — new repo, not yet set up:**
1. Walk the user through adopting the workflow:
   - Create `raw/<domain>/` and `wiki/<domain>/` folders per domain.
   - Add `ai_skills` as a git submodule under `EXTERNALS/ai_skills`
     (pinned to a branch/commit).
   - Symlink `WORKFLOWS/llm_wiki_workflow` →
     `../EXTERNALS/ai_skills/WORKFLOWS/llm_wiki_workflow`.
   - Write the repo's own `AGENTS.md` from
     `WORKFLOWS/llm_wiki_workflow/templates/AGENTS_MD_TEMPLATE.md`, filling
     in domains/taxonomy/frontmatter specifics through discussion with the
     user.
   - Create starter `wiki/index.md` and `wiki/log.md`.
   - (Optional) Set up an Obsidian vault at the repo root.
2. See `WORKFLOWS/llm_wiki_workflow/FOLDER_STRUCTURE.md` for the full
   consuming-repo layout, and an example working instance in `mariamas_brain`.
3. Once scaffolded, proceed as Case A.

## Reference

- Workflow: `WORKFLOWS/llm_wiki_workflow/WORKFLOW.md`
- Agent: `AGENTS/knowledge_ingest_agent.md`
- Private mechanics skill: `WORKFLOWS/llm_wiki_workflow/PRIVATE/SKILLS/wiki-maintenance/SKILL.md`
- Templates: `WORKFLOWS/llm_wiki_workflow/templates/`
- Original pattern: [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- Repo/skill/workflow structural conventions: `workflow-conventions` skill
