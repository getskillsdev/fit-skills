#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
}

teardown() {
  export HOME="$ORIG_HOME"
}

@test "all/user-items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/user-items: returns empty array when no .claude dir" {
  export HOME="$fixtures_dir/empty-home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq 'length')" -eq 0 ]
}

@test "all/user-items: includes skills" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.type == "skill")'
}

@test "all/user-items: includes commands" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.type == "command")'
}

@test "all/user-items: source is user" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # All items should have source: user
  count=$(echo "$output" | jq '[.[] | select(.source == "user")] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/user-items: plugin is null" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # All items should have plugin: null
  count=$(echo "$output" | jq '[.[] | select(.plugin == null)] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/user-items: handles nested commands" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # commands/blog/post.md becomes blog:post
  echo "$output" | jq -e '.[] | select(.name == "blog:post")'
}

@test "all/user-items: finds directory-style skills" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # skills/test-context/SKILL.md
  echo "$output" | jq -e '.[] | select(.name == "test-context")'
}

@test "all/user-items: finds flat .md skills" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # skills/my-skill.md
  echo "$output" | jq -e '.[] | select(.name == "my-skill")'
}

@test "all/user-items: skips bin directories" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # test-context should be found, but helper.md in bin/ should not
  echo "$output" | jq -e '.[] | select(.name == "test-context")'
  [[ "$output" != *"helper"* ]]
}

@test "all/user-items: marks standalone .md skill as invalid" {
  export HOME="$fixtures_dir/home-with-invalid"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # Check that invalid-standalone has invalid field
  invalid_value=$(echo "$output" | jq -r '.[] | select(.name == "invalid-standalone") | .invalid')
  [ -n "$invalid_value" ]
  [ "$invalid_value" != "null" ]
}

@test "all/user-items: valid directory skill has no invalid field" {
  export HOME="$fixtures_dir/home-with-invalid"
  run "$bin_dir/all/user-items"
  [ "$status" -eq 0 ]
  # Check that valid-skill has invalid: null
  invalid_value=$(echo "$output" | jq -r '.[] | select(.name == "valid-skill") | .invalid')
  [ "$invalid_value" = "null" ]
}

@test "all/user-items: invalid field explains the error" {
  export HOME="$fixtures_dir/home-with-invalid"
  result=$("$bin_dir/all/user-items")
  invalid_msg=$(echo "$result" | jq -r '.[] | select(.name == "invalid-standalone") | .invalid')
  [[ "$invalid_msg" == *"standalone"* ]] || [[ "$invalid_msg" == *"directory"* ]]
}
