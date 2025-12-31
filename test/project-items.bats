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

@test "all/project-items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/project-items: returns empty array when no .claude dir" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq 'length')" -eq 0 ]
}

@test "all/project-items: includes skills" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.type == "skill")'
}

@test "all/project-items: includes commands" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.type == "command")'
}

@test "all/project-items: source is project" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  # All items should have source: project
  count=$(echo "$output" | jq '[.[] | select(.source == "project")] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/project-items: plugin is null" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  # All items should have plugin: null
  count=$(echo "$output" | jq '[.[] | select(.plugin == null)] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/project-items: finds project root from subdirectory" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project/src/deep/nested"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  # Should still find items from deep nested dir
  echo "$output" | jq -e '.[] | select(.name == "proj-skill")'
}

@test "all/project-items: handles nested command paths" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/project-items"
  [ "$status" -eq 0 ]
  # commands/sub/cmd.md becomes sub:cmd
  echo "$output" | jq -e '.[] | select(.name == "sub:cmd")'
}
