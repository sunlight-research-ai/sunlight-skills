# Research Plan Template

Use this template after creating the research brief and before dispatching subagents.

```md
# Research Plan

## Classification
<entity_comparison | market_analysis | claim_check | technical_scan | mixed>

## User Intent
<Preserve the user's goal in their own terms. Do not replace it with a narrower interpretation.>

## Constraints
- Recency:
- Required sources:
- Excluded sources:
- Output format:
- Named entities:
- Geography / market:
- Evaluation dimensions:
- Other constraints:

## Research Tracks

### Track 1: <title>
- Objective:
- Dimension:
- Named entities:
- Source hints:
- Questions to answer:
- Expected output:

### Track 2: <title>
- Objective:
- Dimension:
- Named entities:
- Source hints:
- Questions to answer:
- Expected output:

## Optional Context Track
<Add only when user/company/context-specific research helps explain why the findings matter. Otherwise write "none".>
```

## Planning Rules
- Preserve the user's requested output format.
- Do not collapse distinct entities into one broad track when they can be researched independently.
- Do not create duplicate tracks that ask different subagents to answer the same whole question.
- Keep source hints as guidance, not as a reason to ignore better primary sources.
- Add cross-cutting tracks only when they answer something entity-specific tracks will miss.

