# Persistence and Runtime Guidance

Use this reference when the user wants to implement deep research as a durable workflow instead of running it manually in one agent session.

## Runtime Budgets
Set budgets before dispatching research:
- Maximum concurrent investigators.
- Maximum research waves.
- Maximum searches or tool calls per investigator.
- Maximum optional provider calls per investigator.
- Maximum results per query.
- Maximum content length per source.
- Per-investigator timeout.
- Whole-run timeout.
- Rate-limit or token budget.

The four most important sizing controls are:
- Total run time.
- Number of waves.
- Parallel investigators per wave.
- Per-investigator search/tool budget.

## Search Provider Defaults
Default to the model's native `web_search` or equivalent browsing/search capability. Use optional providers only when credentials and tools are present:
- `TAVILY_API_KEY` for Tavily keyword/news/product-page search.
- `EXA_API_KEY` for Exa semantic/community/forum/social-style search.
- `LINKUP_API_KEY` for Linkup web search when installed in the user's environment.

Optional providers should enrich coverage; they should not be required for the workflow to run. If a provider is missing, rate-limited, or returns errors, continue with default web search and any successful providers, then record the limitation when it materially affects confidence. When multiple providers are available, fan out relevant queries across all of them, merge results, and deduplicate by canonical URL first, then normalized title/source/domain.

## Durable State
Persist enough state to resume, audit, cancel, retry, and explain the run:
- Research brief.
- Research plan.
- Subagent briefs.
- Raw investigator outputs.
- Compressed findings.
- Structured data.
- Source registry.
- Final report.
- Strategic analysis.
- Status and progress messages.
- Errors, partial failures, cancellation, and retry metadata.

## Source Registry
Use stable source IDs such as `[SRC_1]` throughout the workflow:
1. Register a source when a useful result is first inspected.
2. Attach the source ID to findings.
3. Preserve source IDs through compression and synthesis.
4. Resolve source IDs to links or a bibliography in the final report.

This prevents citations from drifting and makes it easier to audit claims.

Source IDs must be unique across the whole run. If investigators run independently, allocate ranges in advance, use track-prefixed IDs, or normalize IDs during merge before synthesis.

## Cancellation and Retry
For durable implementations:
- Check cancellation between stages and before starting expensive work.
- Mark partial progress before raising or stopping.
- Retry by creating a new run from the same brief and prior context, not by mutating completed outputs silently.
- Keep failed or partial investigator outputs visible so the final report can state limitations.

## LangGraph
LangGraph can implement this pattern with persisted state, runs, cancellation, and graph nodes. It is optional. The same mechanics can be implemented with a task queue, background jobs, local files, notebooks, or manual subagent dispatch.
