# [P1-T3] Direct analyzer and formatter pass over the PowerShell files of the branch diff

Timestamp: 2026-11-06T23-38
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pssa.ps1 -Format -Path <list>` (Invoke-ScriptAnalyzer and Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1), list from git diff --name-only MERGE_BASE with git status --porcelain --untracked-files=all as the untracked companion, restricted to .ps1 and .psm1
EXIT_CODE: 0
Output Summary: 22 files, 0 analyzer findings of any severity, 0 formatter differences (PSSA_TOTAL=0, FORMAT_DIFF=0).

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
