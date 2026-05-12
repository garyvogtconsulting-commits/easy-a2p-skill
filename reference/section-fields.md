# GHL Trust Center Section Fields

The 9 sections of a GHL Trust Center A2P 10DLC submission, mapped to the
field names the `/api/validate` endpoint expects.

## The canonical sections

| User-friendly name | API field name | What it is |
|---|---|---|
| Brand Registration | `Brand Registration` | Legal entity name + address + EIN. The IRS-verified part. |
| Campaign Description | `Campaign Description` | The "Use Case Description" field — what the messaging program does. |
| Sample Message 1 | `Sample Message 1` | First example SMS the campaign sends. Required for all use cases. |
| Sample Message 2 | `Sample Message 2` | Second example. Required for Mixed and Marketing campaigns. |
| Marketing Opt-In Checkbox | `Marketing Opt-In Checkbox` | Checkbox label/disclosure on the opt-in form for promotional messages. |
| Non-Marketing Opt-In Checkbox | `Non-Marketing Opt-In Checkbox` | Checkbox label/disclosure for transactional/account messages. |
| Opt-In Confirmation | `Opt-In Confirmation` | The welcome SMS the user receives after opting in. Max 320 chars. |
| Opt-In Flow Description | `Opt-In Flow Description` | Description of HOW users opt in — the field labeled "How do Contacts Opt-In to Messages?" in Trust Center. |
| Privacy Policy | `Privacy Policy` | The SMS section of the user's Privacy Policy. |
| Terms of Service | `Terms of Service` | The SMS section of the user's Terms of Service. |

## API request shape

The `validate` script expects a JSON object where keys are section field
names and values are the user's pasted copy. You don't need to include
every section — only the ones the user wants to validate.

```json
{
  "Brand Registration": "Acme Holdings LLC, 1234 Main St, Sacramento CA 95662, EIN 85-0891452, https://acmesalon.com, beauty",
  "Sample Message 1": "Hi Sarah, Acme Salon here — your appointment is confirmed for Thursday at 2:00 PM. Reply STOP to unsubscribe.",
  "Sample Message 2": "Hi Marcus, Acme Salon is offering 20% off color services through Friday. Book at acmesalon.com. Reply STOP to opt-out."
}
```

## Mapping ambiguous user input

Users often paste copy without saying which section it belongs to. Use these
heuristics:

- Contains "I consent to receive marketing" or "promotional" → Marketing Opt-In Checkbox
- Contains "I consent to receive non-marketing" or "transactional" → Non-Marketing Opt-In Checkbox
- Starts with "Hi [Name]" or has a phone-style brand reference + STOP → Sample Message
- Contains "Subscribed" or "You're opted in" + STOP and HELP → Opt-In Confirmation
- Describes how customers signed up (form, QR, verbal, etc.) → Opt-In Flow Description
- Contains "uses SMS messaging to" + use case description → Campaign Description
- Contains "non-sharing" clause or "Information We Collect" → Privacy Policy
- Contains numbered clauses (1. Program: ... 2. Opt-Out: ...) → Terms of Service

If the heuristic is ambiguous, ask the user one question to confirm which
section they're submitting before calling the API.
