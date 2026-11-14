# Full-Suite Pester and Coverage (issue #1001, remediation cycle 1, finding F1)

Timestamp: 2026-10-31T07-21
Command: sh SCRATCH/issue-1001-fullrun.sh (runs SCRATCH/issue-1001-full.ps1 through SCRATCH/issue-1001-run.sh under PowerShell 7; imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts with the default coverage population derived from config/poshqc-coverage.json, 256 files; copies artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml to SCRATCH)
EXIT_CODE: 0

Run window (UTC, from the run log): start 2026-10-31T07-03-57, finish 2026-10-31T07-20-34. The coverage report header carries the generation time 2026-10-31 07:17:22, later than the run start.

## JUnit totals (read from artifacts/pester/pester-junit.xml)

- tests: 13518
- failures: 0
- errors: 0
- skipped: 10
- suites: 478

The Pester console summary for the same run reads: Passed 13508, Failed 0, Skipped 10, Inconclusive 0, NotRun 0.

## Repo-wide line coverage (report-level LINE counter in artifacts/pester/powershell-coverage.xml)

- covered: 20871
- missed: 1444
- total: 22315
- percent: 93.53

The Pester console reports a command-level figure of 92.74 percent over 256 files; the gate figure is the LINE counter above.

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

| File | Covered | Missed | Percent |
|---|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 132 | 0 | 100.00 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 29 | 2 | 93.55 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 81 | 3 | 96.43 |

## Gate evaluation (P1-T4)

- JUnit failures and errors: 0 and 0 (required 0).
- Repo-wide line percent: 93.53 (required at least 85).
- enforce-epic-merge-gate.ps1: 100.00 (required at least 85; expected 100.00).
- enforce-pr-author-skill.epic-base-branch.ps1: 93.55 (required at least 85; expected 93.55 or higher).
- enforce-model-routing-receipt.ps1: 96.43 (required at least 85; expected 96.43 or higher).

Gate: PASS

Output Summary:
- Full tests/scripts Pester run with coverage: 13518 tests, 0 failures, 0 errors, 10 skipped (478 suites).
- Repo-wide PowerShell line coverage: 93.53 percent (20871 covered, 1444 missed of 22315 lines), above the 85 percent threshold. No branch gate applies to PowerShell.
- The three hooks are unchanged from the claude-hooks-scoped run: 100.00, 93.55, 96.43 percent.
- artifacts/pester/powershell-coverage.xml is left in place as the full-suite artifact for re-review.
