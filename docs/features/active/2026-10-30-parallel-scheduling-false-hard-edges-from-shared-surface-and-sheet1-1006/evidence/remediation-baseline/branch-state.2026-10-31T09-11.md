# Branch State (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-11
Command: sh SCRATCH/issue-1006-diff.sh (git fetch origin main; git merge-base origin/main HEAD; git rev-parse HEAD; git rev-parse --abbrev-ref HEAD; git merge-base --is-ancestor MERGE_BASE HEAD; git status --porcelain; git diff --name-only MERGE_BASE HEAD)
EXIT_CODE: 0
Output Summary: Branch bug/parallel-scheduling-false-hard-edges-1006; ancestry check exit 0; porcelain lists only FEATURE/ paths; all three CYCLE_FILES present in the diff listing (86 paths: 41 outside FEATURE/, 45 under FEATURE/).

## Values

- Branch: `bug/parallel-scheduling-false-hard-edges-1006`
- HEAD: `4fdb1848ab48cb161d46725c3115892fb1067000`
- MERGE_BASE: `1898400756e909b88cde5f51a05f0b11d423d3b0`
- Ancestry check (`git merge-base --is-ancestor MERGE_BASE HEAD`): EXIT_CODE: 0

## Porcelain status

```
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/other/preflight-fixes.2026-10-31T09-10.md
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/remediation-baseline/
?? docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/remediation-plan.2026-10-31T08-57.md
```

No path outside `FEATURE/`.

## CYCLE_FILES in `git diff --name-only MERGE_BASE HEAD`

- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts`: present
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts`: present
- `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`: present

## Non-FEATURE paths in the diff listing (reference for P3-T11)

```
.claude/lib/blast-radius/BlastRadius.psm1
.claude/lib/blast-radius/BlastRadiusExtraction.psm1
.claude/lib/blast-radius/BlastRadiusNormalization.psm1
.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1
.claude/rules/parallel-orchestration.md
config/blast-radius.json
docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md
extensions/drm-copilot/jest.config.cjs
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusNormalization.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts
extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts
extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
scripts/dev_tools/_blast_radius_extraction.py
scripts/dev_tools/_blast_radius_token_shapes.py
scripts/dev_tools/_blast_radius_write_intent.py
scripts/dev_tools/compute_blast_radius.py
scripts/dev_tools/push_down_claude_blast_radius_overlay.py
tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json
tests/fixtures/blast_radius_overlay/shared-surfaces-demote-unknown-entry.json
tests/fixtures/blast_radius_overlay/shared-surfaces-demote.json
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1
tests/scripts/dev_tools/blast_radius_parity_test_support.py
tests/scripts/dev_tools/test_blast_radius_config_parity.py
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py
tests/scripts/dev_tools/test_blast_radius_extraction.py
tests/scripts/dev_tools/test_blast_radius_generic_contracts.py
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py
tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py
tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py
```

The remaining 45 paths are under `FEATURE/`.
