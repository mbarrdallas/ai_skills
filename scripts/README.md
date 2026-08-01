# Scripts

Two families:

- **`validate_*.sh`** — check that skills, agents, and workflows in this repo
  follow the conventions documented in `~/WORKSPACE/AGENTS.md` and the sample
  files under `AGENTS/`, `skills/`, and `WORKFLOWS/`.
- **`install_*.sh`** — symlink this repo's skills and agents into the pi
  harness so they're actually discoverable/invocable.

## Validation usage

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

## Install (harness linking) usage

A skill only auto-triggers, and an agent is only invocable, if the harness can
see it. `AGENTS.md` warns that this symlink step "is easy to forget and the
skill will silently never trigger without it" — these scripts make it a
one-liner and, more importantly, make the omission **detectable**.

```bash
scripts/install_all.sh              # link all public skills + agents
scripts/install_all.sh --check      # report drift only, change nothing (exit 1 if out of sync)
scripts/install_all.sh --prune      # also remove broken links pointing into this repo

scripts/install_skills.sh [--check] [--thirdparty] [--prune] [--quiet]
scripts/install_agents.sh [--check] [--private]    [--prune] [--quiet]
```

Run `install_all.sh --check` after adding a skill or agent — it's the fast way
to confirm you didn't forget the link. It exits `1` when out of sync, so it can
be wired into a pre-commit hook or CI.

**Safety properties** (deliberate, and covered by the manual test matrix below):

- **Nothing is destructive by default.** Removal happens only with explicit
  `--prune`, and only for **broken** links that point *into this repo*.
- **Links pointing outside this repo are never touched** — notably pi's own
  bundled example agents (`planner`, `reviewer`, `scout`, `worker`). They're
  reported and left alone.
- **Real files/dirs are never clobbered** — if a target name exists and isn't a
  symlink, it's reported and skipped.
- `--check` is strictly read-only.

**Scoping choices:**

- `skills/*` — linked by default (needs a `SKILL.md`).
- `WORKFLOWS/*/PRIVATE/SKILLS/*` — **never** linked; workflow-private skills
  are intentionally not globally auto-triggering.
- `THIRDPARTY/anthropic_skills/skills/*` — opt-in via `--thirdparty`; that set
  is large and curated by hand (only `skill-creator` is linked today).
- `AGENTS/*.md` — linked by default, excluding `SELF_IMPROVEMENT_LOG.md`
  (a log, not an agent).
- `WORKFLOWS/*/PRIVATE/AGENTS/*` — opt-in via `--private`, since `AGENTS.md`
  makes these case-by-case. Linked under their frontmatter `name:` rather than
  their filename, because private agent files are often generically named
  (`orchestrator_agent.md` → `feature-development-orchestrator.md`) and the
  `name:` is how they're actually invoked.

Target directories are overridable for testing:
`$PI_SKILLS_DIR` / `$PI_AGENTS_DIR`, else `$PI_AGENT_DIR/{skills,agents}`,
else `~/.pi/agent/{skills,agents}`.

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
output) sourced by the validators and the install scripts. Not meant to be run
directly.

Note: the `wiki-maintenance` skill's `scripts/convert_source.sh` deliberately
does **not** source `_lib.sh` — it runs from inside consuming repos where
`ai_skills` is a submodule, so it must stay self-contained.

## Notes

- Written in portable POSIX-ish bash + `awk`/`sed`/`grep -E` — tested on
  macOS (BSD grep/sed). Avoid GNU-only regex extensions (e.g. `\|`
  alternation in BRE) if you modify these.
- Warnings never fail the run — they surface convention drift (naming
  mismatches, short descriptions, unresolved but possibly-aspirational
  references) without blocking work. Only structural problems (missing
  required files/fields) are `FAIL`.
- `validate_all.sh` and `install_all.sh` print a summary **per category**, not
  a grand total — three/two `Summary` blocks. Don't read the last one as a
  repo-wide count.

## Manual test matrix for the install scripts

No automated test suite yet (see `BACKLOG.md`). These cases were verified by
hand and are worth re-running after changes:

| Case | Expected |
|------|----------|
| `--check` on a synced tree | "in sync", exit 0, zero modifications |
| skill link removed | `MISSING` warning, exit 1; plain run relinks it |
| broken link into repo | `BROKEN` warning; removed only with `--prune` |
| link pointing outside repo | reported, left untouched |
| non-symlink at target name | reported, left untouched |
| `--private` | private agent linked under frontmatter `name:` |
| `--thirdparty --check` | reports the 16 unlinked THIRDPARTY skills, changes nothing |
