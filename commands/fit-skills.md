---
description: Audit skill description budget
---

# /gsd:fit-skills

First, find and read the skill file:

```bash
SKILL_PATH=$(find ~/.claude/plugins/cache -path "*/fit-skills/*/skills/fit-skills-context/SKILL.md" 2>/dev/null | head -1)
```

Then read `$SKILL_PATH` and follow the instructions in that file.
