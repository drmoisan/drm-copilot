# Final Line Counts (P8-T10, AC-26)

Timestamp: 2026-10-16T11-53
Command: git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py
EXIT_CODE: 0
Output Summary: 22 lines; every count is at or below 500 (maximum 469); scripts/dev-tools/Invoke-FullReleaseFlow.ps1 = 446, equal to its projection of 446

Output (verbatim):
```
.claude/hooks/enforce-epic-merge-gate-command.ps1:184
.claude/hooks/enforce-epic-merge-gate.ps1:441
.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1:203
.codex/hooks/enforce-epic-merge-gate-command.ps1:184
.codex/hooks/enforce-epic-merge-gate.ps1:364
scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1:92
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:446
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:181
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:190
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:469
tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1:121
tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1:39
tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:205
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:191
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:100
tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1:252
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:439
tests/scripts/dev_tools/merge_queue_documentation_expectations.py:147
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:393
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:446
tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py:62
tests/scripts/workflows/CiWorkflow.Tests.ps1:240
```
