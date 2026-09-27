# N1 Structure Checks (P1-T1 through P1-T3)

## P1-T1

Timestamp: 2026-09-27T10-07
Command: Route C (scratchpad parse-n1.ps1: Parser::ParseFile on tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1, line count, static It count, and a count of each of the seven quoted suite paths; run by `pwsh -NoProfile -File` via `sh` from the worktree root)
EXIT_CODE: 0
Output Summary:
PARSE-ERRORS: 0
LINES: 206
STATIC-IT-BLOCKS: 1
PATH-LITERAL count=1 for each of the seven S1-S7 file names (quoted as 'tests/scripts/claude-hooks/<name>').
Batch budget: no denial on the write of N1 (batch B1).

## P1-T2

Timestamp: 2026-09-27T10-08
Command: Route C parse-n1.ps1 (as above) after adding Context 'guard predicate discrimination'
EXIT_CODE: 0
Output Summary:
PARSE-ERRORS: 0
LINES: 357
STATIC-IT-BLOCKS: 4 (structural path It, compliant-form It with 2 rows, non-compliant It with 6 rows, missing-path It): 9 predicate rows (2 + 6 + 1), all built with Parser::ParseInput over single-quoted here-string fixtures, except row 9, which calls Get-EpicStateIsolationSuiteFinding on /synthetic-worktrees/missing/enforce-missing.Tests.ps1.

## P1-T3

Timestamp: 2026-09-27T10-09
Command: Route C parse-n1.ps1; Route C cr-format.ps1 and cr-pssa.ps1 with -ListName LIST-NEW (construction-time checks); Route C cr-pester-list.ps1 -ListName LIST-NEW (It-expansion count)
EXIT_CODE: 0
Output Summary:
PARSE-ERRORS: 0
LINES: 432 (at most 500)
STATIC-IT-BLOCKS: 6
Pester expansion count: TOTAL Passed=17 + Failed=7 = 24 It expansions (7 structural path rows + 9 predicate rows + 4 control rows + 4 treatment rows).
Construction-time quality fixes applied to N1 only: the repository formatter (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, same normalization as Invoke-PoshQCFormat) aligned assignment statements and one continuation indent; the BeforeDiscovery shape list was renamed to $script:HostileShapes (precedent tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1) to clear PSUseDeclaredVarsMoreThanAssignments. After the fixes: FORMAT-DRIFT-COUNT: 0 and PSSA-TOTAL: 0 for N1.
Line endings: LF, matching the seven suites.
