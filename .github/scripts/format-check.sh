#!/usr/bin/env bash
# Check structural format requirements for community assets.
set -euo pipefail

FAIL=0

# === Protocols must have TL;DR section ===
for f in protocols/*.md; do
  [ -f "$f" ] || continue
  if ! grep -q "^## TL;DR" "$f"; then
    echo "FAIL: $f — missing ## TL;DR section"
    FAIL=1
  fi
  if ! grep -q "^## When to Apply" "$f"; then
    echo "FAIL: $f — missing ## When to Apply section"
    FAIL=1
  fi
  if ! grep -q "^## When NOT to Apply" "$f"; then
    echo "WARN: $f — missing ## When NOT to Apply section (recommended)"
  fi
done

# === Muscles must have digest blocks ===
for f in muscles/*.md; do
  [ -f "$f" ] || continue
  if ! grep -q "<!-- digest:start -->" "$f"; then
    echo "FAIL: $f — missing <!-- digest:start --> marker"
    FAIL=1
  fi
  if ! grep -q "<!-- digest:end -->" "$f"; then
    echo "FAIL: $f — missing <!-- digest:end --> marker"
    FAIL=1
  fi
  
  # Digest should come before the main body
  start_line=$(grep -n "<!-- digest:start -->" "$f" | head -1 | cut -d: -f1)
  end_line=$(grep -n "<!-- digest:end -->" "$f" | head -1 | cut -d: -f1)
  if [ -n "$start_line" ] && [ -n "$end_line" ]; then
    if [ "$start_line" -gt 30 ]; then
      echo "WARN: $f — digest block starts late (line $start_line). Put it near the top."
    fi
    digest_lines=$((end_line - start_line))
    if [ "$digest_lines" -gt 12 ]; then
      echo "WARN: $f — digest block is $digest_lines lines. Keep it under 10 for token efficiency."
    fi
  fi
done

# === Automations must have a title ===
for f in automations/*.md; do
  [ -f "$f" ] || continue
  if ! grep -q "^# " "$f"; then
    echo "FAIL: $f — missing # Title section"
    FAIL=1
  fi
done

# === File naming convention: kebab-case ===
for f in protocols/*.md muscles/*.md automations/*.md; do
  [ -f "$f" ] || continue
  basename=$(basename "$f" .md)
  if echo "$basename" | grep -qE '[A-Z_ ]'; then
    echo "FAIL: $f — use kebab-case (lowercase, hyphens). Got: $basename"
    FAIL=1
  fi
done

# === No empty files ===
for f in $(find protocols/ muscles/ skills/ templates/ -name "*.md" -type f 2>/dev/null); do
  lines=$(wc -l < "$f")
  if [ "$lines" -lt 5 ]; then
    echo "FAIL: $f — file is too short ($lines lines). Minimum useful content required."
    FAIL=1
  fi
done

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Format check failed. See CONTRIBUTING.md for requirements."
  exit 1
fi

echo "✓ Format check passed"
