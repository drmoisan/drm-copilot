<#
.SYNOPSIS
    Setting, state-file, baseline, and sample functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. The entry script reads and writes the
    state file through its I/O seams. Get-EpicProgressReport.Logic.ps1 dot-sources this file,
    so a consumer dot-sources the Logic hub, not this file.
#>

function Select-EpicProgressSample {
    <#
    .SYNOPSIS
        Apply the sample-retention rule for one check-in; return Sample and Changed.
    .DESCRIPTION
        A sample (ts, done) is added only when there is no previous sample, the previous
        sample has no 'ts', or it is at least 90 seconds older than now. On add, samples
        without 'ts' are dropped and only the last SampleCap samples are kept.
    .PARAMETER Sample
        The samples read from the state file.
    .PARAMETER NowUnixSeconds
        The current instant in Unix seconds.
    .PARAMETER Done
        The checked task count now.
    .PARAMETER SampleCap
        The maximum number of samples kept.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $Done,
        [Parameter(Mandatory = $true)] [ValidateRange(1, 100000)] [int] $SampleCap
    )

    $last = $null
    if ($Sample.Count -gt 0) { $last = $Sample[$Sample.Count - 1] }
    $add = ($null -eq $last) -or -not ($last.PSObject.Properties.Name -contains 'ts') -or (($NowUnixSeconds - [long] $last.ts) -ge 90)
    if (-not $add) { return [pscustomobject]@{ Sample = $Sample; Changed = $false } }
    $kept = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Sample) {
        if ($null -ne $entry -and $entry.PSObject.Properties.Name -contains 'ts') { $kept.Add($entry) }
    }
    $kept.Add([pscustomobject]@{ ts = $NowUnixSeconds; done = $Done })
    $retained = [object[]] @($kept | Select-Object -Skip ([math]::Max(0, $kept.Count - $SampleCap)))
    return [pscustomobject]@{ Sample = $retained; Changed = $true }
}

function Resolve-EpicProgressSetting {
    <#
    .SYNOPSIS
        Apply the parameter defaults of the report; pure, with the current location passed in.
    .DESCRIPTION
        A blank value takes its default and an explicit value is kept. The kickoff path is a
        git object path with '/' separators; filesystem paths are built with Join-Path. The
        default state file is .claude/state/epic-progress-<EpicFolder>.json under the
        repository root, which is gitignored and survives a container stop with the checkout.
    .PARAMETER EpicFolder
        The epic folder name.
    .PARAMETER EpicIssue
        The explicit epic issue number, or blank.
    .PARAMETER IntegrationBranch
        The explicit integration branch, or blank.
    .PARAMETER KickoffPath
        The explicit kickoff path, or blank.
    .PARAMETER RepositoryRoot
        The explicit repository root, or blank.
    .PARAMETER CheckpointPath
        The explicit checkpoint path, or blank.
    .PARAMETER StatePath
        The explicit state file path, or blank.
    .PARAMETER CurrentLocation
        The current location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $EpicFolder,
        [AllowEmptyString()] [string] $EpicIssue = '',
        [AllowEmptyString()] [string] $IntegrationBranch = '',
        [AllowEmptyString()] [string] $KickoffPath = '',
        [AllowEmptyString()] [string] $RepositoryRoot = '',
        [AllowEmptyString()] [string] $CheckpointPath = '',
        [AllowEmptyString()] [string] $StatePath = '',
        [Parameter(Mandatory = $true)] [string] $CurrentLocation
    )

    $root = $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($root)) { $root = $CurrentLocation }
    $branch = $IntegrationBranch
    if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "origin/epic/$EpicFolder-integration" }
    $kickoff = $KickoffPath
    if ([string]::IsNullOrWhiteSpace($kickoff)) { $kickoff = "docs/features/epics/$EpicFolder/epic-kickoff.md" }
    $checkpoint = $CheckpointPath
    if ([string]::IsNullOrWhiteSpace($checkpoint)) {
        $checkpoint = Join-Path -Path $root -ChildPath 'artifacts' -AdditionalChildPath 'orchestration', 'epic-orchestrator-state.json'
    }
    $state = $StatePath
    if ([string]::IsNullOrWhiteSpace($state)) {
        $state = Join-Path -Path $root -ChildPath '.claude' -AdditionalChildPath 'state', "epic-progress-$EpicFolder.json"
    }

    return [pscustomobject]@{
        EpicIssue         = $EpicIssue
        IntegrationBranch = $branch
        KickoffPath       = $kickoff.Replace('\', '/')
        RepositoryRoot    = $root
        CheckpointPath    = $checkpoint
        StatePath         = $state
    }
}
