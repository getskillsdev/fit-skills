#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures/compare" && pwd)"
}

@test "compare/on-disk-not-in-context: returns items in disk but not in context" {
  run "$bin_dir/compare/on-disk-not-in-context" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  # dropped-skill is in disk.json but not in context.json
  [[ "$output" == *"dropped-skill"* ]]
  # my-skill is in both, should NOT appear
  [[ "$output" != *"my-skill"* ]] || [[ "$output" == *"dropped-skill"* ]]
}

@test "compare/on-disk-not-in-context: preserves all fields from disk" {
  run "$bin_dir/compare/on-disk-not-in-context" "$fixtures_dir/disk.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  # Should have type and source fields
  [[ "$output" == *'"type"'* ]]
  [[ "$output" == *'"source"'* ]]
}

@test "compare/on-disk-not-in-context: returns empty array when all items match" {
  run "$bin_dir/compare/on-disk-not-in-context" "$fixtures_dir/context.json" "$fixtures_dir/context.json"
  [ "$status" -eq 0 ]
  [ "$output" = "[]" ]
}

@test "compare/on-disk-not-in-context: returns all items when context is empty" {
  run "$bin_dir/compare/on-disk-not-in-context" "$fixtures_dir/disk.json" "$fixtures_dir/empty.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-skill"* ]]
  [[ "$output" == *"dropped-skill"* ]]
  [[ "$output" == *"blog:post"* ]]
  [[ "$output" == *"pptx"* ]]
}

@test "compare/on-disk-not-in-context: fails when disk file missing" {
  run "$bin_dir/compare/on-disk-not-in-context" "/nonexistent.json" "$fixtures_dir/context.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}

@test "compare/on-disk-not-in-context: fails when context file missing" {
  run "$bin_dir/compare/on-disk-not-in-context" "$fixtures_dir/disk.json" "/nonexistent.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File not found"* ]]
}
