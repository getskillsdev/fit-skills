#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"
}

teardown() {
  cd "$ORIG_PWD"
  export HOME="$ORIG_HOME"
}

@test "description/budget-summary: shows header" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKILL FRONTMATTER DESCRIPTION BUDGET SUMMARY"* ]]
}

@test "description/budget-summary: shows all three sources" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Global"* ]]
  [[ "$output" == *"Plugins"* ]]
  [[ "$output" == *"Project"* ]]
}

@test "description/budget-summary: shows TOTAL row" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TOTAL"* ]]
}

@test "description/budget-summary: shows description budget" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Description budget:"* ]]
  [[ "$output" == *"15000"* ]]
}

@test "description/budget-summary: shows remaining budget" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Description budget remaining:"* ]]
}

@test "description/budget-summary: shows usage percentage" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"% used"* ]]
}

@test "description/budget-summary: counts skills from fixtures" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  # fixtures/home has 2 skills (my-skill, test-context)
  [[ "$output" == *"2 skills"* ]]
}

@test "description/budget-summary: handles empty sources gracefully" {
  export HOME="$fixtures_dir/empty-home"
  cd /tmp
  run "$bin_dir/description/budget-summary"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0 skills, 0 commands"* ]]
}
