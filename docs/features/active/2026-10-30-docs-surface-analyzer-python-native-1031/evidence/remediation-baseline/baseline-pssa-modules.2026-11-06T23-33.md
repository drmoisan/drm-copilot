# [P0-T6] Remediation baseline on the merged tree: PSScriptAnalyzer over the two native modules and their copies

Timestamp: 2026-11-06T23-33
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 (PSScriptAnalyzer 1.25.0, launched by `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pssa.ps1`) over LIB/DocsAnalyzerPythonNative.psm1, LIB/DocsPythonNativeProtocol.psm1 and their MIRROR copies, on the merged tree
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 20 findings: 16 Warning, 4 Information, 10 per module copy. The script exits 1 when any finding exists, which is the expected baseline outcome. This artifact supersedes baseline-pssa-modules.2026-11-06T16-20.md.

| Severity | Rule | File | Function |
|---|---|---|---|
| Warning | PSReviewUnusedParameter | LIB/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeCli |
| Warning | PSReviewUnusedParameter | LIB/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeHttp |
| Warning | PSReviewUnusedParameter | LIB/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeApi |
| Warning | PSReviewUnusedParameter | LIB/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeArchitecture |
| Warning | PSUseLiteralInitializerForHashtable | LIB/DocsAnalyzerPythonNative.psm1 | Invoke-DocsPythonNativeInventory |
| Warning | PSUseLiteralInitializerForHashtable | LIB/DocsPythonNativeProtocol.psm1 | New-DocsPythonNativeRequest |
| Warning | PSUseLiteralInitializerForHashtable | LIB/DocsPythonNativeProtocol.psm1 | ConvertFrom-DocsPythonNativeResponse |
| Warning | PSUseLiteralInitializerForHashtable | LIB/DocsPythonNativeProtocol.psm1 | ConvertFrom-DocsPythonNativeResponse |
| Information | PSUseOutputTypeCorrectly | LIB/DocsPythonNativeProtocol.psm1 | Get-DocsPythonNativeKind |
| Information | PSUseOutputTypeCorrectly | LIB/DocsPythonNativeProtocol.psm1 | Get-DocsPythonNativeKind |
| Warning | PSUseLiteralInitializerForHashtable | MIRROR/DocsAnalyzerPythonNative.psm1 | Invoke-DocsPythonNativeInventory |
| Warning | PSReviewUnusedParameter | MIRROR/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeCli |
| Warning | PSReviewUnusedParameter | MIRROR/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeHttp |
| Warning | PSReviewUnusedParameter | MIRROR/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeApi |
| Warning | PSReviewUnusedParameter | MIRROR/DocsAnalyzerPythonNative.psm1 | Invoke-DocsAnalyzerPythonNativeArchitecture |
| Warning | PSUseLiteralInitializerForHashtable | MIRROR/DocsPythonNativeProtocol.psm1 | New-DocsPythonNativeRequest |
| Warning | PSUseLiteralInitializerForHashtable | MIRROR/DocsPythonNativeProtocol.psm1 | ConvertFrom-DocsPythonNativeResponse |
| Warning | PSUseLiteralInitializerForHashtable | MIRROR/DocsPythonNativeProtocol.psm1 | ConvertFrom-DocsPythonNativeResponse |
| Information | PSUseOutputTypeCorrectly | MIRROR/DocsPythonNativeProtocol.psm1 | Get-DocsPythonNativeKind |
| Information | PSUseOutputTypeCorrectly | MIRROR/DocsPythonNativeProtocol.psm1 | Get-DocsPythonNativeKind |
