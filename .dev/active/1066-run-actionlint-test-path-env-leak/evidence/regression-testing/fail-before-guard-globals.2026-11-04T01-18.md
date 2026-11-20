# Fail-Before: GUARD Alone on the Pre-RD1 Tree (P1-T3)

Timestamp: 2026-11-04T01-18
Command: pwsh -NoProfile -File SCRATCH/issue-1066-run-list.ps1 -ListFile SCRATCH/issue-1066-list-guard.txt -OutFile artifacts/pester/issue-1066/guard-alone-pre-rd1.xml -Root <worktree>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Tree: DD1 applied to TARGET, RD1 not applied; GUARD carries the RD3 testcase (P1-T1) and the RD2 form p testcase (P1-T2).
- Pester: Total=4 Passed=3 Failed=1 FailedBlocks=0 FailedContainers=0 (JUnit RAW/guard-alone-pre-rd1.xml).
- Testcase outcomes:
  - `nested harness leaves the process environment unchanged for an empty container`: passed
  - `run-actionlint.Tests.ps1 leaves every process environment variable unchanged`: passed
  - `run-actionlint.Tests.ps1 leaves global LASTEXITCODE at the value set before it runs` (RD2): passed
  - `run-actionlint.Tests.ps1 leaves global functions and loaded modules as the nested harness leaves them` (RD3): failed
- RD3 failure message: "Expected $null or empty, because run-actionlint.Tests.ps1 must remove the global functions and modules it adds; entries: function added Compress-Archive, function added Expand-Archive, function added Import-ScriptFunction, module added Microsoft.PowerShell.Archive".
- RD2 probe values: control probe 41 and target probe 41. The testcase asserts each value equals the sentinel 41 with `Should -Be`, and both assertions passed, so both values are 41.
- Acceptance: EXIT_CODE 1; both environment testcases pass; the RD3 testcase fails naming Import-ScriptFunction, Expand-Archive, Compress-Archive, and Microsoft.PowerShell.Archive. Met.
