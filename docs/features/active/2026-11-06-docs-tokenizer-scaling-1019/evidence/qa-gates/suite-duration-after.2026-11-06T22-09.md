# Suite Duration and Coverage After Remediation Cycle 2 - Issue 1019

Timestamp: 2026-11-06T22-09
Command: sh SCRATCH/issue-1019-rc1-p2-t5.sh (SCRATCH/issue-1019-p2-t3.ps1 -Root WORKTREE -Base MERGE_BASE: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root WORKTREE -ScanFolders tests/scripts/claude-lib/docs; counts and file time from artifacts/pester/pester-junit.xml; coverage from artifacts/pester/powershell-coverage.xml; changed lines from git diff --unified=0 MERGE_BASE -- .claude/lib/docs/DocsPythonTokens.psm1)
EXIT_CODE: 0
Output Summary: The folder run reported 2051 tests, failures 0, errors 0, skipped 0, read from JUnit. SUITE ran 58 tests with 0 failures. MODULE line coverage 100% (151 of 151), baseline 98.44% at MERGE_BASE, changed-line coverage 100% (29 of 29 measurable lines). The 85% floor holds. MERGE_BASE 8fa914935e3efec81d1e970bc525d907a9458203.

## Counts

| Scope | Tests | Failures | Errors | Skipped |
| --- | --- | --- | --- | --- |
| Folder `tests/scripts/claude-lib/docs`, JUnit, 98 suites | 2051 | 0 | 0 | 0 |

| Suite | Tests | Failures | Time (s) |
| --- | --- | --- | --- |
| `DocsPythonTokens.Tests.ps1` (`SUITE`) | 58 | 0 | 57.594 |
| `DocsPythonSyntax.Tests.ps1` | 35 | 0 | 4.011 |
| `DocsPythonBindings.Tests.ps1` | 20 | 0 | 3.750 |
| `DocsPythonHttpSites.Tests.ps1` | 15 | 0 | 2.755 |
| `DocsPythonCliArgparse.Tests.ps1` | 12 | 0 | 2.276 |
| `DocsPythonCliClick.Tests.ps1` | 12 | 0 | 0.901 |
| `DocsPythonCliTyper.Tests.ps1` | 13 | 0 | 1.218 |

## Coverage of `MODULE`

| Measure | Covered | Missed | Percent |
| --- | --- | --- | --- |
| Baseline at `MERGE_BASE`, token-limit test excluded, from `evidence/baseline/pester-coverage-before.2026-11-06T18-01.md` | 126 | 2 | 98.44 |
| Post-change line coverage, all tests | 151 | 0 | 100 |
| Changed-line coverage against `MERGE_BASE` | 29 | 0 | 100 |

The baseline figure was measured against an earlier merge base. `git diff --stat` of `MODULE` between that base and the current `MERGE_BASE` is empty, so the figure is the baseline at the current `MERGE_BASE` as well. The diff against `MERGE_BASE` touches 44 lines of `MODULE`, of which 29 appear in the coverage report as executable. No uncovered line was reported.

## Durations

The before and after duration table is in `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md` (`## Before and After Durations`). This cycle measured `SUITE` at 22.46 s without coverage (`evidence/regression-testing/suite-on-fixed.2026-11-06T21-57.md`) and 57.594 s in the folder run with coverage. The folder run took 581.71 s for the tests and 673.9 s of wall time.

## Repo-Wide Figures

The figure this run prints, 31.31% over 340 files, reflects that only one test folder ran and is not a measure of `MODULE`. Repo-wide figures come from the merged CI artifact at S9.
