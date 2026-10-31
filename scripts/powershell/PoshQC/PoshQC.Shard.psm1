<#
.SYNOPSIS
Selects the test files assigned to one shard (issue #953).
.DESCRIPTION
Assigns the files in longest-processing-time order (issue #953, CR-10): heaviest file first, equal weights
in ordinal path order, each file to the shard with the least assigned weight, then the fewest files, then
the lowest index, so the shard loads differ by at most the weight of one file. When Weight is omitted every
file weighs 1, which assigns the files round-robin in ordinal path order. Returns this shard's files in
input order. Throws when ShardCount is below 1, ShardIndex is outside 1..ShardCount, Weight and TestFile
differ in length, or a weight is negative (CR-18).
.PARAMETER TestFile
Ordered list of test file paths to distribute.
.PARAMETER ShardIndex
One-based index of the shard to select.
.PARAMETER ShardCount
Total number of shards.
.PARAMETER Weight
Optional non-negative weight of each test file (for example its size in bytes), parallel to TestFile.
#>
function Get-PoshQCShardSlice {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [long[]] $Weight
    )

    if ($ShardCount -lt 1) {
        throw "ShardCount must be at least 1; received $ShardCount."
    }
    if ($ShardIndex -lt 1 -or $ShardIndex -gt $ShardCount) {
        throw "ShardIndex must be between 1 and $ShardCount; received $ShardIndex."
    }
    if ($null -eq $Weight) {
        $Weight = [long[]] (@(1) * $TestFile.Count)
    }
    if ($Weight.Count -ne $TestFile.Count) {
        throw "Weight lists $($Weight.Count) values; TestFile lists $($TestFile.Count) files."
    }
    for ($position = 0; $position -lt $Weight.Count; $position++) {
        if ($Weight[$position] -lt 0) {
            throw "Weight must not be negative; '$($TestFile[$position])' has weight $($Weight[$position])."
        }
    }

    $order = [int[]] @(for ($position = 0; $position -lt $TestFile.Count; $position++) { $position })
    $heaviestFirst = [System.Comparison[int]] {
        param([int] $Left, [int] $Right)
        $byWeight = $Weight[$Right].CompareTo($Weight[$Left])
        if ($byWeight -ne 0) { return $byWeight }
        [string]::CompareOrdinal($TestFile[$Left], $TestFile[$Right])
    }
    [System.Array]::Sort($order, $heaviestFirst)

    $load = New-Object 'long[]' $ShardCount
    $fileCount = New-Object 'int[]' $ShardCount
    $selected = New-Object 'System.Collections.Generic.HashSet[int]'
    foreach ($position in $order) {
        $target = 0
        for ($shard = 1; $shard -lt $ShardCount; $shard++) {
            if ($load[$shard] -lt $load[$target] -or ($load[$shard] -eq $load[$target] -and $fileCount[$shard] -lt $fileCount[$target])) {
                $target = $shard
            }
        }
        $load[$target] += $Weight[$position]
        $fileCount[$target]++
        if ($target -eq $ShardIndex - 1) {
            [void] $selected.Add($position)
        }
    }

    for ($position = 0; $position -lt $TestFile.Count; $position++) {
        if ($selected.Contains($position)) {
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
.PARAMETER Weight
Optional weight of each test file, passed to Get-PoshQCShardSlice.
#>
function New-PoshQCShardManifest {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $RootPath,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [long[]] $Weight
    )

    $sliceArguments = @{ TestFile = $TestFile; ShardIndex = $ShardIndex; ShardCount = $ShardCount }
    if ($PSBoundParameters.ContainsKey('Weight')) {
        $sliceArguments['Weight'] = $Weight
    }
    $selected = @(Get-PoshQCShardSlice @sliceArguments)
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

<#
.SYNOPSIS
Selects this shard's test files for Invoke-PoshQCTest (issue #953).
.DESCRIPTION
Weights each enumerated test file with Get-PoshQCShardTestFileWeight (a FileInfo item, as the default
EnumerateTests seam returns, weighs the UTF-8 size of its text with CRLF counted as LF; CR-19), builds
the manifest with New-PoshQCShardManifest, and throws when the shard selects no test file (CR-13), so Pester
never runs with an empty Run.Path. When ShardFileListPath is set, WriteShardFileList receives the path and
the manifest JSON without selectedFullPath. Returns the full paths of the selected files.
.PARAMETER RootPath
Workspace root that the manifest paths are relative to.
.PARAMETER TestFile
Enumerated test files: FileInfo items, objects with FullName (and optionally Length), or path strings.
.PARAMETER ShardIndex
One-based index of the shard.
.PARAMETER ShardCount
Total number of shards.
.PARAMETER ShardFileListPath
Optional path that receives the shard manifest JSON.
.PARAMETER WriteShardFileList
Seam that writes the manifest JSON; receives the path and the JSON text.
.PARAMETER ReadWeightsText
Optional seam passed to Get-PoshQCShardTestFileWeight that returns the weights-file text for RootPath, or $null (issue #1048).
#>
function Select-PoshQCShardTestFile {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][string] $RootPath,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [string] $ShardFileListPath,
        [Parameter(Mandatory)][scriptblock] $WriteShardFileList,
        [scriptblock] $ReadWeightsText
    )

    $paths = [string[]] @($TestFile | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.FullName } })
    # Issue #1048: the root lets the weight lookup read config/poshqc-shard-weights.json; a supplied reader replaces the default one.
    $weightArguments = @{ TestFile = $TestFile; RootPath = $RootPath }
    if ($PSBoundParameters.ContainsKey('ReadWeightsText')) {
        $weightArguments['ReadWeightsText'] = $ReadWeightsText
    }
    $weights = [long[]] @(Get-PoshQCShardTestFileWeight @weightArguments)
    $manifest = New-PoshQCShardManifest -RootPath $RootPath -TestFile $paths -ShardIndex $ShardIndex -ShardCount $ShardCount -Weight $weights
    if (@($manifest.selected).Count -eq 0) {
        throw "Shard $ShardIndex of $ShardCount selects no test file; $($paths.Count) test files cannot fill $ShardCount shards. Lower the shard count."
    }
    if ($ShardFileListPath) {
        & $WriteShardFileList $ShardFileListPath ($manifest | Select-Object -Property shardIndex, shardCount, all, selected | ConvertTo-Json -Depth 4)
    }
    [string[]] $manifest.selectedFullPath
}

<#
.SYNOPSIS
Parses and validates the text of config/poshqc-shard-weights.json (issue #1048).
.DESCRIPTION
The document must be a JSON object with version 1, unit 'ms', and a non-empty files map whose keys are
repository-relative forward-slash paths (no backslash, no leading slash, no colon) and whose values are
non-negative integers. Throws a message that names poshqc-shard-weights.json otherwise. Returns a dictionary
of milliseconds keyed by path, compared case-insensitively.
.PARAMETER Json
The text of the weights file.
#>
function ConvertFrom-PoshQCShardWeightJson {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[string, long]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Json
    )

    $name = 'config/poshqc-shard-weights.json'
    try {
        $document = $Json | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "$name is not valid JSON: $($_.Exception.Message)"
    }
    if ($null -eq $document -or $document -isnot [System.Management.Automation.PSCustomObject]) {
        throw "$name must hold a JSON object."
    }
    $isInteger = { param($Value) $Value -is [int] -or $Value -is [long] }
    $version = $document.PSObject.Properties['version']
    if ($null -eq $version -or -not (& $isInteger $version.Value) -or $version.Value -ne 1) {
        throw "$name must declare version 1."
    }
    $unit = $document.PSObject.Properties['unit']
    if ($null -eq $unit -or [string] $unit.Value -cne 'ms') {
        throw "$name must declare unit 'ms'."
    }
    $files = $document.PSObject.Properties['files']
    if ($null -eq $files -or $files.Value -isnot [System.Management.Automation.PSCustomObject] -or @($files.Value.PSObject.Properties).Count -eq 0) {
        throw "$name must list at least one file in a 'files' object."
    }

    $weights = New-Object 'System.Collections.Generic.Dictionary[string,long]' ([System.StringComparer]::OrdinalIgnoreCase)
    # Validate each entry: a repository-relative forward-slash key and a non-negative integer of milliseconds.
    foreach ($entry in $files.Value.PSObject.Properties) {
        if ([string]::IsNullOrWhiteSpace($entry.Name) -or $entry.Name.Contains('\') -or $entry.Name.StartsWith('/') -or $entry.Name.Contains(':')) {
            throw "$name lists '$($entry.Name)', which is not a repository-relative forward-slash path."
        }
        if (-not (& $isInteger $entry.Value) -or $entry.Value -lt 0) {
            throw "$name gives '$($entry.Name)' the weight '$($entry.Value)'; weights must be non-negative integers."
        }
        $weights[$entry.Name] = [long] $entry.Value
    }
    , $weights
}

<#
.SYNOPSIS
Returns the shard weight of each enumerated test file (issue #953, CR-19; measured weights issue #1048).
.DESCRIPTION
When RootPath is supplied and ReadWeightsText returns text, the text is parsed with
ConvertFrom-PoshQCShardWeightJson and each test file weighs the milliseconds listed for its repository-relative
forward-slash path; a file without an entry weighs the median of all listed values, so bytes and milliseconds
are never mixed. Otherwise the size path runs: a FileInfo item weighs the UTF-8 byte count of its text after
every CRLF pair is replaced by LF, so a checkout with CRLF line endings computes the same weights, and therefore
the same shard assignment, as a checkout with LF line endings. Another object weighs its Length property when it
has one; a plain path string, or an object without a Length property, weighs 1. Returns one weight per item, in
input order.
.PARAMETER TestFile
Enumerated test files: FileInfo items, objects with FullName (and optionally Length), or path strings.
.PARAMETER ReadTestFileText
Seam that returns the text of a test file from its full path. Defaults to [System.IO.File]::ReadAllText.
.PARAMETER RootPath
Optional workspace root. Without it the size path runs.
.PARAMETER ReadWeightsText
Seam that receives RootPath and returns the text of RootPath/config/poshqc-shard-weights.json, or $null when the
file does not exist. Defaults to Test-Path and Get-Content -Raw.
#>
function Get-PoshQCShardTestFileWeight {
    [CmdletBinding()]
    [OutputType([long[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $TestFile,
        [scriptblock] $ReadTestFileText = { param([string] $Path) [System.IO.File]::ReadAllText($Path) },
        [string] $RootPath,
        [scriptblock] $ReadWeightsText = {
            param([string] $Root)
            $weightsPath = Join-Path (Join-Path $Root 'config') 'poshqc-shard-weights.json'
            if (Test-Path -LiteralPath $weightsPath) { Get-Content -Raw -LiteralPath $weightsPath } else { $null }
        }
    )

    $weightsText = if ($RootPath) { & $ReadWeightsText $RootPath } else { $null }
    if ($null -ne $weightsText) {
        $measured = ConvertFrom-PoshQCShardWeightJson -Json ([string] $weightsText)
        [long[]] $listed = @($measured.Values)
        [System.Array]::Sort($listed)
        $middle = [int] [math]::Floor($listed.Count / 2)
        $median = if ($listed.Count % 2 -eq 1) { $listed[$middle] } else { [long] [math]::Floor(($listed[$middle - 1] + $listed[$middle]) / 2) }
        $prefix = ($RootPath -replace '\\', '/').TrimEnd('/') + '/'
        # Look up each file by its root-relative forward-slash path; an unlisted file weighs the median.
        $measuredWeights = New-Object 'System.Collections.Generic.List[long]'
        foreach ($item in $TestFile) {
            $path = $(if ($item -is [string]) { $item } else { [string] $item.FullName }) -replace '\\', '/'
            $relative = if ($path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { $path.Substring($prefix.Length) } else { $path }
            $weight = [long] 0
            if ($measured.TryGetValue($relative, [ref] $weight)) { $measuredWeights.Add($weight) } else { $measuredWeights.Add($median) }
        }
        return [long[]] $measuredWeights.ToArray()
    }

    $weights = New-Object 'System.Collections.Generic.List[long]'
    foreach ($item in $TestFile) {
        if ($item -is [System.IO.FileInfo]) {
            $text = [string] (& $ReadTestFileText $item.FullName)
            $weights.Add([System.Text.Encoding]::UTF8.GetByteCount($text.Replace("`r`n", "`n")))
        } elseif ($item -isnot [string] -and $null -ne $item.PSObject.Properties['Length']) {
            $weights.Add([long] $item.Length)
        } else {
            $weights.Add(1)
        }
    }
    [long[]] $weights.ToArray()
}
