# CI Pester Per-File Coverage (S32, U23)

Timestamp: 2026-11-04T03-06
Command: gh run download 41763299050 --repo drmoisan/drm-copilot -n poshqc-test-results -D SCRATCH/ci-poshqc; per-file LINE counters read from SCRATCH/ci-poshqc/powershell-coverage.xml with a PowerShell 7 XML read
EXIT_CODE: 0
Output Summary: CI run 41763299050 (workflow CI, event pull_request, PR #1071, head 46c8b8514740bf59e3da6d354a6ad265d671bc22, conclusion success). The `poshqc-test-results` artifact is the merged shard coverage written by the `poshqc / PowerShell QC` aggregator from the `windows-latest` shard jobs. Every new production file is at or above 85% line coverage; lowest is DocsEvidencePins.psm1 at 96.84%. No production file is excluded.

Run: https://github.com/drmoisan/drm-copilot/actions/runs/41763299050

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` | 167 | 2 | 98.82% |
| `.claude/lib/docs/DocsLedgerRules.psm1` | 93 | 1 | 98.94% |
| `.claude/lib/docs/DocsEvidencePins.psm1` | 92 | 3 | 96.84% |
| `.claude/lib/docs/DocsStaleness.psm1` | 46 | 0 | 100.00% |
| `.claude/lib/docs/DocsParity.psm1` | 183 | 2 | 98.92% |
| `.claude/lib/docs/DocsReceipt.psm1` | 95 | 0 | 100.00% |
| `.claude/lib/docs/DocsLedgerMutation.psm1` | 59 | 1 | 98.33% |
| `.claude/lib/docs/DocsValidation.psm1` | 154 | 2 | 98.72% |
| `.claude/lib/docs/DocsCoverageReport.psm1` | 77 | 0 | 100.00% |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | 343 | 3 | 99.13% |

This record also resolves review finding F1 (the local coverage artifact was overwritten after the recorded run): the figures above are read from the CI report, which the spec names as the source for S32.
