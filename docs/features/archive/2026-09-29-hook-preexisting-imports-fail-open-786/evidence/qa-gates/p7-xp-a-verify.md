# Chunk XP-A Mirrors and Verification ([P7-T2])

Timestamp: 2026-10-10T00-09
Command: rcopy (rule 6) of the nine files edited in [P7-T1] to extensions/drm-copilot/resources/codex-and-agents-customizations/; R-SCOPED over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 and tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1; per-hook acceptance counts computed from the R-SCOPED output against wedges.csv and wruntime.csv (codex surface)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: mirror-log.md records `equal` for all nine copies (UNEQUAL: 0). For each XP-A hook (none is in W-CONVERT-HOOKS) the six S1 to S6 mirror rows are on PASSED: lines, no FAILED: line names the hook, the B1 PASSED count equals W-EDGES rows minus W-EXEMPT-EDGES rows plus distinct W-RUNTIME targets, and the B2 and B3 rows are on PASSED: lines (CHUNK-RESULT: OK). The X rows for the XP-A hook .codex/hooks/enforce-epic-child-worktree-binding.ps1 (X1, X2) are on PASSED: lines; no X3 row names an XP-A hook. The exit code 1 comes from XP-B and XS rows (including X1/X2 for .codex/hooks/enforce-epic-wave-barrier.ps1 and X3 for validate-bash, both XP-B) and W-CONVERT-HOOKS rows, as expected.

```text
COPY: .codex/hooks/check-powershell-test-purity.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1 | equal
COPY: .codex/hooks/check-python-test-purity.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1 | equal
COPY: .codex/hooks/enforce-checkpoint-monotonic.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1 | equal
COPY: .codex/hooks/enforce-codex-model-routing.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1 | equal
COPY: .codex/hooks/enforce-completion-consistency.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | equal
COPY: .codex/hooks/enforce-epic-child-worktree-binding.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1 | equal
COPY: .codex/hooks/enforce-epic-merge-gate.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | equal
COPY: .codex/hooks/enforce-epic-planning-only.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 | equal
COPY: .codex/hooks/enforce-epic-root-invocation.ps1 -> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1 | equal
UNEQUAL: 0
```

```text
HOOK: .codex/hooks/check-powershell-test-purity.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=1 expected=1 (edges=1 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/check-python-test-purity.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=1 expected=1 (edges=1 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-checkpoint-monotonic.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=1 expected=1 (edges=1 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-codex-model-routing.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=2 expected=2 (edges=2 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-completion-consistency.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=3 expected=3 (edges=3 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-epic-merge-gate.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=2 expected=2 (edges=2 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-epic-planning-only.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .codex/hooks/enforce-epic-root-invocation.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=1 expected=1 (edges=1 exempt=0 runtime=0) | B2=1 | B3=1 | OK
TOTAL PASSED: 555 | TOTAL FAILED: 118
CHUNK-RESULT: OK
```

```text

Starting discovery in 2 files.
Discovery found 673 tests in 587ms.
Running tests.
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 47ms (46ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 23ms (23ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 55ms (54ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (23ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 31ms (31ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 39ms (39ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (19ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (24ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 45ms (44ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 22ms (22ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (40ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 15ms (14ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 4ms (4ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 3ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 76ms (76ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 73ms (72ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 159ms (158ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 64ms (63ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 35ms (34ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 24ms (23ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 23ms (22ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 58ms (58ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 61ms (61ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 133ms (133ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 55ms (55ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 27ms (26ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 18ms (18ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 19ms (19ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 12ms (12ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 12ms (11ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 52ms (51ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 57ms (57ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 20ms (20ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 35ms (34ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails 31ms (31ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-pretooluse-file-mapping.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails 38ms (37ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails 41ms (41ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails 95ms (94ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 88ms (87ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 101ms (100ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 16ms (15ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 31ms (30ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails 15ms (15ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-epic-child-launch-attestation.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails 28ms (28ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-pretooluse-file-mapping.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails 22ms (21ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-batch-budget-route.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails 17ms (17ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-pretooluse-file-mapping.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails 19ms (19ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-batch-budget-route.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails 14ms (14ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-pretooluse-file-mapping.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails 14ms (13ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: codex-authority-store.ps1
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 99ms (99ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 63ms (62ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 137ms (136ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 106ms (105ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 64ms (63ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 44ms (44ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 47ms (47ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 33ms (33ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 34ms (33ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 31ms (31ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:155
 Expected $true, but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 120ms (120ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 52ms (52ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 110ms (110ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 83ms (78ms|5ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 140ms (139ms|1ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 40ms (40ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 33ms (32ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 27ms (26ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:164
 Expected 2, but got 0.
[-] Codex hook dependency-failure behaviour (issue #786).B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 58ms (58ms|0ms)
 at $result.Stderr.StartsWith("$($script:ReasonPrefix[$Hook]) hook-dependency-guard.ps1 failed to load", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:165
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:165
 Expected $true, because Cannot bind argument to parameter 'AgentId' it is an empty string., but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 31ms (31ms|0ms)
 at $result.Stderr.StartsWith("$($script:ReasonPrefix[$Hook]) hook-dependency-guard.ps1 failed to load", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:165
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:165
 Expected $true, because Feature-review coverage validator error: validate-feature-review-coverage hook input requires boolean stop_hook_active., but got $false.
[-] Codex hook dependency-failure behaviour (issue #786).X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure 43ms (43ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:179
 CommandNotFoundException: The term 'Test-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load 48ms (48ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.codex\hooks\codex-epic-child-launch-attestation.ps1:5
 at <ScriptBlock>, <WORKSPACE_ROOT>\.codex\hooks\enforce-epic-wave-barrier.ps1:14
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:98
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:194
 CommandNotFoundException: The term 'synthetic-missing/epic-child-launch-contract.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
[-] Codex hook dependency-failure behaviour (issue #786).X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: 12ms (12ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1:201
 RuntimeException: simulated load failure: hook-command-scanner.ps1
Tests completed in 21.34s
Tests Passed: 555, Failed: 118, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 555
FailedCount: 118
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Failed | passed=522 | failed=76
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Failed | passed=33 | failed=42
FAILED: S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
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
FAILED: S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
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
FAILED: S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
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
FAILED: S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
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
FAILED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails | simulated load failure: codex-epic-child-launch-attestation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | simulated load failure: codex-authority-store.ps1
FAILED: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected $true, because Cannot bind argument to parameter 'AgentId' it is an empty string., but got $false.
FAILED: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected $true, because Feature-review coverage validator error: validate-feature-review-coverage hook input requires boolean stop_hook_active., but got $false.
FAILED: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure | The term 'Test-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load | The term 'synthetic-missing/epic-child-launch-contract.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: | simulated load failure: hook-command-scanner.ps1
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
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
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
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
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
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
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
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
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
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Codex hook and no other
PASSED: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
```
