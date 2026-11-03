# Preflight Fixes (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-10
Plan: docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/remediation-plan.2026-10-31T08-57.md
Mode: proportionate remediation cycle, single-pass preflight

## Fixes

1. [P3-T8] | stale anchor (ambiguous set) | The task named "the five `.claude/lib/blast-radius/*.psm1` modules" while the directory holds ten. The five modules in the branch diff against `MERGE_BASE` are now named: `BlastRadius.psm1`, `BlastRadiusExtraction.psm1`, `BlastRadiusNormalization.psm1`, `BlastRadiusTokenShape.psm1`, `BlastRadiusWriteIntent.psm1`. The asserted threshold (each at least 85 percent) is unchanged.
2. [P3-T6] | literal-formatting / observation strength | `git status --porcelain` reports ` M` for an already-modified file both before and after a formatter rewrite, so porcelain identity alone cannot show the file is unchanged. Added a before-and-after SHA-256 hash observation of the file. The asserted outcome (file unchanged by the formatter) is unchanged.

## Checks performed without a fix

- Plan validator: MCP `validate_orchestration_artifacts` (plan) ok; branch-current Python CLI `plan` subcommand exit 0.
- Every named Jest test title in P1-T1 and P1-T2 exists in the three `TS_TESTS` files.
- The Pester `It` block title in P2-T1 exists; `$script:OverlayDirectiveKey` occurs only in that block.
- `test_push_down_claude_overlay_parity.py` reads the demote module text only for the `SHARED_SURFACES_DEMOTE_KEY` constant, which this cycle does not change; unaffected.
- `test:coverage`, `lint`, and `typecheck` scripts exist in `extensions/drm-copilot/package.json`; both overlay files have `coverageThreshold` entries in `jest.config.cjs`.
- The three policy-audit templates named in P3-T12 exist.
