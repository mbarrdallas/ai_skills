# codebase-analysis Skill - Improvement Log

Track improvements made to this skill based on real-world usage.

## 2026-06-28: Add documentation discovery to codebase analysis

**Issue:** During stats_dashboard_tui, coder-agents implemented Pi extension components (TUI overlays, ctx.ui.custom()) without reading the Pi TUI docs. The extension used the wrong export format and wrong API shape, causing runtime failures that only appeared when Pi actually loaded the extension - not in unit tests.

**Learning:** Codebase analysis must include **external documentation discovery** for any integrations. It is not enough to analyze the code - you must also find and read the official docs for any framework, platform, or SDK being integrated with.

**Improvement:** Added "Documentation Discovery" section to context_agent.md. When integrating with an external API:
1. Find the official docs (local SDK files, README, online)
2. Read the relevant sections
3. Extract key API shapes, required formats, and constraints
4. Include in PROJECT_CONTEXT.md under `## External API Constraints`

Scout agents can gather this upfront so coder-agents receive the doc paths in their task instructions.

**Related:** stats_dashboard_tui lessons: pi-extension-factory-format, pi-extension-symlink-resolution
