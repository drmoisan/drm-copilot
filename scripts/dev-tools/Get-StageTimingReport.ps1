<#
.SYNOPSIS
    Prints the stage timing report from the committed orchestrator evidence (issue #1097, stage B).

.DESCRIPTION
    Reads every stage-timing.*.json file below the evidence root, summarizes the stage durations
    per issue and the median per stage across issues, and writes the report as text lines. The
    logic lives in StageTiming.psm1; this entry only wires its three functions together. The
    report states that its figures are wall-clock time including queueing and that the merge
    stage is not captured. The script throws when the evidence root does not exist.

.PARAMETER EvidenceRoot
    The folder searched recursively for stage-timing.*.json files. The default is docs/features
    below the repository root.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Get-StageTimingReport.ps1
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$EvidenceRoot
)

$ErrorActionPreference = 'Stop'

# The default is resolved here rather than in the param block, so the line is measured by coverage.
if (-not $PSBoundParameters.ContainsKey('EvidenceRoot')) {
    $EvidenceRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../docs/features'
}

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'StageTiming.psm1') -Force

$evidence = @(Read-StageTimingEvidence -Root $EvidenceRoot)
$summary = Get-StageTimingSummary -Evidence $evidence
Format-StageTimingReport -Summary $summary
