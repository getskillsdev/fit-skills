#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
}

@test "scan-skills: finds SKILL.md files" {
  run "$bin_dir/scan-skills" "$fixtures_dir/home-with-themes/.claude/skills"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|theme-factory"* ]]
  [[ "$output" == *"|skill|pdf-skill"* ]]
}

@test "scan-skills: finds flat .md files in skills/" {
  run "$bin_dir/scan-skills" "$fixtures_dir/home-with-themes/.claude/skills"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|skill|flat-skill"* ]]
}

@test "scan-skills: ignores nested theme .md files" {
  run "$bin_dir/scan-skills" "$fixtures_dir/home-with-themes/.claude/skills"
  [ "$status" -eq 0 ]
  [[ "$output" != *"sunset"* ]]
  [[ "$output" != *"arctic"* ]]
}

@test "scan-skills: ignores nested reference .md files" {
  run "$bin_dir/scan-skills" "$fixtures_dir/home-with-themes/.claude/skills"
  [ "$status" -eq 0 ]
  [[ "$output" != *"forms"* ]]
}

@test "scan-skills: counts only real skills" {
  run "$bin_dir/scan-skills" "$fixtures_dir/home-with-themes/.claude/skills"
  [ "$status" -eq 0 ]
  # Should have exactly 3 skills: theme-factory, pdf-skill, flat-skill
  count=$(echo "$output" | grep -c "|skill|")
  [ "$count" -eq 3 ]
}
