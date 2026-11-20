# Cycle 2 Reference Inventory (Issue #931)

Timestamp: 2026-10-16T05-12
Command: git grep -n -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'
EXIT_CODE: 0
Output Summary: First search: 7 distinct files, exactly the plan's expected list. Second search (`Invoke-ReleaseVerificationHelpers`): 3 distinct files, exactly the plan's expected list. No extra file, so no unplanned mirror.

## Search 1

- Command: `git grep -n -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'`
- Exit code: 0

```text
.vscode/tasks.json:293:				"${workspaceFolder}/scripts/dev-tools/Invoke-FullReleaseFlow.ps1",
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:32:    pwsh ./scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken yes
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:358:function Invoke-FullReleaseFlowGuarded {
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:497:    $exitCode = Invoke-FullReleaseFlowGuarded -ConfirmToken $ConfirmToken -RepoRoot $RepoRoot
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:2:Describe "Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded - additional failure paths" {
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:4:        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:43:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:92:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1:2:Describe "Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict" {
tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1:4:        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1:103:Describe "Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput" {
tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1:105:        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1:2:Describe "Invoke-FullReleaseFlow.ps1 - Wait-ForPullRequestChecks" {
tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1:4:        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:2:Describe "Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded" {
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:4:        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:113:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "no" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:133:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "YES" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:149:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:195:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:226:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:258:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:281:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:310:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:344:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:379:            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:44:RELEASE_FLOW_SCRIPT = Path("scripts/dev-tools/Invoke-FullReleaseFlow.ps1")
```

Distinct files (7):

1. `.vscode/tasks.json`
2. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`
3. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`
4. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`
5. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`
6. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`
7. `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`

## Search 2

- Command: `git grep -n -F -e "Invoke-ReleaseVerificationHelpers" -- . ':(exclude)docs'`
- Exit code: 0

```text
scripts/dev-tools/Invoke-ReleaseVerification.ps1:54:. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-ReleaseVerificationHelpers.ps1')
scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1:21:    . ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1
tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1:3:Describe "Invoke-ReleaseVerificationHelpers.ps1 - pure helpers" {
tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1:5:        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1")).Path
```

Distinct files (3):

1. `scripts/dev-tools/Invoke-ReleaseVerification.ps1`
2. `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`
3. `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`
