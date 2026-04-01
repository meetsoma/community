---
type: script
name: soma-seam
version: 1.0.0
status: active
author: meetsoma
license: MIT
language: bash
description: Trace concepts through memory, code, and sessions — the connective tissue of your .soma/
tags: [memory, trace, search, connections, seam, graph, timeline]
requires: [bash 4+, grep, sed, awk]
created: 2026-03-15
updated: 2026-04-01
---

# soma-seam

Traces concepts through your entire `.soma/` workspace — memory, code, sessions, plans, and protocols. Shows how ideas connect, evolve, and where they live.

## Commands

| Command | What it does |
|---------|-------------|
| `trace <term>` | Follow a concept through everything — sessions, plans, muscles, code |
| `graph <seam-hash>` | Map everything connected to a session |
| `matrix <tag> [--depth N]` | Build connection matrix for a tag |
| `timeline [--tag TAG]` | Chronological evolution of a concept |
| `code <pattern>` | Code + context together (like find, but with .soma/ awareness) |
| `audit upstream [range]` | Audit upstream changes for breaking imports |

## Usage

```bash
# Trace a concept across all memory
soma-seam.sh trace "heat system"

# Timeline of how a feature evolved
soma-seam.sh timeline --tag heat

# Audit upstream Pi changes for breakage
soma-seam.sh audit upstream v0.63.1..v0.64.0
```

## Install

```bash
soma hub install script soma-seam
```
