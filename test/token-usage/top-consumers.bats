#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures/token-usage" && pwd)"
}

# top-consumers tests

@test "token-usage/top-consumers: requires context file argument" {
  run "$bin_dir/token-usage/top-consumers"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "token-usage/top-consumers: fails if file not found" {
  run "$bin_dir/token-usage/top-consumers" "/nonexistent.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "token-usage/top-consumers: shows header" {
  run "$bin_dir/token-usage/top-consumers" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Tokens"* ]]
  [[ "$output" == *"Type"* ]]
  [[ "$output" == *"Name"* ]]
}

@test "token-usage/top-consumers: parses k suffix" {
  run "$bin_dir/token-usage/top-consumers" "$fixtures_dir/context.json" 5
  [ "$status" -eq 0 ]
  [[ "$output" == *"6.2k"* ]]
}

@test "token-usage/top-consumers: sorts by tokens descending" {
  run "$bin_dir/token-usage/top-consumers" "$fixtures_dir/context.json" 2
  [ "$status" -eq 0 ]
  # First non-header line should have highest tokens
  [[ "$output" == *"pptx"* ]] || [[ "$output" == *"skill-a"* ]]
}

@test "token-usage/top-consumers: respects limit parameter" {
  run "$bin_dir/token-usage/top-consumers" "$fixtures_dir/context.json" 3
  [ "$status" -eq 0 ]
  # Count data lines (skip 2 header lines)
  local count=$(echo "$output" | tail -n +3 | grep -c . || true)
  [ "$count" -le 3 ]
}
