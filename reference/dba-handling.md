# DBA Handling — The 4-Placement Rule

When a business operates under a DBA different from the legal entity,
GoHighLevel's documentation supports a specific placement pattern.
Misapplying the pattern (e.g., DBA in samples but no declaration in
Campaign Description) is a common rejection cause.

Source of authority: GHL's "Understanding A2P Campaign Rejection Reasons
& Required Fixes" article — the relevant guidance:

> "If you have an EIN for your company but you want to use a different
> brand name for your messages, you can add this sentence 'We are doing
> DBA as [Business_Name]' in the Campaign Use Case. Make sure the rest
> of the submission, including the website, Privacy policy, Terms &
> Conditions, and the business name shown in opt-in form checkboxes,
> matches the declared [Legal Business Name] DBA [DBA Name]."

## The 4 placement rules

| Placement | What name to use |
|---|---|
| Brand Registration → Legal Business Name field | **Legal entity name only** (matches IRS CP 575 letter exactly) |
| Use Case Description (the "Campaign Use Case" field) | Legal name as the opener subject + the declarative sentence "We are doing business as [DBA Name]." |
| Sample messages, opt-in checkboxes, opt-in confirmation | **DBA** (the consumer-facing brand) |
| Privacy Policy / Terms of Service section headers | "[Legal Name] DBA [DBA Name]" — formal disclosure of both names |

Body references inside the Privacy Policy and Terms of Service can use the
DBA alone after the formal header — the user opted in to the DBA, so it's
natural to refer to that brand throughout.

## Worked example

Legal entity: `Acme Holdings LLC`
DBA: `Acme Salon`

**Brand Registration:**
> Legal Business Name: Acme Holdings LLC

**Use Case Description (Mixed campaign, 5 sentences):**
> Acme Holdings LLC uses SMS messaging to communicate with customers
> who have explicitly opted in. We are doing business as Acme Salon.
> Transactional messages may include appointment reminders, account
> updates, and service confirmations. Promotional messages may include
> special offers, sale announcements, and product updates. Consent is
> collected through compliant opt-in processes, and recipients may opt
> out at any time by replying STOP.

**Sample Message:**
> Hi Sarah, Acme Salon here — your appointment is confirmed for
> Thursday at 2:00 PM. Reply STOP to unsubscribe.

**Marketing Opt-In Checkbox:**
> I consent to receive marketing text messages about offers, sales,
> and product updates from Acme Salon at the phone number provided.
> Message frequency may vary. Message & data rates may apply.
> Text HELP for help, reply STOP to opt-out.

**Opt-In Confirmation:**
> Subscribed to Acme Salon SMS — transactional and promotional.
> Msg frequency varies. Msg & data rates may apply. Reply STOP to
> opt out, HELP for help.

**Privacy Policy section header:**
> Acme Holdings LLC DBA Acme Salon operates a text messaging program
> to send appointment reminders, account updates, and promotional
> offers to opted-in customers.

**Terms of Service section header:**
> 1. Program: Acme Holdings LLC DBA Acme Salon SMS Alerts —
> appointment reminders, service confirmations, and promotional offers.

## What goes wrong without the declaration

If the DBA appears in samples and checkboxes but the Campaign Description
doesn't include "We are doing business as [DBA Name].", TCR reviewers see
a brand mismatch:
- Brand Registration says "Acme Holdings LLC"
- Samples say "Acme Salon"
- No documented connection between them

Common rejection patterns this triggers:
- "Use case mismatch"
- "Inconsistent brand identification"
- "Sample messages don't match the declared use case"

The fix is always the same: add the declaration sentence to the Campaign
Description and resubmit. Per GHL Help Center, resubmissions are free —
but the time delay (1-3 days for Sole Prop, 3-15 days for Standard) is
what costs the user.

## Multi-brand under one EIN

GHL allows up to 10 brands per EIN. Multi-brand parent companies handle
separate A2P 10DLC programs by registering separate brands, each with the
same legal entity name and a different DBA:

- Brand 1: Legal "Acme Holdings LLC" / DBA "Acme Salon"
- Brand 2: Legal "Acme Holdings LLC" / DBA "Acme Spa"
- Brand 3: Legal "Acme Holdings LLC" / DBA "Acme Wellness"

Each is a separate Trust Center registration with its own Campaign
Description (each containing its own DBA declaration), its own samples,
its own opt-in flow. The legal name on the brand record is the same
across all three; the DBA differentiates them.

## Sole Proprietor with DBA

Sole Proprietors can also use the DBA pattern. The "legal name" for a
Sole Prop is the proprietor's actual personal name (e.g., "Sarah Mitchell")
or a state-registered DBA filed under the proprietor's name (e.g.,
"Sarah Mitchell Real Estate"). The same 4-placement rule applies — the
Brand Registration field uses the legal name, consumer-facing copy uses
whichever name the public knows, and the Campaign Description declares
the relationship if they differ.
