---
type: script
name: soma-snapshot
version: 1.0.0
status: active
author: meetsoma
license: MIT
tier: official
language: bash
description: Rolling zip snapshots of project directories. Respects .zipignore (or .gitignore), keeps last 3 per project, syncs to external drive if mounted.
tags: [backup, snapshot, archive, recovery]
requires: [bash, zip]
created: 2026-04-25
updated: 2026-04-25
---

# soma-snapshot

Take a rolling-window zip snapshot of a project directory. Useful before risky reorgs, mass renames, or destructive refactors — when you want a "right now" snapshot you can restore without touching git.

## Usage

```bash
soma-snapshot.sh <project-dir> [label]
soma-snapshot.sh /path/to/project "pre-reorg"
soma-snapshot.sh .                          # current dir, auto-labeled
```

## Features

- **Respects `.zipignore`** (same syntax as `.gitignore`). Falls back to `.gitignore` if no `.zipignore` present.
- **Excludes by default:** `node_modules`, `.git`, `dist`, `build`.
- **Rolling window:** keeps the last 3 snapshots per project. Older ones are pruned.
- **External-drive sync:** if `$SOMA_EXTERNAL_DRIVE` (default `/Volumes/Backup`) is mounted, copies the snapshot there too.

## Configuration

| Env var | Default | What |
|---|---|---|
| `SOMA_SNAPSHOT_DIR` | `~/.soma/snapshots` | Where local snapshots live |
| `SOMA_EXTERNAL_DRIVE` | `/Volumes/Backup` | macOS external mount path for sync |

## Restore

Snapshots are plain zip files. Extract anywhere:

```bash
unzip ~/.soma/snapshots/myproject-pre-reorg-2026-04-25.zip -d /tmp/restore
```
