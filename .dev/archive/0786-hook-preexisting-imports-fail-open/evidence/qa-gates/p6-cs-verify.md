# Chunk CS Mirrors and Verification ([P6-T4])

Timestamp: 2026-10-09T23-55
Command: rcopy (rule 6) of the six files edited in [P6-T3] to extensions/drm-copilot/resources/claude-customizations/; R-SCOPED over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 and tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1; per-hook acceptance counts computed from the R-SCOPED output against wedges.csv, wruntime.csv, and W-EXEMPT-EDGES
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: mirror-log.md records `equal` for all six copies (UNEQUAL: 0). For each CS hook not in W-CONVERT-HOOKS (five hooks) the six S1 to S6 mirror rows are on PASSED: lines, no FAILED: line names the hook, the B1 PASSED count equals W-EDGES rows minus W-EXEMPT-EDGES rows plus distinct W-RUNTIME targets (validate-discovery-artifact-gate.ps1: 0 + 1 = 1; the other four have no direct edge and no runtime target), and the B2 and B3 rows are on PASSED: lines (CHUNK-RESULT: OK). The exit code 1 comes from Codex rows and from the W-CONVERT-HOOKS hook validate-orchestrator-output.ps1, whose four H7/H8 B1 rows (validate-orchestrator-output-resolution.ps1, WorktreeItemResolution.psm1, WorktreeRunResolution.psm1, OrchestratorStateEpicWaveBarrier.psm1) fail until the Phase 8 conversion, as expected; its pre-load B1 rows and its B2 and B3 rows pass.

```text
COPY: .claude/hooks/validate-discovery-artifact-gate.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | equal
COPY: .claude/hooks/validate-feature-review-coverage.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | equal
COPY: .claude/hooks/validate-orchestrator-output.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | equal
COPY: .claude/hooks/validate-planner-output.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | equal
COPY: .claude/hooks/validate-pr-author-output.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | equal
COPY: .claude/hooks/validate-prd-feature-output.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | equal
UNEQUAL: 0
```

```text
HOOK: .claude/hooks/validate-discovery-artifact-gate.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=1 expected=1 (edges=0 exempt=0 runtime=1) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/validate-feature-review-coverage.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/validate-planner-output.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/validate-pr-author-output.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/validate-prd-feature-output.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=0 expected=0 (edges=0 exempt=0 runtime=0) | B2=1 | B3=1 | OK
TOTAL PASSED: 589 | TOTAL FAILED: 148
CHUNK-RESULT: OK
```

```text

Starting discovery in 2 files.
Discovery found 737 tests in 754ms.
Running tests.
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 45ms (44ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 58ms (58ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 43ms (42ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (19ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 33ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (18ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 29ms (29ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 29ms (29ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 14ms (14ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (26ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 38ms (38ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (18ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 47ms (46ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 33ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (15ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 22ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 31ms (30ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 30ms (29ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 37ms (36ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 17ms (16ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 28ms (28ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 19ms (18ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 17ms (16ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (24ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 4ms (4ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 49) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: enforce-checkpoint-monotonic.ps1 (line 51) is not in its own single-statement try', 'S2: codex-pretooluse-file-mapping.ps1 (line 57) is not in its own single-statement try', 'S2: enforce-completion-helpers.ps1 (line 62) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 4ms (2ms|2ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 49) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: enforce-checkpoint-monotonic.ps1 (line 51) is not in its own single-statement try', 'S2: codex-pretooluse-file-mapping.ps1 (line 57) is not in its own single-statement try', 'S2: enforce-completion-helpers.ps1 (line 62) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 72ms (72ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 71ms (71ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 152ms (152ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 77ms (76ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 72ms (71ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 15ms (14ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 25ms (25ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 37ms (36ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 32ms (32ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 16ms (16ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 25ms (24ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 15ms (14ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 26ms (26ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 15ms (14ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 19ms (18ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 39ms (39ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 16ms (15ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 77ms (76ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 71ms (71ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 136ms (136ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 69ms (68ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 63ms (63ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 14ms (14ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 22ms (22ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 32ms (32ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 26ms (25ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 14ms (14ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 27ms (27ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 18ms (17ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 24ms (24ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 13ms (12ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 21ms (21ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 44ms (44ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 18ms (17ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicMergeDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EpicRootInvocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexModelRoutingDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EpicPlanningOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicChildGuardDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonTestPurityDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellTestPurityDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CheckpointMonotonicDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
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
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicMergeDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EpicRootInvocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function 3ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexModelRoutingDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EpicPlanningOnlyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexEpicChildGuardDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonTestPurityDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellTestPurityDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CheckpointMonotonicDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails 45ms (45ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:487
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails 27ms (27ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:487
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails 28ms (28ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:487
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails 26ms (26ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:487
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
Tests completed in 23.88s
Tests Passed: 589, Failed: 148, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 589
FailedCount: 148
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Failed | passed=454 | failed=144
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Failed | passed=135 | failed=4
FAILED: S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
FAILED: S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
FAILED: S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 49) is not in its own single-statement try'.
FAILED: S2: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: enforce-checkpoint-monotonic.ps1 (line 51) is not in its own single-statement try', 'S2: codex-pretooluse-file-mapping.ps1 (line 57) is not in its own single-statement try', 'S2: enforce-completion-helpers.ps1 (line 62) is not in its own single-statement try').
FAILED: S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
FAILED: S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 49) is not in its own single-statement try'.
FAILED: S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: enforce-checkpoint-monotonic.ps1 (line 51) is not in its own single-statement try', 'S2: codex-pretooluse-file-mapping.ps1 (line 57) is not in its own single-statement try', 'S2: enforce-completion-helpers.ps1 (line 62) is not in its own single-statement try').
FAILED: S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
FAILED: S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
FAILED: S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
FAILED: S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
FAILED: S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
FAILED: S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicMergeDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EpicRootInvocationDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexModelRoutingDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EpicPlanningOnlyDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicChildGuardDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonTestPurityDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellTestPurityDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CheckpointMonotonicDecision does not return the dependency decision first'.
FAILED: S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
FAILED: S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PromotionMcpOnlyDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicMergeDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexWorktreeRemovalDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EpicRootInvocationDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexModelRoutingDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EpicPlanningOnlyDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicWaveDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexEpicChildGuardDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonTestPurityDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PythonBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellTestPurityDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-EvidenceLocationDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CheckpointMonotonicDecision does not return the dependency decision first'.
FAILED: S6: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
FAILED: S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
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
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
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
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
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
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
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
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
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
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateCompletion.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Claude hook and no other
```
