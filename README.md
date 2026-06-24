# Sunlight Skills

Public agent skills from Sunlight Research.

This repository contains portable skills for Codex, Claude Code, OpenCode, and other agentic coding assistants. The first skill is `sunlight-deepresearch`, a deep research workflow based on subagent orchestration: plan the research, dispatch focused investigators, collect evidence, resolve conflicts, synthesize, and produce a sourced report.

## Quickstart

Install all skills into detected local agent skill directories:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash
```

Install for one target:

```bash
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target codex
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target claude
curl -fsSL https://raw.githubusercontent.com/sunlight-research-ai/sunlight-skills/main/install.sh | bash -s -- --target opencode
```

Supported targets:

- `codex` installs to `${CODEX_HOME:-$HOME/.codex}/skills`
- `claude` installs to `$HOME/.claude/skills`
- `opencode` installs to `$HOME/.config/opencode/skills`
- `all` installs to all three
- `auto` installs to detected directories, or all defaults when none exist

## Manual Installation

Clone the repository:

```bash
git clone https://github.com/sunlight-research-ai/sunlight-skills.git
cd sunlight-skills
```

Copy the skills into your agent's skills directory:

```bash
cp -R skills/* "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R skills/* "$HOME/.claude/skills/"
cp -R skills/* "$HOME/.config/opencode/skills/"
```

See the runtime-specific guides:

- [Codex](docs/README.codex.md)
- [Claude Code](docs/README.claude.md)
- [OpenCode](docs/README.opencode.md)

## What's Inside

### `sunlight-deepresearch`

Use when running, designing, or adapting a deep research workflow driven by subagents. It covers:

- research briefs and clarification
- research plan decomposition
- parallel investigator dispatch
- default `web_search` with optional Tavily, Exa, and Linkup enrichment
- source-tagged evidence collection
- compression, wave checkpoints, structured data extraction, report writing, and optional persistence

## Contributing

Contributions are welcome, especially new portable skills.

Each skill should live in `skills/<skill-name>/` and include:

- `SKILL.md` with valid YAML frontmatter
- optional `references/` for detailed guidance
- optional `scripts/` for reusable tools
- optional `agents/openai.yaml` for Codex-facing display metadata

Before opening a PR, read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

