#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_PWD="$PWD"
}

teardown() {
  cd "$ORIG_PWD"
}

@test "list/project: runs without error" {
  cd "$fixtures_dir/project"
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
}

@test "list/project: returns empty when no .claude dir" {
  cd /tmp
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "list/project: finds skills in current project" {
  cd "$fixtures_dir/project"
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|proj-skill"* ]]
}

@test "list/project: finds commands in current project" {
  cd "$fixtures_dir/project"
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|proj-cmd"* ]]
}

@test "list/project: finds .claude from subdirectory" {
  cd "$fixtures_dir/project/src/deep/nested"
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|proj-skill"* ]]
}

@test "list/project: handles nested command paths" {
  cd "$fixtures_dir/project"
  run "$bin_dir/list/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|sub:cmd"* ]]
}
