<#
.SYNOPSIS
    Prints the cross-epic readiness decision for an epic manifest (issue #1162).

.DESCRIPTION
    Thin command entry over EpicCrossDependency.psm1. Reads the epic.md at -ManifestPath,
    writes compressed JSON to stdout, and writes any error message to stderr. Exit codes:
    0 a decision or a clean validation (hold is a valid decision), 1 manifest validation
    errors (EPIC_CROSS_DEPENDENCY_ codes), 2 usage error.

.PARAMETER Mode
    validate, feature, or main.

.PARAMETER ManifestPath
    Path of the epic.md being orchestrated.

.PARAMETER Issue
    Feature issue number for feature mode; omit it to evaluate every feature with cross-epic edges.

.PARAMETER WaitSeconds
    Wait bound from 0 to 540 seconds; the default 0 evaluates once.

.EXAMPLE
    pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 -Mode feature -ManifestPath docs/features/epics/<slug>/epic.md -Issue 1201
#>
[CmdletBinding()]
param(
    [string] $Mode,
    [string] $ManifestPath,
    [string] $Issue,
    [int] $WaitSeconds = 0
)

Import-Module (Join-Path $PSScriptRoot 'EpicCrossDependency.psm1') -Force -ErrorAction Stop
$result = Invoke-EpicCrossReadinessCommand -Mode $Mode -ManifestPath $ManifestPath -Issue $Issue -WaitSeconds $WaitSeconds
if ($result.Stdout) { Write-Output $result.Stdout }
if ($result.Stderr) { [Console]::Error.WriteLine($result.Stderr) }
exit $result.ExitCode
