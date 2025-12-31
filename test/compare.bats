#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures/compare" && pwd)"
}

@test "all/compare: requires two arguments" {
  run "$bin_dir/all/compare"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "all/compare: requires second argument" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "all/compare: fails if disk file not found" {
  run "$bin_dir/all/compare" "/nonexistent.json" "$fixtures_dir/context.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "all/compare: fails if context file not found" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json" "/nonexistent.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "all/compare: shows item counts" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    4 items"* ]]
  [[ "$output" == *"In context: 4 items"* ]]
}

@test "all/compare: identifies dropped items" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DROPPED"* ]]
  [[ "$output" == *"dropped-skill (skill:project)"* ]]
}

@test "all/compare: identifies external items" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"EXTERNAL"* ]]
  [[ "$output" == *"mcp__playwright__navigate (MCP)"* ]]
}

@test "all/compare: shows (none) when no dropped items" {
  run "$bin_dir/all/compare" "$fixtures_dir/context.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DROPPED"* ]]
  [[ "$output" == *"(none)"* ]]
}

@test "all/compare: handles empty disk file" {
  run "$bin_dir/all/compare" "$fixtures_dir/empty.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    0 items"* ]]
  [[ "$output" == *"In context: 4 items"* ]]
}

@test "all/compare: handles empty context file" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk.json" "$fixtures_dir/empty.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    4 items"* ]]
  [[ "$output" == *"In context: 0 items"* ]]
}

@test "all/compare: handles both empty files" {
  run "$bin_dir/all/compare" "$fixtures_dir/empty.json" "$fixtures_dir/empty.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"On disk:    0 items"* ]]
  [[ "$output" == *"In context: 0 items"* ]]
  [[ "$output" == *"(none)"* ]]
}

@test "all/compare: MCP server with tools is not dropped" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk-with-mcp.json" "$fixtures_dir/context-with-mcp-tools.json"
  [ "$status" -eq 0 ]
  # playwright has mcp__playwright__* tools in context, should NOT be dropped
  [[ "$output" != *"playwright (mcp:project)"* ]]
}

@test "all/compare: MCP server without tools is dropped" {
  run "$bin_dir/all/compare" "$fixtures_dir/disk-with-mcp.json" "$fixtures_dir/context-with-mcp-tools.json"
  [ "$status" -eq 0 ]
  # vercel has no mcp__vercel__* tools in context, SHOULD be dropped
  [[ "$output" == *"vercel (mcp:project)"* ]]
}
