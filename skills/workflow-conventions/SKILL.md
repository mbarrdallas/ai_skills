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

## Where running workflow session artifacts go

**Applies to async, multi-agent-orchestrated workflows** (e.g.
`feature_development_workflow`) that produce planning/process artifacts
distinct from the code/content they're producing — requirements docs,
design docs, task plans, orchestrator state, review reports, etc.

**Rule: these artifacts go under `~/WORKSPACE/active_workflows/<workflow_name>/`,
never inside the code repository itself.** Only the actual code (written via
git worktrees) and actual content (e.g. wiki pages) belong in the
target repo.

```
~/WORKSPACE/active_workflows/<workflow_name>/
├── LOCATIONS.md          # paths to code repo, skills, agents, worktrees -
│                         #   agents resolve paths through this file, never
│                         #   hardcode them (see "No hardcoded paths" below)
├── WORKFLOW_CONFIG.md
├── REQUIREMENTS.md
├── design/ planning/ orchestrator/ reviews/ docs/ lessons/
```

Worktrees for parallel task execution live separately, at
`{worktrees_dir}/{workflow_name}/task-<id>-<name>/` (path configured in
that workflow run's `LOCATIONS.md`) — removed after a successful merge.
The `active_workflows/<workflow_name>/` directory itself is kept after
completion for reference (archive periodically if it builds up).

If a workflow-planning artifact (`IMPLEMENTATION_SPEC*.md`,
`TEST_COVERAGE*.md`, `ORCHESTRATOR_STATE.md`, `TASK_PLAN.md`, or similar)
ever ends up inside a code repo, that's a bug — move it to
`active_workflows/` and `.gitignore` the pattern if it recurs (see
`git-workflow` skill).

**Does not apply** to inline, human-in-the-loop workflows with no
orchestrator/worktree machinery (e.g. `llm_wiki_workflow`) — those don't
spin up a session-artifact directory at all; their only "artifacts" are
the actual content they produce (wiki pages, `log.md`, `BACKLOG.md`),
written directly into the consuming repo.

See `WORKFLOWS/feature_development_workflow/FOLDER_STRUCTURE.md` and
`LOCATIONS_TEMPLATE.md` for the full reference layout and path-resolution
conventions.

### Tier-0 orchestrators must load this skill

**Rule: any Tier-0 orchestrator agent (the top-level coordinator of a
workflow - e.g. `feature-development-orchestrator`) must include
`workflow-conventions` in its own `skills:` frontmatter field and actually
load/apply it**, not just the workflow-specific skills it already uses
(`git-workflow`, `task-breakdown`, etc.). The orchestrator is the agent
responsible for creating the workflow's own planning/process artifacts
(state files, logs, budget tracking, task plans) - it needs this skill's
"Where running workflow session artifacts go" rule directly, not
second-hand, since getting artifact placement wrong is exactly the kind of
mistake that only surfaces once code/content and process files are already
tangled together in the wrong repo.

This applies regardless of whether the orchestrator is a public `AGENTS/`
agent or a workflow-`PRIVATE/AGENTS/` one (most orchestrators are private,
since they're tightly coupled to one workflow's specific shape - see
"Public vs. workflow-private" above).

## Self-improvement logging

**Rule: every agent and every workflow must be self-improving, and must log
when it improves itself.** "Self-improving" means: when a flaw, gap,
inefficiency, or ambiguity in an agent's or workflow's own definition is
found (via a grilling/review pass, a lint pass, a lesson learned during
real use, etc.), the definition gets fixed - not just noted and left for
next time. The log exists so that history of *why* a definition looks the
way it does isn't lost, and so a future reviewer (human or agent) can tell
self-improvement is actually happening rather than assuming it.

**Not a new format — reuses the existing `IMPROVEMENT_LOG.md` structure**
already established for skills (see e.g. `skills/coding-conventions/IMPROVEMENT_LOG.md`,
`skills/task-breakdown/IMPROVEMENT_LOG.md`): one entry per dated
issue/learning/improvement, not a terse one-liner. This extends that same
mechanism to agents and workflows (skills already had it; agents/workflows
didn't). Named `SELF_IMPROVEMENT_LOG.md` (not `IMPROVEMENT_LOG.md`) at the
agent/workflow scope purely to keep the two scopes distinguishable at a
glance in a directory listing — the entry format is identical:

```markdown
## YYYY-MM-DD: <short title>

**Issue:** What was wrong (a flaw, gap, ambiguity, or inefficiency found).

**Learning:** What this revealed more generally.

**Improvement:** What actually changed in the definition, and where.

**Related:** Links/references (a grilling report, a lint finding, a lesson
capture, a specific incident).
```

**Two tiers - one shared log per scope, not one file per agent:**

- **`AGENTS/SELF_IMPROVEMENT_LOG.md`** (repo root, shared across all public
  agents) - one entry per agent-definition change made *because* a flaw was
  found in it (not routine feature additions - see "What counts" below).
  Prefix each entry's title with the agent name, e.g.
  `## 2026-07-03: research-agent - spawn interface made explicit`.
- **`WORKFLOWS/<workflow>/SELF_IMPROVEMENT_LOG.md`** (recommended per
  workflow, alongside `BACKLOG.md`/`FOLDER_STRUCTURE.md`) - workflow-level
  self-improvements: `WORKFLOW.md` corrections, agents/skills added or
  reorganized within the workflow, structural fixes found via a grilling
  pass or a `workflow-monitor-agent` audit.

Workflow-private agents/skills (`PRIVATE/AGENTS/`, `PRIVATE/SKILLS/`) log to
their owning workflow's `SELF_IMPROVEMENT_LOG.md`, not a separate file of
their own.

**Relationship to `lesson-capture` skill:** that skill is for capturing
lessons from a live *project* (output goes to that project's
`active_workflows/<name>/lessons/*.md`, per `feature_development_workflow`).
`SELF_IMPROVEMENT_LOG.md` is narrower and repo-local: specifically for
changes to an agent's or workflow's own *definition* in `ai_skills` itself.
A project lesson may well *cause* a `SELF_IMPROVEMENT_LOG.md` entry (e.g. a
lesson reveals a gap in `coder-agent`'s instructions, which then gets
fixed and logged here) — the two aren't mutually exclusive, they operate
at different scopes.

**What counts as a self-improvement entry** (log it) **vs. routine work**
(don't log every commit):
- Log: a grilling/review pass finds a real flaw and it gets fixed; a lint
  pass (`knowledge-lint-agent`, `workflow-monitor-agent`) finds a structural
  or TPS-style issue and it gets fixed; a lesson learned during real use
  changes how an agent behaves going forward.
- Don't log: adding a brand-new agent/workflow from scratch (that's just
  authoring, not self-improvement of something that already existed);
  routine content changes with no flaw being corrected.

**Checked by:** `validate_agent.sh` and `validate_workflow.sh` warn (not
fail) if `SELF_IMPROVEMENT_LOG.md` is missing at the relevant scope - a
warning, not a hard requirement, since a brand-new agent/workflow won't
have any self-improvement history yet by definition.

See `WORKFLOWS/workflow_monitor_workflow/` for the workflow whose whole job
is auditing other workflows (TPS-style inefficiency, correctness, and
improvement suggestions) and driving entries into these logs.

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
- `WORKFLOWS/feature_development_workflow/FOLDER_STRUCTURE.md` and
  `LOCATIONS_TEMPLATE.md` — full detail on `active_workflows/` layout and
  path resolution (see "Where running workflow session artifacts go" above).
