---
type: script
name: soma-compat
version: 1.0.0
status: active
author: meetsoma
license: MIT
tier: official
language: bash
description: Detects overlap, redundancy, and conflicting directives across protocols and muscles. Outputs a compatibility score.
tags: [audit, compatibility, protocols, muscles, hygiene]
requires: [bash, awk, grep]
created: 2026-04-25
updated: 2026-04-25
---

# soma-compat

Compatibility checker for `.soma/` content. Scans protocols and muscles for redundancy, conflicting directives, and structural overlap. Produces a score (out of 100) and a list of warnings.

## Usage

```bash
bash soma-compat.sh                   # check current project's .soma/
bash soma-compat.sh /path/to/project  # check a specific project
```

## What it checks

- Frontmatter consistency across protocols and muscles
- Duplicate directives (e.g. two protocols telling you opposite things)
- Common-keyword overlap (when two muscles are likely competing for the same trigger)
- Structural anti-patterns (e.g. a protocol shaped like a muscle)

## Output

```
Compatibility score: 87/100
Warnings: 3
  - protocol/quality-standards overlaps with muscle/working-style on key terms: "ship", "verify"
  - ...
```

## When to run

- After installing a new protocol or muscle from the hub
- Before committing a content change
- As a periodic hygiene pass on `.soma/`
