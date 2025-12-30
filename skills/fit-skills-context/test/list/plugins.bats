#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
  export HOME="$fixtures_dir/home"
}

teardown() {
  export HOME="$ORIG_HOME"
}

@test "list/plugins: runs without error" {
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
}

@test "list/plugins: finds skills in plugin cache" {
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|plugin-skill"* ]]
}

@test "list/plugins: finds commands in plugin cache" {
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|plugin-cmd"* ]]
}

@test "list/plugins: handles nested command paths" {
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|sub:cmd"* ]]
}
