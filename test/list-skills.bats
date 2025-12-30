#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
}

@test "list-skills: requires source argument" {
  run "$bin_dir/list-skills"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "list-skills: rejects unknown source" {
  run "$bin_dir/list-skills" unknown
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown source"* ]]
}

@test "list-skills: dispatches to global" {
  run "$bin_dir/list-skills" global
  [ "$status" -eq 0 ]
}

@test "list-skills: dispatches to plugins" {
  run "$bin_dir/list-skills" plugins
  [ "$status" -eq 0 ]
}

@test "list-skills: dispatches to project" {
  run "$bin_dir/list-skills" project
  [ "$status" -eq 0 ]
}
