#!/usr/bin/env bash
# attribution-check.sh — Verify author fields match GitHub identity.
#
# Rules:
#   1. Known members: author MUST match their display_name in MAINTAINERS.json
#   2. Unknown contributors: author must NOT claim a known member's display_name
#   3. Missing author: warn (not fail) — suggest adding it
set -euo pipefail

FAIL=0
WARN=0
MAINTAINERS="MAINTAINERS.json"

if [ ! -f "$MAINTAINERS" ]; then
  echo "FAIL: MAINTAINERS.json not found"
  exit 1
fi

AUTHOR="${GITHUB_ACTOR:-unknown}"

# Get this author's registered display_name (empty if not in MAINTAINERS)
DISPLAY_NAME=$(jq -r --arg a "$AUTHOR" '.members[$a].display_name // empty' "$MAINTAINERS")

# Build list of all known display names for impersonation check
KNOWN_NAMES=$(jq -r '.members | to_entries[] | .value.display_name // empty' "$MAINTAINERS")

echo "GitHub actor: $AUTHOR"
if [ -n "$DISPLAY_NAME" ]; then
  echo "Registered name: $DISPLAY_NAME"
else
  echo "Registered name: (not registered — contributor)"
fi
echo ""

# Extract author from YAML frontmatter
get_author() {
  local file="$1"
  awk '/^---$/{c++;next} c==1 && /^author:/{gsub(/^author:[[:space:]]*/, ""); gsub(/^"/, ""); gsub(/"$/, ""); print; exit} c>=2{exit}' "$file"
}

# Get changed files
if [ -n "${GITHUB_BASE_REF:-}" ]; then
  CHANGED=$(git diff --name-only "origin/${GITHUB_BASE_REF}...HEAD" -- '*.md' 2>/dev/null || true)
else
  CHANGED=$(find protocols/ muscles/ skills/ templates/ -name '*.md' -type f 2>/dev/null || true)
fi

if [ -z "$CHANGED" ]; then
  echo "✓ No content files changed"
  exit 0
fi

CHECKED=0
for file in $CHANGED; do
  [ -f "$file" ] || continue
  
  case "$file" in
    CONTRIBUTING.md|AGENTS.md|README.md|FRONTMATTER.md) continue ;;
    .github/*) continue ;;
  esac

  FILE_AUTHOR=$(get_author "$file")
  CHECKED=$((CHECKED + 1))

  # Case 1: No author field
  if [ -z "$FILE_AUTHOR" ]; then
    echo "WARN: $file — no author field. Consider adding: author: ${DISPLAY_NAME:-$AUTHOR}"
    WARN=$((WARN + 1))
    continue
  fi

  # Case 2: Known member — author must match display_name or org identity
  if [ -n "$DISPLAY_NAME" ]; then
    # Get member's role to check if they can submit as org
    ROLE=$(jq -r --arg a "$AUTHOR" '.members[$a].role // "contributor"' "$MAINTAINERS")
    # Owners and maintainers can submit as "meetsoma" (org identity)
    if [ "$FILE_AUTHOR" = "$DISPLAY_NAME" ]; then
      echo "✓ $file — author: $FILE_AUTHOR (matches registered name)"
    elif [ "$FILE_AUTHOR" = "meetsoma" ] && { [ "$ROLE" = "owner" ] || [ "$ROLE" = "maintainer" ]; }; then
      echo "✓ $file — author: meetsoma (org identity, permitted for $ROLE)"
    else
      echo "FAIL: $file — author: '$FILE_AUTHOR' does not match registered name: '$DISPLAY_NAME'"
      echo "  Registered members must use their display_name or 'meetsoma' (owners/maintainers only)"
      FAIL=1
    fi
    continue
  fi

  # Case 3: Unknown contributor — must not impersonate known members
  IMPERSONATION=0
  while IFS= read -r known_name; do
    [ -z "$known_name" ] && continue
    if [ "$FILE_AUTHOR" = "$known_name" ]; then
      echo "FAIL: $file — author: '$FILE_AUTHOR' matches a registered member's name"
      echo "  Only the registered GitHub user may use this display name"
      IMPERSONATION=1
      FAIL=1
      break
    fi
  done <<< "$KNOWN_NAMES"

  if [ "$IMPERSONATION" -eq 0 ]; then
    echo "✓ $file — author: $FILE_AUTHOR (contributor, no conflict)"
  fi
done

echo ""
echo "Checked $CHECKED files ($WARN warnings)"

# ---------------------------------------------------------------------------
# Fork lineage protection — forked-from cannot be removed once set
# ---------------------------------------------------------------------------
if [ -n "${GITHUB_BASE_REF:-}" ]; then
  FORK_FAIL=0
  for file in $CHANGED; do
    [ -f "$file" ] || continue
    case "$file" in *.md) ;; *) continue ;; esac

    # Check if base version had forked-from
    BASE_HAS_FORK=$(git show "origin/${GITHUB_BASE_REF}:${file}" 2>/dev/null | grep -c "^forked-from:" || true)
    HEAD_HAS_FORK=$(grep -c "^forked-from:" "$file" 2>/dev/null || true)

    if [ "$BASE_HAS_FORK" -gt 0 ] && [ "$HEAD_HAS_FORK" -eq 0 ]; then
      echo "FAIL: $file — forked-from field was removed. Fork lineage is permanent."
      echo "  The forked-from field preserves attribution to the original author."
      echo "  You may update the content, but not remove the lineage."
      FORK_FAIL=1
      FAIL=1
    fi
  done

  if [ "$FORK_FAIL" -eq 0 ]; then
    echo "✓ Fork lineage intact"
  fi
fi

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Attribution check failed. See CONTRIBUTING.md for rules."
  exit 1
fi

echo "✓ Attribution check passed"
