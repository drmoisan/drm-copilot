<#
.SYNOPSIS
    Epic wave-layering computation shipped to every repository the epic skills are
    pushed to (issue #1129).

.DESCRIPTION
    Computes the wave number of every feature in an epic dependency manifest with
    the longest-path-layering formula used by the epic-plan and epic-orchestrate
    skills: wave(f) = 0 when f has no dependencies, otherwise
    wave(f) = 1 + max(wave(d) for each dependency d of f).

    Get-EpicWaveNumber is pure: it takes a feature-to-dependencies dictionary and
    returns an ordinal-sorted ordered map of feature to wave number. It rejects a
    self-loop, an unresolved dependency reference, and a dependency cycle with
    three distinct messages that begin EPIC_WAVE_SELF_LOOP:, EPIC_WAVE_UNRESOLVED_REFERENCE:,
    and EPIC_WAVE_CYCLE:. Feature names compare ordinally and case-sensitively.

    Invoke-EpicWaveCommand is the command entry used by Invoke-EpicWave.ps1. It
    reads a JSON manifest through an injectable reader, calls Get-EpicWaveNumber,
    and returns an object with ExitCode, Stdout, and Stderr: 0 on success, 1 for a
    manifest error (self-loop, cycle, or unresolved reference), and 2 for a usage
    error (empty path, unreadable file, or input that is not a JSON object of string
    arrays). Manifest keys are parsed case-sensitively.

    The Python module scripts/dev_tools/epic_wave_computation.py is this
    repository's parity reference; both implementations are exercised by the shared
    corpus tests/fixtures/epic_wave/wave-computation-cases.json.

.NOTES
    Compatible with PowerShell 7+. No external module dependencies and no network
    access. Mirrored byte-identically under extensions/drm-copilot/resources/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Resolves one feature's wave number by memoized depth-first recursion.

.PARAMETER Feature
    The feature whose wave number is resolved.

.PARAMETER Manifest
    Ordinal map of feature to its dependency list.

.PARAMETER Memo
    Ordinal map of already resolved feature to wave number; written by this function.

.PARAMETER InProgress
    Ordinal set of features on the active recursion path; a revisit proves a cycle.

.OUTPUTS
    The resolved wave number.
#>
function Resolve-EpicWaveFeature {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][string] $Feature,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.Dictionary[string, string[]]] $Manifest,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.Dictionary[string, int]] $Memo,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.HashSet[string]] $InProgress
    )

    if ($Memo.ContainsKey($Feature)) { return $Memo[$Feature] }
    if (-not $InProgress.Add($Feature)) {
        throw "EPIC_WAVE_CYCLE: Epic dependency manifest contains a cycle at feature '$Feature'; wave numbers cannot be computed for a cyclic dependency graph."
    }

    # A feature with no dependencies is wave 0; otherwise it sits one layer above
    # the deepest dependency it relies on, so each dependency is resolved first.
    $wave = 0
    foreach ($dependency in $Manifest[$Feature]) {
        $candidate = 1 + (Resolve-EpicWaveFeature -Feature $dependency -Manifest $Manifest -Memo $Memo -InProgress $InProgress)
        if ($candidate -gt $wave) { $wave = $candidate }
    }

    [void] $InProgress.Remove($Feature)
    $Memo[$Feature] = $wave
    return $wave
}

<#
.SYNOPSIS
    Computes the wave number of every feature in a dependency manifest.

.PARAMETER Manifest
    A dictionary of feature name to a list of the feature names it depends on. A
    null or empty list means the feature has no dependencies.

.OUTPUTS
    An ordinal-sorted ordered dictionary of feature name to wave number.
#>
function Get-EpicWaveNumber {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Manifest
    )

    # Copy the manifest into an ordinal, case-sensitive map so feature names compare
    # exactly and the caller's dictionary is never mutated.
    $ordinal = [System.Collections.Generic.Dictionary[string, string[]]]::new([StringComparer]::Ordinal)
    foreach ($key in $Manifest.Keys) {
        $ordinal[[string] $key] = [string[]] @($Manifest[$key] | Where-Object { $null -ne $_ } | ForEach-Object { [string] $_ })
    }
    $features = [string[]] @($ordinal.Keys)
    [Array]::Sort($features, [StringComparer]::Ordinal)

    # Reject a self-loop first, then a dependency that is not a manifest key, so the
    # three error classes stay distinct and deterministic.
    foreach ($feature in $features) {
        if ([Array]::IndexOf($ordinal[$feature], $feature) -ge 0) {
            throw "EPIC_WAVE_SELF_LOOP: Feature '$feature' depends on itself."
        }
    }
    foreach ($feature in $features) {
        foreach ($dependency in $ordinal[$feature]) {
            if (-not $ordinal.ContainsKey($dependency)) {
                throw "EPIC_WAVE_UNRESOLVED_REFERENCE: Feature '$feature' depends on '$dependency', which is not a feature in the manifest."
            }
        }
    }

    $memo = [System.Collections.Generic.Dictionary[string, int]]::new([StringComparer]::Ordinal)
    $inProgress = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $result = [System.Collections.Specialized.OrderedDictionary]::new([StringComparer]::Ordinal)
    foreach ($feature in $features) {
        $result[$feature] = Resolve-EpicWaveFeature -Feature $feature -Manifest $ordinal -Memo $memo -InProgress $inProgress
    }
    return $result
}

<#
.SYNOPSIS
    Converts a parsed JSON manifest into a feature-to-dependencies dictionary.

.PARAMETER Parsed
    The dictionary produced by ConvertFrom-Json -AsHashtable. Keys are parsed
    case-sensitively, so manifest keys that differ only by case stay distinct.

.OUTPUTS
    An ordinal dictionary of feature to dependency list, or $null when the input is
    not a JSON object whose values are all arrays of strings.
#>
function ConvertTo-EpicWaveManifest {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[string, string[]]])]
    param(
        [Parameter(Mandatory = $true)][AllowNull()] $Parsed
    )

    if ($Parsed -isnot [System.Collections.IDictionary]) { return $null }
    $manifest = [System.Collections.Generic.Dictionary[string, string[]]]::new([StringComparer]::Ordinal)
    foreach ($name in $Parsed.Keys) {
        $value = $Parsed[$name]
        if ($value -isnot [System.Array]) { return $null }
        foreach ($item in $value) {
            if ($item -isnot [string]) { return $null }
        }
        $manifest[[string] $name] = [string[]] $value
    }
    return $manifest
}

<#
.SYNOPSIS
    Runs the wave computation for a manifest file and returns exit code, stdout, and stderr.

.PARAMETER ManifestPath
    Path to a JSON file holding an object of feature name to an array of dependency names.

.PARAMETER ReadManifestText
    Injectable reader that receives the path and returns the file text.

.OUTPUTS
    An object with ExitCode (0 success, 1 manifest error, 2 usage error), Stdout (the
    compressed JSON wave map), and Stderr (the error message).
#>
function Invoke-EpicWaveCommand {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $ManifestPath,
        [scriptblock] $ReadManifestText = { param([string] $Path) Get-Content -Raw -LiteralPath $Path }
    )

    if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
        return [pscustomobject] @{ ExitCode = 2; Stdout = ''; Stderr = 'EPIC_WAVE_USAGE: -ManifestPath is required.' }
    }

    try {
        $text = [string] (& $ReadManifestText $ManifestPath)
    } catch {
        return [pscustomobject] @{ ExitCode = 2; Stdout = ''; Stderr = "EPIC_WAVE_USAGE: Manifest could not be read: $($_.Exception.Message)" }
    }

    try {
        # -AsHashtable yields a case-sensitive map, so keys that differ only by case
        # stay distinct, matching the Python reference.
        $parsed = $text | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    } catch {
        return [pscustomobject] @{ ExitCode = 2; Stdout = ''; Stderr = "EPIC_WAVE_USAGE: Manifest is not valid JSON: $($_.Exception.Message)" }
    }

    $manifest = ConvertTo-EpicWaveManifest -Parsed $parsed
    if ($null -eq $manifest) {
        return [pscustomobject] @{ ExitCode = 2; Stdout = ''; Stderr = 'EPIC_WAVE_USAGE: Manifest must be a JSON object of feature names to arrays of dependency names.' }
    }

    try {
        $waves = Get-EpicWaveNumber -Manifest $manifest
    } catch {
        $message = $_.Exception.Message
        if ($message -like 'EPIC_WAVE_*') {
            return [pscustomobject] @{ ExitCode = 1; Stdout = ''; Stderr = $message }
        }
        throw
    }
    return [pscustomobject] @{ ExitCode = 0; Stdout = ($waves | ConvertTo-Json -Compress); Stderr = '' }
}

Export-ModuleMember -Function Get-EpicWaveNumber, Invoke-EpicWaveCommand
