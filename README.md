# easy-a2p

The official Claude Code skill for **A2P 10DLC compliance in GoHighLevel**.

Validates GHL Trust Center submission copy against The Campaign Registry's
documented rejection causes, and drafts compliant submission packets from
intake fields. Wraps the [Easy A2P](https://easya2p.app) compliance engine.

## What it does

Three actions:

- **Validate existing copy** (1 credit) — Paste any of the 9 GHL Trust
  Center sections (Brand Registration, Sample Messages, Opt-In Checkboxes,
  Privacy Policy, Terms of Service, etc.) and get back structured findings:
  status, specific rule that fired, why it matters. Findings only — not
  paste-ready rewrites.

- **Draft fresh copy** (2 credits) — Provide intake fields (legal name, DBA,
  industry, use case, opt-in method) and get back a complete compliant
  submission packet ready to paste into Trust Center.

- **Fix failing copy** (3 credits) — Paste copy that failed TCR review (or
  is likely to) and get back paste-ready corrected copy that has been
  self-verified against the rule library. The 3-credit cost reflects the
  generate-and-self-verify loop the backend runs internally — the output is
  intended to pass TCR review on submission.

All three actions use Easy A2P's live compliance engine, which catches:
- The #1 documented rejection cause (curly-brace merge fields in samples)
- Use-case mismatch (Mixed campaigns combining transactional + promotional
  in one sentence)
- Missing or non-canonical Privacy Policy non-sharing clause
- DBA inconsistencies across the submission
- 30+ deterministic compliance rules and 13+ AI-powered semantic checks

## Install

```bash
mkdir -p ~/.claude/skills
cd ~/.claude/skills
git clone https://github.com/garyvogtconsulting-commits/skill-easy-a2p.git easy-a2p
```

The skill is now available in Claude Code. Trigger it by mentioning
GoHighLevel A2P 10DLC, TCR rejection, Trust Center, or asking Claude to
validate or draft SMS submission copy.

## Authentication

You need an [Easy A2P](https://easya2p.app) account to use the skill.
Sign up — first 3 credits are free, no card required.

After signup, find your API key in the Easy A2P dashboard under
**Settings → API Access**, and set it in your environment:

```bash
export EASY_A2P_API_KEY=eaap_your_key_here
```

For persistence, add the `export` line to `~/.zshrc` (Mac) or `~/.bashrc`
(Linux).

## Usage examples

Once installed and authenticated, just ask Claude:

- *"Can you check this sample message for A2P compliance? `Hi {{contact.first_name}}, your appointment is confirmed.`"*
- *"I need to set up A2P for a client. Their legal entity is Acme Holdings LLC, they go by Acme Salon, they send appointment reminders and occasional offers."*
- *"Got rejected from Trust Center for 'use case mismatch'. Here's my Use Case Description. Can you fix it?"*

Claude detects the A2P 10DLC context and invokes the skill automatically.

## How it works

Each invocation hits Easy A2P's `/api/validate` endpoint. The skill is a
thin client — the real compliance logic (30+ rules, 13 semantic AI checks,
the rule library, the prompt templates) lives on the Easy A2P backend
where it can be updated centrally.

This means the skill is always running against the latest version of the
rules — when GHL or TCR publishes a new rejection cause, Easy A2P updates
the engine, and your skill picks it up on the next call. No re-installs
needed.

## Pricing

Pay-as-you-go credits, no subscription. Credit bundles:
- Starter — 5 credits, $29
- Agency — 15 credits, $59
- Pro — 40 credits, $99

Credits never expire. 1 credit per validation, 2 credits per draft, 3 credits per fix.

[Sign up for free →](https://easya2p.app)

## License

MIT — see LICENSE file.

## Maintainer

Built by [Gary Vogt Consulting](https://easya2p.app) — info@easya2p.app
