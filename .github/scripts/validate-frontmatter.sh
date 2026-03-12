#!/usr/bin/env bash
# Validate YAML frontmatter on all community content files.
# Synced with scripts/validate-frontmatter.sh schema — CI version.
set -euo pipefail

FAIL=0

check_field() {
  local file="$1" field="$2"
  if ! head -40 "$file" | grep -q "^${field}:"; then
    echo "FAIL: $file — missing required field: $field"
    FAIL=1
  fi
}

validate_value() {
  local file="$1" field="$2" value="$3"
  shift 3
  local valid="$*"
  if [ -n "$value" ] && ! echo "$valid" | grep -qw "$value"; then
    echo "FAIL: $file — invalid ${field}: '${value}' (valid: ${valid})"
    FAIL=1
  fi
}

get_field() {
  local file="$1" field="$2"
  awk -v f="$field" '/^---$/{c++;next} c==1 && $0 ~ "^"f":"{gsub("^"f":[[:space:]]*", ""); print; exit} c>=2{exit}' "$file"
}

VALID_STATUSES="draft active stable dormant archived deprecated"
VALID_TIERS="core official community pro"
VALID_HEAT="cold warm hot"

# === Common fields for all .md content ===
for f in protocols/*.md muscles/*.md automations/*.md; do
  [ -f "$f" ] || continue

  # Must have frontmatter
  if ! head -1 "$f" | grep -q "^---"; then
    echo "FAIL: $f — no YAML frontmatter"
    FAIL=1
    continue
  fi

  # Required fields
  for field in type name status version author license created updated tier; do
    check_field "$f" "$field"
  done

  # Validate enum values
  validate_value "$f" "status" "$(get_field "$f" "status")" $VALID_STATUSES
  validate_value "$f" "tier" "$(get_field "$f" "tier")" $VALID_TIERS
  validate_value "$f" "heat-default" "$(get_field "$f" "heat-default")" $VALID_HEAT
done

# === Protocol-specific ===
for f in protocols/*.md; do
  [ -f "$f" ] || continue
  check_field "$f" "heat-default"
  check_field "$f" "breadcrumb"
  check_field "$f" "applies-to"
  check_field "$f" "tags"
done

# === Muscle-specific ===
for f in muscles/*.md; do
  [ -f "$f" ] || continue
  check_field "$f" "topic"
  check_field "$f" "keywords"
  check_field "$f" "heat-default"
  check_field "$f" "breadcrumb"

  # Heat must be 0 in community (users control their own)
  heat=$(get_field "$f" "heat")
  if [ -n "$heat" ] && [ "$heat" != "0" ]; then
    echo "FAIL: $f — heat must be 0 in community repo (found: $heat)"
    FAIL=1
  fi

  # Loads must be 0 in community
  loads=$(get_field "$f" "loads")
  if [ -n "$loads" ] && [ "$loads" != "0" ]; then
    echo "FAIL: $f — loads must be 0 in community repo (found: $loads)"
    FAIL=1
  fi
done

# === Automation-specific ===
for f in automations/*.md; do
  [ -f "$f" ] || continue
  check_field "$f" "breadcrumb"
  check_field "$f" "topic"
done

# === Skills ===
for d in skills/*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}SKILL.md" ]; then
    echo "FAIL: $d — missing SKILL.md"
    FAIL=1
  fi
done

# === Templates ===
for d in templates/*/; do
  [ -d "$d" ] || continue
  if [ ! -f "${d}README.md" ]; then
    echo "FAIL: $d — missing README.md"
    FAIL=1
  fi
  if [ -f "${d}template.json" ]; then
    # Validate tier in template.json
    tier=$(grep '"tier"' "${d}template.json" 2>/dev/null | head -1 | sed 's/.*"tier"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    if [ -n "$tier" ]; then
      validate_value "${d}template.json" "tier" "$tier" $VALID_TIERS
    fi
  fi
done

# === File naming: kebab-case ===
for f in protocols/*.md muscles/*.md automations/*.md; do
  [ -f "$f" ] || continue
  basename=$(basename "$f" .md)
  if echo "$basename" | grep -qE '[A-Z_ ]'; then
    echo "FAIL: $f — use kebab-case (lowercase, hyphens). Got: $basename"
    FAIL=1
  fi
done

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Frontmatter validation failed. See FRONTMATTER.md for format requirements."
  exit 1
fi

echo "✓ Frontmatter validation passed"
