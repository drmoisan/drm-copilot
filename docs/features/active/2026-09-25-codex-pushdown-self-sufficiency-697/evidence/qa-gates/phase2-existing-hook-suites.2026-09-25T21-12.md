# Phase 2 Existing Hook Suites (Issue #697, AC-3.9)

## codex-planning-only-hook

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## epic-execution-gates

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 50, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## legacy-codex-hook-contracts

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 43, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## codex-epic-runtime-contracts

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## codex-pretooluse-integration

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## codex-detached-head-transport

Timestamp: 2026-09-25T21-12
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 12, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

The `codex-epic-runtime-contracts.Tests.ps1` run includes `[+] keeps root and tracked bundle runtime copies byte-identical` (AC-3.9).
