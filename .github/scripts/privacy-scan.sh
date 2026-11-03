#!/usr/bin/env bash
# Scan for private/user-specific content that shouldn't be in community assets.
# Community protocols and muscles must be GENERIC — no personal data,
# no hardcoded paths, no secrets, no user-specific references.
set -uo pipefail

FAIL=0
# 🔴 Dirs + types must track pr-review.yml's `paths:`. See injection-scan.sh for the
# full note: `scripts/**` fired CI while both scanners enumerated *.md only, so every
# .sh on the hub was scanned by nothing. A hardcoded path secret leaks the same way
# from a script as from a protocol — more easily, since scripts hold real commands.
SCAN_DIRS="protocols/ muscles/ skills/ templates/ automations/ scripts/ extensions/ .github/"
# Exclude files that teach about privacy patterns (they contain examples by definition)
FILES=$(find $SCAN_DIRS \
  \( -name "*.md" -o -name "*.sh" -o -name "*.bash" -o -name "*.mjs" -o -name "*.js" \
     -o -name "*.ts" -o -name "*.py" -o -name "*.yml" -o -name "*.yaml" \) -type f 2>/dev/null \
  | grep -vE "community-safe|\.github/scripts/privacy-scan\.sh")
# Two files are excluded, for the same reason: they hold the leak PATTERNS themselves, so they always
# match their own rules. community-safe.md teaches by example; privacy-scan.sh IS the detector. Every
# other file under .github/ is scanned — workflows are where an id or a path leaks into a public log.

# 🔴 An empty list is NOT a pass — it used to exit 0 with a ✓, so a broken find looked
# identical to a clean repo.
if [ -z "$FILES" ]; then
  present=0
  for d in $SCAN_DIRS; do [ -d "$d" ] && present=1; done
  if [ "$present" = "0" ]; then
    echo "FAIL: none of the scan dirs exist — run this from the repo root (cwd: $PWD)"
    exit 1
  fi
  echo "⚠ scan dirs exist but matched 0 files — check the -name filters before trusting this"
  exit 0
fi

echo "scanning $(echo "$FILES" | grep -c .) file(s) across: $SCAN_DIRS"

# === Email addresses ===
if grep -rnE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' $FILES | grep -v "^.*:.*author:" | grep -v "example\.com" | grep -v "you@" | grep -v "company\.com" | grep -v "@example" | grep -v "email>"; then
  echo "WARN: Found email addresses outside author field (see above)"
  FAIL=1
fi

# === Real private paths — FAIL ===
# These identify specific users/machines or private infrastructure.
# Documentation examples like '~/.soma/' or '~/projects/' are OK (users follow
# the pattern). Only block identifying specifics.
# 🔴 Matched by SHAPE, never by naming the author: a literal `/Users/<realname>` in this file would
#   put that username in the public repo — the exact thing the rule exists to prevent.
if grep -rnE '(~/Gravicity|/Users/[a-z][a-z0-9._-]*/|\$GRAVICITY|~/\.vault\b|VAULT_PATH=)' $FILES; then
  echo "FAIL: Private-path identifiers found (user/machine specific)"
  FAIL=1
fi

# === Session and child ids — FAIL ===
# A hub asset is read by strangers: `s01-abc123` in a protocol is provenance they cannot resolve, and
# in a preload it is a pointer into a memory they do not have. Ruled 2026-11-03 (Curtis): session ids
# are SCRUBBED from published content, never allowlisted. Synthetic placeholders (s01-abc123,
# s01-abcdef, child-cafe01 …) are how a doc TEACHES the shape, so they pass — the rule below drops a
# line only when nothing but a synthetic id remains in it.
if [ -n "$(printf '%s\n' "$FILES" | grep .)" ]; then
  idhits=$(printf '%s\n' "$FILES" | tr '\n' '\0' \
    | xargs -0 grep -HnE 's01-[0-9a-f]{6}|SX-[0-9]+|child-[0-9a-f]{6}' 2>/dev/null \
    | grep -vE '(s01|child)-(aaaaaa|abcdef|abc123|a1b2c3|fff[0-9]{3}|cafe[0-9]{2}|f0000[0-9])' || true)
  if [ -n "$idhits" ]; then
    printf '%s\n' "$idhits" | head -10 | sed 's/^/        /'
    echo "FAIL: Session/child ids found — scrub them, do not allowlist (a reader cannot resolve them)"
    FAIL=1
  fi
fi

# === Generic home references — WARN only ===
# ~/.soma/, ~/projects/, /home/user/, etc. are documentation patterns users
# are told to follow. Worth a visual review but not a release blocker.
if grep -rnE '(~/|/Users/|/home/|/root/)' $FILES > /tmp/.generic-paths 2>/dev/null; then
  hits=$(wc -l < /tmp/.generic-paths | tr -d ' ')
  if [ "$hits" -gt 0 ]; then
    echo "WARN: $hits lines reference generic home paths (documentation — verify not hardcoded)"
    head -5 /tmp/.generic-paths | sed 's/^/        /'
    [ "$hits" -gt 5 ] && echo "        ... ($hits total)"
  fi
  rm -f /tmp/.generic-paths
fi

# === API keys / tokens ===
if grep -rnEi '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{30,}|npm_[a-zA-Z0-9]{30,}|AKIA[A-Z0-9]{16})' $FILES; then
  echo "FAIL: Possible API key or token found"
  FAIL=1
fi

# === Secret/credential patterns ===
if grep -rnEi '(password|secret|token|credential|api.key)\s*[:=]\s*["\x27][^"\x27]{8,}' $FILES; then
  echo "FAIL: Possible hardcoded secret found"
  FAIL=1
fi

# === .env references with values ===
if grep -rnE '^\s*(export\s+)?[A-Z_]+="[^"]{8,}"' $FILES | grep -v "^.*:.*\`\`\`" | grep -v "^.*:.*#"; then
  echo "WARN: Possible .env-style variable assignment found"
  # Warn only — could be an example
fi

# === Private IP / internal URLs ===
if grep -rnE '(192\.168\.|10\.\d+\.\d+\.\d+|172\.(1[6-9]|2[0-9]|3[01])\.|localhost:\d{4,5})' $FILES | grep -v "example"; then
  echo "WARN: Private IP or localhost URL found"
fi

# === Specific org/user references that should be generic ===
# Allow meetsoma (that's the project) but flag other specific orgs
if grep -rnE '(curtismercier|gravicity\.ai|gravicity\.io)' $FILES | grep -v "author:" | grep -v "# "; then
  echo "WARN: Gravicity/Curtis-specific references found — ensure they're examples, not hardcoded"
fi

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Privacy scan failed. Community assets must not contain private data."
  echo "Private info belongs in: USER.md, .env, .soma/secrets/, project memory"
  exit 1
fi

echo "✓ Privacy scan passed"
