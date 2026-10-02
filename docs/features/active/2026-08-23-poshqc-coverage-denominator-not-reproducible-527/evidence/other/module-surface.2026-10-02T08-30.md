# P3-T8 Module Surface (static half; CI half pending)

Timestamp: 2026-10-02T08-30
Command: git -C <ROOT> grep --untracked -n -E "Get-PoshQCSettingsList|Get-PoshQCCoverageConfigRoot|Get-PoshQCCoverageFileSet|Resolve-PoshQCCoveragePopulation" -- scripts/powershell/PoshQC/PoshQC.psm1 scripts/powershell/PoshQC/PoshQC.psd1; git -C <ROOT> grep --untracked -n -E "^function (Get-PoshQCSettingsList|Get-PoshQCCoverageConfigRoot|Get-PoshQCCoverageFileSet|Resolve-PoshQCCoveragePopulation) \{" -- scripts/powershell/PoshQC/PoshQC.Coverage.psm1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: EXPORTED=0 (static): none of the four internal function names appears in `PoshQC.psm1` (whose `Export-ModuleMember` list is unchanged) or in `PoshQC.psd1` (`FunctionsToExport`); the first `git grep` exited 1 with no output. All four functions are defined at the top level of `PoshQC.Coverage.psm1` (lines 15, 62, 154, 246), and `PoshQC.Coverage.psm1` is registered in the sub-module list of `PoshQC.psm1`. DEFINED=4 is not yet established: it is a CI-evidence deviation (classification row P3-T8) and is proven only when the new suites reach all four functions through `InModuleScope PoshQC` in a passing CI run. P3-T8 stays unchecked until then.

## Output

First command (names in the export surfaces): no output, exit 1.

Second command (definitions):

```text
scripts/powershell/PoshQC/PoshQC.Coverage.psm1:15:function Get-PoshQCSettingsList {
scripts/powershell/PoshQC/PoshQC.Coverage.psm1:62:function Get-PoshQCCoverageConfigRoot {
scripts/powershell/PoshQC/PoshQC.Coverage.psm1:154:function Get-PoshQCCoverageFileSet {
scripts/powershell/PoshQC/PoshQC.Coverage.psm1:246:function Resolve-PoshQCCoveragePopulation {
```

## Pending CI half

- Required: a CI `poshqc / PowerShell QC` run on a head containing this module in which the `Get-PoshQCCoverageFileSet (issue #527)`, `Get-PoshQCCoverageConfigRoot (issue #527)`, and `Resolve-PoshQCCoveragePopulation precedence (issue #527)` suites pass (they call `Get-PoshQCCoverageFileSet`, `Get-PoshQCCoverageConfigRoot`, and `Resolve-PoshQCCoveragePopulation` directly, and `Resolve-PoshQCCoveragePopulation` calls `Get-PoshQCSettingsList`).
