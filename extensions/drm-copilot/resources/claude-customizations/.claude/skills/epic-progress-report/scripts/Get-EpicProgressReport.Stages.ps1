<#
.SYNOPSIS
    Step-type catalog, stage-name normalization, stage_timing parsing, and blockage functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. The stage_timing record rules are a port
    of scripts/dev-tools/StageTiming.psm1 (a stage name, an attempt of 1 or more, an ISO-8601
    start, and an end that is null while the stage is open), re-implemented here so the skill
    imports nothing outside its own folder. Get-EpicProgressReport.Logic.ps1 dot-sources this
    file, so a consumer dot-sources the Logic hub, not this file.
#>

function Get-EpicProgressStepTypeCatalog {
    <#
    .SYNOPSIS
        Return the eleven step types of the step model in report order, each with its scope (item or epic).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $itemTypes = @('research', 'spec', 'plan', 'preflight', 'execution', 'review', 'pr', 'ci', 'merge')
    foreach ($type in $itemTypes) { [pscustomobject]@{ Type = $type; Scope = 'item' } }
    [pscustomobject]@{ Type = 'main-sync'; Scope = 'epic' }
    [pscustomobject]@{ Type = 'integration-pr'; Scope = 'epic' }
}

function ConvertTo-EpicProgressStepType {
    <#
    .SYNOPSIS
        Map a stage_timing stage name to a step type, 'composite', or 'unmapped'.
    .DESCRIPTION
        'planning' and 'plan' map to 'plan'; a name that starts with 'remediation' (for example
        'remediation' or 'remediation_cycle_2') is a composite remediation stage and maps to
        'composite'; a catalog type name maps to itself; any other name (for example
        'promotion') maps to 'unmapped'. The comparison ignores case and surrounding blanks.
    .PARAMETER StageName
        The stage name recorded in stage_timing.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $StageName)

    $name = $StageName.Trim().ToLowerInvariant()
    if ($name -eq 'planning' -or $name -eq 'plan') { return 'plan' }
    if ($name.StartsWith('remediation')) { return 'composite' }
    $catalog = @(Get-EpicProgressStepTypeCatalog | ForEach-Object { $_.Type })
    if ($catalog -contains $name) { return $name }
    return 'unmapped'
}

function ConvertTo-EpicProgressUnixSecond {
    <#
    .SYNOPSIS
        Convert an ISO-8601 string, a DateTime, or a DateTimeOffset to UTC epoch seconds; $null when it is not a time.
    .DESCRIPTION
        ConvertFrom-Json turns an ISO-8601 string into a DateTime, so both forms reach this
        function and give the same second. A DateTime of unspecified kind and a string without
        an offset are read as UTC.
    .PARAMETER Value
        The value to convert.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [object] $Value)

    if ($Value -is [System.DateTimeOffset]) { return $Value.ToUnixTimeSeconds() }
    if ($Value -is [datetime]) {
        $instant = $Value
        if ($instant.Kind -eq [System.DateTimeKind]::Unspecified) { $instant = [datetime]::SpecifyKind($instant, [System.DateTimeKind]::Utc) }
        return [System.DateTimeOffset]::new($instant.ToUniversalTime()).ToUnixTimeSeconds()
    }
    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { return $null }
    $parsed = [System.DateTimeOffset]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal
    if ([System.DateTimeOffset]::TryParse($Value, [cultureinfo]::InvariantCulture, $styles, [ref] $parsed)) {
        return $parsed.ToUnixTimeSeconds()
    }
    return $null
}

function ConvertFrom-EpicProgressStageTiming {
    <#
    .SYNOPSIS
        Return one record (Stage, Type, Attempt, StartedUnixSeconds, EndedUnixSeconds) per valid stage_timing entry.
    .DESCRIPTION
        An entry is skipped when it is not an object, its stage is blank, its attempt is not a
        whole number of 1 or more, its start is not a time, its ended_at property is missing,
        its end is not a time, or its end is before its start. An open entry (ended_at null)
        is kept with a null end. An unknown stage name never fails: its Type is 'unmapped'.
    .PARAMETER StageTiming
        The stage_timing list of an item checkpoint; null or empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $StageTiming)

    foreach ($entry in @($StageTiming)) {
        if ($entry -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $names = $entry.PSObject.Properties.Name
        $stage = $entry.stage
        if ($stage -isnot [string] -or [string]::IsNullOrWhiteSpace($stage)) { continue }
        $attempt = $entry.attempt
        $isWhole = ($attempt -is [int] -or $attempt -is [long]) -or ($attempt -is [double] -and [math]::Floor($attempt) -eq $attempt)
        if (-not $isWhole -or $attempt -lt 1) { continue }
        $started = ConvertTo-EpicProgressUnixSecond -Value $entry.started_at
        if ($null -eq $started -or -not ($names -contains 'ended_at')) { continue }
        $ended = $null
        if ($null -ne $entry.ended_at) {
            $ended = ConvertTo-EpicProgressUnixSecond -Value $entry.ended_at
            if ($null -eq $ended -or $ended -lt $started) { continue }
        }
        [pscustomobject]@{
            Stage              = $stage
            Type               = ConvertTo-EpicProgressStepType -StageName $stage
            Attempt            = [long] $attempt
            StartedUnixSeconds = [long] $started
            EndedUnixSeconds   = $ended
        }
    }
}

function Get-EpicProgressBlockage {
    <#
    .SYNOPSIS
        Return Blocked and Reason for one item from its recorded checkpoint state and epic row merge status.
    .DESCRIPTION
        Decision D1: an item is blocked only by recorded state. It is blocked when the
        checkpoint blocked_reason is set to a value other than 'none' or 'awaiting_ci'; when a
        human_interaction.requirements entry has response 'halt'; when step6_status is
        'blocked_remediation_loop_limit' or step9_status is 'blocked_ci_loop_limit'; or when the
        epic row merge status is 'blocked_conflict_loop_limit'. A run with no new checked task
        is never a blockage signal, because no field here depends on the tick rate.
    .PARAMETER Checkpoint
        The parsed item checkpoint; null when the item has none.
    .PARAMETER MergeStatus
        The epic row merge status; blank when the item has no row.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Checkpoint,
        [AllowEmptyString()] [string] $MergeStatus = ''
    )

    $reason = ''
    if ($null -ne $Checkpoint) {
        $blockedReason = [string] $Checkpoint.blocked_reason
        $halt = @(@($Checkpoint.human_interaction.requirements) | Where-Object { $null -ne $_ -and $_.response -eq 'halt' })
        if (-not [string]::IsNullOrWhiteSpace($blockedReason) -and $blockedReason -ne 'none' -and $blockedReason -ne 'awaiting_ci') {
            $reason = $blockedReason
        } elseif ($halt.Count -gt 0) {
            $reason = 'human_interaction halt'
        } elseif ([string] $Checkpoint.step6_status -eq 'blocked_remediation_loop_limit') {
            $reason = 'blocked_remediation_loop_limit'
        } elseif ([string] $Checkpoint.step9_status -eq 'blocked_ci_loop_limit') {
            $reason = 'blocked_ci_loop_limit'
        }
    }
    if (-not $reason -and $MergeStatus -eq 'blocked_conflict_loop_limit') { $reason = 'blocked_conflict_loop_limit' }
    return [pscustomobject]@{ Blocked = [bool] $reason; Reason = $reason }
}
