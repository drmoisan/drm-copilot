# [P6-T13] Seeded shuffled file-order single-process Pester runs (fresh run on the post-merge head)

Timestamp: 2026-11-04T20-49
Command: pwsh -NoProfile -File SCRATCH/issue-1031-shuffle.ps1 -Root <worktree> -SeedList 1031,2026,4242 (one new pwsh process; for each seed a Fisher-Yates shuffle of the ten files driven by [System.Random]::new($seed), then Invoke-Pester with Run.Path set to the shuffled list and Run.PassThru; no strict mode or preference change in the runner)
EXIT_CODE: 0
Output Summary: three runs, each 177 passed, 0 failed, 0 skipped, 0 not run, 0 failed containers. No order dependence observed.

Files (four new suites, five edited docs suites, guard suite): DocsPythonNativeProtocol, DocsAnalyzerPythonNative, DocsAnalyzerPythonNative.Parity, DocsInventory.PythonNative, DocsAnalyzerRegistry, DocsAnalyzerConfigFiles, DocsInventorySnapshot, DocsInventory, DocsInventoryProperties (all `.Tests.ps1` under tests/scripts/claude-lib/docs) and tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1. The suites carry the New- to ConvertTo- helper renames of bbef268db.

| Seed | File order passed as Run.Path | Passed | Failed |
|---|---|---|---|
| 1031 | DocsPythonNativeProtocol, DocsAnalyzerPythonNative, DocsAnalyzerConfigFiles, DocsInventory, DocsInventoryProperties, DocsInventorySnapshot, DocsAnalyzerRegistry, enforcement-hooks-no-python-invocation, DocsAnalyzerPythonNative.Parity, DocsInventory.PythonNative | 177 | 0 |
| 2026 | DocsAnalyzerRegistry, enforcement-hooks-no-python-invocation, DocsInventory.PythonNative, DocsInventoryProperties, DocsPythonNativeProtocol, DocsAnalyzerConfigFiles, DocsInventorySnapshot, DocsInventory, DocsAnalyzerPythonNative.Parity, DocsAnalyzerPythonNative | 177 | 0 |
| 4242 | DocsPythonNativeProtocol, enforcement-hooks-no-python-invocation, DocsAnalyzerPythonNative, DocsAnalyzerConfigFiles, DocsInventory.PythonNative, DocsAnalyzerPythonNative.Parity, DocsInventorySnapshot, DocsInventory, DocsAnalyzerRegistry, DocsInventoryProperties | 177 | 0 |
