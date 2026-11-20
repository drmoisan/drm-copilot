# Final QC: Pester Parallel Gate

Timestamp: 2026-11-14T14-14
Command: sh SCRATCH/issue-1182-pester.sh final (pwsh: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <worktree>; exit $r.ExitCode), one run against the committed head
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest ExitCode 0; 8 workers; wall clock 1205.47 s; run window 2026-11-14T14-14 to 2026-11-14T14-34 (UTC).
- Counts from the merged artifacts/pester/pester-junit.xml: tests 25398, passed 25382, failed 0, errors 0, skipped 16. Zero failures.
- Repo-wide line coverage from the merged artifacts/pester/powershell-coverage.xml: 96.03% (42206/43950). Phase 0 baseline: 96.02% (42083/43827). No drop.
- Per-file line coverage is recorded in the coverage-comparison artifact written with this one (coverage-comparison.<timestamp>.md, same folder).
