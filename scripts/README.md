# Validation Scripts

Bash validators that check skills, agents, and workflows in this repo follow
the conventions documented in `~/WORKSPACE/AGENTS.md` and the sample files
under `AGENTS/`, `skills/`, and `WORKFLOWS/`.

## Usage

```bash
# Validate everything
scripts/validate_all.sh

# Validate one category
scripts/validate_skill.sh                      # all skills/*
scripts/validate_skill.sh skills/git-workflow   # one skill

scripts/validate_agent.sh                       # all AGENTS/*.md + */PRIVATE/AGENTS/*.md
scripts/validate_agent.sh AGENTS/coder_agent.md # one agent

scripts/validate_workflow.sh                                    # all WORKFLOWS/*
scripts/validate_workflow.sh WORKFLOWS/llm_wiki_workflow         # one workflow
```

Each script exits `0` if there are no `FAIL`s (warnings don't fail the run)
and `1` if any `FAIL` was found — safe to wire into a pre-commit hook or CI.

## What gets checked

**`validate_skill.sh`** — `<skill-dir>/SKILL.md` must have YAML frontmatter
with `name` (kebab-case, matching the directory name) and `description`
(non-empty, ideally >= 40 chars and mentioning "use when"/"trigger"
conditions for good auto-triggering), plus non-trivial body content.

**`validate_agent.sh`** — agent `.md` files must have YAML frontmatter with
all of: `name`, `description`, `tools`, `skills`, `spawns`, `model`. Checks
`name` is kebab-case and matches the file's snake_case name, that `skills:`
entries resolve to real skills, that `spawns:` entries resolve to real agent
files (warn-only — some references may be intentionally aspirational, e.g.
a not-yet-built "scout" agent), and that a `## Completion` section exists
(status-code convention).

**`validate_workflow.sh`** — `<workflow-dir>/WORKFLOW.md` must exist with
substantive content. Recommends (warns if missing) `BACKLOG.md` and
`FOLDER_STRUCTURE.md`. If an `agents/` or `PRIVATE/AGENTS/` directory
exists, every entry must resolve (no broken symlinks) and passes through
`validate_agent.sh`.

## `_lib.sh`

Shared helpers (frontmatter parsing, pass/warn/fail counters, colored
output) sourced by all three validators. Not meant to be run directly.

## Notes

- Written in portable POSIX-ish bash + `awk`/`sed`/`grep -E` — tested on
  macOS (BSD grep/sed). Avoid GNU-only regex extensions (e.g. `\|`
  alternation in BRE) if you modify these.
- Warnings never fail the run — they surface convention drift (naming
  mismatches, short descriptions, unresolved but possibly-aspirational
  references) without blocking work. Only structural problems (missing
  required files/fields) are `FAIL`.
