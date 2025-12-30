#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"
}

teardown() {
  cd "$ORIG_PWD"
  export HOME="$ORIG_HOME"
}

@test "summary: shows header" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKILL BUDGET SUMMARY"* ]]
}

@test "summary: shows all three sources" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Global"* ]]
  [[ "$output" == *"Plugins"* ]]
  [[ "$output" == *"Project"* ]]
}

@test "summary: shows TOTAL row" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TOTAL"* ]]
}

@test "summary: shows budget limit" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Budget:"* ]]
  [[ "$output" == *"15000"* ]]
}

@test "summary: shows remaining budget" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Remaining:"* ]]
}

@test "summary: shows usage percentage" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"%"* ]]
}

@test "summary: counts skills from fixtures" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  # fixtures/home has 2 skills (my-skill, test-context)
  [[ "$output" == *"2 skills"* ]]
}

@test "summary: handles empty sources gracefully" {
  export HOME="$fixtures_dir/empty-home"
  cd /tmp
  run "$bin_dir/summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0 skills, 0 commands"* ]]
}
