<#
.SYNOPSIS
    The python-public-api analyzer of issue #1022: literal __all__ forms, the top-level naming
    rule and public-symbol elements.

.DESCRIPTION
    Invoke-DocsAnalyzerPythonApi -CapturedInput -Selection returns @{ Elements; Diagnostics }
    (1020 analyzer contract). The module qualified name comes from the path relative to its
    source root (__init__.py uses the package name); a module with a segment that is not a
    Python identifier is PUBLIC_API_MODULE_NOT_IMPORTABLE, and a module with a segment beginning
    with '_' yields nothing. Get-DocsPublicApiAllName reads the literal __all__ forms at
    indentation 0 in statement order (assignment, annotated assignment, +=, extend, append) and
    marks any other form dynamic. Get-DocsPublicApiBinding applies the naming rule over
    top-level definitions and targets (def, async def, class, simple or chained NAME =,
    NAME: T = and NAME: T, including top-level if, try, except, else and finally bodies, with
    imported names recorded as symbol_kind import). With a literal __all__ the elements are its
    names (basis all; a name without a binding is kept with symbol_kind unresolved and
    PUBLIC_API_NAME_UNRESOLVED; a top-level star import is PUBLIC_API_STAR_IMPORT); otherwise
    the naming rule applies (basis naming; PUBLIC_API_DYNAMIC_ALL when __all__ is dynamic).
    Every element is built through 1020 New-DocsSurfaceElement -SourceText -LineRange by
    Select-DocsUniqueElement; this module computes no digest.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonBindings.psm1') -ErrorAction Stop

$script:DocsApiAnalyzerId = 'python-public-api'
$script:DocsApiIdentifierPattern = '^[\p{L}\p{Nl}_][\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}]*$(?![\s\S])'

function Read-DocsApiLiteralList {
    <#
    .SYNOPSIS
        Reads a bracketed list or tuple of literal strings from Token[Start..End), or returns $null (private helper).
    .DESCRIPTION
        Returns @{ Items (name records with Name, Line, EndLine) } when the slice is one '[' or
        '(' group closing at End - 1 whose comma-separated pieces are all literal strings.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [int] $Start, [int] $End)

    if ($End - $Start -lt 2) { return $null }
    $open = $Token[$Start]
    $close = $Token[$End - 1]
    if ($open['Type'] -cne 'OP' -or $close['Type'] -cne 'OP' -or $open['Level'] -ne $close['Level']) { return $null }
    if (-not (($open['Text'] -ceq '[' -and $close['Text'] -ceq ']') -or ($open['Text'] -ceq '(' -and $close['Text'] -ceq ')'))) { return $null }
    $items = [System.Collections.Generic.List[object]]::new()
    foreach ($piece in (Split-DocsPythonTokenList -Token $Token -Start ($Start + 1) -End ($End - 1) -Level ($open['Level'] + 1))) {
        $value = ConvertFrom-DocsPythonStringToken -Token $piece
        if ($null -eq $value) { return $null }
        $items.Add(@{ Name = $value; Line = $piece[0]['Line']; EndLine = $piece[$piece.Count - 1]['EndLine'] })
    }
    return @{ Items = $items.ToArray() }
}

function Get-DocsPublicApiAllName {
    <#
    .SYNOPSIS
        Returns @{ Found; Dynamic; Name; Site } from the literal __all__ forms of one input.
    .DESCRIPTION
        Found is $true when any __all__ statement exists. The forms read, at indentation 0 and
        in statement order, are __all__ = [...] or (...), __all__: T = [...], __all__ += [...],
        __all__.extend([...]) and __all__.append("x"), each over plain strings. Any other form
        (concatenation, comprehension, list(...), star-unpacking, a non-literal element, or a
        statement at indentation above 0) sets Dynamic. Name is the final list in order with
        duplicates removed; Site maps each name to the Line and EndLine of its first string.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line)

    $found = $false
    $dynamic = $false
    $names = [System.Collections.Generic.List[string]]::new()
    $sites = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($logical in $Line) {
        $tokens = $logical['Tokens']
        if ($tokens[0]['Type'] -cne 'NAME' -or $tokens[0]['Text'] -cne '__all__' -or $tokens.Count -lt 3) { continue }
        $found = $true
        if ($logical['Indent'] -ne 0) { $dynamic = $true; continue }
        $second = $tokens[1]
        $items = $null
        $replace = $false
        if ($second['Type'] -ceq 'OP' -and ($second['Text'] -ceq '=' -or $second['Text'] -ceq '+=')) {
            $replace = $second['Text'] -ceq '='
            $items = Read-DocsApiLiteralList -Token $tokens -Start 2 -End $tokens.Count
        } elseif ($second['Type'] -ceq 'OP' -and $second['Text'] -ceq ':') {
            $assign = -1
            for ($cursor = 2; $cursor -lt $tokens.Count; $cursor++) { if ($tokens[$cursor]['Type'] -ceq 'OP' -and $tokens[$cursor]['Text'] -ceq '=' -and $tokens[$cursor]['Level'] -eq 0) { $assign = $cursor; break } }
            if ($assign -gt 0) { $replace = $true; $items = Read-DocsApiLiteralList -Token $tokens -Start ($assign + 1) -End $tokens.Count }
        } elseif ($second['Type'] -ceq 'OP' -and $second['Text'] -ceq '.' -and $tokens.Count -ge 5 -and $tokens[2]['Type'] -ceq 'NAME' -and $tokens[3]['Text'] -ceq '(' -and $tokens[$tokens.Count - 1]['Text'] -ceq ')' -and $tokens[$tokens.Count - 1]['Level'] -eq 0) {
            if ($tokens[2]['Text'] -ceq 'extend') { $items = Read-DocsApiLiteralList -Token $tokens -Start 4 -End ($tokens.Count - 1) }
            elseif ($tokens[2]['Text'] -ceq 'append') {
                $value = ConvertFrom-DocsPythonStringToken -Token $tokens[4..($tokens.Count - 2)]
                if ($null -ne $value) { $items = @{ Items = @(@{ Name = $value; Line = $tokens[4]['Line']; EndLine = $tokens[$tokens.Count - 2]['EndLine'] }) } }
            }
        }
        if ($null -eq $items) { $dynamic = $true; continue }
        if ($replace) { $names.Clear(); $sites.Clear() }
        foreach ($item in $items['Items']) {
            if ($names.Contains($item['Name'])) { continue }
            $names.Add($item['Name'])
            $sites[$item['Name']] = @{ Line = $item['Line']; EndLine = $item['EndLine'] }
        }
    }
    return @{ Found = $found; Dynamic = $dynamic; Name = $names.ToArray(); Site = $sites }
}

function Get-DocsPublicApiBinding {
    <#
    .SYNOPSIS
        Returns @{ Binding; Diagnostics } for the top-level bindings of one input under the naming rule.
    .DESCRIPTION
        Binding maps a name (first binding by line, ordinal) to @{ Kind (function,
        async-function, class, variable, import); Span @(start, end); Line; Branch }. Top level
        means indentation 0 or a top-level if, elif, else, try, except or finally body. A def or
        class spans its header from the topmost decorator; an assignment or import spans its
        statement. Diagnostic records: PYTHON_IDENTIFIER_NON_ASCII (a non-ASCII def or class
        name, no binding), PUBLIC_API_CONDITIONAL_DEFINITION (a name bound again where either
        binding sits in a branch; the first is kept) and PUBLIC_API_UNPACKING_TARGET (a tuple or
        list target, no binding for its names).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line, [Parameter(Mandatory = $true)] [hashtable] $Import)

    $binding = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $importByIndex = [System.Collections.Generic.Dictionary[int, object]]::new()
    foreach ($statement in $Import['Statements']) { $importByIndex[[int] $statement['Index']] = $statement }
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $logical = $Line[$index]
        $tokens = $logical['Tokens']
        if ($tokens[0]['Type'] -ceq 'OP' -and $tokens[0]['Text'] -ceq '@') { continue }
        $block = Get-DocsPythonEnclosingBlock -Line $Line -Index $index
        if (-not $block['TopLevelOnly']) { continue }
        $inBranch = $block['Kinds'].Count -gt 0
        $candidates = [System.Collections.Generic.List[object]]::new()
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header) {
            if ($header['NameNonAscii']) { $diagnostics.Add(@{ Code = 'PYTHON_IDENTIFIER_NON_ASCII'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }); continue }
            $kind = switch ($header['Kind']) { 'def' { 'function' } 'async def' { 'async-function' } default { 'class' } }
            $candidates.Add(@{ Name = $header['Name']; Kind = $kind; Span = @($header['HeaderStart'], $header['HeaderEnd']); Line = $header['HeaderStart'] })
        } elseif ($importByIndex.ContainsKey($index)) {
            $statement = $importByIndex[$index]
            if (-not $statement['Star']) {
                foreach ($entry in $statement['Names']) {
                    $name = if ($null -ne $entry['Alias']) { [string] $entry['Alias'] } elseif ($statement['Kind'] -ceq 'from') { [string] $entry['Name'] } else { ([string] $entry['Name']).Split('.')[0] }
                    $candidates.Add(@{ Name = $name; Kind = 'import'; Span = @($logical['StartLine'], $logical['EndLine']); Line = $logical['StartLine'] })
                }
            }
        } else {
            $assign = [System.Collections.Generic.List[int]]::new()
            for ($cursor = 0; $cursor -lt $tokens.Count; $cursor++) { if ($tokens[$cursor]['Type'] -ceq 'OP' -and $tokens[$cursor]['Text'] -ceq '=' -and $tokens[$cursor]['Level'] -eq 0) { $assign.Add($cursor) } }
            $annotated = $tokens.Count -ge 3 -and $tokens[0]['Type'] -ceq 'NAME' -and -not $tokens[0]['IsKeyword'] -and $tokens[1]['Type'] -ceq 'OP' -and $tokens[1]['Text'] -ceq ':'
            if ($annotated) {
                if ($tokens[0]['Text'] -cne '__all__') { $candidates.Add(@{ Name = $tokens[0]['Text']; Kind = 'variable'; Span = @($logical['StartLine'], $logical['EndLine']); Line = $logical['StartLine'] }) }
            } elseif ($assign.Count -gt 0) {
                $start = 0
                foreach ($position in $assign) {
                    $target = @($tokens[$start..($position - 1)])
                    $start = $position + 1
                    $isUnpacking = ($target.Count -gt 1 -and ($target[0]['Text'] -cin @('(', '[') -or (@($target | Where-Object { $_['Type'] -ceq 'OP' -and $_['Text'] -ceq ',' -and $_['Level'] -eq 0 }).Count -gt 0)))
                    if ($isUnpacking) { $diagnostics.Add(@{ Code = 'PUBLIC_API_UNPACKING_TARGET'; Severity = 'warning'; Blocking = $false; Line = $logical['StartLine'] }); continue }
                    if ($target.Count -ne 1 -or $target[0]['Type'] -cne 'NAME' -or $target[0]['IsKeyword'] -or $target[0]['Text'] -ceq '__all__') { break }
                    $candidates.Add(@{ Name = $target[0]['Text']; Kind = 'variable'; Span = @($logical['StartLine'], $logical['EndLine']); Line = $logical['StartLine'] })
                }
            }
        }
        foreach ($candidate in $candidates) {
            $name = [string] $candidate['Name']
            if ($binding.Contains($name)) {
                if ($inBranch -or $binding[$name]['Branch']) { $diagnostics.Add(@{ Code = 'PUBLIC_API_CONDITIONAL_DEFINITION'; Severity = 'warning'; Blocking = $false; Line = $candidate['Line'] }) }
                continue
            }
            $binding[$name] = @{ Kind = $candidate['Kind']; Span = $candidate['Span']; Line = $candidate['Line']; Branch = $inBranch }
        }
    }
    return @{ Binding = $binding; Diagnostics = $diagnostics.ToArray() }
}

function Invoke-DocsAnalyzerPythonApi {
    <#
    .SYNOPSIS
        Runs the python-public-api scanner over the captured inputs and returns @{ Elements; Diagnostics }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection
    )

    $sourceRoots = [string[]]@('.')
    if ($Selection -is [System.Collections.IDictionary] -and $Selection.Contains('source_roots') -and $null -ne $Selection['source_roots']) { $sourceRoots = [string[]]@($Selection['source_roots']) }
    $aggregate = New-DocsDiagnosticAggregate
    [object[]] $inputs = @($CapturedInput | Where-Object { $null -ne $_ -and $null -ne $_['text'] -and ([string] $_['path']).EndsWith('.py', [System.StringComparison]::Ordinal) })
    [string[]] $inputKeys = @($inputs | ForEach-Object { [string] $_['path'] })
    [Array]::Sort($inputKeys, $inputs, [System.StringComparer]::Ordinal)
    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        $text = [string] $captured['text']
        $frontEnd = Get-DocsPythonFrontEnd -Text $text
        foreach ($entry in $frontEnd['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        if ($frontEnd['Blocked']) { continue }
        $module = Get-DocsModuleDottedName -Path $path -SourceRoot $sourceRoots
        if ($null -eq $module) { continue }
        $segments = $module.Split('.')
        if (@($segments | Where-Object { $_ -cnotmatch $script:DocsApiIdentifierPattern }).Count -gt 0) {
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code 'PUBLIC_API_MODULE_NOT_IMPORTABLE' -Path $path -Line 1 -Severity 'warning'
            continue
        }
        if (@($segments | Where-Object { $_.StartsWith('_', [System.StringComparison]::Ordinal) }).Count -gt 0) { continue }
        $all = Get-DocsPublicApiAllName -Line $frontEnd['Lines']
        $bound = Get-DocsPublicApiBinding -Line $frontEnd['Lines'] -Import $frontEnd['Import']
        foreach ($entry in $bound['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        $symbols = [System.Collections.Generic.List[object]]::new()
        if ($all['Found'] -and -not $all['Dynamic']) {
            foreach ($statement in $frontEnd['Import']['Statements']) {
                if ($statement['Star'] -and [int] $statement['Indent'] -eq 0) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code 'PUBLIC_API_STAR_IMPORT' -Path $path -Line ([int] $statement['Line']) -Severity 'warning' }
            }
            foreach ($name in $all['Name']) {
                if ($bound['Binding'].Contains($name)) {
                    $record = $bound['Binding'][$name]
                    $symbols.Add(@{ Name = $name; Kind = $record['Kind']; Span = $record['Span']; Line = $record['Line']; Basis = 'all' })
                } else {
                    $site = $all['Site'][$name]
                    Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code 'PUBLIC_API_NAME_UNRESOLVED' -Path $path -Line ([int] $site['Line']) -Severity 'warning'
                    $symbols.Add(@{ Name = $name; Kind = 'unresolved'; Span = @($site['Line'], $site['EndLine']); Line = $site['Line']; Basis = 'all' })
                }
            }
        } else {
            if ($all['Found']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsApiAnalyzerId -Code 'PUBLIC_API_DYNAMIC_ALL' -Path $path -Line 1 -Severity 'warning' }
            foreach ($name in $bound['Binding'].Keys) {
                $record = $bound['Binding'][$name]
                if (([string] $name).StartsWith('_', [System.StringComparison]::Ordinal) -or $record['Kind'] -ceq 'import') { continue }
                $symbols.Add(@{ Name = [string] $name; Kind = $record['Kind']; Span = $record['Span']; Line = $record['Line']; Basis = 'naming' })
            }
        }
        foreach ($symbol in $symbols) {
            $candidates.Add(@{
                    Line      = [int] $symbol['Line']
                    Parameter = @{
                        Kind           = 'public-symbol'
                        Path           = $path
                        Declaration    = $module + '.' + $symbol['Name']
                        Name           = $symbol['Name']
                        AnalyzerId     = $script:DocsApiAnalyzerId
                        AnalysisMethod = 'scanner'
                        SourceText     = $text
                        ParentId       = $null
                        LineRange      = (ConvertTo-DocsLineRange -Span @(, $symbol['Span']))
                        Property       = @{ basis = $symbol['Basis']; symbol_kind = $symbol['Kind'] }
                    }
                })
        }
    }
    $elements = Select-DocsUniqueElement -Candidate $candidates.ToArray() -Aggregate $aggregate
    return @{ Elements = [object[]]@($elements); Diagnostics = [object[]]@($aggregate.Diagnostics) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerPythonApi, Get-DocsPublicApiAllName, Get-DocsPublicApiBinding
