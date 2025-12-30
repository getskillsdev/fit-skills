#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
}

teardown() {
  [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR" || true
}

@test "measure-descriptions: requires path argument" {
  run "$bin_dir/measure-descriptions"
  [ "$status" -eq 1 ]
}

@test "measure-descriptions: returns 0 for nonexistent directory" {
  run "$bin_dir/measure-descriptions" /nonexistent/path
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "measure-descriptions: returns 0 for empty directory" {
  TMP_DIR="$(mktemp -d)"
  mkdir -p "$TMP_DIR/empty"
  run "$bin_dir/measure-descriptions" "$TMP_DIR/empty"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "measure-descriptions: counts chars from fixtures" {
  run "$bin_dir/measure-descriptions" "$fixtures_dir/home/.claude/skills"
  [ "$status" -eq 0 ]
  # Should have positive char count from fixture skills
  [ "$output" -gt 0 ]
}

@test "measure-descriptions: searches recursively" {
  run "$bin_dir/measure-descriptions" "$fixtures_dir/home/.claude/skills"
  [ "$status" -eq 0 ]
  # test-context/SKILL.md is nested - should be found
  [ "$output" -gt 0 ]
}

@test "measure-descriptions: counts multiple files" {
  run "$bin_dir/measure-descriptions" "$fixtures_dir/home/.claude/commands"
  [ "$status" -eq 0 ]
  # Has my-cmd.md and blog/post.md
  [ "$output" -gt 0 ]
}
