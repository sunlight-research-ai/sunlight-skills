# Subagent Brief Template

Use this template when dispatching a focused research subagent.

```text
Research track: <short track name>

Objective:
<What this subagent should investigate. Keep it narrow.>

Context:
<Relevant background from the user request and any constraints.>

Artifact paths:
- Run folder:
- Source registry:
- Per-source files:
- Raw notes file:
- Compressed findings file:

Questions to answer:
1. <Question>
2. <Question>
3. <Question>

Source requirements:
- Treat this as thorough research; do not do a shallow search pass.
- Start with the model's default web_search and its available source coverage.
- Use all available optional providers: Linkup, Exa, and Tavily when their tools and credentials are configured.
- Before searching, create provider-appropriate query variants instead of sending the same wording to every provider.
- Continue with default web_search and any successful optional providers if one provider is unavailable or fails.
- Merge provider outputs and deduplicate sources before reporting findings.
- Use primary sources where available.
- Prefer current sources when the topic is time-sensitive.
- Open and evaluate sources before relying on them.
- Include links or citations for factual claims.
- Assign stable source tags like [SRC_1], [SRC_2] to useful sources.
- Use the assigned source-tag range or prefix if provided.
- Give the same source one stable source tag even if multiple providers return it.
- Aim for 12-20 unique useful sources for broad tracks when available; if fewer, explain source scarcity and the searches attempted.
- For every useful opened link, immediately update `source-registry.md` and create or update a `sources/SRC_NNN.md` evidence file.
- Do not include a factual claim in findings unless it has an inline source tag that resolves to a linked source.

Query plan:
- Orientation:
- Official/source-of-truth:
- Fresh/current:
- User voice/community:
- Metrics/benchmarks:
- Criticism/counterevidence:

Budget:
- Maximum search/tool iterations:
- Optional provider budget:
- Minimum useful sources: 12-20 unique useful sources for broad tracks when available.
- Stop condition: all relevant query-plan categories attempted, source classes checked, counterevidence searched, contradictions documented, and additional searching unlikely to change the answer.

Output format:
- Queries and sources used:
- Coverage matrix:
  - Query type:
  - Queries attempted:
  - Sources found:
  - Source class:
  - Gaps remaining:
- Source registry updates:
  - Source ID:
  - URL:
  - Claims supported:
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
- Require provider outputs to be merged and deduplicated before findings are reported.
- Require artifact files to be updated before findings are returned.
- Ask for concise findings that are easy to merge.
