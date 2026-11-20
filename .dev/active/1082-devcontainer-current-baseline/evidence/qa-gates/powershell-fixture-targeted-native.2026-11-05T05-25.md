Timestamp: 2026-11-05T05-25
Started: 2026-11-05T05:20:33.1883749Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-final-pester.sh targeted
EXIT_CODE: 127
Output Summary:

```text
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Write of the relative checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 10.55s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (Cannot retrieve the dynamic parameters for the cmdlet. The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Edit of the relative checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 9.92s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (Cannot retrieve the dynamic parameters for the cmdlet. The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Write of the absolute checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 9.88s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (Cannot retrieve the dynamic parameters for the cmdlet. The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Edit of the absolute checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 9s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Write of the backslash checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 9.61s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH2 denies a Edit of the backslash checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984) 9.73s
 at $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:150
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH4 returns exit 0 and an allow for a non-checkpoint Edit through the & route when the helpers fail to load (#984) 10.35s
 at $result.ExitCode | Should -Be 0, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:193
 Expected 0, but got 2.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH5 returns exit 0 and a deny naming enforce-completion-helpers.ps1 for a checkpoint Edit through the & route when the helpers fail to load (#984) 10.91s
 at $result.ExitCode | Should -Be 0, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:213
 Expected 0, but got 2.
[-] enforce-completion-consistency.ps1 helper import failure on the repository root (#984).CH6 denies an envelope anomaly and allows a payload without file_path when the helpers fail to load (#984) 10.29s
 at $anomaly.permissionDecisionReason.StartsWith('COMPLETION_CONSISTENCY_BLOCKED: payload anomaly', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $anomaly.permissionDecisionReason, REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:240
 Expected $true, because COMPLETION_CONSISTENCY_BLOCKED: the dependency 'HookPayload.psm1' failed to load (The script failed due to call depth overflow.); the gate fails closed., but got $false.
[-] enforce-completion-consistency.ps1 helper import failure on the mirror root (#984).CH1 allows a non-checkpoint Edit of src/App/App.csproj when enforce-completion-helpers.ps1 fails to load (#984) 9.13s
 at $decision.permissionDecision | Should -Be 'allow', REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:113
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
[-] enforce-completion-consistency.ps1 helper import failure on the mirror root (#984).CH1 allows a non-checkpoint Edit of README.md when enforce-completion-helpers.ps1 fails to load (#984) 9.3s
 at $decision.permissionDecision | Should -Be 'allow', REPO\tests\scripts\claude-hooks\enforce-completion-consistency.HelperImportFailure.Tests.ps1:113
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
```

Raw output: SCRATCH/issue-1082-powershell-fixture-targeted-native.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
