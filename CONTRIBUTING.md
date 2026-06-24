# Contributing to Sunlight Skills

We welcome contributions of new skills and improvements to existing skills.

## What Makes a Good Skill

A good skill is portable, focused, and operational:

- It helps an agent perform a repeatable workflow.
- It has clear trigger language in `SKILL.md`.
- It avoids project-specific assumptions unless the skill is explicitly project-specific.
- It works across Codex, Claude Code, and OpenCode where possible.
- It separates concise core instructions from longer references.

## Skill Structure

Create each skill under `skills/<skill-name>/`:

```text
skills/
  skill-name/
    SKILL.md
    agents/
      openai.yaml
    references/
      detailed-guide.md
    scripts/
      helper-script.py
```

Required:

- `SKILL.md`
- YAML frontmatter with `name` and `description`
- lowercase hyphenated skill folder name

Recommended:

- `agents/openai.yaml` for Codex display metadata
- `references/` for longer documentation
- `scripts/` for deterministic helpers

Avoid:

- one-off personal notes
- long README files inside individual skills
- hidden dependencies on private systems
- claims that have not been tested in a real agent session

## Pull Request Checklist

Include the following in your PR:

- Skill purpose and intended audience
- Example user prompts that should trigger the skill
- Runtime tested: Codex, Claude Code, OpenCode, or other
- Validation steps run
- Any required or optional API keys/tools
- Screenshots or transcript excerpts when behavior matters

## Validation

If you have Codex's skill validator available, run:

```bash
python /path/to/skill-creator/scripts/quick_validate.py skills/<skill-name>
```

At minimum, manually verify:

- `SKILL.md` starts with valid YAML frontmatter
- `name` matches the folder name
- `description` starts with a clear "Use when..." trigger
- scripts run successfully or are documented as examples only

## Contribution Philosophy

Skills shape agent behavior. Treat them like executable process documentation:

- Be specific about what the agent must do.
- Include stop conditions and anti-patterns.
- Prefer evidence and verification over polished prose.
- Keep the public skill useful for people outside Sunlight's internal codebase.

