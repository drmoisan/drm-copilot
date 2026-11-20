# Integration Scenario: Seed a Run from Prepared Items

Timestamp: 2026-11-03T13-39
Task: [P7-T1]
Command: sh-launched PowerShell 7 Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 (counts from artifacts/pester/pester-junit.xml); bash .claude/lib/bash/validate-parallel-manifest.sh tests/fixtures/parallel_admission/seed-parallel.md; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-planner-state tests/fixtures/parallel_admission/seed-planner-state.json --require-ready-for-execution; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state tests/fixtures/parallel_admission/seed-orchestrator-state.json
EXIT_CODE: 0
Output Summary: Describe `Seed from prepared items`: 8 tests, 8 passed, 0 failed. validate-parallel-manifest.sh exit 0 (print-mode `open`); parallel-planner-state with --require-ready-for-execution exit 0 ("validation passed"); parallel-orchestrator-state exit 0 ("validation passed"). All three validators are the branch-current repository entry points.

Evidence scope: local evidence only. The scenario drives the helper functions against in-memory branch trees behind a mocked Invoke-ParallelAdmissionGit and committed fixtures read as text; it performs no network call and no GitHub mutation, and writes no file.

## Describe `Seed from prepared items` (JUnit)

| Test | Result |
| --- | --- |
| assesses item 1101 as cleared and fresh with admit_prepared | PASS |
| assesses item 1102 as cleared and fresh with admit_prepared | PASS |
| orders the cohorts into the fixture cohort table | PASS |
| accepts the seeded orchestrator cohort table | PASS |
| rejects a swapped cohort table with precedence_violated | PASS |
| builds the committed scheduling record | PASS |
| reuses recorded edges read by ref from the plan branch for a matching plan hash | PASS |
| recomputes recorded edges when the plan hash changed | PASS |

## Validators

| Validator | Input | Exit |
| --- | --- | --- |
| .claude/lib/bash/validate-parallel-manifest.sh | tests/fixtures/parallel_admission/seed-parallel.md | 0 |
| validate_orchestration_artifacts parallel-planner-state --require-ready-for-execution | tests/fixtures/parallel_admission/seed-planner-state.json | 0 |
| validate_orchestration_artifacts parallel-orchestrator-state | tests/fixtures/parallel_admission/seed-orchestrator-state.json | 0 |
