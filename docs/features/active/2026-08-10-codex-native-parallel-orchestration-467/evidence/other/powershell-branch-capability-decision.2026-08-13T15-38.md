# PowerShell Branch-Coverage Capability Decision

- Task: `P1-T1`
- Decision: `POLICY_RESOLUTION_REQUIRED`
- PowerShell: `7.6.3`
- PoshQC: `0.1.1`
- Required Pester: `5.6.1`
- Installed Pester versions: `5.6.1`, `3.4.0`

## Binary Decision

The installed local PowerShell coverage surface does not provide a supported,
source-attributable branch mechanism. Pester 5.6.1 exposes only the `JaCoCo`
and `CoverageGutters` output formats. Both formats are generated from Pester's
command-coverage model. The generated line records set `mb=0` and `cb=0`, and
the emitter writes only `Instruction`, `Line`, `Method`, and `Class` counters.
Neither installed Pester version contains a branch-coverage provider, and no
other local coverage module or command is installed.

Therefore this repository cannot produce the required non-zero,
source-attributable PowerShell branch denominator with its supported local
toolchain. This is a fail-closed capability finding. It does not reinterpret,
exclude, fabricate, or change the 75 percent branch threshold.

## Exact Inspection Commands and Results

```powershell
$module = Get-Module -ListAvailable Pester |
    Sort-Object Version -Descending |
    Select-Object -First 1
Import-Module $module.Path -Force
$config = New-PesterConfiguration
$module | Select-Object Name,Version,Path
$config.CodeCoverage | Format-List *
$config.CodeCoverage | Get-Member |
    Select-Object Name,MemberType,Definition
```

Result: Pester `5.6.1` was selected. `CodeCoverage.OutputFormat` lists only
`JaCoCo` and `CoverageGutters`. The coverage configuration exposes paths,
output settings, command-coverage percentage, and breakpoint/profiler options;
it exposes no branch instrumentation or branch result option.

```powershell
Get-Module -ListAvailable Pester |
    Sort-Object Version -Descending |
    Select-Object Name,Version,Path
Get-Module -ListAvailable |
    Where-Object { $_.Name -match 'cover' } |
    Select-Object Name,Version,Path
Get-Command -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'Coverage|Koverage' } |
    Select-Object Name,CommandType,Source,Version
```

Result: installed Pester versions are `5.6.1` and `3.4.0`. No coverage-named
module was found. The only coverage-named commands were unrelated Microsoft
Graph report commands; there was no PowerShell source-coverage provider.

```powershell
$modules = Get-Module -ListAvailable Pester | Sort-Object Version -Descending
foreach ($module in $modules) {
    $root = Split-Path $module.Path -Parent
    rg -n --glob '*.ps1' --glob '*.psm1' --glob '*.cs' \
        'BRANCH|branch-rate|branches-covered|branches-missed|condition-coverage' \
        $root
    rg -n --glob '*.ps1' --glob '*.psm1' --glob '*.cs' \
        'JaCoCo|CoverageGutters|CommandsAnalyzed|MissedCommands' \
        $root
}
```

Result: both installed Pester versions returned zero branch-provider matches.
Pester 5.6.1 returned 49 command-coverage matches and Pester 3.4.0 returned 24.

```powershell
$pester = Get-Module -ListAvailable Pester |
    Sort-Object Version -Descending |
    Select-Object -First 1
$pesterSource = Join-Path (Split-Path $pester.Path -Parent) 'Pester.psm1'
rg -n 'CommandsAnalyzedCount|CommandsExecutedCount|CommandsMissed|Branches|Branch' \
    $pesterSource
Get-Content $pesterSource | Select-Object -Index (9758..9815)
```

Result: the Pester result is populated from `CommandsAnalyzedCount`,
`CommandsExecutedCount`, and missed/executed command collections. In the
JaCoCo/CoverageGutters emitter, every source line receives `mb=0` and `cb=0`.
The aggregate emitters add only `Instruction`, `Line`, `Method`, and `Class`
counters. No `Branch` counter is emitted.

```powershell
& pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
Test-ModuleManifest 'scripts/powershell/PoshQC/PoshQC.psd1' |
    Select-Object Name,Version,Path
rg -n 'Pester|RequiredModules|ModuleVersion' scripts/powershell/PoshQC
```

Result: PowerShell is `7.6.3`; PoshQC is `0.1.1`; the repository installer pins
Pester `5.6.1` in `PoshQC.psm1`.

## In-Scope Repository Inspection

- `PoshQC.Testing.psm1` builds a standard Pester configuration, invokes Pester,
  reports command coverage, and converts paths. It defines no branch provider.
- `convert-poshqc-coverage.ps1` only delegates path normalization to
  `Convert-PoshQCCoverageToRelative`; it does not calculate coverage counters.
- `pester.runsettings.psd1` selects `CoverageGutters` and a zero command-coverage
  target; it defines no branch instrumentation.
- `PoshQC.TestingCoveragePruning.Tests.ps1` verifies coverage-path pruning,
  disabling, and forwarding. It defines no branch provider.

## Required Disposition

`REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`

No Phase 1 code or policy edit is authorized by this decision.
