# Chunk XP-B Edit ([P7-T3])

Timestamp: 2026-10-10T00-12
Command: R-RESET P7-T3#1, #2, #3 (before XP-B production-file ordinals 1, 4, 7); candidate staging, mechanical transform, manual edits, and direct write of the eight XP-B Codex hooks and the W-COND helper .codex/hooks/codex-epic-child-launch-attestation.ps1 (written with .codex/hooks/enforce-epic-wave-barrier.ps1, which dot-sources it); R-LINES over the nine edited files; `git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a -- .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (lists nothing); R-SCOPED over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: section 2.2 applied to the eight XP-B hooks; validate-bash.ps1 uses the D4 prefix HOOK_DEPENDENCY_LOAD_FAILED:. D3: in codex-epic-child-launch-attestation.ps1 the Test-Path condition is kept and the body becomes the guarded dot-source naming 'epic-child-launch-contract.ps1' (net zero). 2.2(f) headroom: in .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 the empty first line and the empty line before `# The readiness checkpoint this gate reads and names in its block message.` were deleted, so the file measures 500 lines (496 + 6 - 2). The H2 modes file is not edited. No -Global (FR-7.3 confirmed; no Codex W-RUNTIME row). Every edited file is at most 500 lines. In the R-SCOPED run each XP-B hook (none is in W-CONVERT-HOOKS) has its six S1 to S6 repository codex rows on PASSED: lines and no repository FAILED: line; the remaining failures are XP-B mirror rows (copied in [P7-T4]), XS rows, and W-CONVERT-HOOKS rows, as expected.

Per-hook S1 to S6 repository codex rows (PASSED / FAILED):
- .codex/hooks/enforce-epic-wave-barrier.ps1 | 6 / 0
- .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 6 / 0
- .codex/hooks/enforce-evidence-locations.ps1 | 6 / 0
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 6 / 0
- .codex/hooks/enforce-powershell-batch-budget.ps1 | 6 / 0
- .codex/hooks/enforce-promotion-mcp-only.ps1 | 6 / 0
- .codex/hooks/enforce-python-batch-budget.ps1 | 6 / 0
- .codex/hooks/validate-bash.ps1 | 6 / 0

R-SCOPED totals: 554 PASSED, 44 FAILED.

```text
RESET: P7-T3#1 | deleted: none present
WRITTEN: P7-T3#1 | .codex/hooks/enforce-epic-wave-barrier.ps1
WRITTEN: P7-T3#1 | .codex/hooks/codex-epic-child-launch-attestation.ps1
WRITTEN: P7-T3#2 | .codex/hooks/enforce-epic-worktree-removal-gate.ps1
RESET: P7-T3#2 | deleted: none present
WRITTEN: P7-T3#3 | .codex/hooks/enforce-evidence-locations.ps1
WRITTEN: P7-T3#4 | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
WRITTEN: P7-T3#5 | .codex/hooks/enforce-powershell-batch-budget.ps1
RESET: P7-T3#3 | deleted: none present
WRITTEN: P7-T3#6 | .codex/hooks/enforce-promotion-mcp-only.ps1
WRITTEN: P7-T3#7 | .codex/hooks/enforce-python-batch-budget.ps1
WRITTEN: P7-T3#8 | .codex/hooks/validate-bash.ps1
ALL-WRITTEN: OK
```

```text
LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | 301
LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 129
LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 190
LINES: .codex/hooks/enforce-evidence-locations.ps1 | 202
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 500
LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | 347
LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | 297
LINES: .codex/hooks/enforce-python-batch-budget.ps1 | 350
LINES: .codex/hooks/validate-bash.ps1 | 319
```

```text

Starting discovery in 1 files.
Discovery found 598 tests in 254ms.
Running tests.
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 38ms (37ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (23ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (41ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (23ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 36ms (35ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 31ms (30ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 30ms (30ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 15ms (14ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (20ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 4ms (4ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 3ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 18ms (17ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 58ms (58ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 55ms (54ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 119ms (118ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 58ms (57ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 28ms (28ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 21ms (20ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 20ms (20ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 18ms (17ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 13ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
Tests completed in 15.77s
Tests Passed: 554, Failed: 44, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 554
FailedCount: 44
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Failed | passed=554 | failed=44
FAILED: S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
FAILED: S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
FAILED: S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
FAILED: S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
FAILED: S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
PASSED: S1: repository claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S2: repository claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S3: repository claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S4: repository claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S5: repository claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S6: repository claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S7: discovers hooks from .claude/settings.json and .codex/config.toml
PASSED: S8: names every exemption with its justification
PASSED: F1: reports an unguarded direct edge in a synthetic hook
PASSED: F2: reports a try body that holds more than the import statement
PASSED: F3: reports a guarded Import-Module without -ErrorAction Stop
PASSED: F4: reports a hook without the bootstrap try
PASSED: F5: reports a missing tail check or one placed before the dot-source early return
PASSED: F6: reports a runtime import that is not pre-loaded under a guard
PASSED: F7: reports a transitive Import-Module that is neither terminating nor covered
PASSED: F8: does not report the named exemptions
```
