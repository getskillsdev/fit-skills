#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures/token-usage" && pwd)"
}

@test "token-usage/plugin-breakdown: requires two arguments" {
  run "$bin_dir/token-usage/plugin-breakdown"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "token-usage/plugin-breakdown: requires disk file argument" {
  run "$bin_dir/token-usage/plugin-breakdown" "$fixtures_dir/context.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "token-usage/plugin-breakdown: fails if context file not found" {
  run "$bin_dir/token-usage/plugin-breakdown" "/nonexistent.json" "$fixtures_dir/disk.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "token-usage/plugin-breakdown: fails if disk file not found" {
  run "$bin_dir/token-usage/plugin-breakdown" "$fixtures_dir/context.json" "/nonexistent.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "token-usage/plugin-breakdown: shows header" {
  run "$bin_dir/token-usage/plugin-breakdown" "$fixtures_dir/context.json" "$fixtures_dir/disk.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plugin TOKEN Usage"* ]]
}

@test "token-usage/plugin-breakdown: groups by plugin" {
  run "$bin_dir/token-usage/plugin-breakdown" "$fixtures_dir/context.json" "$fixtures_dir/disk.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test-plugin@test-marketplace"* ]]
}

@test "token-usage/plugin-breakdown: shows total" {
  run "$bin_dir/token-usage/plugin-breakdown" "$fixtures_dir/context.json" "$fixtures_dir/disk.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TOTAL"* ]]
}
