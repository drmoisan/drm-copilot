# [P6-T9] PowerShell per-file line coverage

Timestamp: 2026-11-07T00-31
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pscov.ps1` over artifacts/pester/powershell-coverage.xml of the [P6-T8] run; `SCRATCH/issue-1031-x-changed.py` intersects missed lines with the lines changed against MERGE_BASE
EXIT_CODE: 0
Output Summary: each of the two new modules and the registry and inventory modules is at 100.00; every line changed against MERGE_BASE in the five files is covered, including the DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING throw.

| File | Line % (covered/total) | Lines changed against MERGE_BASE | Missed on changed lines |
|---|---|---|---|
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (93/93) | 332 | 0 |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) | 341 | 0 |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) | 4 | 0 |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) | 32 | 0 |
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) | 1 | 0 |
