# Baseline — Self-Hosted PoshQC Test Invocation (tests/scripts/claude-lib)

Timestamp: 2026-09-17T07:59:32-04:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib') ; Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml -Force
EXIT_CODE: 0
Output Summary: Tests Passed: 1384, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 (failed count = 0). Scoped-run LINE coverage (report counter): covered=3002, missed=6334, percentage=32.16 (the run executes only the claude-lib suites against the repository-wide CodeCoverage.Path denominator). The two new module paths (.claude/lib/worktree-resolution/WorktreeResolution.psm1 and WorktreeTargetResolution.psm1) produce zero rows at baseline because they do not yet exist: 0 packages whose name ends with worktree-resolution, 0 sourcefile rows for either file name. The session was not terminated.

## Summary lines as printed (verbatim, ANSI colour codes removed)

```text
Starting discovery in 49 files.
Discovery found 1384 tests in 2.19s.
Starting code coverage.
Running tests.
...
Tests completed in 47.04s
Tests Passed: 1384, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 32.77% / 0%. 12,928 analyzed Commands in 101 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c\artifacts\pester\powershell-coverage.koverage.xml
```

Failed count (from the `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}` line): **0**

## Observation on the replay block

The replay header `Pester summary (replayed for readability):` (`PoshQC.Testing.psm1:454`) did not appear in
the 61-line output. The `Tests completed in` and `Tests Passed: ...` lines above are the ones Pester prints
itself; they use the same format as the lines `PoshQC.Testing.psm1:422-428` composes. The replay block runs
only when `$pesterResult` is truthy. A likely cause (not confirmed) is that the `-not $config.Run.PassThru`
guard at `PoshQC.Testing.psm1:325` evaluates a non-null `PesterConfiguration` option object, so the guard
never sets `PassThru` and `Invoke-Pester` returns nothing. This is pre-existing behaviour outside this
feature's scope. The failed count above comes from the Pester-printed line.

## Scoped-run line coverage (evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml)

Report-level counter (verbatim): `<counter type="LINE" missed="6334" covered="3002" />`

- covered lines: 3002
- missed lines: 6334
- percentage: 32.16

New-module rows at baseline: `WorktreeResolution.psm1` = 0 rows, `WorktreeTargetResolution.psm1` = 0 rows
(no `package` element whose `name` ends with `worktree-resolution` exists).
