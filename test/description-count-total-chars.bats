#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
}

teardown() {
  [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR" || true
}

@test "description/count-total-chars: requires path argument" {
  run "$bin_dir/description/count-total-chars"
  [ "$status" -eq 1 ]
}

@test "description/count-total-chars: returns 0 for nonexistent directory" {
  run "$bin_dir/description/count-total-chars" /nonexistent/path
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "description/count-total-chars: returns 0 for empty directory" {
  TMP_DIR="$(mktemp -d)"
  mkdir -p "$TMP_DIR/empty"
  run "$bin_dir/description/count-total-chars" "$TMP_DIR/empty"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "description/count-total-chars: counts chars from fixtures" {
  run "$bin_dir/description/count-total-chars" "$fixtures_dir/home/.claude/skills"
  [ "$status" -eq 0 ]
  # Should have positive char count from fixture skills
  [ "$output" -gt 0 ]
}

@test "description/count-total-chars: searches recursively" {
  run "$bin_dir/description/count-total-chars" "$fixtures_dir/home/.claude/skills"
  [ "$status" -eq 0 ]
  # test-context/SKILL.md is nested - should be found
  [ "$output" -gt 0 ]
}

@test "description/count-total-chars: counts multiple files" {
  run "$bin_dir/description/count-total-chars" "$fixtures_dir/home/.claude/commands"
  [ "$status" -eq 0 ]
  # Has my-cmd.md and blog/post.md
  [ "$output" -gt 0 ]
}
