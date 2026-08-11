#!/usr/bin/env bash
# Scan for prompt injection techniques in community submissions.
# Community assets are loaded into agent context — they must not contain
# hidden instructions, system overrides, or manipulation patterns.
set -uo pipefail

FAIL=0

# 🔴 SCAN DIRS AND TYPES MUST TRACK THE WORKFLOW'S `paths:` FILTER.
# Until 2026-08-11 this enumerated *.md across five dirs, while pr-review.yml also
# fired on `scripts/**` — which holds 10 .sh + 1 .mjs. So every script on the hub
# triggered CI and was then scanned by NOTHING: the workflow said it ran, this said
# "✓ No files to scan", and both were telling the truth. `extensions/**` was in
# neither list. The gated types were all inert markdown; the types that EXECUTE were
# ungated. Protection was inversely proportional to risk.
SCAN_DIRS="protocols/ muscles/ skills/ templates/ automations/ scripts/ extensions/"
FILES=$(find $SCAN_DIRS \
  \( -name "*.md" -o -name "*.sh" -o -name "*.bash" -o -name "*.mjs" -o -name "*.js" \
     -o -name "*.ts" -o -name "*.py" \) -type f 2>/dev/null)

# 🔴 An empty list is NOT a pass. This used to `exit 0` with a ✓, so a broken find,
# a renamed dir, or a bad glob produced a green check that inspected zero files —
# indistinguishable from a clean scan. If none of the scan dirs exist we are not in
# the repo root and the caller must know; if they exist but hold nothing, say so
# loudly rather than approvingly.
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

# === Hidden HTML/CSS (invisible text) ===
if grep -rnEi '(display:\s*none|visibility:\s*hidden|font-size:\s*0|position:\s*absolute.*left:\s*-9999|opacity:\s*0[^.]|class="hidden")' $FILES; then
  echo "FAIL: Hidden content detected — possible invisible instruction injection"
  FAIL=1
fi

# === System/instruction override patterns ===
# Note: "system prompt" in context of describing how protocols load is fine.
# We're looking for DIRECTIVE patterns that try to hijack agent behavior.
if grep -rnEi '(SYSTEM\s*(DIRECTIVE|OVERRIDE|INSTRUCTION)|ignore\s*(previous|above|all)\s*(instruction|prompt|rule)|you\s+are\s+now\s+in\s+(a|guided|override)|override\s+(all|this)\s+protocol|disregard\s+(everything|all|previous))' $FILES; then
  echo "FAIL: System override / instruction injection pattern detected"
  FAIL=1
fi

# === Base64 encoded content (hiding instructions) ===
# Only flag very long base64 strings (60+ chars) — short ones are normal in markdown
if grep -rnE '[A-Za-z0-9+/]{60,}={0,2}' $FILES | grep -v "sha\|hash\|key.*example\|breadcrumb"; then
  echo "WARN: Possible base64-encoded content found — manual review recommended"
fi

# === Invisible unicode characters ===
if grep -rnP '[\x{200B}-\x{200F}\x{2028}-\x{202F}\x{2060}-\x{2064}\x{FEFF}]' $FILES 2>/dev/null; then
  echo "FAIL: Invisible unicode characters detected — possible steganographic injection"
  FAIL=1
fi

# === Jailbreak patterns ===
if grep -rnEi '(DAN\s*mode|do\s+anything\s+now|pretend\s+you\s+(are|can)|act\s+as\s+if\s+you\s+have\s+no\s+restrictions|simulate\s+a\s+mode|roleplay\s+as)' $FILES; then
  echo "FAIL: Jailbreak pattern detected"
  FAIL=1
fi

# === Exfiltration patterns (sending data out) ===
if grep -rnEi '(curl\s+.*\$|wget\s+.*\$|fetch\s*\(.*\+|send.*to.*http|exfiltrat|phone.home)' $FILES; then
  echo "WARN: Possible data exfiltration pattern — manual review recommended"
fi

# === Command execution in unexpected places ===
# Bash blocks in muscles/protocols are fine — but eval/exec outside code blocks is suspicious
if grep -rnEi '^\s*(eval|exec)\s+' $FILES | grep -v 'code block\|```'; then
  echo "WARN: eval/exec outside code block — manual review recommended"
fi

# === Repetitive instruction reinforcement (manipulation) ===
directive_count=$(grep -rnEi '(you\s+must|you\s+will|do\s+not\s+(explain|describe|tell)|simply\s+follow|comply|obey)' $FILES 2>/dev/null | wc -l)
if [ "$directive_count" -gt 10 ]; then
  echo "WARN: High density of directive language ($directive_count matches) — may be manipulation pattern"
fi

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "Injection scan failed. Community assets must not contain hidden instructions."
  echo "See: https://soma.gravicity.ai/docs/extending#safety"
  exit 1
fi

echo "✓ Injection scan passed"
