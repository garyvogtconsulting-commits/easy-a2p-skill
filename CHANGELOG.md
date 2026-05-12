# Changelog

All notable changes to the easy-a2p skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
