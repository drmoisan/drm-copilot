# Batch Accounting (P18-T2)

Timestamp: 2026-09-27T18-16
Command: git log --reverse --format="=== %h %s" --name-only beae3f021674e64fa6662097fe48a332d8da62b8..HEAD -- <code paths> ; review of the batch reset and boundary artifacts under FEATURE/evidence/other and the per-phase static artifacts
EXIT_CODE: 0
Output Summary: PASS. No batch lists more than 3 production or 3 test files of one language. The largest batches are Python P8 (3 production, 1 test), Python P3 (0 production, 3 test), PowerShell P5 first half (3 production, 3 test), PowerShell P10 first half (3 production, 2 test), and TypeScript P4 batch one and P11 batch one (1 production, 3 test each). Bundled mirrors were produced by script copy-file (A10) and are not authored files; configuration JSON, fixtures, and Markdown are not language batches.

## Derivation

Files per batch are taken from the phase commits (the git log above, which lists the code files each
phase commit changed), assigned to batches by the plan task that names each file (the backticked paths
of Phases 1 to 12) and by the reset or boundary artifact that opened each batch. Formatter-only
rewrites made by the PoshQC MCP format call are recorded separately because they were not authored by
a write or edit of the file.

## Python batches

| Batch | Opened by | Authored production files | Authored test files | Prod / Test |
| --- | --- | --- | --- | --- |
| P1 | other/batch-budget-reset-p1.2026-09-27T15-02.md | scripts/dev_tools/_blast_radius_scheduling.py (P1-T10); scripts/dev_tools/compute_blast_radius.py (P1-T11) | tests/scripts/dev_tools/test_blast_radius_scheduling.py (P1-T7); tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py (P1-T8) | 2 / 2 |
| P2 | other/batch-budget-reset-p2.2026-09-27T15-19.md | scripts/dev_tools/_parallel_drift_scheduling.py (P2-T5); scripts/dev_tools/parallel_drift_detection.py (P2-T6) | tests/scripts/dev_tools/test_parallel_drift_scheduling.py (P2-T2, P2-T8); tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py (P2-T3) | 2 / 2 |
| P3 | other/batch-budget-reset-p3.2026-09-27T15-26.md | none | tests/scripts/dev_tools/blast_radius_parity_test_support.py (P3-T4); tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py (P3-T5); tests/scripts/dev_tools/test_blast_radius_historical_runs.py (P3-T9) | 0 / 3 |
| P8 | other/batch-budget-reset-p8.2026-09-27T16-55.md | scripts/dev_tools/_blast_radius_write_intent.py (P8-T5); scripts/dev_tools/compute_blast_radius.py (P8-T6); scripts/dev_tools/_blast_radius_validation.py (P8-T7) | tests/scripts/dev_tools/test_blast_radius_write_intent.py (P8-T3) | 3 / 1 |
| P9 first half | other/batch-budget-reset-p9.2026-09-27T17-03.md | none | tests/scripts/dev_tools/blast_radius_parity_test_support.py (P9-T5); tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py (P9-T6) | 0 / 2 |
| P9 second half | other/batch-budget-reset-p9b.2026-09-27T17-05.md | none | tests/scripts/dev_tools/test_blast_radius_mandate_reads.py (P9-T8); tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py (P9-T9) | 0 / 2 |
| P12 Python | other/batch-budget-reset-p12a.2026-09-27T17-41.md | none | tests/scripts/dev_tools/test_blast_radius_historical_runs.py (P12-T5) | 0 / 1 |

## PowerShell batches

| Batch | Opened by | Authored production files | Authored test files | Prod / Test |
| --- | --- | --- | --- | --- |
| P5 first half | other/batch-budget-reset-p5.2026-09-27T15-39.md (P5-T1) | .claude/lib/blast-radius/BlastRadiusScheduling.psm1 (P5-T5); .claude/lib/blast-radius/BlastRadius.psm1 (P5-T6); scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (P5-T7) | tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (P5-T2); tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (P5-T3); tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 (P5-T4) | 3 / 3 |
| P5 second half | other/batch-budget-reset-p5b.2026-09-27T16-28.md (P5-T11) | none | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 (P5-T12) | 0 / 1 |
| P10 first half | other/batch-budget-reset-p10a.2026-09-27T17-09.md | .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 (P10-T4); .claude/lib/blast-radius/BlastRadius.psm1 (P10-T5); .claude/lib/blast-radius/BlastRadiusValidation.psm1 (P10-T6) | tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 (P10-T2); tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 (P10-T3) | 3 / 2 |
| P10 second half | other/batch-budget-reset-p10b.2026-09-27T17-14.md (P10-T8) | scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (P10-T9, the self-hosted runsettings file) | tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 (P10-T10); tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 (P10-T13 analyzer fix: one heading literal changed to ASCII, recorded in qa-gates/phase10-powershell-static.2026-09-27T17-23.md) | 1 / 2 |
| P12 PowerShell | other/batch-budget-reset-p12b.2026-09-27T17-41.md | none | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (P12-T6) | 0 / 1 |

Formatter-only rewrite (not authored): during the P5 static loop the PoshQC MCP format call re-aligned
the "=" column of one hashtable literal in tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
(six lines, whitespace only; qa-gates/phase5-powershell-static.2026-09-27T16-37.md). It is carried by
the P5 second-half commit. Counted as an authored test file, the P5 second half would hold 0 / 2, still
within the budget.

Bundled mirrors (the four modules under extensions/drm-copilot/resources/claude-customizations and the
bundled runsettings file) were produced by script copy-file (A10) and are not authored files.

## TypeScript batches

No TypeScript batch-budget hook exists (the boundary artifacts record that the hooks directory carries
only the PowerShell and Python batch-budget hooks), so batch one of each phase opens at the phase start
and batch two opens at the recorded boundary.

| Batch | Opened by | Authored production files | Authored test files | Prod / Test |
| --- | --- | --- | --- | --- |
| P4 batch one | Phase 4 start (P4-T1) | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts (P4-T1) | extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts (P4-T2); extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts (P4-T3); extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts (P4-T4) | 1 / 3 |
| P4 batch two | other/batch-boundary-ts-p4b.2026-09-27T15-35.md | none | extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts (P4-T6); extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts (P4-T7) | 0 / 2 |
| P11 batch one | Phase 11 start (P11-T1) | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts (P11-T1) | extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts (P11-T2); extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts (P11-T3); extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts (P11-T3) | 1 / 3 |
| P11 batch two | other/batch-boundary-ts-p11b.2026-09-27T17-27.md | none | extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts (P11-T5) | 0 / 1 |

## Phase commits (code files only)

```text
2b51830c P1  _blast_radius_scheduling.py, compute_blast_radius.py, test_blast_radius_scheduling.py, test_blast_radius_scheduling_properties.py
fd441765 P2  _parallel_drift_scheduling.py, parallel_drift_detection.py, test_parallel_drift_scheduling.py, test_validate_parallel_state_tolerated_edge_fields.py
6eedbdfd P3  blast_radius_parity_test_support.py, test_blast_radius_config_tolerance_keys.py, test_blast_radius_historical_runs.py
3d3abde2 P4  claude-blast-radius-derive-core.ts and the five TypeScript test files of P4
b52a00b1 P5a BlastRadius.psm1, BlastRadiusScheduling.psm1, pester.runsettings.psd1, HistoricalRuns/KeyPartition/Scheduling Tests.ps1
b227f21e P5b BlastRadius.Tests.ps1, BlastRadiusScheduling.Tests.ps1 (formatter-only)
fcd273df P8  _blast_radius_validation.py, _blast_radius_write_intent.py, compute_blast_radius.py, test_blast_radius_write_intent.py
efe67863 P9  blast_radius_parity_test_support.py, test_blast_radius_config_tolerance_keys.py, test_blast_radius_mandate_reads.py, test_blast_radius_mergeable_paths.py
db6b25f4 P10 BlastRadius.psm1, BlastRadiusValidation.psm1, BlastRadiusWriteIntent.psm1, pester.runsettings.psd1, KeyPartition/BlastRadius/WriteIntent Tests.ps1
6f81b876 P11 claude-blast-radius-derive-core.ts and the four TypeScript test files of P11
5ee710b3 P12 BlastRadius.HistoricalRuns.Tests.ps1, test_blast_radius_historical_runs.py
```

Result: every batch holds at most 3 production and at most 3 test files of one language.
