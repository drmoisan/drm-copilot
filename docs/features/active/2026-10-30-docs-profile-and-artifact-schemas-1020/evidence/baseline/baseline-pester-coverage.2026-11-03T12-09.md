# Pester and Coverage Baseline ([P0-T6])

Timestamp: 2026-11-03T12-09
Command: sh SCRATCH/issue-1020-test.sh tests/scripts (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts'; counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1020-summary.ps1)
EXIT_CODE: 0
Output Summary: tests=13723, failures=0, errors=0, skipped=10 (488 suites, one process, CI shape). Overall line coverage 93.62% (21250 covered, 1448 missed). No file under .claude/lib/docs/ exists at baseline.

## Counts (artifacts/pester/pester-junit.xml)

- tests: 13723
- failures: 0
- errors: 0
- skipped: 10 (the root `disabled` attribute also reads 10)
- Failing tests: none

## Coverage (artifacts/pester/powershell-coverage.xml)

- Overall line coverage: 93.62% (covered 21250, missed 1448)
- New-code baseline: not present (no file under `.claude/lib/docs/` exists at baseline, so no per-file figure is reported for it).

Note: the first summarizer pass of the run exited 1 because it read a `tests` property under strict mode without the attribute accessor; the reports produced by the completed run were then read by the corrected summarizer without re-running Pester. The run wall time was about 19 minutes.

CI: `poshqc / PowerShell QC` (windows-latest).
