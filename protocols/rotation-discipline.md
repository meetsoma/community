---
name: rotation-discipline
type: protocol
status: active
description: "Blocks writing a preload until this checklist is read — the only mechanical gate on rotation discipline that ships to the community distribution. breath-cycle names the exhale checklist; this is what enforces it with primitives that actually ship here."
heat-default: cold
tags: [session, rotation, exhale, memory, continuity]
applies-to: [always]
gates:
  - paths: ["memory/preloads/"]
    mode: block
    tool: write
    rule: "CLEARS BY READING: protocols/rotation-discipline.md (this file). A preload written without a session log, a git-state check, and — above 70% context — a reflection pass loses the session. The checklist is short; read it once."
scope: bundled
tier: official
created: 2026-08-14
updated: 2026-08-14
version: 1.0.0
author: meetsoma
license: MIT
---

# Rotation Discipline

## TL;DR
Before writing a preload: verify git state, write or append the session log (`micro-exhale` muscle format), and — above ~70% context — run a `memory-lane-reflection` pass. This protocol's gate **blocks the preload write** until this file has been read once this session. It cannot verify the checklist was actually followed — only that it was seen.

## When to Apply
At `/exhale`, `/breathe`, or any natural-language wrap-up phrase (see `breath-cycle`) — specifically at the LAST step of that checklist, the preload write.

## Why This Exists

`breath-cycle` names a multi-step exhale checklist and warns that a faithful trigger with an incomplete checklist still loses the session — but `breath-cycle` itself carries no enforcement (`scope: core`, zero `gates:`). The deeper discipline some Soma deployments run — a structured pre-reflection interrogation, a mechanical link/reference audit before trusting a preload, an explicit handoff to a successor session — is real, but **none of it ships to this distribution.** Community installs get `protocols/`, `muscles/`, `automations/`, `templates/`, and `scripts/` — nothing that depends on a skills layer.

This protocol closes part of that gap using only what's here: a `mode: block` gate on `memory/preloads/`, the same mechanism `working-style` uses to remind after a commit and `changelog-style` uses to block an undocumented CHANGELOG edit (see that pattern in `meetsoma`'s own `.soma/amps/protocols/`). It fires on the first `write` under `memory/preloads/` each session and stays shut until this file has been read.

## The Checklist (what ships)

1. **Verify state** — `git status` in every touched repo. Unpushed work described as shipped in a preload is a lie the next session will believe.
2. **Log the session** — append to today's session log using the `micro-exhale` muscle's format (`## HH:MM` sections, one file per day, read first, never overwrite). This is the durable record; the preload is a pointer into it, not a replacement for it.
3. **Reflect, if context is high** — above roughly 70% context, run the `memory-lane-reflection` muscle (3-5 cycles) BEFORE the preload. It surfaces connections the tactical mind skipped; writing the preload first forecloses that.
4. **Write the preload last** — use `preload-template` if installed, or the built-in default. Resume point, what shipped, orient-from, next steps. Not a summary — a briefing for an amnesiac reader.

## What This Gate CAN Enforce
- That this file has been READ before the preload write completes, once per session — the same trip-wire `changelog-style` uses for `CHANGELOG.md`.
- That the reminder fires on every session that writes a preload, not only the ones where someone remembers to check a doc.

## What This Gate CANNOT Enforce
- **Content.** A `paths:` gate sees that you wrote to `memory/preloads/`; it cannot see whether you ran the reflection, wrote the log first, or checked git state. Reading this file clears the gate whether or not the checklist above was actually followed.
- **A structured pre-reflection interrogation.** There is no shipped set of standing diagnostic questions to answer before reflecting — only the `memory-lane-reflection` muscle's open-ended cycle.
- **A mechanical link/reference audit.** Nothing here resolves every file reference and commit hash in a preload before trusting it. A dead pointer in a community preload will not be caught by this gate.
- **Successor handoff.** There is no shipped mechanism for spawning or notifying a next agent session — that assumes an orchestrator topology this distribution doesn't have. A community session ends; it doesn't hand off between panes.
- **A second preload write in the same session.** The gate clears for the whole session on the first read — a later preload write (after amending or re-exhaling) is not re-gated.

## Settings

Turn this gate off like any protocol gate: `/gates off rotation-discipline`, or add `"rotation-discipline"` to `guard.gatesOff` in `.soma/settings.json`.

## Source
- Gate mechanism: `soma-guard` extension → protocol frontmatter `gates:` (`mode: block` on a `paths:` pattern, cleared by reading the owning doc)
- Pattern precedent, same repo: `protocols/working-style.md` (`after:` commit/push reminders)
