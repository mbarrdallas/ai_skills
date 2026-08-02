# Coding Conventions Skill - Improvement Log

Track improvements made to this skill based on real-world usage.

## 2026-06-27: Add anti-pattern for placeholder tests

**Issue:** Test agent wrote tests with placeholder assertions like `expect(true).toBe(true)` instead of real assertions. These tests passed but didn't verify actual behavior.

**Learning:** Tests must have meaningful assertions that verify actual behavior, not placeholders that always pass.

**Improvement:** Added to SKILL.md:
- Anti-pattern section for placeholder tests
- Explicit rule: "Every test must have assertions that would fail if the code was wrong"
- Example of bad vs good test assertions

**Related:** stats_dashboard_tui T12 review, agent-panel.test.ts

## 2026-06-28: Always read API docs before implementing integrations

**Issue:** Pi extension entry point was implemented with wrong export format (`activate/deactivate` object instead of factory function), and `ctx.ui.custom()` was called with a component instance instead of a factory function. These caused runtime failures that unit tests couldn't catch.

**Learning:** When implementing a component that integrates with an external framework or platform API, the implementer MUST read the official documentation for that specific API before writing any code. Guessing the API shape based on similar patterns or test mocks leads to code that passes unit tests but fails in the real runtime.

**Improvement:** Added to coder-agent behavior rule #1: "Read relevant documentation first". Added to orchestrator rule #14: include doc paths in coder-agent task instructions.

**Related:** stats_dashboard_tui lessons: pi-extension-factory-format, missing-integration-testing

## 2026-08-01: Standardize Python tooling on ruff (drop black/isort)

**Issue:** The Python overlay's Tools section recommended `black` + `isort` +
`ruff` + `flake8` + `pylint` side by side, with `[tool.black]`, `[tool.isort]`,
and `[tool.ruff]` config blocks all present in the same example
`pyproject.toml`. That's contradictory guidance: two formatters (`black` and
`ruff format`) in one repo fight over the same files, and three linters is
noise. The example also used the pre-0.2 `select` layout directly under
`[tool.ruff]`, which is deprecated and now warns.

**Learning:** Recommend exactly ONE tool per job. `ruff` subsumes `black`
(formatting), `isort` (import sorting), and `flake8`/`pylint` (linting) in a
single much faster binary with one config block. It does NOT type-check, so
`mypy` remains separately necessary - that distinction has to be stated
explicitly or readers assume ruff covers everything.

**Improvement:** Rewrote the Tools section of `overlays/python.md`:
- `ruff format` + `ruff check` as the single formatting/linting standard, with
  an explicit "do not add black or isort alongside it" warning
- corrected config to the current `[tool.ruff.lint]` layout, with a note that
  `select` under `[tool.ruff]` is the deprecated form
- expanded the rule selection beyond `E/F/I/N/W` to include `UP`, `B`, `SIM`
- called out that ruff does not type-check, so `mypy` is still required
- added a "if the project is fully type-hinted, enforce it" subsection -
  unchecked type hints are decoration that silently drifts
- added a `ruff-pre-commit` config example
- demoted `black`/`isort`/`flake8`/`pylint`/`pyright` to an "Alternatives (only
  if a project already standardizes on them)" note, so they're recognizable in
  existing code but not introduced into new projects
- noted in the Imports section that ordering is enforced by `ruff check
  --select I`, not by hand

**Related:** `wiki_tool` run instance - the `wikitool` CLI built for
`mariamas_brain` used `ruff` only (no black/isort), which is what surfaced the
overlay's stale advice. That build was also fully type-hinted but shipped with
no `mypy` configured, which motivated the new "enforce it" subsection.

## 2026-08-01: Require a regression test for every bug fix

**Issue:** The skill said tests must have real assertions, but said nothing
about what happens when a *bug* is found. Nothing required a bug fix to come
with a test, and nothing required that test to be observed failing first. In
the `wiki_tool` run this gap was visible three times: unreachable dead code, a
data-loss bug in a file-rewriting path, and output that failed the tool's own
validator - all fixed at some point in a codebase with 115 passing tests,
because the tests covered what someone thought to write, not what had actually
broken.

**Learning:**
- A bug is *evidence* that some behavior was never covered. Fixing the code
  alone leaves the coverage gap exactly as wide as before, so the next refactor
  can reintroduce it silently.
- **Order matters more than existence.** A test written after the fix and never
  observed failing is unverified - it can assert the wrong thing, exercise the
  wrong path, or pass for an unrelated reason. Writing it first and watching it
  fail is what proves it actually catches the defect. (When the three
  index-regeneration fixes were made, each new test was explicitly re-run
  against the pre-fix code to confirm it failed; two of them would otherwise
  have looked fine while testing nothing.)
- "I can't make it fail" means the bug isn't understood yet - that is a signal
  to keep investigating, not to proceed with the fix.
- Level matters: a unit test with the buggy collaborator mocked out will not
  catch a recurrence of an integration bug.
- Regression tests get deleted as redundant unless they say what they protect,
  so the docstring must record the original defect.

**Improvement:** Added an "Every bug fix requires a regression test" subsection
to the Testing Conventions section of SKILL.md: the rule, the four-step
reproduce-verify-fix-confirm order, the instruction to verify the failure is
the *right* failure, the retroactive fallback (temporarily revert the fix to
prove the test catches it), test-level guidance, a worked docstring example
from a real incident, and a closing "fix the class, not just the instance"
note that ties back to fixing generators rather than their output.

**Related:** `wiki_tool` run instance
(`lessons/index-regeneration-data-loss.md`), and the parallel hardening of
`test-agent` and `reviewer-agent` in the `feature_development_workflow`
SELF_IMPROVEMENT_LOG.
