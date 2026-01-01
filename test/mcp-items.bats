#!/usr/bin/env bats

setup() {
  bin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/../skills/fit-skills-context/bin" && pwd)"
  fixtures_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  ORIG_HOME="$HOME"
  ORIG_PWD="$PWD"
}

teardown() {
  export HOME="$ORIG_HOME"
  cd "$ORIG_PWD"
}

@test "all/mcp-items: outputs valid JSON" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq '.' > /dev/null
}

@test "all/mcp-items: returns empty array when no MCP config" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq 'length')" -eq 0 ]
}

@test "all/mcp-items: includes project MCP servers" {
  export HOME="$fixtures_dir/empty-home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "playwright" and .source == "project")'
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .source == "project")'
}

@test "all/mcp-items: includes global MCP servers" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/empty-home"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "astro-docs" and .source == "global")'
}

@test "all/mcp-items: type is mcp for all entries" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # All entries should have type "mcp"
  count=$(echo "$output" | jq '[.[] | select(.type == "mcp")] | length')
  total=$(echo "$output" | jq 'length')
  [ "$count" -eq "$total" ]
}

@test "all/mcp-items: includes path field" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # Project MCP should have .mcp.json path
  echo "$output" | jq -e '.[] | select(.name == "playwright") | .path' | grep -q ".mcp.json"
  # Global MCP should have .claude.json path
  echo "$output" | jq -e '.[] | select(.name == "astro-docs") | .path' | grep -q ".claude.json"
}

@test "all/mcp-items: plugin field is null" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.plugin == null)' > /dev/null
}

@test "all/mcp-items: combines project and global servers" {
  export HOME="$fixtures_dir/home"
  cd "$fixtures_dir/project"
  run "$bin_dir/all/mcp-items"
  [ "$status" -eq 0 ]
  # Should have both project (2) and global (1) servers
  [ "$(echo "$output" | jq 'length')" -eq 3 ]
}

@test "all/mcp-items: disabled project MCP shows disabled: true" {
  # Create temp config with correct project path
  local tmp_home=$(mktemp -d)
  local project_path="$fixtures_dir/project"
  cat > "$tmp_home/.claude.json" <<EOF
{
  "projects": {
    "$project_path": {
      "disabledMcpServers": ["vercel"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$project_path"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "playwright" and .disabled == null)'
}

@test "all/mcp-items: disabled global MCP shows disabled: true" {
  # Create temp config with global server + disabled state
  local tmp_home=$(mktemp -d)
  mkdir -p "$tmp_home/.claude"
  local project_path=$(readlink -f "$tmp_home")
  cat > "$tmp_home/.claude.json" <<EOF
{
  "mcpServers": {
    "astro-docs": {"command": "npx", "args": ["@anthropic/mcp-astro"]},
    "memory": {"command": "npx", "args": ["@anthropic/mcp-memory"]}
  },
  "projects": {
    "$project_path": {
      "disabledMcpServers": ["astro-docs"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "astro-docs" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "memory" and .disabled == null)'
}

@test "all/mcp-items: disabled in local config affects both project and global MCP" {
  # Create temp config with both project .mcp.json and global mcpServers
  local tmp_home=$(mktemp -d)
  local resolved_home=$(readlink -f "$tmp_home")
  mkdir -p "$tmp_home/.claude"
  cat > "$tmp_home/.mcp.json" <<EOF
{"mcpServers": {"vercel": {"command": "npx", "args": []}}}
EOF
  cat > "$tmp_home/.claude.json" <<EOF
{
  "mcpServers": {
    "astro-docs": {"command": "npx", "args": []}
  },
  "projects": {
    "$resolved_home": {
      "disabledMcpServers": ["vercel", "astro-docs"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .source == "project" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "astro-docs" and .source == "global" and .disabled == true)'
}

@test "all/mcp-items: global disabledMcpServers disables servers in all projects" {
  local tmp_home=$(mktemp -d)
  cat > "$tmp_home/.mcp.json" <<EOF
{"mcpServers": {"vercel": {"command": "npx", "args": []}}}
EOF
  cat > "$tmp_home/.claude.json" <<EOF
{
  "disabledMcpServers": ["vercel"]
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .disabled == true)'
}

@test "all/mcp-items: disabledMcpjsonServers at project level disables servers" {
  local tmp_home=$(mktemp -d)
  local resolved_home=$(readlink -f "$tmp_home")
  cat > "$tmp_home/.mcp.json" <<EOF
{"mcpServers": {"playwright": {"command": "npx", "args": []}}}
EOF
  cat > "$tmp_home/.claude.json" <<EOF
{
  "projects": {
    "$resolved_home": {
      "disabledMcpjsonServers": ["playwright"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "playwright" and .disabled == true)'
}

@test "all/mcp-items: disabledMcpjsonServers at global level disables servers" {
  local tmp_home=$(mktemp -d)
  cat > "$tmp_home/.mcp.json" <<EOF
{"mcpServers": {"memory": {"command": "npx", "args": []}}}
EOF
  cat > "$tmp_home/.claude.json" <<EOF
{
  "disabledMcpjsonServers": ["memory"]
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.[] | select(.name == "memory" and .disabled == true)'
}

@test "all/mcp-items: combines all 4 disabled sources" {
  local tmp_home=$(mktemp -d)
  local resolved_home=$(readlink -f "$tmp_home")
  cat > "$tmp_home/.mcp.json" <<EOF
{"mcpServers": {
  "srv1": {"command": "npx", "args": []},
  "srv2": {"command": "npx", "args": []},
  "srv3": {"command": "npx", "args": []},
  "srv4": {"command": "npx", "args": []},
  "enabled": {"command": "npx", "args": []}
}}
EOF
  cat > "$tmp_home/.claude.json" <<EOF
{
  "disabledMcpServers": ["srv1"],
  "disabledMcpjsonServers": ["srv2"],
  "projects": {
    "$resolved_home": {
      "disabledMcpServers": ["srv3"],
      "disabledMcpjsonServers": ["srv4"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$tmp_home"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home"
  [ "$status" -eq 0 ]
  # All 4 should be disabled
  echo "$output" | jq -e '.[] | select(.name == "srv1" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "srv2" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "srv3" and .disabled == true)'
  echo "$output" | jq -e '.[] | select(.name == "srv4" and .disabled == true)'
  # One should be enabled
  echo "$output" | jq -e '.[] | select(.name == "enabled" and .disabled == null)'
}

@test "all/mcp-items: resolves symlinks when checking disabled status" {
  local tmp_home=$(mktemp -d)
  local real_project=$(mktemp -d)
  local resolved_project=$(readlink -f "$real_project")
  local symlink_project="$tmp_home/symlink-project"
  ln -s "$real_project" "$symlink_project"

  cat > "$real_project/.mcp.json" <<EOF
{"mcpServers": {"vercel": {"command": "npx", "args": []}}}
EOF
  # Config uses fully resolved path (matches what script will resolve to)
  cat > "$tmp_home/.claude.json" <<EOF
{
  "projects": {
    "$resolved_project": {
      "disabledMcpServers": ["vercel"]
    }
  }
}
EOF
  export HOME="$tmp_home"
  cd "$symlink_project"
  run "$bin_dir/all/mcp-items"
  rm -rf "$tmp_home" "$real_project"
  [ "$status" -eq 0 ]
  # Should find disabled status even when running from symlink
  echo "$output" | jq -e '.[] | select(.name == "vercel" and .disabled == true)'
}
