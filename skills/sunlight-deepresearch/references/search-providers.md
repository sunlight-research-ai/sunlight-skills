# Search Providers

Use this reference when deciding how investigators should search.

## Default
Start with the model's built-in `web_search` or equivalent browsing/search capability. This is the baseline path and should work even when no external search API keys are configured.

Use the sources that default search exposes: official pages, news, documentation, public web pages, forums, social/community pages when available, and other model-accessible search results.

## Optional Providers
Use these only when the runtime has the provider tool installed and the API key is available.

| Provider | Typical key | Best for |
|----------|-------------|----------|
| Tavily | `TAVILY_API_KEY` | Keyword/freshness-oriented web search, news, blogs, product pages, changelogs, pricing pages, release notes |
| Exa | `EXA_API_KEY` | Semantic search, forum/community discussion, user sentiment, quote retrieval, less exact-match discovery |
| Linkup | `LINKUP_API_KEY` | Additional web search coverage when Linkup tooling is installed in the user's environment |

## Provider Rules
- Do not require optional providers.
- Do not ask the user for API keys unless the user wants to configure richer search.
- If optional providers are unavailable, continue with default web search.
- If multiple optional providers are available, use them to diversify evidence, not to repeat the same query blindly.
- Record provider failures only when they reduce confidence or leave a material gap.

## Practical Routing
- For official facts, pricing, release notes, changelogs, docs, and recent news: default `web_search`; optionally add Tavily.
- For user voice, community threads, sentiment, and hard-to-keyword phrasing: default `web_search`; optionally add Exa.
- For broader web coverage in environments that expose it: optionally add Linkup.
- For high-stakes or time-sensitive research: use at least two independent source paths when available.

