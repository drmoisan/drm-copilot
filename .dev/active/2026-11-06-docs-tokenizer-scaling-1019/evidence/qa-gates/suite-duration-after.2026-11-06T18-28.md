# Suite Duration and Coverage After the Fix - Issue 1019

Timestamp: 2026-11-06T18-28
Command: sh SCRATCH/issue-1019-p2-t3.sh (SCRATCH/issue-1019-fullsuite.ps1 -Root <worktree>, then SCRATCH/issue-1019-p2-t3.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs; counts and file time from artifacts/pester/pester-junit.xml; coverage from artifacts/pester/powershell-coverage.xml; changed lines from git diff --unified=0 MERGE_BASE -- .claude/lib/docs/DocsPythonTokens.psm1)
EXIT_CODE: 0
Output Summary: SUITE ran 56 tests with 0 failures in 27.07 s without coverage. The folder run reported 2049 tests, failures 0, errors 0, skipped 0. MODULE line coverage 100% (151 of 151), baseline 98.44%, changed-line coverage 100% (29 of 29 measurable lines). The 85% floor holds. MODULE hash 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf. MERGE_BASE c4a2398aa93c721e06f6878851526d4338ec98c7.

## Before and After Durations

| Run | Module | Coverage | Duration | Label |
| --- | --- | --- | --- | --- |
| Full `SUITE` on this host, 600 s bound | unfixed | no | did not finish; lower bound 600 s (exit 124) | measured lower bound |
| Token-limit test alone | unfixed | no | about 49,530 s | extrapolated from 1,000 tokens at 47.236 ms |
| Full `SUITE` as reported by the 1034 work | unfixed | not established | 43342.74 s | unverified 1034 figure, not reproduced here |
| Full `SUITE`, `issue-1019-fullsuite.ps1` | fixed | no | 27.07 s | measured |
| `SUITE` file time in the folder run, from JUnit | fixed | yes | 46.832 s | measured |

The before figures are in `evidence/qa-gates/suite-duration-before.2026-11-06T17-49.md`. Absolute times are specific to this host.

## Counts

| Scope | Tests | Failures | Errors | Skipped |
| --- | --- | --- | --- | --- |
| `SUITE`, result object, no coverage | 56 passed | 0 | not applicable | 0, not-run 0 |
| Folder `tests/scripts/claude-lib/docs`, JUnit, 98 suites | 2049 | 0 | 0 | 0 |
| `SUITE`, JUnit | 56 | 0 | 0 | 0 |

The folder run also holds the `CONSUMER SUITES`:

| Suite | Tests | Failures | Time (s) |
| --- | --- | --- | --- |
| `DocsPythonSyntax.Tests.ps1` | 35 | 0 | 3.486 |
| `DocsPythonBindings.Tests.ps1` | 20 | 0 | 3.065 |
| `DocsPythonHttpSites.Tests.ps1` | 15 | 0 | 2.201 |
| `DocsPythonCliArgparse.Tests.ps1` | 12 | 0 | 2.048 |
| `DocsPythonCliClick.Tests.ps1` | 12 | 0 | 0.753 |
| `DocsPythonCliTyper.Tests.ps1` | 13 | 0 | 0.945 |

## Coverage of `MODULE`

| Measure | Covered | Missed | Percent |
| --- | --- | --- | --- |
| Baseline line coverage, token-limit test excluded | 126 | 2 | 98.44 |
| Post-change line coverage, all tests | 151 | 0 | 100 |
| Changed-line coverage against `MERGE_BASE` | 29 | 0 | 100 |

The diff adds or changes 38 lines of `MODULE`. Of these, 29 appear in the coverage report as executable; the other 9 are five comment lines and four lines holding only a closing brace or `} else {`. The baseline excludes the token-limit test, so it understates full-suite coverage by the two lines only that test reaches; the change from 98.44 to 100 therefore combines those two lines with the added lines.

## Run Conditions

The folder run reported 519.96 s for the tests and took 638.96 s of wall time including coverage processing. The whole-population figure that run prints, 31.61% over 338 files, reflects that only one test folder ran; it is not a measure of `MODULE`. [P2-T4] to [P2-T6] started at 2026-11-06T18:24:48Z, which is after the test phase and during coverage processing, so they overlapped no reported test time. The no-coverage full-suite run finished before that start as well.
