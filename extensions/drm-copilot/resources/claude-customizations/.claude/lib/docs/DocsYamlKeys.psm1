<#
.SYNOPSIS
    YAML key scanner for the issue #1022 config-files analyzer: mapping key paths with spans and
    value types for the classified YAML subset, never values.

.DESCRIPTION
    Get-DocsYamlKey scans block mappings, block sequences (segment [] with mapping items inside
    sequences), plain, single-quoted and escape-free double-quoted keys, comments, block scalars
    with chomping and indentation indicators, one optional '---' before the first content line
    and an optional final '...', single-line scalar values, plain multi-line continuation lines
    that contain no ': ', and single-line flow collections as values. Each key record carries
    Segment, Span (key line through the last non-blank, non-comment line of its value block) and
    ValueType (object, array, string, integer, number, boolean, null). Diagnostics: YAML_INVALID
    (blocking: tab indentation, a dedent to an unknown column, an unterminated quoted scalar, a
    continuation line containing ': '), YAML_MULTI_DOCUMENT, YAML_ANCHOR_ALIAS, YAML_UNSUPPORTED
    and YAML_ROOT_NOT_MAPPING (input level, no keys), YAML_FLOW_COLLECTION_NOT_EXPANDED and
    YAML_KEY_ESCAPE_UNSUPPORTED (site level).

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1022. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop

function New-DocsYamlDiagnostic {
    <#
    .SYNOPSIS
        Builds one scanner diagnostic record (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory record factory.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Code, [Parameter(Mandatory = $true)] [int] $Line, [bool] $Blocking = $false)

    return @{ Code = $Code; Severity = $(if ($Blocking) { 'error' } else { 'warning' }); Blocking = $Blocking; Line = $Line }
}

function Read-DocsYamlKeyText {
    <#
    .SYNOPSIS
        Reads a mapping key at the start of Content and returns @{ Key; Rest; Escape; Quoted } or $null (private helper).
    .DESCRIPTION
        Rest is the text after the ': ' or trailing ':' separator (trimmed, comment removed).
        Escape is $true for a double-quoted key containing a backslash. Returns $null when
        Content is not a key line.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Content)

    $first = $Content[0]
    if ($first -eq '"' -or $first -eq '''') {
        $close = 1
        $escape = $false
        while ($close -lt $Content.Length -and $Content[$close] -ne $first) {
            if ($first -eq '"' -and $Content[$close] -eq '\') { $escape = $true; $close++ }
            $close++
        }
        if ($close -ge $Content.Length) { return $null }
        $after = $Content.Substring($close + 1)
        if (-not ($after.StartsWith(': ') -or $after -ceq ':')) { return $null }
        return @{ Key = $Content.Substring(1, $close - 1); Rest = (Read-DocsYamlInlineValue -Text $after.Substring(1)); Escape = $escape; Quoted = $true }
    }
    $match = [regex]::Match($Content, '^([^#:\s][^:#]*?)\s*:(?:\s+|$)')
    if (-not $match.Success) { return $null }
    return @{ Key = $match.Groups[1].Value; Rest = (Read-DocsYamlInlineValue -Text $Content.Substring($match.Length)); Escape = $false; Quoted = $false }
}

function Read-DocsYamlInlineValue {
    <#
    .SYNOPSIS
        Trims an inline value and removes a trailing comment outside quotes (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $value = $Text.Trim()
    if ($value.Length -eq 0) { return '' }
    $quote = [char]0
    for ($index = 0; $index -lt $value.Length; $index++) {
        $character = $value[$index]
        if ($quote -ne [char]0) {
            if ($quote -eq '"' -and $character -eq '\') { $index++; continue }
            if ($character -eq $quote) { $quote = [char]0 }
        } elseif (($character -eq '"' -or $character -eq '''') -and $index -eq 0) { $quote = $character }
        elseif ($character -eq '#' -and ($index -eq 0 -or [char]::IsWhiteSpace($value[$index - 1]))) { return $value.Substring(0, $index).TrimEnd() }
    }
    return $value
}

function Get-DocsYamlScalarType {
    <#
    .SYNOPSIS
        Classifies an inline scalar value as string, integer, number, boolean or null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    if ($Value.Length -eq 0 -or $Value -ceq '~' -or $Value -ceq 'null' -or $Value -ceq 'Null' -or $Value -ceq 'NULL') { return 'null' }
    if ($Value -cmatch '^(?:true|false|True|False|TRUE|FALSE)$') { return 'boolean' }
    if ($Value -cmatch '^[-+]?(?:0|[1-9][0-9]*|0o[0-7]+|0x[0-9a-fA-F]+)$') { return 'integer' }
    if ($Value -cmatch '^[-+]?(?:\.[0-9]+|[0-9]+(?:\.[0-9]*)?)(?:[eE][-+]?[0-9]+)?$' -or $Value -cmatch '^[-+]?\.(?:inf|Inf|INF)$' -or $Value -cmatch '^\.(?:nan|NaN|NAN)$') { return 'number' }
    return 'string'
}

function Test-DocsYamlUnterminatedQuote {
    <#
    .SYNOPSIS
        Returns $true when a scalar starting with a quote does not close on its line (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    if ($Value.Length -eq 0) { return $false }
    $quote = $Value[0]
    if ($quote -ne '"' -and $quote -ne '''') { return $false }
    $index = 1
    while ($index -lt $Value.Length) {
        if ($quote -eq '"' -and $Value[$index] -eq '\') { $index += 2; continue }
        if ($Value[$index] -eq $quote) {
            if ($quote -eq '''' -and $index + 1 -lt $Value.Length -and $Value[$index + 1] -eq '''') { $index += 2; continue }
            return $false
        }
        $index++
    }
    return $true
}

function Get-DocsYamlKey {
    <#
    .SYNOPSIS
        Returns @{ Keys; Diagnostics } for YAML text: mapping key paths with spans and value types.
    .DESCRIPTION
        Each key is @{ Segment; Span; ValueType }. An input-level diagnostic empties Keys. Lines
        are indexed from 1 in the 1020 canonical text.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $lines = ConvertTo-DocsSourceLine -Text $Text
    $keys = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $stack = [System.Collections.Generic.List[object]]::new()
    $inputLevel = $null
    $contentSeen = $false
    $documentEnded = $false
    $lastContent = 0
    $index = 0
    while ($index -lt $lines.Count) {
        $line = $lines[$index]
        $number = $index + 1
        $index++
        if ($line.Trim().Length -eq 0 -or $line.TrimStart().StartsWith('#')) { continue }
        if ($line -cmatch '^%') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
        if ($line -ceq '---' -or $line.StartsWith('--- ')) {
            if ($contentSeen) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_MULTI_DOCUMENT' -Line $number; break }
            if ($line.Length -gt 4 -and $line.Substring(4).Trim().Length -gt 0 -and -not $line.Substring(4).TrimStart().StartsWith('#')) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
            $contentSeen = $true
            continue
        }
        if ($line -ceq '...') { $documentEnded = $true; continue }
        if ($documentEnded) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_MULTI_DOCUMENT' -Line $number; break }
        $contentSeen = $true
        $indentText = $line.Substring(0, $line.Length - $line.TrimStart().Length)
        if ($indentText.Contains("`t")) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break }
        $indent = $indentText.Length
        $content = $line.Substring($indent)
        while ($stack.Count -gt 0 -and $stack[$stack.Count - 1]['Indent'] -gt $indent) { $stack.RemoveAt($stack.Count - 1) }
        $parent = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
        $isItem = $content -ceq '-' -or $content.StartsWith('- ')
        if ($null -ne $parent -and $parent['Indent'] -eq $indent -and $parent['IsItem'] -and -not $isItem -and $parent['ItemMapping']) {
            # A sibling key of a mapping item at the item's content column: keep the item frame.
        } elseif ($null -ne $parent -and $parent['Indent'] -eq $indent -and -not ($parent['IsItem'] -and -not $isItem)) {
            $stack.RemoveAt($stack.Count - 1)
            $parent = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
        } elseif ($null -ne $parent -and $parent['Indent'] -lt $indent -and $null -ne $parent['ChildIndent'] -and $parent['ChildIndent'] -ne $indent) {
            $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break
        }
        if ($null -ne $parent -and $null -eq $parent['ChildIndent']) { $parent['ChildIndent'] = $indent }
        if ($null -ne $parent -and -not $parent['IsItem'] -and $null -ne $parent['Key'] -and $parent['Key']['ValueType'] -ceq 'null') {
            $parent['Key']['ValueType'] = $(if ($isItem) { 'array' } else { 'object' })
        }
        if ($content -cmatch '^(?:&\S|\*\S)' -or $content -cmatch '^<<\s*:' -or $content -cmatch '(?:^|\s)(?:&|\*)\S' -and $content -cnotmatch '^["'']') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_ANCHOR_ALIAS' -Line $number; break }
        if ($content -cmatch '^!' -or $content -cmatch ':\s+!' -or $content -cmatch '^\?\s' -or $content -cmatch '^-\s+!') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
        $path = @($stack | Where-Object { $_['Segment'].Count -gt 0 } | ForEach-Object { $_['Segment'] })
        if ($isItem) {
            if ($null -eq $parent) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_ROOT_NOT_MAPPING' -Line $number; break }
            $itemContent = $content.Substring(1).TrimStart()
            $frame = @{ Indent = $indent; IsItem = $true; ItemMapping = $false; Segment = @('[]'); ChildIndent = $null; Key = $null }
            $stack.Add($frame)
            if ($itemContent.Length -eq 0 -or $itemContent.StartsWith('#')) { $lastContent = $number; continue }
            $keyText = Read-DocsYamlKeyText -Content $itemContent
            if ($null -eq $keyText) {
                if ($itemContent -cmatch '^(?:&|\*)\S') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_ANCHOR_ALIAS' -Line $number; break }
                if (Test-DocsYamlUnterminatedQuote -Value $itemContent) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break }
                if ($itemContent -cmatch '^[\[{]' -and $itemContent -cnotmatch '[\]}]\s*(?:#.*)?$') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
                $lastContent = $number
                continue
            }
            $frame['ItemMapping'] = $true
            $itemIndent = $indent + ($content.Length - $itemContent.Length)
            $child = @{ Indent = $itemIndent; IsItem = $false; ItemMapping = $false; Segment = @(); ChildIndent = $null; Key = $null }
            $stack.Add($child)
            $path = @($path + @('[]'))
            $indent = $itemIndent
            $parent = $child
        } else {
            if ($null -ne $parent -and $null -ne $parent['Key'] -and $parent['Key']['ValueType'] -cin @('string', 'number', 'integer', 'boolean') -and $indent -gt $parent['Indent']) {
                # A line indented under a scalar value is a plain continuation line.
                if ($content.Contains(': ') -or $content.EndsWith(':')) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break }
                $parent['Key']['Span'][1] = $number
                $lastContent = $number
                continue
            }
            $keyText = Read-DocsYamlKeyText -Content $content
            if ($null -eq $keyText) {
                if (Test-DocsYamlUnterminatedQuote -Value $content) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break }
                if ($stack.Count -eq 0) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_ROOT_NOT_MAPPING' -Line $number; break }
                $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break
            }
        }
        $value = [string] $keyText['Rest']
        $record = @{ Segment = [string[]]@($path + @($keyText['Key'])); Span = [int[]]@($number, $number); ValueType = 'null' }
        if ($value -cmatch '^[|>]') {
            $record['ValueType'] = 'string'
            $blockIndent = $indent
            while ($index -lt $lines.Count) {
                $next = $lines[$index]
                $nextTrim = $next.TrimStart(' ')
                if ($nextTrim.Length -eq 0) { $index++; continue }
                if (($next.Length - $nextTrim.Length) -le $blockIndent) { break }
                $record['Span'][1] = $index + 1
                $index++
            }
        } elseif ($value.Length -gt 0) {
            if ($value -cmatch '^[\[{]') {
                if ($value -cnotmatch '[\]}]$') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
                $record['ValueType'] = $(if ($value.StartsWith('[')) { 'array' } else { 'object' })
                $diagnostics.Add((New-DocsYamlDiagnostic -Code 'YAML_FLOW_COLLECTION_NOT_EXPANDED' -Line $number))
            } elseif ($value -cmatch '^(?:&|\*)\S') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_ANCHOR_ALIAS' -Line $number; break }
            elseif ($value -cmatch '^!') { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_UNSUPPORTED' -Line $number; break }
            elseif (Test-DocsYamlUnterminatedQuote -Value $value) { $inputLevel = New-DocsYamlDiagnostic -Code 'YAML_INVALID' -Line $number -Blocking $true; break }
            elseif ($value -cmatch '^["'']') { $record['ValueType'] = 'string' }
            else { $record['ValueType'] = Get-DocsYamlScalarType -Value $value }
        }
        $frame = @{ Indent = $indent; IsItem = $false; ItemMapping = $false; Segment = @($keyText['Key']); ChildIndent = $null; Key = $record }
        $stack.Add($frame)
        if ($keyText['Escape']) { $diagnostics.Add((New-DocsYamlDiagnostic -Code 'YAML_KEY_ESCAPE_UNSUPPORTED' -Line $number)) }
        else { $keys.Add($record) }
        $lastContent = $number
    }
    if ($null -ne $inputLevel) { return @{ Keys = [object[]]@(); Diagnostics = [object[]]@($inputLevel) } }
    if ($null -ne $lastContent) {
        foreach ($record in $keys) {
            if ($record['ValueType'] -cin @('object', 'array')) {
                $end = $record['Span'][0]
                foreach ($other in $keys) { if ($other['Span'][0] -gt $record['Span'][0] -and $other['Segment'].Count -gt $record['Segment'].Count -and (($other['Segment'][0..($record['Segment'].Count - 1)] -join "`u{1}") -ceq ($record['Segment'] -join "`u{1}")) -and $other['Span'][1] -gt $end) { $end = $other['Span'][1] } }
                $record['Span'][1] = $end
            }
        }
    }
    return @{ Keys = $keys.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsYamlKey
