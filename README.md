# easy-a2p

The official Claude Code skill for **A2P 10DLC SMS registration in GoHighLevel**.

The Easy A2P skill reviews your GoHighLevel Trust Center submission copy against
The Campaign Registry's documented rejection causes, drafts review-ready
submission packets from your business inputs, and rewrites failing copy — all
without leaving Claude Code. It's a thin client over the [Easy A2P](https://easya2p.app)
rule engine, so it always runs against the latest rules.

**Full docs:** [easya2p.app/claude-skill](https://easya2p.app/claude-skill)

## What it does

Three actions, the same rules and credits as the [Easy A2P web app](https://app.easya2p.app):

- **review** (1 credit) — Paste any of the 10 GHL Trust Center sections (Brand
  Registration, Campaign / Use Case Description, Sample Message 1, Sample
  Message 2, Marketing Opt-In Checkbox, Non-Marketing Opt-In Checkbox, Opt-In
  Confirmation Message, Opt-In Flow Description, Privacy Policy SMS section,
  Terms of Service SMS section) and get back structured findings per section:
  status, the specific rule that fired, and why it matters. **Findings and
  remediation guidance only — not paste-ready rewrites.**

- **draft** (2 credits) — Provide intake fields (legal name, DBA, industry, use
  case, opt-in method) and get back a complete, review-ready submission packet
  ready to paste into the Trust Center.

- **fix** (1 credit) — Paste copy that failed TCR review (or is likely to) and
  get back paste-ready corrected copy that the backend self-verifies against the
  rule library before returning it. A review (1) plus a fix (1) totals the same
  2 credits as a fresh draft — any path to a clean packet costs the same.

All three run on Easy A2P's live rule engine, which catches, among others:

- The #1 documented rejection cause (curly-brace merge fields left in samples)
- Use-case mismatch (Mixed campaigns combining transactional + promotional in one sentence)
- A missing or non-canonical Privacy Policy non-sharing clause
- Missing STOP language or business name in samples
- DBA inconsistencies across the submission
- A library of deterministic pattern checks plus AI-powered semantic rules,
  built to the TCR CSP User Guide v8 and GHL Help Center patterns

## Install

```bash
git clone https://github.com/garyvogtconsulting-commits/easy-a2p-skill ~/.claude/skills/easy-a2p
```

The skill is now available in Claude Code. Trigger it by mentioning GoHighLevel
A2P 10DLC, TCR rejection, Trust Center, or by asking Claude to review or draft
SMS registration copy — the skill auto-loads and routes you to the right action.

## Authentication

You need an [Easy A2P](https://app.easya2p.app) account to use the skill. Sign up —
your first 3 credits are free, no card required.

After signup, find your API key in the Easy A2P dashboard under
**Settings → API Access**, and set it in your environment:

```bash
export EASY_A2P_API_KEY=eaap_your_key_here
```

For persistence, add the `export` line to `~/.zshrc` (Mac) or `~/.bashrc` (Linux).

## Usage examples

Once installed and authenticated, just ask Claude:

- *"Can you check this sample message before I submit it to Trust Center? `Hi {{contact.first_name}}, your appointment is confirmed.`"*
- *"I need to set up A2P for a client. Their legal entity is Acme Holdings LLC, they go by Acme Salon, and they send appointment reminders and occasional offers."*
- *"I got rejected from Trust Center for 'use case mismatch'. Here's my Use Case Description — can you fix it?"*

Claude detects the A2P 10DLC context and invokes the skill automatically.

## How it works

Each invocation hits Easy A2P's `/api/validate` endpoint. The skill is a thin
client — the real logic (the rule library, the AI semantic checks, the prompt
templates) lives on the Easy A2P backend, where it can be updated centrally.

This means the skill always runs against the latest version of the rules — when
GHL or TCR publishes a new rejection cause, Easy A2P updates the engine and your
skill picks it up on the next call. No re-installs needed.

Easy A2P checks and drafts your copy — it does **not** submit or approve
campaigns. The Campaign Registry and the mobile carriers make every approval
decision. The skill's job is to catch the preventable rejection causes before
you submit.

## Pricing

Credits are shared with the [web app](https://app.easya2p.app) and never expire:

- **review** — 1 credit
- **draft** — 2 credits
- **fix** — 1 credit

Every account starts with **3 free credits**, no card required. Need more? Pro is
$39/month (or $390/year) for 10 credits a month with rollover, plus a one-time
top-up option. Current plans: [easya2p.app/pricing](https://easya2p.app/pricing).

## License

MIT — see [LICENSE](LICENSE).

## Maintainer

Built by [Gary Vogt Consulting](https://easya2p.app) — info@easya2p.app · Ship it Clean!
