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

