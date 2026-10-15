# Baseline: batch-budget analysis ([P0-T27])

Timestamp: 2026-10-09T21-06
Command: none (analysis of .claude/hooks/enforce-python-batch-budget.ps1 and .claude/hooks/enforce-powershell-batch-budget.ps1, read in full in [P0-T2])
Output Summary: two production Python files are edited, within the cap of three; no production PowerShell file is edited; no reset is scheduled.

1. Cap: in direct mode the Python hook allows at most 3 distinct production Python files per session (`[int] $ProdCap = 3`, Invoke-PythonBatchBudgetHook; the 4th distinct path is denied with PYTHON_LARGE_PATH_REQUIRED). Test files are never counted: enforce-python-batch-budget.ps1 line 302 (`(^|/)tests/.*\.py$` or `(^|/)test_[^/]+\.py$`). PowerShell test files are never counted: enforce-powershell-batch-budget.ps1 line 299 (`(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$`).
2. Production Python files this plan edits (2): scripts/dev_tools/check_quality_tiers.py and scripts/dev_tools/potential_to_issue.py. The new support module tests/scripts/dev_tools/quality_tiers_contract_test_support.py is under tests/ and is not counted. No production PowerShell file is edited (tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 is a test file).
3. Resets scheduled: 0
4. Instruction: if either hook denies a write during execution, stop and report the exact denial text; do not reset budget state or work around the hook.
