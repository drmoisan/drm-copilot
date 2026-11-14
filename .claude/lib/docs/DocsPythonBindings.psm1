<#
.SYNOPSIS
    Python binding tables for the issue #1022 scanners: the per-input import alias table, the
    tracked-receiver table, definition headers (split from DocsPythonSyntax.psm1 under the
    500-line module rule), qualified-name resolution through the alias table, and the shared
    front-end that the four Python analyzers run over every input.

.DESCRIPTION
    Every function takes the logical lines of Get-DocsPythonLogicalLine and returns new
    hashtables. Diagnostics are records with Code, Severity, Blocking, Line and Name; the
    analyzers attach the path. Names are compared ordinally, so App and app stay distinct. The
    framework modules are argparse, click, typer, fastapi and flask.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonSyntax.psm1') -ErrorAction Stop

$script:DocsPythonFrameworkList = [string[]]@('argparse', 'click', 'typer', 'fastapi', 'flask')

function Get-DocsPythonImportTable {
    <#
    .SYNOPSIS
        Builds the per-input import alias table and returns @{ Alias; Ambiguous; Star; Statements; Diagnostics }.
    .DESCRIPTION
        Statements lists every import logical line at any indentation (Index, Line, EndLine,
        Indent, Kind, Module, Level, Names, Star, Nested, TopLevel). Alias maps a bound name to
        @{ Module; Member; Level; Full; Line } for statements at indentation 0 or inside
        top-level if, elif, else, try, except and finally blocks. Diagnostics (non-blocking,
        site level): PYTHON_IMPORT_STAR_FRAMEWORK, PYTHON_IMPORT_NESTED_FRAMEWORK and
        PYTHON_BINDING_AMBIGUOUS (the name is removed from Alias and listed in Ambiguous).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line)

    $alias = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $ambiguous = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $star = [System.Collections.Generic.List[string]]::new()
    $statements = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        $first = $tokens[0]
        if ($first['Type'] -cne 'NAME' -or -not $first['IsKeyword'] -or ($first['Text'] -cne 'import' -and $first['Text'] -cne 'from')) { continue }
        $block = Get-DocsPythonEnclosingBlock -Line $Line -Index $index
        $statement = @{ Index = $index; Line = $Line[$index]['StartLine']; EndLine = $Line[$index]['EndLine']; Indent = $Line[$index]['Indent']; Kind = $first['Text']; Module = ''; Level = 0; Names = @(); Star = $false; Nested = ($block['InDef'] -or $block['InClass']); TopLevel = $block['TopLevelOnly'] }
        $cursor = 1
        $names = [System.Collections.Generic.List[object]]::new()
        if ($first['Text'] -ceq 'from') {
            while ($cursor -lt $tokens.Count -and $tokens[$cursor]['Type'] -ceq 'OP' -and ($tokens[$cursor]['Text'] -ceq '.' -or $tokens[$cursor]['Text'] -ceq '...')) { $statement['Level'] += $tokens[$cursor]['Text'].Length; $cursor++ }
            $chain = Read-DocsPythonDottedChain -Token $tokens -Index $cursor
            if ($null -ne $chain) { $statement['Module'] = $chain['Text']; $cursor = $chain['End'] }
            if ($cursor -ge $tokens.Count -or $tokens[$cursor]['Text'] -cne 'import') { continue }
            $cursor++
            if ($cursor -lt $tokens.Count -and $tokens[$cursor]['Type'] -ceq 'OP' -and $tokens[$cursor]['Text'] -ceq '*') { $statement['Star'] = $true }
        }
        while ($cursor -lt $tokens.Count) {
            $token = $tokens[$cursor]
            if ($token['Type'] -ceq 'OP' -and $token['Text'] -cin @('(', ')', ',')) { $cursor++; continue }
            $chain = Read-DocsPythonDottedChain -Token $tokens -Index $cursor
            if ($null -eq $chain) { break }
            $cursor = $chain['End']
            $bound = $null
            if ($cursor + 1 -lt $tokens.Count -and $tokens[$cursor]['Text'] -ceq 'as' -and $tokens[$cursor + 1]['Type'] -ceq 'NAME') { $bound = $tokens[$cursor + 1]['Text']; $cursor += 2 }
            $names.Add(@{ Name = $chain['Text']; Alias = $bound })
        }
        $statement['Names'] = $names.ToArray()
        $statements.Add($statement)
        $root = if ($first['Text'] -ceq 'from') { $statement['Module'].Split('.')[0] } else { '' }
        if ($statement['Star']) {
            if ($statement['Level'] -eq 0 -and $script:DocsPythonFrameworkList -ccontains $root) {
                $star.Add($statement['Module'])
                $diagnostics.Add(@{ Code = 'PYTHON_IMPORT_STAR_FRAMEWORK'; Severity = 'warning'; Blocking = $false; Line = $statement['Line']; Name = $statement['Module'] })
            }
            continue
        }
        foreach ($entry in $names) {
            $isFrom = $first['Text'] -ceq 'from'
            $full = if ($isFrom) { ('.' * $statement['Level']) + $statement['Module'] + $(if ($statement['Module'].Length -gt 0) { '.' } else { '' }) + $entry['Name'] } else { $entry['Name'] }
            $topRoot = if ($isFrom) { $root } else { $entry['Name'].Split('.')[0] }
            $bound = if ($null -ne $entry['Alias']) { $entry['Alias'] } elseif ($isFrom) { $entry['Name'] } else { $entry['Name'].Split('.')[0] }
            $target = @{ Module = $(if ($isFrom) { $statement['Module'] } else { $entry['Name'] }); Member = $(if ($isFrom) { $entry['Name'] } else { $null }); Level = $statement['Level']; Full = $(if ($isFrom -or $null -ne $entry['Alias']) { $full } else { $bound }); Line = $statement['Line'] }
            if ($statement['Nested']) {
                if ($statement['Level'] -eq 0 -and $script:DocsPythonFrameworkList -ccontains $topRoot) { $diagnostics.Add(@{ Code = 'PYTHON_IMPORT_NESTED_FRAMEWORK'; Severity = 'warning'; Blocking = $false; Line = $statement['Line']; Name = $bound }) }
                continue
            }
            if (-not $statement['TopLevel'] -or $ambiguous.Contains($bound)) { continue }
            $existing = $null
            if ($alias.TryGetValue($bound, [ref] $existing)) {
                if ($existing['Full'] -cne $target['Full']) {
                    [void] $alias.Remove($bound)
                    [void] $ambiguous.Add($bound)
                    $diagnostics.Add(@{ Code = 'PYTHON_BINDING_AMBIGUOUS'; Severity = 'warning'; Blocking = $false; Line = $statement['Line']; Name = $bound })
                }
                continue
            }
            $alias[$bound] = $target
        }
    }
    return @{ Alias = $alias; Ambiguous = $ambiguous; Star = $star.ToArray(); Statements = $statements.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

function Get-DocsPythonReceiverTable {
    <#
    .SYNOPSIS
        Tracks NAME = ctor(...) and NAME: T = ctor(...) bindings at any indentation; returns @{ Receiver; Ambiguous; Diagnostics }.
    .DESCRIPTION
        Receiver maps the bound name to @{ Callee; Call; Line; Index; Indent; Nested; Text }. A
        name bound to two different call texts yields PYTHON_BINDING_AMBIGUOUS and is removed.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line)

    $receiver = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $ambiguous = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        if ($tokens.Count -lt 4 -or $tokens[0]['Type'] -cne 'NAME' -or $tokens[0]['IsKeyword']) { continue }
        $cursor = 1
        if ($tokens[1]['Type'] -ceq 'OP' -and $tokens[1]['Text'] -ceq ':') {
            $cursor = 2
            while ($cursor -lt $tokens.Count -and -not ($tokens[$cursor]['Type'] -ceq 'OP' -and $tokens[$cursor]['Text'] -ceq '=' -and $tokens[$cursor]['Level'] -eq 0)) { $cursor++ }
        }
        if ($cursor -ge $tokens.Count -or $tokens[$cursor]['Type'] -cne 'OP' -or $tokens[$cursor]['Text'] -cne '=') { continue }
        $call = Read-DocsPythonCall -Token $tokens -Index ($cursor + 1)
        if ($null -eq $call -or $call['CloseIndex'] -ne $tokens.Count - 1) { continue }
        $name = [string] $tokens[0]['Text']
        $text = (@($tokens[($cursor + 1)..($tokens.Count - 1)] | ForEach-Object { $_['Text'] })) -join ' '
        if ($ambiguous.Contains($name)) { continue }
        $existing = $null
        if ($receiver.TryGetValue($name, [ref] $existing)) {
            if ($existing['Text'] -cne $text) {
                [void] $receiver.Remove($name)
                [void] $ambiguous.Add($name)
                $diagnostics.Add(@{ Code = 'PYTHON_BINDING_AMBIGUOUS'; Severity = 'warning'; Blocking = $false; Line = $Line[$index]['StartLine']; Name = $name })
            }
            continue
        }
        $block = Get-DocsPythonEnclosingBlock -Line $Line -Index $index
        $receiver[$name] = @{ Callee = $call['Callee']; Call = $call; Line = $Line[$index]['StartLine']; Index = $index; Indent = $Line[$index]['Indent']; Nested = ($block['InDef'] -or $block['InClass']); Text = $text }
    }
    return @{ Receiver = $receiver; Ambiguous = $ambiguous; Diagnostics = $diagnostics.ToArray() }
}

function Get-DocsPythonDefinitionHeader {
    <#
    .SYNOPSIS
        Reads the def or class header at logical line Index, or returns $null.
    .DESCRIPTION
        Returns @{ Kind (def, async def, class); Name; NameNonAscii; Decorator (preceding
        contiguous '@' lines at the same indent, each with Index, StartLine, EndLine, Tokens,
        Callee, Call and IsCall); HeaderStart (topmost decorator line, else the def line);
        DefLine; HeaderEnd (line of the ':' ending the header); Parameter (Name, NonAscii, Kind,
        StartLine, EndLine, AnnotationTokens, DefaultTokens, HasDefault); Base (class bases) }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line, [Parameter(Mandatory = $true)] [int] $Index)

    $tokens = $Line[$Index]['Tokens']
    $cursor = 0
    $kind = ''
    if ($tokens.Count -gt 1 -and $tokens[0]['Text'] -ceq 'async' -and $tokens[1]['Text'] -ceq 'def') { $kind = 'async def'; $cursor = 1 }
    elseif ($tokens.Count -gt 0 -and $tokens[0]['Type'] -ceq 'NAME' -and $tokens[0]['IsKeyword'] -and ($tokens[0]['Text'] -ceq 'def' -or $tokens[0]['Text'] -ceq 'class')) { $kind = $tokens[0]['Text'] }
    else { return $null }
    if ($cursor + 1 -ge $tokens.Count -or $tokens[$cursor + 1]['Type'] -cne 'NAME') { return $null }
    $nameToken = $tokens[$cursor + 1]
    $headerEnd = -1
    $open = -1
    $close = -1
    for ($position = $cursor + 2; $position -lt $tokens.Count; $position++) {
        $token = $tokens[$position]
        if ($token['Type'] -cne 'OP') { continue }
        if ($token['Text'] -ceq '(' -and $token['Level'] -eq 0 -and $open -lt 0) { $open = $position }
        elseif ($token['Text'] -ceq ')' -and $token['Level'] -eq 0 -and $open -ge 0 -and $close -lt 0) { $close = $position }
        elseif ($token['Text'] -ceq ':' -and $token['Level'] -eq 0) { $headerEnd = $position; break }
    }
    if ($headerEnd -lt 0) { return $null }
    $decorators = [System.Collections.Generic.List[object]]::new()
    for ($back = $Index - 1; $back -ge 0; $back--) {
        $candidate = $Line[$back]
        $first = $candidate['Tokens'][0]
        if ($candidate['Indent'] -ne $Line[$Index]['Indent'] -or $first['Type'] -cne 'OP' -or $first['Text'] -cne '@') { break }
        $call = Read-DocsPythonCall -Token $candidate['Tokens'] -Index 1
        $chain = Read-DocsPythonDottedChain -Token $candidate['Tokens'] -Index 1
        $decorators.Insert(0, @{ Index = $back; StartLine = $candidate['StartLine']; EndLine = $candidate['EndLine']; Tokens = $candidate['Tokens']; Callee = $(if ($null -ne $chain) { $chain['Text'] } else { $null }); Call = $call; IsCall = ($null -ne $call) })
    }
    $parameters = [System.Collections.Generic.List[object]]::new()
    if ($open -ge 0 -and $close -gt $open) {
        foreach ($piece in (Split-DocsPythonTokenList -Token $tokens -Start ($open + 1) -End $close -Level 1)) {
            $position = 0
            $parameterKind = 'normal'
            if ($piece[0]['Type'] -ceq 'OP' -and $piece[0]['Text'] -cin @('*', '**', '/')) {
                $parameterKind = switch ($piece[0]['Text']) { '*' { 'star' } '**' { 'starstar' } default { 'slash' } }
                $position = 1
            }
            if ($position -ge $piece.Count -or $piece[$position]['Type'] -cne 'NAME') {
                if ($parameterKind -cne 'normal') { $parameters.Add(@{ Name = $null; Kind = $parameterKind; NonAscii = $false; StartLine = $piece[0]['Line']; EndLine = $piece[$piece.Count - 1]['EndLine']; AnnotationTokens = @(); DefaultTokens = @(); HasDefault = $false }) }
                continue
            }
            $parameterName = $piece[$position]
            $annotation = [System.Collections.Generic.List[object]]::new()
            $default = [System.Collections.Generic.List[object]]::new()
            $target = $null
            for ($scan = $position + 1; $scan -lt $piece.Count; $scan++) {
                $token = $piece[$scan]
                if ($null -eq $target -and $token['Type'] -ceq 'OP' -and $token['Text'] -ceq ':' -and $token['Level'] -eq 1) { $target = $annotation; continue }
                if ($token['Type'] -ceq 'OP' -and $token['Text'] -ceq '=' -and $token['Level'] -eq 1) { $target = $default; continue }
                if ($null -ne $target) { $target.Add($token) }
            }
            $parameters.Add(@{ Name = $parameterName['Text']; Kind = $parameterKind; NonAscii = ($parameterName['Text'] -cmatch '[^\x00-\x7F]'); StartLine = $parameterName['Line']; EndLine = $piece[$piece.Count - 1]['EndLine']; AnnotationTokens = $annotation.ToArray(); DefaultTokens = $default.ToArray(); HasDefault = ($default.Count -gt 0) })
        }
    }
    return @{
        Kind         = $kind
        Name         = $nameToken['Text']
        NameNonAscii = ($nameToken['Text'] -cmatch '[^\x00-\x7F]')
        Decorator    = $decorators.ToArray()
        HeaderStart  = $(if ($decorators.Count -gt 0) { $decorators[0]['StartLine'] } else { $Line[$Index]['StartLine'] })
        DefLine      = $Line[$Index]['StartLine']
        HeaderEnd    = $tokens[$headerEnd]['EndLine']
        Parameter    = $parameters.ToArray()
        Base         = $(if ($kind -ceq 'class' -and $open -ge 0 -and $close -gt $open + 1) { $tokens[($open + 1)..($close - 1)] } else { @() })
    }
}

function Resolve-DocsPythonQualifiedName {
    <#
    .SYNOPSIS
        Resolves a dotted name through the import alias table and returns its qualified form.
    .DESCRIPTION
        The first segment is looked up in Import.Alias; when bound, the alias Full value replaces
        it (a relative Full keeps its leading dots). An unbound first segment is returned with its
        remaining segments unchanged. An ambiguous first segment (PYTHON_BINDING_AMBIGUOUS)
        returns $null, so a site on that name resolves to nothing.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Name,
        [Parameter(Mandatory = $true)] [hashtable] $Import
    )

    if ($Name.Length -eq 0) { return $Name }
    $parts = $Name.Split('.')
    if ($Import['Ambiguous'].Contains($parts[0])) { return $null }
    $target = $null
    if (-not $Import['Alias'].TryGetValue($parts[0], [ref] $target)) { return $Name }
    $rest = if ($parts.Count -gt 1) { '.' + ($parts[1..($parts.Count - 1)] -join '.') } else { '' }
    return ([string] $target['Full']) + $rest
}

function Get-DocsPythonFrontEnd {
    <#
    .SYNOPSIS
        Runs the shared Python front-end over one input text: lexer, logical lines, import table and receiver table.
    .DESCRIPTION
        Returns @{ Lines; Import; Receiver; Diagnostics; Blocked }. Diagnostics collects the
        lexer, indentation, import-table and receiver-table records (Code, Severity, Blocking,
        Line) in that order; Blocked is $true when any record is blocking, in which case Import
        and Receiver are $null and the analyzer emits no element for the file. Every analyzer
        reports these diagnostics under its own identifier.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $lexed = Get-DocsPythonToken -Text $(if ($null -eq $Text) { '' } else { $Text })
    foreach ($record in $lexed['Diagnostics']) { $diagnostics.Add($record) }
    if ($diagnostics.Count -gt 0) { return @{ Lines = [object[]]@(); Import = $null; Receiver = $null; Diagnostics = $diagnostics.ToArray(); Blocked = $true } }
    $grouped = Get-DocsPythonLogicalLine -Token $lexed['Tokens']
    foreach ($record in $grouped['Diagnostics']) { $diagnostics.Add($record) }
    if ($diagnostics.Count -gt 0) { return @{ Lines = $grouped['Lines']; Import = $null; Receiver = $null; Diagnostics = $diagnostics.ToArray(); Blocked = $true } }
    $import = Get-DocsPythonImportTable -Line $grouped['Lines']
    $receiver = Get-DocsPythonReceiverTable -Line $grouped['Lines']
    foreach ($record in $import['Diagnostics']) { $diagnostics.Add($record) }
    foreach ($record in $receiver['Diagnostics']) { $diagnostics.Add($record) }
    return @{ Lines = $grouped['Lines']; Import = $import; Receiver = $receiver; Diagnostics = $diagnostics.ToArray(); Blocked = $false }
}

Export-ModuleMember -Function `
    Get-DocsPythonImportTable, `
    Get-DocsPythonReceiverTable, `
    Get-DocsPythonDefinitionHeader, `
    Resolve-DocsPythonQualifiedName, `
    Get-DocsPythonFrontEnd
