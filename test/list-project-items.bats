#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
}

@test "list-project-items: finds directory-style skills" {
  run "$bin_dir/list-project-items" "$fixtures_dir/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"proj-skill"* ]]
}

@test "list-project-items: finds top-level commands" {
  run "$bin_dir/list-project-items" "$fixtures_dir/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"proj-cmd"* ]]
}

@test "list-project-items: converts nested commands to colon format" {
  run "$bin_dir/list-project-items" "$fixtures_dir/project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sub:cmd"* ]]
}

@test "list-project-items: does not include path separators" {
  run "$bin_dir/list-project-items" "$fixtures_dir/project"
  [ "$status" -eq 0 ]
  [[ "$output" != *"/"* ]]
  [[ "$output" != *".md"* ]]
}

@test "list-project-items: errors when no .claude directory" {
  run "$bin_dir/list-project-items" "/tmp"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No .claude directory"* ]]
}

@test "list-project-items: handles empty project" {
  run "$bin_dir/list-project-items" "$fixtures_dir/empty-home"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
