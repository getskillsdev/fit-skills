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
- MCP tool definitions
- Project skills (appear to load last, dropped first when over budget)

**References:**
- [Skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) - individual limits (1024 chars per description - not enforced)
- [Claude Code skills not triggering?](https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/) - explains the 15k default budget

## Individual Skill Limits

Per [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | ≤64 chars, lowercase letters/numbers/hyphens only |
| `description` | Yes | ≤1024 chars (not enforced), what it does + when to use, third person |
| `allowed-tools` | No | Comma-separated list of tools to restrict access |

Keep SKILL.md body under 500 lines for optimal performance.

## Scripts

This skill includes helper scripts in the `bin/` subdirectory:

- `description/budget-summary` - Full budget summary with counts
- `list-skills <source>` - List skills/commands for global|plugins|project
- `description/audit-source <source>` - Generate JSON audit for a source
- `description/plugin-breakdown` - Per-plugin breakdown
- `description/top-consumers [limit]` - Top consumers by description chars (default: 5)
- `description/count-total-chars` - Count description chars in a directory
- `all/items` - Combined JSON of all sources (user, plugin, project, MCP)
- `all/user-items` - JSON array of user-space skills/commands (~/.claude)
- `all/plugin-items` - JSON array of plugin skills/commands with plugin field
- `all/project-items` - JSON array of project-space skills/commands (.claude)
- `all/mcp-items` - JSON array of configured MCP servers (.mcp.json, ~/.claude.json)
- `compare/summary <disk.json> <context.json>` - Compare two JSON snapshots, show categorized sections
- `audit/start` - Start audit: generate token, save disk inventory to project root

## Instructions

### 1. Locate skill directory

Use the path where you found this SKILL.md file. The scripts are in the `bin/` subdirectory relative to this file.

### 2. Capture disk inventory

Run the audit start script:

```bash
{path-from-step-1}/bin/audit/start
```

This generates an audit token and saves the disk inventory to project root. Note the token for subsequent steps.

### 3. Request and save /context output

Ask the user:

**Although I can see what skills are in my context window, I can't see token usage until you run `/context`. Please run `/context` and then type OK <enter>**

`<local-command-stdout>` is a tag in your context containing output from slash commands the user runs. Trust me - you will only be aware of the tag's existence once the user has run `/context` - otherwise you might think it's user-error. It exists! When the user enters OK or similar after running `/context`, look for this tag. If you cannot see it, the user has not run `/context` - ask them to run again.

**Step 1: Convert to JSON and save**

Parse each skill/tool from `<local-command-stdout>` into structured format:
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

### 4. Find invalid items

```bash
{path-from-step-1}/bin/compare/on-disk-not-in-context ./skill-audit-YYYY-MM-DD-{audit-token}-disk.json ./skill-audit-YYYY-MM-DD-{audit-token}-context.json > ./skill-audit-YYYY-MM-DD-{audit-token}-invalid.json
```

Read the saved file. If it contains `[]`, all disk items are valid.

### 5. Compare items on disk, but not in context

Run the compare script with both saved files:
```bash
{path-from-step-1}/bin/compare/summary ./skill-audit-YYYY-MM-DD-{audit-token}-disk.json ./skill-audit-YYYY-MM-DD-{audit-token}-context.json
```

Save output to: `./skill-audit-YYYY-MM-DD-{audit-token}-compare.txt`

The script shows:
- **KNOWN INVALID**: Standalone `.md` files that Claude Code ignores (not a token limit issue)
- **DISABLED**: MCP servers intentionally turned off via `/mcp` toggle
- **UNKNOWN INVALID**: On disk but not in context (reason unknown)
- **MCP LOADED TOOLS**: Individual MCP tool definitions from working servers (e.g., `mcp__playwright__navigate`)

**MCP servers in UNKNOWN INVALID section:** If an MCP server appears here, the server may have failed to start. Debug with:
- Run `/mcp` to check server status
- Run `claude mcp list` to see configured servers
- Run `claude --debug` to see connection attempts
- Check that `.mcp.json` is in project root (not `.claude/.mcp.json`)

### 6. Run budget summary

Using the path from step 1, run the summary script:
```bash
{path-from-step-1}/bin/description/budget-summary
```

**Print the full output in your response** (don't just summarize).

### 7. Run plugin breakdown

```bash
{path-from-step-1}/bin/description/plugin-breakdown
```

**Print the full output in your response** (don't just summarize).

### 8. Check for dropped skills (token limits)

`<available_skills>` is a section in your system prompt listing loaded skills. Check if you can see it, and look for a line similar to:

```
<!-- Showing x of y skills due to token limits -->
```

If this line appears, skills are being dropped from your context window due to token limits.

Compare these two sources to find dropped items:

1. **`<local-command-stdout>`** — Skills configured (from step 3's `/context` output)
2. **`<available_skills>`** — Skills actually loaded in your system prompt

Items that appear in #1 but NOT in #2 were dropped due to token limits.

Write the dropped items to:

`./skill-audit-YYYY-MM-DD-{audit-token}-dropped.json`

Use the same JSON format as other audit files.

If no truncation message appears, skip this step.

### 9. Summarize findings

Based on the results, provide actionable advice.

**Use the compare output sections:**

The `compare/summary` output has FOUR sections:
1. `=== KNOWN INVALID ===` — Items that are NOT loadable (standalone .md files). These are NOT token limit issues.
2. `=== DISABLED ===` — MCP servers intentionally turned off. Not a token limit issue.
3. `=== UNKNOWN INVALID ===` — On disk but not in context (reason unknown - may be token limits or other issue).
4. `=== MCP LOADED TOOLS ===` — MCP tools loaded from servers (expected, ignore).

**CRITICAL:** Items in the KNOWN INVALID section must NEVER be reported as "hidden due to token limits". They are simply not loadable. Report them as:
- "Invalid (not loadable): skill-name — use directory with SKILL.md instead"
- Provide fix: `mkdir ~/.claude/skills/skill-name && mv ~/.claude/skills/skill-name.md ~/.claude/skills/skill-name/SKILL.md`

**Note:** Items in UNKNOWN INVALID may or may not be token limit issues. Step 8 uses `<available_skills>` to identify items specifically dropped due to token limits.

**Note:** `description/budget-summary` and `description/plugin-breakdown` measure the **description budget** (15k chars). This is separate from token limits that cause "hidden due to token limits". You can be under the description budget and still have skills hidden due to total content tokens.

**Description budget recommendations:**

**If over 80% of description budget:**
- Identify the largest consumers
- Suggest plugins to uninstall if not actively used

**If plugins are the main consumer:**
- Name the specific plugin(s)
- Show uninstall command: `claude plugin uninstall <plugin>@<marketplace>`

**Token limit recommendations (from /context JSON):**

**If skills appear in step 8's dropped list and description budget has headroom:**
- The issue is token limits, not description chars
- **IMPORTANT:** `SLASH_COMMAND_TOOL_CHAR_BUDGET` does NOT help here - it only affects description budget
- Do NOT report KNOWN INVALID items as "token limit issues" - they are simply not loadable
- There is no env var to increase token limits - the only fix is to remove items
- Step 8's dropped.json shows what was dropped due to token limits
- If a plugin skill is >3k tokens, suggest trimming or uninstalling
- If an MCP server adds >10k tokens, note the cost
- Identify quick wins (large items that could be removed)
- Project skills load last and get dropped first

Example phrasing: "To restore the dropped project skills, uninstall large plugins or MCP servers to free token budget."
