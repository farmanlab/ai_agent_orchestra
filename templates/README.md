# Agent Configuration

This directory is managed by [AI Agent Orchestra](https://github.com/your-org/ai-agent-orchestra).

## Structure

```
rules/      Rule definitions (applied to all agents)
agents/     Sub-agent definitions
commands/   Slash command definitions
skills/     Skill definitions
scripts/    Sync and validation scripts
templates/  File templates
plugins/    Imported plugin components
config.yaml Agent enable/disable settings
```

## Sync

```bash
# Sync to all enabled agents
aao sync

# Sync to a specific agent
aao sync claude
aao sync copilot

# Validate configuration
aao validate

# Check prompt quality
aao check-quality
```

## Adding Rules

Create a new `.md` file in `rules/`:

```yaml
---
description: Enforces X. Use when Y.
paths: "**/*.{ts,tsx}"
---

# Rule Title

Your rule content here.
```

Then run `aao sync` to propagate to all agents.
