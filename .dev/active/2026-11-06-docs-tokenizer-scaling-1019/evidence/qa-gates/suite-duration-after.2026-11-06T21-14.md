# Suite Duration and Coverage After Remediation Cycle 1 - Issue 1019

Timestamp: 2026-11-06T21-14
Command: sh SCRATCH/issue-1019-rc1-p2-t5.sh (SCRATCH/issue-1019-p2-t3.ps1 -Root <worktree> -Base MERGE_BASE: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs; counts and file time from artifacts/pester/pester-junit.xml; coverage from artifacts/pester/powershell-coverage.xml; changed lines from git diff --unified=0 MERGE_BASE -- .claude/lib/docs/DocsPythonTokens.psm1)
EXIT_CODE: 0
Output Summary: The folder run reported 2050 tests, failures 0, errors 0, skipped 0. SUITE ran 57 tests with 0 failures. MODULE line coverage 100% (151 of 151), baseline 98.44% at MERGE_BASE, changed-line coverage 100% (29 of 29 measurable lines). The 85% floor holds. Final MODULE hash 015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702. MERGE_BASE c4a2398aa93c721e06f6878851526d4338ec98c7.

## Counts

| Scope | Tests | Failures | Errors | Skipped |
| --- | --- | --- | --- | --- |
| Folder `tests/scripts/claude-lib/docs`, JUnit, 98 suites | 2050 | 0 | 0 | 0 |

| Suite | Tests | Failures | Time (s) |
| --- | --- | --- | --- |
| `DocsPythonTokens.Tests.ps1` (`SUITE`) | 57 | 0 | 46.752 |
| `DocsPythonSyntax.Tests.ps1` | 35 | 0 | 3.263 |
| `DocsPythonBindings.Tests.ps1` | 20 | 0 | 3.220 |
| `DocsPythonHttpSites.Tests.ps1` | 15 | 0 | 2.339 |
| `DocsPythonCliArgparse.Tests.ps1` | 12 | 0 | 1.916 |
| `DocsPythonCliClick.Tests.ps1` | 12 | 0 | 0.764 |
| `DocsPythonCliTyper.Tests.ps1` | 13 | 0 | 0.868 |

## Coverage of `MODULE`

| Measure | Covered | Missed | Percent |
| --- | --- | --- | --- |
| Baseline at `MERGE_BASE`, token-limit test excluded, from `evidence/baseline/pester-coverage-before.2026-11-06T18-01.md` | 126 | 2 | 98.44 |
| Cycle baseline at `PRIOR HASH`, from `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md` | 151 | 0 | 100 |
| Post-change line coverage, all tests | 151 | 0 | 100 |
| Changed-line coverage against `MERGE_BASE` | 29 | 0 | 100 |

The diff against `MERGE_BASE` touches 44 lines of `MODULE`, of which 29 appear in the coverage report as executable. No uncovered line was reported. The executable count is unchanged from the cycle baseline, as expected for comment edits.

## Durations

The before and after duration table is in `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md` (`## Before and After Durations`). This cycle measured `SUITE` at 23.32 s without coverage (`evidence/regression-testing/suite-on-fixed.2026-11-06T20-59.md`) and 46.752 s in the folder run with coverage. The folder run took 498.09 s for the tests and 583.95 s of wall time.

## Repo-Wide Figures

The figure this run prints, 31.61% over 338 files, reflects that only one test folder ran and is not a measure of `MODULE`. Repo-wide figures come from the merged CI artifact at S9.
