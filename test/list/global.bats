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

@test "list/global: runs without error" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
}

@test "list/global: finds flat skill files" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|my-skill"* ]]
}

@test "list/global: finds SKILL.md in subdirs" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|test-context"* ]]
}

@test "list/global: finds commands" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|my-cmd"* ]]
}

@test "list/global: handles nested commands with colon notation" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|blog:post"* ]]
}

@test "list/global: skips bin directories" {
  run "$bin_dir/list/global"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test-context"* ]]
  [[ "$output" != *"helper"* ]]
}
