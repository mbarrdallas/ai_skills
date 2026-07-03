# Workflow Folder Structure

## Workflow Definition Structure

The workflow definition lives in:
```
~/WORKSPACE/REPOS/ai_skills/WORKFLOWS/llm_wiki_workflow/
├── WORKFLOW.md                     # Main workflow definition
├── BACKLOG.md                      # Workflow-specific future work
├── FOLDER_STRUCTURE.md             # This file
├── agents/                         # Symlinks to agents used by this workflow
│   └── knowledge_ingest_agent.md → ../../../AGENTS/knowledge_ingest_agent.md
└── templates/                      # Starter page templates for consuming repos
    ├── SOURCE_PAGE_TEMPLATE.md
    ├── CONCEPT_PAGE_TEMPLATE.md
    └── AGENTS_MD_TEMPLATE.md
```

Unlike `feature_development_workflow`, this workflow has no orchestrator, no
parallel task execution, and no worktrees — it runs inline in a single
conversation with a human in the loop. There is deliberately no
`CONFIG_TEMPLATE.md` / `LOCATIONS_TEMPLATE.md` / `PRIVATE/` — those exist in
`feature_development_workflow` to support async, multi-agent orchestration
that this workflow doesn't need.

## Consuming Repo Structure

A repo using this workflow (e.g. `mariamas_brain`) is structured as:

```
<repo>/
├── AGENTS.md                       # Repo-specific schema (domains, page
│                                    #   taxonomy, frontmatter fields).
│                                    #   References this workflow as the
│                                    #   kickoff point for ingest/query/lint.
├── EXTERNALS/
│   └── ai_skills/                  # git submodule -> ai_skills repo
├── WORKFLOWS/
│   └── llm_wiki_workflow           # symlink -> ../EXTERNALS/ai_skills/WORKFLOWS/llm_wiki_workflow
├── raw/
│   └── <domain>/                   # Immutable source documents
└── wiki/
    ├── index.md                    # Root catalog
    ├── log.md                      # Chronological, append-only log
    └── <domain>/
        ├── index.md                # Per-domain catalog
        ├── sources/                # One page per ingested source
        ├── concepts/                # Durable concept pages
        ├── entities/                # (if applicable) people/places/things
        └── synthesis/                # (if applicable) evolving-thesis pages
```

## Path Resolution

No `LOCATIONS.md` is needed for this workflow — everything operates relative
to the consuming repo's own root (`raw/`, `wiki/`, `AGENTS.md`). The only
external reference is the submodule path to `ai_skills`, which the
consuming repo's `AGENTS.md` should state explicitly, e.g.:

```markdown
This repo follows the LLM Wiki Workflow, defined at
`EXTERNALS/ai_skills/WORKFLOWS/llm_wiki_workflow/` (symlinked at
`WORKFLOWS/llm_wiki_workflow`). See that workflow's `WORKFLOW.md` for the
general ingest/query/lint procedure; this file defines the schema specific
to this repo.
```
