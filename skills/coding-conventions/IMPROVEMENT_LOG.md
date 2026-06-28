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
