# STOP / HELP Canonical Phrasing

Different surfaces of an A2P 10DLC submission have different conventions
for STOP and HELP keyword references. Using the wrong phrasing for the
surface causes warnings or rejections.

## Opt-in checkbox text — strict canonical

Trust Center samples and the Easy A2P copy review system both expect:

```
Text HELP for help, reply STOP to opt-out.
```

Notes:
- "opt-out" with a hyphen, NOT "unsubscribe" or "cancel"
- "Text HELP for help" NOT "Reply HELP for help"
- The two clauses combined into one sentence saves character count and
  matches the Trust Center sample format

## Sample message text — flexible

GHL Trust Center sample messages use both "unsubscribe" and "opt-out"
interchangeably. Either passes review:

```
Reply STOP to unsubscribe.
Reply STOP to opt-out.
Reply STOP to cancel.   ← also accepted
```

In sample messages:
- HELP is NOT required (only STOP)
- Adding "Reply HELP for help" is technically harmless but eats character
  budget and isn't expected. Don't add it.

## Opt-In Confirmation Message — canonical with all 5 elements

The welcome SMS the user receives must include all five required elements:
business name, STOP keyword, HELP keyword, frequency disclosure, and
"Msg & data rates may apply".

Tightest canonical phrasing (fits a single 160-char SMS segment for
shorter brand names):

```
Subscribed to [Brand] SMS — [content type]. Msg frequency varies.
Msg & data rates may apply. Reply STOP to opt out, HELP for help.
```

Variants that also pass:
- "You're opted in to [Brand] SMS. Msg frequency varies. Msg & data rates may apply. Reply STOP to opt out, HELP for help."
- "[Brand] SMS for [content type] is confirmed. Msg frequency varies. Msg & data rates may apply. Reply STOP to opt out, HELP for help."

## Terms of Service — STOP must be unconditional

The STOP language in the SMS section of Terms of Service must be
universal — not scoped to one message type. The FCC's pending
"Revocation-All" rule (delayed to January 31, 2027) explicitly requires
that a single STOP halt all automated messages.

What passes:
```
Text STOP at any time to cancel. After texting STOP, you will receive
one confirmation that you have been unsubscribed and will receive no
further messages.
```

What fails:
```
Reply STOP to stop receiving promotional messages from us.
```
(Implies transactional messages continue. Already preferred against by
reviewers; will be a hard violation once Revocation-All takes effect.)

## When this comes up

Use this when:
- User is auditing or drafting opt-in checkbox text
- User is auditing the Opt-In Confirmation Message
- User is auditing the SMS section of Terms of Service
- User asks "do I need HELP in my sample messages?"
- User asks the difference between "opt-out" and "unsubscribe"
