<#
.SYNOPSIS
    Planning-time issue combination over the scheduling pair data (issue #1013).

.DESCRIPTION
    Destination-runtime PowerShell mirror of
    scripts/dev_tools/_blast_radius_combination.py (spec D-5). Finds the pairs
    of work items whose integration cost is high enough that delivering them as
    one item costs less than merging them, and groups them into combinations.

    Rules:
      1. Disabled when conflict_tolerance is absent or tolerance_percent is 0.
      2. Get-BlastRadiusPairDecision supplies each conflicting pair's reasons,
         cost (including the D-7 contract term), and benefit; edges and
         tolerated pairs are both evaluated.
      3. A pair is a candidate when its full reasons contain
         contract_dependency or it has a same-file overlap: an overlapping entry
         pair, after the mergeable exclusion, of two equal concrete entries that
         do not match append_only_paths.
      4. A candidate qualifies when
         cost * 100 >= benefit * combination_threshold_percent.
      5. Qualifying pairs are grouped into connected components (union-find);
         each becomes one combination with ascending members, primary equal to
         the smallest member, pairs sorted by (a, b), and estimated_savings equal
         to the sum of its pair costs.

    Parity notes for maintainers:
      - The Python module is the reference implementation; the committed
        combination fixtures bind the two runtimes together.
      - Every function is pure: no filesystem, subprocess, network, or clock
        access, and no input is mutated.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusGlob.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusConflict.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusValidation.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusScheduling.psm1') -Force -ErrorAction Stop

# The threshold is a percentage of the pair benefit.
$script:Percent = 100
$script:ContractDependency = 'contract_dependency'

# Port of has_same_file_overlap: two equal, non-mergeable, non-append-only
# concrete entries among the overlapping pairs the relation enumerates.
function Test-SameFileOverlap {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $RadiusA,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $RadiusB,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [hashtable] $Tolerance
    )

    $left = ConvertTo-NormalizedBlastRadius -Radius $RadiusA
    $right = ConvertTo-NormalizedBlastRadius -Radius $RadiusB
    $mergeable = [string[]]@(Get-ConfigMergeablePath -Config $Config)
    $pathsA = @(Get-NonMergeablePathEntry -Entry ([string[]]@($left['paths'])) -MergeablePath $mergeable)
    $pathsB = @(Get-NonMergeablePathEntry -Entry ([string[]]@($right['paths'])) -MergeablePath $mergeable)
    $appendOnly = [string[]]@($Tolerance['append_only_paths'])
    foreach ($pair in @(Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB)) {
        $entry = [string]$pair['EntryA']
        $isEqual = [string]::Equals($entry, [string]$pair['EntryB'], [System.StringComparison]::Ordinal)
        if ($isEqual -and -not (Test-GlobEntry -Entry $entry) -and -not (Test-MergeablePath -Entry $entry -MergeablePath $appendOnly)) {
            return $true
        }
    }
    return $false
}

# Validate item keys (distinct integers) and return records sorted by key.
function Get-CombinationOrderedItem {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Item
    )

    $seen = [System.Collections.Generic.HashSet[long]]::new()
    $record = foreach ($entry in $Item) {
        $key = [long]$entry['key']
        if (-not $seen.Add($key)) {
            throw "combination item keys must be distinct: $key."
        }
        $band = if ($entry.Contains('band')) { $entry['band'] } else { $null }
        @{ key = $key; radius = $entry['radius']; band = $band }
    }
    return @(@($record) | Where-Object { $null -ne $_ } | Sort-Object -Property { $_['key'] })
}

# Return the union-find root of Key, registering Key as its own root when new.
# Parent is the component's working map, owned by Get-CombinationComponent.
function Get-UnionFindRoot {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Parent,
        [Parameter(Mandatory = $true)]
        [long] $Key
    )

    if (-not $Parent.ContainsKey($Key)) { $Parent[$Key] = $Key }
    $root = $Key
    while ($Parent[$root] -ne $root) { $root = $Parent[$root] }
    return $root
}

# Group qualifying pairs into connected components with union-find.
function Get-CombinationComponent {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Pair
    )

    $parent = @{}
    foreach ($entry in $Pair) {
        $rootA = Get-UnionFindRoot -Parent $parent -Key $entry['a']
        $rootB = Get-UnionFindRoot -Parent $parent -Key $entry['b']
        if ($rootA -ne $rootB) {
            $parent[[System.Math]::Max($rootA, $rootB)] = [System.Math]::Min($rootA, $rootB)
        }
    }

    $grouped = @{}
    foreach ($entry in $Pair) {
        $root = Get-UnionFindRoot -Parent $parent -Key $entry['a']
        if (-not $grouped.ContainsKey($root)) { $grouped[$root] = [System.Collections.Generic.List[object]]::new() }
        $grouped[$root].Add($entry)
    }
    $combination = foreach ($root in @($grouped.Keys | Sort-Object)) {
        $component = @($grouped[$root].ToArray() | Sort-Object -Property { $_['a'] }, { $_['b'] })
        [long[]]$member = @($component | ForEach-Object { $_['a']; $_['b'] } | Sort-Object -Unique)
        [long]$savings = 0
        foreach ($entry in $component) { $savings += $entry['cost'] }
        [ordered]@{ members = $member; primary = $member[0]; pairs = $component; estimated_savings = $savings }
    }
    return @($combination)
}

function Get-BlastRadiusCombination {
    <#
    .SYNOPSIS
        Find the qualifying pairs of a set of items and group them.

    .DESCRIPTION
        Port of find_combinations. Visits every unordered pair once in ascending
        key order and applies D-5 rules 1 to 5.

    .PARAMETER Item
        The run's items: records carrying key (an integer issue number), radius,
        and an optional band.

    .PARAMETER Config
        Parsed truth table.

    .PARAMETER Relation
        The detection relation passed to every pair decision; pass
        ${function:Test-BlastRadiusConflict}.

    .OUTPUTS
        System.Collections.Hashtable. Keys pairs (ordered records a, b, cost,
        benefit, sorted by (a, b)) and combinations (ordered records members,
        primary, pairs, estimated_savings, sorted by primary). Both are empty
        when combination is disabled.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Item,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Config,
        [scriptblock] $Relation
    )

    if ($null -eq $Relation) {
        throw '-Relation is required: pass ${function:Test-BlastRadiusConflict} from the facade module BlastRadius.psm1.'
    }
    $tolerance = Get-ConfigConflictTolerance -Config $Config
    $ordered = @(Get-CombinationOrderedItem -Item $Item)
    # The absent key reads as the strict tolerance, whose percent is 0.
    if ([long]$tolerance['tolerance_percent'] -eq 0) {
        return @{ pairs = @(); combinations = @() }
    }

    $threshold = [long]$tolerance['combination_threshold_percent']
    $qualifying = [System.Collections.Generic.List[object]]::new()
    for ($first = 0; $first -lt $ordered.Count; $first++) {
        for ($second = $first + 1; $second -lt $ordered.Count; $second++) {
            $a = $ordered[$first]
            $b = $ordered[$second]
            $decision = Get-BlastRadiusPairDecision -RadiusA $a['radius'] -RadiusB $b['radius'] -Config $Config -BandA $a['band'] -BandB $b['band'] -Relation $Relation
            if (-not $decision['conflict']) { continue }
            # The full reasons are read, because contract_dependency is never first.
            $isCandidate = @($decision['reasons']) -ccontains $script:ContractDependency
            if (-not $isCandidate) {
                $isCandidate = Test-SameFileOverlap -RadiusA $a['radius'] -RadiusB $b['radius'] -Config $Config -Tolerance $tolerance
            }
            if ($isCandidate -and ($decision['cost'] * $script:Percent -ge $decision['benefit'] * $threshold)) {
                $qualifying.Add([ordered]@{ a = $a['key']; b = $b['key']; cost = [long]$decision['cost']; benefit = [long]$decision['benefit'] })
            }
        }
    }

    $pair = @($qualifying.ToArray())
    return @{ pairs = $pair; combinations = @(Get-CombinationComponent -Pair $pair) }
}

Export-ModuleMember -Function Get-BlastRadiusCombination
