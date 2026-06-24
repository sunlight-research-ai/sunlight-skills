# Subagent Brief Template

Use this template when dispatching a focused research subagent.

```text
Research track: <short track name>

Objective:
<What this subagent should investigate. Keep it narrow.>

Context:
<Relevant background from the user request and any constraints.>

Questions to answer:
1. <Question>
2. <Question>
3. <Question>

Source requirements:
- Start with the model's default web_search and its available source coverage.
- Use Tavily, Exa, or Linkup only when the tool is available and credentials are configured.
- Continue with default web_search if optional provider keys are unavailable.
- Use primary sources where available.
- Prefer current sources when the topic is time-sensitive.
- Open and evaluate sources before relying on them.
- Include links or citations for factual claims.
- Assign stable source tags like [SRC_1], [SRC_2] to useful sources.
- Use the assigned source-tag range or prefix if provided.

Budget:
- Maximum search/tool iterations:
- Optional provider budget:
- Minimum useful sources:
- Stop condition:

Output format:
- Queries and sources used:
- Key findings:
- Evidence and sources:
- Conflicts or uncertainty:
- Inferences:
- Open questions:
- Confidence:
```

## Briefing Rules
- Do not ask a subagent to solve the entire research objective.
- Include only the context needed for the assigned track.
- Require uncertainty notes.
- Require source links when external facts are involved.
- Require source tags to stay attached to claims.
- Ask for concise findings that are easy to merge.
