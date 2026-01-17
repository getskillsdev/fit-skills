# fit-skills

[![CI](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml)

📺 <a href="https://youtu.be/bRLnq0mxynQ" target="_blank">Watch: Anthropic's Plugin is Eating Your Claude's Budget</a>

Did your Claude stuff its context window with too many bloated skills?

<img src="./logo.png" alt="fit-skills logo" width="200">

## Why use this?

Answers the frustrating "why isn't my skill loading?" question:

- **Description budget usage** - are you over the 15k char limit?
- **Token usage per plugin** - which plugins consume the most?
- **Disk vs context comparison** - what's configured vs what's loaded?
- **Disabled MCP detection** - servers toggled off but forgotten?
- **Invalid skill detection** - standalone .md files that won't load?
- **Dropped skills** - identify what got cut due to token limits

## Overview

Use this diagnostic tool to analyse skills across:
- `User` (global)
- `plugin`
- `project`

Which skills are being loaded into the context-window - and determine how much headroom you have.

Find misbehaving plugins.

## Features

- Shows budget summary across global, plugins, and project sources
- Per-plugin breakdown of description character usage
- Lists skills and commands with char counts
- Identifies which plugins are consuming the most budget
- Actionable advice when over 80% used

## Requirements

- `jq` - JSON processor

```bash
# macOS
brew install jq

# Linux
sudo apt-get install -y jq
```

## Install (quit Claude first)

```bash
claude plugin marketplace add getskillsdev/fit-skills
claude plugin install gsd@fit-skills
```

## Usage (in Claude)

```
/gsd:fit-skills
```

## Update (quit Claude first)

```bash
claude plugin marketplace update fit-skills
claude plugin update gsd@fit-skills
```

## Uninstall (quit Claude first)

```bash
claude plugin uninstall gsd@fit-skills
claude plugin marketplace remove fit-skills
```

## Troubleshooting

**Command not showing in completion?**

Restart Claude after installing or updating plugins.

## License

MIT - see [LICENSE.md](./LICENSE.md)

## Disclaimer

Not affiliated with, endorsed by, or sponsored by Anthropic.
