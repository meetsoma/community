---
name: safe-file-ops
type: muscle
status: active
description: "Safe file operations — read before write, verify after edit, never delete without scanning dependencies."
heat: 0
triggers: [write, delete, file-ops, overwrite, safety, file-operations, workflow, read, edit, archive, backup, guard]
tags: [safety, files, editing, guard]
applies-to: [any]
created: 2026-03-10
updated: 2026-03-23
tools: [soma-refactor.sh]
---

# Safe File Operations

## Digest
<!-- digest:start -->
Four rules: (1) Never `write` without checking if the file exists first — write overwrites silently. Use `ls` then `read` then decide: `edit`, append, or write new. (2) Never `find ~` or broad find without timeout — stalls on large dirs. Use `ls`, scoped `grep -r`, or `timeout 3 find`. (3) Never clone to `/tmp/` — check for existing local clones first, clone to permanent workspace location. (4) Never create a muscle, protocol, or spec without `ls`ing the directory first — duplicates rot into false context.
<!-- digest:end -->

## Rules

### ❌ Never
- `find ~ -maxdepth N` — home dirs have node_modules, .git, caches. Will stall.
- `find / ...` — same problem, worse.
- `find` without a timeout on any directory you haven't sized.

### ✅ Instead
1. **Start with `ls`** — if you know the general area, just list it.
2. **`grep -r` in known dirs** — faster, scoped, and finds content not just names.
3. **`fd` if available** — respects .gitignore by default, much faster.
4. **`find` with timeout** — `timeout 3 find <dir> -maxdepth 2 -name "pattern"` — caps damage.
5. **Narrow the scope** — use project knowledge to pick the right starting directory.

### Escalation Pattern
```
ls <known-dir>/           # first: just look
grep -r "term" <dir>/     # second: search content in known scope
timeout 3 find <dir> -maxdepth 2 -name "pattern"  # third: broader but bounded
```

### Before Using Write — Always Check First
The `write` tool **overwrites without warning**. No diff, no backup, no prompt. If the file exists, it's gone.

**Before every write:**
1. `ls` the target directory — does the file already exist?
2. If yes → `read` it first. Understand what's there.
3. Then decide: `edit` (surgical change), append, merge, or write a new file with a different name.

**Never use `write` when `edit` would work.** Write is for new files or complete rewrites where you've already read the original.

### Never Clone to /tmp/
Clone repos to their permanent location in the workspace. `/tmp/` gets wiped on reboot. If the push fails or the user wants to review, the work is gone. Check `personal/`, `products/`, `archives/` first — the repo probably already exists locally.

### Why This Matters
A stalled `find` burns 30+ seconds of wall time and breaks session flow. The user notices.
Every `find` that stalls is a signal you didn't scope tightly enough. Think before searching.
