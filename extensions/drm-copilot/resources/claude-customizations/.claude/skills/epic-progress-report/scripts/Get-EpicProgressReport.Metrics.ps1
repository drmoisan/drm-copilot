<#
.SYNOPSIS
    Estimate and formatting functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. Numeric and time text uses the invariant
    culture, and every non-finite value prints as n/a. Get-EpicProgressTypeEstimate computes
    the per-type remaining-time estimate of the step model (remaining steps times the median
    of each type, with in-progress credit and blocked steps excluded), and
    Get-EpicProgressWaveParallelSecond combines per-feature remaining seconds by wave. The
    task-velocity, standard-deviation, critical-path, and range functions were removed with
    the step model (issue #1118, decision D13). Get-EpicProgressReport.Logic.ps1 dot-sources
    this file, so a consumer dot-sources the Logic hub, not this file.
#>

function Format-EpicProgressHour {
    <#
    .SYNOPSIS
        Format hours as 'H h MM min' from the rounded total minutes; 'n/a' when not finite.
    .PARAMETER Hours
        The hours to format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Hours)

    if ([double]::IsNaN($Hours) -or [double]::IsInfinity($Hours)) { return 'n/a' }
    $minutes = [math]::Round($Hours * 60, [System.MidpointRounding]::AwayFromZero)
    $wholeHours = [math]::Floor($minutes / 60)
    return [string]::Format([cultureinfo]::InvariantCulture, '{0:N0} h {1:00} min', $wholeHours, ($minutes - 60 * $wholeHours))
}

function Format-EpicProgressNumber {
    <#
    .SYNOPSIS
        Return a number rounded to Digits decimals as invariant text; 'n/a' when not finite.
    .PARAMETER Value
        The number to format.
    .PARAMETER Digits
        The decimal digits kept (0 to 15). The default of 15 prints the value unrounded.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [double] $Value,
        [ValidateRange(0, 15)] [int] $Digits = 15
    )

    if ([double]::IsNaN($Value) -or [double]::IsInfinity($Value)) { return 'n/a' }
    return ([math]::Round($Value, $Digits)).ToString([cultureinfo]::InvariantCulture)
}

function Get-EpicProgressWeeklyText {
    <#
    .SYNOPSIS
        Return a weekly quota percentage as 'N%', or 'n/a' when it is not finite.
    .PARAMETER Value
        The percentage.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Value)

    $text = Format-EpicProgressNumber -Value $Value
    if ($text -eq 'n/a') { return $text }
    return "$text%"
}

function Get-EpicProgressTypeEstimate {
    <#
    .SYNOPSIS
        Return the per-type remaining-time estimate (Type rows, InProgress rows, and totals) of a step list.
    .DESCRIPTION
        Each type with at least one step gives a row (Type, Done, InProgress, Remaining,
        Blocked, MedianSeconds, Samples, IsDefault, IsApproximate, SubtotalSeconds,
        BlockedSubtotalSeconds). The median is taken over the type's retained ledger samples;
        a type without a sample uses its default and sets IsDefault, and IsApproximate is set
        when an approximate sample is retained. The subtotal is remaining steps times the
        median plus, per in-progress step, max(0, median - elapsed). Blocked steps are left out
        of the subtotal and summed in BlockedSubtotalSeconds; a blocked step that had started
        counts its elapsed time only up to the start of the item's blocked span. Each
        in-progress step also gives an InProgress row (Issue, Type, ElapsedSeconds,
        MedianSeconds, OverMedian, StartRecorded); StartRecorded is false when the step has no
        recorded start, whose ElapsedSeconds is then 0. TotalSeconds is the sum of the
        subtotals (decision D7).
    .PARAMETER Step
        The step records.
    .PARAMETER Ledger
        The duration ledger: a hashtable from step type to its samples.
    .PARAMETER Default
        The default seconds per type from Resolve-EpicProgressStepDefault.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Step,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{}
    )

    $rows = [System.Collections.Generic.List[object]]::new()
    $running = [System.Collections.Generic.List[object]]::new()
    $total = 0.0
    $blockedTotal = 0.0
    foreach ($type in @(Get-EpicProgressStepTypeCatalog | ForEach-Object { $_.Type })) {
        $typeSteps = @($Step | Where-Object { $_.Type -eq $type })
        if ($typeSteps.Count -eq 0) { continue }
        $samples = @()
        if ($null -ne $Ledger -and $Ledger.ContainsKey($type)) { $samples = @($Ledger[$type] | Where-Object { $null -ne $_ }) }
        $isDefault = $samples.Count -eq 0
        $median = [double] $Default[$type]
        if (-not $isDefault) { $median = Get-EpicProgressMedian -Value ([double[]] @($samples | ForEach-Object { [double] $_.seconds })) }
        $subtotal = 0.0
        $blockedSubtotal = 0.0
        foreach ($entry in $typeSteps) {
            $elapsed = 0.0
            if ($null -ne $entry.StartedUnixSeconds) {
                $until = $NowUnixSeconds
                if ($entry.Status -eq 'blocked' -and $BlockedSince.ContainsKey([string] $entry.Issue) -and $null -ne $BlockedSince[[string] $entry.Issue]) {
                    $until = [math]::Min($NowUnixSeconds, [long] $BlockedSince[[string] $entry.Issue])
                }
                $elapsed = [double] [math]::Max(0, $until - [long] $entry.StartedUnixSeconds)
            }
            switch ($entry.Status) {
                'remaining' { $subtotal += $median }
                'in_progress' {
                    $subtotal += [math]::Max(0.0, $median - $elapsed)
                    $running.Add([pscustomobject]@{ Issue = $entry.Issue; Type = $type; ElapsedSeconds = $elapsed; MedianSeconds = $median; OverMedian = ($elapsed -gt $median); StartRecorded = ($null -ne $entry.StartedUnixSeconds) })
                }
                'blocked' { $blockedSubtotal += [math]::Max(0.0, $median - $elapsed) }
            }
        }
        $total += $subtotal
        $blockedTotal += $blockedSubtotal
        $rows.Add([pscustomobject]@{
                Type                   = $type
                Done                   = @($typeSteps | Where-Object { $_.Status -eq 'done' }).Count
                InProgress             = @($typeSteps | Where-Object { $_.Status -eq 'in_progress' }).Count
                Remaining              = @($typeSteps | Where-Object { $_.Status -eq 'remaining' }).Count
                Blocked                = @($typeSteps | Where-Object { $_.Status -eq 'blocked' }).Count
                MedianSeconds          = $median
                Samples                = $samples.Count
                IsDefault              = $isDefault
                IsApproximate          = @($samples | Where-Object { $_.approx }).Count -gt 0
                SubtotalSeconds        = $subtotal
                BlockedSubtotalSeconds = $blockedSubtotal
            })
    }
    return [pscustomobject]@{
        Type                   = [object[]] $rows.ToArray()
        InProgress             = [object[]] $running.ToArray()
        TotalSeconds           = $total
        BlockedSubtotalSeconds = $blockedTotal
        BlockedCount           = @($Step | Where-Object { $_.Status -eq 'blocked' }).Count
        DefaultCount           = @($rows | Where-Object { $_.IsDefault }).Count
    }
}

function Get-EpicProgressWaveParallelSecond {
    <#
    .SYNOPSIS
        Return the wave-parallel remaining seconds: the largest remaining feature of each open wave, summed, plus the epic-level seconds.
    .DESCRIPTION
        A wave is open when one of its features has remaining seconds above 0. The figure is
        secondary to the per-type sum (decision D7). In item mode, with one feature and no
        epic-level steps, it equals the item's sum.
    .PARAMETER Feature
        The per-feature records (Wave, RemainingSeconds).
    .PARAMETER EpicSeconds
        The remaining seconds of the epic-level steps.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [double] $EpicSeconds = 0
    )

    $largest = @{}
    foreach ($record in $Feature) {
        $seconds = [double] $record.RemainingSeconds
        if ($seconds -le 0) { continue }
        $wave = [string] $record.Wave
        if (-not $largest.ContainsKey($wave) -or $seconds -gt $largest[$wave]) { $largest[$wave] = $seconds }
    }
    $sum = [double] $EpicSeconds
    foreach ($value in $largest.Values) { $sum += $value }
    return $sum
}
