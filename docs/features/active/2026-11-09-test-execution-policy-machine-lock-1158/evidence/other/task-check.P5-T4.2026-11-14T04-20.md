# Task Check: P5-T4

Timestamp: 2026-11-14T04-20
Command: sh SCRATCH/issue-1158-psstatic.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on the changed test file); JSON parse of `.vscode/tasks.json` with comment lines removed; sh SCRATCH/issue-1158-jsoncheck.sh (`npx prettier --check .vscode/tasks.json`, `poetry run python -m scripts.dev_tools.validate_json`); sh SCRATCH/issue-1158-pester-files.sh (Run.Path = the selection below, Run.Exit $true)
EXIT_CODE: 0
Output Summary: PowerShell format diffs 0, PSSA findings 0; tasks.json parses; validate_json exit 0; Prettier reports `.vscode/tasks.json` as unformatted, which the committed file at HEAD already is (tab indentation across the whole file, pre-existing, not changed by this task); Pester selection 35 passed, 0 failed.

## Changed Files

- `.vscode/tasks.json` (`QC: 4 Pytest: run tests (parallel)`, `QC: 4 Pytest: run tests with coverage (parallel)`, `PoshQC: 4 test (Pester, parallel)`, `Shell QC: 4 bats: run tests`, `TS: 4 Jest: unit tests`, `TS: 4 Jest: unit tests with coverage` now run `pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 <suite>`; the three serial debugging tasks stay direct)
- `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1` (new cases `VT-TEST-TASKS-USE-LAUNCHER`, six rows, and `VT-SERIAL-TASKS-DIRECT`, three rows, placed after the recorded `0001` block)
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (ledger rule: the `QC: 4 Pytest: run tests (parallel)` default-group block regenerated to carry `"command": "pwsh",`; `Rebased over #1158` paragraph added)

## Selection and Rule

Rule: for a changed configuration path, the contract tests that read it (`## Test Cadence (Mandatory)`); for the changed ledger entry, the ledger contract tests.

- Pester: `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format (PowerShell) | Invoke-Formatter comparison on the test file | 0 (0 diffs) |
| lint (PowerShell) | Invoke-ScriptAnalyzer with the repository settings | 0 (0 findings) |
| JSON | parse of `.vscode/tasks.json`; `validate_json` | 0 |
| Prettier | `npx prettier --check .vscode/tasks.json` | 1 (pre-existing at HEAD) |
| tests | Pester `Run.Path` = three files, `Run.Exit` = `$true` | 0 |

Type check: not applicable (PowerShell and JSON).
