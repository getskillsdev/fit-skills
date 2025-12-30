---
name: fit-skills-context
description: Find bloated plugins.
allowed-tools: Read, Bash
---

# Skill Limits Audit

Check how much of the 15,000 character skill description budget is being used.

Skill names and descriptions are loaded into the system prompt at startup. The default limit is ~15,000 characters. Skills over the limit are silently dropped.

## Individual Skill Limits

Per [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | ≤64 chars, lowercase letters/numbers/hyphens only |
| `description` | Yes | ≤1024 chars, what it does + when to use, third person |
| `allowed-tools` | No | Comma-separated list of tools to restrict access |

Keep SKILL.md body under 500 lines for optimal performance.

## Scripts

This skill includes helper scripts in the `bin/` subdirectory:

- `summary` - Full budget summary with counts
- `list-skills <source>` - List skills/commands for global|plugins|project
- `audit-source <source>` - Generate JSON audit for a source
- `plugin-breakdown` - Per-plugin breakdown
- `measure-descriptions` - Count description chars in a directory

## Instructions

### 1. Locate skill directory

Run this to find where the skill is installed:
```bash
find ~/.claude/plugins/cache -type d -name "fit-skills-context" | tail -1
```

Note the output path (e.g., `/Users/.../.claude/plugins/cache/fit-skills/gsd/1.0.5/skills/fit-skills-context`).

### 2. Check your context window

> What skills are in your context window? Report the total count and how many are shown vs hidden due to token limits.

Do not announce what you're doing. Just output, similar to below:
```
Context window: 86 skills total, 77 shown (9 hidden due to token limits)
```

### 3. Run budget summary

Using the path from step 1, run the summary script:
```bash
{path-from-step-1}/bin/summary
```

**Print the full output in your response** (don't just summarize).

### 4. Run plugin breakdown

```bash
{path-from-step-1}/bin/plugin-breakdown
```

**Print the full output in your response** (don't just summarize).

### 5. Summarize findings

Based on the results, provide actionable advice:

**If over 80% used:**
- Identify the largest consumers
- Suggest plugins to uninstall if not actively used

**If plugins are the main consumer:**
- Name the specific plugin(s)
- Show uninstall command: `claude plugin uninstall <plugin>@<marketplace>`
