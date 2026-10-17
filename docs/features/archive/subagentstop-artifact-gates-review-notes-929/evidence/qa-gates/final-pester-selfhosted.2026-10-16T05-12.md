# Final Self-Hosted PoshQC Test (P9-T4, QA loop pass 1)

Timestamp: 2026-10-16T05-12

Command: sh SCRATCH/929/P9-T4-1.sh
Script: `'RUN_START_UTC=' + [DateTime]::UtcNow.ToString('o'); Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/claude-runtime')`
EXIT_CODE: 0
Output (selected lines; ANSI color codes stripped; per-container progress lines carry host paths and are omitted):
```
RUN_START_UTC=2026-10-16T04:52:46.6652814Z
Code coverage population: source=config; files=203
Starting discovery in 168 files.
Discovery found 5358 tests in 135.39s.
Tests completed in 1016.35s
Tests Passed: 5358, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 48.9% / 0%. 26,455 analyzed Commands in 203 Files.
```

Output Summary: `EXIT_CODE: 0` (outcome (a)); under `Run.Exit = $true` the code is `FailedCount + FailedBlocksCount + FailedContainersCount`, so 0 means no failed test, block, or container. The P0-T23 baseline code was also 0, so no `ExpectedExitCode:` field is carried. 168 test files and 5358 tests ran (baseline 167 files and 5319 tests; the increase is the new dispatch suite, the new characterization tests, and the two #936 test files merged from `main`). The aggregate command-coverage line spans all 203 files in the configured coverage roots and is informational; per-file counters are recorded by P9-T6 (AC-22).
