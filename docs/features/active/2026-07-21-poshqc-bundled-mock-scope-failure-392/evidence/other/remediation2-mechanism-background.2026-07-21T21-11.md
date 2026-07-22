Timestamp: 2026-07-21T21-11

# Mechanism-Background Verification (Revision 2, P0-T4)

## Confirmed line numbers (installed Pester 5.6.1)

Source file: `C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1\Pester.psm1`
Located via `grep -n "function <name>"`:

| Function | Definition line | Plan's cited range | Match |
|---|---|---|---|
| `Get-CoveragePlugin` | 8556 | ~8556-8662 | yes |
| `Enter-CoverageAnalysis` | 8780 | ~8780-8868 | yes |
| `Exit-CoverageAnalysis` | 8870 | RunEnd/End ~8664-8708 references this | yes |
| `Get-CoverageBreakpoints` | 9037 | ~9037-9093 | yes |
| `Get-CommandsInFile` | 9071 | ~9037-9093 | yes |
| `Get-CoverageMissedCommands` | 9390 | ~9390-9397 | yes |
| `Get-CoverageHitCommands` | 9395 | ~9390-9397 | yes |

No drift: every line range cited in this plan's Background section matches the actually-installed
Pester 5.6.1 module.

## PoshQC bootstrap loop

`scripts/powershell/PoshQC/PoshQC.psm1` lines 82-106 contain the AST-reparse-and-dot-source
bootstrap loop. For each of the four sub-modules (`PoshQC.FileDiscovery.psm1`,
`PoshQC.ScanConfig.psm1`, `PoshQC.Analyzer.psm1`, `PoshQC.Testing.psm1`) the loop calls
`[System.Management.Automation.Language.Parser]::ParseFile(...)`, throws on parse errors, and
dot-sources `($ast.GetScriptBlock())`. This runs on every `Import-Module -Force`. The existing
inline comment records the issue #344 rationale (PS7.6+ treats dot-sourced .psm1 files as
isolated modules; a file-associated ScriptBlock is required so Pester coverage breakpoints bind
to sub-module source files). Both `scripts/powershell/PoshQC/PoshQC.psm1` and its mirror
`extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` are byte-identical across this
region (121 lines each).

## Restatement of established facts (Pester script level)

Pester registers coverage breakpoints exactly once per `Invoke-Pester` invocation, at `RunStart`
(`Get-CoveragePlugin` -> `Enter-CoverageAnalysis`), before any test container's `BeforeAll`
executes. Each breakpoint is derived from Pester's own independent `[Parser]::ParseFile($Path)`
of each coverage-tracked file (`Get-CoverageBreakpoints` / `Get-CommandsInFile`), separate from
whatever `PoshQC.psm1` does to load its sub-modules. With `UseSingleHitBreakpoints` defaulting to
`$true`, each breakpoint removes itself on first hit. Covered-vs-missed is decided purely from the
`HitCount` on those same one-time breakpoint-wrapper objects (`Get-CoverageMissedCommands` /
`Get-CoverageHitCommands`); no new breakpoints are registered mid-run, and the final
JaCoCo/CoverageGutters report reads that same one-time list.

## Hypothesis status

The re-parse/re-compile interaction between `PoshQC.psm1`'s bootstrap loop (fresh
`[Parser]::ParseFile(...).GetScriptBlock()` per `-Force` reimport) and the PowerShell engine's
association of a running script's execution position with its file-path breakpoint set lives in
compiled `System.Management.Automation` internals, not readable PowerShell source. It therefore
CANNOT be confirmed by reading text alone. It is labeled UNCONFIRMED and is to be tested
empirically by the Phase 0 experiments (E-B / E-C / E-D) before any production fix is adopted.
