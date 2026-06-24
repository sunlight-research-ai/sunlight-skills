# Sunlight Skills Contributor Guide

This repository contains public agent skills. Changes should preserve portability across Codex, Claude Code, and OpenCode unless a skill explicitly documents a narrower runtime.

## For AI Agents

Before changing a skill:

1. Read the target `SKILL.md`.
2. Read any directly referenced files in `references/` that apply to the change.
3. Keep instructions concise and operational.
4. Do not add private Sunlight Platform paths, secrets, or assumptions.
5. Validate the changed skill before claiming completion.

## Pull Requests

Every PR should explain:

- which skill changed
- what user behavior should improve
- what runtime was tested
- what validation was run

New skills belong under `skills/<skill-name>/`.

