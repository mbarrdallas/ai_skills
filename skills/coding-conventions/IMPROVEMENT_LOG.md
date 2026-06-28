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
