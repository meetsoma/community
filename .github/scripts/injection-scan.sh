#!/usr/bin/env bash
# Scan for prompt injection techniques in community submissions.
# Community assets are loaded into agent context — they must not contain
# hidden instructions, system overrides, or manipulation patterns.
set -euo pipefail

FAIL=0
FILES=$(find protocols/ muscles/ skills/ templates/ -name "*.md" -type f 2>/dev/null)

if [ -z "$FILES" ]; then
  echo "✓ No files to scan"
  exit 0
fi

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
