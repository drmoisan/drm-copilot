# Facade Export Surface, Part B (P10-T10)

Timestamp: 2026-09-27T17-15
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
EXIT_CODE: 0
Output Summary: The facade Pester file ran with TotalCount=47, PassedCount=47, FailedCount=0. The Describe 'Exported facade surface' block now lists the eight Part A names plus the six write-intent names of P10-T5 in It 'exports <_>' (14 passing lines, including "exports Get-PlanPathForConfig"), and It 'exports no function beyond the spec-fixed names' passes with the assertion "$exported.Count | Should -Be 14". The file is 492 lines (at most 500). Only that Describe block changed: the -ForEach list, the eight-to-fourteen comment, and the count literal.

## Export-surface result lines (ANSI colour codes removed)

```text
   [+] exports Get-PlanPaths 10ms (7ms|2ms)
   [+] exports Get-BlastRadius 1ms (1ms|0ms)
   [+] exports Get-BlastRadiusFromObservedPaths 1ms (1ms|0ms)
   [+] exports Get-NormalizedDeclaredRadius 1ms (1ms|1ms)
   [+] exports Test-BlastRadius 1ms (1ms|0ms)
   [+] exports Test-BlastRadiusConflict 1ms (1ms|0ms)
   [+] exports Get-BlastRadiusConflictEdge 1ms (1ms|0ms)
   [+] exports Get-BlastRadiusPairDecision 1ms (1ms|0ms)
   [+] exports Test-WriteIntentExtractionEnabled 1ms (1ms|0ms)
   [+] exports Get-ConfigPathRoot 2ms (1ms|1ms)
   [+] exports Get-WriteIntentPlanPath 2ms (1ms|1ms)
   [+] exports Get-WriteIntentSpecContract 5ms (1ms|4ms)
   [+] exports Select-WriteIntentPathEntry 1ms (1ms|0ms)
   [+] exports Get-PlanPathForConfig 1ms (1ms|0ms)
   [+] exports no function beyond the spec-fixed names 3ms (3ms|0ms)
```

## Count lines

```text
TotalCount=47
PassedCount=47
FailedCount=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
