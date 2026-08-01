---
name: trigger-feature-development-workflow
description: Detect when the user wants to build a software feature, application, or non-trivial code change end-to-end and route to the feature_development_workflow (requirements → design → planning → TDD implementation → docs → sign-off, async multi-agent with worktrees). Use when the user says things like "build me X", "implement a feature that does X", "add X to my app", "create a new service/API/CLI for X", "I want to develop X", "refactor this module", "write this feature properly", or otherwise asks for real code to be produced with tests and review rather than a quick one-off snippet. Also trigger when the user names the workflow directly ("kick off the feature development workflow", "start feature development", "run the coding workflow"). Do NOT trigger for trivial single-file edits, debugging an existing error, answering a code question, or wiki/knowledge work (see trigger-llm-wiki-workflow).
---

# Trigger: Feature Development Workflow

A lightweight **routing skill**. Its only job is to recognize that a request
warrants the full, structured software-development workflow and to route
there — it does not itself carry the phase procedures, which live in
`WORKFLOWS/feature_development_workflow/WORKFLOW.md` and the individual
agent definitions.

This is the counterpart to `trigger-llm-wiki-workflow`,
`trigger-workflow-monitor`, and the `research_workflow`'s routing: those
handle knowledge, workflow-auditing, and research work respectively. This one
handles **producing code**.

## When this triggers

- The user asks for a **feature, app, service, API, CLI, or library** to be
  built — greenfield or added to an existing codebase.
- The user asks for a **non-trivial refactor** or restructuring of existing
  code.
- The user explicitly names the workflow ("kick off feature development",
  "run the coding workflow").
- The request implies real code that should be **tested and reviewed**, not a
  throwaway snippet.

## When this does NOT trigger

Routing a small request into an 8-phase multi-agent workflow is itself waste
(over-processing, in TPS terms). Don't trigger for:

- **Trivial changes** — a one-line fix, a rename, adding a single log
  statement. Just make the edit.
- **Debugging** an existing failure — that's investigative work; use the
  `scientific-method` skill. Escalate here only if the fix turns out to
  require a real feature-sized change.
- **Questions about code** ("how does this work?", "what does this do?") —
  use `codebase-analysis`.
- **Knowledge/wiki work** — route to `trigger-llm-wiki-workflow`.
- **Research** — route to the `research_workflow`.
- **Auditing a workflow** itself — route to `trigger-workflow-monitor`.
- **Scripts/tooling internal to a workflow or skill** (e.g. adding a helper
  script to a skill's `scripts/` dir) — that's authoring workflow
  definitions; see `workflow-conventions`.

**If it's genuinely borderline, ask the user** rather than silently choosing.
A one-line question ("want me to just make this change, or run it through the
full feature workflow?") is cheaper than either mistake.

## What to do when triggered

1. **Read `WORKFLOWS/feature_development_workflow/WORKFLOW.md` first** — the
   full 8-phase definition. Don't improvise the phase order from this skill.
2. **Gather the four inputs** the workflow needs before it can start (see its
   "Getting Started"). Ask for whatever the user hasn't already supplied:
   - **Goal** — what to build
   - **Project type** — greenfield, or existing codebase (determines whether
     Phase 1 context analysis runs)
   - **Mode** — **interactive** (default; pauses for human approval after
     requirements, design, and sign-off) or **autonomous** (no checkpoints,
     human reviews `COMPLETION_REPORT.md` at the end). Only go autonomous if
     the user explicitly asks.
   - **Paths** — where the code repository lives
3. **Create the run instance** at
   `~/WORKSPACE/active_workflows/<workflow-name>/`, and write its
   `LOCATIONS.md` (from `LOCATIONS_TEMPLATE.md`) and `WORKFLOW_CONFIG.md`
   (from `CONFIG_TEMPLATE.md`).
   **Workflow artifacts never go inside the code repo** — only actual code
   does. See `workflow-conventions` for this rule and the reasoning.
4. **Hand off to the orchestrator**
   (`WORKFLOWS/feature_development_workflow/PRIVATE/AGENTS/orchestrator_agent.md`),
   which coordinates all phases, spawns the other agents, and manages
   worktrees, state, and budget. Don't run the phases manually if the
   orchestrator can drive them.

## Phases at a glance

Full detail in `WORKFLOW.md`; this is orientation only.

| # | Phase | Agent | Key output |
|---|-------|-------|-----------|
| 1 | Context *(existing projects only)* | context-agent | `PROJECT_CONTEXT.md` |
| 2 | Requirements | requirements-agent | `REQUIREMENTS.md` ⏸ |
| 3 | Design | design-agent | `design/` |
| 4 | Planning | planning-agent | `planning/TASK_PLAN.md` |
| 5 | Implementation | orchestrator → test-agent → coder-agent → reviewer-agent | `src/`, `tests/`, `reviews/` |
| 6 | Documentation | documentation-agent | `docs/` |
| 7 | Sign-off | orchestrator | `SIGN_OFF.md`, `COMPLETION_REPORT.md` ⏸ |
| 8 | Merge | orchestrator | merged to `development` (human merges to `main`) |

⏸ = human approval checkpoint in interactive mode.

**Phase 5 is deliberately three agents, not one:** test-agent writes tests
**before** implementation (TDD, defining the contract), coder-agent implements
against them, and reviewer-agent validates and can return
`CHANGES_REQUESTED`. The agent that writes the code does not grade it — the
same separation-of-concerns principle as the `llm_wiki_workflow`'s
ingest/lint split.

## After the run

- Capture lessons into the instance's `lessons/*.md` using the
  `lesson-capture` skill — the workflow's continuous-improvement mechanism.
- The `active_workflows/<name>/` directory is **kept** after completion for
  reference; worktrees are removed after a successful merge.
- A completed run instance is the primary audit target for
  `workflow_monitor_workflow` ("did we actually fix the lessons we
  captured?") — see `trigger-workflow-monitor`.

## Reference

- Workflow: `WORKFLOWS/feature_development_workflow/WORKFLOW.md`
- Agent roster: `WORKFLOWS/feature_development_workflow/AGENTS.md`
- Orchestrator: `WORKFLOWS/feature_development_workflow/PRIVATE/AGENTS/orchestrator_agent.md`
- Layout: `WORKFLOWS/feature_development_workflow/FOLDER_STRUCTURE.md`
- Templates: `WORKFLOWS/feature_development_workflow/templates/`,
  `CONFIG_TEMPLATE.md`, `LOCATIONS_TEMPLATE.md`
- Structural conventions (incl. artifact placement, no hardcoded paths):
  `workflow-conventions` skill
