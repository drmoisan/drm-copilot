# No-Python Checks ([P9-T7])

Timestamp: 2026-10-10T00-41
Command: (a) `git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a -- <the three no-Python guard files>` and `git status --porcelain -- tests/scripts/claude-runtime`; (b) R-SCOPED over tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1; (c) for each of the 57 production files selected in [P9-T6], the added lines of `git diff -U0 86e457a003be0c60b65e01156e4cccd6495dfd1a -- <file>` matched case-insensitively against `python|poetry`
EXIT_CODE: 0
Output Summary: (a) neither listing names any of the three guard files (GUARD_FILES_NAMED: 0). (b) PassedCount 32, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. (c) 53 files count 0; 4 files count 3 each: .claude/hooks/check-python-test-purity.ps1, .claude/hooks/enforce-python-batch-budget.ps1, .codex/hooks/check-python-test-purity.ps1, .codex/hooks/enforce-python-batch-budget.ps1. In every case the matched lines are the section 2.2(d)/(e) decision-check and tail lines, and the match is the hook's R-PREFIX string literal fixed by section 3 (`Python unit test purity hook:`, `PYTHON_LARGE_PATH_REQUIRED:`, `check-python-test-purity:`). None of them invokes Python.
ACCEPTANCE-GAP: (c) requires every count to be 0. That cannot hold, because the section 2.2 lines that the plan requires in these four hooks carry R-PREFIX values that contain the word "python". The (c) counts are recorded as measured. [P9-T7] is left unchecked and escalated as a plan defect (deviations.md, [P9-T7]). (a) and (b) pass, and no added line invokes Python.

```text
(a) git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a -- <three guard files>:
(a) git status --porcelain -- tests/scripts/claude-runtime:
(a) GUARD_FILES_NAMED: 0

(c) PYTHON_POETRY_ADDED: .claude/hooks/check-powershell-test-purity.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/check-python-test-purity.ps1 | 3
    +    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'Python unit test purity hook:'
    +if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('Python unit test purity hook: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
    +$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'Python unit test purity hook:'
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-completion-consistency.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-invocation-origin.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-merge-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-wave-barrier.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-evidence-locations.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-feature-folder-order.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-mermaid-validation.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-model-routing-receipt.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-parallel-drift-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-powershell-batch-budget.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-pr-author-skill.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-promotion-mcp-only.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/enforce-python-batch-budget.ps1 | 3
    +    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PYTHON_LARGE_PATH_REQUIRED:'
    +if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PYTHON_LARGE_PATH_REQUIRED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
    +$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PYTHON_LARGE_PATH_REQUIRED:'
(c) PYTHON_POETRY_ADDED: .claude/hooks/hook-dependency-guard.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-bash.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-discovery-artifact-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-feature-review-coverage.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-orchestrator-output.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-planner-output.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-pr-author-output.ps1 | 0
(c) PYTHON_POETRY_ADDED: .claude/hooks/validate-prd-feature-output.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/check-powershell-test-purity.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/check-python-test-purity.ps1 | 3
    +    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'check-python-test-purity:'
    +if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('check-python-test-purity: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
    +$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'check-python-test-purity:'
(c) PYTHON_POETRY_ADDED: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-codex-model-routing.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-completion-consistency.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-merge-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-planning-only.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-root-invocation.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-wave-barrier.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-evidence-locations.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-powershell-batch-budget.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-promotion-mcp-only.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/enforce-python-batch-budget.ps1 | 3
    +    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PYTHON_LARGE_PATH_REQUIRED:'
    +if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PYTHON_LARGE_PATH_REQUIRED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
    +$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PYTHON_LARGE_PATH_REQUIRED:'
(c) PYTHON_POETRY_ADDED: .codex/hooks/hook-dependency-guard.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/validate-bash.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/validate-codex-subagent-routing.ps1 | 0
(c) PYTHON_POETRY_ADDED: .codex/hooks/validate-feature-review-coverage.ps1 | 0
```

```text

Starting discovery in 1 files.
Discovery found 32 tests in 138ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 3.42s (2.99s|306ms)
Tests completed in 3.43s
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 32
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | result=Passed | passed=32 | failed=0
PASSED: ships an empty allowlist
PASSED: detects a bare python invocation
PASSED: detects an ampersand-invoked python invocation
PASSED: detects a dot-invoked python invocation
PASSED: detects a quoted python constant invocation
PASSED: detects python3, py, and poetry as interpreter commands
PASSED: detects an interpreter name written in mixed case
PASSED: detects a subprocess start whose FilePath is an interpreter
PASSED: detects a subprocess start whose first positional argument is an interpreter
PASSED: reports no finding for a subprocess start targeting an unrelated executable
PASSED: detects an ampersand-invoked variable that is not a scriptblock parameter
PASSED: detects an ampersand-invoked expression in the command position
PASSED: detects an Invoke-Expression call
PASSED: detects the built-in alias of Invoke-Expression
PASSED: reports no finding for interpreter names inside string literals
PASSED: reports no finding for interpreter names inside comments
PASSED: reports no finding for function names beginning with Invoke-Python
PASSED: reports no finding for a scriptblock-parameter seam invocation
PASSED: reports no finding when a seam variable differs from its parameter by letter case
PASSED: reports no finding for dot-sourcing a sibling helper path variable
PASSED: reports no finding for dot-sourcing an inline sibling helper path
PASSED: still reports a dot-sourced expression that is not a Join-Path call
PASSED: still reports a Join-Path load that does not resolve a ps1 sibling
PASSED: still reports an ampersand-invoked inline sibling-load expression
PASSED: enumerates only the guarded roots and never the bundled mirror
PASSED: reports no Python invocation beyond the allowlist across the guarded tree
PASSED: carries no stale allowlist entry
PASSED: AC-15 claude hooks path is under a scan root
PASSED: AC-15 codex hooks path is under a scan root
PASSED: AC-15 bundled mirror path is outside every scan root
PASSED: AC-15 unrelated path is outside every scan root
PASSED: AC-15 enumeration includes at least one codex hooks file
```
