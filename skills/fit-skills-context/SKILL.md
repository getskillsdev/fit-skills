---
name: fit-skills-context
description: Find bloated plugins.
allowed-tools: Read, Bash
---

# Skill Limits Audit

There are **two separate limits** that affect skill loading:

## 1. Description Budget (15k chars)

Skill names and descriptions are loaded into the system prompt. The default limit is ~15,000 characters for all descriptions combined. This is what the scripts in this skill measure.

**Increase:** `SLASH_COMMAND_TOOL_CHAR_BUDGET=30000 claude`

## 2. Token Limit (content + MCP tools)

The full content of skills, commands, and MCP tools consume context window tokens. Even if you're under the 15k description budget, skills can still be "hidden due to token limits" if total content tokens exceed the limit.

Things that consume tokens:
- Full SKILL.md content (not just descriptions)
- MCP tool definitions (e.g., playwright adds ~21k tokens for 34 tools)
- Project skills (appear to load last, dropped first when over budget)

**References:**
- [Skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) - individual limits (1024 chars per description)
- [Claude Code skills not triggering?](https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/) - explains the 15k default budget

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

- `description/budget-summary` - Full budget summary with counts
- `list-skills <source>` - List skills/commands for global|plugins|project
- `audit-source <source>` - Generate JSON audit for a source
- `description/plugin-breakdown` - Per-plugin breakdown
- `top-desc-limit-consumers [limit]` - Top consumers by description chars (default: 5)
- `measure-descriptions` - Count description chars in a directory
- `all/items` - Combined JSON of all sources (user, plugin, project, MCP)
- `all/user-items` - JSON array of user-space skills/commands (~/.claude)
- `all/plugin-items` - JSON array of plugin skills/commands with plugin field
- `all/project-items` - JSON array of project-space skills/commands (.claude)
- `all/mcp-items` - JSON array of configured MCP servers (.mcp.json, ~/.claude.json)
- `all/compare <disk.json> <context.json>` - Compare two JSON snapshots, show dropped/external items

## Instructions

### 1. Locate skill directory

Use the path where you found this SKILL.md file. The scripts are in the `bin/` subdirectory relative to this file.

### 2. Capture disk inventory

Generate a unique audit token and capture the current disk state:

1. Generate a short unique ID (e.g., first 8 chars of a UUID) - store as `audit-token`
2. Run the inventory script:
```bash
{path-from-step-1}/bin/all/items > ./skill-audit-YYYY-MM-DD-{audit-token}-disk.json
```

This captures all user, plugin, and project skills/commands as JSON.

### 3. Request and save /context output

Ask the user:

**Although I can see what skills are in my context window, I can't see token usage. Please run `/context` and paste the output here.**

When the user pastes the output:

**Step 1: Convert to JSON and save**

Parse each skill/tool into structured format:
```json
[
  {"name": "spec-context", "tokens": "4.4k", "type": "User"},
  {"name": "pptx", "tokens": "6.3k", "type": "Plugin"},
  {"name": "mcp__playwright__navigate", "tokens": "737", "type": "MCP"}
]
```

Save using the same audit token:

`./skill-audit-YYYY-MM-DD-{audit-token}-context.json`

**Step 2: Extract metrics**

Calculate and report:

| Metric | Value |
|--------|-------|
| Total skills loaded | X (User + Project + Plugin) |
| Total tokens (skills) | Xk |
| MCP servers | N servers, X tools total, Xk tokens |
| Biggest skill | name (Xk) |

### 4. Identify dropped items

Run the compare script with both saved files:
```bash
{path-from-step-1}/bin/all/compare ./skill-audit-YYYY-MM-DD-{audit-token}-disk.json ./skill-audit-YYYY-MM-DD-{audit-token}-context.json
```

Save output to: `./skill-audit-YYYY-MM-DD-{audit-token}-compare.txt`

The script shows:
- **DROPPED**: Items on disk but not in context (skills, commands, or MCP servers hidden due to token limits)
- **EXTERNAL**: Items in context but not on disk (individual MCP tool definitions like `mcp__playwright__navigate`)

If no items are missing, report "All items loaded" and move on.

### 5. Run budget summary

Using the path from step 1, run the summary script:
```bash
{path-from-step-1}/bin/description/budget-summary
```

**Print the full output in your response** (don't just summarize).

### 6. Run plugin breakdown

```bash
{path-from-step-1}/bin/description/plugin-breakdown
```

**Print the full output in your response** (don't just summarize).

### 7. Summarize findings

Based on the results, provide actionable advice.

**Note:** `description/budget-summary` and `description/plugin-breakdown` measure the **description budget** (15k chars). This is separate from token limits that cause "hidden due to token limits". You can be under the description budget and still have skills hidden due to total content tokens.

**Description budget recommendations:**

**If over 80% of description budget:**
- Identify the largest consumers
- Suggest plugins to uninstall if not actively used

**If plugins are the main consumer:**
- Name the specific plugin(s)
- Show uninstall command: `claude plugin uninstall <plugin>@<marketplace>`

**Token limit recommendations (from /context JSON):**

**If skills are hidden but description budget has headroom:**
- The issue is token limits, not description chars
- Step 4's `all/compare` output shows what was dropped
- If a plugin skill is >3k tokens, suggest trimming or uninstalling
- If an MCP server adds >10k tokens, note the cost
- Identify quick wins (large items that could be removed)
- Project skills load last and get dropped first
