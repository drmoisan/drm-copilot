# [P3-T1] PowerShell analyzer and formatter

Timestamp: 2026-11-07T01-42
Command: direct Invoke-ScriptAnalyzer and Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over each .ps1 and .psm1 file in git diff --name-only MERGE_BASE (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-c2-pssa.ps1`)
EXIT_CODE: 0
Output Summary: 23 files: 0 analyzer findings of any severity, 0 formatter differences.

## Files and counts

`git status --porcelain` listed no untracked PowerShell file.

| File | Findings | Formatter differences |
|---|---|---|
| `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` | 0 | 0 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 0 | 0 |
| `.claude/lib/docs/DocsInventory.psm1` | 0 | 0 |
| `.claude/lib/docs/DocsPythonNativeProtocol.psm1` | 0 | 0 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerPythonNative.psm1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsInventory.psm1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonNativeProtocol.psm1` | 0 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Parity.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsInventory.PythonNative.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonNativeProtocol.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 0 | 0 |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` | 0 | 0 |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` | 0 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 0 | 0 |
