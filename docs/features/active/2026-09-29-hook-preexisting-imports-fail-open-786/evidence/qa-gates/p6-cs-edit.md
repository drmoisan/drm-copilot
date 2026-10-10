# Chunk CS Edit ([P6-T3])

Timestamp: 2026-10-09T23-54
Command: R-RESET P6-T3#1, #2 (before CS production-file ordinals 1, 4); R-INSTALL groups P6-T3#1 to P6-T3#6 in section 3 order; R-LINES over the six edited files; R-EXIT1 for each CS hook against `git show 86e457a003be0c60b65e01156e4cccd6495dfd1a:<hook path>`; R-SCOPED over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: section 2.2 applied to the six Claude SubagentStop hooks with `<E>` SubagentStop and the SubagentStop tail form. W-RUNTIME pre-loads: validate-discovery-artifact-gate.ps1 (DiscoveryValidation.psm1, placed after the bootstrap line because the hook has no direct edge) and validate-orchestrator-output.ps1 (OrchestratorStateCompletion.psm1, OrchestratorStateUnconditional.psm1, OrchestratorState.psm1). 2.2(a) EAP placement: in validate-orchestrator-output.ps1 the `$ErrorActionPreference = 'Stop'` line preceded its imports and was moved to directly after the last pre-load line, which follows the last H7/H8 W-HELD region line (the H7 and H8 regions are unchanged). The other three EAP_STOP hooks (validate-feature-review-coverage.ps1, validate-planner-output.ps1, validate-prd-feature-output.ps1) have no import or dot-source after the assignment other than the new bootstrap, so their assignment line stays. The byte-order mark of validate-planner-output.ps1 was restored in the candidate before install. install-log.md records INSTALL-RESULT: OK for all six groups; smoke-log.md records a pass for every smoked hook. Every edited file is at most 500 lines. Every CS hook's R-EXIT1 count is unchanged from BASE. In the R-SCOPED run each CS hook not in W-CONVERT-HOOKS (five hooks) has its six S1 to S6 repository claude rows on PASSED: lines and no repository FAILED: line; validate-orchestrator-output.ps1 (W-CONVERT-HOOKS) still fails S2 on its H7/H8 regions until Phase 8, as expected.

Per-hook S1 to S6 repository claude rows (PASSED / FAILED), hooks not in W-CONVERT-HOOKS:
- .claude/hooks/validate-discovery-artifact-gate.ps1 | 6 / 0
- .claude/hooks/validate-feature-review-coverage.ps1 | 6 / 0
- .claude/hooks/validate-planner-output.ps1 | 6 / 0
- .claude/hooks/validate-pr-author-output.ps1 | 6 / 0
- .claude/hooks/validate-prd-feature-output.ps1 | 6 / 0

R-SCOPED totals: 439 PASSED, 159 FAILED.

```text
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 264
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | 465
LINES: .claude/hooks/validate-orchestrator-output.ps1 | 491
LINES: .claude/hooks/validate-planner-output.ps1 | 416
LINES: .claude/hooks/validate-pr-author-output.ps1 | 142
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 97
```

```text
EXIT1: .claude/hooks/validate-discovery-artifact-gate.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-feature-review-coverage.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-orchestrator-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-planner-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-pr-author-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-prd-feature-output.ps1 | base=1 | post=1 | equal
```

```text

Starting discovery in 1 files.
Discovery found 598 tests in 345ms.
Running tests.
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 50ms (49ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (24ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 63ms (63ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 45ms (44ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 19ms (19ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (26ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 38ms (37ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 38ms (37ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 48ms (47ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 26ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 44ms (43ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (23ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 36ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 43ms (42ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 30ms (29ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 40ms (39ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (40ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 11ms (10ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 37ms (37ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 22ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 19ms (18ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 37ms (37ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 17ms (17ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 29ms (29ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 33ms (32ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (16ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (16ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (27ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 15ms (15ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 36ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 31ms (30ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 4ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 3ms (3ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: OrchestratorState.psm1 (line 51) is not in its own single-statement try', 'S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 18) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 23) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 29) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 32) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 34) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 35) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 49) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: enforce-checkpoint-monotonic.ps1 (line 51) is not in its own single-statement try', 'S2: codex-pretooluse-file-mapping.ps1 (line 57) is not in its own single-statement try', 'S2: enforce-completion-helpers.ps1 (line 62) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 65ms (65ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 63ms (63ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 135ms (134ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 67ms (67ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 63ms (63ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 15ms (15ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 22ms (21ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 31ms (31ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 26ms (26ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 15ms (14ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 23ms (22ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 22ms (22ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 13ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 19ms (18ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 35ms (35ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 15ms (14ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating 116ms (115ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .claude/hooks/validate-orchestrator-output.ps1:51 OrchestratorState.psm1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 93ms (92ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 89ms (89ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 184ms (184ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 86ms (86ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 71ms (70ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 17ms (16ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 29ms (28ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 39ms (39ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 36ms (35ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 17ms (16ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 23ms (23ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 20ms (20ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 20ms (20ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 36ms (36ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 13ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard 5ms (5ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
[-] hook dependency guard structural completeness (issue #786).S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard 65ms (64ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
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
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function 2ms (2ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-DiscoveryArtifactGateValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-FeatureReviewCoverageValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PlannerOutputValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PrdFeatureOutputValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Get-PrAuthorOutputDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestratorOutputValidation does not return the dependency decision first'.
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
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
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
Tests completed in 16.18s
Tests Passed: 439, Failed: 159, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 439
FailedCount: 159
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Failed | passed=439 | failed=159
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
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
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
FAILED: S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: OrchestratorState.psm1 (line 51) is not in its own single-statement try', 'S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
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
FAILED: S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .claude/hooks/validate-orchestrator-output.ps1:51 OrchestratorState.psm1 is neither guarded nor covered'.
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
FAILED: S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
FAILED: S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
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
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-DiscoveryArtifactGateValidation does not return the dependency decision first'.
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-FeatureReviewCoverageValidation does not return the dependency decision first'.
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PlannerOutputValidation does not return the dependency decision first'.
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PrdFeatureOutputValidation does not return the dependency decision first'.
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Get-PrAuthorOutputDecision does not return the dependency decision first'.
FAILED: S6: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestratorOutputValidation does not return the dependency decision first'.
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
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
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
