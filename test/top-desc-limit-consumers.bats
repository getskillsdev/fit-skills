#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PROJECT_DIR="$PROJECT_DIR"
}

teardown() {
  export HOME="$ORIG_HOME"
  export PROJECT_DIR="$ORIG_PROJECT_DIR"
}

@test "top-desc-limit-consumers: shows header" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  run "$bin_dir/top-desc-limit-consumers"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Chars"* ]]
  [[ "$output" == *"Source"* ]]
  [[ "$output" == *"Type"* ]]
  [[ "$output" == *"Name"* ]]
}

@test "top-desc-limit-consumers: shows items from plugins" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  # Use high limit to include smaller plugin items
  run "$bin_dir/top-desc-limit-consumers" 100
  [ "$status" -eq 0 ]
  [[ "$output" == *"plugins"* ]]
}

@test "top-desc-limit-consumers: shows items from project" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  # Use high limit to include smaller project items
  run "$bin_dir/top-desc-limit-consumers" 100
  [ "$status" -eq 0 ]
  [[ "$output" == *"project"* ]]
}

@test "top-desc-limit-consumers: respects limit parameter" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  run "$bin_dir/top-desc-limit-consumers" 1
  [ "$status" -eq 0 ]
  # Count non-header lines (skip 2 header lines)
  local count=$(echo "$output" | tail -n +3 | grep -c . || true)
  [ "$count" -le 1 ]
}

@test "top-desc-limit-consumers: handles empty home" {
  export HOME="$fixtures_dir/empty-home"
  export PROJECT_DIR="$fixtures_dir/project"
  run "$bin_dir/top-desc-limit-consumers"
  [ "$status" -eq 0 ]
  # Should still show header
  [[ "$output" == *"Chars"* ]]
}

@test "top-desc-limit-consumers: shows char counts" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  run "$bin_dir/top-desc-limit-consumers"
  [ "$status" -eq 0 ]
  # Should have numeric char counts
  [[ "$output" =~ [0-9]+ ]]
}

@test "top-desc-limit-consumers: sorts by chars descending" {
  export HOME="$fixtures_dir/home"
  export PROJECT_DIR="$fixtures_dir/project"
  run "$bin_dir/top-desc-limit-consumers"
  [ "$status" -eq 0 ]
  # Extract char values from output (skip header), verify descending order
  local chars=$(echo "$output" | tail -n +3 | awk '{print $1}' | grep -E '^[0-9]+$')
  local sorted_chars=$(echo "$chars" | sort -nr)
  [ "$chars" = "$sorted_chars" ]
}
