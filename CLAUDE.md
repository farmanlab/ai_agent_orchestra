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

### Size Check

Check file sizes and token counts to prevent prompt bloat:

```bash
# Check prompt sizes
.agents/sync/sync.sh check-size
```

**Metrics**:
- Line count, character count, byte size per file
- Estimated token count (1 token ≈ 4 characters)
- Category breakdown (rules, skills, agents, commands)
- Total token count across all files

**Default thresholds**:
- Single file warning: 500 lines or 2000 tokens
- Single file error: 1000 lines or 4000 tokens
- Total warning: 10000 tokens
- Total error: 20000 tokens

Exceeding thresholds triggers recommendations to split files or use progressive disclosure.

### Quality Check

Verify prompt construction against official best practices:

```bash
# Quick static check
.agents/sync/check-quality
```

**Validation Criteria**:
1. **Clarity**: Detect vague language ("maybe", "consider", etc.)
2. **Structure**: Proper heading hierarchy and organization
3. **Examples**: Presence of concrete code examples
4. **Scope**: Repository-level guidance, not task-specific
5. **Progressive Disclosure**: Appropriate separation of details
6. **No Duplication**: Avoid redundant or conflicting instructions
7. **File Naming**: Names clearly reflect purpose
8. **Action-Oriented**: Executable instructions with verbs
9. **Metadata**: Complete frontmatter fields
10. **Tone**: Consistent professional style

**Best Practice Compliance**:
- Cursor: Keep rules under 500 lines, include concrete examples
- GitHub Copilot: Max 2 pages, not task-specific, clear and concise
- Claude Code: Specific context, structured format

**Issue Priority**:
- 🔴 High: Missing required metadata, excessive size
- 🟡 Medium: Structural issues, vague language, poor progressive disclosure
- 🟢 Low: Action-orientation, minor improvements

#### Dynamic Check with Latest Documentation

The `prompt-quality-checker` agent fetches and validates against the latest official documentation:

**Agent Execution Process**:
1. **Fetch Official Docs**: Automatically retrieves latest docs from Cursor, Copilot, Claude
2. **Extract Thresholds**: Pulls current line limits, token limits, best practices
3. **Detect Changes**: Reports if official recommendations have been updated
4. **Validate**: Checks prompts against the most current standards

**Official Sources Referenced**:
- Cursor: https://cursor.com/docs/context/rules
- GitHub Copilot: https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot
- Claude: https://support.claude.com/en/articles/7996856-what-is-the-maximum-prompt-length

**Benefits**:
- Always aligned with current best practices
- Automatic detection of guideline updates
- Fallback to known values if fetch fails

**Usage**:
```bash
# In Claude Code terminal
# Say: "Use the prompt-quality-checker agent to check prompt quality"
```

The agent will automatically:
1. Fetch official documentation
2. Extract latest thresholds
3. Validate all files in `.agents/`
4. Generate detailed report

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
