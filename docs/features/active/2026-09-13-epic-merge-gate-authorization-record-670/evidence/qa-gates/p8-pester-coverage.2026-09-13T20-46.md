# Phase 8 Testing With Coverage — Issue #670

Timestamp: 2026-09-17T08-52
Task: [P8-T4]
Loop pass: 2
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')
EXIT_CODE: 2

Execution note: `tests/powershell` is removed from the scan list for the reason recorded in `phase0-pester-coverage.2026-09-13T20-46.md` (the folder does not exist; the executed test set is unchanged). Exit code 2 is `Run.Exit` reporting the failures below.

## Fixed failed-count derivation (JUnit)

`artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:45:35), `testsuites` element:

| Attribute | Value |
| --- | --- |
| `tests` | 4627 |
| `failures` | 2 |
| `errors` | 0 |

Failing nodes (identical to the Phase 0 baseline; environmental; outside the change surface):

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:145`)
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:165`; `EPIC_WAVE_BARRIER_BLOCKED: '670' ...`)

Both depend on the live, gitignored `artifacts/orchestration/orchestrator-state.json` of this #670 epic-child run, which the delegation forbids editing. No merge-gate case failed: all three new suites and the five existing merge-gate suites passed within this run.

## Coverage

Source: `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:44:42), fixed derivation, `line`-element form.

| File | Covered | Total | Line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 100 | 100 | 100.00 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 116 | 120 | 96.67 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 150 | 151 | 99.34 |

Total line coverage: 95.56% (covered 9092, missed 422).

Output Summary:
- JUnit counts: tests=4627, failures=2, errors=0. The acceptance requires the failed count to print 0; it prints 2, so [P8-T4] stays unchecked. The two failures are the pre-existing environmental cases present since the Phase 0 baseline (4547 tests, 2 failures), and the change added 80 passing tests with no new failure.
- Total line coverage 95.56%; per-file 100.00% / 96.67% / 99.34%.
