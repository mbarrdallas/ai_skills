---
name: research-methodology
description: Scope a research effort before gathering data — clarify the objective, decide whether the question calls for measurable metrics, qualitative stories, or subjective opinions, and calibrate how deep to go given available time, budget, and access to subjects. Use when asked to "research X", "find out about X", "look into X", plan a research effort, or decide how much research is enough before starting to gather data.
---

# Research Methodology

Scoping discipline for research efforts, independent of where the findings
end up. Pairs naturally with `scientific-method` (which this skill leans on
for the actual questioning technique) but is specific to *research*
scoping — deciding what kind of answer is needed and how deep to dig,
**before** spending any time/budget gathering data.

This skill deliberately does not cover what to do with findings afterward
(e.g. writing them into a personal knowledge base) — that's a separate
concern, handled by whichever agent/workflow invokes this skill (see
`research-agent` / `research_workflow` for how these compose).

## Step 1: Define the research objective

Don't start gathering data until the objective is explicit and falsifiable.
Apply `scientific-method`'s questioning techniques here directly — ask
clarifying, boundary, and motivation questions **one at a time**:

- "What decision will this research inform?"
- "What would change if the answer were X vs. Y?"
- "What does 'done' look like for this research — a specific question
  answered, a range narrowed, a decision unblocked?"
- "What's explicitly out of scope?"

Write the objective as a single, falsifiable statement, not a vague topic.
Bad: "research electric bus maintenance." Good: "determine whether
switching to electric coaches would reduce our per-mile maintenance cost,
within 15%, over a 5-year horizon."

## Step 2: Decide what kind of answer is needed

Research questions call for different evidence types — decide this
explicitly, don't default to whichever is easiest to gather:

| Type | When it's the right fit | Example |
|------|--------------------------|---------|
| **Measurable metrics** | The objective is comparative/quantitative, decisions hinge on a number crossing a threshold | Cost per mile, failure rate, compliance percentage |
| **Stories** | The objective is about how/why something happens, process, or lived experience — numbers alone won't capture it | How drivers actually handle a specific compliance scenario in practice |
| **Subjective opinions** | The objective is about preference, sentiment, or judgment calls where there's no single "correct" measurable answer | Whether a proposed policy would be well-received |

Many objectives need more than one type — say so explicitly rather than
collapsing to whichever's most convenient to gather. If unsure which
type(s) fit, ask the human requesting the research directly: "Are you
looking for hard numbers here, or understanding of how/why this happens?"

## Step 3: Calibrate depth against time, budget, and access

Before gathering anything, assess the three constraints that determine how
deep this research can/should go — make each one explicit rather than
assumed:

- **Time**: How much time is actually available before the answer is
  needed? A same-day answer and a multi-week answer call for very
  different depth.
- **Budget**: Any hard cost ceiling (paid data sources, travel, compensated
  interviews, tools)? Free/existing sources only, or is spend authorized?
- **Access to subjects**: If the research needs stories or subjective
  opinions from people, is that access actually available? (Can you
  reach the drivers/vendors/customers in question, or only secondary
  sources about them?) Don't assume access exists — ask.

Given these three, state the calibrated depth explicitly before starting,
e.g.: "Given a 1-day time box, no budget for paid sources, and no direct
access to drivers, this will be a desk-research pass over existing
documents and public sources only — not primary interviews." Revisit this
calibration if new constraints surface mid-research rather than silently
letting scope creep.

## Step 4: Check existing knowledge before gathering new data

Don't spend time/budget re-deriving something already known. Before
gathering any new data, check whatever existing knowledge base(s) are
available for prior coverage of this objective (a personal wiki, prior
research reports, existing documentation — whatever applies in context).
Only proceed to gather new data for the gap that existing knowledge
doesn't already cover.

(How to identify and query a specific knowledge base — e.g. an
`llm_wiki_workflow` wiki — is out of scope for this skill; that's the
calling agent/workflow's job. See `research-agent` /
`WORKFLOWS/research_workflow/` for the concrete integration.)

## Step 5: Gather data at the calibrated depth

Execute against the objective, evidence type(s), and depth decided above.
Keep the objective statement visible throughout — it's easy to drift into
gathering interesting-but-irrelevant data once research is underway.
Time-box consistent with Step 3; if the calibrated depth turns out to be
insufficient partway through, that's a signal to go back to the human and
renegotiate scope/depth/budget, not to silently keep digging past the
agreed constraints.

## Anti-patterns

- **Skipping Step 1** and jumping straight to gathering data on a vague
  topic — produces a pile of loosely-related findings instead of an answer
  to a specific question.
- **Defaulting to whichever evidence type is easiest to gather** instead of
  what the objective actually needs (e.g. reaching for a metric because
  it's measurable, when the real question was about *why*, not *how much*).
- **Ignoring Step 3 entirely** and researching until it "feels" thorough —
  depth should be a deliberate decision against real constraints, not a
  vibe.
- **Re-researching what's already known** by skipping Step 4.
