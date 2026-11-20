# [P6-T3] Pester and coverage QA gate (issue #1022)

Timestamp: 2026-11-04T03-04
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t6-pester-baseline.ps1 -WorktreeRoot <item worktree> (new PowerShell process; imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <item worktree> -ScanFolders @('tests/scripts') single-process with coverage from scripts/powershell/PoshQC/settings/pester.runsettings.psd1; run log SCRATCH/issue-1022-p6t3-run.log, ANSI-stripped copy SCRATCH/issue-1022-p6t3-run.clean.log; started 2026-11-04T02-39, tests completed in 1360.7 s)
EXIT_CODE: 255
Output Summary: Discovery found 14433 tests (baseline 14108; +325 from the 1022 suites). Pester summary: Tests Passed: 14014, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0; BeforeAll \ AfterAll failed: 6. Every suite under tests/scripts/claude-lib/docs (31 files, including all 19 new 1022 suites) reports 0 failed and 0 errored. The sorted failing-test list (97 lines: 91 tests in 19 suites plus the 6 container failures) is byte-identical to the [P0-T6] baseline list (`diff` exit 0): no new failure. Overall line coverage 93.33% (24348 covered / 26088 lines, JaCoCo root LINE counter of artifacts/pester/powershell-coverage.xml, 287 files measured; baseline 92.66%). The non-zero exit code is Run.Exit = $true on a run with the pre-existing host-only failures owned by #1066/#1067.

## Count source

`artifacts/pester/pester-junit.xml` is truncated again by the same pre-existing defect recorded in the [P0-T6] baseline: Pester 5.9.1 `Export-XmlReport` stops at an ESC character (0x1B) in the failure message of `tests/scripts/dev-tools/activate.Tests.ps1` (`wraps the venv-active form in green when the background is dark`), so the file holds 44 `testcase` elements. Its header attributes, written before the failure, read `tests="14433" errors="6" failures="409" disabled="10"` and agree with the Pester summary. Passed, failed and skipped counts and the failing-test list therefore come from the Pester summary and the Normal-verbosity run log of the same run (parsed by `SCRATCH/issue-1022-pester-log-failures.ps1`, output `SCRATCH/issue-1022-p6t3-failing.txt`); the coverage file is complete.

## Counts

| Metric | This run | [P0-T6] baseline |
|---|---|---|
| Discovered tests | 14433 | 14108 |
| Passed | 14014 | 13689 |
| Failed | 409 | 409 |
| Skipped | 10 | 10 |
| Containers failed in `BeforeAll`/`AfterAll` | 6 | 6 |
| Failing-test list lines | 97 (identical) | 97 |
| Overall line coverage | 93.33% (24348 / 26088) | 92.66% (21914 / 23651) |
| Coverage files measured | 287 | 269 |

## Failed tests absent from the baseline list

None.

## tests/scripts/claude-lib/docs suites

All 31 suite files completed with no failed test (`[+]` file lines, zero `[-]` test lines under the folder, zero failing-list entries): the 1020 suites plus `DocsSourceText`, `DocsPythonTokens`, `DocsPythonSyntax`, `DocsPythonBindings`, `DocsTomlKeys`, `DocsYamlKeys`, `DocsJsonSchemaKeys`, `DocsPythonCliArgparse`, `DocsPythonCliClick`, `DocsPythonCliTyper`, `DocsAnalyzerPythonCli`, `DocsPythonHttpSites`, `DocsAnalyzerPythonHttp`, `DocsAnalyzerPythonApi`, `DocsAnalyzerArchitecture`, `DocsAnalyzerConfigFiles`, `DocsInventorySnapshot`, `DocsInventory` and `DocsInventoryProperties` (`.Tests.ps1`).

CI: `poshqc / PowerShell QC` (windows-latest shards), where the full set reports 0 failed.
