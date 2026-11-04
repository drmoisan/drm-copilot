# Seeded Shuffled Pester File-Order Runs (Issue #1074)

Timestamp: 2026-11-04T15-51
Task: [P6-T7]
Command: sh SCRATCH/issue-1074-shuffle.sh (PowerShell 7 script SCRATCH/issue-1074-shuffle.ps1: for each seed, a Fisher-Yates shuffle of the four files with System.Random(seed), then one Invoke-Pester process run over that file order with JUnit output SCRATCH/issue-1074-shuffle-seed-<seed>.xml; the launcher sets no strict mode and no coverage)
EXIT_CODE: 0
Output Summary:
- Files: `tests/scripts/ci/CiRequiredGate.Tests.ps1`, `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`, `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`.
- Seed 11: order CiChangeScopeWorkflow > CiRequiredGateWorkflow > CiRequiredGate > Invoke-CiRequiredGate (JUnit suite order matches); JUnit tests 166, failures 0, errors 0.
- Seed 42: order Invoke-CiRequiredGate > CiChangeScopeWorkflow > CiRequiredGate > CiRequiredGateWorkflow (JUnit suite order matches); JUnit tests 166, failures 0, errors 0.
- Seed 1074: order Invoke-CiRequiredGate > CiRequiredGate > CiRequiredGateWorkflow > CiChangeScopeWorkflow (JUnit suite order matches); JUnit tests 166, failures 0, errors 0.
- No order dependence found.
