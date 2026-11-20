# D3 Fail-Before (P3-T2)

Timestamp: 2026-11-04T04-03
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 -Report 'resolves a relative path against the PowerShell location, not the process directory','resolves a relative virtual environment path against the PowerShell location, not the process directory'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: P3-T1 test changes applied (portable root, no personal profile path, four new It blocks); `scripts/dev-tools/DrmCopilotPromptSupport.ps1` unchanged.
- TOTAL Tests=9 Passed=7 Failed=2 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 tests=9 failed=2 (the 4 baseline fixture failures are resolved; only the two relative-path regression tests fail)
- RESULT DrmCopilotPromptSupport.ps1.Get-DrmCopilotNormalizedPath.resolves a relative path against the PowerShell location, not the process directory Failed
- RESULT DrmCopilotPromptSupport.ps1.Resolve-DrmCopilotActivationScriptPath.resolves a relative virtual environment path against the PowerShell location, not the process directory Failed
- Messages: expected `<test directory>/relative-repo` but was `/relative-repo`; expected `<test directory>/relative-venv/Scripts/Activate.ps1` but was `/relative-venv/Scripts/Activate.ps1` (resolved against the process directory).
