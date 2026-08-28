Timestamp: 2026-08-28T21-17
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path *>&1
EXIT_CODE: 0
Output Summary: PSScriptAnalyzer reports zero findings across the full repository, including the new file added by this fix (`tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1`) and the appended, documentation-only change to `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` (Markdown, not a PowerShell file, so outside the analyzer's scan set).

Full captured output:

```
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4
```
