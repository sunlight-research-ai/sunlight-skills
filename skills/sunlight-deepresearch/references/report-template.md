# Deep Research Report Template

Use this template when synthesizing subagent findings into a final deliverable.

```md
# <Report Title>

## Executive Summary
<Short answer to the user's core question.>

## Research Scope
<What was investigated and what was intentionally excluded.>

## Key Findings
- <Finding with inline linked source or source tag.>
- <Finding with inline linked source or source tag.>
- <Finding with inline linked source or source tag.>

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
- [SRC_001] [<Title>](<https://...>)
- [SRC_002] [<Title>](<https://...>)
```

## Synthesis Rules
- Use a provided report template for section names and ordering.
- Let the user's explicit intent override the template when they conflict.
- Treat the user's requested sections and source constraints as required.
- Do not include unsupported claims as facts.
- Do not hide contradictions.
- Keep recommendations traceable to findings.
- Separate what sources say from what the agent infers.
- Every factual sentence should have an inline linked source or source tag.
- Every key finding sentence must have an inline linked source or source tag.
- Source tags may appear before sentence punctuation or immediately after it, but they must remain adjacent to the supported sentence.
- Keep citation tags attached to factual claims until they are resolved into links and a final source list.
- Do not write vague source labels such as "SEC filings", "earnings reports", or "developer surveys" without exact links.
- Run `scripts/evaluate-source-coverage.py` against the actual `final-report.md` before final delivery when a report file exists. If it fails, revise or research more instead of delivering.

## Strategy Rules
- Add recommendations only when requested or when the research objective clearly supports a decision.
- Ground recommendations in cited findings.
- State assumptions and risks.
- Do not turn weak evidence into strong strategic advice.
