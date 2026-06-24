# Installing Sunlight Skills for OpenCode

Add Sunlight Skills to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["sunlight-skills@git+https://github.com/sunlight-research-ai/sunlight-skills.git"]
}
```

Restart OpenCode. The plugin registers the repository `skills/` directory.

Verify by using OpenCode's native `skill` tool to list available skills, then load `sunlight-deepresearch`.

If you also use Codex or Claude Code, install Sunlight Skills separately for each runtime.

