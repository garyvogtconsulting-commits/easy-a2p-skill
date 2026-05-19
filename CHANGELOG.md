# Changelog

All notable changes to the easy-a2p skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.6] — 2026-05-19

### Changed
- **"Validate" is now "Review" everywhere user-facing.** The skill's
  first action — grading existing GHL Trust Center copy — is now called
  "Review existing copy" instead of "Validate existing copy", matching
  the web app's "Review Existing Copy" wording. All user-facing language
  in `SKILL.md` and `README.md` updated. (The internal script
  `validate.sh` and the `/api/validate` endpoint keep their names — they
  are implementation detail the user never sees.)
- **`fix` is now gated behind a Review.** The skill no longer offers or
  runs the 3-credit `fix` until the user has run a 1-credit Review in the
  same session, and it no longer presents a "Review or Fix?" choice up
  front. Even when a user opens with "fix this copy", the skill runs the
  Review first, presents the findings, then offers the fix. This stops
  users from spending 3 credits on a fix without first seeing — for 1
  credit — exactly what fails, and it gives the fix the Review's findings
  to work from.
- **The skill never shows a numeric score.** The API response carries an
  internal `score` field; the skill now treats it as internal only and
  never displays it. Results are presented with the plain-English
  `verdict` and per-section pass/warn/fail status instead.

## [1.0.5] — 2026-05-19

### Added
- **Use-case checkpoint before `fix`.** When a user asks the skill to
  fix only a few sections, the corrector can't see the campaign's use
  case or opt-in method and would silently guess them — rewriting a
  vague Campaign Description as "Low Volume Mixed" or assuming a
  "Website Form" opt-in. Use case is a permanent campaign attribute, so
  a wrong guess misregisters the campaign. The skill now checks whether
  the submitted sections establish the use case and opt-in method; if
  not, it asks the user those one or two questions (not the full
  15-round draft interview) and passes the confirmed answers to
  `fix.sh` via `rejectionContext`. If the backend still has to assume a
  use case, it flags it ("USE CASE ASSUMED — NOT IN SUBMISSION") and the
  skill surfaces that to the user before they submit.

### Notes for users
- This pairs with a backend change: a free-text `rejectionContext` is
  now read by the fix endpoint (previously only the web app's
  structured rejection object was). Confirmed use-case / opt-in details
  passed in `rejectionContext` are treated as authoritative.

## [1.0.4] — 2026-05-14

### Changed
- **All three scripts (`validate.sh`, `draft.sh`, `fix.sh`) now surface
  the `X-Credits-Remaining` HTTP response header to the user.** When
  Easy A2P's backend reports a remaining credit balance (which it does
  for normal customers via the response header, not the JSON body),
  the scripts now print `[easy-a2p] Credits remaining: N` to **stderr**.
  The body still goes to stdout unchanged, so existing JSON parsers
  keep working — the credit info is purely additive and visible to
  users without polluting structured output.
- **Scripts now correctly propagate HTTP status as exit code.** Previously
  they relied on `--fail-with-body` which masked the underlying HTTP
  code. Now they capture the code via `-w` and exit `22` (curl's
  HTTP-error code) when the response is `>= 400`. Body is still
  emitted on error so callers can inspect the error JSON.

### Notes for users
- Admin accounts and unlimited (`plan_max`) plans don't have a finite
  credit balance, so they won't see the credits-remaining message.
  This is expected — the message only appears when there's a real
  balance to report.

## [1.0.3] — 2026-05-13

### Added
- **Privacy reassurance in the skill's opening message.** Every new
  skill session now ends its first reply with a "Your business data
  stays yours" paragraph that mirrors the trust copy on easya2p.app
  and app.easya2p.app. Tells users their legal name, EIN, address,
  and description are sent once to Anthropic to generate copy and
  then discarded — never stored or logged on Easy A2P's servers.
  Consistent trust signal across web app, marketing site, and skill.

## [1.0.2] — 2026-05-12

### Fixed
- **API key location instructions** referenced a non-existent "Settings"
  menu. Updated both the Authentication section and the Round 15 auth
  fallback to match the live UI: "click your name in the top right →
  API Access".

## [1.0.1] — 2026-05-12

### Fixed
- **Authorized Representative round-trip.** Round 6 was sending
  `authRepName` / `authRepTitle` (combined), but the server expects
  three separate fields. Skill now splits the user's reply into
  `authRepFirstName`, `authRepLastName`, `authRepJobTitle` before
  calling `draft.sh`. The "First Name / Last Name / Job Position"
  section in the GHL Trust Center packet is now populated correctly.

### Changed
- **Auth flow leads with paste-in-chat.** Previously the skill demanded
  users export `EASY_A2P_API_KEY` in a terminal before they could draft
  — a barrier for non-technical users. Now Claude accepts the key pasted
  into chat and exports it for the script call within the session. The
  persistent `~/.zshrc` export is offered as an optional follow-up after
  a successful run.
- **Round 8 ask simplified** to "What kinds of messages do you send and
  to who do you send them?" — drops the explanation about templates and
  AI restructuring. Matches the web app's tone.
- **Round 15 confirmation reworded** from "Ready to generate? Quick
  summary before I spend your 2 credits" to "Here is a summary of your
  inputs. Ready to generate your Fresh Draft?"
- **Stop echoing internal variable names.** Added an explicit interview
  rule: never write `Captured: optInMethod = "Website Form"` (or any
  similar field-name leak) back to the user. Acknowledge in plain
  English instead.

## [1.0.0] — 2026-05-12

Initial public release.

### Added
- 15-round conversational intake interview for `draft` (mirrors the
  app.easya2p.app Draft Fresh Copy Wizard).
- Three action scripts:
  - `validate.sh` (1 credit) — grade existing GHL Trust Center copy.
  - `draft.sh` (2 credits) — generate a full submission packet from intake.
  - `fix.sh` (3 credits) — generate-and-self-verify rewrite of failing copy.
- Two-checkpoint mismatch detection (after description, after scenarios)
  surfacing Direction A/B/C scope mismatches before the API call.
- Bulk-dump and order-flexibility handling — parses pre-supplied user
  fields and only asks for what's missing.
- Auto-applied silent defaults (country, region, age18Confirmed) and
  state-default-confirm pattern for `infoCollected` / `dataSecurity`.
- Detailed signup + auth-fallback instructions for users without an API key.
- Reference docs: DBA handling, section field map, STOP/HELP canonical,
  TCR non-sharing clause.
- Evals scaffolding under `evals/`.

[1.0.0]: https://github.com/garyvogtconsulting-commits/easy-a2p-skill/releases/tag/v1.0.0
