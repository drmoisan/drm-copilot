# Reconciliation Addendum — Pack-Manifest Placement Decision Superseded (Remediation Cycle 1)

Timestamp: 2026-07-19T08-07

## Purpose

This addendum documents a correction to the original reconciliation-pass evidence record
without modifying that record. It supersedes only the "Pack-Manifest Placement Decision"
disposition (the final disposition item) in
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/other/integration-reconciliation.2026-07-19T07-30.md`,
lines 170-189.

## What the Original Disposition Relied On

The original "Pack-Manifest Placement Decision" disposition verified the pack-manifest
placement of agent personas/hooks/skills directly (against `core.json`), but for the
schemas/templates half of the claim it relied on
`docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md` prose alone:
"Neither `schemas/` nor `docs/discovery/templates/` is a mirrored root... they are Python
source/data distributed to consumers through the MCP-server npm package, not through the
`.claude`/`.codex` push-down publishers." That spec.md text documents a design
classification (`Decision: scripts-non-mirrored`); the original disposition did not
independently verify `packages/mcp-server/package.json`, `packages/mcp-server/prepack.cjs`,
or `extensions/drm-copilot/resources/**` before treating the claim as an accurate
description of current consumer-facing behavior. `consumer-onboarding.md` then converted
this unverified aspirational language into a present-tense factual claim, which was
identified as Blocking Finding 1 in
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/remediation-inputs.2026-07-19T09-20.md`.

## What This Remediation Cycle's Independent Verification Found

This cycle independently verified the packaging code directly (not #372's spec.md prose):

- `packages/mcp-server/package.json`'s `files` field is a two-entry array
  (`out/mcp-server.js`, `resources`); neither `schemas/discovery` nor
  `docs/discovery/templates` is declared
  (`evidence/qa-gates/r1c1-package-json-files-field.2026-07-19T08-01.md`).
- `packages/mcp-server/prepack.cjs`'s `shouldCopy()` filter copies only from
  `extensions/drm-copilot/resources/`, excluding `.py` files and `scripts/`-segment paths,
  with no allow-list entry or additional source directory for either asset tree
  (`evidence/qa-gates/r1c1-prepack-exclusion-filter.2026-07-19T08-02.md`).
- `extensions/drm-copilot/resources/**` contains zero `schemas/discovery` content and zero
  `docs/discovery/templates` content — the only "templates" hits are unrelated
  `feature-templates/` and `templates/` scaffolding directories
  (`evidence/qa-gates/r1c1-resources-tree-check.2026-07-19T08-03.md`).

Together, these three independent checks confirm no consumer-facing distribution mechanism
exists today for either the seven discovery schemas or the initialization templates. The
`@danmoisan/drm-copilot-mcp` npm package does not ship them, and no push-down publisher
mirrors them. This is a real, unremediated capability gap in the delivered epic, not merely
a documentation-wording issue.

## Disposition

The original evidence file
(`evidence/other/integration-reconciliation.2026-07-19T07-30.md`) remains the unmodified
historical record of this remediation cycle's predecessor review; it is not edited or
deleted (confirmed: `git diff` against that path is empty). This addendum supersedes only
its "Pack-Manifest Placement Decision" disposition: that disposition's schemas/templates
half should now be read as "verified against #372's spec.md prose only, not against the
packaging code — corrected by this addendum's independent verification, which found no
distribution mechanism exists." Its agent-personas/hooks/skills half (verified against
`core.json`) is unaffected and remains accurate. `consumer-onboarding.md` has been rewritten
(Phase 1 of `remediation-plan.2026-07-19T09-20.md`) to state the gap plainly per Branch A of
the remediation-inputs required-remediation guidance.