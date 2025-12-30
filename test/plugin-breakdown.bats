#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
}

teardown() {
  export HOME="$ORIG_HOME"
}

@test "plugin-breakdown: handles no plugins installed" {
  export HOME="$fixtures_dir/empty-home"
  run "$bin_dir/plugin-breakdown"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No plugins installed"* ]]
}

@test "plugin-breakdown: shows header" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/plugin-breakdown"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plugin Description Usage"* ]]
}

@test "plugin-breakdown: shows plugin from fixtures" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/plugin-breakdown"
  [ "$status" -eq 0 ]
  [[ "$output" == *"myplugin@marketplace"* ]]
}

@test "plugin-breakdown: shows total" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/plugin-breakdown"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TOTAL"* ]]
}

@test "plugin-breakdown: counts chars for plugin" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/plugin-breakdown"
  [ "$status" -eq 0 ]
  # Should show non-zero chars for the plugin
  [[ "$output" =~ [1-9][0-9]* ]]
}
