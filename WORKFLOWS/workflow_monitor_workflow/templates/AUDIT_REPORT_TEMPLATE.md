# Workflow Audit — <workflow-name> — <YYYY-MM-DD>

Prerequisite: `scripts/validate_workflow.sh <workflow-name>` result:
<PASS / PASS with N warnings — paste the Summary line>

## Summary

<1-3 sentence summary of the overall audit outcome — written last, after
the sections below are filled in.>

---

## TPS Findings

Only include subsections with actual findings — omit entirely if clean
(note it once in the Summary instead of writing "none found" repeatedly).

### Overproduction (作りすぎ)
- **<agent/step>**: <finding>. Resolution: <fixed directly / filed to BACKLOG.md>.

### Waiting (待ち)
- **<handoff point>**: <finding>. Resolution: <...>.

### Transport (運搬)
- **<handoff>**: <finding>. Resolution: <...>.

### Over-processing (加工)
(Use the Redundancy Detection procedure's output here.)
- **<skill> loaded by <agent A> and <agent B>**: <overlapping operation
  found>. Recommended owner: <which agent should own this check>.
  Resolution: <fixed directly / filed to BACKLOG.md>.

### Inventory (在庫)
- **<workflow>**: <missing BACKLOG.md / missing SELF_IMPROVEMENT_LOG.md /
  findings that would evaporate>. Resolution: <...>.

### Motion (動作)
- **<agent>**: <finding>. Resolution: <...>.

### Defects (不良)
- **<agent>.spawns references <nonexistent agent>**, or **<agent> assumes
  <contract detail> about <spawned agent> that its real definition
  contradicts**. Resolution: <...>.

---

## Jidoka / Quality-Built-In Findings

- <validator/author separation respected in spirit? Tier-0 orchestrator
  actually loading workflow-conventions? Defects surfaced rather than
  silently passed downstream?>

## Kaizen / Continuous-Improvement Findings

- <BACKLOG.md / SELF_IMPROVEMENT_LOG.md present and actually used, or just
  scaffolded and empty?>

## Semantic / Correctness Findings

(Agent-to-agent contradictions, unclear handoffs, missing edge cases —
the kind of thing a grilling critique pass surfaces. See
`WORKFLOWS/research_workflow/SELF_IMPROVEMENT_LOG.md` for a worked
example of this category.)

- **<agent A> vs <agent B>**: <contradiction/ambiguity>. Resolution: <...>.

---

## Fixes applied directly this pass

- <file>: <one-line description of the fix>

(Only unambiguous fixes belong here. Anything requiring a design/editorial
judgment call goes to the audited workflow's `BACKLOG.md` instead.)

## BACKLOG.md changes this pass (audited workflow's own BACKLOG.md)

- Filed: <item>
- Checked off (already resolved): <item>

## SELF_IMPROVEMENT_LOG.md entry (audited workflow's own log, if a fix was applied)

```markdown
## YYYY-MM-DD: <short title>

**Issue:** <what was wrong>
**Learning:** <what this revealed>
**Improvement:** <what changed, where>
**Related:** This audit report (`WORKFLOWS/workflow_monitor_workflow/audits/<file>`).
```
