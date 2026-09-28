Timestamp: 2026-09-27T16-00

Edit: replaced `$entries.Count | Should -BeGreaterThan 0` with
`Test-NonVacuousCollection -Value $entries | Should -BeTrue` at the same indentation and same line
position in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`.

Before this edit (per P0-T26): old-literal count = 1.

After this edit:

Command: sh <scratchpad>/run-ps.sh <scratchpad>/select-string-count.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Pattern '$entries.Count | Should -BeGreaterThan 0'
EXIT_CODE: 0
Output: 0

Command: sh <scratchpad>/run-ps.sh <scratchpad>/select-string-count.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Pattern 'Test-NonVacuousCollection -Value $entries | Should -BeTrue'
EXIT_CODE: 0
Output: 1

Command: sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
EXIT_CODE: 0
Output: tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 LineCount=391

Output Summary: All four counts match expectation — before=1, after-old=0, after-new=1, line count 391 equals the P0-T14 baseline (net-zero line delta). AC-1's edit is complete and verified.
