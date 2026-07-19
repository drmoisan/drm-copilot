# Phase 2 — spec.md AC6 Re-Check (Remediation Cycle 1)

Timestamp: 2026-07-19T08-08

Quoted AC6 text (spec.md, `## Acceptance Criteria`):

> A consumer-onboarding page documents how consumer repositories receive the
> capability via the push-down tooling
> (`scripts/dev_tools/push_down_*_customizations.py` CLIs and MCP `push_down_*`
> tools), with TaskMaster and TMW framed strictly as onboarding examples.

Output Summary:

Re-checked from `- [ ]` to `- [x]` on the strength of the following evidence chain:

- `P1-T1` (item 2 rewrite) and `P1-T2` (introductory sentence rewrite): the corrected
  `consumer-onboarding.md` now documents the delivered push-down mechanism for agent
  personas/skills/hooks (item 1, unchanged and previously verified) accurately alongside
  the schemas/templates gap (item 2), instead of asserting undelivered behavior as landed.
- `P1-T3` (Onboarding Sequence step 2 rewrite): the sequence section accurately describes
  the currently available manual retrieval path rather than a nonexistent automated
  package-install step.
- `P1-T4` (post-edit grep): confirms zero remaining occurrences of the retired claim
  language in the corrected file.
- `P1-T5` (internal-consistency check): confirms the three edited passages agree with each
  other and with the rest of the page.
- `P2-T1`-`P2-T3` (independent packaging-code verification): confirms directly against
  `packages/mcp-server/package.json`, `packages/mcp-server/prepack.cjs`, and
  `extensions/drm-copilot/resources/**` that no distribution mechanism exists for the
  schemas/templates, grounding the corrected page's "no consumer-facing distribution
  mechanism today" statement in independently verified fact rather than another feature's
  spec.md prose.
- `P2-T4`-`P2-T6`: confirm the Phase 1 edit introduced no domain-neutrality, naming-collision,
  or link-resolution regression.

The page as corrected accurately documents both the delivered push-down mechanism (item 1)
and the schema/template gap (item 2, marked as an open item), with TaskMaster and TMW
framed strictly as onboarding examples (unchanged Worked Example section, re-verified by
`P2-T4`). AC6 is satisfied.