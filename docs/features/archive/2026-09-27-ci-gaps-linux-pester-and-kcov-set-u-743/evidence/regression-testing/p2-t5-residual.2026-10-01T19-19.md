# P2-T5 Residual Windows Literal in the Routing Suites

Timestamp: 2026-10-01T19-19
Command: grep -c -F -e 'C:/synthetic-absent-root' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary:
```
tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1:1
tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1:1
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1:1
tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1:1
```
Acceptance: four lines, each ending `:1` (only the Windows branch of the R2a line remains). Met.
