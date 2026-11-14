<#
.SYNOPSIS
    JSON parsing, UTF-8 decoding, deterministic serialization, canonical JSON and SHA-256
    helpers for the documentation library.

.DESCRIPTION
    Parses JSON text with System.Text.Json into ordinal (case-sensitive) hashtables, Int64 and
    Double numbers and unchanged strings, reporting malformed text, repeated object members and
    excess depth as findings instead of exceptions. Serializes values with ordinal key order,
    relaxed escaping, LF line endings and one trailing LF. Canonical JSON and SHA-256 delegate
    to DiscoveryEncoding.psm1, so docs digests agree byte for byte with the discovery runtime.
    Get-DocsTextSha256Hex hashes bytes after mapping CRLF and lone CR to LF (issue #1173), for
    estate artifact references and write conflict checks that must not depend on line endings.
    ConvertFrom-Json is never used for artifacts, because it converts timestamp-shaped strings
    to DateTime and loses the integer and boolean distinctions.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../discovery-validation/DiscoveryEncoding.psm1') -ErrorAction Stop

function New-DocsJsonFinding {
    <#
    .SYNOPSIS
        Builds one error finding in the docs common finding shape (private helper).
    .DESCRIPTION
        DocsFinding.psm1 imports this module, so the parser builds its findings directly with the
        same eight keys rather than importing DocsFinding.psm1.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    $path = if ([string]::IsNullOrEmpty($ArtifactPath)) { $null } else { $ArtifactPath }
    return [ordered]@{
        code          = $Code
        severity      = 'error'
        artifact_path = $path
        pointer       = $Pointer
        related_ids   = [string[]]@()
        related_paths = [string[]]@()
        message       = $Message
        next_action   = $NextAction
    }
}

function ConvertTo-DocsJsonPointerToken {
    <#
    .SYNOPSIS
        Escapes one JSON pointer reference token per RFC 6901 (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Token)

    return $Token.Replace('~', '~0').Replace('/', '~1')
}

function ConvertFrom-DocsJsonElement {
    <#
    .SYNOPSIS
        Converts one System.Text.Json element to a PowerShell value (private recursive helper).
    .DESCRIPTION
        Objects become ordinal hashtables, arrays object arrays, integral numbers Int64, other
        numbers Double, strings stay unchanged. A repeated member adds DOCS_JSON_DUPLICATE_KEY at
        the repeated member's pointer, and a container nested deeper than MaxDepth adds
        DOCS_JSON_TOO_DEEP; both are appended to the Findings list.
    #>
    # The @{} literal is case-insensitive while JSON object keys are case-sensitive, so an
    # ordinal-comparer hashtable is constructed explicitly.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'JSON object keys are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable], [System.Object[]], [string], [long], [double], [bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [int] $Depth,
        [Parameter(Mandatory = $true)] [int] $MaxDepth,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Findings,
        [AllowNull()] [string] $ArtifactPath
    )

    $kind = $Element.ValueKind
    $isContainer = ($kind -eq [System.Text.Json.JsonValueKind]::Object) -or ($kind -eq [System.Text.Json.JsonValueKind]::Array)
    if ($isContainer -and $Depth -ge $MaxDepth) {
        $Findings.Add((New-DocsJsonFinding -Code 'DOCS_JSON_TOO_DEEP' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "JSON nesting at '$Pointer' exceeds the maximum depth of $MaxDepth." -NextAction 'Reduce the nesting depth of the document.'))
        return $null
    }

    switch ($kind) {
        ([System.Text.Json.JsonValueKind]::Object) {
            $table = [hashtable]::new([System.StringComparer]::Ordinal)
            foreach ($property in $Element.EnumerateObject()) {
                $childPointer = $Pointer + '/' + (ConvertTo-DocsJsonPointerToken -Token $property.Name)
                if ($table.ContainsKey($property.Name)) {
                    $Findings.Add((New-DocsJsonFinding -Code 'DOCS_JSON_DUPLICATE_KEY' -Pointer $childPointer -ArtifactPath $ArtifactPath -Message "Member '$($property.Name)' is repeated in the same JSON object." -NextAction 'Remove the repeated member so each name appears once.'))
                    continue
                }
                $table[$property.Name] = ConvertFrom-DocsJsonElement -Element $property.Value -Pointer $childPointer -Depth ($Depth + 1) -MaxDepth $MaxDepth -Findings $Findings -ArtifactPath $ArtifactPath
            }
            return $table
        }
        ([System.Text.Json.JsonValueKind]::Array) {
            $list = [System.Collections.Generic.List[object]]::new()
            $index = 0
            foreach ($entry in $Element.EnumerateArray()) {
                $list.Add((ConvertFrom-DocsJsonElement -Element $entry -Pointer ($Pointer + '/' + $index) -Depth ($Depth + 1) -MaxDepth $MaxDepth -Findings $Findings -ArtifactPath $ArtifactPath))
                $index++
            }
            return , $list.ToArray()
        }
        ([System.Text.Json.JsonValueKind]::String) { return $Element.GetString() }
        ([System.Text.Json.JsonValueKind]::Number) {
            $integral = [long]0
            if ($Element.TryGetInt64([ref] $integral)) { return $integral }
            return $Element.GetDouble()
        }
        ([System.Text.Json.JsonValueKind]::True) { return $true }
        ([System.Text.Json.JsonValueKind]::False) { return $false }
        default { return $null }
    }
}

function ConvertFrom-DocsJsonText {
    <#
    .SYNOPSIS
        Parses JSON text into ordinal hashtables and reports parse findings.
    .DESCRIPTION
        Returns @{ Value; Findings }. Value is $null whenever a finding exists. Findings are
        DOCS_JSON_INVALID (malformed or empty text), DOCS_JSON_DUPLICATE_KEY (at the repeated
        member's pointer) and DOCS_JSON_TOO_DEEP. One leading U+FEFF is ignored.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text,
        [AllowNull()] [string] $ArtifactPath,
        [ValidateRange(1, 1024)] [int] $MaxDepth = 64
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $source = if ($null -eq $Text) { '' } else { $Text }
    if ($source.StartsWith([char]0xFEFF)) { $source = $source.Substring(1) }
    if ([string]::IsNullOrWhiteSpace($source)) {
        $findings.Add((New-DocsJsonFinding -Code 'DOCS_JSON_INVALID' -Pointer '' -ArtifactPath $ArtifactPath -Message 'The JSON text is empty.' -NextAction 'Provide a JSON document.'))
        return @{ Value = $null; Findings = $findings.ToArray() }
    }

    # The reader bound sits above MaxDepth so that excess depth is reported by the converter
    # with a pointer; the reader bound itself only protects against pathological input.
    $options = [System.Text.Json.JsonDocumentOptions]::new()
    $options.MaxDepth = $MaxDepth + 64
    $document = $null
    try {
        $document = [System.Text.Json.JsonDocument]::Parse($source, $options)
    } catch [System.Text.Json.JsonException] {
        # The reader reports its own depth bound with this phrase; an unterminated document also
        # mentions depth ("Expected depth to be zero"), so the broader word is not matched.
        $code = if ($_.Exception.Message -match 'maximum configured depth') { 'DOCS_JSON_TOO_DEEP' } else { 'DOCS_JSON_INVALID' }
        $findings.Add((New-DocsJsonFinding -Code $code -Pointer '' -ArtifactPath $ArtifactPath -Message "The JSON text cannot be parsed: $($_.Exception.Message)" -NextAction 'Correct the JSON syntax.'))
        return @{ Value = $null; Findings = $findings.ToArray() }
    }

    try {
        $value = ConvertFrom-DocsJsonElement -Element $document.RootElement -Pointer '' -Depth 0 -MaxDepth $MaxDepth -Findings $findings -ArtifactPath $ArtifactPath
    } finally {
        $document.Dispose()
    }
    if ($findings.Count -gt 0) { $value = $null }
    return @{ Value = $value; Findings = $findings.ToArray() }
}

function Write-DocsJsonValue {
    <#
    .SYNOPSIS
        Writes one PowerShell value to a Utf8JsonWriter with ordinal key order (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.Utf8JsonWriter] $Writer,
        [AllowNull()] [object] $Value
    )

    if ($null -eq $Value) { $Writer.WriteNullValue(); return }
    if ($Value -is [bool]) { $Writer.WriteBooleanValue($Value); return }
    if ($Value -is [string]) { $Writer.WriteStringValue([string] $Value); return }
    if ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64] -or $Value -is [uint16] -or $Value -is [uint32]) {
        $Writer.WriteNumberValue([long] $Value)
        return
    }
    if ($Value -is [double] -or $Value -is [single] -or $Value -is [decimal]) { $Writer.WriteNumberValue([double] $Value); return }
    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        $table = [ordered]@{}
        foreach ($property in $Value.PSObject.Properties) { $table[$property.Name] = $property.Value }
        $Value = $table
    }
    if ($Value -is [System.Collections.IDictionary]) {
        [string[]] $keys = @($Value.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        $Writer.WriteStartObject()
        foreach ($key in $keys) {
            $Writer.WritePropertyName($key)
            Write-DocsJsonValue -Writer $Writer -Value $Value[$key]
        }
        $Writer.WriteEndObject()
        return
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $Writer.WriteStartArray()
        foreach ($item in $Value) { Write-DocsJsonValue -Writer $Writer -Value $item }
        $Writer.WriteEndArray()
        return
    }
    throw "DOCS_JSON_UNSUPPORTED_VALUE: a value of type $($Value.GetType().FullName) cannot be written as JSON."
}

function ConvertTo-DocsJsonText {
    <#
    .SYNOPSIS
        Serializes a value as JSON text with ordinal key order and one trailing LF.
    .DESCRIPTION
        Keys are sorted by ordinal comparison at every depth; non-ASCII text stays literal through
        relaxed escaping; CRLF from the writer is normalized to LF. Used for files a person reads.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Value,
        [switch] $Indented
    )

    $options = [System.Text.Json.JsonWriterOptions]::new()
    $options.Indented = [bool] $Indented
    $options.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
    $stream = [System.IO.MemoryStream]::new()
    $writer = [System.Text.Json.Utf8JsonWriter]::new($stream, $options)
    try {
        Write-DocsJsonValue -Writer $writer -Value $Value
        $writer.Flush()
        $text = [System.Text.Encoding]::UTF8.GetString($stream.ToArray())
    } finally {
        $writer.Dispose()
        $stream.Dispose()
    }
    return $text.Replace("`r`n", "`n").TrimEnd("`n") + "`n"
}

function ConvertTo-DocsCanonicalJson {
    <#
    .SYNOPSIS
        Returns canonical JSON (compact, sorted keys, trailing LF) through DiscoveryEncoding.psm1.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [object] $Value)

    return ConvertTo-DiscoveryCanonicalJson -Value $Value
}

function Get-DocsSha256Hex {
    <#
    .SYNOPSIS
        Returns the lowercase hex SHA-256 of the UTF-8 bytes of Text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    return Get-DiscoverySha256Hex -Text $Text
}

function Get-DocsBytesSha256Hex {
    <#
    .SYNOPSIS
        Returns the lowercase hex SHA-256 of raw bytes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [byte[]] $Bytes)

    return Get-DiscoveryBytesSha256Hex -Bytes $Bytes
}

function Get-DocsTextSha256Hex {
    <#
    .SYNOPSIS
        Returns the lowercase hex SHA-256 of Bytes after mapping CRLF and lone CR to LF (issue #1173).
    .DESCRIPTION
        The mapping is done at byte level: each CR (0x0D) followed by LF (0x0A) is dropped, and
        each other CR becomes LF. A leading BOM and every other byte are kept, so for LF-only
        content the value equals Get-DocsBytesSha256Hex. Estate artifact references and write
        conflict checks use this hash, so a CRLF checkout of LF-written text keeps its hash.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [byte[]] $Bytes)

    $carriageReturn = [System.Array]::IndexOf($Bytes, [byte] 0x0D)
    if ($carriageReturn -lt 0) { return Get-DiscoveryBytesSha256Hex -Bytes $Bytes }
    # Copy the runs between CR bytes in bulk, so the loop runs once per CR rather than once per byte.
    $normalized = [byte[]]::new($Bytes.Length)
    $length = 0
    $start = 0
    while ($carriageReturn -ge 0) {
        [System.Array]::Copy($Bytes, $start, $normalized, $length, $carriageReturn - $start)
        $length += $carriageReturn - $start
        $nextIsLineFeed = ($carriageReturn + 1 -lt $Bytes.Length) -and ($Bytes[$carriageReturn + 1] -eq 0x0A)
        if (-not $nextIsLineFeed) { $normalized[$length] = 0x0A; $length++ }
        $start = $carriageReturn + 1
        $carriageReturn = if ($start -lt $Bytes.Length) { [System.Array]::IndexOf($Bytes, [byte] 0x0D, $start) } else { -1 }
    }
    [System.Array]::Copy($Bytes, $start, $normalized, $length, $Bytes.Length - $start)
    $length += $Bytes.Length - $start
    $trimmed = [byte[]]::new($length)
    [System.Array]::Copy($normalized, $trimmed, $length)
    return Get-DiscoveryBytesSha256Hex -Bytes $trimmed
}

function ConvertFrom-DocsUtf8Bytes {
    <#
    .SYNOPSIS
        Decodes UTF-8 bytes to text with one leading BOM removed.
    .DESCRIPTION
        Zero bytes, and a BOM alone, return the empty string, never $null. Decoding is strict, so
        an invalid UTF-8 sequence throws instead of being replaced with U+FFFD.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1020 spec contract that the command context ReadText depends on.')]
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [byte[]] $Bytes)

    $offset = 0
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { $offset = 3 }
    if ($Bytes.Length -eq $offset) { return [string]::Empty }
    return [System.Text.UTF8Encoding]::new($false, $true).GetString($Bytes, $offset, $Bytes.Length - $offset)
}

Export-ModuleMember -Function `
    ConvertFrom-DocsJsonText, `
    ConvertTo-DocsJsonText, `
    ConvertTo-DocsCanonicalJson, `
    Get-DocsSha256Hex, `
    Get-DocsBytesSha256Hex, `
    Get-DocsTextSha256Hex, `
    ConvertFrom-DocsUtf8Bytes
