<#
.SYNOPSIS
    Rendering of reference-page blocks for the documentation reference generator: single-line
    normalization, CommonMark code spans, source and property lines, and the block body of one
    surface element.

.DESCRIPTION
    Every consumer-derived string (declaration, name, path, property name and property value)
    passes through ConvertTo-DocsReferenceSingleLine and then ConvertTo-DocsReferenceCodeSpan,
    so no consumer text starts a line, opens an HTML block, forms a generated-block marker or
    forms a link. Every heading is a fixed English word followed by a code span, so no rendered
    heading begins with an instructional prefix ('how to ', 'step <n>').

    Get-DocsReferenceBlockLine is table-driven over the element kind. architecture-component is
    not rendered and throws. The analysis method and the element digest are never rendered, so a
    change of either causes no page change.

    Property values are canonical JSON without the trailing LF. A non-integral number, which
    canonical JSON does not accept, is written with ConvertTo-DocsJsonText instead.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop

function ConvertTo-DocsReferenceSingleLine {
    <#
    .SYNOPSIS
        Replaces every \p{Cc}, \p{Zl} and \p{Zp} character with a space, collapses space runs and trims both ends.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $spaced = [regex]::Replace($Text, '[\p{Cc}\p{Zl}\p{Zp}]', ' ')
    return ([regex]::Replace($spaced, ' {2,}', ' ')).Trim(' ')
}

function ConvertTo-DocsReferenceCodeSpan {
    <#
    .SYNOPSIS
        Returns a CommonMark code span whose content decodes to Text.
    .DESCRIPTION
        The delimiter is a backtick run one longer than the longest backtick run in Text. One
        space of padding is added on both sides when Text starts or ends with a backtick, or
        starts and ends with a space. Text must be a single line (no CR or LF) and not empty.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    if ($Text.Length -eq 0) { throw 'DOCS_REFERENCE_RENDER_INVALID: a code span needs a non-empty text.' }
    if ($Text.Contains("`n") -or $Text.Contains("`r")) { throw 'DOCS_REFERENCE_RENDER_INVALID: a code span needs a single-line text.' }
    $longest = 0
    foreach ($run in [regex]::Matches($Text, '`+')) {
        if ($run.Length -gt $longest) { $longest = $run.Length }
    }
    $delimiter = '`' * ($longest + 1)
    $pad = $Text.StartsWith('`') -or $Text.EndsWith('`') -or ($Text.StartsWith(' ') -and $Text.EndsWith(' '))
    $content = if ($pad) { " $Text " } else { $Text }
    return $delimiter + $content + $delimiter
}

function ConvertTo-DocsReferenceInlineValue {
    <#
    .SYNOPSIS
        Returns the code span of the single-line form of Text (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    return ConvertTo-DocsReferenceCodeSpan -Text (ConvertTo-DocsReferenceSingleLine -Text $Text)
}

function ConvertTo-DocsReferenceValueJson {
    <#
    .SYNOPSIS
        Returns the JSON text of a property value without the trailing LF (private helper).
    .DESCRIPTION
        Canonical JSON accepts only safe integers as numbers, so a non-integral number is
        written with ConvertTo-DocsJsonText; every other value uses ConvertTo-DocsCanonicalJson.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [object] $Value)

    $isFraction = ($Value -is [double] -or $Value -is [decimal] -or $Value -is [single]) -and ([double] $Value -ne [math]::Truncate([double] $Value))
    $json = if ($isFraction) { ConvertTo-DocsJsonText -Value $Value } else { ConvertTo-DocsCanonicalJson -Value $Value }
    return $json.TrimEnd("`n")
}

function Format-DocsReferenceSourceLine {
    <#
    .SYNOPSIS
        Returns '- Source: `<path>` (lines <start>-<end>)', without the parenthesis when LineRange is null.
    .DESCRIPTION
        LineRange is the element line_range dictionary with start and end, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [System.Collections.IDictionary] $LineRange
    )

    $line = '- Source: ' + (ConvertTo-DocsReferenceInlineValue -Text $Path)
    if ($null -eq $LineRange) { return $line }
    return $line + " (lines $([long] $LineRange['start'])-$([long] $LineRange['end']))"
}

function Format-DocsReferencePropertyLine {
    <#
    .SYNOPSIS
        Returns one '- Property `<name>`: `<json value>`' line per property, ordinal by name.
    .DESCRIPTION
        Property is the element properties array of { name, value } records. Records with the
        same name are ordered by their JSON value, so the result does not depend on input order.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Property)

    $records = @($Property | Where-Object { $null -ne $_ })
    $sorted = [System.Collections.Generic.SortedDictionary[string, string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $records.Count; $index++) {
        $name = [string] $records[$index]['name']
        $json = ConvertTo-DocsReferenceValueJson -Value $records[$index]['value']
        $key = $name + [char]0 + $json + [char]0 + $index.ToString('D9')
        $sorted[$key] = '- Property ' + (ConvertTo-DocsReferenceInlineValue -Text $name) + ': ' + (ConvertTo-DocsReferenceInlineValue -Text $json)
    }
    [string[]] $lines = @($sorted.Values)
    return , $lines
}

function Get-DocsReferenceBlockLine {
    <#
    .SYNOPSIS
        Returns the body lines of the generated block of one element.
    .DESCRIPTION
        Lines: the heading ('## Command', '### Option', '## Route', '## Key' or '## Symbol'
        followed by the code span of the declaration), a blank line, '- Name: `<name>`', the
        source line and the property lines. architecture-component and any other kind throw.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element)

    $kind = [string] $Element['kind']
    $heading = switch -CaseSensitive ($kind) {
        'cli-command' { '## Command' }
        'cli-option' { '### Option' }
        'http-route' { '## Route' }
        'config-key' { '## Key' }
        'public-symbol' { '## Symbol' }
        default { throw "DOCS_REFERENCE_RENDER_INVALID: elements of kind '$kind' are not rendered on a reference page." }
    }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add($heading + ' ' + (ConvertTo-DocsReferenceInlineValue -Text ([string] $Element['declaration'])))
    $lines.Add('')
    $lines.Add('- Name: ' + (ConvertTo-DocsReferenceInlineValue -Text ([string] $Element['name'])))
    $lines.Add((Format-DocsReferenceSourceLine -Path ([string] $Element['path']) -LineRange $Element['line_range']))
    [object[]] $properties = @()
    if ($Element.Contains('properties') -and $null -ne $Element['properties']) { $properties = @($Element['properties']) }
    $propertyLines = Format-DocsReferencePropertyLine -Property $properties
    $lines.AddRange([string[]] $propertyLines)
    return , $lines.ToArray()
}

Export-ModuleMember -Function `
    ConvertTo-DocsReferenceSingleLine, `
    ConvertTo-DocsReferenceCodeSpan, `
    Format-DocsReferenceSourceLine, `
    Format-DocsReferencePropertyLine, `
    Get-DocsReferenceBlockLine
