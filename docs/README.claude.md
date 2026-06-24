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

