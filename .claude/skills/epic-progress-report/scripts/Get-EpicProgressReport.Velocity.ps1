<#
.SYNOPSIS
    Task-velocity functions for Get-EpicProgressReport.ps1: default rate, sequential (per-feature) and pooled velocity.

.DESCRIPTION
    Pure, host-neutral functions (issue #1153, decisions E2, E3, E11, and E12): each takes data
    in and returns data, and none reads a file, starts a process, calls the network, calls an
    I/O seam, or reads the clock. A feature's sequential velocity is its execution-sample count
    divided by the summed sample seconds in hours, read from the duration-ledger samples whose
    key starts with '<issue>|exec|'. A feature qualifies with at least 5 tasks and 900 active
    seconds; the pooled value is the median of the qualifying features' velocities with the
    across-feature standard deviation (n-1). Get-EpicProgressReport.Logic.ps1 dot-sources this
    file, so a consumer dot-sources the Logic hub, not this file.
#>

function Get-EpicProgressStandardDeviation {
    <#
    .SYNOPSIS
        Return the sample standard deviation (n-1) of the values; NaN for fewer than two values.
    .PARAMETER Value
        The values.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [double[]] $Value)

    if ($Value.Count -lt 2) { return [double]::NaN }
    $mean = 0.0
    foreach ($entry in $Value) { $mean += $entry }
    $mean = $mean / $Value.Count
    $squares = 0.0
    foreach ($entry in $Value) { $squares += ($entry - $mean) * ($entry - $mean) }
    return [math]::Sqrt($squares / ($Value.Count - 1))
}

function Get-EpicProgressDefaultRate {
    <#
    .SYNOPSIS
        Return the default sequential rate in tasks per hour: 3600 divided by the execution default seconds (decision E2).
    .PARAMETER Default
        The default seconds per type from Resolve-EpicProgressStepDefault.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [hashtable] $Default)

    return 3600.0 / [double] $Default['execution']
}

function Get-EpicProgressFeatureVelocity {
    <#
    .SYNOPSIS
        Return Issue, Tasks, ActiveSeconds, TasksPerHour, and Qualifies for one feature from the duration ledger (decision E3).
    .DESCRIPTION
        Only samples whose key starts with '<issue>|exec|' (ordinal comparison) are counted, so
        another issue's execution samples and every non-execution sample are ignored. The rate
        is Tasks / (ActiveSeconds / 3600); with no active seconds it is NaN. The feature
        qualifies when Tasks is at least 5 and ActiveSeconds is at least 900.
    .PARAMETER Issue
        The feature issue number.
    .PARAMETER Ledger
        The duration ledger: a hashtable from step type to its samples.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger
    )

    $prefix = "$Issue|exec|"
    $tasks = 0
    $seconds = 0.0
    if ($null -ne $Ledger) {
        foreach ($type in $Ledger.Keys) {
            foreach ($entry in @($Ledger[$type] | Where-Object { $null -ne $_ })) {
                if (([string] $entry.key).StartsWith($prefix, [System.StringComparison]::Ordinal)) {
                    $tasks++
                    $seconds += [double] $entry.seconds
                }
            }
        }
    }
    $rate = [double]::NaN
    if ($seconds -gt 0) { $rate = $tasks / ($seconds / 3600.0) }
    return [pscustomobject]@{
        Issue         = $Issue
        Tasks         = $tasks
        ActiveSeconds = $seconds
        TasksPerHour  = $rate
        Qualifies     = ($tasks -ge 5 -and $seconds -ge 900)
    }
}

function Get-EpicProgressPooledVelocity {
    <#
    .SYNOPSIS
        Return the pooled sequential velocity (Median, StandardDeviation, Count) and each feature's Rate with its Source.
    .DESCRIPTION
        The median and the across-feature standard deviation (n-1; NaN below 2) are taken over
        the qualifying features only; Count is their number, and Median is NaN when none
        qualifies. Each feature's rate is its own when it qualifies (source 'own'), else the
        pooled median when one exists (source 'pooled'), else the default rate (source
        'default').
    .PARAMETER Feature
        The per-feature records from Get-EpicProgressFeatureVelocity.
    .PARAMETER DefaultRate
        The default rate from Get-EpicProgressDefaultRate.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [double] $DefaultRate
    )

    [double[]] $qualifying = @($Feature | Where-Object { $null -ne $_ -and $_.Qualifies } | ForEach-Object { [double] $_.TasksPerHour })
    $median = Get-EpicProgressMedian -Value $qualifying
    $rates = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $Feature) {
        if ($null -eq $record) { continue }
        if ($record.Qualifies) {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = [double] $record.TasksPerHour; Source = 'own' })
        } elseif ($qualifying.Count -gt 0) {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = $median; Source = 'pooled' })
        } else {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = $DefaultRate; Source = 'default' })
        }
    }
    return [pscustomobject]@{
        Median            = $median
        StandardDeviation = Get-EpicProgressStandardDeviation -Value $qualifying
        Count             = $qualifying.Count
        Rate              = [object[]] $rates.ToArray()
    }
}
