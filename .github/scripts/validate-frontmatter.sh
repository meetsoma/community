#!/usr/bin/env bash
# Validate YAML frontmatter on all community files
set -euo pipefail

FAIL=0

check_field() {
  local file="$1" field="$2"
  if ! head -40 "$file" | grep -q "^${field}:"; then
    echo "FAIL: $file — missing required field: $field"
    FAIL=1
  fi
}

for f in protocols/*.md muscles/*.md; do
  [ -f "$f" ] || continue
  
  # Must have frontmatter
  if ! head -1 "$f" | grep -q "^---"; then
    echo "FAIL: $f — no YAML frontmatter"
    FAIL=1
    continue
  fi

  # Common required fields
  check_field "$f" "type"
  check_field "$f" "status"
  check_field "$f" "author"
  check_field "$f" "license"
  check_field "$f" "version"
done

# Protocol-specific
for f in protocols/*.md; do
  [ -f "$f" ] || continue
  check_field "$f" "name"
  check_field "$f" "heat-default"
  check_field "$f" "breadcrumb"
done

# Muscle-specific
for f in muscles/*.md; do
  [ -f "$f" ] || continue
  check_field "$f" "topic"
  check_field "$f" "keywords"
  
  # Heat must be 0 in community (users control their own)
  heat=$(grep "^heat:" "$f" | head -1 | awk '{print $2}')
  if [ -n "$heat" ] && [ "$heat" != "0" ]; then
    echo "FAIL: $f — heat must be 0 in community repo (found: $heat)"
    FAIL=1
  fi
done

# Skills
for d in skills/*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}SKILL.md" ]; then
    echo "FAIL: $d — missing SKILL.md"
    FAIL=1
  fi
done

# Templates
for d in templates/*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}README.md" ]; then
    echo "FAIL: $d — missing README.md"
    FAIL=1
  fi
done

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Frontmatter validation failed. See CONTRIBUTING.md for format requirements."
  exit 1
fi

echo "✓ Frontmatter validation passed"
