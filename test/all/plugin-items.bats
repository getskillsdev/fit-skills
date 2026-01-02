#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
}

teardown() {
  export HOME="$ORIG_HOME"
}

@test "all/plugin-items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/plugin-items: returns empty array when no plugins" {
  export HOME="$fixtures_dir/empty-home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq 'length')" -eq 0 ]
}

@test "all/plugin-items: includes skill with correct name" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # Skills have no prefix, just the name
  echo "$output" | jq -e '.[] | select(.name == "plugin-skill" and .type == "skill")'
}

@test "all/plugin-items: includes command with plugin prefix" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # Commands have prefix from plugin dir (no plugin.json in this fixture)
  echo "$output" | jq -e '.[] | select(.name == "myplugin:plugin-cmd" and .type == "command")'
}

@test "all/plugin-items: uses plugin.json name for command prefix" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # plugin.json has name "tp", not "testplugin"
  echo "$output" | jq -e '.[] | select(.name == "tp:current-cmd" and .type == "command")'
}

@test "all/plugin-items: falls back to dir name when no plugin.json" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # No plugin.json, so prefix is dir name "myplugin"
  echo "$output" | jq -e '.[] | select(.name | startswith("myplugin:"))'
}

@test "all/plugin-items: includes plugin field" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.plugin == "myplugin")'
}

@test "all/plugin-items: includes marketplace field" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.marketplace == "marketplace")'
}

@test "all/plugin-items: skips orphaned versions" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # Version 1.0.0 has .orphaned_at, should not appear
  [[ "$output" != *"old-skill"* ]]
  [[ "$output" != *"old-cmd"* ]]
}

@test "all/plugin-items: uses latest non-orphaned version" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # Version 1.0.1 is current
  echo "$output" | jq -e '.[] | select(.name == "current-skill")'
}

@test "all/plugin-items: skips fully uninstalled plugins" {
  export HOME="$fixtures_dir/home-multiversion"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # "uninstalled" plugin has only orphaned versions
  [[ "$output" != *"gone-skill"* ]]
}

@test "all/plugin-items: handles nested command directories" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # commands/sub/cmd.md becomes sub:cmd
  echo "$output" | jq -e '.[] | select(.name == "myplugin:sub:cmd")'
}

@test "all/plugin-items: follows symlinks" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  # find -L follows symlinks, should work without error
}

@test "all/plugin-items: type is skill for SKILL.md files" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  result=$(echo "$output" | jq '.[] | select(.name == "plugin-skill") | .type')
  [ "$result" = '"skill"' ]
}

@test "all/plugin-items: type is command for command .md files" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  result=$(echo "$output" | jq '.[] | select(.name == "myplugin:plugin-cmd") | .type')
  [ "$result" = '"command"' ]
}

@test "all/plugin-items: includes source field as plugin" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.source == "plugin")'
}

@test "all/plugin-items: marks standalone .md skill as invalid" {
  export HOME="$fixtures_dir/home-with-invalid"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  invalid_value=$(echo "$output" | jq -r '.[] | select(.name == "invalid-plugin-standalone") | .invalid')
  [ -n "$invalid_value" ]
  [ "$invalid_value" != "null" ]
}

@test "all/plugin-items: valid directory skill has no invalid field" {
  export HOME="$fixtures_dir/home-with-invalid"
  run "$bin_dir/all/plugin-items"
  [ "$status" -eq 0 ]
  invalid_value=$(echo "$output" | jq -r '.[] | select(.name == "valid-plugin-skill") | .invalid')
  [ "$invalid_value" = "null" ]
}

@test "all/plugin-items: invalid field explains the error" {
  export HOME="$fixtures_dir/home-with-invalid"
  result=$("$bin_dir/all/plugin-items")
  invalid_msg=$(echo "$result" | jq -r '.[] | select(.name == "invalid-plugin-standalone") | .invalid')
  [[ "$invalid_msg" == *"standalone"* ]] || [[ "$invalid_msg" == *"directory"* ]]
}
