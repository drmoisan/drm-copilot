# [P6-T7] Analyzer and formatter pass over the branch diff

Timestamp: 2026-11-07T00-08
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pssa.ps1 -Format -Path <list>` (Invoke-ScriptAnalyzer and Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1) over the .ps1 and .psm1 files of the branch diff from MERGE_BASE
EXIT_CODE: 0
Output Summary: 22 files, 0 analyzer findings, 0 formatter differences (PSSA_TOTAL=0, FORMAT_DIFF=0).

| File | Findings | Formatter result equals file |
|---|---|---|
| `LIB/DocsAnalyzerPythonNative.psm1` | 0 | True |
| `LIB/DocsAnalyzerRegistry.psm1` | 0 | True |
| `LIB/DocsInventory.psm1` | 0 | True |
| `LIB/DocsPythonNativeProtocol.psm1` | 0 | True |
| `LIB/Invoke-DocsCommand.ps1` | 0 | True |
| `MIRROR/DocsAnalyzerPythonNative.psm1` | 0 | True |
| `MIRROR/DocsAnalyzerRegistry.psm1` | 0 | True |
| `MIRROR/DocsInventory.psm1` | 0 | True |
| `MIRROR/DocsPythonNativeProtocol.psm1` | 0 | True |
| `MIRROR/Invoke-DocsCommand.ps1` | 0 | True |
| `TESTS/DocsAnalyzerConfigFiles.Tests.ps1` | 0 | True |
| `TESTS/DocsAnalyzerPythonNative.Parity.Tests.ps1` | 0 | True |
| `TESTS/DocsAnalyzerPythonNative.Tests.ps1` | 0 | True |
| `TESTS/DocsAnalyzerRegistry.Tests.ps1` | 0 | True |
| `TESTS/DocsInventory.PythonNative.Tests.ps1` | 0 | True |
| `TESTS/DocsInventory.Tests.ps1` | 0 | True |
| `TESTS/DocsInventoryProperties.Tests.ps1` | 0 | True |
| `TESTS/DocsInventorySnapshot.Tests.ps1` | 0 | True |
| `TESTS/DocsPythonNativeProtocol.Tests.ps1` | 0 | True |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` | 0 | True |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` | 0 | True |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 0 | True |
