#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
}

@test "scan-commands: finds .md files in commands dir" {
  run "$bin_dir/scan-commands" "$fixtures_dir/home/.claude/commands"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|my-cmd"* ]]
}

@test "scan-commands: finds nested commands with colon separator" {
  run "$bin_dir/scan-commands" "$fixtures_dir/home/.claude/commands"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|blog:post"* ]]
}

@test "scan-commands: returns empty for nonexistent dir" {
  run "$bin_dir/scan-commands" "/nonexistent/path"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "scan-commands: finds plugin commands" {
  run "$bin_dir/scan-commands" "$fixtures_dir/home/.claude/plugins/cache/marketplace/myplugin/1.0.0/commands"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|command|plugin-cmd"* ]]
  [[ "$output" == *"|command|sub:cmd"* ]]
}

@test "scan-commands: output format is path|command|name" {
  run "$bin_dir/scan-commands" "$fixtures_dir/home/.claude/commands"
  [ "$status" -eq 0 ]
  # Check first line has correct format
  echo "$output" | head -1 | grep -qE "^.+\|command\|.+$"
}
