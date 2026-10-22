<#
.SYNOPSIS
    Hashing and canonical JSON encoding shared by the native discovery hooks.

.DESCRIPTION
    Renders JSON values with sorted keys, no whitespace, a trailing LF and non-ASCII
    kept literal, exactly as `canonical_json` in the Python runtime and
    `canonicalJson` in the TypeScript gateway do, and returns lowercase hex SHA-256
    digests of text and bytes. Every discovery digest (tool/input authorization,
    input manifest, receipt) is computed over this encoding, so a hook that
    recomputes a digest with these functions agrees with the runtime byte for byte.

    Numbers must be safe integers because a fractional value cannot be normalized
    identically across runtimes; anything outside JSON is refused rather than
    guessed. The module performs no I/O.

.NOTES
    Issue #980. Compatible with PowerShell 7+. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/
    and published to the Codex bundle under .codex/lib/discovery-validation/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DiscoverySha256Hex {
    <#
    .SYNOPSIS
        Returns the lowercase hex SHA-256 of the UTF-8 encoding of Text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    return Get-DiscoveryBytesSha256Hex -Bytes ([System.Text.Encoding]::UTF8.GetBytes($Text))
}

function Get-DiscoveryBytesSha256Hex {
    <#
    .SYNOPSIS
        Returns the lowercase hex SHA-256 of raw bytes (an empty array is allowed).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Bytes)

    return [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($Bytes)).ToLowerInvariant()
}

function ConvertTo-DiscoveryJsonString {
    <#
    .SYNOPSIS
        Quotes one string the way JSON.stringify and json.dumps(ensure_ascii=False) do.
    .DESCRIPTION
        Only the quote, the backslash and C0 controls are escaped; every other code
        point stays literal so digests agree across the three runtimes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

    $builder = [System.Text.StringBuilder]::new('"')
    # Escape per code point (culture-aware string comparison treats control
    # characters as ignorable, so the switch is on the integer value): the short
    # forms first, then \u00XX for other controls.
    foreach ($character in $Value.ToCharArray()) {
        $code = [int]$character
        switch ($code) {
            34 { [void]$builder.Append('\"') }
            92 { [void]$builder.Append('\\') }
            8 { [void]$builder.Append('\b') }
            12 { [void]$builder.Append('\f') }
            10 { [void]$builder.Append('\n') }
            13 { [void]$builder.Append('\r') }
            9 { [void]$builder.Append('\t') }
            default {
                if ($code -lt 0x20) {
                    [void]$builder.Append('\u' + $code.ToString('x4'))
                } else {
                    [void]$builder.Append($character)
                }
            }
        }
    }
    return $builder.Append('"').ToString()
}

function ConvertTo-DiscoveryCanonicalJson {
    <#
    .SYNOPSIS
        Renders a JSON value with sorted keys, no whitespace and a trailing LF.
    .DESCRIPTION
        Mirrors `canonical_json` in the Python runtime and `canonicalJson` in the
        TypeScript gateway. Objects (hashtables, ordered dictionaries and
        PSCustomObjects) sort keys by ordinal code point; arrays keep order; numbers
        must be integers because a fractional value cannot be normalized identically.
    .OUTPUTS
        [string] The canonical text, ending with a single LF.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    return (ConvertTo-DiscoveryCanonicalFragment -Value $Value) + "`n"
}

function ConvertTo-DiscoveryCanonicalFragment {
    <#
    .SYNOPSIS
        Renders one JSON value without the trailing LF; recursive helper.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    # Routing by JSON type; anything outside JSON is refused rather than guessed.
    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) { return $(if ($Value) { 'true' } else { 'false' }) }
    if ($Value -is [string]) { return ConvertTo-DiscoveryJsonString -Value $Value }
    if ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64] -or $Value -is [uint16] -or $Value -is [uint32]) {
        return ([int64]$Value).ToString([System.Globalization.CultureInfo]::InvariantCulture)
    }
    if ($Value -is [double] -or $Value -is [decimal] -or $Value -is [single]) {
        if ([math]::Floor([double]$Value) -ne [double]$Value -or [math]::Abs([double]$Value) -gt 9007199254740991) {
            throw 'AUTHORIZATION_INPUT_INVALID: canonical JSON accepts only safe integers as numbers.'
        }
        return ([int64][double]$Value).ToString([System.Globalization.CultureInfo]::InvariantCulture)
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $members = @()
        # Ordinal key order is what both reference runtimes emit.
        [string[]]$sortedKeys = @($Value.Keys | ForEach-Object { [string]$_ })
        [Array]::Sort($sortedKeys, [System.StringComparer]::Ordinal)
        foreach ($key in $sortedKeys) {
            $members += (ConvertTo-DiscoveryJsonString -Value ([string]$key)) + ':' + (ConvertTo-DiscoveryCanonicalFragment -Value $Value[$key])
        }
        return '{' + ($members -join ',') + '}'
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @()
        foreach ($item in $Value) { $items += ConvertTo-DiscoveryCanonicalFragment -Value $item }
        return '[' + ($items -join ',') + ']'
    }
    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        $table = [ordered]@{}
        foreach ($property in $Value.PSObject.Properties) { $table[$property.Name] = $property.Value }
        return ConvertTo-DiscoveryCanonicalFragment -Value $table
    }
    throw "AUTHORIZATION_INPUT_INVALID: canonical JSON cannot render a value of type $($Value.GetType().FullName)."
}

Export-ModuleMember -Function `
    Get-DiscoverySha256Hex, `
    Get-DiscoveryBytesSha256Hex, `
    ConvertTo-DiscoveryCanonicalJson
