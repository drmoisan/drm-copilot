<#
.SYNOPSIS
    Precedence gate: an ordering must pass the parallel scheduling rule (issue #1164).

.DESCRIPTION
    Two items run sequentially if and only if the expected merge time exceeds
    the expected time gained by running them in parallel. An operator --after
    flag or a planner-proposed ordering serializes a pair, so each recorded
    precedence[] entry of kind "cost" must name a pair that the scheduling entry
    point returned as an edge (hard, or merge time greater than gain). An entry
    of kind "correctness" is accepted without a cost test when it carries a
    non-empty reason. An entry without kind is a legacy entry and is honoured
    unchanged without a test (spec B6.4).

    A rejection throws "precedence_not_justified: <detail>", which the admission
    entry script turns into exit 1 and one PARALLEL_ADMISSION_REJECTED line.
    The module is pure: no filesystem, subprocess, network, or clock access, and
    no input is mutated.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../blast-radius/BlastRadiusScheduling.psm1') -Force -ErrorAction Stop

# The rejection code; it is listed in $script:AdmissionRejectionCode of Invoke-ParallelAdmission.ps1.
$script:PrecedenceNotJustified = 'precedence_not_justified'

# Return a dictionary value, or null when the map is not a dictionary or lacks the key.
function Get-PrecedenceGateValue {
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][object] $Map, [string] $Key)

    if ($Map -isnot [System.Collections.IDictionary] -or -not $Map.Contains($Key)) { return $null }
    return $Map[$Key]
}

# Find the record of a list whose unordered {a, b} pair equals the given pair, or null.
function Find-PrecedenceGatePairRecord {
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Record = @(), [long] $First, [long] $Second)

    foreach ($entry in @($Record)) {
        $a = Get-PrecedenceGateValue -Map $entry -Key 'a'
        $b = Get-PrecedenceGateValue -Map $entry -Key 'b'
        if ($null -eq $a -or $null -eq $b) { continue }
        if (([long]$a -eq $First -and [long]$b -eq $Second) -or ([long]$a -eq $Second -and [long]$b -eq $First)) { return $entry }
    }
    return $null
}

# Read the complexity band of one item key from the entry's items, or null.
function Get-PrecedenceGateItemBand {
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Item = @(), [long] $IssueNum)

    foreach ($entry in @($Item)) {
        $key = Get-PrecedenceGateValue -Map $entry -Key 'issue_num'
        if ($null -ne $key -and [long]$key -eq $IssueNum) { return Get-PrecedenceGateValue -Map $entry -Key 'complexity_band' }
    }
    return $null
}

function Test-ParallelPrecedenceJustified {
    <#
    .SYNOPSIS
        Throw precedence_not_justified for an ordering that fails the scheduling rule.
    .DESCRIPTION
        For each precedence entry of kind "cost", the unordered pair {before,
        after} is accepted when it is a returned edge. Otherwise the entry is
        rejected with the pair's recorded estimates: the tolerated overlap's cost
        and benefit, or merge time 0 and the pair's gain (the shorter of the two
        items' band durations, Get-BlastRadiusPairBenefit) when the pair is not a
        detected conflict. A "correctness" entry whose reason is blank or
        whitespace is rejected. An entry without kind is skipped. Entries are
        tested in order and the first rejection is thrown.
    .PARAMETER Entry
        The scheduling result: precedence, edges, tolerated_overlaps, and items
        (issue_num and complexity_band).
    .PARAMETER Tolerance
        A value returned by Get-ConfigConflictTolerance, for the band durations.
    .OUTPUTS
        System.Int32. The number of tested "cost" entries.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Entry,
        [Parameter(Mandatory = $true)][hashtable] $Tolerance
    )

    $edges = @(Get-PrecedenceGateValue -Map $Entry -Key 'edges')
    $tolerated = @(Get-PrecedenceGateValue -Map $Entry -Key 'tolerated_overlaps')
    $items = @(Get-PrecedenceGateValue -Map $Entry -Key 'items')
    $checked = 0
    foreach ($precedence in @(Get-PrecedenceGateValue -Map $Entry -Key 'precedence')) {
        $kind = Get-PrecedenceGateValue -Map $precedence -Key 'kind'
        if ($null -eq $kind) { continue }
        $before = [long](Get-PrecedenceGateValue -Map $precedence -Key 'before')
        $after = [long](Get-PrecedenceGateValue -Map $precedence -Key 'after')
        $flag = "--after ${after}:${before}"
        if ($kind -ceq 'correctness') {
            if ([string]::IsNullOrWhiteSpace([string](Get-PrecedenceGateValue -Map $precedence -Key 'reason'))) {
                throw "$($script:PrecedenceNotJustified): $flag is marked as a correctness ordering with an empty reason"
            }
            continue
        }
        $checked++
        if ($null -ne (Find-PrecedenceGatePairRecord -Record $edges -First $before -Second $after)) { continue }
        $overlap = Find-PrecedenceGatePairRecord -Record $tolerated -First $before -Second $after
        if ($null -ne $overlap) {
            $cost = [long](Get-PrecedenceGateValue -Map $overlap -Key 'cost')
            $benefit = [long](Get-PrecedenceGateValue -Map $overlap -Key 'benefit')
        } else {
            $cost = [long]0
            $benefit = Get-BlastRadiusPairBenefit -BandA (Get-PrecedenceGateItemBand -Item $items -IssueNum $before) `
                -BandB (Get-PrecedenceGateItemBand -Item $items -IssueNum $after) -Tolerance $Tolerance
        }
        throw "$($script:PrecedenceNotJustified): $flag fails the parallel scheduling rule (merge time $cost min does not exceed parallel gain $benefit min); add --reason `"<text>`" to record a correctness ordering"
    }
    return $checked
}

Export-ModuleMember -Function Test-ParallelPrecedenceJustified
