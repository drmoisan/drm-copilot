# Isolation Runs

Timestamp: 2026-10-29T11-44
Task: [P6-T9]
Command: for seed in 995 4242 31337: Invoke-Pester over the 19 touched suites in one PowerShell 7 process per seed, file order shuffled by System.Random($seed), coverage off (`sh SCRATCH/issue-995-isolation.sh`); poetry run pytest --no-cov -q -p no:randomly <the 13 [P6-T5] modules in reversed order> in one process
EXIT_CODE: 0
Output Summary: all three seeded shuffled Pester runs report 474 passed, 0 failed, 0 skipped; the reversed-order Python run reports 233 passed, 0 failed. No order dependence was found.

## Pester, seed 995 (474 passed, 0 failed, 0 skipped)

1. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
2. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
3. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
4. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
5. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
6. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
7. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
8. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
9. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
10. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
11. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
12. tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1
13. tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
14. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
15. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
16. tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1
17. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1
18. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
19. tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1

## Pester, seed 4242 (474 passed, 0 failed, 0 skipped)

1. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
2. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
3. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
4. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
5. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
6. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
7. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
8. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1
9. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
10. tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
11. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
12. tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1
13. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
14. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
15. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
16. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
17. tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1
18. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
19. tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1

## Pester, seed 31337 (474 passed, 0 failed, 0 skipped)

1. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
2. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
3. tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
4. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
5. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
6. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
7. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
8. tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1
9. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1
10. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
11. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
12. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
13. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
14. tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
15. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
16. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
17. tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
18. tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1
19. tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1

## Python, reversed module order (233 passed, 0 failed)

Order: test_codex_agent_wrapper_contracts.py, test_push_down_pack_manifest_dependency_closure.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_claude_resource_contracts.py, test_execution_environment_brief_contracts.py, test_claude_rules_frontmatter.py, test_orchestrator_state_remediation_docs.py, test_parallel_issue_adoption_skill_contracts.py, test_ci_gate_all_checks_contracts.py, test_parallel_complexity_routing_contracts.py, test_completion_gate_documentation_contracts.py, test_parallel_orchestrator_permission_contracts.py, test_parallel_orchestrator_surface_contracts.py (all under tests/scripts/dev_tools/).

The fresh single-process run over tests/scripts is recorded in qa-gates/pester-coverage.2026-10-29T11-40.md ([P6-T3]).
