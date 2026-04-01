---
type: script
name: soma-code
version: 2.0.0
status: active
author: meetsoma
license: MIT
language: bash
description: Fast codebase navigator — find, map, refs, blast radius, structure, and more
tags: [navigation, search, code, grep, map, refactor, blast-radius]
requires: [bash 4+, grep, sed, awk]
created: 2026-03-15
updated: 2026-04-01
---

# soma-code

Fast codebase navigator built for AI agents. Replaces scattered `grep`, `find`, and `cat` commands with structured, line-numbered output that's immediately actionable.

## Commands

| Command | What it does |
|---------|-------------|
| `find <pattern> [path] [ext]` | Grep with `file:line` format — clickable in terminal |
| `lines <file> <start> [end]` | Show exact line range with line numbers |
| `map <file\|dir>` | Function/class/interface map for TS/JS/Bash/CSS/Astro |
| `refs <symbol> [path]` | Find all references — classifies DEF vs IMP vs USE |
| `blast <symbol> [path]` | Blast radius — files × risk assessment |
| `replace <file> <ln> <old> <new>` | Line-specific find & replace |
| `structure [path]` | File tree with sizes |
| `tsc-errors [path]` | TypeScript errors with context lines |
| `physics [path]` | Find all physics/animation code |
| `events [path]` | Find all event listeners and dispatchers |
| `css-vars [path]` | CSS custom property definitions and usage count |
| `config [path]` | Find config/options/settings objects |

## Usage

```bash
# Find all references to a function
soma-code.sh refs loadSettings

# See blast radius before renaming
soma-code.sh blast findPreload extensions/

# Map a file before editing
soma-code.sh map src/core/identity.ts

# Grep with file:line format
soma-code.sh find "session_start" extensions/ ts
```

## v2.0.0 Changes

- Added `blast` command — blast radius analysis with risk scoring
- Added `tsc-errors` command — TypeScript errors with surrounding context
- Improved `refs` output — DEF/IMP/USE classification
- Improved `find` — optional extension filter, suggestion on no results
- Better help output with colored formatting

## Install

```bash
soma hub install script soma-code
```

Or copy `soma-code.sh` to your project and run directly.
