# Changelog

All notable changes to the easy-a2p skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
