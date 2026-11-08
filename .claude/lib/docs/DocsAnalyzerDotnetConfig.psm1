<#
.SYNOPSIS
    dotnet-config scanner: configuration keys of appsettings*.json files, emitted as config-key
    elements with key paths and value shapes only, never values.

.DESCRIPTION
    Invoke-DocsAnalyzerDotnetConfig selects inputs whose basename matches
    appsettings(.<name>)?.json. Each file passes a validity gate
    (System.Text.Json.JsonDocument.Parse with comments skipped, trailing commas allowed and the
    depth bound) and is then walked by a lexical JSONC key walker that supplies the line of
    every object member, because JsonDocument carries no line numbers. One config-key element
    is emitted per member path with properties value_type (object, array, string, number,
    boolean, null), configuration_path (colon form) and environment (the middle basename
    segment when present); keys of objects inside arrays are unioned under a [] segment; the
    declaration quotes any segment outside ^[A-Za-z0-9_-]+$. No value is read into output.
    Elements are built only through New-DocsSurfaceElement -AnalysisMethod scanner -SourceText
    over the raw captured text with the key's line as the range (1020 D5); the digest is never
    computed here. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of the scanner precision limit;
    dotnet-config has no precision-limit row because it parses the complete JSON document.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsConfigAnalyzerId = 'dotnet-config'
$script:DocsConfigRegexOptions = [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
$script:DocsConfigWhitespace = [regex]::new('\G\s+', $script:DocsConfigRegexOptions)
$script:DocsConfigLineComment = [regex]::new('\G//[^\r\n]*', $script:DocsConfigRegexOptions)
$script:DocsConfigBlockComment = [regex]::new('\G/\*[\s\S]*?\*/', $script:DocsConfigRegexOptions)
$script:DocsConfigString = [regex]::new('\G"((?:[^"\\]|\\[\s\S])*)"', $script:DocsConfigRegexOptions)
$script:DocsConfigNumber = [regex]::new('\G-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?', $script:DocsConfigRegexOptions)
$script:DocsConfigLiteral = [regex]::new('\G(?:true|false|null)\b', $script:DocsConfigRegexOptions)
$script:DocsConfigPunct = [regex]::new('\G[{}\[\]:,]', $script:DocsConfigRegexOptions)
$script:DocsConfigNewline = [regex]::new('\r\n|\r|\n', $script:DocsConfigRegexOptions)

function Test-DocsConfigDocument {
    <#
    .SYNOPSIS
        Returns @{ Ok; Line } for the JsonDocument validity gate: Ok is $false with the failing line for invalid JSON, a non-object root or a depth above MaxDepth (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $MaxDepth
    )

    $options = [System.Text.Json.JsonDocumentOptions]::new()
    $options.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
    $options.AllowTrailingCommas = $true
    $options.MaxDepth = $MaxDepth
    $document = $null
    try {
        $document = [System.Text.Json.JsonDocument]::Parse($Text, $options)
        if ($document.RootElement.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return @{ Ok = $false; Line = 1 } }
        return @{ Ok = $true; Line = 0 }
    } catch [System.Text.Json.JsonException] {
        $line = 1
        if ($null -ne $_.Exception.LineNumber) { $line = [int] $_.Exception.LineNumber + 1 }
        return @{ Ok = $false; Line = $line }
    } finally {
        if ($null -ne $document) { $document.Dispose() }
    }
}

function ConvertTo-DocsConfigSegment {
    <#
    .SYNOPSIS
        Returns the declaration spelling of one key segment: bare when it matches ^[A-Za-z0-9_-]+$ or is [], else double-quoted with " and \ escaped (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Segment)

    if ($Segment -ceq '[]' -or $Segment -cmatch '^[A-Za-z0-9_-]+$(?![\s\S])') { return $Segment }
    return '"' + $Segment.Replace('\', '\\').Replace('"', '\"') + '"'
}

function ConvertFrom-DocsConfigKeyText {
    <#
    .SYNOPSIS
        Decodes the body of a JSON string token through System.Text.Json (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Body)

    $document = [System.Text.Json.JsonDocument]::Parse('"' + $Body + '"')
    try { return $document.RootElement.GetString() } finally { $document.Dispose() }
}

function Get-DocsConfigKeyRecord {
    <#
    .SYNOPSIS
        Walks the JSONC text lexically and returns @{ Key; Duplicate; Count } with one record per distinct member path and the duplicate key sites (private helper).
    .DESCRIPTION
        A record is @{ Segment; ValueType; Line }. A key repeated inside one object is recorded
        in Duplicate (the first site is kept); the same path reached through another array
        element is unioned silently. Count is the number of member keys read.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Key paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $keys = [System.Collections.Generic.List[object]]::new()
    $duplicates = [System.Collections.Generic.List[object]]::new()
    $seen = [hashtable]::new([System.StringComparer]::Ordinal)
    $stack = [System.Collections.Generic.List[object]]::new()
    $position = 0
    $line = 1
    $count = 0
    while ($position -lt $Text.Length) {
        $top = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
        $match = $script:DocsConfigWhitespace.Match($Text, $position)
        if (-not $match.Success) { $match = $script:DocsConfigLineComment.Match($Text, $position) }
        if (-not $match.Success) { $match = $script:DocsConfigBlockComment.Match($Text, $position) }
        if ($match.Success) { $line += $script:DocsConfigNewline.Matches($match.Value).Count; $position += $match.Length; continue }
        $valueType = $null
        $match = $script:DocsConfigString.Match($Text, $position)
        if ($match.Success) {
            if ($null -ne $top -and [string] $top['Kind'] -ceq 'object' -and $top['ExpectKey']) {
                $top['PendingKey'] = ConvertFrom-DocsConfigKeyText -Body $match.Groups[1].Value
                $top['PendingLine'] = $line
                $top['ExpectKey'] = $false
                $line += $script:DocsConfigNewline.Matches($match.Value).Count
                $position += $match.Length
                continue
            }
            $valueType = 'string'
        }
        if (-not $match.Success) { $match = $script:DocsConfigNumber.Match($Text, $position); if ($match.Success) { $valueType = 'number' } }
        if (-not $match.Success) { $match = $script:DocsConfigLiteral.Match($Text, $position); if ($match.Success) { $valueType = if ($match.Value -ceq 'null') { 'null' } else { 'boolean' } } }
        if (-not $match.Success) { $match = $script:DocsConfigPunct.Match($Text, $position) }
        if (-not $match.Success) { break }
        $token = $match.Value
        if ($null -eq $valueType) {
            if ($token -ceq ':') { $position += $match.Length; continue }
            if ($token -ceq ',') { if ($null -ne $top -and [string] $top['Kind'] -ceq 'object') { $top['ExpectKey'] = $true }; $position += $match.Length; continue }
            if ($token -ceq '}' -or $token -ceq ']') { if ($stack.Count -gt 0) { $stack.RemoveAt($stack.Count - 1) }; $position += $match.Length; continue }
            $valueType = if ($token -ceq '{') { 'object' } else { 'array' }
        }
        [string[]] $childPath = @()
        if ($null -eq $top) { $childPath = @() }
        elseif ([string] $top['Kind'] -ceq 'array') { $childPath = [string[]] (@($top['Path']) + @('[]')) }
        elseif ($null -ne $top['PendingKey']) {
            $key = [string] $top['PendingKey']
            $keyLine = [int] $top['PendingLine']
            $top['PendingKey'] = $null
            $count++
            $childPath = [string[]] (@($top['Path']) + @($key))
            $pathText = $childPath -join "`n"
            if ($top['Keys'].Contains($key)) { $duplicates.Add(@{ Line = $keyLine }) }
            else {
                [void]$top['Keys'].Add($key)
                if (-not $seen.ContainsKey($pathText)) { $seen[$pathText] = $true; $keys.Add(@{ Segment = $childPath; ValueType = $valueType; Line = $keyLine }) }
            }
        }
        if ($token -ceq '{') { $stack.Add(@{ Kind = 'object'; Path = $childPath; Keys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal); PendingKey = $null; PendingLine = 0; ExpectKey = $true }) }
        elseif ($token -ceq '[') { $stack.Add(@{ Kind = 'array'; Path = $childPath }) }
        $line += $script:DocsConfigNewline.Matches($token).Count
        $position += $match.Length
    }
    return @{ Key = [object[]] $keys.ToArray(); Duplicate = [object[]] $duplicates.ToArray(); Count = $count }
}

function Invoke-DocsAnalyzerDotnetConfig {
    <#
    .SYNOPSIS
        Scans the captured appsettings*.json inputs for configuration keys and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection is accepted for the 1020 analyzer contract and not read. MaxKey (default
        10000) and MaxDepth (default 64) are the configuration-key and JSON-depth bounds,
        overridable only in tests. Every element is built by New-DocsSurfaceElement with
        -AnalysisMethod scanner and the raw captured text; diagnostics are aggregated per
        (code, path) and emitted through ConvertTo-DocsScannerDiagnostic under dotnet-config.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Selection', Justification = 'The 1020 analyzer contract passes -Selection to every analyzer; this scanner reads no selection key.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection,
        [ValidateRange(1, 2147483647)] [int] $MaxKey = 10000,
        [ValidateRange(1, 2147483647)] [int] $MaxDepth = 64
    )

    $set = New-DocsScannerDiagnosticSet
    $elements = [System.Collections.Generic.List[object]]::new()
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.json') -BasenamePattern '^appsettings(\.[^/]+)?\.json$'
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        $text = $captured['text']
        if ($null -eq $text) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $gate = Test-DocsConfigDocument -Text $text -MaxDepth $MaxDepth
        if (-not $gate['Ok']) { Add-DocsScannerDiagnostic -Set $set -Code 'JSON_INVALID' -Path $path -Line ([int] $gate['Line']) -Blocking $true; continue }
        $walk = Get-DocsConfigKeyRecord -Text $text
        if ([int] $walk['Count'] -gt $MaxKey) { Add-DocsScannerDiagnostic -Set $set -Code 'INPUT_KEY_LIMIT' -Path $path -Line 0 -Blocking $true; continue }
        foreach ($duplicate in $walk['Duplicate']) { Add-DocsScannerDiagnostic -Set $set -Code 'DUPLICATE_DECLARATION' -Path $path -Line ([int] $duplicate['Line']) }
        $basename = $path.Substring($path.LastIndexOf('/') + 1)
        $environment = [regex]::Match($basename, '^appsettings\.([^/]+)\.json$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        foreach ($record in $walk['Key']) {
            [string[]] $segments = $record['Segment']
            $declaration = ($segments | ForEach-Object { ConvertTo-DocsConfigSegment -Segment $_ }) -join '.'
            $property = [ordered]@{ value_type = [string] $record['ValueType']; configuration_path = ($segments -join ':') }
            if ($environment.Success) { $property['environment'] = $environment.Groups[1].Value }
            try {
                $elements.Add((New-DocsSurfaceElement -Kind 'config-key' -Path $path -Declaration $declaration -Name $segments[$segments.Count - 1] -AnalyzerId $script:DocsConfigAnalyzerId -AnalysisMethod 'scanner' -SourceText $text -LineRange @([int] $record['Line'], [int] $record['Line']) -Property $property))
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $record['Line']) }
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsConfigAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerDotnetConfig
