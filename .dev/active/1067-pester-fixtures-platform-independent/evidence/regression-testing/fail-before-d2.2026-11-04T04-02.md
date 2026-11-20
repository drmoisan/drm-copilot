# D2 Fail-Before (P2-T2)

Timestamp: 2026-11-04T04-02
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 -Report 'resolves a relative path against the PowerShell location, not the process directory','resolves a relative explicit repo root against the PowerShell location, not the process directory'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: P2-T1 test changes applied; `scripts/dev-tools/HostBootstrapWorkspace.psm1` unchanged.
- TOTAL Tests=34 Passed=32 Failed=2 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 tests=34 failed=2 (the 8 baseline fixture failures are resolved by the portable root; only the two new regression tests fail)
- RESULT Resolve-WorkspaceRoot.resolves a relative path against the PowerShell location, not the process directory Failed
- RESULT Resolve-ProjectRepoRoot.resolves a relative explicit repo root against the PowerShell location, not the process directory Failed
- Messages: expected `<test directory>/relative-ws` but was `/relative-ws`; expected `<test directory>/relative-repo` but was `/relative-repo`. The input resolved against the process directory (set to the drive root) instead of the PowerShell location.
