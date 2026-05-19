---
name: easy-a2p
description: |
  Use whenever the user is preparing, reviewing, or troubleshooting a
  GoHighLevel A2P 10DLC SMS registration — including Brand Registration,
  Use Case Description, Sample Messages, Marketing/Non-Marketing Opt-In
  Checkboxes, Opt-In Confirmation Message, Opt-In Flow Description, Privacy
  Policy SMS section, or Terms of Service SMS section. Trigger when the user
  mentions GHL Trust Center, TCR rejection, A2P 10DLC compliance, Sole
  Proprietor brand registration, DBA handling in SMS registrations, or asks
  to review or draft compliant SMS submission copy. Use even if the user
  doesn't explicitly mention "Easy A2P" — if the work involves A2P 10DLC
  compliance for GoHighLevel, this skill is the right tool. Skip for:
  non-SMS work, non-GoHighLevel platforms, generic compliance reviews
  unrelated to A2P 10DLC, or messaging compliance for countries other than
  the US/Canada.
---

# Easy A2P — A2P 10DLC compliance for GoHighLevel

This skill is the official Claude Code interface to Easy A2P. It reviews
GHL Trust Center submission copy against The Campaign Registry's
documented rejection causes, and drafts compliant copy from intake fields.

## What this skill does

Three actions, priced by the work involved:

1. **Review existing copy** (`scripts/validate.sh`) — **1 credit**. Take any
   of the 9 GHL Trust Center sections the user already has and run them
   through Easy A2P's rule library. Returns structured findings with status
   (pass/warn/fail), the specific rule that fired, and why it matters.
   **Review is a grading action only — it does NOT return paste-ready
   rewrites.** If the user wants corrected copy, that's `fix` — and `fix`
   always runs *after* a Review, never before it (see below).

2. **Draft fresh copy** (`scripts/draft.sh`) — **2 credits**. Take intake
   fields (legal name, DBA, industry, use case, opt-in method, etc.) and
   generate a complete compliant submission packet: Use Case Description,
   two sample messages, opt-in checkboxes, opt-in confirmation, opt-in flow
   description, plus Privacy Policy and Terms of Service SMS sections.

3. **Fix existing copy** (`scripts/fix.sh`) — **3 credits**. Take failing or
   rejected copy and return paste-ready corrected copy that has been
   self-verified against the rule library. This is the rewrite/recovery
   path. The 3-credit cost reflects the generate-and-self-verify loop the
   backend runs internally — the output is intended to pass TCR review on
   submission.

All three hit the live `app.easya2p.app/api/validate` endpoint. The user
needs an Easy A2P account and credits — sign up at https://easya2p.app
(3 free credits, no card required).

## Fix is gated behind a Review (REQUIRED)

`fix` (3 credits) is NEVER a first action and is NEVER offered before the
user has run a Review. A Review is what tells the user — and the fix —
exactly what is wrong.

1. **Never offer `fix` until a Review has run this session.** Even if the
   user opens with "fix this copy", "rewrite this", or "give me a
   compliant version", do NOT jump to `fix`. Run the 1-credit Review
   first, present the findings, and only then offer the 3-credit fix.
2. **Never present a "Review or Fix — which do you want?" choice.** When
   the user pastes copy, the answer is always: run the Review. Fix is a
   follow-up the user opts into after seeing the findings.
3. **After the Review, offer the fix with the cost stated plainly:**

> "That's your 1-credit review. Want me to fix the failing sections? A
> fix costs 3 credits — it returns paste-ready corrected copy,
> self-verified against the rule library. Proceed?"

   Wait for an explicit "yes" before calling `scripts/fix.sh`.

Why: the Review is 1 credit and names precisely what fails. Spending 3
credits on a fix without that baseline is a worse deal for the user — and
the fix produces better copy when it has the Review's findings to work
from.

## Authentication

The skill needs an Easy A2P API key to call the backend. Two ways to
provide it:

1. **Paste it into chat** (easiest — works for everyone). The user pastes
   their key (`eaap_…`) and Claude exports it for the script call within
   the same session. No terminal commands required.
2. **Persistent env var** (recommended for repeat users). The key lives in
   `~/.zshrc` / `~/.bashrc` so every new shell has it. Suggest this only
   AFTER the user has confirmed it works in chat once.

The user can find their API key in Easy A2P by clicking their name in
the top right → **API Access**. New accounts get 3 free credits, no card
required (sign up at https://easya2p.app).

When the key is missing, ALWAYS offer the paste-in-chat path FIRST — it
keeps non-technical users in the conversation. Only mention the terminal
export as a "for next time" follow-up.

## When to invoke each action

**Use `review` (1 credit) when the user:**
- Pastes existing copy and asks "is this compliant?" or "will this pass?"
- Wants a grade only — they'll rewrite it themselves
- Wants to audit a Privacy Policy or Terms of Service
- Pastes copy and asks to "fix" it — a Review still runs first (see below)

After a review, present findings only. Do NOT compose a paste-ready
rewrite in your response. If the user wants the rewrite, surface the
3-credit `fix` option as a follow-up.

**Use `draft` (2 credits) when the user:**
- Is starting a new GHL A2P registration from scratch
- Has switched use cases and needs all sections regenerated
- Wants compliant templates for a specific industry or use case

**Use `fix` (3 credits) — but ONLY after a Review has run this session.**
`fix` is always a follow-up to a Review, never a standalone first action
(see "Fix is gated behind a Review" above). After the Review, it is the
right follow-up when the user:
- Has a TCR rejection email and wants the failing copy corrected
- Wants the reviewed copy rewritten / corrected / recovered
- Asks for a paste-ready "compliant version" of the reviewed copy

If the user asks for any of these *before* a Review has run, run the
Review first, then offer the fix.

**Always confirm the 3-credit cost before calling `fix.sh`** — and never
reach `fix.sh` without a completed Review this session. See "Fix is gated
behind a Review" above.

**For all three:** if the user has a DBA different from the legal entity,
the skill follows GHL's documented DBA-handling pattern automatically —
see `reference/dba-handling.md` for the placement rule.

## Operational logic

### Opening message (REQUIRED)

The very first message you send the user after this skill triggers MUST end
with the privacy reassurance below — verbatim. Place it as the LAST
paragraph of your opening message, after you've acknowledged the user's
intent and any clarifying question. This mirrors the trust copy on
easya2p.app and app.easya2p.app, so the experience is consistent across
the web app and the skill.

> **Your business data stays yours.** We don't save it. We don't sell
> it. We don't analyze it. The legal name, EIN, address, and description
> you share are sent once to our AI provider (Anthropic) to generate
> your compliance copy — then they're discarded. Easy A2P's servers
> don't keep a copy and don't log them. The only thing persisted is
> your email and your credit balance.

This block is required on the FIRST message of every new skill session.
Subsequent messages do NOT need to repeat it.

### Step-by-step

When the user invokes this skill:

1. **Check for `EASY_A2P_API_KEY`.** If missing, do NOT block the user
   upfront with terminal commands. For `draft`, run the full interview
   first — by Round 15 you'll already have all their answers, and the
   auth fallback message at that point offers paste-in-chat as the
   primary path. For `review` / `fix`, briefly ask: "Paste your Easy
   A2P API key (starts with `eaap_`) and I'll use it for this run, or
   sign up at https://easya2p.app if you don't have one yet."

2. **Identify the action.** Review, draft, or fix? Read the user's intent
   from context. If ambiguous, ask one clarifying question. If the user
   wants corrected copy, that does NOT go straight to `fix` — it begins
   with a Review (step 3), and `fix` (step 5) is offered only afterward.

3. **For `review` (1 credit):** Collect the section text from the user.
   Each of the 9 GHL Trust Center sections has its own field name — see
   `reference/section-fields.md` for the canonical names. Map the user's
   pasted copy to the right field, then call `scripts/validate.sh`.
   Present findings only — name the section, the rule that fired, why it
   matters. Do NOT include a paste-ready rewrite in the response;
   suggest `fix` as a follow-up if the user wants the corrected copy.

4. **For `draft` (2 credits):** Run the **conversational intake interview**
   below before calling `scripts/draft.sh`. This mirrors the web app's
   Draft Fresh Copy wizard at app.easya2p.app — same fields, same order,
   same validation, same scope-mismatch guards.

   **Interview rules:**
   - **NEVER echo internal variable names back to the user.** SKILL.md uses
     `Capture: fieldName` and similar phrasing as INSTRUCTIONS TO YOU about
     which `draftData` field to populate — these are not for the user. Do
     NOT write "Captured: optInMethod = 'Website Form'" or similar in the
     chat. Just acknowledge naturally ("Got it." / "Thanks." / "Noted.")
     and continue to the next round. Internal field names like `legalName`,
     `optInUrl`, `hasEIN`, `bizType`, `dataSecurity`, etc. should never
     appear in your messages to the user.
   - **One round per topic.** Use smart grouping where fields are tightly
     related (e.g., address as `street, city, state, zip` together; EIN
     status + number + age in one round when applicable). Otherwise,
     ask single questions. Aim for ~10-12 rounds for a typical user.
   - **Wait for an answer between rounds.** Do not pre-batch unrelated
     questions just to save tokens.
   - **Skip conditional fields silently** when prerequisites don't
     apply (no EIN → skip einNumber/einAge; no DBA → skip dbaName;
     opt-in method ≠ QR Code → skip qrLocation; Chat Widget → skip
     checkbox-related discussion since the widget auto-generates;
     2FA / Fraud / Security use cases → skip ageGate, those don't
     carry age-gated content).
   - **Auto-apply silent defaults:** `country = "United States"`,
     `region = ["USA & Canada"]`, `age18Confirmed = "yes"` (auto unless
     user picks an age-gated industry). Do NOT ask the user for these.
   - **State-default-confirm pattern** for `infoCollected` and
     `dataSecurity`: state the defaults, ask only if they want changes.
     Defaults: `infoCollected = ["Phone number", "Name (first and/or last)"]`;
     `dataSecurity = ["Encryption in transit (TLS/HTTPS for all data)",
     "Access controls (data limited to authorized personnel)",
     "Secure third-party processors (GoHighLevel, Twilio, Stripe)"]`.
   - **Enum fields:** present the exact options. Do not invent options.
   - **Mismatch detection** runs at TWO checkpoints (after the
     description round, and after the scenarios round). See "Scope
     mismatch guards" below.
   - **Compact end summary:** confirm the key fields only (brand name,
     use case, description, opt-in method, has-existing-legal-docs).
     Don't list every field. Wait for explicit "yes" / "go" / "confirm"
     before calling the API.

   **Bulk-dump and order-flexibility handling:**

   Some users will paste everything upfront — for example, a returning
   user re-running a draft after picking the wrong use case the first
   time will often paste back all the answers they already supplied.
   The skill should never force them to re-type fields they've already
   provided.

   - On the user's FIRST message after invoking `draft`, scan it for
     any `draftData` fields they've already supplied. Common things
     to extract: legal business name, DBA name, EIN status / number,
     industry, website, phone, email, address, use case, plain-English
     description, opt-in method, opt-in URL, scenarios, monthly volume.
   - **Mentally store everything they've provided.** Skip the round
     that asks for that field. Only ask for what's STILL MISSING.
   - **Confirm before skipping** if anything is ambiguous: "I saw you
     mentioned 'Acme Salon LLC' and 'Acme Salon' — should I treat
     'Acme Salon LLC' as the legal entity and 'Acme Salon' as the DBA?
     Reply 'yes' or correct me."
   - **Run mismatch checkpoints regardless** of how the data was
     collected. If the user bulk-dumped a Customer Care use case + a
     description mentioning promotional content, fire the Direction B
     hard block immediately — don't wait until you've collected
     "every" field. The check needs only `useCase` + `description`
     (and later, scenarios). Apply it as soon as both are present,
     regardless of which round they came from.
   - **Order flexibility:** the user may choose to discuss things in
     a different order than the round numbering (e.g., they want to
     pick the use case before giving you their business name). Honor
     it. The round numbers are a recommended sequence, not a forced
     one. By Round 15, you just need every required field collected
     and every mismatch checkpoint cleared.

   **Round-by-round interview:**

   **Round 1 — Legal business name**
   > "What's your legal business name? Please match your IRS CP 575
   > EIN Confirmation Letter EXACTLY — including punctuation, commas,
   > LLC, Inc., spacing. (Even minor differences are a confirmed TCR
   > rejection cause.)"

   **Round 2 — Business type + EIN status (grouped)**
   > "Two quick questions:
   > 1. Business type — pick one: LLC / Corporation (Inc.) / Sole Proprietor / Nonprofit / Partnership
   > 2. Do you have an EIN? (yes/no — if yes, share the EIN in XX-XXXXXXX format and whether it was issued more than 15 days ago)"
   >
   > Capture: `bizType`, `hasEIN`, optional `einNumber`, optional `einAge`.
   > If `hasEIN=no`: warn the user that for Sole Proprietor brands, the
   > legal business name CANNOT contain "LLC", "Inc.", "Corp", "Company",
   > "Co.", "Team", "Group", "Partners", "Enterprises", or "Holdings" —
   > TCR auto-rejects. If their `legalName` contains any of those, ask
   > them to use the proprietor's actual personal name instead.

   **Round 3 — DBA**
   > "Do you operate under a different brand name (DBA)?
   > Reply 'no', or share the DBA name."

   **Round 4 — Industry**
   > "What industry? Pick one:
   > • Dental
   > • Healthcare / Medical (non-dental)
   > • Beauty / Salon / Spa
   > • Fitness / Gym / Wellness
   > • Home Services (HVAC, Plumbing, etc.)
   > • Real Estate
   > • Professional Services
   > • Legal / Law Firm
   > • Accounting / Tax / Bookkeeping
   > • Insurance / Agencies
   > • Marketing / Advertising Agency
   > • Restaurant / Food Service
   > • Hospitality / Hotel / Travel
   > • Automotive / Auto Repair / Dealership
   > • Pet Services / Veterinary
   > • Financial Services / Lending
   > • Solar / Green Energy
   > • Technology / SaaS / Software
   > • E-Commerce / Retail
   > • Education / Training
   > • Nonprofit / Association
   > • Other"
   >
   > Cannabis, payday lending, debt collection, gambling, lead generation,
   > adult content, and MLM are TCR-forbidden — if the user picks one of
   > these, warn them their registration will be auto-rejected by carriers
   > and refuse to proceed with `draft.sh`. They cannot register A2P 10DLC
   > campaigns for these categories regardless of how the copy is written.

   **Round 5 — Contact + Address (grouped)**
   > "Now your business contact details:
   > - Website URL (must be live, no password gate, no 'coming soon')
   > - Business phone (E.164 preferred: +15551234567)
   > - Business email (business-domain like info@yourcompany.com is preferred over Gmail/Yahoo)
   > - Physical street address, city, state, ZIP (no PO Boxes — confirmed TCR rejection cause)"

   **Round 6 — Authorized Representative**
   > "Authorized Representative — full name and job title.
   > Example: 'Sarah Mitchell, Owner'"

   **CRITICAL — split the name before passing to draft.sh.** The server
   expects three separate fields, NOT a combined `authRepName` /
   `authRepTitle`. Parse the user's reply into:
   - `authRepFirstName` — first word of the name
   - `authRepLastName` — everything after the first word (handles middle
     names: "Gary Ross Vogt" → first="Gary", last="Ross Vogt")
   - `authRepJobTitle` — the title portion after the comma

   Example: input `"Sarah Mitchell, Owner"` →
   `{ authRepFirstName: "Sarah", authRepLastName: "Mitchell", authRepJobTitle: "Owner" }`.
   If you send `authRepName` / `authRepTitle` instead, the GHL Trust
   Center fields come back blank — confirmed broken in v1.0.0 testing.

   **Round 7 — Use case**
   > "Which campaign use case best matches what you'll send?
   > ⭐ Low Volume Mixed (Recommended) — for businesses sending both transactional + promotional
   > Appointment Reminders / Customer Care
   > Account Notifications
   > 2FA / One-Time Passwords
   > Delivery Notification
   > Higher Education
   > Fraud Alert Messaging
   > Marketing Offers & Promotions
   > Polling and Voting
   > Public Service Announcement
   > Security Alert"

   **Round 8 — Plain-English description**
   > "What kinds of messages do you send and to who do you send them?"

   That's the whole ask. Do NOT pad with explanation about templates,
   compliance, or AI restructuring — the web app doesn't, and the user
   doesn't need to know how the sausage is made.

   Do NOT show the user an example structure or coach them on
   compliance phrasing — the web app doesn't do this and the AI
   handles the structural pattern automatically. Asking the user to
   pre-format their description is cumbersome and pointless.

   → **MISMATCH CHECKPOINT 1** runs here. See "Scope mismatch guards" below.

   Note: Even if the description is short, contains a single combined
   sentence ("we send appointment reminders and promotional offers"),
   or otherwise reads as thin — DO NOT surface quality coaching to the
   user. The AI will restructure into the proper Mixed 4-5 sentence
   pattern with separate transactional and promotional sentences. The
   only blocking concern at this checkpoint is direction A/B/C
   mismatch per the regex check; everything else is the AI's job.

   **Round 9 — Monthly volume**
   > "Approximate monthly message volume across all your subscribers?
   > Examples: '500/month', '2,000–3,000/month', 'about 5000 messages'"

   **Round 10 — Opt-in method**
   > "How do contacts opt in to receive your SMS?
   > ⭐ GHL Chat Widget (Pre-Built) — Recommended by GHL
   > Website Form
   > Paper Form (in-person)
   > QR Code
   > Kiosk / Point of Sale
   > Facebook Lead Form
   > Verbal"

   - **GHL Chat Widget warning:** if selected, tell the user the widget
     MUST be the only SMS opt-in method on their website. SMS consent
     checkboxes on contact forms, lead forms, landing pages, or
     appointment booking forms must be removed or the campaign is
     rejected.
   - Note: "Keyword Opt-In" is no longer offered by GHL — do not present
     it as an option.

   **Round 11 — Opt-in URL (or evidence) + collateral fields (grouped)**

   This round always asks for a URL — but the URL type depends on the
   opt-in method picked in Round 10.

   - **For Website Form / Facebook Lead Form / Chat Widget:** ask for
     the **live opt-in URL** (must be publicly accessible, no password
     gate, returns 200).
   - **For QR Code:** ask TWO things — (a) `qrLocation` ("Where is the
     QR code displayed?" — examples: "in-store signage", "menu",
     "receipt", "business location"), AND (b) a **public URL pointing
     to a hosted image of the opt-in evidence** (the user uploads a
     photo/screenshot of their QR signage to Google Drive or Dropbox
     with "anyone with the link can view" sharing, then provides that
     public share URL).
   - **For Verbal / Paper Form / Kiosk:** ask for a **public URL
     pointing to hosted image/video evidence** of the opt-in process
     (paper form scan, kiosk screen photo, recording of verbal consent
     script). Same hosting pattern as QR Code.
   - **For all methods:** also ask the two PERMANENT TCR checkboxes:
     > "Two final questions for this step — these settings CANNOT be
     > changed after submission without re-registering:
     > - Will any of your messages contain URLs / links? (yes/no)
     > - Will any of your messages contain a phone number? (yes/no)"

   Capture: `optInUrl` (always — either the live opt-in URL OR the
   hosted-evidence URL), `qrLocation` (only if QR Code), `includeUrls`,
   `includePhone`.

   **Round 12 — Existing legal documents**

   Mirror the web wizard's dropdown order EXACTLY (do not reorder for
   "logic" — match the live UI so screenshots and skill outputs stay
   consistent):

   > "Do you already have a Privacy Policy and Terms of Service published on your website?
   > 1. No — I need both
   > 2. Yes — both
   > 3. Yes — Privacy Policy only
   > 4. Yes — Terms of Service only"

   - If 2 or 3: ask for the existing Privacy Policy URL.
   - If 2 or 4: ask for the existing Terms of Service URL.
   - If 1: defaults to `{website}/privacy` and `{website}/terms`; user
     can override the planned publish path.

   Capture: `hasExistingLegalDocs` (one of `neither | both | pp_only | tos_only`),
   `ppUrl` (always — defaults to `{website}/privacy`),
   `tosUrl` (always — defaults to `{website}/terms`).

   **Round 13 — Sample message scenarios**
   > "Describe two real message scenarios in plain English. The system
   > will generate fully compliant sample messages from your descriptions.
   >
   > Scenario 1: ?
   > Scenario 2: ?
   >
   > Don't worry about compliance language — focus on the actual content
   > and context your customers will receive. Use real examples that
   > reflect your real business."

   This matches how the web app asks for scenarios — open-ended, no
   prescription about content type or ordering. The AI generator handles
   ordering automatically (for Mixed campaigns, the AI assigns the more
   promotional scenario to Sample Message 1 and the more transactional
   one to Sample Message 2 per its MIXED-CAMPAIGN SAMPLE ORDER rule).

   → **MISMATCH CHECKPOINT 2** runs here. See "Scope mismatch guards" below.

   **Round 14 — Settings (state-default-confirm pattern)**
   > "Almost done — a few quick settings:
   > - Age-gated content? (alcohol, tobacco, cannabis, firearms, gambling, adult) — defaulting to NO unless you say otherwise
   > - Sending to Canadian phone numbers? — defaulting to NO unless you say otherwise
   > - Information collected at opt-in: defaults to **Phone number** + **Name**. Additional options if you want to add any: Email address, ZIP code or address, Date of birth, Other.
   > - Data security measures: defaults to **Encryption in transit (TLS/HTTPS)** + **Access controls** + **Secure third-party processors (GHL, Twilio, Stripe)**.
   >
   > Reply 'defaults' to accept all four. Otherwise tell me what's different."

   Capture: `ageGate` (default `no`), `canada` (default `no`),
   `infoCollected` (use defaults unless user customizes),
   `dataSecurity` (use defaults unless user customizes).

   **Round 15 — Compact confirmation**

   Build a short summary using the collected fields in natural language —
   not literal template syntax. Show the legal brand name and append
   "(DBA: <dbaName>)" only when the user provided a DBA. Truncate the
   description to its first ~80 characters with an ellipsis. Show the
   opt-in method together with the opt-in / evidence URL. Show the
   resolved `hasExistingLegalDocs` choice in plain English.

   Do NOT surface a "heads up" paragraph about description quality or
   sample order — the user has already responded to those concerns
   earlier in the interview (or they didn't apply). The AI handles
   structure and ordering automatically. Round 15 is a clean
   confirmation, not another teaching moment.

   Example output (for a typical Mixed campaign with DBA, no override):
   > "Here is a summary of your inputs. Ready to generate your Fresh Draft?
   >
   > • Brand: Acme Holdings LLC (DBA: Acme Salon)
   > • Use case: Low Volume Mixed
   > • Description: We send appointment reminders, special promotional offers, …
   > • Opt-in: Website Form → https://acmesalon.com/sms
   > • Existing legal docs: No — we'll generate full Privacy Policy and Terms
   >
   > **Auto-applied defaults you didn't have to specify:** country = United States,
   > region = USA & Canada, age18Confirmed = yes. Reply 'different' if any of
   > those need to change (e.g., you're not US-based — Easy A2P only supports
   > US-based A2P 10DLC submissions today).
   >
   > This costs **2 credits**. The result is a full GHL Trust Center
   > submission packet — roughly 19 sections covering Brand, Address,
   > Use Case, Sample Messages, Opt-In Form/Image URL, Opt-In Flow,
   > Opt-In Confirmation, Marketing/Non-Marketing Checkboxes (or Chat
   > Widget Checklist), Website Compliance Checklist, Privacy Policy +
   > Terms of Service, the Before-You-Open-GHL prep checklist, Legal
   > Document URLs, and any applicable state or cross-border advisories.
   >
   > Confirm? Reply 'yes' / 'go' / 'confirm', or tell me what to change."

   Wait for explicit confirmation. When the user confirms:

   1. **Check `EASY_A2P_API_KEY` is set in the environment.** If it is,
      call `scripts/draft.sh` with the JSON-encoded `draftData` object.
      The 2 credits are deducted server-side; render the response packet.

   2. **If `EASY_A2P_API_KEY` is missing** — the user has confirmed but
      can't actually run the call. Surface the full signup + auth
      instructions below. Do NOT call the API and do NOT make the user
      retype anything — their `draftData` is already collected and ready
      to fire as soon as they paste a key.

   **Auth fallback message (verbatim — show this when key is missing):**

   > "All your answers are captured and ready to go. I just need an
   > Easy A2P API key to make the call.
   >
   > **If you already have a key:** paste it here in the chat (it starts
   > with `eaap_`) and I'll use it for this run.
   >
   > **If you don't have an account yet:**
   > 1. Visit https://easya2p.app and click **Sign Up**.
   > 2. Sign up with email or Google. New accounts get **3 free credits**
   >    — enough for one Draft Fresh Copy (2 credits) plus one Review of
   >    Existing Copy (1 credit).
   > 3. Verify your email if prompted.
   > 4. Open Easy A2P again, click your name in the top right →
   >    **API Access**, click **Generate API Key**, and copy the key.
   >    It starts with `eaap_` and is shown only once — if you lose it,
   >    regenerate.
   > 5. Paste the key here in the chat.
   >
   > Once I have your key, I'll re-run the draft with the inputs you
   > already provided — no need to repeat the interview."

   **When the user pastes the key:** export it for the script call in this
   session (`export EASY_A2P_API_KEY=eaap_…`), then immediately call
   `scripts/draft.sh`. Do NOT wait, do NOT ask another confirmation —
   the user already confirmed at Round 15.

   **After a successful run, offer the persistence path as a follow-up:**
   > "If you want me to remember this key for future sessions, run this
   > in your terminal once:
   >
   > ```bash
   > echo 'export EASY_A2P_API_KEY=eaap_your_key_here' >> ~/.zshrc && source ~/.zshrc
   > ```
   >
   > That way you won't have to paste it again."

   This is optional — never block the flow on it.

   ---

   **Scope mismatch guards (run at Mismatch Checkpoints 1 and 2):**

   Mirror the web wizard's deterministic mismatch detection. Use these
   keyword regexes (case-insensitive):

   - **Marketing keywords:** `\b(market|promot|offer|deal|discount|sale|coupon|special)\b`
   - **Transactional keywords:** `\b(account|appointment|service\s+alert|notification|transactional|support|delivery|tracking|invoice|receipt|verification|reminder|confirmation)\b`

   Classify the use case:
   - `mixed` if `useCase.toLowerCase().includes('mixed')`
   - `marketing-only` if `useCase.toLowerCase().includes('market')` and not mixed
   - `transactional` otherwise

   Apply to the text being checked (description at Checkpoint 1, scenario1+scenario2 concatenated at Checkpoint 2):

   | Use case | Text contains marketing keywords? | Text contains transactional keywords? | Direction | Action |
   |---|---|---|---|---|
   | Mixed or Marketing-only | NO | (any) | **A** (soft block) | Checkpoint 1 only — see below |
   | Transactional | YES | (any) | **B** (HARD BLOCK) | See below |
   | Marketing-only | NO | YES | **C** (HARD BLOCK) | See below |

   **Direction A — soft block at Checkpoint 1 only:**
   > "⚠️ Heads up — your description doesn't mention any promotional content (offers, discounts, sales, deals, promotions). Per TCR rules, your declared use case must match your message content.
   >
   > If you continue as-is, the system will generate a NON-MARKETING packet to match your description (this is a safe subset of your declared scope — TCR allows it).
   >
   > Three options:
   > 1. Edit your description to add promotional content
   > 2. Change your use case (probably to a non-marketing one like Customer Care or Account Notifications)
   > 3. Continue with non-marketing packet (acknowledged)
   >
   > Reply 1, 2, or 3."

   If user picks 3, set internal flag `_userAcknowledgedScopeOverride = true`
   and proceed.

   **Direction B — HARD BLOCK (no override):**
   > "🚫 Use case mismatch — your registration will fail TCR review.
   >
   > You picked **{useCase}** — a transactional-only use case. But your {description / sample scenarios} mention promotional content (offers, discounts, sales, deals, promotions).
   >
   > Per TCR rules, your declared use case must match your message content. **{useCase} campaigns CANNOT include promotional content** — carriers will compare what you declared against your samples and reject your registration. This is a documented TCR rejection cause.
   >
   > **You must either:**
   > 1. Edit your {description / scenarios} to remove promotional content, OR
   > 2. Change your use case to **Low Volume Mixed** (which supports both transactional + promotional)
   >
   > Reply 1 or 2. (No override option for this case — submitting as-is would waste the 2 credits.)"

   **Direction C — HARD BLOCK (no override):**
   > "🚫 Use case mismatch — your registration will fail TCR review.
   >
   > You picked **{useCase}** — a marketing-only use case. But your {description / sample scenarios} mention transactional content (account updates, appointments, notifications, confirmations).
   >
   > Per TCR rules, your declared use case must match your message content. **Marketing-only campaigns CANNOT include transactional content** — carriers will reject this submission.
   >
   > **You must either:**
   > 1. Edit your {description / scenarios} to remove transactional content, OR
   > 2. Change your use case to **Low Volume Mixed** (which supports both)
   >
   > Reply 1 or 2."

   **Why these guards matter:** even if these checks pass, the server runs
   a Layer 3 post-AI guard that detects mismatch in the AI's own output.
   If Layer 3 fires, the user is automatically refunded the 2 credits.
   These wizard guards exist to save the user's TIME (no waiting for AI)
   and to prevent the cycle of generate → refund → generate again.

   ---

   **Response shape (as of 2026-05-12):** `draft.sh` returns the raw
   HTTP response. Parse `.content[0].text` as JSON to get the packet:
   ```
   {
     "sections": [
       { "label": "Profile Needs", "displayLabel": "...", "text": "...", "field": "...", ... },
       { "label": "Business Details", "fieldList": [...], ... },
       ...
     ],
     "usage":     { "input_tokens": ..., "output_tokens": ... },
     "aiMerged":  true,
     "mismatch":  { "detected": false }   // or { detected: true, direction: 'B', useCase, affectedSections, reason, refunded, creditsRemaining }
   }
   ```

   **Section rendering (in priority order):**
   - Use `section.displayLabel` as the user-facing heading if present;
     otherwise fall back to `section.label`. (Mode A complete PP/ToS use
     `displayLabel: "Privacy Policy (Complete)"` while their internal
     `label` stays `"Privacy Policy — SMS Section"` for validation.)
   - Render `section.text` inside a code block so the user can copy it.
   - If `section.fieldList` exists, it's a structured field card —
     render each `{label, value}` row instead of a single text block.
   - If `section.warning` exists, render it as an advisory panel
     ABOVE the text (red/yellow accent for `(!) Critical` / `Action required`).
   - If `section.mixedNotice` exists (only on Sample Message 1 and
     Sample Message 2 for Mixed campaigns), render it as an amber
     callout below the text confirming which slot it belongs in.
   - If `section.infoNote` exists, render it BELOW the text (italic /
     muted) — it's the "📋 paste this directly into the GHL field"
     guidance.
   - Group rendering by `section.ghlGroup` if present (e.g.,
     "Business Details", "Campaign Details — Messaging Use Case",
     "Legal Documents", "Submission Prep") to mirror the GHL Trust
     Center wizard's flow.

   **Handling the `mismatch` field (Layer 3 post-AI guard):**
   When the server detects a use-case ↔ AI-output mismatch, it sets
   `mismatch.detected = true`, **automatically refunds the 2 credits**,
   and returns the packet anyway so the user can see what was generated.
   When this happens:
   - **Surface the refund prominently** — banner at the top of your
     output: "⚠️ Use case mismatch detected — your 2 credits have
     been refunded."
   - **Quote the `mismatch.reason` field** verbatim — it includes
     specific guidance on what to change.
   - **List `mismatch.affectedSections`** so the user sees which
     sections were flagged (Campaign Use Case Description, Sample
     Message 1, etc.).
   - **Tell them not to re-run with the same inputs** — re-running
     will produce the same mismatch.
   - **Still render the packet** — users can read what was generated
     to understand why it failed and learn what to change.

   **`aiMerged: true`** confirms the 4 AI-owned outputs (Use Case
   Description, Sample Message 1, Sample Message 2, and the
   marketing/non-marketing checkbox content phrases when applicable)
   were successfully overlaid on the deterministic packet.
   **`aiMerged: false`** means the model returned malformed JSON and
   only the deterministic fallbacks are shown for those sections —
   flag this to the user and offer to retry.

   **`section.text` for Marketing/Non-Marketing Checkbox sections:**
   The AI generates ONLY a noun phrase ("exclusive packages, seasonal
   services, and member-only promotions"); the deterministic template
   wraps it with the compliance-critical wording (HELP/STOP/frequency/
   rates). If the AI phrase fails the safety check (under 3 words, over
   10 words, contains URLs / sentence wrappers / forbidden language),
   the template falls back to GHL's standard wording. You don't need
   to do anything special here — the wrapped text is in `section.text`
   ready to render.

5. **For `fix` (3 credits):** **A `fix` only ever runs after a Review has
   completed this session — never before** (see "Fix is gated behind a
   Review"). If the user asked to fix copy they have not yet had reviewed,
   run the Review first (step 3), present the findings, then offer the
   fix. Confirm the 3-credit cost and wait for an explicit "yes" before
   calling `scripts/fix.sh`. You already have (a) the section copy from
   the Review; pass (b) the Review's findings to fix.sh as
   `rejectionContext`.

   **Use-case checkpoint — REQUIRED before calling `fix.sh`.** When the
   user supplies only a few sections, the corrector cannot see the
   campaign's use case or opt-in method — and rather than leave the copy
   vague (which fails review) it will GUESS them: silently rewriting a
   vague Campaign Description as "Low Volume Mixed", or assuming a
   "Website Form" opt-in. Use case is a **permanent** campaign attribute,
   and a wrong use case is itself a TCR rejection cause — a bad guess
   misregisters the campaign. So before calling `fix.sh`, check whether
   the sections the user gave you already establish BOTH:
   - the **campaign use case** (Appointment Reminders / Customer Care,
     Account Notifications, Marketing Offers & Promotions, Low Volume
     Mixed, 2FA, Delivery Notification, etc.), and
   - the **opt-in method** (GHL Chat Widget, Website Form, QR Code,
     Paper Form, Kiosk, Facebook Lead Form, Verbal).

   If a complete Campaign Description (or Opt-In Flow Description) is
   among the submitted sections and makes both clear, proceed. If either
   is missing or ambiguous, **ask the user — just those one or two
   questions.** This is NOT the 15-round draft interview; it is the
   minimum context the fix needs to produce copy that fits the user's
   real campaign instead of a guessed one. Then pass the confirmed
   answers to `fix.sh` inside the `rejectionContext` string, clearly
   labelled — e.g.: `"Confirmed use case: Low Volume Mixed. Confirmed
   opt-in method: Website Form. Rejection reasons: <review findings>"`.

   Call `scripts/fix.sh` with a body shaped
   `{"sections": {...}, "rejectionContext": "..."}`. The response
   contains `corrected` (paste-ready text per section), `changes` (what
   was wrong, what was fixed), and `verification` (PASS confirmation per
   section). Present `corrected` text inside code blocks for clean copy.
   **If any `changes` entry flags an assumed use case or opt-in method
   ("USE CASE ASSUMED — NOT IN SUBMISSION"), surface it to the user
   prominently** — never let them paste copy built on a guessed use case
   into the GHL Trust Center.

6. **Format results clearly.** The API returns structured JSON. Present
   findings to the user in plain English: section name, status, the specific
   issue, and (only for `fix` and `draft`) the paste-ready corrected text.
   For `draft`, walk the `sections` array described in Step 7 and render
   each section's `label` as a heading and `text` inside a code block
   so the user can copy directly into the GHL Trust Center fields.
   Group by `ghlGroup` if present (e.g. "Business Details", "Campaign
   Details — Messaging Use Case", "Legal Documents") to mirror the
   Trust Center wizard's flow.

7. **Be proactive about DBA handling.** If the user mentions a DBA different
   from their legal entity, confirm both names before drafting or fixing.
   The skill follows GHL's "We are doing business as [DBA Name]"
   declaration pattern automatically when both fields are provided.

## Reference files

Read these when relevant — Claude doesn't need them in context for every
invocation, only when the topic comes up:

- `reference/tcr-non-sharing-clause.md` — The verbatim Privacy Policy
  non-sharing language TCR scans for. Read when the user is auditing or
  drafting a Privacy Policy.
- `reference/stop-help-canonical.md` — Canonical phrasing for STOP/HELP
  in opt-in checkboxes ("Text HELP for help, reply STOP to opt-out") vs.
  sample messages ("Reply STOP to unsubscribe" or "to opt-out"). Read when
  the user is reviewing checkbox or sample copy.
- `reference/dba-handling.md` — The 4-placement rule for legal name vs. DBA
  across the GHL Trust Center submission. Read when the user has a DBA
  different from their legal entity.
- `reference/section-fields.md` — Canonical names for all 9 sections of a
  GHL Trust Center submission, mapped to the field names the API expects.
  Read this before constructing any Review API call.

## Examples of expected behavior

**Example 1 — User asks "check this":**
User: "Can you check this sample? 'Hi {{contact.first_name}}, your appointment is confirmed. Reply STOP to unsubscribe.'"

Action: Call `review` (1 credit) on the Sample Messages section. Return findings only:

> **FAIL — Curly-brace merge fields detected.** The variable `{{contact.first_name}}` reads as broken code to TCR reviewers — this is the #1 documented A2P 10DLC rejection cause.
>
> Want me to fix it? A 3-credit `fix` will return paste-ready corrected copy that's been self-verified against the rule library. Or you can fix it yourself by replacing the merge field with a real example name (e.g. "Hi Sarah,") or a square-bracket placeholder ("Hi [Customer Name],").

Do NOT include the corrected text in the review response — that's what `fix` is for.

**Example 1b — User asks "fix this":**
User: "Fix this sample message: 'Hi {{contact.first_name}}, your appointment is confirmed. Reply STOP.'"

Action: Even though the user said "fix", `fix` never runs before a Review. Run the 1-credit Review on the sample first and present the findings (here: the curly-brace merge field, the missing STOP best-practice). THEN offer the 3-credit fix — "Want me to fix it? That's 3 credits — proceed?" — and only on an explicit "yes" call `scripts/fix.sh` (sample as `Sample Message 1`, the Review's findings passed as `rejectionContext`). Return the `corrected` text in a code block with a one-line summary of what changed.

**Example 2 — User wants to draft fresh copy with a DBA:**
User: "I need to set up A2P for my client. Legal entity is Acme Holdings LLC, they go by Acme Salon. They send appointment reminders and occasional offers."

Action: Confirm Mixed use case. Call `draft` with `legalName: "Acme Holdings LLC"`, `dbaName: "Acme Salon"`, `useCase: "Mixed"`. Parse `.content[0].text` to get the `sections` array, then render each section so the user can copy it directly into the matching GHL Trust Center field. Verify on inspection: the DBA "Acme Salon" appears across Sample Message 1, Sample Message 2, the Marketing Opt-In Checkbox, the Non-Marketing Opt-In Checkbox, and the Opt-In Confirmation; "Acme Holdings LLC DBA Acme Salon" appears in the Privacy Policy and Terms of Service section openers; and the Use Case Description includes "We are doing business as Acme Salon." as its second sentence.

## When the API is unavailable

Easy A2P's backend can occasionally rate-limit or 503. If `validate.sh` or
`draft.sh` exits non-zero with a 503/429 response:

- Tell the user the API is temporarily overloaded (don't expose raw error
  details unless they ask).
- Suggest retrying in a minute.
- Don't auto-retry — the API itself has retry logic; an additional retry
  layer here would compound rate-limiting.

## Things this skill is NOT for

- Generic SMS marketing advice or platform comparisons
- Non-GoHighLevel SMS platforms (Twilio direct, Bandwidth, etc.)
- A2P 10DLC outside the US/Canada (other regions have different carrier rules)
- Toll-free SMS verification (different process — see Easy A2P's docs for that)
- Legal review of Privacy Policies or Terms of Service (this is administrative
  aid, not legal advice)

## Brand voice and tone

When presenting findings or generated copy to the user:
- Use plain, specific language — agencies are time-pressed and skeptical of
  jargon.
- Cite the rule by name when something fails (e.g., "fails SEMANTIC FAIL 2B
  — Mixed Use Case Combined Content")
- For paste-ready copy, present it inside a code block so the user can copy
  it cleanly.
- Don't over-explain compliance theory unless the user asks — they want the
  fix, not a lecture.
