# fit-skills

[![CI](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/getskillsdev/fit-skills/actions/workflows/ci.yml)

Did your Claude stuff its context window with too many bloated skills?

<img src="./logo.png" alt="fit-skills logo" width="200">

Use this diagnostic tool to find which skills, both `User` (global), `plugins` and `project` specific are being loaded into the context-window to determine how much headroom you have.

Find misbehaving plugins.

## Features

- Shows budget summary across global, plugins, and project sources
- Per-plugin breakdown of description character usage
- Lists skills and commands with char counts
- Identifies which plugins are consuming the most budget
- Actionable advice when over 80% used

## Requirements

- `jq` - JSON processor ([install](https://jqlang.github.io/jq/download/))

## Install

```bash
claude plugin marketplace add getskillsdev/fit-skills
claude plugin install gsd@fit-skills
```

## Usage

```
/gsd:fit-skills
```

## Update

```bash
claude plugin marketplace update fit-skills
claude plugin update gsd@fit-skills
```

## Uninstall

```bash
claude plugin uninstall gsd@fit-skills
claude plugin marketplace remove fit-skills
```

## License

MIT - see [LICENSE.md](./LICENSE.md)
