#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"
}

teardown() {
  export HOME="$ORIG_HOME"
  cd "$ORIG_PWD"
}

@test "all/items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/items: includes user items" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.source == "user")'
}

@test "all/items: includes plugin items" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.source == "plugin")'
}

@test "all/items: includes project items" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.source == "project")'
}

@test "all/items: merges all four sources" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  # Count unique sources (user, plugin, project, global)
  sources=$(echo "$output" | jq '[.[].source] | unique | length')
  [ "$sources" -eq 4 ]
}

@test "all/items: includes MCP items" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.type == "mcp")'
}

@test "all/items: plugin items have plugin field" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  # Plugin items should have non-null plugin
  echo "$output" | jq -e '.[] | select(.source == "plugin" and .plugin != null)'
}

@test "all/items: user items have null plugin" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  # User items should have null plugin
  count=$(echo "$output" | jq '[.[] | select(.source == "user" and .plugin == null)] | length')
  user_count=$(echo "$output" | jq '[.[] | select(.source == "user")] | length')
  [ "$count" -eq "$user_count" ]
}

@test "all/items: project items have null plugin" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  # Project items should have null plugin
  count=$(echo "$output" | jq '[.[] | select(.source == "project" and .plugin == null)] | length')
  proj_count=$(echo "$output" | jq '[.[] | select(.source == "project")] | length')
  [ "$count" -eq "$proj_count" ]
}

@test "all/items: handles empty sources gracefully" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}
