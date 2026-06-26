# Search Providers

Use this reference when deciding how investigators should search.

## Default
Start with the model's built-in `web_search` or equivalent browsing/search capability. This is the baseline path and should work even when no external search API keys are configured.

Tell the user that default search works, but research is richer when Linkup, Exa, and Tavily keys are configured because the agent can compare more source paths and reduce blind spots.

## Optional Provider Setup
Use optional providers when the runtime has the provider tool installed and the API key is available.

| Provider | Key | Where to get it | Best for |
|----------|-----|-----------------|----------|
| Linkup | `LINKUP_API_KEY` | [Linkup app](https://app.linkup.so/) / [Docs](https://docs.linkup.so/) | Additional web coverage and AI-oriented search/fetch/research workflows when Linkup tooling is installed |
| Exa | `EXA_API_KEY` | [Exa Dashboard](https://dashboard.exa.ai/) / [Docs](https://exa.ai/docs/reference/getting-started) | Semantic search, forum/community discussion, user sentiment, quote retrieval, less exact-match discovery |
| Tavily | `TAVILY_API_KEY` | [Tavily Platform](https://app.tavily.com/) / [Quickstart](https://docs.tavily.com/documentation/quickstart) | Keyword/freshness-oriented web search, news, blogs, product pages, changelogs, pricing pages, release notes |

Do not ask for keys before starting every task. Mention them when onboarding a new user, when research quality matters, or when optional providers are missing and richer coverage would materially help.

Before dispatching investigators, check what the current runtime can actually use:

```bash
python3 skills/sunlight-deepresearch/scripts/search-providers.py --check
```

If the skill is installed outside the current project, use the installed path, for example:

```bash
python3 ~/.codex/skills/sunlight-deepresearch/scripts/search-providers.py --check
```

The provider script reads keys from the live process environment first, then common env files and shell exports: `SUNLIGHT_SEARCH_ENV`, `.env`, `.env.local`, `.sunlight.env`, `~/.sunlight-skills.env`, `~/.zshrc`, `~/.bashrc`, and `~/.profile`. This lets a running agent use keys saved by the installer or stored in a project env file even if the agent process was not restarted after the keys were added.

## Provider Rules
- Default `web_search` is always acceptable.
- When Linkup, Exa, or Tavily are available, use all available providers for relevant high-value queries.
- If provider-specific MCP/tools are not exposed, call the bundled script:
  `python3 skills/sunlight-deepresearch/scripts/search-providers.py "<query>" --provider all --json`
- `--provider all` must attempt every configured provider; do not let the model choose only one provider when multiple keys are present.
- Merge provider outputs into one evidence set before compression and synthesis.
- Deduplicate by canonical URL first using the same rules as the Sunlight backend SourceRegistry: normalize scheme to `https`, strip `www.`, strip fragments and trailing slashes, remove tracking params such as `utm_*`, `gclid`, `fbclid`, and `ref`, and preserve meaningful query params. If URL is missing, deduplicate by normalized title, source name, and domain.
- When the same source appears from multiple providers, keep one source row and preserve all provider labels in notes or the source registry.
- Preserve one stable source ID per deduplicated source.
- Keep provider labels in notes when they help explain source provenance.
- If one provider fails or is missing, continue with the successful providers and default `web_search`.
- Record provider failures only when they reduce confidence or leave a material gap.

## Thorough Search Standard
Every `sunlight-deepresearch` investigation should be thorough. Do not run a shallow search pass.

For each broad research track, aim for 12-20 unique useful sources when the web has enough material. Use fewer only when the investigator records scarcity and the specific query variants attempted.

Do not stop just because:
- 3 sources were found.
- the first page of results looks plausible.
- multiple sources repeat the same obvious fact.
- default `web_search` returned a concise answer.

Stop only when:
- the relevant query-pack categories have been attempted,
- at least three distinct source classes have been checked when applicable,
- counterevidence or criticism has been searched for,
- important contradictions have been resolved or documented,
- another query is unlikely to change the answer.

When results are too few, too obvious, or too homogeneous, pivot instead of synthesizing. Change at least one of: entity alias, source type, timeframe, geography, positive/negative framing, metric name, community surface, or provider.

## Query Strategy
Do not send the same query blindly to every provider. For each research track, create a small query pack before searching. Fill only the query types that fit the task:

- Orientation: broad query to map the topic and vocabulary.
- Official/source-of-truth: primary domains, docs, filings, changelogs, pricing pages, regulator pages, journal pages, or company pages.
- Fresh/current: recent news, release notes, product updates, pricing changes, outages, funding, hiring, regulation, or market moves.
- User voice/community: Reddit, forums, app stores, Trustpilot, G2/Capterra, ProductHunt, YouTube comments, X/Twitter, LinkedIn, or community discussions.
- Metrics/benchmarks: revenue, ARR, funding, market size, CAGR, unit economics, benchmarks, filings, analyst reports, surveys, or cited datasets.
- Criticism/counterevidence: complaints, churn, lawsuits, failure cases, limitations, negative reviews, security incidents, and contradictory claims.

Route query variants by provider strength:

- Use default `web_search` for balanced discovery, official-source lookup, and opening sources.
- Use Tavily for exact, fresh, keyword-heavy searches: pricing, changelogs, release notes, official docs, product pages, news, funding, benchmarks, and named facts.
- Use Exa for semantic and user-voice searches: forum threads, ProductHunt comments, user sentiment, social/community discussion, hard-to-keyword phrasing, and quote discovery.
- Use Linkup as an additional recall/fetch path for the highest-value queries when installed.

When using the bundled script, choose provider-specific query variants and run them separately rather than sending one generic query:

```bash
python3 skills/sunlight-deepresearch/scripts/search-providers.py "official pricing changelog <entity>" --provider tavily --json
python3 skills/sunlight-deepresearch/scripts/search-providers.py "user complaints forum discussion <entity>" --provider exa --json
python3 skills/sunlight-deepresearch/scripts/search-providers.py "high quality sources about <entity> strategy risks" --provider linkup --json
```

Use `--max-results 2` or `--max-results 3` for smoke tests and `--max-results 5` or more during real investigator sweeps.

Prefer query diversity over repeated wording. Vary entity names, aliases, source type, timeframe, geography, product/category terms, positive framing, negative framing, and neutral framing.

Use concise keyword or noun-phrase queries for Tavily/Exa-style search. Avoid Boolean operators, `site:` filters, quoted exact-match, one-word queries, and keyword stuffing unless the active provider explicitly supports them.

Avoid aggregate questions the public web cannot answer directly, such as "what percentage of users did X?" Reframe them as "documented examples of X", "specific named cases of X", or "published surveys/data on X".

After results return:
- Open and evaluate sources before treating them as evidence.
- Deduplicate across providers before synthesis.
- If all providers return similar sources, run one or two follow-up queries with different framing.
- If providers disagree, search specifically for the contradiction.
- Treat social/community sources as valid for user voice, but weak for market sizing, financial, regulatory, or factual claims.
- Prefer primary and reputable secondary sources for numbers, regulation, financials, and factual claims.

## Practical Routing
- For official facts, pricing, release notes, changelogs, docs, and recent news: default `web_search`; add Tavily when available.
- For user voice, community threads, sentiment, and hard-to-keyword phrasing: default `web_search`; add Exa when available.
- For broader web coverage or AI-oriented search/fetch workflows: add Linkup when available.
- For high-stakes or time-sensitive research: use at least two independent source paths when available.

## Dimension Hints
- Market sizing: search for TAM/SAM/SOM, market size, CAGR, segment breakdowns, regional splits, forecasts, primary datasets, reputable analyst reports, and cited surveys.
- Financial benchmarks: search for CAC/LTV, gross margin, valuation multiples, growth benchmarks, pricing benchmarks, public filings, investor materials, and analyst databases.
- Competitor financials: search for revenue, ARR, MRR, funding rounds, valuations, headcount, customer counts, margins, and named operating metrics.
- Competitive landscape: search for product pages, feature launches, integrations, partnerships, positioning, customer segments, category pages, and comparison pages.
- Regulatory: search for regulator pages, enforcement actions, statutory language, official guidance, licensing requirements, compliance deadlines, and jurisdiction-specific sources.
- User voice: search for direct quotes, complaint themes, praise themes, rating distributions, migration stories, churn reasons, app reviews, forums, social posts, and review platforms.
