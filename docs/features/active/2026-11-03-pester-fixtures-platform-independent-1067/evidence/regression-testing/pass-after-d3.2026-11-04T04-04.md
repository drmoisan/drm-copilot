# D3 Pass-After (P3-T4)

Timestamp: 2026-11-04T04-04
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 -Report 'resolves a relative path against the PowerShell location, not the process directory','resolves a relative virtual environment path against the PowerShell location, not the process directory'
EXIT_CODE: 0
Output Summary:
- State: `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` resolve with `[System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PWD.ProviderPath, <input>))`; no other function changed.
- TOTAL Tests=9 Passed=9 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 tests=9 failed=0
- RESULT DrmCopilotPromptSupport.ps1.Get-DrmCopilotNormalizedPath.resolves a relative path against the PowerShell location, not the process directory Passed
- RESULT DrmCopilotPromptSupport.ps1.Resolve-DrmCopilotActivationScriptPath.resolves a relative virtual environment path against the PowerShell location, not the process directory Passed
- Each new relative-path test restores the PowerShell location and `[Environment]::CurrentDirectory` in `finally` (AC5). The global-function leak (PROBE LEAKED_GLOBAL_FUNCTIONS=7) is addressed by P6-T2.
