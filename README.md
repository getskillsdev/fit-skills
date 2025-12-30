# fit-skills

[![CI](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml)

Did your Claude stuff its context window with too many bloated skills?

<img src="./logo.png" alt="fit-skills logo" width="200">

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

## License

MIT - see [LICENSE.md](./LICENSE.md)
