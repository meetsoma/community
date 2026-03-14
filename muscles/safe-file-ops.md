---
type: muscle
name: safe-file-ops
status: active
heat-default: warm
heat: 0
loads: 0
breadcrumb: "Check before write, never delete without backup, scope your searches, check for existing content before creating."
author: meetsoma
license: MIT
version: 1.0.0
tier: official
scope: hub
topic: [safety, files, tools, workflow]
keywords: [safe-file-ops, write, delete, find, duplicate, overwrite]
created: 2026-03-14
updated: 2026-03-14
---

# Safe File Operations

<!-- digest:start -->
> **Safe File Ops** — four rules: (1) Never `write` without checking if the file exists first — `write` overwrites silently. Use `ls` or `read`, then decide: `edit`, append, or create new. (2) Never `find ~` or broad find without a timeout — stalls on large dirs. Use `ls`, scoped `grep -r`, or `timeout 3 find`. (3) Never delete without confirming — move to archive or rename with a prefix instead. (4) Never create a new file without checking the directory first — duplicates create false context that poisons future sessions.
<!-- digest:end -->

## The Rules

### 1. Check before write
`write` silently overwrites existing files. Before writing:
```
ls path/to/file          # does it exist?
read path/to/file        # what's in it?
# THEN decide: edit (surgical), append, or write (new file only)
```

### 2. Scope your searches
```bash
# ❌ Dangerous — can stall for minutes
find ~ -name "*.md"

# ✅ Safe alternatives
ls .soma/protocols/                    # known directory
grep -rn "keyword" src/ --include="*.ts"  # scoped + filtered
timeout 3 find . -name "*.md"          # time-bounded
```

### 3. Archive, don't delete
```bash
# ❌ Irreversible
rm -rf old-feature/

# ✅ Recoverable
mv old-feature/ _archive/old-feature/
# or
git rm old-feature/ && git commit -m "archive: old-feature"
```

### 4. Check before create
```bash
# Before creating a new muscle, protocol, or plan:
ls .soma/amps/muscles/         # what already exists?
grep -l "similar-concept" .soma/amps/muscles/*.md  # any overlap?
# THEN create if truly new
```

## Why This Matters

- A silently overwritten file might have had user customizations
- A stalled `find` wastes an entire agent turn
- Deleted operational scripts orphan the tests and muscles that reference them
- Duplicate files create conflicting context — the agent sees both and gets confused
