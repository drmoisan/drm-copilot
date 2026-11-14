# Task Check - P4-T3 failed gate attempt and fixes

Timestamp: 2026-11-13T19-22
Command: sh SCRATCH/issue-1161-tc-fix2.sh (Invoke-Formatter and Invoke-ScriptAnalyzer on the edited suite; New-PesterConfiguration with Run.Path set to the selection and PassThru; env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov over the pack-manifest and resource contract tests)
EXIT_CODE: 0
Output Summary: format drift 0, PSScriptAnalyzer 0; Pester selection 644 tests, 644 passed, 0 failed; pytest 45 passed. This is a task check, not a gate; the P4-T3 gate is re-run from the start of the QA loop.

## Failed gate attempt (not the P4-T3 artifact)

Command: sh SCRATCH/issue-1161-pester-gate.sh (one Invoke-PoshQCParallelTest run, started 2026-11-13T19-05)
EXIT_CODE: 1
Result: 8 workers, wall clock 808.76 s; shards 1 and 7 exited non-zero; no merged artifact was written. Shard counts from shard.log: 1: 546 passed, 1 failed; 2: 2953/0; 3: 3667/0; 4: 2555/0; 5: 3047/0; 6: 3327/0; 7: 4009 passed, 2 failed; 8: 2560/0.

Failures:

1. `discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1 complies with the baseline isolation form for every closure seam`: Mock of Get-WorktreeItemCheckpointText and of Get-WorktreeItemLiveRoot missing from outermost BeforeAll. Cause: the suite's outermost BeforeAll called Register-EpicStateBaselineMock before the adapter dot-source, and the guard credits a helper registration only after the hook dot-source. The earlier task checks did not select the discovery guard. Fix: the adapter is dot-sourced first; the helper then registers the two item seams; the run seam is mocked directly with `Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith { $null }`, so the helper's R1 branch does not also mock Get-PlannerWorktreeCheckpointText, whose real body the seam-body rows test. No assertion changed.
2. `Committed process-reduction ledger chain.PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS`: ledger entry 0010's stored patch hunks on both `pack-manifests/core.json` files no longer applied. Cause: P3-T4 inserted `.claude/hooks/enforce-worktree-removal-gate-planner.ps1` and `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` inside the three-line context window after the 0010 added line. Fix: each entry moved to directly after its helper entry (`hook-planner-worktree-removal.ps1`), outside the window; the manifests are unordered and keep the same members. The ledger record and patch are not edited. No other ledger patch touches the manifests.

## Changed files

- tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json

## Selection and rule

Rule (Test Cadence): the suite itself and every test that names or enumerates it (the discovery guard enumerates the hook-suite directory); for the manifests, the tests that read them: the ledger chain suite, legacy-codex-hook-contracts.Tests.ps1, and the pack-manifest and resource contract tests.

| Step | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| Format and analyze | Invoke-Formatter, Invoke-ScriptAnalyzer on the edited suite | 0 | drift 0, findings 0 |
| Pester | tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1, tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 0 | 644 passed, 0 failed |
| pytest | test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py | 0 | 45 passed |
