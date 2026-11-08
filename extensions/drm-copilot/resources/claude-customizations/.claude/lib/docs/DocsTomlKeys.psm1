<#
.SYNOPSIS
    TOML key scanner for the issue #1022 config-files analyzer: key paths with spans and value
    types, never values, plus console-script table entries for python-cli.

.DESCRIPTION
    Get-DocsTomlKey scans the TOML subset of the 1022 spec (comments, [table] and
    [[array.of.tables]] headers with bare, quoted and dotted keys, key = value with values
    skipped by extent: basic, literal, multi-line basic and multi-line literal strings, arrays
    spanning lines with comments, one-line inline tables, numbers, booleans and date-times).
    Each key record carries Segment (the key path, with the array marker [] for array-of-tables
    elements), Span @(start, end) and ValueType (table, array, string, integer, float, boolean,
    datetime). A table header spans through its last non-blank, non-comment line. Diagnostics:
    TOML_INVALID (blocking), TOML_INLINE_TABLE_NOT_EXPANDED and TOML_KEY_ESCAPE_UNSUPPORTED.
    Get-DocsTomlScriptEntry returns the one-line string entries of [project.scripts],
    [project.gui-scripts] and [tool.poetry.scripts] with CLI_CONSOLE_SCRIPT_UNSUPPORTED for other
    forms; it is the only function that reads a value.

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

$script:DocsTomlScriptTableList = [string[]]@('project.scripts', 'project.gui-scripts', 'tool.poetry.scripts')
$script:DocsTomlDateTimePattern = '^\d{4}-\d{2}-\d{2}(?:[Tt ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:[Zz]|[-+]\d{2}:\d{2})?)?|^\d{2}:\d{2}:\d{2}(?:\.\d+)?'
$script:DocsTomlNumberPattern = '^[-+]?(?:0x[0-9A-Fa-f_]+|0o[0-7_]+|0b[01_]+|inf|nan|\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][-+]?\d[\d_]*)?)'

function Read-DocsTomlKeyPath {
    <#
    .SYNOPSIS
        Reads a dotted key at Offset of Text and returns @{ Segment; End; Escape } or $null (private helper).
    .DESCRIPTION
        Segments are bare keys, basic-quoted keys (Escape is $true when a backslash occurs) or
        literal-quoted keys. End is the index after the key.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text, [Parameter(Mandatory = $true)] [int] $Offset)

    $segments = [System.Collections.Generic.List[string]]::new()
    $escape = $false
    $index = $Offset
    while ($true) {
        while ($index -lt $Text.Length -and ($Text[$index] -eq ' ' -or $Text[$index] -eq "`t")) { $index++ }
        if ($index -ge $Text.Length) { return $null }
        $character = $Text[$index]
        if ($character -eq '"' -or $character -eq '''') {
            $close = $index + 1
            while ($close -lt $Text.Length -and $Text[$close] -ne $character) {
                if ($character -eq '"' -and $Text[$close] -eq '\') { $escape = $true; $close++ }
                $close++
            }
            if ($close -ge $Text.Length) { return $null }
            $segments.Add($Text.Substring($index + 1, $close - $index - 1))
            $index = $close + 1
        } else {
            $match = [regex]::Match($Text.Substring($index), '^[A-Za-z0-9_-]+')
            if (-not $match.Success) { return $null }
            $segments.Add($match.Value)
            $index += $match.Length
        }
        while ($index -lt $Text.Length -and ($Text[$index] -eq ' ' -or $Text[$index] -eq "`t")) { $index++ }
        if ($index -lt $Text.Length -and $Text[$index] -eq '.') { $index++; continue }
        break
    }
    return @{ Segment = $segments.ToArray(); End = $index; Escape = $escape }
}

function Read-DocsTomlValue {
    <#
    .SYNOPSIS
        Skips one value starting at Line/Offset and returns @{ ValueType; EndLine; Text; Valid } (private helper).
    .DESCRIPTION
        Text is the one-line string content for a basic or literal single-line string, else
        $null. Valid is $false for an unterminated string or array or a multi-line inline table.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Line, [Parameter(Mandatory = $true)] [int] $Index, [Parameter(Mandatory = $true)] [int] $Offset)

    $text = $Line[$Index]
    $rest = $text.Substring($Offset).TrimStart(' ', "`t")
    if ($rest.Length -eq 0) { return @{ ValueType = $null; EndLine = $Index; Text = $null; Valid = $false } }
    $first = $rest[0]
    if ($rest.StartsWith('"""') -or $rest.StartsWith("'''")) {
        $quote = $rest.Substring(0, 3)
        $cursor = $Index
        $search = $rest.Substring(3)
        while ($cursor -lt $Line.Count) {
            $position = 0
            while ($position -lt $search.Length) {
                if ($quote -eq '"""' -and $search[$position] -eq '\') { $position += 2; continue }
                if ($search.Substring($position).StartsWith($quote)) { return @{ ValueType = 'string'; EndLine = $cursor; Text = $null; Valid = $true } }
                $position++
            }
            $cursor++
            if ($cursor -lt $Line.Count) { $search = $Line[$cursor] }
        }
        return @{ ValueType = 'string'; EndLine = $Line.Count - 1; Text = $null; Valid = $false }
    }
    if ($first -eq '"' -or $first -eq '''') {
        $close = 1
        while ($close -lt $rest.Length -and $rest[$close] -ne $first) {
            if ($first -eq '"' -and $rest[$close] -eq '\') { $close++ }
            $close++
        }
        if ($close -ge $rest.Length) { return @{ ValueType = 'string'; EndLine = $Index; Text = $null; Valid = $false } }
        return @{ ValueType = 'string'; EndLine = $Index; Text = $rest.Substring(1, $close - 1); Valid = $true }
    }
    if ($first -eq '[' -or $first -eq '{') {
        $depth = 0
        $cursor = $Index
        $search = $rest
        while ($cursor -lt $Line.Count) {
            $position = 0
            $inQuote = [char]0
            while ($position -lt $search.Length) {
                $character = $search[$position]
                if ($inQuote -ne [char]0) {
                    if ($inQuote -eq '"' -and $character -eq '\') { $position += 2; continue }
                    if ($character -eq $inQuote) { $inQuote = [char]0 }
                } elseif ($character -eq '"' -or $character -eq '''') { $inQuote = $character }
                elseif ($character -eq '#') { break }
                elseif ($character -eq '[' -or $character -eq '{') { $depth++ }
                elseif ($character -eq ']' -or $character -eq '}') {
                    $depth--
                    if ($depth -eq 0) {
                        $valueType = if ($first -eq '[') { 'array' } else { 'table' }
                        return @{ ValueType = $valueType; EndLine = $cursor; Text = $null; Valid = ($first -eq '[' -or $cursor -eq $Index) }
                    }
                }
                $position++
            }
            if ($first -eq '{') { return @{ ValueType = 'table'; EndLine = $cursor; Text = $null; Valid = $false } }
            $cursor++
            if ($cursor -lt $Line.Count) { $search = $Line[$cursor] }
        }
        return @{ ValueType = $(if ($first -eq '[') { 'array' } else { 'table' }); EndLine = $Line.Count - 1; Text = $null; Valid = $false }
    }
    $scalar = ($rest -split '\s*#', 2)[0].Trim()
    if ($scalar -ceq 'true' -or $scalar -ceq 'false') { return @{ ValueType = 'boolean'; EndLine = $Index; Text = $null; Valid = $true } }
    if ($scalar -cmatch $script:DocsTomlDateTimePattern) { return @{ ValueType = 'datetime'; EndLine = $Index; Text = $null; Valid = $true } }
    if ($scalar -cmatch $script:DocsTomlNumberPattern) {
        $valueType = if ($scalar -cmatch '[.eE]' -and $scalar -cnotmatch '^[-+]?0x' -or $scalar -cmatch 'inf|nan') { 'float' } else { 'integer' }
        return @{ ValueType = $valueType; EndLine = $Index; Text = $null; Valid = $true }
    }
    return @{ ValueType = $null; EndLine = $Index; Text = $null; Valid = $false }
}

function Read-DocsTomlDocument {
    <#
    .SYNOPSIS
        Scans the TOML text into entries and diagnostics (private helper shared by both exported functions).
    .DESCRIPTION
        Returns @{ Entries; Diagnostics } where each entry is @{ Segment; Span; ValueType; Text;
        Table; IsHeader; ArrayElement }. Text is the one-line string content (for the script
        entry reader only). Diagnostics are records with Code, Severity, Blocking and Line.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $lines = ConvertTo-DocsSourceLine -Text $Text
    $entries = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $defined = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $arrayTables = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $tablePrefix = [string[]]@()
    $tableKey = ''
    $instance = 0
    $prefixEscape = $false
    $header = $null
    $lastContent = -1
    $index = 0
    while ($index -lt $lines.Count) {
        $line = $lines[$index]
        $trimmed = $line.TrimStart(' ', "`t")
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { $index++; continue }
        if ($trimmed.StartsWith('[')) {
            if ($null -ne $header) { $header['Span'] = [int[]]@(($header['Span'][0]), ($lastContent + 1)) }
            $isArray = $trimmed.StartsWith('[[')
            $keyPath = Read-DocsTomlKeyPath -Text $trimmed -Offset $(if ($isArray) { 2 } else { 1 })
            $closer = if ($isArray) { ']]' } else { ']' }
            if ($null -eq $keyPath -or -not $trimmed.Substring($keyPath['End']).StartsWith($closer) -or ($trimmed.Substring($keyPath['End'] + $closer.Length) -split '#', 2)[0].Trim().Length -gt 0) {
                $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
                return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
            }
            $tableKey = $keyPath['Segment'] -join "`u{1}"
            if ($isArray) {
                $prefixEscape = $keyPath['Escape']
                $tablePrefix = [string[]]@($keyPath['Segment'] + @('[]'))
                $instance++
                $firstHeader = $arrayTables.Add($tableKey)
                $header = @{ Segment = $keyPath['Segment']; Span = [int[]]@(($index + 1), ($index + 1)); ValueType = 'array'; Text = $null; Table = $tableKey; IsHeader = $true; ArrayElement = $false; Escape = $keyPath['Escape'] }
                if ($firstHeader) { $entries.Add($header) } else { $header = $null }
            } else {
                $prefixEscape = $keyPath['Escape']
                $tablePrefix = [string[]] $keyPath['Segment']
                if (-not $defined.Add($tableKey) -or $arrayTables.Contains($tableKey)) {
                    $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
                    return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
                }
                $header = @{ Segment = $keyPath['Segment']; Span = [int[]]@(($index + 1), ($index + 1)); ValueType = 'table'; Text = $null; Table = $tableKey; IsHeader = $true; ArrayElement = $false; Escape = $keyPath['Escape'] }
                $entries.Add($header)
            }
            $lastContent = $index
            $index++
            continue
        }
        $keyPath = Read-DocsTomlKeyPath -Text $trimmed -Offset 0
        if ($null -eq $keyPath -or $keyPath['End'] -ge $trimmed.Length -or $trimmed[$keyPath['End']] -ne '=') {
            $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
            return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
        }
        $offset = $line.Length - $trimmed.Length + $keyPath['End'] + 1
        $value = Read-DocsTomlValue -Line $lines -Index $index -Offset $offset
        if (-not $value['Valid']) {
            $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
            return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
        }
        $segment = [string[]]@($tablePrefix + $keyPath['Segment'])
        $fullKey = $segment -join "`u{1}"
        $inArrayTable = $tablePrefix.Count -gt 0 -and $tablePrefix[$tablePrefix.Count - 1] -ceq '[]'
        if ($inArrayTable) {
            $instanceKey = $tableKey + "`u{2}" + $instance + "`u{1}" + $fullKey
            if (-not $defined.Add($instanceKey)) {
                $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
                return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
            }
        } elseif (-not $defined.Add($fullKey)) {
            $diagnostics.Add(@{ Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Line = $index + 1 })
            return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
        }
        $entries.Add(@{ Segment = $segment; Span = [int[]]@(($index + 1), ($value['EndLine'] + 1)); ValueType = $value['ValueType']; Text = $value['Text']; Table = $tableKey; IsHeader = $false; ArrayElement = $inArrayTable; Escape = ($keyPath['Escape'] -or $prefixEscape) })
        $lastContent = $value['EndLine']
        $index = $value['EndLine'] + 1
    }
    if ($null -ne $header) { $header['Span'] = [int[]]@(($header['Span'][0]), ($lastContent + 1)) }
    return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

function Get-DocsTomlKey {
    <#
    .SYNOPSIS
        Returns @{ Keys; Diagnostics } for TOML text: key paths with spans and value types, never values.
    .DESCRIPTION
        Each key is @{ Segment; Span; ValueType }. A key whose quoted segment carries a backslash
        escape is dropped with TOML_KEY_ESCAPE_UNSUPPORTED; an inline-table value is emitted with
        ValueType table and TOML_INLINE_TABLE_NOT_EXPANDED. TOML_INVALID (blocking) empties Keys.
        A key path under an array of tables is emitted once per distinct path.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $document = Read-DocsTomlDocument -Text $Text
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    foreach ($diagnostic in $document['Diagnostics']) { $diagnostics.Add($diagnostic) }
    if ($diagnostics.Count -gt 0) { return @{ Keys = [object[]]@(); Diagnostics = $diagnostics.ToArray() } }
    $keys = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $document['Entries']) {
        if ($entry['Escape']) {
            $diagnostics.Add(@{ Code = 'TOML_KEY_ESCAPE_UNSUPPORTED'; Severity = 'warning'; Blocking = $false; Line = $entry['Span'][0] })
            continue
        }
        if (-not $seen.Add(($entry['Segment'] -join "`u{1}"))) { continue }
        if ($entry['ValueType'] -ceq 'table' -and -not $entry['IsHeader']) {
            $diagnostics.Add(@{ Code = 'TOML_INLINE_TABLE_NOT_EXPANDED'; Severity = 'warning'; Blocking = $false; Line = $entry['Span'][0] })
        }
        $keys.Add(@{ Segment = $entry['Segment']; Span = $entry['Span']; ValueType = $entry['ValueType'] })
    }
    return @{ Keys = $keys.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

function Get-DocsTomlScriptEntry {
    <#
    .SYNOPSIS
        Returns @{ Entries; Diagnostics } for the console-script tables of pyproject.toml.
    .DESCRIPTION
        Each entry is @{ Table (project.scripts, project.gui-scripts or tool.poetry.scripts);
        Name; Target (the one-line string value); Span }. An entry whose value is not a one-line
        string, or whose key is a quoted key with escapes, yields CLI_CONSOLE_SCRIPT_UNSUPPORTED.
        TOML_INVALID (blocking) is passed through with no entries.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $document = Read-DocsTomlDocument -Text $Text
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    foreach ($diagnostic in $document['Diagnostics']) { $diagnostics.Add($diagnostic) }
    if ($diagnostics.Count -gt 0) { return @{ Entries = [object[]]@(); Diagnostics = $diagnostics.ToArray() } }
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $document['Entries']) {
        if ($entry['IsHeader']) { continue }
        $table = ($entry['Table'] -split "`u{1}") -join '.'
        if ($script:DocsTomlScriptTableList -cnotcontains $table) { continue }
        $segment = $entry['Segment']
        $tableDepth = ($table -split '\.').Count
        if ($segment.Count -ne $tableDepth + 1 -or $entry['Escape'] -or $null -eq $entry['Text']) {
            $diagnostics.Add(@{ Code = 'CLI_CONSOLE_SCRIPT_UNSUPPORTED'; Severity = 'warning'; Blocking = $false; Line = $entry['Span'][0] })
            continue
        }
        $entries.Add(@{ Table = $table; Name = $segment[$segment.Count - 1]; Target = $entry['Text']; Span = $entry['Span'] })
    }
    return @{ Entries = $entries.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsTomlKey, Get-DocsTomlScriptEntry
