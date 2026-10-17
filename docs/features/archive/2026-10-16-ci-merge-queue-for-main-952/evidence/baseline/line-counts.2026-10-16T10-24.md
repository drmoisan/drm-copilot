# Baseline Line Counts (P0-T7)

Timestamp: 2026-10-16T10-24
Command: git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py .claude/agents/epic-orchestrator.md .claude/skills/cleanup-merged-worktrees/SKILL.md
EXIT_CODE: 0
Output Summary: thirteen lines; the set equals the planner-read mapping (merged tree 1195107340f811b565a2ee311e1ad3ce731c5680); no missing, extra or different line.

Output (verbatim):
```
.claude/agents/epic-orchestrator.md:168
.claude/hooks/enforce-epic-merge-gate.ps1:472
.claude/skills/cleanup-merged-worktrees/SKILL.md:579
.codex/hooks/enforce-epic-merge-gate.ps1:385
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:435
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:181
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:465
tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:205
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:99
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:438
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:387
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:426
tests/scripts/workflows/CiWorkflow.Tests.ps1:174
```
