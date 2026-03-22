---
type: protocol
name: quality-standards
status: active
heat-default: warm
applies-to: [always]
breadcrumb: "Deletion is irreversible — move or archive. Tests cover NEW code, not just pass on old. Blast radius before editing — find every caller, test, and doc. Atomic commits — one concern each."
author: meetsoma
license: MIT
version: 1.0.0
tier: official
scope: bundled
tags: [quality, safety, git, workflow]
created: 2026-03-10
updated: 2026-03-22
---

# Quality Standards

Guardrails for safe, reliable work. These protect against destructive operations and sloppy git hygiene. Verification lives in tool-discipline. Pattern recognition lives in pattern-evolution.

## TL;DR

Never delete — move or archive. Clean atomic commits with descriptive messages. Push when ready. Know which branch deploys. Confirm before touching critical files. Close the loop — when fixing a bug, fix the system that allowed it. Tests match shipped code, not planned features. Use conventional commit format: `type(scope): description`.

## When to Apply

Every session, every commit. These are baseline guardrails — not optional refinements.

## Safety

- **Deletion is irreversible.** Move to an archive directory, rename with a prefix, or ask — don't destroy.
- **Protect critical files.** Configuration files, identity files, environment files — confirm before overwriting.
- **When in doubt, ask.** A question costs nothing. A bad assumption costs a rollback.

## Git Discipline

- **Commit with clean, descriptive messages.** The message should explain what changed and why, not just "update files."
- **Don't leave local-only commits.** Push when work is ready. Unpushed commits are invisible to everyone else.
- **Know which branch deploys.** Don't push to main without intent. Work on feature/dev branches.
- **Atomic commits.** One concern per commit. Don't bundle unrelated changes.
- **Conventional commit format.** `type(scope): description` — type is `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Scope is optional but helpful.

## Closing the Loop

- **Fix the system, not just the instance.** When you find a bug, ask: what allowed this to happen? Fix the root cause — a missing test, a stale check, a gap in validation.
- **When code changes, check the tools.** Scripts, verification checks, and tests can go stale when the code they operate on changes. After any structural change, verify that tooling still produces correct results.
- **Tests cover new code, not just pass on old.** Every code change must include test assertions for the NEW behavior. Existing tests passing on new code is false confidence — they're checking yesterday's behavior. The test: if you removed your change, would a test fail? If not, you haven't tested it.
- **Blast radius before editing.** Before changing a function, type, or field: search for every reference. `grep -rn "function_name" src/ tests/ docs/` — find callers, tests, and docs that need updating alongside the code. A code change without test/doc updates is half-shipped.

## Shipped Tools

Soma ships scripts that implement these practices. Use them instead of raw commands:

| Practice | Tool | Example |
|----------|------|---------|
| Find references (blast radius) | `soma-code.sh find` | `soma-code.sh find "functionName" src/` |
| Map file structure before editing | `soma-code.sh map` | `soma-code.sh map src/myfile.ts` |
| Check test coverage exists | `grep` | `grep -rn "functionName" tests/` |
| Search for prior art | `soma-query.sh search` | `soma-query.sh search "keyword"` |
| Git identity enforcement | `git-identity-hook.sh` | Install as `.git/hooks/pre-commit` |
| File tree overview | `soma-code.sh structure` | `soma-code.sh structure src/` |

Run any script with `--help` for full options.

---
