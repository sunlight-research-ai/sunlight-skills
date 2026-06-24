# Search Providers

Use this reference when deciding how investigators should search.

## Default
Start with the model's built-in `web_search` or equivalent browsing/search capability. This is the baseline path and should work even when no external search API keys are configured.

Tell the user that default search works, but research is richer when Tavily, Exa, and Linkup keys are configured because the agent can compare more source paths and reduce blind spots.

## Optional Provider Setup
Use optional providers when the runtime has the provider tool installed and the API key is available.

| Provider | Key | Where to get it | Best for |
|----------|-----|-----------------|----------|
| Tavily | `TAVILY_API_KEY` | [Tavily Platform](https://app.tavily.com/) / [Quickstart](https://docs.tavily.com/documentation/quickstart) | Keyword/freshness-oriented web search, news, blogs, product pages, changelogs, pricing pages, release notes |
| Exa | `EXA_API_KEY` | [Exa Dashboard](https://dashboard.exa.ai/) / [Docs](https://exa.ai/docs/reference/getting-started) | Semantic search, forum/community discussion, user sentiment, quote retrieval, less exact-match discovery |
| Linkup | `LINKUP_API_KEY` | [Linkup app](https://app.linkup.so/) / [Docs](https://docs.linkup.so/) | Additional web coverage and AI-oriented search/fetch/research workflows when Linkup tooling is installed |

Do not ask for keys before starting every task. Mention them when onboarding a new user, when research quality matters, or when optional providers are missing and richer coverage would materially help.

## Provider Rules
- Default `web_search` is always acceptable.
- When Tavily, Exa, or Linkup are available, use all available providers for relevant queries.
- Merge provider outputs into one evidence set before compression and synthesis.
- Deduplicate by canonical URL first; if URL is missing, deduplicate by normalized title, source name, and domain.
- Preserve one stable source ID per deduplicated source.
- Keep provider labels in notes when they help explain source provenance.
- If one provider fails or is missing, continue with the successful providers and default `web_search`.
- Record provider failures only when they reduce confidence or leave a material gap.

## Practical Routing
- For official facts, pricing, release notes, changelogs, docs, and recent news: default `web_search`; add Tavily when available.
- For user voice, community threads, sentiment, and hard-to-keyword phrasing: default `web_search`; add Exa when available.
- For broader web coverage or AI-oriented search/fetch workflows: add Linkup when available.
- For high-stakes or time-sensitive research: use at least two independent source paths when available.
