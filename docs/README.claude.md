# Sunlight Skills for Claude Code

## Install with curl

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target claude
```

This installs skills into:

```bash
$HOME/.claude/skills
```

## Manual install

```bash
git clone https://github.com/sunlight-research-ai/sunlight-skills.git
mkdir -p "$HOME/.claude/skills"
cp -R sunlight-skills/skills/* "$HOME/.claude/skills/"
```

Restart Claude Code or start a new session, then ask Claude to use `sunlight-deepresearch`.

## Optional API keys

`sunlight-deepresearch` works with the default `web_search` available to your agent. During install, the script asks one question at a time for optional Linkup, Exa, and Tavily keys. Press Enter to accept defaults or skip any provider.

Skip prompts during install:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target claude --no-api-key-setup
```

Run only key setup later:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --api-key-setup-only
```

You can also set keys manually before starting Claude Code:

```bash
export LINKUP_API_KEY="..."
export EXA_API_KEY="..."
export TAVILY_API_KEY="..."
```

Get keys here:

- Linkup: [app.linkup.so](https://app.linkup.so/) / [docs](https://docs.linkup.so/)
- Exa: [dashboard.exa.ai](https://dashboard.exa.ai/) / [docs](https://exa.ai/docs/reference/getting-started)
- Tavily: [app.tavily.com](https://app.tavily.com/) / [quickstart](https://docs.tavily.com/documentation/quickstart)

When optional providers are available, the skill uses them alongside default web search, merges results, and deduplicates sources before synthesis.
