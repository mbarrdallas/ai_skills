---
name: workflow-conventions
description: Structural conventions for defining workflows, agents, and skills in the ai_skills repo (required/recommended files, YAML frontmatter fields, naming conventions, public vs. workflow-private scoping, symlink patterns) and how to validate them with scripts/validate_skill.sh, validate_agent.sh, validate_workflow.sh, and validate_all.sh. Use when creating a new workflow, agent, or skill in ai_skills, when asking "how should I structure this workflow", "what fields does an agent need", "should this be public or private", or before committing new WORKFLOWS/*, AGENTS/*, or skills/* content.
---

# Workflow Conventions

The structural standard this repo's content is expected to follow, and the
tooling (`scripts/validate_*.sh`) that checks it. This is the repo's own
meta-documentation — read it before creating or restructuring a workflow,
agent, or skill. For *designing an individual agent's role/behavior*, see
the `agent-creator` skill instead; this skill covers the repo-wide
structural/file-layout standard, including how workflows tie agents and
skills together.

## Skill format

```
skills/<skill-name>/SKILL.md
```

Required YAML frontmatter:
```yaml
---
name: <kebab-case, matches directory name exactly>
description: >
  What the skill does, when to use it, and trigger phrases. Should read
  naturally to an LLM deciding whether to load it — mention "use when" /
  concrete trigger phrases so auto-triggering works well.
---
```
Followed by the skill's actual content (procedures, checklists, reference
material). No other frontmatter fields are used for skills.

**Checked by:** `scripts/validate_skill.sh` — fails if `SKILL.md` is
missing or frontmatter lacks `name`/`description`; warns if `name` doesn't
match the directory, description is short (<40 chars) or doesn't mention
"use when"/"trigger", or body content looks empty.

## Agent format

```
AGENTS/<agent_name_snake_case>.md
```

Required YAML frontmatter:
```yaml
---
name: <kebab-case>
description: <what this agent does, one or two sentences>
tools: <comma-separated tool list, e.g. read, write, bash, grep, find, ls, edit>
skills: <comma-separated skill names this agent loads, or "none">
spawns: <comma-separated agent names this agent can invoke, or "none">
model: <claude-sonnet-4-5 | claude-opus-4-5-... | etc.>
---
```
Body should include a `## Completion` section documenting the agent's status
code convention (`DONE`, `BLOCKED needs: ...`, etc.) as the mandatory final
output line.

**Naming:** the file's snake_case name should match the frontmatter `name`'s
kebab-case (e.g. `name: context-agent` ↔ `context_agent.md`).

**Checked by:** `scripts/validate_agent.sh` — fails if any required
frontmatter field is missing; warns on naming mismatches, unresolved
`skills:`/`spawns:` references (unresolved spawns may be intentionally
aspirational, e.g. a not-yet-built agent), non-`claude-*` model ids, or a
missing `## Completion` section.

## Workflow format

```
WORKFLOWS/<workflow_name>/
├── WORKFLOW.md              # required: overview, diagram, agents/skills
│                             #   table, operations, getting-started
├── BACKLOG.md                # recommended: future work for this workflow
├── FOLDER_STRUCTURE.md        # recommended: this workflow's + consuming
│                             #   repos' folder layout
├── agents/                   # symlinks to shared agents this workflow uses
│   └── <agent>.md → ../../../AGENTS/<agent>.md
├── templates/                 # (optional) starter file templates
└── PRIVATE/                   # (optional) workflow-scoped, not shared
    ├── AGENTS/
    │   └── <agent>.md         # agent definitions too coupled to this
    │                          #   workflow's specific shape to be reusable
    │                          #   elsewhere (e.g. an orchestrator managing
    │                          #   this workflow's specific pipeline)
    └── SKILLS/
        └── <skill-name>/
            └── SKILL.md       # skills only ever used by this workflow's
                                #   agent(s); intentionally excluded from
                                #   global auto-triggering
```

**Checked by:** `scripts/validate_workflow.sh` — fails if `WORKFLOW.md` is
missing; warns if `BACKLOG.md`/`FOLDER_STRUCTURE.md` are missing or no
`agents/`/`PRIVATE/AGENTS/` exists. Recurses into `agents/`,
`PRIVATE/AGENTS/`, and `PRIVATE/SKILLS/` entries and validates each against
the agent/skill standard above (broken symlinks are a hard fail).

## Public (`skills/`) vs. workflow-private (`PRIVATE/SKILLS/`)

The test: **would this skill's content and auto-trigger conditions make
sense to load in a completely unrelated pi session, outside this specific
workflow?**

- **Yes → public**, under `skills/`. Example: `codebase-analysis` is useful
  any time an agent needs to understand an unfamiliar codebase, regardless
  of which workflow (if any) is running.
- **No, only meaningful in the context of one specific workflow's
  agent(s) → private**, under `WORKFLOWS/<workflow>/PRIVATE/SKILLS/`.
  Example: `wiki-maintenance` (ingest/query/lint mechanics for the
  `llm_wiki_workflow`) is only ever invoked by that workflow's
  `knowledge-ingest-agent` — its trigger phrases ("ingest a source", "lint
  the wiki") only make sense once a repo is already set up with the
  `raw/`+`wiki/`+`AGENTS.md` layout that workflow expects.

Making a skill private loses global auto-triggering (it won't get
symlinked into `~/.pi/agent/skills` or matched by description in unrelated
sessions). If you still want the *workflow itself* to be publicly
discoverable despite hiding its mechanics, add a thin public **routing
skill** whose only job is pattern recognition + pointing at the workflow —
see `trigger-llm-wiki-workflow` as the reference example for
`llm_wiki_workflow`.

The same reasoning applies to agents and `PRIVATE/AGENTS/` — e.g. an
orchestrator tightly coupled to one workflow's parallel-task/worktree shape
belongs in `PRIVATE/AGENTS/`, not `AGENTS/`.

## Separate the main workflow agent(s) from the validator/linter agent

**Rule: a workflow's validation/health-check/review role must always be a
separate agent from the agent(s) doing the primary work — never the same
agent grading its own output.**

An agent that just wrote or implemented something shares the blind spots
that produced any issues in it — it's prone to missing the same
contradictions, gaps, or mistakes on a self-review pass that it missed while
producing the work. A separate agent, coming to the artifact fresh with
validation as its *only* job, catches more.

This applies regardless of workflow shape or scale:

- **`feature_development_workflow`** (async, multi-agent): `coder-agent`
  implements; `reviewer-agent` — a distinct agent — validates the code
  against requirements/conventions/quality before it ships.
- **`llm_wiki_workflow`** (inline, human-in-the-loop): `knowledge-ingest-agent`
  ingests sources and answers queries; `knowledge-lint-agent` — a distinct
  agent — health-checks the wiki (contradictions, orphans, stale claims,
  missing cross-refs). Even though both agents are lightweight and run in
  the same kind of inline conversation, they are still separate role
  definitions with separate, narrower scopes.

When designing a new workflow:
1. Identify the primary-work agent(s) (implementers, writers, ingesters).
2. Identify the validation/lint/review responsibility explicitly as its own
   role, even if the workflow is small enough that one human runs both
   agents back-to-back in the same session.
3. Give the validator agent a narrow, explicit "not your job" list covering
   the primary-work agent's responsibilities (and vice versa), so scope
   doesn't quietly blur back together over time.
4. Cross-reference the two agents' definitions to each other ("why this is
   separate") so future edits don't accidentally re-merge them.

## No hardcoded paths or credentials

Applies to **workflows, agents, and skills alike**: definitions in this repo
are shared, reusable, and get symlinked/submoduled into other repos (and
other machines). A hardcoded absolute path or embedded credential breaks
portability and can leak information about a specific machine or account.

- **No hardcoded absolute filesystem paths** — no `/Users/<name>/...` or
  `/home/<name>/...`. Use `~` (home-relative), paths relative to the
  repo/workflow root, or an indirection file (e.g. a `LOCATIONS.md`-style
  config) that the consuming repo fills in. Example paths in documentation
  should use `~/WORKSPACE/...` or placeholders like `<repo>/...`, never a
  literal path tied to one person's machine.
- **No embedded credentials or secrets** — no API keys, tokens, passwords,
  connection strings with embedded auth, or similar in `WORKFLOW.md`,
  agent `.md` files, or `SKILL.md` files. If a workflow/agent needs a
  credential, it should read it from the environment or a config file the
  human sets up locally (and gitignored) — never inline it in a definition
  that gets committed and shared.

**Checked by:** all three validators (`validate_skill.sh`,
`validate_agent.sh`, `validate_workflow.sh`) scan for both patterns and
**fail** (not just warn) on a match — this is a hard structural rule, not a
style preference, since these files are meant to be portable and shared.

## Validating before committing

Always run the validators before committing new/changed skills, agents, or
workflows:

```bash
scripts/validate_all.sh                       # everything
scripts/validate_skill.sh [skill-dir]         # one skill, or all skills/*
scripts/validate_agent.sh [agent-file.md]     # one agent, or all AGENTS/*
scripts/validate_workflow.sh [workflow-dir]   # one workflow, or all WORKFLOWS/*
```

Exit code is `1` if any `FAIL` was found, `0` otherwise (warnings never
fail the run — they surface convention drift like naming mismatches or
thin descriptions without blocking work). See `scripts/README.md` for full
details on what each validator checks.

## See also

- `agent-creator` skill — designing an individual agent's role, inputs,
  outputs, and behavior (complements this skill's structural/file-layout
  focus).
- `scripts/README.md` — validator usage and internals.
- `WORKFLOWS/feature_development_workflow/` and
  `WORKFLOWS/llm_wiki_workflow/` — two working examples at different scales
  (async multi-agent orchestration vs. inline single-agent).
