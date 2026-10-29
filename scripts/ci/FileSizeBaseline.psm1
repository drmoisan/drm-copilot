<#
.SYNOPSIS
    Pure baseline JSON handling and repository-level ratchet evaluation for the file-size policy (issue #990).

.DESCRIPTION
    config/file-size-baseline.json records every legacy covered file above the 800-line hard
    limit with its logical line count:

        { "schemaVersion": 1, "hardLimit": 800, "files": { "<path>": <count>, ... } }

    Keys are repository-relative forward-slash paths sorted by ordinal comparison; the text
    uses a two-space indent, LF line endings, and a trailing newline, so the generator output
    is byte-stable and reviewable.

    The single-entry ratchet comparison lives in the shared policy module
    .claude/lib/file-size-policy/FileSizePolicy.psm1 (Compare-FileSizeBaselineEntry); this
    module applies it across the whole repository. It is repository-internal and is not
    shipped by push-down. Every function is pure: callers supply the sizes and the JSON text.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/lib/file-size-policy/FileSizePolicy.psm1') -ErrorAction Stop

function ConvertTo-FileSizeBaselineJson {
    <#
    .SYNOPSIS
        Render a path-to-size map as the canonical baseline JSON text.
    .PARAMETER Files
        A dictionary from repository-relative path to recorded logical line count.
    .OUTPUTS
        System.String: the JSON text with LF endings and a trailing newline.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary] $Files
    )

    $hardLimit = (Get-FileSizePolicyLimit).HardLimit
    [string[]] $keys = @($Files.Keys | ForEach-Object { [string]$_ })
    [System.Array]::Sort($keys, [System.StringComparer]::Ordinal)

    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append("{`n  `"schemaVersion`": 1,`n  `"hardLimit`": $hardLimit,`n")
    if ($keys.Count -eq 0) {
        [void]$builder.Append("  `"files`": {}`n}`n")
        return $builder.ToString()
    }

    [void]$builder.Append("  `"files`": {`n")
    for ($index = 0; $index -lt $keys.Count; $index++) {
        $key = $keys[$index]
        $separator = if ($index -lt ($keys.Count - 1)) { ',' } else { '' }
        $encodedKey = ConvertTo-Json -InputObject $key -Compress
        [void]$builder.Append("    $encodedKey`: $([int]$Files[$key])$separator`n")
    }
    [void]$builder.Append("  }`n}`n")
    return $builder.ToString()
}

function ConvertFrom-FileSizeBaselineJson {
    <#
    .SYNOPSIS
        Parse and validate baseline JSON text.
    .DESCRIPTION
        Throws when the text is not a JSON object, when schemaVersion is not 1, when hardLimit
        is not the policy hard limit, when files is not an object, or when a recorded size is
        not a positive integer.
    .PARAMETER Json
        The baseline file text.
    .OUTPUTS
        A PSCustomObject with SchemaVersion, HardLimit, and Files (an ordered dictionary from
        path to recorded size, in file order).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Json
    )

    try {
        $parsed = ConvertFrom-Json -InputObject $Json -AsHashtable -ErrorAction Stop
    } catch {
        throw "File-size baseline is not valid JSON: $($_.Exception.Message)"
    }
    if ($parsed -isnot [System.Collections.IDictionary]) {
        throw 'File-size baseline must be a JSON object.'
    }

    $hardLimit = (Get-FileSizePolicyLimit).HardLimit
    if (-not $parsed.Contains('schemaVersion') -or $parsed['schemaVersion'] -ne 1) {
        throw 'File-size baseline schemaVersion must be 1.'
    }
    if (-not $parsed.Contains('hardLimit') -or $parsed['hardLimit'] -ne $hardLimit) {
        throw "File-size baseline hardLimit must be $hardLimit."
    }
    if (-not $parsed.Contains('files') -or $parsed['files'] -isnot [System.Collections.IDictionary]) {
        throw 'File-size baseline files must be a JSON object.'
    }

    $files = [ordered]@{}
    foreach ($entry in $parsed['files'].GetEnumerator()) {
        $value = $entry.Value
        if (($value -isnot [int] -and $value -isnot [long]) -or $value -le 0) {
            throw "File-size baseline entry '$($entry.Key)' must be a positive integer."
        }
        $files[[string]$entry.Key] = [int]$value
    }

    return [pscustomobject]@{ SchemaVersion = 1; HardLimit = $hardLimit; Files = $files }
}

function Get-FileSizeRatchetViolation {
    <#
    .SYNOPSIS
        Evaluate the strict ratchet for every covered file on disk and every baseline entry.
    .DESCRIPTION
        Applies Compare-FileSizeBaselineEntry to each path in the union of the current sizes
        and the baseline. A path present only in the baseline is evaluated as a file with no
        file on disk, so a deleted or renamed baselined file reports a stale entry, and its new
        path reports a new file over the hard limit unless the entry moved with it.
    .PARAMETER CurrentSize
        A dictionary from repository-relative path to the current logical line count of each
        covered file on disk.
    .PARAMETER Baseline
        A dictionary from repository-relative path to the recorded size.
    .OUTPUTS
        The violations (Path, Rule, Message) in ordinal path order, written to the pipeline;
        nothing when there is no violation. Callers wrap the call in @() to get an array.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary] $CurrentSize,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary] $Baseline
    )

    # Copy both maps into ordinal dictionaries so paths that differ only by case stay distinct.
    $current = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $CurrentSize.GetEnumerator()) { $current[[string]$entry.Key] = [int]$entry.Value }
    $recorded = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $Baseline.GetEnumerator()) { $recorded[[string]$entry.Key] = [int]$entry.Value }

    $pathSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($key in $current.Keys) { [void]$pathSet.Add($key) }
    foreach ($key in $recorded.Keys) { [void]$pathSet.Add($key) }
    [string[]] $paths = @($pathSet)
    [System.Array]::Sort($paths, [System.StringComparer]::Ordinal)

    foreach ($path in $paths) {
        # Distinct local names: PowerShell variable names are case-insensitive, so a local
        # named like the typed -CurrentSize parameter would be coerced to IDictionary.
        $sizeOnDisk = $null
        if ($current.ContainsKey($path)) { $sizeOnDisk = $current[$path] }
        $sizeRecorded = $null
        if ($recorded.ContainsKey($path)) { $sizeRecorded = $recorded[$path] }

        $violation = Compare-FileSizeBaselineEntry -Path $path -CurrentSize $sizeOnDisk -BaselineSize $sizeRecorded
        if ($null -ne $violation) { $violation }
    }
}

Export-ModuleMember -Function ConvertTo-FileSizeBaselineJson, ConvertFrom-FileSizeBaselineJson, Get-FileSizeRatchetViolation
