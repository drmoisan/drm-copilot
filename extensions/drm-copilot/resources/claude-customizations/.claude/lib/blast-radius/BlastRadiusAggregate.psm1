<#
.SYNOPSIS
    Aggregate integration-cost cap over tolerated overlaps (issue #1013, D-2).

.DESCRIPTION
    Destination-runtime PowerShell mirror of
    scripts/dev_tools/_blast_radius_aggregate.py. The pairwise edge rule judges
    each pair alone, so one item can accumulate many tolerated overlaps whose
    summed cost exceeds what running it serially would cost. Get-AggregateCappedPair
    caps each item's summed tolerated cost and returns the pairs to promote to
    scheduling edges; Get-BlastRadiusConflictEdge applies the result.

    Cap rule: total(i) is the summed cost of the remaining tolerated overlaps
    that include item i. Item i is over its cap when
    total(i) * 100 > band_duration(i) * tolerance_percent, evaluated in
    integers; a missing band reads as default_band. While an item is over its
    cap, the smallest-key such item promotes its overlap with the minimum key
    (benefit ascending, cost descending, a ascending, b ascending).

    Parity notes for maintainers:
      - The Python module is the reference implementation; the committed
        aggregate fixtures bind the two runtimes together.
      - Every function is pure: no filesystem, subprocess, network, or clock
        access, and no input is mutated. Integers only.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# tolerance_percent is a percentage of the band duration.
$script:Percent = 100

# Resolve an item's band duration, reading a missing band as default_band.
function Get-AggregateBandDuration {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [AllowNull()]
        [object] $Band,
        [Parameter(Mandatory = $true)]
        [hashtable] $Tolerance
    )

    $resolved = if ($null -eq $Band) { $Tolerance['default_band'] } else { $Band }
    $duration = $Tolerance['band_durations']
    if ($resolved -isnot [string] -or -not $duration.ContainsKey($resolved)) {
        throw "band '$resolved' must be one of $(@($duration.Keys | Sort-Object) -join ', ')."
    }
    return [long]$duration[$resolved]
}

# Return the smallest item key whose tolerated total exceeds its cap, or $null.
function Get-FirstOverCapItem {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Remaining,
        [Parameter(Mandatory = $true)]
        [hashtable] $BandByKey,
        [Parameter(Mandatory = $true)]
        [hashtable] $Tolerance
    )

    # Each overlap's cost counts toward both of its items.
    $total = @{}
    foreach ($overlap in $Remaining) {
        foreach ($key in @($overlap['a'], $overlap['b'])) {
            $current = if ($total.ContainsKey($key)) { $total[$key] } else { [long]0 }
            $total[$key] = $current + $overlap['cost']
        }
    }
    $percent = [long]$Tolerance['tolerance_percent']
    foreach ($key in @($total.Keys | Sort-Object)) {
        $band = if ($BandByKey.ContainsKey($key)) { $BandByKey[$key] } else { $null }
        $cap = (Get-AggregateBandDuration -Band $band -Tolerance $Tolerance) * $percent
        if ($total[$key] * $script:Percent -gt $cap) {
            return $key
        }
    }
    return $null
}

function Get-AggregateCappedPair {
    <#
    .SYNOPSIS
        Return the tolerated pairs to promote so every item is within its cap.

    .DESCRIPTION
        Port of select_capped_pairs. Repeatedly takes the smallest-key item that
        is over its cap, promotes its cheapest-to-serialize overlap, and
        recomputes the totals, until no item is over its cap.

    .PARAMETER ToleratedOverlap
        The pairwise tolerated overlaps, in any order: records carrying a, b,
        cost, and benefit.

    .PARAMETER Band
        Item key to complexity band; a key that is absent or maps to null reads
        as default_band.

    .PARAMETER Tolerance
        A value returned by Get-ConfigConflictTolerance.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary. The promoted pairs in
        promotion order, each an ordered record with keys a and b, written to
        the pipeline; nothing when no item is over its cap. Wrap the call in
        @() to read the result as an array. Throws when a band is not a
        configured band.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $ToleratedOverlap,
        [Parameter(Mandatory = $true)]
        [hashtable] $Band,
        [Parameter(Mandatory = $true)]
        [hashtable] $Tolerance
    )

    # Copy every overlap and band key into Int64 records, so integer keys of any
    # width compare equal and no input is mutated.
    $bandByKey = @{}
    foreach ($key in $Band.Keys) { $bandByKey[[long]$key] = $Band[$key] }
    $copied = foreach ($overlap in $ToleratedOverlap) {
        [ordered]@{ a = [long]$overlap['a']; b = [long]$overlap['b']; cost = [long]$overlap['cost']; benefit = [long]$overlap['benefit'] }
    }
    $remaining = [System.Collections.Generic.List[object]]::new()
    foreach ($overlap in @($copied | Sort-Object -Property { $_['a'] }, { $_['b'] })) {
        if ($null -ne $overlap) { $remaining.Add($overlap) }
    }

    $promoted = [System.Collections.Generic.List[object]]::new()
    while ($true) {
        $item = Get-FirstOverCapItem -Remaining @($remaining.ToArray()) -BandByKey $bandByKey -Tolerance $Tolerance
        if ($null -eq $item) {
            # Callers wrap the enumerated records with @() so an empty result is
            # an empty array.
            return $promoted.ToArray()
        }
        # Cheapest to serialize: least benefit, then most cost, then pair keys.
        $cheapest = @($remaining | Where-Object { $_['a'] -eq $item -or $_['b'] -eq $item } |
                Sort-Object -Property { $_['benefit'] }, { - $_['cost'] }, { $_['a'] }, { $_['b'] })[0]
        [void]$remaining.Remove($cheapest)
        $promoted.Add([ordered]@{ a = $cheapest['a']; b = $cheapest['b'] })
    }
}

Export-ModuleMember -Function Get-AggregateCappedPair
