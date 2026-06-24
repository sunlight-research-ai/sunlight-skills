# Sunlight Skills for Codex

## Install with curl

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target codex
```

This installs skills into:

```bash
${CODEX_HOME:-$HOME/.codex}/skills
```

## Manual install

```bash
git clone https://github.com/sunlight-research-ai/sunlight-skills.git
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R sunlight-skills/skills/* "${CODEX_HOME:-$HOME/.codex}/skills/"
```

Restart Codex or start a new session, then ask Codex to use `sunlight-deepresearch`.

## Optional API keys

`sunlight-deepresearch` works with the default `web_search` available to your agent. For richer source coverage, optionally set provider keys before starting your session:

```bash
export TAVILY_API_KEY="..."
export EXA_API_KEY="..."
export LINKUP_API_KEY="..."
```

Get keys here:

- Tavily: [app.tavily.com](https://app.tavily.com/) / [quickstart](https://docs.tavily.com/documentation/quickstart)
- Exa: [dashboard.exa.ai](https://dashboard.exa.ai/) / [docs](https://exa.ai/docs/reference/getting-started)
- Linkup: [app.linkup.so](https://app.linkup.so/) / [docs](https://docs.linkup.so/)

When optional providers are available, the skill uses them alongside default web search, merges results, and deduplicates sources before synthesis.

