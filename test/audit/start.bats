#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"

  # Create temp project dir for testing
  test_project=$(mktemp -d)
  mkdir -p "$test_project/.claude"
}

teardown() {
  export HOME="$ORIG_HOME"
  cd "$ORIG_PWD"
  # Clean up temp project
  rm -rf "$test_project"
}

@test "audit/start: creates disk file in project root" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  run "$bin_dir/audit/start"
  [ "$status" -eq 0 ]
  # Should have created a file
  [ "$(ls "$test_project"/skill-audit-*-disk.json 2>/dev/null | wc -l)" -eq 1 ]
}

@test "audit/start: outputs audit token" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  run "$bin_dir/audit/start"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Audit token:"* ]]
}

@test "audit/start: outputs saved file path" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  run "$bin_dir/audit/start"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Saved:"* ]]
  [[ "$output" == *"-disk.json"* ]]
}

@test "audit/start: creates valid JSON" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  "$bin_dir/audit/start" > /dev/null
  file=$(ls "$test_project"/skill-audit-*-disk.json)
  jq '.' "$file" > /dev/null
}

@test "audit/start: filename contains date" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  "$bin_dir/audit/start" > /dev/null
  today=$(date +%Y-%m-%d)
  [ "$(ls "$test_project"/skill-audit-${today}-*-disk.json 2>/dev/null | wc -l)" -eq 1 ]
}

@test "audit/start: token is 8 chars lowercase" {
  export HOME="$fixtures_dir/home"
  cd "$test_project"
  run "$bin_dir/audit/start"
  [ "$status" -eq 0 ]
  token=$(echo "$output" | grep "Audit token:" | awk '{print $3}')
  [ "${#token}" -eq 8 ]
  [[ "$token" =~ ^[a-f0-9]+$ ]]
}

@test "audit/start: fails if no project root" {
  export HOME="$fixtures_dir/empty-home"
  cd /tmp
  run "$bin_dir/audit/start"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Could not find project root"* ]]
}

@test "audit/start: finds project root from subdirectory" {
  export HOME="$fixtures_dir/home"
  mkdir -p "$test_project/src/deep/nested"
  cd "$test_project/src/deep/nested"
  run "$bin_dir/audit/start"
  [ "$status" -eq 0 ]
  # File should be in project root, not nested dir
  [ "$(ls "$test_project"/skill-audit-*-disk.json 2>/dev/null | wc -l)" -eq 1 ]
  [ "$(ls "$test_project/src/deep/nested"/skill-audit-*-disk.json 2>/dev/null | wc -l)" -eq 0 ]
}
