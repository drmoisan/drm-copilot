# Integration Stage (issue #1009)

Timestamp: 2026-10-30T18-27
Command: SCRATCH/issue-1009-report.ps1 -NamePattern over artifacts/pester/pester-junit.xml from the final [P9-T5] run
EXIT_CODE: 0
Output Summary: every process-level integration row passed.

- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`: 11/11 passed, including `leaves no Codex batch-budget state behind`.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: 43/43 passed, including the process rows `fails closed with exit 2 and stderr for malformed stdin on every hook`, `ignores poisoned Claude variables when safe Codex stdin payloads are supplied`, `emits the current PreToolUse deny envelope for shell and patch violations`, and `parse-checks each root and bundled hook and keeps every file within 500 lines`.
- `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1` BB4 passed on the repository root and the mirror root for both hooks: `BB4 enforce-python-batch-budget.ps1 emits no deny for src/app.ts through the & route when enforce-batch-budget-route.ps1 fails to load (#984)` and `BB4 enforce-powershell-batch-budget.ps1 emits no deny for src/app.py through the & route when enforce-batch-budget-route.ps1 fails to load (#984)`.
