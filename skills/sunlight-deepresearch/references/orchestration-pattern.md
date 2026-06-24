# Deep Research Orchestration Pattern

Use this reference when the user wants to run or design a deep research workflow without assuming a codebase.

## Core Loop
1. Define the objective and output.
2. Decompose into independent tracks.
3. Dispatch focused subagents.
4. Collect structured findings.
5. Detect gaps, conflicts, and weak evidence.
6. Dispatch follow-up research where needed.
7. Synthesize.
8. Verify.
9. Deliver.

## Step 1: Start and Clarify
Before dispatching subagents, create a research brief. This brief becomes the contract for all later work.

Capture:
- User question.
- Audience.
- Decision the research should support.
- Entities, markets, competitors, claims, or topics in scope.
- Timeframe and recency needs.
- Required source types.
- Excluded sources or approaches.
- Desired output format.
- Success criteria.

If the brief is too vague to decompose into focused tracks, ask one concise clarifying question. If it is clear enough, proceed and use the brief to keep every subagent scoped to the same research objective.

## Step 2: Plan Research Tracks
Convert the research brief into a structured research plan before assigning work. Planning is not just splitting the topic; it preserves the user's intent and constraints so downstream subagents optimize for the right report.

Classify the request shape:
- `entity_comparison` - compare companies, products, people, countries, tools, or other named entities.
- `market_analysis` - map a market, trend, category, or ecosystem.
- `claim_check` - verify whether a claim is true, false, misleading, or uncertain.
- `technical_scan` - investigate implementation options, architectures, standards, or engineering tradeoffs.
- `mixed` - combine multiple shapes.

Extract constraints:
- Recency and timeframe.
- Required source types.
- Excluded sources, domains, or approaches.
- Desired output format.
- Named entities.
- Geography, market, segment, or audience.
- Any explicit evaluation dimensions.

Create one track per independently researchable unit. For entity comparisons, prefer one track per entity plus cross-cutting tracks only when needed. Add a user-context or self-comparison track only when it helps answer why the findings matter for the user.

A good research track is narrow enough for one subagent to investigate independently and broad enough to produce useful evidence.

## Research Tracks
Good tracks are narrow enough for one subagent to complete independently. Examples:
- Background and definitions.
- Current state of the market or field.
- Technical architecture or implementation options.
- Evidence for and against a claim.
- Risks, failure modes, and constraints.
- Competitive or alternative approaches.
- Source quality and fact-checking.

Avoid tracks that duplicate each other or ask every subagent to answer the whole question.

## Step 3: Dispatch Investigators
Assign each research track to one focused investigator subagent. Run investigators in parallel when the runtime supports it; otherwise run them sequentially while preserving separate outputs.

Set explicit budgets before dispatch:
- Maximum number of investigator subagents.
- Maximum search or tool iterations per investigator.
- Recency expectations.
- Minimum useful source threshold.
- Time or token limit.
- Failure condition for low-quality or unavailable sources.

The supervisor should dispatch one investigator per planned track, not one generalist subagent for the whole report. If there are more tracks than available parallel slots, queue the remaining tracks for the next dispatch round.

## Step 4: Investigate with Source-Tagged Evidence
Each investigator should work in a loop:
1. Choose the next query or source to inspect.
2. Open and evaluate the source, not just the search result snippet.
3. Record useful findings with stable source tags such as `[SRC_1]`.
4. Reflect on what is still missing.
5. Continue until the question is answered, evidence becomes repetitive, or the budget is reached.

Use the model's default `web_search` first. If Tavily, Exa, or Linkup credentials/tools are available, use them as optional supplemental search surfaces rather than hard requirements. Do not block or fail the workflow when those provider keys are unavailable; continue with default web search and whatever sources the model can access.

Investigator output should include:
- Queries or source paths used.
- Key findings.
- Source tags with links or source names.
- Conflicts or uncertainty.
- What could not be found.
- Confidence.

Prefer primary sources when available, then credible secondary sources. For time-sensitive topics, favor recent sources and state the cutoff or recency assumption.

Source tags must be unique across the full research run. In parallel workflows, either give each investigator a source-tag range or have the supervisor normalize source tags when merging outputs.

## Step 5: Compress Per-Investigator Findings
Compress each investigator's raw notes before synthesis. The compressor's job is not to write the final report; it turns messy evidence into a clean, source-preserving summary for one track.

Compression should:
- Preserve facts, numbers, dates, named entities, and short relevant quotes.
- Keep inline source tags attached to claims.
- Organize findings by theme.
- Keep uncertainty and failed searches visible.
- Avoid adding new claims not present in the investigator output.

If an investigator produced mostly errors, weak snippets, or unsupported findings, mark that track as partial or failed instead of pretending it succeeded.

## Step 6: Checkpoint and Decide on More Waves
After a wave of compressed summaries, review whether the original brief is answered. Do not move to final synthesis just because every planned track returned something.

Check:
- Does the evidence answer the user's primary question?
- Which required dimensions are covered?
- Which dimensions are missing, thin, or contradicted?
- Which claims need stronger sources?
- Which follow-up questions would materially improve the final answer?

Dispatch a follow-up wave only for material gaps or contradictions. Cap the number of waves before starting the run so research does not expand indefinitely.

## Step 7: Extract Structured Data
When the findings include hard numbers, dates, entities, rankings, prices, funding amounts, traffic estimates, benchmark metrics, or named facts, extract them into structured rows before writing the final report.

Structured extraction is useful for:
- Comparison tables.
- Charts.
- Evidence audits.
- Claim verification.
- Reusing facts in later workflows.

Do not extract unsupported facts. Every row should point back to a source tag, source URL, or named source.

## Step 8: Generate the Report
Write the report from compressed findings and structured data, not from raw search snippets alone.

Priority order:
1. Any provided report template for section names and ordering.
2. The user's explicit intent when it conflicts with or extends the template.
3. The user's requested output format and required sections.
4. The evidence actually found.

Every factual claim should have a citation or be clearly labeled as inference. Keep source tags attached through the draft and resolve them to links or a source list before final delivery.

## Step 9: Add Strategic Implications
Add recommendations, risks, and "so what" analysis only when the user wants decisions, strategy, prioritization, or next steps.

Strategic analysis should:
- Be grounded in the findings.
- State assumptions.
- Explain tradeoffs.
- Separate recommendations from evidence.
- Be framed for the user's audience, market, company, or decision context when provided.

If the research does not support a recommendation, say so and provide the missing evidence needed.

## Step 10: Package or Persist the Result
Finish by packaging the final artifact in the form the user needs: markdown report, memo, table, implementation plan, dataset, or durable application state.

For manual agent workflows, return:
- Final report.
- Sources.
- Structured data when useful.
- Confidence and limitations.
- Follow-up questions.

For durable product workflows, persist:
- Research brief.
- Research plan.
- Subagent briefs and outputs.
- Source registry.
- Compressed findings.
- Structured data.
- Final report.
- Strategic analysis.
- Status, cancellation, retry, and error metadata.

## Quality Gates
Before synthesis, check:
- Each important claim has a source or is labeled as inference.
- Sources are current enough for the question.
- Conflicting claims are listed explicitly.
- Weak, unavailable, or paywalled evidence is called out.
- Follow-up questions are dispatched for material gaps.

Before final delivery, check:
- The report answers the original objective.
- The level of detail matches the user's requested format.
- Evidence, inference, and recommendations are distinguishable.
- Confidence and limitations are stated plainly.

See `persistence-and-runtime.md` for implementation-oriented runtime guidance.
