---
name: scientific-method
description: Apply systematic hypothesis-driven thinking to problem solving, requirements gathering, and design decisions. Use when gathering requirements, validating assumptions, making design decisions, debugging issues, or any situation requiring rigorous analytical thinking. Triggers on needing to "understand requirements", "validate assumptions", "analyze options", "debug systematically", or when facing complex decisions with uncertainty.
---

# Scientific Method

Apply rigorous, hypothesis-driven thinking to software development challenges. This skill helps you systematically validate assumptions, make informed decisions, and avoid common reasoning pitfalls.

## Core Principle

**Don't assume. Hypothesize, test, conclude.**

Every significant decision or understanding should follow:
1. **Observe** - What do we actually know?
2. **Hypothesize** - What do we think is true?
3. **Predict** - If hypothesis is true, what should we see?
4. **Test** - Check the prediction
5. **Conclude** - Update understanding based on results

## Application Areas

### Requirements Gathering

Instead of assuming you understand what the user wants:

```
OBSERVE: User said "I need a dashboard"

HYPOTHESIZE: User wants to see key metrics at a glance

PREDICT: If true, user should be able to identify:
- Which metrics matter most
- How often they need to see them
- What decisions the metrics inform

TEST: Ask clarifying questions:
- "What decisions will you make based on this dashboard?"
- "Which metrics are most important to see first?"
- "How often do you need to check these?"

CONCLUDE: User actually needs real-time alerts, not a dashboard.
          They want to be notified when metrics exceed thresholds.
```

### Design Decisions

Instead of assuming a solution is best:

```
OBSERVE: We need to store user sessions

HYPOTHESIZE: Redis is the best choice for session storage

PREDICT: If Redis is best, it should:
- Handle our expected load
- Fit our infrastructure
- Be cost-effective
- Match team expertise

TEST: 
- Calculate expected session volume
- Check if Redis fits current infrastructure
- Compare costs with alternatives
- Assess team familiarity

CONCLUDE: Redis is overkill. Database sessions with caching
          meet our needs and reduce infrastructure complexity.
```

### Debugging

Instead of randomly trying fixes:

```
OBSERVE: Users report intermittent login failures

HYPOTHESIZE: Session tokens are expiring prematurely

PREDICT: If true, we should see:
- Failures correlate with time since login
- Token expiration logs
- Success after re-login

TEST:
- Check logs for expiration patterns
- Compare failure times to token lifetimes
- Reproduce with short-lived tokens

CONCLUDE: Hypothesis incorrect. Actually a race condition
          in the OAuth callback handler.
```

## Questioning Techniques

### For Requirements

Ask questions that test your understanding:

**Clarifying Questions:**
- "When you say X, do you mean A or B?"
- "Can you give me an example of when you would use this?"
- "What happens if [edge case]?"

**Boundary Questions:**
- "What's the minimum acceptable version of this?"
- "What would make this a failure even if it 'works'?"
- "What's explicitly NOT part of this?"

**Motivation Questions:**
- "What problem does this solve?"
- "What are you doing today without this?"
- "Who else cares about this?"

**Prediction Questions:**
- "If we build this, what changes for you?"
- "How will you know it's working?"
- "What metrics would improve?"

### For Design

**Assumption Questions:**
- "What are we assuming about [X]?"
- "What if [assumption] is wrong?"
- "How would we know if this assumption fails?"

**Alternative Questions:**
- "What other approaches could solve this?"
- "Why is this better than [alternative]?"
- "What would we lose by choosing differently?"

**Risk Questions:**
- "What could go wrong?"
- "What's the worst case?"
- "How do we recover if this fails?"

## Cognitive Biases to Avoid

### Confirmation Bias
**Problem:** Seeking evidence that confirms what you already believe.
**Solution:** Actively look for disconfirming evidence. Ask "What would prove me wrong?"

### Anchoring
**Problem:** Over-relying on first piece of information received.
**Solution:** Gather multiple data points before deciding. Revisit initial assumptions.

### Sunk Cost Fallacy
**Problem:** Continuing because of past investment, not future value.
**Solution:** Ask "If starting fresh today, would we choose this path?"

### Availability Heuristic
**Problem:** Overweighting recent or memorable examples.
**Solution:** Seek systematic data, not anecdotes. Ask "Is this representative?"

### Bandwagon Effect
**Problem:** Choosing something because others chose it.
**Solution:** Evaluate based on your specific context and needs.

### Overconfidence
**Problem:** Being too certain about uncertain things.
**Solution:** Explicitly state confidence levels. Identify unknowns.

## Structured Decision Making

### For Binary Decisions

```markdown
## Decision: [What we're deciding]

### Option A: [Description]
**Evidence For:**
- [Point 1]
- [Point 2]

**Evidence Against:**
- [Point 1]
- [Point 2]

**Unknowns:**
- [What we don't know]

### Option B: [Description]
[Same structure]

### Analysis
- Strength of evidence: A [strong/moderate/weak] vs B [strong/moderate/weak]
- Reversibility: [Can we change our mind later?]
- Cost of being wrong: [What happens if we choose wrong?]

### Decision
[Choice] because [reasoning]

### Validation
We'll know this was right if [observable outcome]
We'll know this was wrong if [observable outcome]
```

### For Multiple Options

```markdown
## Decision: [What we're deciding]

### Criteria (weighted)
| Criterion | Weight | Why This Weight |
|-----------|--------|-----------------|
| [Criterion 1] | [1-5] | [Reasoning] |
| [Criterion 2] | [1-5] | [Reasoning] |

### Options Evaluated
| Option | C1 Score | C2 Score | ... | Weighted Total |
|--------|----------|----------|-----|----------------|
| A | [1-5] | [1-5] | | [calculated] |
| B | [1-5] | [1-5] | | [calculated] |

### Qualitative Factors
[Things that don't fit the matrix but matter]

### Decision
[Choice] because [reasoning]
```

## Validation Checkpoints

Build validation into your process:

### After Requirements
- [ ] Can I explain this to someone else?
- [ ] Have I identified assumptions?
- [ ] Have I tested my understanding with the stakeholder?
- [ ] Do I know what success looks like?

### After Design
- [ ] Have I considered alternatives?
- [ ] Have I identified risks?
- [ ] Have I validated assumptions are still true?
- [ ] Can I explain why this design, not another?

### After Implementation
- [ ] Does it actually solve the stated problem?
- [ ] Have edge cases been handled?
- [ ] Would I be surprised by any behavior?

## Anti-Patterns

### "Obvious" Solutions
**Problem:** Jumping to solutions without validating the problem.
**Better:** Spend more time on problem definition. "Obvious" solutions often solve the wrong problem.

### Analysis Paralysis
**Problem:** Endless research without deciding.
**Better:** Set time boxes. Accept "good enough" information. Decide and iterate.

### Argument from Authority
**Problem:** "X said so, therefore it's true."
**Better:** Evaluate the reasoning, not the source. Even experts are wrong sometimes.

### False Dichotomy
**Problem:** "We must choose A or B."
**Better:** Ask "Are there other options?" Often there's a C, or a combination.

## Summary

1. **State assumptions explicitly** - You can't test hidden assumptions
2. **Ask "How would I know if I'm wrong?"** - Every belief should be falsifiable
3. **Seek disconfirming evidence** - Actively look for reasons you might be wrong
4. **Update based on evidence** - Change your mind when facts warrant it
5. **Validate with stakeholders** - Your understanding isn't truth until confirmed
6. **Document reasoning** - Future you needs to know why, not just what
