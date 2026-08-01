# Self-Improvement Log - LLM Wiki Workflow

Append-only, chronological log of self-improvements to this workflow's own
definition (`WORKFLOW.md`, `FOLDER_STRUCTURE.md`, `BACKLOG.md`, and the
agents/skills it owns) — see `workflow-conventions` skill's
"Self-improvement logging" for the entry format and what counts as an
entry vs. routine work. Backfilled below with real history from before
this log file existed.

---

## 2026-07-02: Non-text sources need an explicit conversion convention

**Issue:** Ingesting a PDF source (FMCSA Carrier Compliance Questionnaire)
raised the question of whether to keep the original binary alongside a
converted version, or convert-and-discard. No documented convention
existed.

**Learning:** `raw/` needs to stay uniformly plain-text/markdown for
consistent downstream handling (grep, diff, git-friendliness) — keeping
mixed binary+converted copies adds no real value and complicates the
"read the raw source" step for every future agent.

**Improvement:** Documented in the `wiki-maintenance` skill: non-text
sources (PDF, docx, etc.) are always converted to markdown via `markitdown`
and the original is discarded, not kept alongside.

**Related:** commit `c78b090`.

## 2026-07-02: wiki-maintenance skill scoped to workflow-private, `trigger-llm-wiki-workflow` added for discoverability

**Issue:** `wiki-maintenance` initially lived in the shared, globally
auto-triggering `skills/` directory, but its trigger conditions ("ingest a
source", "lint the wiki") only make sense once a repo is already set up
with the `raw/`+`wiki/`+`AGENTS.md` layout this workflow expects — loading
it in an unrelated session is noise.

**Learning:** A skill's *mechanics* being workflow-specific doesn't mean
the *pattern itself* should stop being publicly discoverable — those are
separable concerns, addressed with a thin public routing skill.

**Improvement:** Moved `wiki-maintenance` to
`WORKFLOWS/llm_wiki_workflow/PRIVATE/SKILLS/` (no longer globally
auto-triggering). Added `trigger-llm-wiki-workflow` as a public routing
skill whose only job is pattern recognition + pointing at this workflow.
Also added `workflow-conventions` as the general structural standard this
change established a precedent for.

**Related:** commit `090d5da`.

## 2026-07-03: Split knowledge-ingest-agent and knowledge-lint-agent

**Issue:** A single agent originally handled ingest, query, *and*
lint/health-checking. That agent grading the health of a wiki it just
wrote is prone to the same blind spots that produced any issues in the
first place.

**Learning:** Mirrors `coder-agent`/`reviewer-agent` in
`feature_development_workflow` — validation/health-check responsibility
should be a separate agent from the one doing the primary work, even at
small/inline scale. This became the general rule now codified in
`workflow-conventions`' "Separate the main workflow agent(s) from the
validator/linter agent".

**Improvement:** Split into `knowledge-ingest-agent` (ingest + query only)
and a new `knowledge-lint-agent` (lint only). Established the per-repo
`BACKLOG.md` convention so lint findings that aren't safely auto-fixable
get filed as checkbox items rather than evaporating in a findings report.

**Related:** commit `c136c2d`.

## 2026-07-03: Standardized lint report structure

**Issue:** `knowledge-lint-agent`'s findings reports were ad hoc prose,
inconsistent across passes and repos.

**Learning:** A structural template pays off even for a lightweight,
inline-only workflow — consistency in report shape makes it easier to spot
what's missing (e.g. a category silently skipped) across repeated passes.

**Improvement:** Added `templates/LINT_REPORT_TEMPLATE.md`, wired into
`knowledge-lint-agent` and the `wiki-maintenance` skill's Lint operation.
Also fixed `FOLDER_STRUCTURE.md`, which had never listed the pre-existing
`BACKLOG_TEMPLATE.md` either.

**Related:** commit `231c3e8`.

## 2026-08-01: Unsourced specifics — traceability was never actually required

**Issue:** An ingest of two DOL sources asserted `29 U.S.C. §213(b)(1)` on three
wiki pages as the citation for the FLSA motor-carrier overtime exemption. Both
sources said only "§13(b)". The full U.S. Code citation appeared **nowhere** in
`raw/` — it came from the model's own knowledge. It passed a clean
`brain validate` run (0 errors, 0 warnings) and was caught only by a later
manual `grep raw/` spot-check.

**Learning (three distinct ones):**

1. **The rule was never written down.** Both the skill and
   `knowledge-ingest-agent` said "don't invent facts" only in passing, and never
   defined what that meant operationally or how to check it. Every task brief
   for this workflow had been *manually* restating "never invent a fact" —
   which is a strong signal the rule belonged in the definitions, not in the
   prompt. It was working only because the human kept remembering to say it.
2. **This failure mode is invisible to every automated check.** Frontmatter
   validation, wikilink checks, orphan detection, and the whole `wikitool`
   validator all pass, because nothing *structural* is wrong. Only comparing
   the page's assertions against its own `sources:` files finds it.
3. **The fabricated fact is usually correct, and that's what makes it
   dangerous.** A wrong fact gets challenged; a right-but-unsourced fact gets
   trusted and propagated. The defect isn't accuracy, it's that no future reader
   can distinguish grounded claims from remembered ones. Discipline has to be
   framed around *traceability*, not *correctness*, or agents will
   self-authorize whenever they feel confident.

**Improvement:**
- `wiki-maintenance` SKILL.md: new **"Traceability: every specific must trace to
  `raw/`"** section defining what counts as a verifiable specific, what is
  explicitly still allowed (summary, synthesis, shown arithmetic), the
  `grep raw/` pre-write check, and the **only three legitimate options** when
  there's no hit (say only what the source says / mark not-in-source + BACKLOG /
  omit) — with "I'm confident it's right" explicitly excluded. Added the
  "don't complete a source's shorthand" corollary, since expanding "§13(b)" felt
  like tidying rather than fabricating. Added the append-a-correction-to-`log.md`
  rule so retractions are on the record instead of quietly edited away.
- `knowledge-ingest-agent`: new Behavior rule 5 with the same content, plus a
  **mandatory traceability sweep in `## Completion`** — extract every specific
  introduced, grep for it, resolve misses *before* reporting `DONE`. Its
  Completion section previously had no verification step at all, which is why a
  `DONE` could be sincere and still wrong.
- `knowledge-lint-agent`: **"Unsourced specifics" added as the FIRST and
  highest-priority lint category**, with the grep method, the "report it even if
  correct" instruction, and an explicit warning that this fix is *not*
  unambiguous — correct the page, file to BACKLOG, append to `log.md`; never
  silently delete.

**Why it went in all three:** the ingest rule prevents it, the lint rule catches
it when prevention fails, and the skill holds the shared definition so the two
agents can't drift. Per the workflow's own ingest/lint separation, the agent that
writes the pages should not be the only thing standing between a fabricated
citation and the wiki.

**Related:** `mariamas_brain` commit 15b487a (the correction), its BACKLOG item
to verify the real citation, and the `wiki/log.md` retraction entry.
