# Suite Evidence: dispatch rows ([P4-T2])

Timestamp: 2026-11-04T00-47
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml); git -C <worktree root> diff --numstat fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3 -- .claude/lib/docs/Invoke-DocsCommand.ps1
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsLedgerCommands.Tests.ps1 tests=21 failures=0 errors=0 (including the two dispatch-row cases); Invoke-DocsCommand.Tests.ps1 tests=46 failures=0 errors=0 (unchanged, the disposition [P0-T1] selected). `git diff --numstat MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1` reports `3 0`: three rows added under `# --- 1023: coverage, update-ledger, validate ---`, no line deleted. Line coverage of `.claude/lib/docs/Invoke-DocsCommand.ps1`: 87.58 (134 covered, 19 missed; baseline 87.33, the three rows are covered). The run exit 4 is the four Docs.Manifest.Tests.ps1 cases deferred to Phase 6.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 21 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 46 | 0 | 0 | 0 |

[P4-T2] tests (`Describe 'Dispatch rows'`): `Get-DocsCommandTable carries the coverage, update-ledger and validate rows bound to DocsLedgerCommands.psm1` (membership by name, `Module` file name, `Function` values, option sets with `Page` as `multi` and `Write`/`WriteReceipt` as `switch`, and the rows' text position between the 1023 and 1024 anchors), `Test-DocsCommandTable returns no finding for the committed table`.

## MERGE_BASE

`MERGE_BASE` = merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD` = `fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3` (the branch point; recorded here as the derivation result of the plan's definition, not as a plan citation).

Numstat row: `3	0	.claude/lib/docs/Invoke-DocsCommand.ps1`. The anchor `# --- 1023: coverage, update-ledger, validate ---` occurs once. The bundle copy receives the same rows in Phase 6 ([P6-T1]).
