# Post-Change Coverage — Issue #670

Timestamp: 2026-09-17T08-34
Task: [P7-T1]
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')
EXIT_CODE: 2

Execution note: `tests/powershell` is removed from the scan list for the reason recorded in `phase0-pester-coverage.2026-09-13T20-46.md` (the folder does not exist; the executed test set is unchanged). This is the second post-change measurement. The first (JUnit tests=4614, failures=2; Codex hook 93.38%) was superseded after the [P7-T2] coverage remediation added Codex record-shape cases; see the addendum in `pass-after-codex-authorization.2026-09-13T20-46.md`.

## Fixed failed-count derivation (JUnit)

`artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:32:27), `testsuites` element:

| Attribute | Value |
| --- | --- |
| `tests` | 4627 |
| `failures` | 2 |
| `errors` | 0 |

Failing nodes (unchanged from the Phase 0 baseline; environmental, outside this change surface):

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Both read the live, gitignored `artifacts/orchestration/orchestrator-state.json` for this #670 epic-child run. The delegation instructions forbid editing that checkpoint.

## Per-file line coverage (fixed derivation, `line`-element form)

Source: `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:31:34).

| File | Covered | Total | Line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 100 | 100 | 100.00 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 116 | 120 | 96.67 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 150 | 151 | 99.34 |

Remaining uncovered lines are the pre-existing process entry-point tails: `.claude/hooks/enforce-epic-merge-gate.ps1` lines 478, 479, 480 and 483, and `.codex/hooks/enforce-epic-merge-gate.ps1` line 372.

Total line coverage: 95.56% (covered 9092, missed 422).

Output Summary:
- JUnit counts: tests=4627, failures=2, errors=0. The acceptance requires the failed count to print 0; it prints 2, so [P7-T1] stays unchecked. Both failures are the pre-existing environmental cases from the Phase 0 baseline.
- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`: 100.00%.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 96.67%.
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 99.34%.
- Total line coverage: 95.56%.
