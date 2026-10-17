# AC-11 Temporary-File and Live-Checkpoint Check (P10-T13)

Timestamp: 2026-09-29T20-54
Command: git grep -n -F -e 'New-TemporaryFile' -e 'GetTempFileName' -e 'GetTempPath' -e 'TestDrive' -e 'Set-Content' -e 'Out-File' -e 'New-Item' -- tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1; git grep -c -F -e 'Invoke-PythonBatchBudgetHook:ReadCheckpoint' -- tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1; git grep -c -F -e 'ReadCheckpoint = {' -- tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Negative search: exit 1, no output.
- CPYTEST: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1:2
- XTEST: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1:2 (both rows inject an empty checkpoint).
