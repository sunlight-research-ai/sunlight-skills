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

