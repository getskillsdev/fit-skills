#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"
}

teardown() {
  export HOME="$ORIG_HOME"
  cd "$ORIG_PWD"
}

@test "all/mcp-items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/mcp-items: returns empty array when no MCP config" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq 'length')" -eq 0 ]
}

@test "all/mcp-items: includes project MCP servers" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "playwright" and .source == "project")'
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .source == "project")'
}

@test "all/mcp-items: includes global MCP servers" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "astro-docs" and .source == "global")'
}

@test "all/mcp-items: type is mcp for all entries" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # All entries should have type "mcp"
  count=$(echo "$output" | jq '[.[] | select(.type == "mcp")] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/mcp-items: includes path field" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # Project MCP should have .mcp.json path
  echo "$output" | jq -e '.[] | select(.name == "playwright") | .path' | grep -q ".mcp.json"
  # Global MCP should have .claude.json path
  echo "$output" | jq -e '.[] | select(.name == "astro-docs") | .path' | grep -q ".claude.json"
}

@test "all/mcp-items: plugin field is null" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.plugin == null)' > /dev/null
}

@test "all/mcp-items: combines project and global servers" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # Should have both project (2) and global (1) servers
  [ "$(echo "$output" | jq 'length')" -eq 3 ]
}
