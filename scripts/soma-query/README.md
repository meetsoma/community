---
type: script
name: soma-query
version: 1.0.0
status: active
author: meetsoma
license: MIT
language: bash
description: Search and explore across the entire Soma ecosystem — docs, code, sessions, and git
tags: [search, query, explore, sessions, frontmatter]
requires: [bash 4+, grep, sed, awk]
created: 2026-03-21
updated: 2026-04-01
---

# soma-query

Cross-ecosystem search that spans docs, code, sessions, and git history. Understands frontmatter, tags, and staleness.

## Commands

| Command | What it does |
|---------|-------------|
| `topic <query>` | Search across all sources (docs, code, sessions, git) |
| `search [--type X] [--tags Y] [--stale] [--deep]` | Frontmatter-based query |
| `related <file>` | Find files linked via frontmatter references |
| `sessions <query>` | Search session logs + preloads |

## Usage

```bash
# Search everything for a topic
soma-query.sh topic "heat system"

# Find stale protocols
soma-query.sh search --type protocol --stale

# Find files related to a plan
soma-query.sh related releases/v0.6.x/plans/init-prompt.md

# Search session logs
soma-query.sh sessions "correction"
```

## Install

```bash
soma hub install script soma-query
```
