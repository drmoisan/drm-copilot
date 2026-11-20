# Phase 0 — Feature document read record (issue #545)

Timestamp: 2026-08-25T10-19

Task: [P0-T2]

Documents read, in the mandated order:

1. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md` (856 lines)
2. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/issue.md` (189 lines)
3. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md` (368 lines)

Command: `wc -l spec.md issue.md research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md`

EXIT_CODE: 0

## Specification design-decision identifiers present at the time of this read

D10 does not exist in `spec.md` at this point; it is added by [P1-T2]. The nine decisions
currently present are:

- **D1** — Selected remedy: masked-trigger scanning with a wrapper carve-out, plus structural
  relocation classification. Records the three rejected alternatives (naive segment-leading
  classifier, wholesale promotion of the #539 exemption parser, any Python leg).
- **D2** — Behavior contract (normative). Piece 1 the command scanner and its five per-segment
  properties; Piece 2 masked trigger evaluation with the three ordered scan-text selection
  clauses and the fourteen-member wrapper carve-out set; Piece 3 the structural relocation
  classifier with its six numbered steps. Carries decision rules R1 through R6 and the per-hook
  application table.
- **D3** — The fail-closed argument, form by form. The fourteen-row table that is the load-bearing
  obligation on the test surface.
- **D4** — Residual accepted risks and the hook family's posture. Three entries at the time of
  this read: over-match inside wrapper-led segments, obfuscated respellings, and an unlisted
  wrapper whose quoted argument is a command line. A fourth entry is added by [P1-T10].
- **D5** — `enforce-promotion-mcp-only.ps1` is in scope for masking (orchestrator decision).
- **D6** — The pr-author under-match is in scope (orchestrator decision).
- **D7** — Shared helper name is `hook-command-scanner.ps1` (orchestrator decision).
- **D8** — Issue #539's spec is annotated additively, never rewritten (orchestrator decision);
  names the five affected locations.
- **D9** — Synchronization contract: two deliberately divergent synchronized pairs, the copy
  sets, the enforcing mechanisms, and the six registrations a new shared helper requires.

## Output Summary

All three feature documents exist and were read in full. The specification carries design
decisions D1 through D9 and no D10, matching this task's stated expectation. `issue.md` records
`- Work Mode: full-bug`, which resolves `spec.md` as the sole acceptance-criteria source; no
`user-story.md` exists in the feature folder. The `## Acceptance Criteria` section of `spec.md`
holds 24 unchecked criteria at this point; [P1-T5] takes that count to 25. The research document
is authoritative for design and is not re-derived by this plan.
