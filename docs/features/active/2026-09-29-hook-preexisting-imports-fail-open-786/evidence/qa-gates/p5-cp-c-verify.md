# Chunk CP-C Mirrors and Verification ([P5-T7])

Timestamp: 2026-10-09T23-45
Command: rcopy (rule 6) of the five files edited in [P5-T6] to extensions/drm-copilot/resources/claude-customizations/; R-SCOPED over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 and tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1; per-hook acceptance counts computed from the R-SCOPED output against wedges.csv, wruntime.csv, and W-EXEMPT-EDGES
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: CP-C is not empty. mirror-log.md records `equal` for all five copies (UNEQUAL: 0). For each of the five CP-C hooks (none is in W-CONVERT-HOOKS) the six S1 to S6 mirror rows are on PASSED: lines, no FAILED: line names the hook, the B1 PASSED count equals W-EDGES rows minus W-EXEMPT-EDGES rows plus distinct W-RUNTIME targets (enforce-pr-author-skill.ps1: 4 + 2 = 6), and the B2 and B3 rows are on PASSED: lines (CHUNK-RESULT: OK). The exit code 1 comes from rows of CP-S, CS, Codex hooks, and W-CONVERT-HOOKS, as expected.

```text
COPY: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | equal
COPY: .claude/hooks/enforce-pr-author-skill.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 | equal
COPY: .claude/hooks/enforce-prd-feature-before-planner.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | equal
COPY: .claude/hooks/enforce-promotion-mcp-only.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 | equal
COPY: .claude/hooks/enforce-python-batch-budget.ps1 -> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 | equal
UNEQUAL: 0
```

```text
HOOK: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=5 expected=5 (edges=5 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/enforce-pr-author-skill.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=6 expected=6 (edges=4 exempt=0 runtime=2) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/enforce-prd-feature-before-planner.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=4 expected=4 (edges=4 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/enforce-promotion-mcp-only.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=3 expected=3 (edges=3 exempt=0 runtime=0) | B2=1 | B3=1 | OK
HOOK: .claude/hooks/enforce-python-batch-budget.ps1 | S1-S6 mirror PASSED=6 | S1-S6 repository PASSED=6 | FAILED=0 | B1 PASSED=2 expected=2 (edges=2 exempt=0 runtime=0) | B2=1 | B3=1 | OK
TOTAL PASSED: 501 | TOTAL FAILED: 232
CHUNK-RESULT: OK
```

```text

Starting discovery in 2 files.
Discovery found 733 tests in 793ms.
Running tests.
[-] hook dependency guard structural completeness (issue #786).S1: repository claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 191ms (173ms|18ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 65ms (65ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 31ms (30ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 59ms (58ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 52ms (52ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 28ms (27ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 59ms (58ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 42ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 81ms (79ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 61ms (60ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 34ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 33ms (32ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 37ms (36ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 40ms (39ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (34ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 42ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 32ms (31ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (15ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 30ms (30ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 15ms (14ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (25ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 40ms (40ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (24ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 25ms (24ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 28ms (28ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 33ms (33ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (15ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 41ms (41ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 37ms (37ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 10ms (9ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return 38ms (38ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return 21ms (21ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 40ms (39ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 36ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return 20ms (20ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (17ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 22ms (22ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return 36ms (35ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 16ms (15ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 27ms (27ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return 14ms (13ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return 28ms (27ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return 13ms (13ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return 23ms (22ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return 35ms (34ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return 18ms (18ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return 24ms (23ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S1:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:118
 Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: tail check missing after the dot-source early return').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 6ms (5ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 41) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 45) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 46) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 9) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 14) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 20) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 25) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 28) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 29) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 62) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 63) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: OrchestratorState.psm1 (line 51) is not in its own single-statement try', 'S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 21) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 22) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 35) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 36) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 3ms (2ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 5ms (4ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 3ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 41) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 45) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 46) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 9) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 14) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 20) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 25) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 28) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 29) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: HookPayload.psm1 (line 62) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 63) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: OrchestratorState.psm1 (line 51) is not in its own single-statement try', 'S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: hook-command-scanner.ps1 (line 11) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 12) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try 2ms (1ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-authority-store.ps1 (line 12) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-authority-store.ps1 (line 8) is not in its own single-statement try', 'S2: codex-agent-profile-attestation.ps1 (line 9) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-epic-child-launch-attestation.ps1 (line 14) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: epic-child-launch-contract.ps1 (line 16) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 35) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try 4ms (3ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 38) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got @('S2: codex-pretooluse-file-mapping.ps1 (line 51) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 54) is not in its own single-statement try').
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try 2ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S2:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:122
 Expected $null or empty, but got 'S2: codex-pretooluse-file-mapping.ps1 (line 46) is not in its own single-statement try'.
[-] hook dependency guard structural completeness (issue #786).S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try 2ms (2ms|1ms)
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
[-] hook dependency guard structural completeness (issue #786).S4: repository claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 123ms (123ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/validate-bash.ps1:41 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:45 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:46 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 251ms (250ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:9 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:14 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:20 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:25 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:28 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:29 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:55 EpicScopeReadiness.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:57 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 36ms (36ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/enforce-powershell-batch-budget.ps1:62 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-powershell-batch-budget.ps1:63 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating 132ms (132ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .claude/hooks/validate-orchestrator-output.ps1:51 OrchestratorState.psm1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 86ms (86ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 87ms (86ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 186ms (185ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 101ms (100ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 90ms (89ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 18ms (17ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 29ms (29ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 48ms (48ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 40ms (39ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 17ms (16ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 28ms (28ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 23ms (22ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 35ms (35ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 18ms (18ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 23ms (22ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 45ms (45ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 17ms (16ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 108ms (108ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/validate-bash.ps1:41 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:45 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:46 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 302ms (301ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:9 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:14 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:20 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:25 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:28 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:29 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:55 EpicScopeReadiness.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:57 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 29ms (29ms|1ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .claude/hooks/enforce-powershell-batch-budget.ps1:62 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-powershell-batch-budget.ps1:63 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating 78ms (77ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .claude/hooks/validate-orchestrator-output.ps1:51 OrchestratorState.psm1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating 55ms (55ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/validate-bash.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/validate-bash.ps1:22 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating 55ms (54ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-promotion-mcp-only.ps1:35 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-promotion-mcp-only.ps1:36 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating 118ms (118ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:37 enforce-orchestration-preimplementation-gate-epic-resolution.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating 61ms (61ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-merge-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-merge-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating 52ms (52ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:11 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .codex/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating 11ms (11ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-root-invocation.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating 18ms (18ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-codex-model-routing.ps1:8 codex-authority-store.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-codex-model-routing.ps1:9 codex-agent-profile-attestation.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating 26ms (25ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-epic-wave-barrier.ps1:14 codex-epic-child-launch-attestation.ps1 is neither guarded nor covered', 'S4: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 epic-child-launch-contract.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating 22ms (21ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-epic-child-worktree-binding.ps1:16 epic-child-launch-contract.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 14ms (14ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-python-test-purity.ps1:35 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 18ms (18ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-python-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-python-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating 12ms (12ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/check-powershell-test-purity.ps1:38 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating 19ms (18ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-powershell-batch-budget.ps1:51 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-powershell-batch-budget.ps1:54 enforce-batch-budget-route.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating 11ms (11ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-evidence-locations.ps1:46 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating 14ms (13ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating 28ms (28ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got @('S4: .codex/hooks/enforce-completion-consistency.ps1:51 enforce-checkpoint-monotonic.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:57 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-completion-consistency.ps1:62 enforce-completion-helpers.ps1 is neither guarded nor covered', 'S4: .codex/hooks/enforce-checkpoint-monotonic.ps1:49 codex-pretooluse-file-mapping.ps1 is neither guarded nor covered').
[-] hook dependency guard structural completeness (issue #786).S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating 11ms (11ms|0ms)
 at @(Get-TransitiveFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook)) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:130
 Expected $null or empty, but got 'S4: .codex/hooks/validate-codex-subagent-routing.ps1:12 codex-authority-store.ps1 is neither guarded nor covered'.
[-] hook dependency guard structural completeness (issue #786).S5: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard 7ms (6ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
[-] hook dependency guard structural completeness (issue #786).S5: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard 68ms (68ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
[-] hook dependency guard structural completeness (issue #786).S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard 5ms (5ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
[-] hook dependency guard structural completeness (issue #786).S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard 62ms (62ms|0ms)
 at @(Get-RuntimeFinding -Registration (New-Registration -RootPath $RootPath -Surface $Surface -HookEvent $Event -Hook $Hook) -Exemption $script:Exemptions) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:134
 Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
[-] hook dependency guard structural completeness (issue #786).S6: repository claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 5ms (4ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-DiscoveryArtifactGateValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-FeatureReviewCoverageValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PlannerOutputValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PrdFeatureOutputValidation does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Get-PrAuthorOutputDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestratorOutputValidation does not return the dependency decision first'.
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
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function 2ms (2ms|0ms)
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
[-] hook dependency guard structural completeness (issue #786).S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CompletionConsistencyDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-CodexSubagentStopDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function 2ms (2ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
[-] hook dependency guard structural completeness (issue #786).S6: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function 1ms (1ms|0ms)
 at @(Get-ShapeFinding -RootPath $RootPath -Hook $Hook -HookEvent $Event | Where-Object { $_ -like 'S6:*' }) | Should -BeNullOrEmpty, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1:138
 Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
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
[-] hook dependency guard structural completeness (issue #786).S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function 3ms (3ms|0ms)
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
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails 63ms (63ms|1ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: HookPayload.psm1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 34ms (34ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 57ms (57ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails 23ms (22ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: HookPayload.psm1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails 24ms (24ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails 29ms (29ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails 44ms (44ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails 62ms (62ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-scanner.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails 85ms (85ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: hook-command-invocation.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails 16ms (16ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: HookPayload.psm1
[-] Claude hook dependency-failure behaviour (issue #786).B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails 17ms (17ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: enforce-batch-budget-route.ps1
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails 27ms (27ms|0ms)
 at <ScriptBlock>, <No file>:1
 RuntimeException: simulated load failure: OrchestratorState.psm1
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails 22ms (22ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:478
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails 23ms (23ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:478
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails 19ms (18ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:478
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails 25ms (24ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:478
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:143
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
[-] Claude hook dependency-failure behaviour (issue #786).B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 73ms (72ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 92ms (92ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 30ms (30ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 24ms (24ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 24ms (24ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 25ms (25ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 25ms (24ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 24ms (23ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load 35ms (34ms|0ms)
 at $flag | Should -BeTrue, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:175
 Expected $true, but got $false.
[-] Claude hook dependency-failure behaviour (issue #786).B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 66ms (65ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 Expected 2, but got 0.
[-] Claude hook dependency-failure behaviour (issue #786).B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 89ms (89ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 Expected 2, but got 0.
[-] Claude hook dependency-failure behaviour (issue #786).B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 34ms (34ms|0ms)
 at $result.ExitCode | Should -Be 2, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:184
 Expected 2, but got 0.
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 12ms (12ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:253
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 14ms (13ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-feature-review-coverage.ps1:455
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: feature-review hook: CLAUDE_HOOK_INPUT is empty; cannot validate review output.
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 13ms (12ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-planner-output.ps1:406
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: atomic-planner hook: CLAUDE_HOOK_INPUT is empty; cannot validate planner output.
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 13ms (12ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-prd-feature-output.ps1:90
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: prd-feature hook: CLAUDE_HOOK_INPUT is empty.
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 11ms (11ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-pr-author-output.ps1:132
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.
[-] Claude hook dependency-failure behaviour (issue #786).B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load 18ms (18ms|0ms)
 at <ScriptBlock>, <WORKSPACE_ROOT>\.claude\hooks\validate-orchestrator-output.ps1:478
 at Invoke-HookProcess, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:116
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1:182
 WriteErrorException: orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
Tests completed in 23.06s
Tests Passed: 501, Failed: 232, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 501
FailedCount: 232
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Failed | passed=400 | failed=198
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Failed | passed=101 | failed=34
FAILED: S1: repository claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
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
FAILED: S1: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
FAILED: S1: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return | Expected $null or empty, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return').
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
FAILED: S2: repository claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 41) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 45) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 46) is not in its own single-statement try').
FAILED: S2: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 9) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 14) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 20) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 25) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 28) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 29) is not in its own single-statement try').
FAILED: S2: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 62) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 63) is not in its own single-statement try').
FAILED: S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: OrchestratorState.psm1 (line 51) is not in its own single-statement try', 'S2: the catch of validate-orchestrator-output-resolution.ps1 (line 58) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeItemResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of WorktreeRunResolution.psm1 (line 66) does not record it through Add-HookDependencyFailure', 'S2: the catch of OrchestratorStateEpicWaveBarrier.psm1 (line 73) does not record it through Add-HookDependencyFailure').
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
FAILED: S2: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 41) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 45) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 46) is not in its own single-statement try').
FAILED: S2: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 9) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-helpers.ps1 (line 14) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-modes.ps1 (line 20) is not in its own single-statement try', 'S2: enforce-orchestration-preimplementation-gate-epic-scope.ps1 (line 25) is not in its own single-statement try', 'S2: hook-command-scanner.ps1 (line 28) is not in its own single-statement try', 'S2: hook-command-invocation.ps1 (line 29) is not in its own single-statement try').
FAILED: S2: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try | Expected $null or empty, but got @('S2: HookPayload.psm1 (line 62) is not in its own single-statement try', 'S2: enforce-batch-budget-route.ps1 (line 63) is not in its own single-statement try').
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
FAILED: S4: repository claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/validate-bash.ps1:41 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:45 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:46 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:9 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:14 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:20 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:25 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:28 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:29 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:55 EpicScopeReadiness.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:57 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/enforce-powershell-batch-budget.ps1:62 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-powershell-batch-budget.ps1:63 enforce-batch-budget-route.ps1 is neither guarded nor covered').
FAILED: S4: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got 'S4: .claude/hooks/validate-orchestrator-output.ps1:51 OrchestratorState.psm1 is neither guarded nor covered'.
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
FAILED: S4: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/validate-bash.ps1:41 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:45 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/validate-bash.ps1:46 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:22 hook-command-payload.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:23 hook-command-payload-powershell.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:24 hook-command-invocation-operands.ps1 is neither guarded nor covered').
FAILED: S4: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:9 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:14 enforce-orchestration-preimplementation-gate-helpers.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:20 enforce-orchestration-preimplementation-gate-modes.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:25 enforce-orchestration-preimplementation-gate-epic-scope.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:28 hook-command-scanner.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:29 hook-command-invocation.ps1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:55 EpicScopeReadiness.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:57 enforce-orchestration-preimplementation-gate-targets.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-scanner.ps1:20 hook-command-heredoc.ps1 is neither guarded nor covered', 'S4: .claude/hooks/hook-command-invocation.ps1:21 hook-command-scanner.ps1 is neither guarded nor covered', ...3 more).
FAILED: S4: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating | Expected $null or empty, but got @('S4: .claude/hooks/enforce-powershell-batch-budget.ps1:62 HookPayload.psm1 is neither guarded nor covered', 'S4: .claude/hooks/enforce-powershell-batch-budget.ps1:63 enforce-batch-budget-route.ps1 is neither guarded nor covered').
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
FAILED: S5: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
FAILED: S5: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
FAILED: S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got 'S5: runtime import of DiscoveryValidation.psm1 at .claude/hooks/validate-discovery-artifact-gate.ps1:73 is not pre-loaded under a guard'.
FAILED: S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard | Expected $null or empty, but got @('S5: runtime import of OrchestratorStateCompletion.psm1 at .claude/hooks/validate-orchestrator-output.ps1:295 is not pre-loaded under a guard', 'S5: runtime import of OrchestratorStateUnconditional.psm1 at .claude/lib/orchestrator-state/OrchestratorState.psm1:431 is not pre-loaded under a guard').
FAILED: S6: repository claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-DiscoveryArtifactGateValidation does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-FeatureReviewCoverageValidation does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PlannerOutputValidation does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PrdFeatureOutputValidation does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Get-PrAuthorOutputDecision does not return the dependency decision first'.
FAILED: S6: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestratorOutputValidation does not return the dependency decision first'.
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
FAILED: S6: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-ValidateBashDecision does not return the dependency decision first'.
FAILED: S6: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-OrchestrationPreimplementationGateDecision does not return the dependency decision first'.
FAILED: S6: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function | Expected $null or empty, but got 'S6: Invoke-PowerShellBatchBudgetDecision does not return the dependency decision first'.
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
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails | simulated load failure: OrchestratorState.psm1
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty
FAILED: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | feature-review hook: CLAUDE_HOOK_INPUT is empty; cannot validate review output.
FAILED: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | atomic-planner hook: CLAUDE_HOOK_INPUT is empty; cannot validate planner output.
FAILED: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | prd-feature hook: CLAUDE_HOOK_INPUT is empty.
FAILED: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.
FAILED: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
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
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
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
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
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
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
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
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
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
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
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
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
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
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
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
PASSED: S6: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
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
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
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
PASSED: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
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
PASSED: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
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
PASSED: B4: has a reason-prefix entry for every discovered Claude hook and no other
```
