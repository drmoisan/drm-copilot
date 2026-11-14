<#
.SYNOPSIS
    Shared source-text helpers for the issue #1022 scanners: canonical source lines, line-range
    reduction, key-path declarations, module dotted names, path-or-glob matching, per-code
    diagnostic aggregation and element de-duplication.

.DESCRIPTION
    ConvertTo-DocsSourceLine applies steps 1 to 3 of the 1020 declaration-lines digest rule
    (one BOM removed, CRLF then CR to LF, exactly one trailing LF dropped, split on LF, numbered
    from 1), so every line number a scanner reports is a line number of the 1020 canonical text.
    This module contains no digest or hashing function: ConvertTo-DocsLineRange reduces token
    spans to @(start, end) and never hashes, and source_sha256 is computed only by the 1020
    New-DocsSurfaceElement. Every comparison is case-sensitive and ordinal.

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

function ConvertTo-DocsSourceLine {
    <#
    .SYNOPSIS
        Returns the canonical source lines of Text (digest steps 1 to 3), line i at index i - 1.
    .DESCRIPTION
        Removes one leading U+FEFF, replaces CRLF then CR with LF, drops exactly one trailing LF
        and splits on LF. Form feed, U+2028, U+2029 and U+0085 are not line breaks. The empty
        text has zero lines.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $normalized = if ($null -eq $Text) { '' } else { $Text }
    if ($normalized.StartsWith([char]0xFEFF)) { $normalized = $normalized.Substring(1) }
    $normalized = $normalized.Replace("`r`n", "`n").Replace("`r", "`n")
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    if ($normalized.Length -eq 0) { return , [string[]]@() }
    return , [string[]] $normalized.Split("`n")
}

function ConvertTo-DocsLineRange {
    <#
    .SYNOPSIS
        Reduces one or more @(start, end) spans to @(first start, last end); pure and non-hashing.
    .DESCRIPTION
        Span is a list of two-element integer spans in site order. A single flat pair is one
        span. An empty list, a span that is not two integers, a start below 1 or a result whose
        start exceeds its end throws DOCS_LINE_RANGE_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Span)

    if ($null -eq $Span -or $Span.Count -eq 0) { throw 'DOCS_LINE_RANGE_INVALID: at least one span is required.' }
    $spans = $Span
    if ($Span.Count -eq 2 -and $Span[0] -is [ValueType] -and $Span[1] -is [ValueType]) { $spans = @(, $Span) }
    $first = $null
    $last = $null
    foreach ($entry in $spans) {
        $pair = @($entry)
        if ($pair.Count -ne 2 -or -not ($pair[0] -is [ValueType]) -or -not ($pair[1] -is [ValueType])) { throw 'DOCS_LINE_RANGE_INVALID: every span must be two integers.' }
        $start = [int] $pair[0]
        $end = [int] $pair[1]
        if ($start -lt 1 -or $end -lt $start) { throw "DOCS_LINE_RANGE_INVALID: span @($start, $end) is not a line range." }
        if ($null -eq $first) { $first = $start }
        $last = $end
    }
    if ($last -lt $first) { throw "DOCS_LINE_RANGE_INVALID: the last end $last precedes the first start $first." }
    return [int[]]@($first, $last)
}

function ConvertTo-DocsKeyPathDeclaration {
    <#
    .SYNOPSIS
        Joins key-path segments into the config-key declaration string.
    .DESCRIPTION
        A segment matching ^[A-Za-z0-9_-]+$ and the array marker [] stay bare; any other segment
        becomes a TOML basic string with the quote and the backslash escaped. Segments are joined
        with '.'. The mapping is injective: a quoted segment always starts with a quote, which a
        bare segment never contains.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Segment)

    if ($Segment.Count -eq 0) { throw 'DOCS_IDENTITY_INPUT_INVALID: a key path needs at least one segment.' }
    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Segment) {
        $text = if ($null -eq $entry) { '' } else { [string] $entry }
        if ($text -ceq '[]' -or $text -cmatch '^[A-Za-z0-9_-]+$(?![\s\S])') {
            $parts.Add($text)
        } else {
            $parts.Add('"' + $text.Replace('\', '\\').Replace('"', '\"') + '"')
        }
    }
    return $parts -join '.'
}

function Get-DocsModuleDottedName {
    <#
    .SYNOPSIS
        Returns the dotted module name of a Python path relative to its containing source root.
    .DESCRIPTION
        The containing root is the longest SourceRoot entry that equals '.' or that Path begins
        with (entry plus '/'). The '.py' extension is removed and '/' becomes '.'; '__init__.py'
        yields the package name. Returns $null for a path under no root, a non-.py path, or a
        root-level __init__.py (no package name). Segment validity is not checked here.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot
    )

    if (-not $Path.EndsWith('.py', [System.StringComparison]::Ordinal)) { return $null }
    $relative = $null
    $bestLength = -1
    foreach ($root in $SourceRoot) {
        $trimmed = ([string] $root).TrimEnd('/')
        if ($trimmed -ceq '.' -or $trimmed -ceq '') {
            if ($bestLength -lt 0) { $bestLength = 0; $relative = $Path }
            continue
        }
        if ($Path.StartsWith($trimmed + '/', [System.StringComparison]::Ordinal) -and $trimmed.Length -gt $bestLength) {
            $bestLength = $trimmed.Length
            $relative = $Path.Substring($trimmed.Length + 1)
        }
    }
    if ($null -eq $relative) { return $null }
    $stem = $relative.Substring(0, $relative.Length - 3)
    if ($stem.EndsWith('/__init__', [System.StringComparison]::Ordinal)) { $stem = $stem.Substring(0, $stem.Length - 9) }
    elseif ($stem -ceq '__init__') { return $null }
    if ($stem.Length -eq 0) { return $null }
    return $stem.Replace('/', '.')
}

function ConvertTo-DocsGlobRegex {
    <#
    .SYNOPSIS
        Converts a path-or-glob entry to an anchored case-sensitive regex (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Glob)

    $builder = [System.Text.StringBuilder]::new('^')
    $index = 0
    while ($index -lt $Glob.Length) {
        $character = $Glob[$index]
        if ($character -eq '*') {
            if ($index + 1 -lt $Glob.Length -and $Glob[$index + 1] -eq '*') { [void] $builder.Append('.*'); $index += 2; continue }
            [void] $builder.Append('[^/]*')
        } elseif ($character -eq '?') {
            [void] $builder.Append('[^/]')
        } else {
            [void] $builder.Append([regex]::Escape([string] $character))
        }
        $index++
    }
    [void] $builder.Append('$(?![\s\S])')
    return $builder.ToString()
}

function Find-DocsPathOrGlobMatch {
    <#
    .SYNOPSIS
        Returns the first Entry whose path_or_glob matches Path, or $null.
    .DESCRIPTION
        An entry is a dictionary with a path_or_glob key or a plain string. A match is exact, a
        prefix match where the entry plus '/' begins Path, or a case-sensitive glob where '*'
        matches any run other than '/', '**' any run including '/', '?' one character other
        than '/', and every other character is literal. Entries are tried in order.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Entry
    )

    if ($null -eq $Entry) { return $null }
    foreach ($candidate in $Entry) {
        $pattern = if ($candidate -is [System.Collections.IDictionary]) { [string] $candidate['path_or_glob'] } else { [string] $candidate }
        if ([string]::IsNullOrEmpty($pattern)) { continue }
        if ($Path -ceq $pattern) { return $candidate }
        if ($Path.StartsWith($pattern.TrimEnd('/') + '/', [System.StringComparison]::Ordinal)) { return $candidate }
        if ($pattern.IndexOfAny([char[]]@('*', '?')) -ge 0 -and $Path -cmatch (ConvertTo-DocsGlobRegex -Glob $pattern)) { return $candidate }
    }
    return $null
}

function New-DocsDiagnosticAggregate {
    <#
    .SYNOPSIS
        Returns an empty diagnostic aggregate: one diagnostic per (analyzer, code, path).
    .DESCRIPTION
        Entry maps the ordinal key '<analyzer>|<code>|<path>' to an occurrence record; the
        Diagnostics member is the list of 1020 New-DocsDiagnostic records, sorted by analyzer,
        code and path, refreshed by Add-DocsDiagnosticOccurrence.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    return [pscustomobject]@{
        Entry       = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
        Diagnostics = [object[]]@()
    }
}

function Add-DocsDiagnosticOccurrence {
    <#
    .SYNOPSIS
        Records one occurrence of a diagnostic code at Path and Line in Aggregate.
    .DESCRIPTION
        The diagnostic for (AnalyzerId, Code, Path) is built with 1020 New-DocsDiagnostic; its
        message states the occurrence count and the first line number only and never quotes
        source text. Severity is 'error' (blocking) or 'warning' (non-blocking); the first
        occurrence fixes it. Returns nothing; read Aggregate.Diagnostics.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [pscustomobject] $Aggregate,
        [Parameter(Mandatory = $true)] [string] $AnalyzerId,
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Path,
        [int] $Line = 0,
        [ValidateSet('error', 'warning')] [string] $Severity = 'warning'
    )

    $diagnosticPath = if ([string]::IsNullOrEmpty($Path)) { $null } else { $Path }
    $key = $AnalyzerId + '|' + $Code + '|' + [string] $diagnosticPath
    $entry = $null
    if ($Aggregate.Entry.TryGetValue($key, [ref] $entry)) {
        $entry['Count'] = [int] $entry['Count'] + 1
        if ($Line -gt 0 -and ([int] $entry['FirstLine'] -eq 0 -or $Line -lt [int] $entry['FirstLine'])) { $entry['FirstLine'] = $Line }
    } else {
        $entry = @{ AnalyzerId = $AnalyzerId; Code = $Code; Path = $diagnosticPath; Severity = $Severity; Count = 1; FirstLine = $Line }
        $Aggregate.Entry[$key] = $entry
    }
    $message = "$($entry['Count']) occurrence(s); first at line $($entry['FirstLine'])."
    $entry['Diagnostic'] = New-DocsDiagnostic -Code $Code -Path $diagnosticPath -Message $message -AnalyzerId $AnalyzerId -Severity ([string] $entry['Severity'])

    [string[]] $keys = @($Aggregate.Entry.Keys)
    [Array]::Sort($keys, [System.StringComparer]::Ordinal)
    $list = [System.Collections.Generic.List[object]]::new()
    foreach ($sortedKey in $keys) { $list.Add($Aggregate.Entry[$sortedKey]['Diagnostic']) }
    $Aggregate.Diagnostics = $list.ToArray()
}

function Select-DocsUniqueElement {
    <#
    .SYNOPSIS
        Builds the unique elements of a candidate list through 1020 New-DocsSurfaceElement.
    .DESCRIPTION
        Each candidate is a dictionary with Line (first line of the site) and Parameter (the
        New-DocsSurfaceElement argument dictionary). A candidate whose kind, path or declaration
        Get-DocsElementId rejects is dropped with DECLARATION_INVALID; a repeated (kind, path,
        declaration) is dropped with DUPLICATE_DECLARATION, keeping the first site by line
        (candidate order breaks ties). Both diagnostics carry analyzer_id docs-inventory and are
        non-blocking. Returns the built elements in surviving candidate order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Candidate,
        [Parameter(Mandatory = $true)] [pscustomobject] $Aggregate
    )

    $ordered = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Candidate.Count; $index++) {
        $ordered.Add(@{ Index = $index; Line = [int] $Candidate[$index]['Line']; Candidate = $Candidate[$index] })
    }
    $byLine = @($ordered | Sort-Object -Property @{ Expression = 'Line' }, @{ Expression = 'Index' })
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $kept = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($record in $byLine) {
        $parameter = $record['Candidate']['Parameter']
        $kind = [string] $parameter['Kind']
        $path = [string] $parameter['Path']
        $declaration = [string] $parameter['Declaration']
        try {
            [void] (Get-DocsElementId -Kind $kind -Path $path -Declaration $declaration)
        } catch {
            if (-not $_.Exception.Message.StartsWith('DOCS_IDENTITY_INPUT_INVALID', [System.StringComparison]::Ordinal)) { throw }
            Add-DocsDiagnosticOccurrence -Aggregate $Aggregate -AnalyzerId 'docs-inventory' -Code 'DECLARATION_INVALID' -Path $path -Line $record['Line'] -Severity 'warning'
            continue
        }
        $key = $kind + "`n" + $path + "`n" + $declaration
        if (-not $seen.Add($key)) {
            Add-DocsDiagnosticOccurrence -Aggregate $Aggregate -AnalyzerId 'docs-inventory' -Code 'DUPLICATE_DECLARATION' -Path $path -Line $record['Line'] -Severity 'warning'
            continue
        }
        [void] $kept.Add([int] $record['Index'])
    }

    $elements = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Candidate.Count; $index++) {
        if (-not $kept.Contains($index)) { continue }
        $splat = @{}
        foreach ($name in $Candidate[$index]['Parameter'].Keys) { $splat[[string] $name] = $Candidate[$index]['Parameter'][$name] }
        $elements.Add((New-DocsSurfaceElement @splat))
    }
    return , $elements.ToArray()
}

Export-ModuleMember -Function `
    ConvertTo-DocsSourceLine, `
    ConvertTo-DocsLineRange, `
    ConvertTo-DocsKeyPathDeclaration, `
    Get-DocsModuleDottedName, `
    Find-DocsPathOrGlobMatch, `
    New-DocsDiagnosticAggregate, `
    Add-DocsDiagnosticOccurrence, `
    Select-DocsUniqueElement
