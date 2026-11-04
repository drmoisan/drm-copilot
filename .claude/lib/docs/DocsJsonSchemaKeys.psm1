<#
.SYNOPSIS
    JSON Schema key walker for the issue #1022 config-files analyzer: member line spans of JSON
    text and the property key paths of a schema, never values.

.DESCRIPTION
    Get-DocsJsonMemberSpan maps JSON pointers (RFC 6901, object members and array elements) to
    @(start, end) line spans for text already accepted by ConvertFrom-DocsJsonText.
    Get-DocsJsonSchemaKey walks root and nested properties, object-form items.properties
    (segment []), allOf, anyOf and oneOf members (Conditional for anyOf and oneOf) and local
    $ref to #/$defs/ and #/definitions/ up to depth 16 with a visited set, returning key records
    with Segment, Span, SchemaType (the literal type string, multiple, or $null), Required and
    Conditional. default, enum, const, examples and pattern are never read into the output.
    Diagnostics: JSON_SCHEMA_REF_UNRESOLVED (remote $ref, missing target, cycle, depth above 16)
    and JSON_SCHEMA_KEYWORD_NOT_EXPANDED (if, then, else, not, patternProperties, schema-valued
    additionalProperties, dependentSchemas, prefixItems, unevaluatedProperties), both site level.

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

$script:DocsJsonSchemaMaxDepth = 16
$script:DocsJsonSchemaUnexpandedKeywordList = [string[]]@('if', 'then', 'else', 'not', 'patternProperties', 'dependentSchemas', 'prefixItems', 'unevaluatedProperties')

function ConvertTo-DocsJsonSchemaPointerToken {
    <#
    .SYNOPSIS
        Escapes one JSON pointer token (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Token)

    return $Token.Replace('~', '~0').Replace('/', '~1')
}

function Get-DocsJsonMemberSpan {
    <#
    .SYNOPSIS
        Returns an ordinal dictionary of JSON pointer to @(start, end) line span for JSON text.
    .DESCRIPTION
        The span of an object member runs from the line of its name to the line where its value
        ends; an array element spans its value. The root pointer '' spans the document. Text is
        normalized with ConvertTo-DocsSourceLine; the text must already have been accepted by
        ConvertFrom-DocsJsonText, so no syntax error is reported here.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[string, object]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $source = (ConvertTo-DocsSourceLine -Text $Text) -join "`n"
    $spans = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $stack = [System.Collections.Generic.List[object]]::new()
    $line = 1
    $index = 0
    $pendingName = $null
    $pendingLine = 0
    $rootStart = 0
    while ($index -lt $source.Length) {
        $character = $source[$index]
        if ($character -eq "`n") { $line++; $index++; continue }
        if ([char]::IsWhiteSpace($character)) { $index++; continue }
        if ($rootStart -eq 0) { $rootStart = $line }
        if ($character -eq '"') {
            $close = $index + 1
            $builder = [System.Text.StringBuilder]::new()
            while ($close -lt $source.Length -and $source[$close] -ne '"') {
                if ($source[$close] -eq '\') {
                    $escaped = $source[$close + 1]
                    if ($escaped -eq 'u') { [void] $builder.Append([char][Convert]::ToInt32($source.Substring($close + 2, 4), 16)); $close += 6; continue }
                    $mapped = switch ($escaped) { 'n' { "`n" } 't' { "`t" } 'r' { "`r" } 'b' { "`b" } 'f' { "`f" } default { [string] $escaped } }
                    [void] $builder.Append($mapped)
                    $close += 2
                    continue
                }
                [void] $builder.Append($source[$close])
                $close++
            }
            $value = $builder.ToString()
            $index = $close + 1
            $frame = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
            if ($null -ne $frame -and $frame['IsObject'] -and $null -eq $pendingName -and $frame['ExpectName']) {
                $pendingName = $value
                $pendingLine = $line
                $frame['ExpectName'] = $false
                continue
            }
            $pointer = $(if ($null -ne $frame) { $frame['Pointer'] + '/' + $(if ($frame['IsObject']) { ConvertTo-DocsJsonSchemaPointerToken -Token $pendingName } else { [string] $frame['Index'] }) } else { '' })
            $spans[$pointer] = [int[]]@($(if ($null -ne $frame -and $frame['IsObject']) { $pendingLine } else { $line }), $line)
            $pendingName = $null
            continue
        }
        if ($character -eq '{' -or $character -eq '[') {
            $frame = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
            $pointer = $(if ($null -ne $frame) { $frame['Pointer'] + '/' + $(if ($frame['IsObject']) { ConvertTo-DocsJsonSchemaPointerToken -Token $pendingName } else { [string] $frame['Index'] }) } else { '' })
            $start = $(if ($null -ne $frame -and $frame['IsObject']) { $pendingLine } else { $line })
            $stack.Add(@{ Pointer = $pointer; IsObject = ($character -eq '{'); Index = 0; Start = $start; ExpectName = ($character -eq '{') })
            $pendingName = $null
            $index++
            continue
        }
        if ($character -eq '}' -or $character -eq ']') {
            $frame = $stack[$stack.Count - 1]
            $stack.RemoveAt($stack.Count - 1)
            $spans[$frame['Pointer']] = [int[]]@($frame['Start'], $line)
            $index++
            continue
        }
        if ($character -eq ',') {
            $frame = $stack[$stack.Count - 1]
            if ($frame['IsObject']) { $frame['ExpectName'] = $true } else { $frame['Index'] = [int] $frame['Index'] + 1 }
            $index++
            continue
        }
        if ($character -eq ':') { $index++; continue }
        $match = [regex]::Match($source.Substring($index), '^(?:true|false|null|-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?)')
        if (-not $match.Success) { throw "DOCS_JSON_SPAN_INVALID: unexpected character at line $line." }
        $frame = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
        $pointer = $(if ($null -ne $frame) { $frame['Pointer'] + '/' + $(if ($frame['IsObject']) { ConvertTo-DocsJsonSchemaPointerToken -Token $pendingName } else { [string] $frame['Index'] }) } else { '' })
        $spans[$pointer] = [int[]]@($(if ($null -ne $frame -and $frame['IsObject']) { $pendingLine } else { $line }), $line)
        $pendingName = $null
        $index += $match.Length
    }
    return $spans
}

function Get-DocsJsonSchemaKey {
    <#
    .SYNOPSIS
        Returns @{ Keys; Diagnostics } for a parsed JSON Schema value and its member spans.
    .DESCRIPTION
        Value is the ordinal hashtable of ConvertFrom-DocsJsonText; MemberSpan the dictionary of
        Get-DocsJsonMemberSpan. Each key is @{ Segment; Span; SchemaType; Required; Conditional;
        Pointer }. The walk is depth-first in ordinal member order.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [System.Collections.IDictionary] $Value,
        [Parameter(Mandatory = $true)] [AllowNull()] [System.Collections.IDictionary] $MemberSpan
    )

    $state = @{
        Root        = $Value
        Spans       = $MemberSpan
        Keys        = [System.Collections.Generic.List[object]]::new()
        Diagnostics = [System.Collections.Generic.List[object]]::new()
        Seen        = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    }
    if ($null -ne $Value) {
        Invoke-DocsJsonSchemaWalk -State $state -Schema $Value -Pointer '' -Segment ([string[]]@()) -Depth 0 -Conditional $false -Visited ([System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal))
    }
    return @{ Keys = $state['Keys'].ToArray(); Diagnostics = $state['Diagnostics'].ToArray() }
}

function Get-DocsJsonSchemaSpan {
    <#
    .SYNOPSIS
        Returns the recorded span of a pointer, or a one-line span at line 1 when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param([Parameter(Mandatory = $true)] [hashtable] $State, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer)

    $span = $null
    if ($null -ne $State['Spans'] -and $State['Spans'].ContainsKey($Pointer)) { $span = $State['Spans'][$Pointer] }
    if ($null -eq $span) { return [int[]]@(1, 1) }
    return [int[]]@($span[0], $span[1])
}

function Add-DocsJsonSchemaDiagnostic {
    <#
    .SYNOPSIS
        Records one site-level diagnostic at the line of a pointer (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State, [Parameter(Mandatory = $true)] [string] $Code, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer)

    $State['Diagnostics'].Add(@{ Code = $Code; Severity = 'warning'; Blocking = $false; Line = (Get-DocsJsonSchemaSpan -State $State -Pointer $Pointer)[0] })
}

function Resolve-DocsJsonSchemaRef {
    <#
    .SYNOPSIS
        Resolves a local $ref to @{ Schema; Pointer } or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [hashtable] $State, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Reference)

    if (-not ($Reference.StartsWith('#/$defs/', [System.StringComparison]::Ordinal) -or $Reference.StartsWith('#/definitions/', [System.StringComparison]::Ordinal))) { return $null }
    $current = $State['Root']
    $pointer = ''
    foreach ($token in $Reference.Substring(1).Split('/')) {
        if ($token.Length -eq 0) { continue }
        $name = $token.Replace('~1', '/').Replace('~0', '~')
        if (-not ($current -is [System.Collections.IDictionary]) -or -not $current.Contains($name)) { return $null }
        $current = $current[$name]
        $pointer = $pointer + '/' + $token
    }
    if (-not ($current -is [System.Collections.IDictionary])) { return $null }
    return @{ Schema = $current; Pointer = $pointer }
}

function Invoke-DocsJsonSchemaWalk {
    <#
    .SYNOPSIS
        Walks one schema object and records its property keys (private recursive helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Schema,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Segment,
        [Parameter(Mandatory = $true)] [int] $Depth,
        [Parameter(Mandatory = $true)] [bool] $Conditional,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visited
    )

    if ($Depth -gt $script:DocsJsonSchemaMaxDepth) { Add-DocsJsonSchemaDiagnostic -State $State -Code 'JSON_SCHEMA_REF_UNRESOLVED' -Pointer $Pointer; return }
    if ($Schema.Contains('$ref') -and $Schema['$ref'] -is [string]) {
        $target = Resolve-DocsJsonSchemaRef -State $State -Reference ([string] $Schema['$ref'])
        if ($null -eq $target -or $Visited.Contains($target['Pointer'])) { Add-DocsJsonSchemaDiagnostic -State $State -Code 'JSON_SCHEMA_REF_UNRESOLVED' -Pointer ($Pointer + '/$ref') }
        else {
            $branch = [System.Collections.Generic.HashSet[string]]::new($Visited, [System.StringComparer]::Ordinal)
            [void] $branch.Add($target['Pointer'])
            Invoke-DocsJsonSchemaWalk -State $State -Schema $target['Schema'] -Pointer $target['Pointer'] -Segment $Segment -Depth ($Depth + 1) -Conditional $Conditional -Visited $branch
        }
    }
    foreach ($keyword in $script:DocsJsonSchemaUnexpandedKeywordList) {
        if ($Schema.Contains($keyword)) { Add-DocsJsonSchemaDiagnostic -State $State -Code 'JSON_SCHEMA_KEYWORD_NOT_EXPANDED' -Pointer ($Pointer + '/' + $keyword) }
    }
    if ($Schema.Contains('additionalProperties') -and $Schema['additionalProperties'] -is [System.Collections.IDictionary]) { Add-DocsJsonSchemaDiagnostic -State $State -Code 'JSON_SCHEMA_KEYWORD_NOT_EXPANDED' -Pointer ($Pointer + '/additionalProperties') }
    $required = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    if ($Schema.Contains('required') -and $Schema['required'] -is [System.Collections.IEnumerable] -and -not ($Schema['required'] -is [string])) {
        foreach ($name in $Schema['required']) { if ($name -is [string]) { [void] $required.Add($name) } }
    }
    if ($Schema.Contains('properties') -and $Schema['properties'] -is [System.Collections.IDictionary]) {
        if ($Depth + 1 -gt $script:DocsJsonSchemaMaxDepth) { Add-DocsJsonSchemaDiagnostic -State $State -Code 'JSON_SCHEMA_REF_UNRESOLVED' -Pointer ($Pointer + '/properties'); return }
        $properties = $Schema['properties']
        [string[]] $names = @($properties.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($names, [System.StringComparer]::Ordinal)
        foreach ($name in $names) {
            $child = $properties[$name]
            if (-not ($child -is [System.Collections.IDictionary])) { continue }
            $childPointer = $Pointer + '/properties/' + (ConvertTo-DocsJsonSchemaPointerToken -Token $name)
            $childSegment = [string[]]@($Segment + @($name))
            $identity = ($childSegment -join "`u{1}")
            if ($State['Seen'].Add($identity)) {
                $schemaType = $null
                if ($child.Contains('type')) {
                    if ($child['type'] -is [string]) { $schemaType = [string] $child['type'] }
                    elseif ($child['type'] -is [System.Collections.IEnumerable]) { $schemaType = 'multiple' }
                }
                $State['Keys'].Add(@{ Segment = $childSegment; Span = (Get-DocsJsonSchemaSpan -State $State -Pointer $childPointer); SchemaType = $schemaType; Required = $required.Contains($name); Conditional = $Conditional; Pointer = $childPointer })
            }
            Invoke-DocsJsonSchemaWalk -State $State -Schema $child -Pointer $childPointer -Segment $childSegment -Depth ($Depth + 1) -Conditional $Conditional -Visited $Visited
        }
    }
    if ($Schema.Contains('items') -and $Schema['items'] -is [System.Collections.IDictionary]) {
        Invoke-DocsJsonSchemaWalk -State $State -Schema $Schema['items'] -Pointer ($Pointer + '/items') -Segment ([string[]]@($Segment + @('[]'))) -Depth ($Depth + 1) -Conditional $Conditional -Visited $Visited
    }
    foreach ($combiner in @('allOf', 'anyOf', 'oneOf')) {
        if (-not $Schema.Contains($combiner) -or -not ($Schema[$combiner] -is [System.Collections.IEnumerable]) -or $Schema[$combiner] -is [string]) { continue }
        $position = 0
        foreach ($member in $Schema[$combiner]) {
            if ($member -is [System.Collections.IDictionary]) {
                Invoke-DocsJsonSchemaWalk -State $State -Schema $member -Pointer ($Pointer + '/' + $combiner + '/' + $position) -Segment $Segment -Depth ($Depth + 1) -Conditional ($Conditional -or $combiner -cne 'allOf') -Visited $Visited
            }
            $position++
        }
    }
}

Export-ModuleMember -Function Get-DocsJsonMemberSpan, Get-DocsJsonSchemaKey
