# Prompt Templates

プロンプトファイル作成用のテンプレート集です。

## Rule Template

```yaml
---
name: descriptive-name
description: Third-person description of what this rule enforces. Use when working with specific file types or implementing particular patterns.
paths: "**/*.{ts,tsx}"
---

# Rule Title

## Purpose

This rule enforces [purpose].

## Scope

- TypeScript/TSX files
- [specific use cases]

## Rules

### Required

1. [Rule 1]
2. [Rule 2]

### Recommended

- [Recommendation 1]
- [Recommendation 2]

## Examples

### Bad

```typescript
// bad code
```

### Good

```typescript
// good code
```

**Why**: [explanation]

## References

- [Related documentation]
```

---

## Skill Template

```yaml
---
name: doing-something
description: Does something specific. Use when performing certain tasks or analyzing particular data types.
allowed-tools: [Read, Write, Bash]
---

# Skill Title

## Overview

This skill provides [purpose].

## Quick Start

```language
# minimal example
code here
```

## References

- **`patterns.md`**: Pattern collection
- **`examples.md`**: Concrete examples

## Workflow

Copy this checklist:

```
Task Progress:
- [ ] Step 1: Description
- [ ] Step 2: Description
- [ ] Step 3: Description
```

**Step 1: Description**
[detailed instructions]

**Step 2: Description**
[detailed instructions]

If Step 2 fails, return to Step 1 and revise.

## References

- [Related resources]
```

---

## Agent Template

```yaml
---
name: agent-name
description: Performs specific tasks as a specialized agent. Use when conducting particular types of analysis or implementation.
tools: [Read, Write, Grep, Glob]
skills: [relevant-skill]
model: sonnet
---

# Agent Title

## Role

This agent handles [role].

## Tasks

Execute the following tasks:

1. [Task 1]
2. [Task 2]
3. [Task 3]

## Process

### Step 1: Task Description

[detailed instructions]

Tools:
```bash
Read: file_path="..."
Grep: pattern="..." path="..."
```

### Step 2: Task Description

[detailed instructions]

If validation fails, return to Step 1.

## Output Format

```markdown
# Output Title

## Summary
[summary]

## Details
- Detail 1
- Detail 2
```

## References

- **[skill-name](../../skills/skill-name/SKILL.md)**: Referenced skill
```

---

## Command Template

```yaml
---
name: command-name
description: Executes specific operations when invoked. Use when [trigger condition].
---

# Command Title

## Overview

This command executes [purpose].

## Usage

```bash
/command-name [arg1] [arg2]
```

**Arguments**:
- `arg1`: Description of arg1
- `arg2`: Description of arg2 (optional)

## Process

### Step 1: Description

[details]

### Step 2: Description

[details]

If Step 2 fails, [recovery action]

## Output Example

```
Expected output
```

## Notes

- [Note 1]
- [Note 2]
```
