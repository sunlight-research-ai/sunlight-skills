# Deep Research Report Template

Use this template when synthesizing subagent findings into a final deliverable.

```md
# <Report Title>

## Executive Summary
<Short answer to the user's core question.>

## Research Scope
<What was investigated and what was intentionally excluded.>

## Key Findings
- <Finding with source or evidence note.>
- <Finding with source or evidence note.>
- <Finding with source or evidence note.>

## Evidence Review
<Summarize source quality, freshness, and coverage.>

## Structured Data
<Include tables or extracted metrics when useful. Omit if not applicable.>

## Conflicts and Uncertainty
<List material disagreements, weak evidence, or unresolved questions.>

## Analysis
<Synthesize evidence into a coherent answer. Label inference clearly.>

## Recommendations
<Actionable next steps when the user requested decisions or strategy.>

## Confidence
<High, medium, or low, with a short reason.>

## Sources
- <Source>
- <Source>
- <Source>
```

## Synthesis Rules
- Use a provided report template for section names and ordering.
- Let the user's explicit intent override the template when they conflict.
- Treat the user's requested sections and source constraints as required.
- Do not include unsupported claims as facts.
- Do not hide contradictions.
- Keep recommendations traceable to findings.
- Separate what sources say from what the agent infers.
- Keep citation tags attached to factual claims until they are resolved into links or a final source list.

## Strategy Rules
- Add recommendations only when requested or when the research objective clearly supports a decision.
- Ground recommendations in cited findings.
- State assumptions and risks.
- Do not turn weak evidence into strong strategic advice.
