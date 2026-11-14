# Test Isolation Runs (issue #1012)

Timestamp: 2026-10-31T11-33
Command: sh SCRATCH/issue-1012-isolation.sh (for each seed 1012, 4242, 90210: SCRATCH/issue-1012-shuffle.ps1 -Seed <seed> applies a seeded Fisher-Yates shuffle to the P2-T4 suite set and runs it in one PowerShell 7 process through Invoke-Pester with the repository runsettings, one New-PesterContainer per file in the seeded order, coverage disabled, and JUnit written to artifacts/pester/pester-junit.xml); then poetry run pytest -p no:cacheprovider -q --no-cov over the P5-T6 module list in reversed order
EXIT_CODE: 0
Output Summary:
- Seed 1012: total 1564, passed 1564, failed 0, skipped 0
- Seed 4242: total 1564, passed 1564, failed 0, skipped 0
- Seed 90210: total 1564, passed 1564, failed 0, skipped 0
- Python reversed module order: 235 passed, 0 failed
- No order dependence found.

## Route note

A first attempt passed the shuffled list to `Invoke-PoshQCTest -ScanFolders`. All three seeds passed (1564 of 1564 each), but the JUnit suite order was identical and alphabetical for every seed, so that attempt did not exercise a shuffled order. The run was therefore repeated through `Invoke-Pester` with one container per file, and the executed container order (from the Pester result object) and the JUnit suite order both match the seeded order below. Only the repeated runs are the evidence for this task.

## Seed 1012 (executed order)

1. enforcement-hooks-no-python-invocation.Tests.ps1
2. enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
3. validate-orchestrator-output-rejection.Tests.ps1
4. validate-orchestrator-output.Reentry.Tests.ps1
5. subagentstop-uncaught-error.Tests.ps1
6. validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
7. validate-orchestrator-output.Envelope.Tests.ps1
8. validate-orchestrator-output.Tests.ps1
9. validate-orchestrator-output.model-routing.Tests.ps1
10. validate-orchestrator-output.human-interaction.Tests.ps1
11. hook-dependency-failure.SpecialCases.Tests.ps1
12. validate-orchestrator-output.FeatureFolder.Tests.ps1
13. hook-dependency-guard-completeness.Tests.ps1
14. validate-orchestrator-output.MutationRejection.Tests.ps1
15. validate-orchestrator-output.WorktreeResolution.Tests.ps1
16. validate-orchestrator-output-resolution.Tests.ps1
17. hook-dependency-failure.Claude.Tests.ps1
18. validate-orchestrator-output.WaveBarrier.Tests.ps1

## Seed 4242 (executed order)

1. validate-orchestrator-output.Envelope.Tests.ps1
2. validate-orchestrator-output-resolution.Tests.ps1
3. validate-orchestrator-output-rejection.Tests.ps1
4. hook-dependency-failure.SpecialCases.Tests.ps1
5. validate-orchestrator-output.human-interaction.Tests.ps1
6. validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
7. validate-orchestrator-output.MutationRejection.Tests.ps1
8. hook-dependency-failure.Claude.Tests.ps1
9. validate-orchestrator-output.FeatureFolder.Tests.ps1
10. validate-orchestrator-output.WaveBarrier.Tests.ps1
11. validate-orchestrator-output.model-routing.Tests.ps1
12. validate-orchestrator-output.Tests.ps1
13. hook-dependency-guard-completeness.Tests.ps1
14. validate-orchestrator-output.Reentry.Tests.ps1
15. enforcement-hooks-no-python-invocation.Tests.ps1
16. subagentstop-uncaught-error.Tests.ps1
17. validate-orchestrator-output.WorktreeResolution.Tests.ps1
18. enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1

## Seed 90210 (executed order)

1. validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
2. validate-orchestrator-output.WorktreeResolution.Tests.ps1
3. validate-orchestrator-output-rejection.Tests.ps1
4. enforcement-hooks-no-python-invocation.Tests.ps1
5. enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
6. subagentstop-uncaught-error.Tests.ps1
7. validate-orchestrator-output.Reentry.Tests.ps1
8. validate-orchestrator-output.Tests.ps1
9. validate-orchestrator-output-resolution.Tests.ps1
10. hook-dependency-failure.SpecialCases.Tests.ps1
11. validate-orchestrator-output.FeatureFolder.Tests.ps1
12. hook-dependency-guard-completeness.Tests.ps1
13. validate-orchestrator-output.model-routing.Tests.ps1
14. validate-orchestrator-output.human-interaction.Tests.ps1
15. validate-orchestrator-output.Envelope.Tests.ps1
16. validate-orchestrator-output.WaveBarrier.Tests.ps1
17. validate-orchestrator-output.MutationRejection.Tests.ps1
18. hook-dependency-failure.Claude.Tests.ps1

Files under `tests/scripts/claude-hooks/` except the last two of the P2-T4 set, which are under `tests/scripts/claude-runtime/` (hook-dependency-guard-completeness.Tests.ps1 and enforcement-hooks-no-python-invocation.Tests.ps1).

## Python reversed order

Order: test_parallel_mutation_rejection_signal_contracts.py, test_parallel_complexity_routing_contracts.py, test_skill_bundle_contract_repo.py, test_parallel_abandon_token_seam.py, test_parallel_issue_adoption_skill_contracts.py, test_parallel_planner_surface_contracts.py, test_parallel_orchestrator_surface_contracts.py, test_claude_rules_frontmatter.py, test_push_down_issue_824_follow_ups.py, test_push_down_pack_manifest_dependency_closure.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_claude_resource_contracts.py (all under tests/scripts/dev_tools/), one process.

Result: 235 passed, 0 failed.
