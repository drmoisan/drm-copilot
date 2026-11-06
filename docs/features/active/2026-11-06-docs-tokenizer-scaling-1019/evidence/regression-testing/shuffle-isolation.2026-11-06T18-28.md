# Shuffled File-Order Isolation - Issue 1019

Timestamp: 2026-11-06T18-28
Command: pwsh -NoProfile -File SCRATCH/issue-1019-shuffle.ps1 -Root <worktree> -Seed <seed>, one process per seed, for seeds 11, 42, and 1019 (Fisher-Yates over the seven suite names with System.Random(seed); Pester 6.2.0; counts from the result object)
EXIT_CODE: 0
Output Summary: Each seed passed 163 tests with failed 0, skipped 0, and not-run 0. For each seed, the executed container order equals the requested order. MODULE hash 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf.

| Seed | Passed | Failed | Skipped | Not run | Seconds |
| --- | --- | --- | --- | --- | --- |
| 11 | 163 | 0 | 0 | 0 | 68.53 |
| 42 | 163 | 0 | 0 | 0 | 69.63 |
| 1019 | 163 | 0 | 0 | 0 | 67.6 |

## File Orders

Each suite name below carries the suffix `.Tests.ps1`.

| Seed | Executed file order |
| --- | --- |
| 11 | `DocsPythonSyntax`, `DocsPythonCliArgparse`, `DocsPythonCliClick`, `DocsPythonCliTyper`, `DocsPythonBindings`, `DocsPythonTokens`, `DocsPythonHttpSites` |
| 42 | `DocsPythonSyntax`, `DocsPythonHttpSites`, `DocsPythonCliTyper`, `DocsPythonBindings`, `DocsPythonCliClick`, `DocsPythonTokens`, `DocsPythonCliArgparse` |
| 1019 | `DocsPythonSyntax`, `DocsPythonBindings`, `DocsPythonHttpSites`, `DocsPythonCliClick`, `DocsPythonCliTyper`, `DocsPythonCliArgparse`, `DocsPythonTokens` |

These runs shared the host with the differential processes of [P2-T6], so the seconds column is not a duration measurement. All three orders happen to start with `DocsPythonSyntax`, so no seed ran another suite ahead of it. `DocsPythonTokens` runs sixth for seeds 11 and 42, with one suite after it, and last for seed 1019.
