---
type: script
name: soma-reflect
version: 1.0.0
status: active
author: meetsoma
license: MIT
language: bash
description: Parse session logs for observations, gaps, and recurring patterns
tags: [memory, reflection, patterns, session-logs, observations]
requires: [bash 4+, grep, sed, awk]
created: 2026-03-21
updated: 2026-04-01
---

# soma-reflect

Scans your session logs for observations, gaps, corrections, and recurring patterns. Surfaces insights that would otherwise be buried in conversation history.

## Usage

```bash
# Last 7 days, all signals
soma-reflect.sh

# Since a specific date
soma-reflect.sh --since 2026-03-12

# Last 14 days
soma-reflect.sh --days 14

# Only gaps, bugs & fixes
soma-reflect.sh --gaps

# Only observations & insights
soma-reflect.sh --observations
```

## What It Finds

- **Observations** — tagged insights from sessions (`[testing]`, `[architecture]`, etc.)
- **Gaps** — things that broke or were missing
- **Corrections** — behavioral adjustments noted in logs
- **Recurring patterns** — themes that appear across multiple sessions

## Install

```bash
soma hub install script soma-reflect
```
