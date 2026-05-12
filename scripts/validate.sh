#!/usr/bin/env bash
# easy-a2p — validate
# Calls Easy A2P's /api/validate endpoint with user-pasted GHL Trust Center
# section copy. Returns structured findings as JSON.
#
# Required env: EASY_A2P_API_KEY
# Usage:
#   ./validate.sh '<JSON-encoded sections object>'
#
# Example:
#   ./validate.sh '{"Brand Registration":"Acme Holdings LLC...", "Sample Message 1":"Hi Sarah..."}'

set -euo pipefail

if [ -z "${EASY_A2P_API_KEY:-}" ]; then
  cat <<EOF >&2
Error: EASY_A2P_API_KEY is not set.

Sign up at https://easya2p.app to get your API key, then set it:
  export EASY_A2P_API_KEY=eaap_your_key_here

For persistence, add the line to your ~/.zshrc or ~/.bashrc.
EOF
  exit 2
fi

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 '<JSON-encoded sections object>'" >&2
  exit 1
fi

SECTIONS_JSON="$1"
ENDPOINT="${EASY_A2P_ENDPOINT:-https://app.easya2p.app}/api/validate"

REQUEST_BODY=$(cat <<EOF
{
  "_type": "validation",
  "model": "claude-sonnet-4-6",
  "max_tokens": 16000,
  "sections": ${SECTIONS_JSON}
}
EOF
)

curl --silent --show-error --fail-with-body \
  --max-time 300 \
  -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "X-Easy-A2P-API-Key: $EASY_A2P_API_KEY" \
  -d "$REQUEST_BODY"
