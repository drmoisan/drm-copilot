# Phase 1 PowerShell Test and Coverage Gate

- Task: `P1-T4`
- Command provider: bundled PoshQC MCP `run_poshqc_test`
- Workspace root: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25`
- Result: `FAIL`
- Provider result: `ok=false`
- Exit code: `1`
- Provider stderr excerpt: five lines containing `payload failure`

## Pester JUnit Result

- Tests: `2430`
- Passed: `2420`
- Failures: `1`
- Errors: `0`
- Skipped/disabled: `9`
- Duration: `118.126` seconds
- JUnit SHA-256: `777B34773BF5DC09E3A15BD50B9A221797791860F8CE6CCC7230414AFF52389C`

The single failure is
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:195-196`,
`leaves no Codex batch-budget state behind`. It expected `.codex/state` not to
exist after benign payloads, but the active session state directory existed.
This is the same first unexpected baseline failure recorded by `P0-T3`; this
task did not delete the active state or rerun the test.

## Machine-Readable Coverage

- Coverage file: `artifacts/pester/powershell-coverage.xml`
- Coverage SHA-256: `B99C83956704F2C0D8F8FB2801442C4C0809CC8262D0F9C12BB5D4464AB2DB8B`
- Instructions: `5489 / 5814`
- Lines: `4040 / 4260` (`94.835681%`)
- Methods: `336 / 363`
- Classes: `50 / 52`
- Counter types: `CLASS,INSTRUCTION,LINE,METHOD`
- Source lines with non-zero `mb` or `cb`: `0`
- Source-attributable branch denominator: `0`

The ordinary test gate is non-green because of the preserved active-state
failure. The coverage artifact also cannot satisfy the PowerShell branch gate.
