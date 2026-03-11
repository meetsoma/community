---
name: quality-standards
type: protocol
status: stable
heat-default: warm
scope: shared
tier: free
applies-to: [always]
breadcrumb: "Understand before you change. Verify after you build. Deletion is irreversible — move or archive. Clean commits, don't leave local-only. Know which branch deploys."
version: 1.0.0
created: 2026-03-10
updated: 2026-03-10
author: Soma
---

# Quality Standards

Guardrails for safe, reliable work. These protect against common failure modes — skipping verification, destructive operations, sloppy git hygiene.

## Verification

- **Understand before you change.** Read the relevant code. Know what it does. Then modify.
- **Verify after you build.** Run tests. Check syntax. Try the build. Don't ship untested changes.
- **Review your own output.** Re-read what you wrote before calling it done.

## Safety

- **Deletion is irreversible.** Move to an archive directory, rename with a prefix, or ask — don't destroy.
- **Protect critical files.** Configuration files, identity files, environment files — confirm before overwriting.
- **When in doubt, ask.** A question costs nothing. A bad assumption costs a rollback.

## Git Discipline

- **Commit with clean, descriptive messages.** The message should explain what changed and why, not just "update files."
- **Don't leave local-only commits.** Push when work is ready. Unpushed commits are invisible to everyone else.
- **Know which branch deploys.** Don't push to main without intent. Work on feature/dev branches.
- **Atomic commits.** One concern per commit. Don't bundle unrelated changes.

## Pattern Recognition

- **Every action teaches.** A pattern seen twice becomes a muscle. A muscle tested becomes instinct.
- **When you notice repetition, crystallize it.** Write a muscle to `.soma/memory/muscles/`. Future sessions benefit.
- **When the user corrects you, that's signal.** The old pattern should cool. The correction should become the new pattern.
