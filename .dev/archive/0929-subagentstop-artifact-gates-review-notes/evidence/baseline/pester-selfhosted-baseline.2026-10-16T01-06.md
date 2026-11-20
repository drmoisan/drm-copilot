# Self-Hosted PoshQC Test Baseline (P0-T23)

Timestamp: 2026-10-16T01-06

Command: sh SCRATCH/issue-929/P0-T23-1.sh
Script: `'RUN_START_UTC=' + [DateTime]::UtcNow.ToString('o'); Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/claude-runtime')`
EXIT_CODE: 0
Output (selected lines; per-container progress lines carry host paths and are omitted):
```
RUN_START_UTC=2026-10-16T00:46:26.6237167Z
Code coverage population: source=config; files=203
Starting discovery in 167 files.
Discovery found 5319 tests in 94.86s.
Tests completed in 1033.86s
Tests Passed: 5319, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 48.9% / 0%. 26,456 analyzed Commands in 203 Files.
```

Output Summary: BASELINE-SELFHOSTED-EXIT-CODE: 0. Under `Run.Exit = $true` the exit code is `FailedCount + FailedBlocksCount + FailedContainersCount`, not a failed-test count; 0 means no failed test, block, or container. The aggregate command-coverage line (48.9%) spans all 203 files in the configured coverage roots and is informational; the per-file counters for the changed file are recorded by P0-T25. This artifact records this one gate only.
