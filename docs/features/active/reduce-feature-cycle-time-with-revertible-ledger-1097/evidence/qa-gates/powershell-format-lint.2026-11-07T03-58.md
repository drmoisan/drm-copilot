# PowerShell Format and Lint Gate

Timestamp: 2026-11-07T03-57
Command: Invoke-PoshQCFormat -Root <worktree root> -ScanFolders scripts/dev-tools, tests/scripts/dev-tools, with a no-op -WriteFile; then Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each file below
EXIT_CODE: 0
Output Summary: format log of 78 lines with 0 `Formatted: ` lines. `Already formatted: ` appears for `scripts/dev-tools/ProcessReductionLedger.psm1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, and `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`. Analyzer findings: 0 in each of the three files.

Notes: this pass follows the self-review fix, which added tests for the non-empty `Current` rule, the entry name error, and unlabeled fences. It supersedes the earlier gate artifact.
