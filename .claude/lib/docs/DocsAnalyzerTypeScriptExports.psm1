<#
.SYNOPSIS
    typescript-exports scanner: exported symbols of TypeScript modules, emitted as
    public-symbol elements qualified by the module path.

.DESCRIPTION
    Invoke-DocsAnalyzerTypeScriptExports selects *.ts, *.tsx, *.mts and *.cts inputs
    (declaration files included; .tsx tokenized with the JSX state) and classifies every
    export statement at module level and inside exported namespaces: functions (async,
    generator; overload signatures merged into one element with overloads), classes (abstract),
    variables with simple declarators and simple destructuring, interfaces, type aliases, enums
    (const), namespaces (nested names N.f), default exports (name default, local_name),
    export { a, b as c } resolved against the file's local declarations, export type { },
    export { x } from and export * as ns from (reexport_from), and export * from a captured
    relative module expanded with a visited set and depth bound 16. The declaration is the
    module path from Get-DocsScannerModulePath (Selection.source_roots optional), '.', and the
    export name. Elements are built only through New-DocsSurfaceElement -AnalysisMethod scanner
    -SourceText; the digest is never computed here. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of this scanner's precision limit
    (TS_REEXPORT_UNRESOLVED, TS_EXPORT_PATTERN_UNSUPPORTED, TS_EXPORT_ASSIGNMENT,
    TS_AMBIENT_MODULE, TS_COMMONJS_EXPORT).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsExportsAnalyzerId = 'typescript-exports'
$script:DocsExportsReexportDepth = 16

function Add-DocsExportsRecord {
    <#
    .SYNOPSIS
        Adds one export record, merging a repeated function name into one record with its signature count (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [AllowNull()] [string] $LocalName,
        [bool] $TypeOnly = $false,
        [AllowNull()] [string] $ReexportFrom,
        [AllowNull()] [string] $ExportForm,
        [bool] $IsSignature = $false
    )

    $isFunction = @('function', 'async-function', 'generator') -ccontains $Kind
    if ($isFunction) {
        foreach ($existing in $State['Record']) {
            if ([string] $existing['Name'] -ceq $Name -and @('function', 'async-function', 'generator') -ccontains [string] $existing['Kind']) {
                $existing['Count'] = [int] $existing['Count'] + 1
                if ($IsSignature) { $existing['Signatures'] = [int] $existing['Signatures'] + 1 }
                return
            }
        }
    }
    $State['Record'].Add(@{ Name = $Name; Kind = $Kind; Line = $Line; EndLine = $EndLine; LocalName = $LocalName; TypeOnly = $TypeOnly; ReexportFrom = $ReexportFrom; ExportForm = $ExportForm; Count = 1; Signatures = $(if ($IsSignature) { 1 } else { 0 }) })
}

function Get-DocsExportsBodyIndex {
    <#
    .SYNOPSIS
        Returns the index of the first '{' or ';' at the depth of token Index within End, else End (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $depth = [int] $Tokens[$Index]['Depth']
    for ($cursor = $Index; $cursor -le $End; $cursor++) {
        if ([int] $Tokens[$cursor]['Depth'] -eq $depth -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('{', ';'))) { return $cursor }
    }
    return $End
}

function Get-DocsExportsConstructEndLine {
    <#
    .SYNOPSIS
        Returns the last line of a whole construct: the matching '}' of its first block at the start depth, else the statement end (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $body = Get-DocsExportsBodyIndex -Tokens $Tokens -Index $Index -End $End
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $body -Kind 'punct' -Text @('{')) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $body
        if ($close -ge 0) { return [int] $Tokens[$close]['Line'] }
    }
    return [int] $Tokens[$End]['EndLine']
}

function Add-DocsExportsDeclarator {
    <#
    .SYNOPSIS
        Adds the variable names of an exported const, let or var statement; a pattern with a default, rest or nested pattern is TS_EXPORT_PATTERN_UNSUPPORTED (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [int] $End,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Prefix,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [int] $Line
    )

    $tokens = $State['Tokens']
    $depth = [int] $tokens[$Start]['Depth']
    $cursor = $Start
    while ($cursor -le $End) {
        $declaratorEnd = $End
        for ($scan = $cursor; $scan -le $End; $scan++) {
            if ([int] $tokens[$scan]['Depth'] -eq $depth -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $scan -Kind 'punct' -Text @(',', ';'))) { $declaratorEnd = $scan - 1; break }
        }
        $endLine = [int] $tokens[$declaratorEnd]['EndLine']
        for ($scan = $cursor; $scan -le $declaratorEnd; $scan++) {
            if ([int] $tokens[$scan]['Depth'] -eq $depth -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $scan -Kind 'punct' -Text @('=')) -and $scan -lt $declaratorEnd) { $endLine = [int] $tokens[$scan + 1]['Line']; break }
        }
        [string[]] $names = @()
        $unsupported = $false
        if (Test-DocsTypeScriptName -Tokens $tokens -Index $cursor) { $names = @([string] $tokens[$cursor]['Text']) }
        elseif (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('{')) {
            $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex $cursor
            foreach ($member in $members) {
                if ($member['Computed'] -or $member['Spread'] -or $null -eq $member['Key']) { $unsupported = $true; continue }
                if ([int] $member['ValueStart'] -eq [int] $member['KeyIndex']) { $names += [string] $member['Key']; continue }
                if ((Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $member['KeyIndex'] + 1) -Kind 'punct' -Text @(':')) -and [int] $member['ValueStart'] -eq [int] $member['ValueEnd'] -and (Test-DocsTypeScriptName -Tokens $tokens -Index ([int] $member['ValueStart']))) { $names += [string] $tokens[[int] $member['ValueStart']]['Text']; continue }
                $unsupported = $true
            }
        } elseif (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('[')) {
            [object[]] $elements = Get-DocsScannerCallArgument -Tokens $tokens -OpenIndex $cursor
            foreach ($element in $elements) {
                if ([int] $element['Start'] -eq [int] $element['End'] -and (Test-DocsTypeScriptName -Tokens $tokens -Index ([int] $element['Start']))) { $names += [string] $tokens[[int] $element['Start']]['Text'] } else { $unsupported = $true }
            }
        }
        if ($unsupported) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'TS_EXPORT_PATTERN_UNSUPPORTED' -Path $State['Path'] -Line ([int] $tokens[$cursor]['Line']) }
        else { foreach ($name in $names) { Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind $Kind -Line $Line -EndLine $endLine } }
        $cursor = $declaratorEnd + 2
    }
}

function Add-DocsExportsStatement {
    <#
    .SYNOPSIS
        Classifies one export statement starting at the 'export' token at Index (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Prefix,
        [Parameter(Mandatory = $true)] [int] $Line
    )

    $tokens = $State['Tokens']
    $path = [string] $State['Path']
    $set = $State['Set']
    $endLine = [int] $tokens[$End]['EndLine']
    $cursor = $Index + 1
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('=')) {
        Add-DocsScannerDiagnostic -Set $set -Code 'TS_EXPORT_ASSIGNMENT' -Path $path -Line $Line
        $local = if ((Test-DocsTypeScriptName -Tokens $tokens -Index ($cursor + 1)) -and ($cursor + 1 -eq $End -or (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 2) -Kind 'punct' -Text @(';')))) { [string] $tokens[$cursor + 1]['Text'] } else { $null }
        Add-DocsExportsRecord -State $State -Name ($Prefix + 'default') -Kind 'variable' -Line $Line -EndLine $endLine -LocalName $local -ExportForm 'assignment'
        return
    }
    $isDefault = $false
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('default')) { $isDefault = $true; $cursor++ }
    $typeOnlyClause = $false
    if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('type')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'punct' -Text @('{', '*'))) { $typeOnlyClause = $true; $cursor++ }
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('{')) {
        $close = Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex $cursor
        [object[]] $pairs = Get-DocsTypeScriptBindingList -Tokens $tokens -OpenIndex $cursor
        $from = if ((Test-DocsTypeScriptToken -Tokens $tokens -Index ($close + 1) -Kind 'identifier' -Text @('from')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($close + 2) -Kind 'string')) { [string] $tokens[$close + 2]['Value'] } else { $null }
        foreach ($pair in $pairs) {
            $exported = [string] $pair['Local']
            $local = [string] $pair['Imported']
            $typeOnly = $typeOnlyClause -or [bool] $pair['TypeOnly']
            if ($null -ne $from) { Add-DocsExportsRecord -State $State -Name ($Prefix + $exported) -Kind 'reexport' -Line $Line -EndLine $endLine -LocalName $(if ($local -cne $exported) { $local } else { $null }) -TypeOnly $typeOnly -ReexportFrom $from; continue }
            $kind = if ($State['Local'].ContainsKey($local)) { [string] $State['Local'][$local] } elseif ($typeOnly) { 'type' } else { 'variable' }
            Add-DocsExportsRecord -State $State -Name ($Prefix + $exported) -Kind $kind -Line $Line -EndLine $endLine -LocalName $(if ($local -cne $exported) { $local } else { $null }) -TypeOnly $typeOnly
        }
        return
    }
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('*')) {
        $specifierIndex = $cursor + 2
        $alias = $null
        if ((Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'identifier' -Text @('as')) -and (Test-DocsTypeScriptName -Tokens $tokens -Index ($cursor + 2))) { $alias = [string] $tokens[$cursor + 2]['Text']; $specifierIndex = $cursor + 4 }
        if (-not (Test-DocsTypeScriptToken -Tokens $tokens -Index ($specifierIndex - 1) -Kind 'identifier' -Text @('from')) -or -not (Test-DocsTypeScriptToken -Tokens $tokens -Index $specifierIndex -Kind 'string')) { return }
        $specifier = [string] $tokens[$specifierIndex]['Value']
        if ($null -ne $alias) { Add-DocsExportsRecord -State $State -Name ($Prefix + $alias) -Kind 'reexport' -Line $Line -EndLine $endLine -TypeOnly $typeOnlyClause -ReexportFrom $specifier }
        else { $State['Star'].Add(@{ Specifier = $specifier; Prefix = $Prefix; Line = $Line; EndLine = $endLine; TypeOnly = $typeOnlyClause }) }
        return
    }
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('declare')) { $cursor++ }
    $isAbstract = Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('abstract')
    if ($isAbstract) { $cursor++ }
    $isAsync = Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('async')
    if ($isAsync) { $cursor++ }
    $isConstEnum = (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('const')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'keyword' -Text @('enum'))
    if ($isConstEnum) { $cursor++ }
    $head = [string] $tokens[$cursor]['Text']
    $headKind = [string] $tokens[$cursor]['Kind']
    $nameIndex = $cursor + 1
    if ($head -ceq 'function' -and $headKind -ceq 'keyword') {
        $isGenerator = Test-DocsTypeScriptToken -Tokens $tokens -Index $nameIndex -Kind 'punct' -Text @('*')
        if ($isGenerator) { $nameIndex++ }
        $kind = if ($isGenerator) { 'generator' } elseif ($isAsync) { 'async-function' } else { 'function' }
        $local = if (Test-DocsTypeScriptName -Tokens $tokens -Index $nameIndex) { [string] $tokens[$nameIndex]['Text'] } else { $null }
        $name = if ($isDefault) { 'default' } else { $local }
        if ($null -eq $name) { return }
        $body = Get-DocsExportsBodyIndex -Tokens $tokens -Index $Index -End $End
        Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind $kind -Line $Line -EndLine ([int] $tokens[$body]['Line']) -LocalName $(if ($isDefault) { $local } else { $null }) -IsSignature (-not (Test-DocsTypeScriptToken -Tokens $tokens -Index $body -Kind 'punct' -Text @('{')))
        return
    }
    if ($head -ceq 'class' -and $headKind -ceq 'keyword') {
        $local = if (Test-DocsTypeScriptName -Tokens $tokens -Index $nameIndex) { [string] $tokens[$nameIndex]['Text'] } else { $null }
        $name = if ($isDefault) { 'default' } else { $local }
        if ($null -eq $name) { return }
        $body = Get-DocsExportsBodyIndex -Tokens $tokens -Index $Index -End $End
        Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind $(if ($isAbstract) { 'abstract-class' } else { 'class' }) -Line $Line -EndLine ([int] $tokens[$body]['Line']) -LocalName $(if ($isDefault) { $local } else { $null })
        return
    }
    if ($isDefault) {
        $local = if ((Test-DocsTypeScriptName -Tokens $tokens -Index $cursor) -and ($cursor -eq $End -or (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'punct' -Text @(';')))) { $head } else { $null }
        Add-DocsExportsRecord -State $State -Name ($Prefix + 'default') -Kind 'variable' -Line $Line -EndLine $endLine -LocalName $local
        return
    }
    if ($headKind -ceq 'keyword' -and @('const', 'let', 'var') -ccontains $head) { Add-DocsExportsDeclarator -State $State -Start $nameIndex -End $End -Prefix $Prefix -Kind 'variable' -Line $Line; return }
    if (-not (Test-DocsTypeScriptName -Tokens $tokens -Index $nameIndex)) { return }
    $name = [string] $tokens[$nameIndex]['Text']
    $wholeEnd = Get-DocsExportsConstructEndLine -Tokens $tokens -Index $Index -End $End
    if ($head -ceq 'interface' -and $headKind -ceq 'keyword') { Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind 'interface' -Line $Line -EndLine $wholeEnd; return }
    if ($head -ceq 'enum' -and $headKind -ceq 'keyword') { Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind 'enum' -Line $Line -EndLine $wholeEnd; return }
    if ($head -ceq 'type' -and $headKind -ceq 'identifier') { Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind 'type' -Line $Line -EndLine $wholeEnd; return }
    if (($head -ceq 'namespace' -or $head -ceq 'module') -and $headKind -ceq 'identifier') {
        Add-DocsExportsRecord -State $State -Name ($Prefix + $name) -Kind 'namespace' -Line $Line -EndLine $wholeEnd
        $body = Get-DocsExportsBodyIndex -Tokens $tokens -Index $Index -End $End
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $body -Kind 'punct' -Text @('{')) {
            $close = Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex $body
            if ($close -gt $body + 1) { Invoke-DocsExportsWalk -State $State -Start ($body + 1) -End ($close - 1) -Prefix ($Prefix + $name + '.') }
        }
    }
}

function Invoke-DocsExportsWalk {
    <#
    .SYNOPSIS
        Walks the statements of a token range at its depth: decorators, exports, ambient modules, CommonJS exports and local declarations (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [int] $End,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Prefix
    )

    $tokens = $State['Tokens']
    if ($Start -gt $End) { return }
    $depth = [int] $tokens[$Start]['Depth']
    $decoratorLine = -1
    $index = $Start
    while ($index -le $End) {
        if ([int] $tokens[$index]['Depth'] -ne $depth -or -not (Test-DocsTypeScriptStatementStart -Tokens $tokens -Index $index)) { $index++; continue }
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'punct' -Text @('@')) {
            if ($decoratorLine -lt 0) { $decoratorLine = [int] $tokens[$index]['Line'] }
            $index += 2
            while ((Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'punct' -Text @('.')) -and (Test-DocsTypeScriptName -Tokens $tokens -Index ($index + 1))) { $index += 2 }
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'punct' -Text @('(')) { $close = Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex $index; $index = $(if ($close -ge 0) { $close + 1 } else { $index + 1 }) }
            continue
        }
        $statementEnd = Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index $index
        if ($statementEnd -gt $End) { $statementEnd = $End }
        $line = if ($decoratorLine -ge 0) { $decoratorLine } else { [int] $tokens[$index]['Line'] }
        $decoratorLine = -1
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'keyword' -Text @('export')) {
            Add-DocsExportsStatement -State $State -Index $index -End $statementEnd -Prefix $Prefix -Line $line
        } elseif ((Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'identifier' -Text @('declare')) -and (((Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 1) -Kind 'identifier' -Text @('module')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 2) -Kind 'string')) -or (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 1) -Kind 'identifier' -Text @('global')))) {
            Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'TS_AMBIENT_MODULE' -Path $State['Path'] -Line $line
        } elseif (((Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'identifier' -Text @('module')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 1) -Kind 'punct' -Text @('.')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 2) -Kind 'identifier' -Text @('exports'))) -or ((Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'identifier' -Text @('exports')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 1) -Kind 'punct' -Text @('.')))) {
            Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'TS_COMMONJS_EXPORT' -Path $State['Path'] -Line $line
        } elseif ($depth -eq 0) {
            $cursor = $index
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('declare')) { $cursor++ }
            $isAbstract = Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('abstract')
            if ($isAbstract) { $cursor++ }
            $isAsync = Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('async')
            if ($isAsync) { $cursor++ }
            if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('const')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'keyword' -Text @('enum'))) { $cursor++ }
            $head = [string] $tokens[$cursor]['Text']
            $nameIndex = $cursor + 1
            $isGenerator = ($head -ceq 'function') -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $nameIndex -Kind 'punct' -Text @('*'))
            if ($isGenerator) { $nameIndex++ }
            $kind = switch ($head) {
                'function' { if ($isGenerator) { 'generator' } elseif ($isAsync) { 'async-function' } else { 'function' } }
                'class' { if ($isAbstract) { 'abstract-class' } else { 'class' } }
                'interface' { 'interface' }
                'enum' { 'enum' }
                'type' { 'type' }
                'namespace' { 'namespace' }
                'module' { 'namespace' }
                'const' { 'variable' }
                'let' { 'variable' }
                'var' { 'variable' }
                default { $null }
            }
            if ($null -ne $kind -and (Test-DocsTypeScriptName -Tokens $tokens -Index $nameIndex)) { $State['Local'][[string] $tokens[$nameIndex]['Text']] = $kind }
        }
        $index = $statementEnd + 1
    }
}

function Get-DocsExportsFileRecord {
    <#
    .SYNOPSIS
        Scans one tokenized file and returns @{ Record; Star } (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    $state = @{ Tokens = $Tokens; Path = $Path; Set = $Set; Record = [System.Collections.Generic.List[object]]::new(); Star = [System.Collections.Generic.List[object]]::new(); Local = [hashtable]::new([System.StringComparer]::Ordinal) }
    if ($Tokens.Count -gt 0) { Invoke-DocsExportsWalk -State $state -Start 0 -End ($Tokens.Count - 1) -Prefix '' }
    return @{ Record = $state['Record']; Star = $state['Star'] }
}

function Get-DocsExportsStarName {
    <#
    .SYNOPSIS
        Returns @{ Name; Failed } for a star re-export: the non-default export names reachable through captured relative modules, and whether any step was unresolvable, cyclic or deeper than the bound (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $File,
        [Parameter(Mandatory = $true)] [string] $FromPath,
        [Parameter(Mandatory = $true)] [string] $Specifier,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $CapturedPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visited,
        [Parameter(Mandatory = $true)] [int] $Depth
    )

    $names = [System.Collections.Generic.List[string]]::new()
    $resolved = Resolve-DocsTypeScriptRelativeModule -FromPath $FromPath -Specifier $Specifier -CapturedPath $CapturedPath
    if ($null -eq $resolved -or -not $File.ContainsKey($resolved) -or $Visited.Contains($resolved) -or $Depth -gt $script:DocsExportsReexportDepth) { return @{ Name = [string[]]@(); Failed = $true } }
    foreach ($record in $File[$resolved]['Record']) {
        $name = [string] $record['Name']
        if ($name -cne 'default' -and -not $name.Contains('.')) { $names.Add($name) }
    }
    $failed = $false
    $nextVisited = [System.Collections.Generic.HashSet[string]]::new($Visited, [System.StringComparer]::Ordinal)
    [void]$nextVisited.Add($resolved)
    foreach ($star in $File[$resolved]['Star']) {
        $inner = Get-DocsExportsStarName -File $File -FromPath $resolved -Specifier ([string] $star['Specifier']) -CapturedPath $CapturedPath -Visited $nextVisited -Depth ($Depth + 1)
        if ($inner['Failed']) { $failed = $true }
        foreach ($name in $inner['Name']) { if (-not $names.Contains($name)) { $names.Add($name) } }
    }
    return @{ Name = [string[]] $names.ToArray(); Failed = $failed }
}

function Invoke-DocsAnalyzerTypeScriptExports {
    <#
    .SYNOPSIS
        Scans the captured TypeScript inputs for exported symbols and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection.source_roots (optional) shortens the module path that qualifies each
        declaration. Every element is built by New-DocsSurfaceElement with -AnalysisMethod
        scanner and the captured text; diagnostics are aggregated per (code, path) and emitted
        through ConvertTo-DocsScannerDiagnostic under typescript-exports.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1033 registry row (Function Invoke-DocsAnalyzerTypeScriptExports for analyzer typescript-exports).')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $sourceRoots = $null
    if ($Selection -is [System.Collections.IDictionary] -and $Selection.Contains('source_roots')) { $sourceRoots = $Selection['source_roots'] }
    elseif ($null -ne $Selection -and $Selection -isnot [System.Collections.IDictionary] -and $null -ne $Selection.PSObject.Properties['source_roots']) { $sourceRoots = $Selection.PSObject.Properties['source_roots'].Value }
    [string[]] $roots = @($sourceRoots | ForEach-Object { [string] $_ })
    $set = New-DocsScannerDiagnosticSet
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.ts', '.tsx', '.mts', '.cts')
    [string[]] $capturedPath = @($selected | ForEach-Object { [string] $_['path'] })
    $file = [hashtable]::new([System.StringComparer]::Ordinal)
    $text = [hashtable]::new([System.StringComparer]::Ordinal)
    $order = [System.Collections.Generic.List[string]]::new()
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        if ($null -eq $captured['text']) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $lexed = ConvertTo-DocsTypeScriptToken -Text ([string] $captured['text']) -Jsx:($path.EndsWith('.tsx', [System.StringComparison]::OrdinalIgnoreCase))
        if ($lexed['Diagnostics'].Count -gt 0) {
            foreach ($diagnostic in $lexed['Diagnostics']) { Add-DocsScannerDiagnostic -Set $set -Code ([string] $diagnostic['Code']) -Path $path -Line ([int] $diagnostic['Line']) -Blocking $true }
            continue
        }
        $file[$path] = Get-DocsExportsFileRecord -Tokens $lexed['Tokens'] -Path $path -Set $set
        $text[$path] = [string] $captured['text']
        $order.Add($path)
    }
    $elements = [System.Collections.Generic.List[object]]::new()
    foreach ($path in $order) {
        $modulePath = Get-DocsScannerModulePath -Path $path -SourceRoot $roots
        $records = [System.Collections.Generic.List[object]]::new($file[$path]['Record'])
        foreach ($star in $file[$path]['Star']) {
            $visited = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            [void]$visited.Add($path)
            $expansion = Get-DocsExportsStarName -File $file -FromPath $path -Specifier ([string] $star['Specifier']) -CapturedPath $capturedPath -Visited $visited -Depth 1
            if ($expansion['Failed']) { Add-DocsScannerDiagnostic -Set $set -Code 'TS_REEXPORT_UNRESOLVED' -Path $path -Line ([int] $star['Line']) }
            foreach ($name in $expansion['Name']) { $records.Add(@{ Name = [string] $star['Prefix'] + $name; Kind = 'reexport'; Line = [int] $star['Line']; EndLine = [int] $star['EndLine']; LocalName = $null; TypeOnly = [bool] $star['TypeOnly']; ReexportFrom = [string] $star['Specifier']; ExportForm = $null; Count = 1; Signatures = 0 }) }
        }
        foreach ($record in $records) {
            $exportName = [string] $record['Name']
            $property = [ordered]@{ symbol_kind = [string] $record['Kind'] }
            if ([bool] $record['TypeOnly']) { $property['type_only'] = $true }
            if (-not [string]::IsNullOrEmpty([string] $record['LocalName'])) { $property['local_name'] = [string] $record['LocalName'] }
            if (-not [string]::IsNullOrEmpty([string] $record['ReexportFrom'])) { $property['reexport_from'] = [string] $record['ReexportFrom'] }
            if ([int] $record['Count'] -ge 2) { $property['overloads'] = [int] $record['Signatures'] }
            if (-not [string]::IsNullOrEmpty([string] $record['ExportForm'])) { $property['export_form'] = [string] $record['ExportForm'] }
            $name = $exportName.Substring($exportName.LastIndexOf('.') + 1)
            try {
                $elements.Add((New-DocsSurfaceElement -Kind 'public-symbol' -Path $path -Declaration ($modulePath + '.' + $exportName) -Name $name -AnalyzerId $script:DocsExportsAnalyzerId -AnalysisMethod 'scanner' -SourceText $text[$path] -LineRange @([int] $record['Line'], [int] $record['EndLine']) -Property $property))
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $record['Line']) }
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsExportsAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerTypeScriptExports
