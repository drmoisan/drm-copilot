# Pester Directory, Convention, and Guard Runs, Phase 5 (P5-T11) - STOPPED

Timestamp: 2026-09-27T15-55
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: STOP. The directory run printed TotalCount=494, PassedCount=493, FailedCount=1. The failing test, "Exported facade surface.Spec PowerShell surface.exports no function beyond the six spec-fixed names" in tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1, is not in the P0-T32 baseline failure set (which is empty), so the P5-T11 acceptance is not met. The convention run (B46) printed FailedCount=0 (6/6) and the guard run (B47) printed FailedCount=0 (5/5); those two acceptance clauses are met.

## Directory run

```text
   [-] exports no function beyond the six spec-fixed names
    Expected 6, but got 8.
TotalCount=494
PassedCount=493
FailedCount=1
FAILED: Exported facade surface.Spec PowerShell surface.exports no function beyond the six spec-fixed names
```

## Convention run (block B46)

```text
  [+] discovers the claude library modules on disk
  [+] sets the fail-fast error preference at module scope in every discovered module
  [+] guards every load-time sibling import with an explicit stop preference
  [+] states the fail-fast convention in the module help block
  [+] leaves the caller error preference unchanged after import
  [+] keeps every claude library module within the five hundred line limit
TotalCount=6
PassedCount=6
FailedCount=0
```

## Guard run (block B47)

```text
   [+] detects two sibling It names that differ only by letter case
   [+] detects a literal -ForEach whose rows differ only by data-value case
   [+] reports no collision when a literal -ForEach disambiguates rows with a distinct data key
   [+] skips a non-literal -ForEach argument without raising a collision
   [+] reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1
TotalCount=5
PassedCount=5
FailedCount=0
```

## Stop reason (plan defect)

P5-T6 requires the facade `.claude/lib/blast-radius/BlastRadius.psm1` to add Get-BlastRadiusConflictEdge
and Get-BlastRadiusPairDecision to its exported function list. The existing test
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 (lines 467-489, Describe 'Exported facade
surface') pins the facade export set: a -ForEach over the six spec-fixed names and the case
'exports no function beyond the six spec-fixed names', which asserts an export count of exactly 6.
After P5-T6 the count is 8, so that case fails.

The plan does not name BlastRadius.Tests.ps1 in any task, and the spec's files-to-change list does
not name it. Updating it is also blocked by the batch budget: the PowerShell batch of Phase 5 has
already authored its three permitted test files (BlastRadiusScheduling.Tests.ps1,
BlastRadius.HistoricalRuns.Tests.ps1, BlastRadius.KeyPartition.Tests.ps1), as recorded by the
PowerShell batch-budget hook state (testCap 3, three testFiles). A fourth test-file edit in this
batch would exceed the budget that AC-37 requires, and opening a second batch requires a
batch-budget reset task that the plan does not contain.

Required plan delta (for the planner): add, within Phase 5 after P5-T10 and before P5-T11, a second
PowerShell batch consisting of a batch-budget reset task (A8, -Kind powershell, with its evidence
artifact) and a task that edits tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 so the
'Exported facade surface' Describe lists the eight exported names (the six existing names plus
Get-BlastRadiusConflictEdge and Get-BlastRadiusPairDecision) and its count case asserts 8 with a
correspondingly renamed It. Stage that file in P5-T13, and add it to the P7-T5 line-count list, the
P16 PowerShell QA file list (block B40), and the P18 batch accounting. Phase 10 should be checked for
the same pin if it adds facade exports.

## Informational observation for P5-T12 (read-only; P5-T12 not executed)

A read-only run of script ps-format-check (A6) over the six Phase 5 PowerShell files printed
Changed=True for tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 and
Changed=False for the other five (FORMAT-SUMMARY ChangedCount=1). No file was modified by that run.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
