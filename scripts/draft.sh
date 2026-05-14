#!/usr/bin/env bash
# easy-a2p — draft
# Calls Easy A2P's /api/validate endpoint in generation mode to draft a
# complete A2P 10DLC submission packet from intake fields.
#
# Response shape (as of 2026-05-12): the raw HTTP response is printed to
# stdout. The Anthropic-style envelope is `{content:[{type:'text', text}]}`.
# Parse `.content[0].text` as JSON to get:
#   {
#     sections: [...],   // GHL Trust Center field cards (~19 sections)
#     usage:    {...},   // Anthropic token usage
#     aiMerged: boolean, // true = AI output overlaid on deterministic packet
#     mismatch: { detected: false }  // OR { detected: true, direction, useCase,
#                                     //      affectedSections, reason, refunded,
#                                     //      creditsRemaining }
#   }
# Each `section` has `label` and `text`. PP/ToS may also have `displayLabel`
# (prefer this for user-facing heading). Some sections also have
# `fieldList` / `warning` / `mixedNotice` / `infoNote` / `ghlGroup`.
# If `mismatch.detected`, the server has ALREADY refunded the 2 credits —
# surface the refund + mismatch.reason to the user before rendering sections.
# `aiMerged: false` means the model returned malformed JSON and only
# deterministic fallbacks are present for AI-owned sections.
#
# Required env: EASY_A2P_API_KEY
# Usage:
#   ./draft.sh '<JSON-encoded draftData object>'
#
# Required draftData fields:
#   legalName, industry, useCase, optInMethod
# Optional but recommended:
#   dbaName, hasEIN, einNumber, website, phone, email, optInUrl,
#   frequency (monthly volume), description, scenario1, scenario2,
#   includeUrls, includePhone, ageGated, infoCollected, dataSecurity
#
# Example:
#   ./draft.sh '{
#     "legalName":"Acme Holdings LLC",
#     "hasDBA":"yes",
#     "dbaName":"Acme Salon",
#     "industry":"beauty",
#     "useCase":"Low Volume Mixed",
#     "optInMethod":"Website Form",
#     "website":"https://acmesalon.com",
#     "optInUrl":"https://acmesalon.com/sms",
#     "phone":"+15551234567",
#     "email":"info@acmesalon.com",
#     "description":"Send appointment reminders and occasional offers"
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
  echo "Usage: $0 '<JSON-encoded draftData object>'" >&2
  exit 1
fi

DRAFT_DATA="$1"
ENDPOINT="${EASY_A2P_ENDPOINT:-https://app.easya2p.app}/api/validate"

REQUEST_BODY=$(cat <<EOF
{
  "_type": "generation",
  "model": "claude-sonnet-4-6",
  "max_tokens": 4000,
  "draftData": ${DRAFT_DATA}
}
EOF
)

# Capture headers + body separately so we can surface the
# X-Credits-Remaining header to the user without polluting the JSON
# body that downstream consumers parse.
HEADERS_FILE=$(mktemp)
BODY_FILE=$(mktemp)
trap 'rm -f "$HEADERS_FILE" "$BODY_FILE"' EXIT

HTTP_CODE=$(curl --silent --show-error \
  --max-time 300 \
  -D "$HEADERS_FILE" \
  -o "$BODY_FILE" \
  -w "%{http_code}" \
  -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "X-Easy-A2P-API-Key: $EASY_A2P_API_KEY" \
  -d "$REQUEST_BODY" || echo "0")

# Surface credits-remaining to stderr (visible to user, doesn't break body parsing)
CREDITS=$(awk -F': *' 'tolower($1) == "x-credits-remaining" { gsub(/\r/, "", $2); print $2; exit }' "$HEADERS_FILE" 2>/dev/null || true)
if [ -n "$CREDITS" ]; then
  echo "[easy-a2p] Credits remaining: $CREDITS" >&2
fi

# Body goes to stdout (unchanged — backward compatible with existing consumers)
cat "$BODY_FILE"

# Exit non-zero on HTTP error so callers can detect failure
if [ "$HTTP_CODE" -ge 400 ] || [ "$HTTP_CODE" = "0" ]; then
  exit 22
fi
