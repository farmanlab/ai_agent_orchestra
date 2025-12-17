# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **AI Agent Orchestra** - a unified management system for AI coding agent configurations (Claude Code, Cursor, GitHub Copilot). The core principle is "Single Source of Truth": all agent configurations are defined once in `.agents/` and automatically converted to each agent's specific format.

## Key Architecture

### Single Source of Truth Pattern

```
.agents/                    # Edit these files
├── rules/                  # Unified rule definitions
├── skills/                 # Unified skill definitions
├── agents/                 # Unified subagent definitions
└── commands/               # Unified slash command definitions

↓ Sync via .agents/sync/sync.sh

.claude/                    # Auto-generated for Claude Code
.cursor/                    # Auto-generated for Cursor
.github/                    # Auto-generated for GitHub Copilot
AGENTS.md                   # Auto-generated (Copilot agents)
```

**Critical**: Never edit files in `.claude/`, `.cursor/`, `.github/`, or `AGENTS.md` directly. Always edit source files in `.agents/` and run sync.

### Format Conversion Rules

Each agent requires different frontmatter formats:

**Rules (.agents/rules/*.md)**:
- Source format: `paths` as YAML array + metadata (`name`, `agents`, `priority`)
- Claude: Keeps YAML array format
- Cursor: Converts to `globs` as comma-separated single line + only `description` and `alwaysApply`
- Copilot: Converts to `applyTo` as comma-separated single line

**Cursor-specific rules**:
- `alwaysApply: false` when `description` OR `globs` exists
- When both `description` and `globs` exist, `globs` determines file scope
- Unneeded fields (`name`, `triggers`, `agents`, `priority`) are auto-removed

**Skills (.agents/skills/{name}/SKILL.md)**:
- Source format: Includes `name`, `description`, `triggers`, `agents`, `allowed-tools`
- Claude: Converts to only `name`, `description`, `allowed-tools` (triggers/agents removed)
- Cursor: Converts to RULE.md with only `description` and `alwaysApply`
- Copilot: Not supported (no auto-loading triggers)

## Essential Commands

### Sync Operations

```bash
# Sync to all agents (run this after editing .agents/)
.agents/sync/sync.sh all

# Sync to specific agent
.agents/sync/sync.sh claude
.agents/sync/sync.sh cursor
.agents/sync/sync.sh copilot

# See what would change without modifying files
.agents/sync/sync.sh --dry-run all

# Verbose output for debugging
.agents/sync/sync.sh --verbose all
```

### Validation

Validate `.agents/` structure and content before syncing:

```bash
# Validate configuration files
.agents/sync/sync.sh validate
```

**Validation checks**:
- Directory structure (existence of rules, skills, agents, commands)
- Required frontmatter fields (name, description, agents, etc.)
- Value validity (agents field must be claude/cursor/copilot, priority must be numeric)
- File naming conventions
- YAML syntax (frontmatter delimiters)
- Skills structure (SKILL.md existence)

Returns exit code 1 if errors found, 0 if only warnings or success.

### Setup and Maintenance

```bash
# Initialize directory structure
.agents/sync/sync.sh init

# Install git pre-commit hook for auto-sync
.agents/sync/sync.sh install-hooks

# Clean all generated files
.agents/sync/sync.sh clean

# Grant execution permissions if needed
chmod +x .agents/sync/*.sh
```

## Workflow for Making Changes

1. Edit source files in `.agents/rules/`, `.agents/skills/`, `.agents/agents/`, or `.agents/commands/`
2. Run `.agents/sync/sync.sh all` to convert to all agent formats
3. Commit both source files (`.agents/`) and generated files (`.claude/`, `.cursor/`, `.github/`, etc.)

**Example - Adding a new rule**:

```bash
# 1. Create rule in unified format
cat > .agents/rules/my-rule.md << 'EOF'
---
name: my-rule
description: My custom rule
paths:
  - "**/*.ts"
agents: [claude, cursor, copilot]
priority: 80
---

# My Custom Rule
...
EOF

# 2. Sync to convert formats
.agents/sync/sync.sh all

# 3. Commit everything
git add .agents/ .claude/ .cursor/ .github/
git commit -m "Add my-rule"
```

## Important Implementation Details

### Progressive Disclosure (Skills)

Skills use progressive disclosure with reference files:

```
.agents/skills/code-review/
├── SKILL.md          # Entry point
├── checklist.md      # Referenced from SKILL.md
└── patterns.md       # Referenced from SKILL.md
```

When converted:
- Claude: SKILL.md frontmatter converted (only `name`, `description`, `allowed-tools`), supplementary files symlinked
- Cursor: SKILL.md → RULE.md (frontmatter converted to `description`, `alwaysApply`), supplementary files symlinked
- Copilot: Not supported

### Frontmatter Transformation Logic

The sync scripts (`to-claude.sh`, `to-cursor.sh`, `to-copilot.sh`) use AWK to parse and transform YAML frontmatter:

- Track which fields are present (`has_description`, `has_paths`)
- Buffer and filter fields based on target agent requirements
- Convert array formats (YAML arrays ↔ comma-separated)
- Auto-compute `alwaysApply` for Cursor based on field presence

**Agent-specific field requirements**:
- Claude skills: `name`, `description`, `allowed-tools`
- Cursor rules/skills: `description`, `alwaysApply`, `globs` (comma-separated)
- Copilot: `applyTo` (comma-separated)

### File Naming Conventions

- `.agents/rules/_base.md` → Base rules that apply to all files
- `.agents/rules/{domain}.md` → Domain-specific rules (architecture, testing, etc.)
- `.agents/skills/{skill-name}/SKILL.md` → Skill entry point
- `.agents/agents/{agent-name}.md` → Subagent definitions
- `.agents/commands/{command-name}.md` → Slash command definitions

## Cross-Platform Compatibility

### Cursor Format Specifics

Cursor v2.2+ uses `.cursor/rules/{name}/RULE.md` format:
- Supports progressive disclosure via directory structure
- Only accepts `description`, `alwaysApply`, `globs` in frontmatter
- `globs` must be comma-separated single line (not YAML array)
- `alwaysApply` logic: false when `description` OR `globs` exist

## Troubleshooting

### Sync Script Fails
- Check execution permissions: `chmod +x .agents/sync/*.sh`
- Run with verbose flag: `.agents/sync/sync.sh --verbose all`
- Verify YAML frontmatter is valid (must start/end with `---`)

### Changes Not Reflected in Agent
- **Claude Code**: Start new session
- **Cursor**: Restart application
- **GitHub Copilot**: Reload VS Code window

### Frontmatter Format Errors
- Ensure `---` delimiters on separate lines
- Use proper YAML syntax (2-space indent for arrays)
- Check that field names match expected format for each agent
