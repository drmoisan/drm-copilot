<#
.SYNOPSIS
Selects the test files assigned to one shard (issue #953).
.DESCRIPTION
Returns, in input order, the entries at zero-based positions i where i % ShardCount equals
ShardIndex - 1 (round-robin assignment). Throws when ShardCount is below 1 or ShardIndex is
outside 1..ShardCount.
.PARAMETER TestFile
Ordered list of test file paths to distribute.
.PARAMETER ShardIndex
One-based index of the shard to select.
.PARAMETER ShardCount
Total number of shards.
#>
function Get-PoshQCShardSlice {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount
    )

    if ($ShardCount -lt 1) {
        throw "ShardCount must be at least 1; received $ShardCount."
    }
    if ($ShardIndex -lt 1 -or $ShardIndex -gt $ShardCount) {
        throw "ShardIndex must be between 1 and $ShardCount; received $ShardIndex."
    }

    for ($position = 0; $position -lt $TestFile.Count; $position++) {
        if ($position % $ShardCount -eq $ShardIndex - 1) {
            $TestFile[$position]
        }
    }
}

<#
.SYNOPSIS
Builds the shard manifest for one shard (issue #953).
.DESCRIPTION
Returns an in-memory object with shardIndex, shardCount, all (root-relative forward-slash paths
of every input file), selected (root-relative paths of this shard's slice), and selectedFullPath
(the slice as given). Relative paths are computed by case-insensitive removal of the root prefix;
a path outside the root keeps its forward-slash form.
.PARAMETER RootPath
Workspace root that the relative paths are computed against.
.PARAMETER TestFile
Ordered list of test file paths to distribute.
.PARAMETER ShardIndex
One-based index of the shard.
.PARAMETER ShardCount
Total number of shards.
#>
function New-PoshQCShardManifest {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $RootPath,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount
    )

    $selected = @(Get-PoshQCShardSlice -TestFile $TestFile -ShardIndex $ShardIndex -ShardCount $ShardCount)
    $prefix = ($RootPath -replace '\\', '/').TrimEnd('/') + '/'
    $toRelative = {
        param([string] $Path)
        $normalized = $Path -replace '\\', '/'
        if ($normalized.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $normalized.Substring($prefix.Length)
        } else {
            $normalized
        }
    }

    [pscustomobject]@{
        shardIndex       = $ShardIndex
        shardCount       = $ShardCount
        all              = @($TestFile | ForEach-Object { & $toRelative $_ })
        selected         = @($selected | ForEach-Object { & $toRelative $_ })
        selectedFullPath = $selected
    }
}

<#
.SYNOPSIS
Verifies that a set of shard manifests covers every test file exactly once (issue #953).
.DESCRIPTION
Throws unless the shard indices are exactly 1..N once each, every manifest declares shardCount N,
every 'all' list is identical, the 'selected' lists are pairwise disjoint, and their union sorted
ordinally equals 'all' sorted ordinally. Returns $true otherwise.
.PARAMETER ShardManifest
The manifests produced by New-PoshQCShardManifest, one per shard (for example loaded from JSON).
#>
function Test-PoshQCShardCompleteness {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][object[]] $ShardManifest
    )

    $count = $ShardManifest.Count
    $indices = @($ShardManifest | ForEach-Object { [int] $_.shardIndex } | Sort-Object)
    if (($indices -join ',') -ne ((1..$count) -join ',')) {
        throw "Shard indices '$($indices -join ',')' are not exactly 1..$count."
    }

    $reference = @($ShardManifest[0].all | ForEach-Object { [string] $_ })
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($manifest in $ShardManifest) {
        if ([int] $manifest.shardCount -ne $count) {
            throw "Shard $($manifest.shardIndex) declares shardCount $($manifest.shardCount); $count manifests were supplied."
        }
        $all = @($manifest.all | ForEach-Object { [string] $_ })
        if (($all -join "`n") -cne ($reference -join "`n")) {
            throw "Shard $($manifest.shardIndex) reports an 'all' list that differs from shard $($ShardManifest[0].shardIndex)."
        }
        foreach ($path in @($manifest.selected | ForEach-Object { [string] $_ })) {
            if (-not $seen.Add($path)) {
                throw "Test file '$path' is selected by more than one shard."
            }
        }
    }

    [string[]] $union = @($seen)
    [string[]] $expected = $reference
    [System.Array]::Sort($union, [System.StringComparer]::Ordinal)
    [System.Array]::Sort($expected, [System.StringComparer]::Ordinal)
    if (($union -join "`n") -cne ($expected -join "`n")) {
        $missing = @($expected | Where-Object { -not $seen.Contains($_) })
        throw "The shard selections do not cover every test file; missing or extra entries (missing: $($missing -join ', '))."
    }

    $true
}

<#
.SYNOPSIS
Verifies that the shard test counts add up to the discovery count (issue #953).
.DESCRIPTION
Throws unless the sum of ShardTestCount equals DiscoveryCount. Returns $true otherwise.
.PARAMETER ShardTestCount
The test count reported by each shard (for example the JUnit testsuites/@tests value).
.PARAMETER DiscoveryCount
The test count reported by a discovery-only Pester pass over every test file.
#>
function Test-PoshQCShardTestCount {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][int[]] $ShardTestCount,
        [Parameter(Mandatory)][int] $DiscoveryCount
    )

    $sum = 0
    foreach ($testCount in $ShardTestCount) {
        $sum += $testCount
    }
    if ($sum -ne $DiscoveryCount) {
        throw "Shard test counts sum to $sum; the discovery pass found $DiscoveryCount tests."
    }

    $true
}
