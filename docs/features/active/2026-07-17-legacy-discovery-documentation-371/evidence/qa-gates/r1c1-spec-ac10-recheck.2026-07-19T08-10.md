# Phase 2 — spec.md AC10 Re-Check (Remediation Cycle 1)

Timestamp: 2026-07-19T08-10

Quoted AC10 text (spec.md, `## Acceptance Criteria`):

> A reconciliation pass against the integration branch
> (`epic/legacy-discovery-and-parity-integration`) is completed before the PR: every
> documented command name, path, schema name, and pack decision is verified against
> the integration branch or corrected/re-marked as planned.

Output Summary:

Re-checked from `- [ ]` to `- [x]` on the strength of the `P2-T7` reconciliation addendum
together with `P2-T1`-`P2-T3`'s independent verification. The original reconciliation pass
(`evidence/other/integration-reconciliation.2026-07-19T07-30.md`) verified ten of eleven
disposition items directly against landed code; its eleventh item ("Pack-Manifest Placement
Decision") relied on `legacy-discovery-publishing-372`'s spec.md prose for the
schemas/templates half of the claim rather than the packaging code itself. `P2-T7`'s
addendum documents this precisely and supersedes that one disposition. `P2-T1`-`P2-T3`
supply the missing independent verification the original pass lacked: direct inspection of
`packages/mcp-server/package.json`, `packages/mcp-server/prepack.cjs`, and
`extensions/drm-copilot/resources/**`, all three confirming no distribution mechanism
exists. With the addendum in place, the reconciliation pass is now complete: every
documented command name, path, schema name, and pack decision across the six-page doc set
has been verified against the integration branch (ten items via the original pass, one item
via this cycle's addendum and independent re-verification), and the one item that could not
be verified as a delivered mechanism (schema/template distribution) is now correctly
re-marked as planned/open in the corrected `consumer-onboarding.md`. AC10 is satisfied.