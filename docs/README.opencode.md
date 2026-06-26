# Sunlight Skills for OpenCode

## Install with curl

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target opencode
```

This installs skills into:

```bash
$HOME/.config/opencode/skills
```

## Plugin install

Add Sunlight Skills to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["sunlight-skills@git+https://github.com/sunlight-research-ai/sunlight-skills.git"]
}
```

Restart OpenCode. The plugin registers all skills from this repository.

## Manual install

```bash
git clone https://github.com/sunlight-research-ai/sunlight-skills.git
mkdir -p "$HOME/.config/opencode/skills"
cp -R sunlight-skills/skills/* "$HOME/.config/opencode/skills/"
```

Use OpenCode's native `skill` tool to list and load `sunlight-deepresearch`.

## Optional API keys

`sunlight-deepresearch` works with the default `web_search` available to your agent. During install, the script asks one question at a time for optional Linkup, Exa, and Tavily keys. Press Enter to accept defaults or skip any provider.

Skip prompts during install:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target opencode --no-api-key-setup
```

Run only key setup later:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --api-key-setup-only
```

You can also set keys manually before starting OpenCode:

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
