# [P6-T14] Pester isolation

Timestamp: 2026-11-07T00-41
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-x-shuffle.ps1` (for each seed, a Fisher-Yates shuffle driven by [System.Random]::new($seed), then one Invoke-Pester with Run.Path in that order, in one process); then `Invoke-PoshQCParallelTest -Root <worktree>` in a new process
EXIT_CODE: 0
Output Summary: three seeded runs, 64 passed and 0 failed each, 0 failed containers. Parallel run: 8 shards, every shard exit 0, 448 s; merged JUnit tests 16542, failures 0, errors 0, skipped 10, suites 611; every test file under TESTS reports 0 failed (2136 tests). No failing test outside TESTS, so none is listed. No order dependence observed.

## Seeded runs

| Seed | File order | Passed | Failed |
|---|---|---|---|
| 1031 | DocsInventory.PythonNative, DocsPythonNativeProtocol, DocsAnalyzerPythonNative, DocsAnalyzerPythonNative.Parity | 64 | 0 |
| 2026 | DocsPythonNativeProtocol, DocsAnalyzerPythonNative.Parity, DocsInventory.PythonNative, DocsAnalyzerPythonNative | 64 | 0 |
| 4242 | DocsAnalyzerPythonNative, DocsPythonNativeProtocol, DocsAnalyzerPythonNative.Parity, DocsInventory.PythonNative | 64 | 0 |
