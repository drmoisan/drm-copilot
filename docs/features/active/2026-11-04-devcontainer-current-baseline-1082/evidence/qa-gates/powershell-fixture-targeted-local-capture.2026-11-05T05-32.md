Timestamp: 2026-11-05T05-32
Started: 2026-11-05T05:32:00.1365609Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-final-pester.sh targeted
EXIT_CODE: 1
Output Summary:

```text
 CommandNotFoundException: The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-discovery-planning-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 23ms
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:186
 ParameterBindingValidationException: Cannot bind argument to parameter 'Path' because it is null.
[-] Codex hook dependency-failure behaviour (issue #786).B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 69ms
 at <ScriptBlock>, REPO\.codex\hooks\validate-codex-subagent-routing.ps1:13
 at Invoke-HookProcess, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:105
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:188
 CommandNotFoundException: The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).B3: SubagentStop .codex/hooks/validate-discovery-agent-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 28ms
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:186
 ParameterBindingValidationException: Cannot bind argument to parameter 'Path' because it is null.
[-] Codex hook dependency-failure behaviour (issue #786).B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 52ms
 at <ScriptBlock>, REPO\.codex\hooks\validate-feature-review-coverage.ps1:49
 at Invoke-HookProcess, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:105
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:188
 CommandNotFoundException: The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load 64ms
 at <ScriptBlock>, REPO\.codex\hooks\enforce-epic-wave-barrier.ps1:15
 at Invoke-HookProcess, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:105
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:225
 CommandNotFoundException: The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load 17ms
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:222
 ParameterBindingValidationException: Cannot bind argument to parameter 'Path' because it is null.
[-] Codex hook dependency-failure behaviour (issue #786).X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: 53ms
 at <ScriptBlock>, REPO\.codex\hooks\validate-bash.ps1:22
 at Invoke-HookProcess, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:105
 at <ScriptBlock>, REPO\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:238
 CommandNotFoundException: The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] preimplementation gate modes handler proof on the codex surface.H2 codex preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load 32ms
 at $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION', REPO\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1:70
 Expected 'feature-folder-resolution.ps1', because E-CONSTRUCTION, but got $null.
[-] preimplementation gate modes handler proof on the codex surface.H2 codex preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load 35ms
 at $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION', REPO\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1:91
 Expected 'feature-folder-resolution.ps1', because E-CONSTRUCTION, but got $null.
[+] REPO\tests\scripts\host-tools.manifest.Tests.ps1 432ms (9 tests)
Tests completed in 43.45s
Tests Passed: 509, Failed: 271, Skipped: 0, Inconclusive: 0, NotRun: 0
Targeted result: Failed; discovered=780; passed=509; failed=271; skipped=0; notrun=0
```

Raw output: SCRATCH/issue-1082-powershell-fixture-targeted-local-capture.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
