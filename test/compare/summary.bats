#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures/compare" && pwd)"
}

@test "compare/summary: requires two arguments" {
  run "$bin_dir/compare/summary"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "compare/summary: requires second argument" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "compare/summary: fails if disk file not found" {
  run "$bin_dir/compare/summary" "/nonexistent.json" "$fixtures_dir/context.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "compare/summary: fails if context file not found" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json" "/nonexistent.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "compare/summary: shows item counts" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    4 items"* ]]
  [[ "$output" == *"In context: 4 items"* ]]
}

@test "compare/summary: identifies unknown invalid items" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"UNKNOWN INVALID"* ]]
  [[ "$output" == *"dropped-skill (skill:project)"* ]]
}

@test "compare/summary: identifies MCP loaded tools" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"MCP LOADED TOOLS"* ]]
  [[ "$output" == *"mcp__playwright__navigate (MCP)"* ]]
}

@test "compare/summary: shows (none) when no unknown invalid items" {
  run "$bin_dir/compare/summary" "$fixtures_dir/context.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"UNKNOWN INVALID"* ]]
  [[ "$output" == *"(none)"* ]]
}

@test "compare/summary: handles empty disk file" {
  run "$bin_dir/compare/summary" "$fixtures_dir/empty.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    0 items"* ]]
  [[ "$output" == *"In context: 4 items"* ]]
}

@test "compare/summary: handles empty context file" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk.json" "$fixtures_dir/empty.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    4 items"* ]]
  [[ "$output" == *"In context: 0 items"* ]]
}

@test "compare/summary: handles both empty files" {
  run "$bin_dir/compare/summary" "$fixtures_dir/empty.json" "$fixtures_dir/empty.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    0 items"* ]]
  [[ "$output" == *"In context: 0 items"* ]]
  [[ "$output" == *"(none)"* ]]
}

@test "compare/summary: MCP server with tools is not unknown invalid" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-mcp.json" "$fixtures_dir/context-with-mcp-tools.json"
  [ "$status" -eq 0 ]
  # playwright has mcp__playwright__* tools in context, should NOT be unknown invalid
  [[ "$output" != *"playwright (mcp:project)"* ]]
}

@test "compare/summary: MCP server without tools is unknown invalid" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-mcp.json" "$fixtures_dir/context-with-mcp-tools.json"
  [ "$status" -eq 0 ]
  # vercel has no mcp__vercel__* tools in context, SHOULD be unknown invalid
  [[ "$output" == *"vercel (mcp:project)"* ]]
}

@test "compare/summary: shows KNOWN INVALID section" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-invalid.json" "$fixtures_dir/context-missing-both.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"=== KNOWN INVALID (not loadable by Claude Code) ==="* ]]
}

@test "compare/summary: invalid items appear in KNOWN INVALID section" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-invalid.json" "$fixtures_dir/context-missing-both.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"invalid-standalone"* ]]
  [[ "$output" == *"standalone .md files"* ]]
}

@test "compare/summary: valid items not in context appear in UNKNOWN INVALID section" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-invalid.json" "$fixtures_dir/context-missing-both.json"
  [ "$status" -eq 0 ]
  # valid-skill should be in UNKNOWN INVALID, not KNOWN INVALID
  [[ "$output" == *"=== UNKNOWN INVALID"*"valid-skill"* ]]
}

@test "compare/summary: shows DISABLED section" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-disabled-mcp.json" "$fixtures_dir/context-mcp-missing.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"=== DISABLED (intentionally turned off) ==="* ]]
}

@test "compare/summary: disabled MCP appears in DISABLED section not UNKNOWN INVALID" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-disabled-mcp.json" "$fixtures_dir/context-mcp-missing.json"
  [ "$status" -eq 0 ]
  # vercel is disabled, should be in DISABLED section
  [[ "$output" == *"=== DISABLED"*"vercel"* ]]
  # vercel should NOT be in UNKNOWN INVALID section
  [[ "$output" != *"=== UNKNOWN INVALID"*"vercel"* ]]
}

@test "compare/summary: enabled MCP with tools is not unknown invalid" {
  run "$bin_dir/compare/summary" "$fixtures_dir/disk-with-disabled-mcp.json" "$fixtures_dir/context-mcp-missing.json"
  [ "$status" -eq 0 ]
  # playwright has tools loaded (mcp__playwright__*), should not appear in UNKNOWN INVALID
  [[ "$output" != *"playwright (mcp:project)"* ]]
}
