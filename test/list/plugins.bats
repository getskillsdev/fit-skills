#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
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

@test "list/plugins: only processes latest non-orphaned version" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
  # Should find latest non-orphaned version (1.0.1)
  [[ "$output" == *"|skill|current-skill"* ]]
  [[ "$output" == *"|command|current-cmd"* ]]
  # Should NOT find orphaned version (1.0.0)
  [[ "$output" != *"old-skill"* ]]
  [[ "$output" != *"old-cmd"* ]]
}

@test "list/plugins: skips fully orphaned plugins (uninstalled)" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/list/plugins"
  [ "$status" -eq 0 ]
  # Should NOT find skills from fully orphaned plugin
  [[ "$output" != *"gone-skill"* ]]
}
