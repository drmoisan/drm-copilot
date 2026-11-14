# Scratch Tooling Extension for REPRO (P0-T6)

Timestamp: 2026-11-03T23-40
Command: sh SCRATCH/issue-1066-launch-p0t6.sh (issue-1066-order.ps1 -Mode Leak and -Mode Forward over REPRO; issue-1066-junit-sets.ps1 -ProfileMode -First RAW/baseline-forward.xml -Base RAW/baseline-excluded.xml; a Parser.ParseFile check of the four scripts)
EXIT_CODE: 0
Output Summary:
- `Leak` list: 45 paths; position 1 is `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (TARGET); positions 2 to 9 are the eight VICTIMS in Forward order; positions 10 to 45 are the 36 other DEVLIST files in Forward order.
- `Forward` list: 45 paths; positions 1 to 8 are the eight VICTIMS; TARGET is at position 38.
- Profile mode, RAW/baseline-forward.xml against RAW/baseline-excluded.xml: `PROFILE: Containers=37 Tests=692 Failed=94 Blocks=0 Container=0`; `WITHIN-BASE: Shared=36 Outside=0 OnlyRun=1 OnlyBase=0`; the only run-only container is TARGET (`tests=35 failed=0 blocks=0 container=0`). No shared container lies outside its base profile.
- Parse check: `PARSE-ERRORS issue-1066-poshqc-run.ps1: 0` (and 0 for issue-1066-order.ps1, issue-1066-junit-sets.ps1, issue-1066-sets-lib.ps1).

## Tooling changes under SCRATCH

- `issue-1066-order.ps1`: new `-Set Repro|DevList` (default `Repro` = DEVLIST plus the eight VICTIMS) and new mode `Leak` (GUARD when present, TARGET, VICTIMS in Forward order, then the remaining DEVLIST files in Forward order). `Forward` sorts the file objects with `Sort-Object -Property FullName -Stable`; `Reversed` reverses Forward; `Seeded` uses `Get-Random -Count <n> -SetSeed <seed>` over Forward. `-Exclude` and `-Only` are kept; the control of an order is produced with `-Exclude` naming TARGET and GUARD.
- `issue-1066-sets-lib.ps1`: new `Get-Issue1066Profile` (container profile per plan `## Conventions`; reads JUnit XML or a profile JSON), `Test-Issue1066ProfileWithin`, `Format-Issue1066Profile`, and `Get-Issue1066ProfileFieldwise` (field-wise Min or Max).
- `issue-1066-junit-sets.ps1`: new `-ProfileMode` switch. Prints the profile table of `-First`; with `-Second`, the differing containers and the field-wise minimum and maximum (`-MinOut`, `-MaxOut` write JSON); with `-Base`, every shared container whose profile is not within the base profile, plus run-only and base-only containers; `-ProfileOut` writes the `-First` table as JSON. The key-set mode is unchanged.
- `issue-1066-poshqc-run.ps1` (new): imports `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCTest` with `-ScanFolders`, `-TestResultPath`, `-CoverageOutputPath`, and an `-InvokePester` scriptblock that sets `Run.Exit` and `TestResult.Enabled` to false, runs `Invoke-Pester -Configuration` through a global trampoline function (as the default seam does), writes JUnit from the result with `issue-1066-junit-writer.ps1`, and exits 1 when any test, block, or container failed.
