# Coverage Delta: baseline [P0-T6] against final [P7-T3] ([P7-T4])

Timestamp: 2026-11-04T01-51
Command: comparison of the LINE counters recorded in evidence/baseline/baseline-pester-coverage.2026-11-03T22-10.md (baseline, artifacts/pester/powershell-coverage.xml of the [P0-T6] run) and evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md (post-change, artifacts/pester/powershell-coverage.xml of the [P7-T3] run), both read by SCRATCH/issue-1023-pester-summary.ps1
EXIT_CODE: 0
Output Summary: PASS. Every new LIB file is at or above the 85 line-coverage floor (lowest DocsEvidencePins.psm1 96.84; highest 100). Invoke-DocsCommand.ps1 rose from 87.33 to 87.58 and its three new rows are covered. No 1020 file regressed (nine files unchanged at their baseline figures). Total line coverage rose from 92.66 (269 files) to 92.99 (279 files). Pester measures no branch coverage, so no branch gate applies.

## New LIB files (new-code coverage; floor 85)

| File | Baseline | Post-change | Floor | Result |
|---|---|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` | not present | 98.82 | 85 | PASS |
| `.claude/lib/docs/DocsLedgerRules.psm1` | not present | 98.94 | 85 | PASS |
| `.claude/lib/docs/DocsEvidencePins.psm1` | not present | 96.84 | 85 | PASS |
| `.claude/lib/docs/DocsStaleness.psm1` | not present | 100 | 85 | PASS |
| `.claude/lib/docs/DocsParity.psm1` | not present | 98.92 | 85 | PASS |
| `.claude/lib/docs/DocsReceipt.psm1` | not present | 100 | 85 | PASS |
| `.claude/lib/docs/DocsLedgerMutation.psm1` | not present | 98.33 | 85 | PASS |
| `.claude/lib/docs/DocsValidation.psm1` | not present | 98.72 | 85 | PASS |
| `.claude/lib/docs/DocsCoverageReport.psm1` | not present | 100 | 85 | PASS |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | not present | 99.13 | 85 | PASS |

## Edited entry script (no-regression; changed lines covered)

| File | Baseline | Post-change | Change | Result |
|---|---|---|---|---|
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 87.33 (131/150) | 87.58 (134/153) | +0.25; the 3 added lines are the 3 new covered lines (hit counts 7, 21, 10; 0 missed); the 19 missed lines are unchanged | PASS |

## 1020 files (no-regression)

| File | Baseline | Post-change | Result |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsFinding.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsJson.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsProfile.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 97.1 | 97.1 | unchanged |
| `.claude/lib/docs/DocsSchema.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 100 | 100 | unchanged |
| `.claude/lib/docs/DocsSurface.psm1` | 100 | 100 | unchanged |

## Total

| Scope | Baseline | Post-change |
|---|---|---|
| All files in the coverage population | 92.66 (21914/23651, 269 files) | 92.99 (23226/24977, 279 files) |

Branch coverage: not measured by Pester; no branch gate applies to PowerShell. No production file is excluded from measurement (`config/poshqc-coverage.json` unchanged).

CI proof of the same figures: `poshqc / PowerShell QC` (`windows-latest`), which merges the shard coverage; S32 and U23 cite that job and stay pending-CI until its report is read on the PR head.
