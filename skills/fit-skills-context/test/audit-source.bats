#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
}

teardown() {
  export HOME="$ORIG_HOME"
  [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR" || true
}

@test "audit-source: requires source argument" {
  run "$bin_dir/audit-source"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "audit-source: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' >/dev/null
}

@test "audit-source: includes source in output" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.source')" = "global" ]
}

@test "audit-source: includes audit_date" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.audit_date')" = "$(date +%Y-%m-%d)" ]
}

@test "audit-source: counts skills from fixtures" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  # fixtures/home has 2 skills
  [ "$(echo "$output" | jq '.skills | length')" -eq 2 ]
}

@test "audit-source: counts commands from fixtures" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  # fixtures/home has 2 commands (my-cmd, blog:post)
  [ "$(echo "$output" | jq '.commands | length')" -eq 2 ]
}

@test "audit-source: calculates total_chars correctly" {
  export HOME="$fixtures_dir/home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]

  skills_chars=$(echo "$output" | jq '.skills_chars')
  commands_chars=$(echo "$output" | jq '.commands_chars')
  total_chars=$(echo "$output" | jq '.total_chars')

  [ "$total_chars" -eq $((skills_chars + commands_chars)) ]
}

@test "audit-source: writes to output file when specified" {
  export HOME="$fixtures_dir/home"
  TMP_DIR="$(mktemp -d)"
  run "$bin_dir/audit-source" global "$TMP_DIR/output.json"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIR/output.json" ]
  jq '.' "$TMP_DIR/output.json" >/dev/null
}

@test "audit-source: handles empty source gracefully" {
  export HOME="$fixtures_dir/empty-home"
  run "$bin_dir/audit-source" global
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.skills | length')" -eq 0 ]
  [ "$(echo "$output" | jq '.commands | length')" -eq 0 ]
  [ "$(echo "$output" | jq '.total_chars')" -eq 0 ]
}
