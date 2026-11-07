<#
.SYNOPSIS
    Duration-ledger functions for Get-EpicProgressReport.ps1: median, defaults, samples, and the ledger merge.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. A duration sample holds key, type,
    seconds, source (stage_timing, tick, epic_row, artifact_stamp, or cycle_entry), approx,
    and recorded (epoch seconds). Composite remediation stages and unrecognized stage names
    give unmapped-time records, which never enter a median (decision D2).
    Get-EpicProgressReport.Logic.ps1 dot-sources this file, so a consumer dot-sources the
    Logic hub, not this file.
#>

function Get-EpicProgressMedian {
    <#
    .SYNOPSIS
        Return the median of the values: the middle value of an odd count, the mean of the middle pair of an even count, and NaN for none.
    .PARAMETER Value
        The values.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [double[]] $Value)

    if ($Value.Count -eq 0) { return [double]::NaN }
    $sorted = [double[]] @($Value | Sort-Object)
    $middle = [math]::Floor($sorted.Count / 2)
    if ($sorted.Count % 2 -eq 1) { return $sorted[$middle] }
    return ($sorted[$middle - 1] + $sorted[$middle]) / 2.0
}

function Resolve-EpicProgressStepDefault {
    <#
    .SYNOPSIS
        Return the default duration of each step type in seconds, with the -StepDefaultMinutes overrides applied.
    .DESCRIPTION
        The built-in defaults (decision D5) are research 13, spec 6, plan 11, preflight 10,
        execution 5 per task, review 14, pr 3, ci 17, merge 5, main-sync 60, and integration-pr
        45 minutes. An override key that is not a step type, and an override value that is not
        a number above 0, raise a terminating error that names the key.
    .PARAMETER StepDefaultMinutes
        The overrides in minutes, keyed by step type; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [hashtable] $StepDefaultMinutes = @{})

    $minutes = [ordered]@{
        research = 13; spec = 6; plan = 11; preflight = 10; execution = 5; review = 14
        pr = 3; ci = 17; merge = 5; 'main-sync' = 60; 'integration-pr' = 45
    }
    if ($null -ne $StepDefaultMinutes) {
        foreach ($key in $StepDefaultMinutes.Keys) {
            $type = [string] $key
            if (-not $minutes.Contains($type)) {
                throw "-StepDefaultMinutes key '$type' is not a step type; use one of: $(@($minutes.Keys) -join ', ')."
            }
            $value = $StepDefaultMinutes[$key]
            $isNumber = $value -is [int] -or $value -is [long] -or $value -is [double] -or $value -is [decimal] -or $value -is [single]
            if (-not $isNumber -or [double] $value -le 0) {
                throw "-StepDefaultMinutes value for '$type' must be a number of minutes above 0; '$value' was given."
            }
            $minutes[$type] = [double] $value
        }
    }
    $seconds = @{}
    foreach ($type in $minutes.Keys) { $seconds[$type] = 60.0 * [double] $minutes[$type] }
    return $seconds
}

function Get-EpicProgressDurationSample {
    <#
    .SYNOPSIS
        Return one duration sample record (key, type, seconds, source, approx, recorded).
    .PARAMETER Key
        The de-duplication key.
    .PARAMETER Type
        The step type.
    .PARAMETER Seconds
        The duration in seconds.
    .PARAMETER Source
        stage_timing, tick, epic_row, artifact_stamp, or cycle_entry.
    .PARAMETER Approx
        Whether the duration is approximate (decision D3).
    .PARAMETER Recorded
        The epoch second at which the sample was recorded.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Key,
        [Parameter(Mandatory = $true)] [string] $Type,
        [Parameter(Mandatory = $true)] [double] $Seconds,
        [Parameter(Mandatory = $true)] [string] $Source,
        [bool] $Approx = $false,
        [long] $Recorded = 0
    )

    return [pscustomobject]@{ key = $Key; type = $Type; seconds = $Seconds; source = $Source; approx = $Approx; recorded = $Recorded }
}

function Get-EpicProgressStageSample {
    <#
    .SYNOPSIS
        Return Sample (one per closed stage_timing entry of a typed stage) and Unmapped (composite and unmapped stage time).
    .DESCRIPTION
        A closed entry of a step type other than execution gives one sample keyed
        '<issue>|<stage>|<attempt>' with source stage_timing. Execution samples are per task and
        come from Get-EpicProgressTickSample. A closed composite remediation entry or an
        unrecognized stage gives an unmapped-time record (Issue, Stage, Kind, Seconds, Approx,
        Source) and no sample. Open entries give nothing.
    .PARAMETER Issue
        The item issue number.
    .PARAMETER StageRecord
        The records from ConvertFrom-EpicProgressStageTiming.
    .PARAMETER RecordedUnixSeconds
        The current epoch second, stored as the sample's recorded time.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $StageRecord,
        [long] $RecordedUnixSeconds = 0
    )

    $samples = [System.Collections.Generic.List[object]]::new()
    $unmapped = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $StageRecord) {
        if ($null -eq $record -or $null -eq $record.EndedUnixSeconds) { continue }
        $seconds = [double] ($record.EndedUnixSeconds - $record.StartedUnixSeconds)
        if ($record.Type -in @('composite', 'unmapped')) {
            $unmapped.Add([pscustomobject]@{ Issue = $Issue; Stage = $record.Stage; Kind = $record.Type; Seconds = $seconds; Approx = $false; Source = 'stage_timing' })
        } elseif ($record.Type -ne 'execution') {
            $samples.Add((Get-EpicProgressDurationSample -Key "$Issue|$($record.Stage)|$($record.Attempt)" -Type $record.Type -Seconds $seconds -Source 'stage_timing' -Recorded $RecordedUnixSeconds))
        }
    }
    return [pscustomobject]@{ Sample = [object[]] $samples.ToArray(); Unmapped = [object[]] $unmapped.ToArray() }
}

function Merge-EpicProgressDuration {
    <#
    .SYNOPSIS
        Merge new samples into the per-type duration ledger; return Ledger and Changed.
    .DESCRIPTION
        One sample is kept per key across runs. A stage_timing sample replaces a tick sample
        with the same key (the closed execution stage is the authoritative record); any other
        repeated key keeps the stored sample. The ledger is not limited by -SampleCap; each
        type keeps its newest Cap samples by recorded time. The input ledger is not modified.
    .PARAMETER Ledger
        The stored ledger: a hashtable from step type to its sample array.
    .PARAMETER Sample
        The samples observed in this run.
    .PARAMETER Cap
        The per-type retention ceiling; default 1000.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [ValidateRange(1, 100000)] [int] $Cap = 1000
    )

    $lists = @{}
    $positions = @{}
    $changed = $false
    $add = {
        param([object] $Entry, [bool] $FromRun)
        $type = [string] $Entry.type
        if (-not $lists.ContainsKey($type)) {
            $lists[$type] = [System.Collections.Generic.List[object]]::new()
            $positions[$type] = @{}
        }
        $key = [string] $Entry.key
        if (-not $positions[$type].ContainsKey($key)) {
            $positions[$type][$key] = $lists[$type].Count
            $lists[$type].Add($Entry)
            return $FromRun
        }
        $index = $positions[$type][$key]
        if ($FromRun -and $lists[$type][$index].source -eq 'tick' -and $Entry.source -eq 'stage_timing') {
            $lists[$type][$index] = $Entry
            return $true
        }
        return $false
    }
    if ($null -ne $Ledger) {
        foreach ($type in $Ledger.Keys) {
            foreach ($entry in @($Ledger[$type] | Where-Object { $null -ne $_ })) { $null = & $add $entry $false }
        }
    }
    foreach ($entry in $Sample) {
        if ($null -eq $entry) { continue }
        if (& $add $entry $true) { $changed = $true }
    }
    $merged = @{}
    foreach ($type in $lists.Keys) {
        $kept = [object[]] @($lists[$type] | Sort-Object -Property { [long] $_.recorded } -Stable)
        if ($kept.Count -gt $Cap) {
            $kept = [object[]] @($kept | Select-Object -Last $Cap)
            $changed = $true
        }
        $merged[$type] = $kept
    }
    return [pscustomobject]@{ Ledger = $merged; Changed = $changed }
}
