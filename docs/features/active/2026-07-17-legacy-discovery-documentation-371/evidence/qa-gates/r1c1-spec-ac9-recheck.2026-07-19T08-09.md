# Phase 2 — spec.md AC9 Re-Check (Remediation Cycle 1)

Timestamp: 2026-07-19T08-09

Quoted AC9 text (spec.md, `## Acceptance Criteria`):

> Provisional content is handled per the upstream-presence constraint: content is
> authored against planned scope from `objective-source.md` where an upstream spec
> is absent and against the delivered spec where present, and forward references to
> not-yet-delivered files are explicitly marked as planned.

Output Summary:

Re-checked from `- [ ]` to `- [x]` on the strength of the corrected item 2 wording
(`P1-T1`). The corrected item 2 marks the schema/init-template distribution gap using the
same "open, planned item, not delivered behavior" convention used elsewhere in this doc
set for genuinely forward-looking references (per the provisional-content convention named
in the Constraints & Risks section of this spec and in the required-remediation guidance of
`remediation-inputs.2026-07-19T09-20.md`, Branch A). The corrected text does not assert the
gap is closed; it names the classification decision
(`legacy-discovery-publishing-372`'s spec.md "Schema/Init-Template Placement — Resolved"
section, `Decision: scripts-non-mirrored`) as the source of why the assets are not pushed
down, while stating plainly that closing the distribution gap itself remains open and
planned, not landed. This is a correct application of the provisional-content convention:
a design classification decision is documented as resolved (it is), while the undelivered
distribution mechanism is documented as planned/open (it is). AC9 is satisfied.