---
type: script
name: git-identity-hook
version: 1.0.0
status: active
author: meetsoma
license: MIT
tier: official
language: bash
description: Pre-commit hook that validates git user.email before allowing commits. Lightweight safety net for multi-account workflows.
tags: [git, hooks, identity, safety, multi-account]
requires: [bash, git]
created: 2026-04-25
updated: 2026-04-25
---

# git-identity-hook

A pre-commit hook that validates `git user.email` before allowing a commit. Useful when you switch between work and personal git accounts and want a guard against committing under the wrong identity.

## Modes

| Configuration in `.soma/settings.json` | Behavior |
|---|---|
| `guard.gitIdentity.email` set | Enforces that exact email |
| Not set | Just checks that `user.email` is non-empty |

The hook checks the first email value only. For multi-email validation (array format), `soma-guard.ts` runtime handles the full check; this hook is a fast pre-commit safety net.

## Install

```bash
# Direct copy
cp git-identity-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Or via soma init
soma init --hooks
```

## Why

Easy to forget which account you're commiting under after `git config --local user.email <other>`. This hook fails the commit before it lands.
