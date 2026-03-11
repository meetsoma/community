#!/usr/bin/env bash
# tier-guard.sh — Ensure PR author is authorized for claimed tiers.
#
# Reads MAINTAINERS.json to resolve author → role → allowed_tiers.
# Checks every changed .md and template.json for tier claims.
# Unknown authors default to "contributor" (community tier only).
set -euo pipefail

FAIL=0
MAINTAINERS="MAINTAINERS.json"

if [ ! -f "$MAINTAINERS" ]; then
  echo "FAIL: MAINTAINERS.json not found"
  exit 1
fi

# Resolve author from environment (GitHub Actions sets GITHUB_ACTOR)
AUTHOR="${GITHUB_ACTOR:-unknown}"

# Look up role
ROLE=$(jq -r --arg a "$AUTHOR" '.members[$a].role // .defaults.role' "$MAINTAINERS")

# Get allowed tiers for this role
ALLOWED_TIERS=$(jq -r --arg r "$ROLE" '.roles[$r].allowed_tiers // [] | .[]' "$MAINTAINERS")

echo "Author: $AUTHOR"
echo "Role: $ROLE"
echo "Allowed tiers: $(echo $ALLOWED_TIERS | tr '\n' ', ')"
echo ""

# Extract tier from YAML frontmatter
get_tier_md() {
  local file="$1"
  awk '/^---$/{c++;next} c==1 && /^tier:/{gsub(/^tier:[[:space:]]*/, ""); print; exit} c>=2{exit}' "$file"
}

# Extract tier from template.json
get_tier_json() {
  local file="$1"
  jq -r '.tier // empty' "$file" 2>/dev/null
}

# Get changed files (CI: compare against base branch; local: all content files)
if [ -n "${GITHUB_BASE_REF:-}" ]; then
  CHANGED=$(git diff --name-only "origin/${GITHUB_BASE_REF}...HEAD" -- '*.md' '**/template.json' 2>/dev/null || true)
else
  # Fallback: check all content files
  CHANGED=$(find protocols/ muscles/ skills/ templates/ -type f \( -name '*.md' -o -name 'template.json' \) 2>/dev/null || true)
fi

if [ -z "$CHANGED" ]; then
  echo "✓ No content files changed"
  exit 0
fi

CHECKED=0
for file in $CHANGED; do
  [ -f "$file" ] || continue
  
  # Skip non-content files
  case "$file" in
    CONTRIBUTING.md|AGENTS.md|README.md|FRONTMATTER.md) continue ;;
    .github/*) continue ;;
  esac

  TIER=""
  if [[ "$file" == *.md ]]; then
    TIER=$(get_tier_md "$file")
  elif [[ "$file" == *template.json ]]; then
    TIER=$(get_tier_json "$file")
  fi

  # Default to community if tier is missing
  if [ -z "$TIER" ]; then
    TIER="community"
  fi

  CHECKED=$((CHECKED + 1))

  # Check if tier is in allowed list
  if echo "$ALLOWED_TIERS" | grep -qw "$TIER"; then
    echo "✓ $file — tier: $TIER (authorized)"
  else
    echo "FAIL: $file — tier: $TIER (not authorized for role: $ROLE)"
    echo "  Allowed tiers: $(echo $ALLOWED_TIERS | tr '\n' ', ')"
    FAIL=1
  fi
done

echo ""
echo "Checked $CHECKED files"

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Tier guard failed. You cannot claim a tier above your role."
  echo "Community contributors may only use tier: community."
  exit 1
fi

echo "✓ Tier guard passed"
