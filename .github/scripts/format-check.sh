#!/usr/bin/env bash
# Check structural format requirements for community assets.
set -euo pipefail

FAIL=0

# === Protocols must have TL;DR section ===
for f in protocols/*.md; do
  [ -f "$f" ] || continue
  # scope:core protocols are documentation of coded behavior — different format
  is_core=$(head -20 "$f" | grep -c "^scope: core" || true)
  if [ "$is_core" -gt 0 ]; then
    # Core protocols need TL;DR but use "How It Works" instead of "When to Apply"
    if ! grep -q "^## TL;DR" "$f"; then
      echo "FAIL: $f — missing ## TL;DR section"
      FAIL=1
    fi
    # "How It Works" or "When to Apply" — either is fine for core
    if ! grep -qE "^## (How It Works|When to Apply|When This Fires)" "$f"; then
      echo "WARN: $f — core protocol missing ## How It Works section (recommended)"
    fi
  else
    # Behavioral protocols need both TL;DR and When to Apply
    if ! grep -q "^## TL;DR" "$f"; then
      echo "FAIL: $f — missing ## TL;DR section"
      FAIL=1
    fi
    if ! grep -qE "^## (When to Apply|When This Fires)" "$f"; then
      # Downgraded to WARN (s01-419457) — existing protocols predate this requirement.
      # Upgrade back to FAIL once content sweep lands (SX-477).
      echo "WARN: $f — missing ## When to Apply section (upgrading to FAIL after content sweep)"
    fi
    if ! grep -q "^## When NOT to Apply" "$f"; then
      echo "WARN: $f — missing ## When NOT to Apply section (recommended)"
    fi
  fi
done

# === Muscles must have ## TL;DR (unified AMPS format per frontmatter-standard) ===
# Digest markers (<!-- digest:start/end -->) were DEPRECATED in favor of ## TL;DR
# for warm-tier loading. All AMPS content (protocols, muscles, automations) now
# uses ## TL;DR. Community muscles: verified 17/17 migrated as of s01-419457.
for f in muscles/*.md; do
  [ -f "$f" ] || continue
  if ! grep -q "^## TL;DR" "$f"; then
    echo "FAIL: $f — missing ## TL;DR section (AMPS warm-tier load format)"
    FAIL=1
  fi
  # Legacy digest markers — WARN on presence so we know to migrate old files
  if grep -q "<!-- digest:" "$f"; then
    echo "WARN: $f — legacy digest markers present (deprecated; remove when convenient)"
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
