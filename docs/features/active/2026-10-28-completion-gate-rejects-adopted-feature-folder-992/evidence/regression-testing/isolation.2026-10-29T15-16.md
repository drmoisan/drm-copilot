# Test Isolation Runs (P6-T8, AC-18)

Timestamp: 2026-10-29T15-16
Command: node run-jest.cjs --randomize --seed=992 (in extensions/drm-copilot); poetry run pytest <three modules> -p issue_992_reverse (SCRATCH plugin that reverses collected items); Invoke-Pester over the six touched suites in System.Random(seed) file order (sh SCRATCH/issue-992-ps.sh shuffle -SeedList 992,4242,20261029); Invoke-PoshQCTest -Root <worktree> single process (P6-T6)
EXIT_CODE: 0
Output Summary: Every isolation run passed with zero failures. Jest seed 992 (also 4242 and 20261029): 4172 of 4172. Python reversed order: 112 passed. Pester shuffled file order, seeds 992, 4242, 20261029 (repeated with 7, 77, 777): 202 passed per seed, 0 failed. Fresh single-process tests/scripts run: 12104 tests, 0 failures.

## Jest (seeded shuffle)

| Seed | Result |
| --- | --- |
| 992 (recorded seed; output line `Seed: 992`) | 282 suites, 4172 tests passed, 0 failed |
| 4242 | 282 suites, 4172 tests passed, 0 failed |
| 20261029 | 282 suites, 4172 tests passed, 0 failed |

## Python (reversed order, one process)

Modules, in plan order: `test_orchestrator_state_issue_adoption_feature_folder.py`, `test_orchestrator_state_issue_adoption_waivers.py`, `test_orchestrator_state_issue_adoption_parity.py`. The SCRATCH plugin reversed every collected item, so the run began with `test_orchestrator_state_issue_adoption_parity.py::test_corpus_document_reproduces_the_expected_routing_errors[waives-validate-orchestration-artifacts]` and ended with the first test of the first module. Result: 112 passed, 0 failed. A module-order-only reversal (parity, waivers, feature_folder) also passed 112.

## Pester (shuffled file order, one process per seed)

| Seed | File order | Result |
| --- | --- | --- |
| 992 | validate-orchestrator-output.FeatureFolder > OrchestratorStateIssueAdoption.Parity > OrchestratorState.Manifest > validate-orchestrator-output > OrchestratorStateIssueAdoption > OrchestratorStateFeatureFolderRecord | 202 passed, 0 failed |
| 4242 | validate-orchestrator-output.FeatureFolder > OrchestratorStateIssueAdoption > validate-orchestrator-output > OrchestratorStateFeatureFolderRecord > OrchestratorStateIssueAdoption.Parity > OrchestratorState.Manifest | 202 passed, 0 failed |
| 20261029 | OrchestratorStateFeatureFolderRecord > validate-orchestrator-output > OrchestratorStateIssueAdoption.Parity > validate-orchestrator-output.FeatureFolder > OrchestratorStateIssueAdoption > OrchestratorState.Manifest | 202 passed, 0 failed |

Seeds 7, 77, and 777 were also run with 202 passed and 0 failed each.

## Fresh single-process run over tests/scripts

`evidence/qa-gates/ps-pester.2026-10-29T15-15.md`: tests=12104, failures=0, errors=0, skipped=10.

## Test hygiene observations (AC-18)

- No new test starts git: the hook suite injects recording invokers through `-FeatureFolderGitInvoker`; `git` is neither executed nor mocked.
- No temporary file is created; checkpoints are in-memory JSON, and Python and Jest suites read only committed corpus fixtures.
- No drive-letter path in the hook suite (worktree root `/synthetic-worktrees/feature-folder-session`); drive-letter strings appear only as rejected path-pattern inputs in the module suites.
- No suite reads the worktree's gitignored `artifacts/` checkpoint.
