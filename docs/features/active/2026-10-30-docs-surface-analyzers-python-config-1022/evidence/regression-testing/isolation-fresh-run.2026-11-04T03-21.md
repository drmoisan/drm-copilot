# [P6-T6] Fresh single-process Pester run without coverage (issue #1022)

Timestamp: 2026-11-04T03-21
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p6t6-fresh-run.ps1 -WorktreeRoot <item worktree> (new PowerShell process; imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <item worktree> -ScanFolders @('tests/scripts') single-process, with the -LoadSettings seam loading scripts/powershell/PoshQC/settings/pester.runsettings.psd1 and setting CodeCoverage.Enabled to $false; run log SCRATCH/issue-1022-p6t6-run.log, ANSI-stripped copy SCRATCH/issue-1022-p6t6-run.clean.log; started 2026-11-04T03-11, tests completed in 594.28 s)
EXIT_CODE: 255
Output Summary: Discovery found 14433 tests. Pester summary: Tests Passed: 14014, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0; BeforeAll \ AfterAll failed: 6. No top-level `Code coverage population` line was logged (coverage disabled; the four `source=settings; files=1` lines come from nested runs inside the PoshQC suites). Every suite under tests/scripts/claude-lib/docs (31 files) reports 0 failed and 0 errored. The sorted failing-test list (97 lines) is byte-identical to the [P0-T6] baseline list (`diff` exit 0): no new failure. The non-zero exit code is Run.Exit = $true on a run with the pre-existing host-only failures owned by #1066/#1067.

## Count source

`artifacts/pester/pester-junit.xml` is truncated by the pre-existing ESC (0x1B) defect recorded in [P0-T6] and [P6-T3] (Pester 5.9.1 `Export-XmlReport` stops in the `activate.Tests.ps1` failure message `wraps the venv-active form in green when the background is dark`; 44 `testcase` elements written). Its header attributes read `tests="14433" errors="6" failures="409" disabled="10"` and agree with the Pester summary. Counts and the failing-test list therefore come from the Pester summary and the Normal-verbosity run log of the same run (parsed by `SCRATCH/issue-1022-pester-log-failures.ps1`, output `SCRATCH/issue-1022-p6t6-failing.txt`).

## Counts

| Metric | This run | [P0-T6] baseline |
|---|---|---|
| Discovered tests | 14433 | 14108 |
| Passed | 14014 | 13689 |
| Failed | 409 | 409 |
| Skipped | 10 | 10 |
| Containers failed in `BeforeAll`/`AfterAll` | 6 | 6 |
| Failing-test list lines | 97 (identical) | 97 |
| tests/scripts/claude-lib/docs suite files with a failed test | 0 of 31 | 0 |

## Failed tests absent from the baseline list

None.
