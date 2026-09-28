# Facade Export Pin Update, Phase 5 Second Batch (P5-T12)

Timestamp: 2026-09-27T16-28
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. TotalCount=41, PassedCount=41, FailedCount=0. The 'Exported facade surface' Describe now lists eight names (the six existing names plus Get-BlastRadiusConflictEdge and Get-BlastRadiusPairDecision), the renamed case 'exports no function beyond the spec-fixed names' asserts "$exported.Count | Should -Be 8", and both pass. The file is 490 lines (limit 500).

## Edit summary

- tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1, Describe 'Exported facade surface' only:
  - appended Get-BlastRadiusConflictEdge and Get-BlastRadiusPairDecision to the -ForEach list of It 'exports <_>';
  - comment "the six spec-fixed names are all exported" changed to "the eight spec-fixed names are all exported";
  - It 'exports no function beyond the six spec-fixed names' renamed to 'exports no function beyond the spec-fixed names';
  - assertion changed from "Should -Be 6" to "$exported.Count | Should -Be 8".
- No other test in the file changed.

## Printed output (Exported facade surface and totals; ANSI colour codes removed)

```text
   [+] exports Get-PlanPaths 10ms (7ms|3ms)
   [+] exports Get-BlastRadius 2ms (1ms|1ms)
   [+] exports Get-BlastRadiusFromObservedPaths 1ms (1ms|0ms)
   [+] exports Get-NormalizedDeclaredRadius 1ms (1ms|0ms)
   [+] exports Test-BlastRadius 1ms (1ms|0ms)
   [+] exports Test-BlastRadiusConflict 1ms (1ms|1ms)
   [+] exports Get-BlastRadiusConflictEdge 1ms (1ms|1ms)
   [+] exports Get-BlastRadiusPairDecision 1ms (1ms|1ms)
   [+] exports no function beyond the spec-fixed names 4ms (4ms|1ms)
TotalCount=41
PassedCount=41
FailedCount=0
```

## Line count

```text
490 tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
```

## Fail-before evidence

The STOPPED artifact pester-directory-p5.2026-09-27T15-55.md under FEATURE/evidence/regression-testing
records, for the same case before this edit, "[-] exports no function beyond the six spec-fixed names"
with "Expected 6, but got 8.".

SCRATCH denotes the executor session scratchpad directory (outside the repository).
