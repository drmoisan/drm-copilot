# Routing Edit Sites (P0-T7)

Timestamp: 2026-10-01T19-03
Command: grep -n -F -e 'C:/synthetic-absent-root' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: four lines, one per file:
```
tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1:303:                -Root 'C:/synthetic-absent-root' `
tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1:304:                -Root 'C:/synthetic-absent-root' `
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1:301:            $decision = Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'scripts/d.ps1') -SessionId 'routing' -Root 'C:/synthetic-absent-root' @seams
tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1:298:            $decision = Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'src/d.py') -SessionId 'routing' -Root 'C:/synthetic-absent-root' @seams
```
Acceptance: four lines at 303, 304, 301, 298 respectively. Met.
