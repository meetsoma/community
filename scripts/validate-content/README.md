---
type: script
name: validate-content
version: 1.0.0
status: active
author: meetsoma
license: MIT
tier: official
language: bash
description: Validate AMPS content files (protocols, muscles, automations) before submitting a PR to the hub. Checks frontmatter, breadcrumb, TL;DR, naming, PII patterns.
tags: [validation, hub, contributing, frontmatter, ci]
requires: [bash, awk, grep]
created: 2026-04-25
updated: 2026-04-25
---

# validate-content

Pre-flight validator for content contributed to the Soma hub (`meetsoma/community`). Checks the structural requirements that the hub-index generator and the agent's content loaders expect.

## Usage

```bash
bash validate-content.sh <file.md>          # validate one file
bash validate-content.sh <directory>        # validate all .md in dir
bash validate-content.sh --type protocol .  # filter by type
```

## What it checks

- **Frontmatter:** valid YAML; required keys present (`type`, `name`, `status`, `heat-default`)
- **Breadcrumb:** present, under 200 chars
- **TL;DR section:** required for protocols (warm-tier loading)
- **Digest markers:** required for muscles
- **File naming:** kebab-case enforced
- **PII patterns:** flags emails, API-key-shaped strings, common secrets
- **`applies-to`:** valid array

## Exit codes

| Code | Meaning |
|---|---|
| 0 | All checks passed |
| 1 | One or more files failed validation |
| 2 | Usage error / bad arguments |

## Recommended pre-commit usage

```bash
# .git/hooks/pre-commit
bash scripts/validate-content/validate-content.sh \
  $(git diff --cached --name-only --diff-filter=AM | grep '\.md$')
```
