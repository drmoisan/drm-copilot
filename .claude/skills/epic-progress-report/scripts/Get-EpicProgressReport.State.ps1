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

function ConvertFrom-EpicProgressStateText {
    <#
    .SYNOPSIS
        Parse the state file text into StartUnixSeconds, BaselineDone, BaselineWeeklyPct, and Samples.
    .DESCRIPTION
        Accepts the version-1 object written by ConvertTo-EpicProgressStateJson and the legacy
        JSON array of samples written by the issue #1080 tool (samples only, no baseline).
        Blank text, unparseable text, any other JSON value, and an object whose version is
        not 1 give the empty state. A version-1 field that is missing, null, or not a number
        is absent: its value is $null. Samples is always an array.
    .PARAMETER Text
        The raw state file text; blank or null for no state file.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $state = [pscustomobject]@{ StartUnixSeconds = $null; BaselineDone = $null; BaselineWeeklyPct = $null; Samples = [object[]] @() }
    if (-not (Test-EpicProgressJsonText -Json $Text)) { return $state }
    $parsed = ConvertFrom-Json -InputObject $Text -NoEnumerate
    if ($parsed -is [array]) {
        $state.Samples = [object[]] @($parsed | Where-Object { $null -ne $_ })
        return $state
    }
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) { return $state }
    $names = $parsed.PSObject.Properties.Name
    if (-not ($names -contains 'version') -or [string] $parsed.version -ne '1') { return $state }
    if ($names -contains 'startUnixSeconds' -and $null -ne $parsed.startUnixSeconds) { $state.StartUnixSeconds = $parsed.startUnixSeconds -as [long] }
    if ($names -contains 'baselineDone' -and $null -ne $parsed.baselineDone) { $state.BaselineDone = $parsed.baselineDone -as [int] }
    if ($names -contains 'baselineWeeklyPct' -and $null -ne $parsed.baselineWeeklyPct) { $state.BaselineWeeklyPct = $parsed.baselineWeeklyPct -as [double] }
    if ($names -contains 'samples' -and $null -ne $parsed.samples) {
        $state.Samples = [object[]] @($parsed.samples | Where-Object { $null -ne $_ })
    }
    return $state
}

function ConvertTo-EpicProgressStateJson {
    <#
    .SYNOPSIS
        Return the version-1 state document as JSON text.
    .DESCRIPTION
        The document holds version 1, startUnixSeconds, baselineDone, baselineWeeklyPct, and
        samples, each sample with an integer 'ts' (Unix epoch seconds) and a 'done' count.
        A sample without 'ts' is not written. Epoch seconds are used because ConvertFrom-Json
        converts ISO date strings into local-time DateTime values.
    .PARAMETER StartUnixSeconds
        The start instant in Unix epoch seconds.
    .PARAMETER BaselineDone
        The checked task count at the start instant.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at the start instant.
    .PARAMETER Sample
        The retained samples (ts, done).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [long] $StartUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $BaselineDone,
        [Parameter(Mandatory = $true)] [double] $BaselineWeeklyPct,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample
    )

    $written = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Sample) {
        if ($null -eq $entry -or -not ($entry.PSObject.Properties.Name -contains 'ts')) { continue }
        $written.Add([ordered]@{ ts = [long] $entry.ts; done = [int] $entry.done })
    }
    $document = [ordered]@{
        version           = 1
        startUnixSeconds  = $StartUnixSeconds
        baselineDone      = $BaselineDone
        baselineWeeklyPct = $BaselineWeeklyPct
        samples           = [object[]] $written.ToArray()
    }
    return ConvertTo-Json -InputObject $document -Depth 4
}

function Resolve-EpicProgressBaseline {
    <#
    .SYNOPSIS
        Resolve the start instant and the baseline values from the passed values, the stored state, and the reset switch.
    .DESCRIPTION
        Start: the passed value, else (with ResetBaseline) NowUtc, else the stored value; with
        none of these a terminating error names -StartUtc and -ResetBaseline. Baseline done:
        the passed value, else (with ResetBaseline) the current done count, else the stored
        value, else 0. Weekly baseline: the passed value, else the stored value, else 0; a
        reset does not capture it. The current done count is not known before the git calls,
        so UseCurrentDone is $true when the caller must substitute it for BaselineDone.
    .PARAMETER StartUtc
        The passed start instant; read only when StartUtcPassed is set.
    .PARAMETER StartUtcPassed
        Whether -StartUtc was passed to the report.
    .PARAMETER BaselineDone
        The passed baseline done count; read only when BaselineDonePassed is set.
    .PARAMETER BaselineDonePassed
        Whether -BaselineDone was passed to the report.
    .PARAMETER BaselineWeeklyPct
        The passed weekly baseline; read only when BaselineWeeklyPctPassed is set.
    .PARAMETER BaselineWeeklyPctPassed
        Whether -BaselineWeeklyPct was passed to the report.
    .PARAMETER State
        The parsed state from ConvertFrom-EpicProgressStateText.
    .PARAMETER ResetBaseline
        Whether the run resets the baseline.
    .PARAMETER NowUtc
        The current instant (UTC).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [datetime] $StartUtc,
        [switch] $StartUtcPassed,
        [int] $BaselineDone,
        [switch] $BaselineDonePassed,
        [double] $BaselineWeeklyPct,
        [switch] $BaselineWeeklyPctPassed,
        [Parameter(Mandatory = $true)] [pscustomobject] $State,
        [switch] $ResetBaseline,
        [Parameter(Mandatory = $true)] [datetime] $NowUtc
    )

    if ($StartUtcPassed) {
        $start = $StartUtc.ToUniversalTime()
    } elseif ($ResetBaseline) {
        $start = $NowUtc.ToUniversalTime()
    } elseif ($null -ne $State.StartUnixSeconds) {
        $start = [DateTimeOffset]::FromUnixTimeSeconds([long] $State.StartUnixSeconds).UtcDateTime
    } else {
        throw 'The start instant could not be resolved: pass -StartUtc, or pass -ResetBaseline to start the measurement now; the state file holds no start.'
    }

    $useCurrentDone = $false
    $done = 0
    if ($BaselineDonePassed) {
        $done = $BaselineDone
    } elseif ($ResetBaseline) {
        $useCurrentDone = $true
    } elseif ($null -ne $State.BaselineDone) {
        $done = [int] $State.BaselineDone
    }

    $weekly = 0.0
    if ($BaselineWeeklyPctPassed) {
        $weekly = $BaselineWeeklyPct
    } elseif ($null -ne $State.BaselineWeeklyPct) {
        $weekly = [double] $State.BaselineWeeklyPct
    }

    return [pscustomobject]@{ StartUtc = $start; BaselineDone = $done; BaselineWeeklyPct = $weekly; UseCurrentDone = $useCurrentDone }
}
