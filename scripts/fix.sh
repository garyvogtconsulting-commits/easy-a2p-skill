#!/usr/bin/env bash
# easy-a2p — fix
# Calls Easy A2P's /api/validate endpoint in `fix` mode. Takes existing
# (likely-failing) Trust Center copy plus optional rejection context, and
# returns paste-ready corrected copy that has been self-verified against
# the rule library.
#
# COST: 3 credits per call (vs 1 for validate, 1 for draft).
# The skill MUST confirm with the user before invoking this script.
#
# Required env: EASY_A2P_API_KEY
# Usage:
#   ./fix.sh '<JSON-encoded body>'
#
# Body shape:
#   {
#     "sections": { "<Section Name>": "<current text>", ... },
#     "rejectionContext": "<optional: reviewer's rejection reason>"
#   }
#
# Example:
#   ./fix.sh '{
#     "sections": {
#       "Sample Message 1": "Hi {{contact.first_name}}, your appointment is confirmed. Reply STOP."
#     },
#     "rejectionContext": "Curly-brace merge fields not allowed"
#   }'

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
  echo "Usage: $0 '<JSON-encoded body>'" >&2
  exit 1
fi

BODY_JSON="$1"
ENDPOINT="${EASY_A2P_ENDPOINT:-https://app.easya2p.app}/api/validate"

# Inject _type and model defaults into the user-supplied body. We use jq
# when available for safety; fall back to raw string concat if not.
if command -v jq >/dev/null 2>&1; then
  REQUEST_BODY=$(printf '%s' "$BODY_JSON" | jq '. + {"_type":"fix","model":"claude-sonnet-4-6","max_tokens":16000}')
else
  # Body must be a JSON object opening with `{`. Strip leading `{` and prepend
  # our fields so this works without a JSON parser.
  TRIMMED=$(printf '%s' "$BODY_JSON" | sed -e 's/^[[:space:]]*{//')
  REQUEST_BODY="{\"_type\":\"fix\",\"model\":\"claude-sonnet-4-6\",\"max_tokens\":16000,${TRIMMED}"
fi

curl --silent --show-error --fail-with-body \
  --max-time 300 \
  -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "X-Easy-A2P-API-Key: $EASY_A2P_API_KEY" \
  -d "$REQUEST_BODY"
