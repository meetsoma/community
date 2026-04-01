---
type: script
name: soma-plans
version: 1.0.0
status: active
author: meetsoma
license: MIT
language: bash
description: Plan lifecycle management — list, check, archive, and audit plans
tags: [plans, lifecycle, audit, workflow, hygiene]
requires: [bash 4+, grep, sed, awk]
created: 2026-03-21
updated: 2026-04-01
---

# soma-plans

Manages the plan lifecycle — lists active plans, checks for stale or completed plans, and helps with archival. Works with the plan-hygiene protocol.

## Usage

```bash
# List all plans with status
soma-plans.sh

# Check for stale plans (no updates in 7+ days)
soma-plans.sh --stale

# Show plan budget (≤12 active recommended)
soma-plans.sh --budget
```

## Install

```bash
soma hub install script soma-plans
```
