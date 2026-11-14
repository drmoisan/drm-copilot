<#
.SYNOPSIS
    Shared pure syntax helpers over the C# token stream used by the dotnet-http and
    dotnet-public-api scanners: token predicates, attribute sections, modifiers, type text,
    parameter lists, type declarations, member-call chains, string lists, namespace ranges and
    parameter scopes.

.DESCRIPTION
    Every function reads the token records of ConvertTo-DocsCSharpToken and returns plain
    hashtables of token indices and spelled text. Type text is the source spelling with
    whitespace removed (Repository<T>, int[], (int, string)?), so overloads stay distinct
    without semantic analysis. Nothing here evaluates an expression: a construct that is not a
    literal or a literal-only container is reported as $null so that the calling scanner emits
    its precision-limit diagnostic. Every function is pure; inputs are not mutated.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from the .NET analyzer modules under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

$script:CsModifier = [string[]]@('public', 'private', 'protected', 'internal', 'static', 'abstract', 'sealed', 'virtual', 'override', 'readonly', 'partial', 'async', 'unsafe', 'extern', 'new', 'volatile', 'const', 'file', 'required', 'ref')
$script:CsTypeKeyword = [string[]]@('class', 'struct', 'interface', 'enum', 'record', 'delegate')

function Test-DocsCSharpToken {
    <#
    .SYNOPSIS
        Returns $true when the token at Index exists and has the given Kind (when set) and one of the given Text values (when set).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [AllowNull()] [AllowEmptyString()] [string] $Kind,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $Text
    )

    if ($Index -lt 0 -or $Index -ge $Tokens.Count) { return $false }
    $token = $Tokens[$Index]
    if (-not [string]::IsNullOrEmpty($Kind) -and [string] $token['Kind'] -cne $Kind) { return $false }
    if ($null -ne $Text -and $Text.Count -gt 0 -and $Text -cnotcontains [string] $token['Text']) { return $false }
    return $true
}

function Test-DocsCSharpName {
    <#
    .SYNOPSIS
        Returns $true when the token at Index is an identifier or a keyword (a name or type keyword).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    if ($Index -lt 0 -or $Index -ge $Tokens.Count) { return $false }
    $kind = [string] $Tokens[$Index]['Kind']
    return ($kind -ceq 'identifier' -or $kind -ceq 'keyword')
}

function Get-DocsCSharpAttributeSection {
    <#
    .SYNOPSIS
        Reads the consecutive '[...]' attribute sections starting at Index and returns @{ Attribute; EndIndex }.
    .DESCRIPTION
        Each attribute is @{ Name; Argument; Line; EndLine } where Name is the last segment of
        the dotted attribute name with an 'Attribute' suffix removed, Argument holds the
        top-level argument spans of its parenthesized list (empty without a list), and an
        attribute target such as 'return:' is skipped. EndIndex is the first token after the
        last section (Index when no section starts there).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $attributes = [System.Collections.Generic.List[object]]::new()
    $cursor = $Index
    while (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('[')) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $cursor
        if ($close -lt 0) { break }
        [object[]] $spans = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $cursor
        foreach ($span in $spans) {
            $start = [int] $span['Start']
            if ((Test-DocsCSharpName -Tokens $Tokens -Index $start) -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($start + 1) -Kind 'punct' -Text @(':'))) { $start += 2 }
            if (-not (Test-DocsCSharpName -Tokens $Tokens -Index $start)) { continue }
            $nameIndex = $start
            while ((Test-DocsCSharpToken -Tokens $Tokens -Index ($nameIndex + 1) -Kind 'punct' -Text @('.')) -and (Test-DocsCSharpName -Tokens $Tokens -Index ($nameIndex + 2))) { $nameIndex += 2 }
            $name = [string] $Tokens[$nameIndex]['Text']
            if ($name.EndsWith('Attribute') -and $name.Length -gt 9) { $name = $name.Substring(0, $name.Length - 9) }
            [object[]] $arguments = @()
            if ((Test-DocsCSharpToken -Tokens $Tokens -Index ($nameIndex + 1) -Kind 'punct' -Text @('(')) -and $nameIndex + 1 -le [int] $span['End']) { $arguments = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex ($nameIndex + 1) }
            $attributes.Add(@{ Name = $name; Argument = $arguments; Line = [int] $Tokens[$cursor]['Line']; EndLine = [int] $Tokens[$close]['Line'] })
        }
        $cursor = $close + 1
    }
    return @{ Attribute = [object[]] $attributes.ToArray(); EndIndex = $cursor }
}

function Get-DocsCSharpModifier {
    <#
    .SYNOPSIS
        Reads the declaration modifiers starting at Index and returns @{ Modifier; EndIndex }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $modifiers = [System.Collections.Generic.List[string]]::new()
    $cursor = $Index
    while ((Test-DocsCSharpName -Tokens $Tokens -Index $cursor) -and $script:CsModifier -ccontains [string] $Tokens[$cursor]['Text']) {
        $text = [string] $Tokens[$cursor]['Text']
        if ($text -ceq 'ref' -and -not (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'keyword' -Text @('struct', 'readonly', 'partial'))) { break }
        if ($text -ceq 'file' -and -not (Test-DocsCSharpName -Tokens $Tokens -Index ($cursor + 1))) { break }
        $modifiers.Add($text)
        $cursor++
    }
    return @{ Modifier = [string[]] $modifiers.ToArray(); EndIndex = $cursor }
}

function Get-DocsCSharpTypeText {
    <#
    .SYNOPSIS
        Reads one type expression starting at Index and returns @{ Text; EndIndex }, or $null when no type starts there.
    .DESCRIPTION
        Covers dotted and aliased names (global::, Ns.Type), generic argument lists, tuple
        types, array ranks, nullable '?' and pointer '*'. Text is the spelling with whitespace
        removed; EndIndex is the last token of the type.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $builder = [System.Text.StringBuilder]::new()
    $cursor = $Index
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('(')) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $cursor
        if ($close -lt 0) { return $null }
        for ($scan = $cursor; $scan -le $close; $scan++) { [void]$builder.Append([string] $Tokens[$scan]['Text']) }
        $cursor = $close
    } elseif (Test-DocsCSharpName -Tokens $Tokens -Index $cursor) {
        [void]$builder.Append([string] $Tokens[$cursor]['Text'])
        while ((Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('.', '::')) -and (Test-DocsCSharpName -Tokens $Tokens -Index ($cursor + 2))) {
            [void]$builder.Append([string] $Tokens[$cursor + 1]['Text']).Append([string] $Tokens[$cursor + 2]['Text'])
            $cursor += 2
        }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('<')) {
            $depth = 0
            for ($scan = $cursor + 1; $scan -lt $Tokens.Count; $scan++) {
                $text = [string] $Tokens[$scan]['Text']
                if ([string] $Tokens[$scan]['Kind'] -ceq 'punct' -and $text -ceq '<') { $depth++ }
                elseif ([string] $Tokens[$scan]['Kind'] -ceq 'punct' -and $text -ceq '>') { $depth-- }
                elseif ($depth -gt 0 -and [string] $Tokens[$scan]['Kind'] -ceq 'punct' -and @(';', '{', '}', '=').Contains($text)) { return $null }
                [void]$builder.Append($text)
                if ($depth -eq 0) { $cursor = $scan; break }
            }
            if ($depth -ne 0) { return $null }
        }
    } else { return $null }
    while ($true) {
        if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('?', '*')) { [void]$builder.Append([string] $Tokens[$cursor + 1]['Text']); $cursor++; continue }
        if ((Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('[')) -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 2) -Kind 'punct' -Text @(']', ','))) {
            $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($cursor + 1)
            if ($close -lt 0) { break }
            for ($scan = $cursor + 1; $scan -le $close; $scan++) { [void]$builder.Append([string] $Tokens[$scan]['Text']) }
            $cursor = $close
            continue
        }
        break
    }
    return @{ Text = $builder.ToString(); EndIndex = $cursor }
}

function Get-DocsCSharpParameterList {
    <#
    .SYNOPSIS
        Reads the parameter list opened at OpenIndex and returns @{ Parameter; CloseIndex }.
    .DESCRIPTION
        Each parameter is @{ Modifier; Type; Name } where Modifier is 'ref', 'out', 'in',
        'params', 'scoped' or 'this' (or $null), Type is the whitespace-free type text and
        Name the parameter identifier; attributes and default values are skipped. A parameter
        whose type cannot be read is returned with Type $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $OpenIndex
    )

    $parameters = [System.Collections.Generic.List[object]]::new()
    $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $OpenIndex
    if ($close -lt 0) { return @{ Parameter = [object[]]@(); CloseIndex = -1 } }
    [object[]] $spans = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $OpenIndex
    foreach ($span in $spans) {
        $cursor = (Get-DocsCSharpAttributeSection -Tokens $Tokens -Index ([int] $span['Start']))['EndIndex']
        $modifier = $null
        while ((Test-DocsCSharpName -Tokens $Tokens -Index $cursor) -and @('ref', 'out', 'in', 'params', 'scoped', 'this', 'readonly') -ccontains [string] $Tokens[$cursor]['Text'] -and $cursor -lt [int] $span['End']) {
            if (@('ref', 'out', 'in', 'params', 'this') -ccontains [string] $Tokens[$cursor]['Text']) { $modifier = [string] $Tokens[$cursor]['Text'] }
            $cursor++
        }
        $type = Get-DocsCSharpTypeText -Tokens $Tokens -Index $cursor
        $name = $null
        $typeText = $null
        if ($null -ne $type) {
            $typeText = [string] $type['Text']
            if ((Test-DocsCSharpName -Tokens $Tokens -Index ([int] $type['EndIndex'] + 1)) -and [int] $type['EndIndex'] + 1 -le [int] $span['End']) { $name = [string] $Tokens[[int] $type['EndIndex'] + 1]['Text'] }
            elseif ([int] $type['EndIndex'] -eq [int] $span['End'] -and (Test-DocsCSharpToken -Tokens $Tokens -Index ([int] $type['EndIndex']) -Kind 'identifier')) { $name = $typeText; $typeText = $null }
        }
        $parameters.Add(@{ Modifier = $modifier; Type = $typeText; Name = $name })
    }
    return @{ Parameter = [object[]] $parameters.ToArray(); CloseIndex = $close }
}

function Get-DocsCSharpTypeDeclaration {
    <#
    .SYNOPSIS
        Reads a type declaration head at Index (after attributes and modifiers) and returns its record, or $null.
    .DESCRIPTION
        The record is @{ Kind; Name; TypeParameter; Base; PositionalParameter; BodyOpen;
        BodyClose; HeaderEnd } where Kind is class, struct, interface, enum, record,
        record-struct or delegate, TypeParameter is the '<T, U>' spelling or '', Base is the
        list of base type texts, PositionalParameter is the primary-constructor parameter list
        (records), BodyOpen and BodyClose delimit the body (-1 for a delegate or a bodyless
        declaration) and HeaderEnd is the last header token before the body or ';'.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $cursor = $Index
    if (-not (Test-DocsCSharpName -Tokens $Tokens -Index $cursor) -or $script:CsTypeKeyword -cnotcontains [string] $Tokens[$cursor]['Text']) { return $null }
    $kind = [string] $Tokens[$cursor]['Text']
    $cursor++
    if ($kind -ceq 'record' -and (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'keyword' -Text @('class', 'struct'))) { if ([string] $Tokens[$cursor]['Text'] -ceq 'struct') { $kind = 'record-struct' }; $cursor++ }
    if ($kind -ceq 'delegate') {
        $returnType = Get-DocsCSharpTypeText -Tokens $Tokens -Index $cursor
        if ($null -eq $returnType) { return $null }
        $cursor = [int] $returnType['EndIndex'] + 1
    }
    if (-not (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'identifier')) { return $null }
    $name = [string] $Tokens[$cursor]['Text']
    $typeParameter = ''
    if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('<')) {
        $generic = Get-DocsCSharpTypeText -Tokens $Tokens -Index $cursor
        if ($null -eq $generic) { return $null }
        $typeParameter = ([string] $generic['Text']).Substring($name.Length)
        $cursor = [int] $generic['EndIndex']
    }
    $positional = [object[]]@()
    if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('(')) {
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex ($cursor + 1)
        if ([int] $list['CloseIndex'] -lt 0) { return $null }
        $positional = $list['Parameter']
        $cursor = [int] $list['CloseIndex']
    }
    $bases = [System.Collections.Generic.List[string]]::new()
    if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @(':')) {
        $cursor++
        while ($true) {
            $base = Get-DocsCSharpTypeText -Tokens $Tokens -Index ($cursor + 1)
            if ($null -eq $base) { break }
            $cursor = [int] $base['EndIndex']
            if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('(')) { $cursor = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($cursor + 1); if ($cursor -lt 0) { return $null } }
            $bases.Add([string] $base['Text'])
            if (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @(',')) { $cursor++; continue }
            break
        }
    }
    $depth = [int] $Tokens[$Index]['Depth']
    $bodyOpen = -1
    for ($scan = $cursor + 1; $scan -lt $Tokens.Count; $scan++) {
        if ([int] $Tokens[$scan]['Depth'] -lt $depth) { return $null }
        if ([int] $Tokens[$scan]['Depth'] -ne $depth) { continue }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('{')) { $bodyOpen = $scan; break }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @(';')) { $cursor = $scan; break }
        $cursor = $scan
    }
    $bodyClose = -1
    if ($bodyOpen -ge 0) {
        $bodyClose = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $bodyOpen
        if ($bodyClose -lt 0) { return $null }
        $cursor = $bodyOpen - 1
    }
    return @{ Kind = $kind; Name = $name; TypeParameter = $typeParameter; Base = [string[]] $bases.ToArray(); PositionalParameter = $positional; BodyOpen = $bodyOpen; BodyClose = $bodyClose; HeaderEnd = $cursor }
}

function Get-DocsCSharpMemberChain {
    <#
    .SYNOPSIS
        Returns the member-call chain starting at the identifier at StartIndex: @{ ReceiverEnd; Call; EndIndex }, or $null.
    .DESCRIPTION
        Each call is @{ Name; TypeArgument; OpenIndex; CloseIndex; Argument; Line; EndLine };
        a generic call such as .MapHub<ChatHub>(...) carries its '<...>' spelling in
        TypeArgument. The chain stops at a member without a call or at an unbalanced call.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $StartIndex
    )

    if (-not (Test-DocsCSharpName -Tokens $Tokens -Index $StartIndex)) { return $null }
    $end = $StartIndex
    if (Test-DocsCSharpToken -Tokens $Tokens -Index ($StartIndex + 1) -Kind 'punct' -Text @('(')) {
        $end = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($StartIndex + 1)
        if ($end -lt 0) { return $null }
    }
    $calls = [System.Collections.Generic.List[object]]::new()
    $index = $end + 1
    while ((Test-DocsCSharpToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('.', '?.')) -and (Test-DocsCSharpName -Tokens $Tokens -Index ($index + 1))) {
        $nameIndex = $index + 1
        $open = $nameIndex + 1
        $typeArgument = ''
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $open -Kind 'punct' -Text @('<')) {
            $generic = Get-DocsCSharpTypeText -Tokens $Tokens -Index $nameIndex
            if ($null -eq $generic) { break }
            $typeArgument = ([string] $generic['Text']).Substring(([string] $Tokens[$nameIndex]['Text']).Length)
            $open = [int] $generic['EndIndex'] + 1
        }
        if (-not (Test-DocsCSharpToken -Tokens $Tokens -Index $open -Kind 'punct' -Text @('('))) { break }
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $open
        if ($close -lt 0) { break }
        [object[]] $arguments = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $open
        $calls.Add(@{ Name = [string] $Tokens[$nameIndex]['Text']; TypeArgument = $typeArgument; OpenIndex = $open; CloseIndex = $close; Argument = $arguments; Line = [int] $Tokens[$nameIndex]['Line']; EndLine = [int] $Tokens[$close]['Line'] })
        $index = $close + 1
    }
    return @{ ReceiverEnd = $end; Call = [object[]] $calls.ToArray(); EndIndex = ($index - 1) }
}

function Get-DocsCSharpStringList {
    <#
    .SYNOPSIS
        Returns the string literals of a single literal, an array or collection initializer, or a collection expression filling Span, else $null.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $single = Get-DocsScannerLiteral -Tokens $Tokens -Span $Span
    if ($null -ne $single) { return , [object[]]@($single) }
    $open = -1
    if (Test-DocsCSharpToken -Tokens $Tokens -Index ([int] $Span['Start']) -Kind 'punct' -Text @('[')) { $open = [int] $Span['Start'] }
    else {
        for ($scan = [int] $Span['Start']; $scan -le [int] $Span['End']; $scan++) {
            if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('{')) { $open = $scan; break }
        }
    }
    if ($open -lt 0 -or (Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $open) -ne [int] $Span['End']) { return $null }
    if ($open -gt [int] $Span['Start'] -and -not (Test-DocsCSharpToken -Tokens $Tokens -Index ([int] $Span['Start']) -Kind 'keyword' -Text @('new'))) { return $null }
    $items = [System.Collections.Generic.List[object]]::new()
    [object[]] $elements = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $open
    foreach ($element in $elements) {
        $literal = Get-DocsScannerLiteral -Tokens $Tokens -Span $element
        if ($null -eq $literal) { return $null }
        $items.Add($literal)
    }
    return , [object[]] $items.ToArray()
}

function Get-DocsCSharpNamespaceRange {
    <#
    .SYNOPSIS
        Returns the namespace ranges of a file: @{ Name; Start; End } for each file-scoped and block namespace.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens)

    $ranges = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        if (-not (Test-DocsCSharpToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('namespace'))) { continue }
        $type = Get-DocsCSharpTypeText -Tokens $Tokens -Index ($index + 1)
        if ($null -eq $type) { continue }
        $next = [int] $type['EndIndex'] + 1
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $next -Kind 'punct' -Text @(';')) { $ranges.Add(@{ Name = [string] $type['Text']; Start = $next + 1; End = $Tokens.Count - 1 }) }
        elseif (Test-DocsCSharpToken -Tokens $Tokens -Index $next -Kind 'punct' -Text @('{')) {
            $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $next
            if ($close -gt $next) { $ranges.Add(@{ Name = [string] $type['Text']; Start = $next + 1; End = $close - 1 }) }
        }
    }
    return , [object[]] $ranges.ToArray()
}

function Get-DocsCSharpNamespaceName {
    <#
    .SYNOPSIS
        Returns the dotted namespace name enclosing token Index (outer to inner), or '' at top level.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Range,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in @($Range)) {
        if ($null -eq $entry) { continue }
        if ($Index -ge [int] $entry['Start'] -and $Index -le [int] $entry['End']) { $parts.Add([string] $entry['Name']) }
    }
    return ($parts -join '.')
}

function Get-DocsCSharpParameterScope {
    <#
    .SYNOPSIS
        Returns @{ Name; Start; End } for every method and lambda parameter: the parameter name and the token range of its body.
    .DESCRIPTION
        A parenthesized list followed by '{' or '=>' declares parameters (the last name of each
        comma-separated entry); a bare identifier before '=>' is a single lambda parameter. A
        block body ranges over its braces; an expression body ranges to the next ';' at the
        arrow's depth or the end of the enclosing brackets.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens)

    $scopes = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        $names = [System.Collections.Generic.List[string]]::new()
        $after = -1
        if ((Test-DocsCSharpToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @(')')) -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('{', '=>'))) {
            $open = -1
            for ($scan = $index - 1; $scan -ge 0; $scan--) { if ([int] $Tokens[$scan]['Depth'] -eq [int] $Tokens[$index]['Depth'] -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('('))) { $open = $scan; break } }
            if ($open -lt 0) { continue }
            [object[]] $spans = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $open
            foreach ($span in $spans) {
                $last = [int] $span['End']
                $spanDepth = [int] $Tokens[[int] $span['Start']]['Depth']
                for ($scan = [int] $span['Start']; $scan -le [int] $span['End']; $scan++) {
                    if ([int] $Tokens[$scan]['Depth'] -eq $spanDepth -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('='))) { $last = $scan - 1; break }
                }
                if (Test-DocsCSharpToken -Tokens $Tokens -Index $last -Kind 'identifier') { $names.Add([string] $Tokens[$last]['Text']) }
            }
            $after = $index + 1
        } elseif ((Test-DocsCSharpToken -Tokens $Tokens -Index $index -Kind 'identifier') -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('=>')) -and -not (Test-DocsCSharpToken -Tokens $Tokens -Index ($index - 1) -Kind 'punct' -Text @(')'))) {
            $names.Add([string] $Tokens[$index]['Text'])
            $after = $index + 1
        } else { continue }
        if ($names.Count -eq 0) { continue }
        $bodyStart = $after
        $bodyEnd = -1
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $after -Kind 'punct' -Text @('=>')) { $bodyStart = $after + 1 }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $bodyStart -Kind 'punct' -Text @('{')) { $bodyEnd = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $bodyStart }
        else {
            $depth = [int] $Tokens[$after]['Depth']
            for ($scan = $bodyStart; $scan -lt $Tokens.Count; $scan++) {
                if ([int] $Tokens[$scan]['Depth'] -lt $depth) { $bodyEnd = $scan - 1; break }
                if ([int] $Tokens[$scan]['Depth'] -eq $depth -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @(';', ','))) { $bodyEnd = $scan - 1; break }
            }
            if ($bodyEnd -lt 0) { $bodyEnd = $Tokens.Count - 1 }
        }
        if ($bodyEnd -lt $bodyStart) { continue }
        foreach ($name in $names) { $scopes.Add(@{ Name = $name; Start = $bodyStart; End = $bodyEnd }) }
    }
    return , [object[]] $scopes.ToArray()
}

Export-ModuleMember -Function `
    Test-DocsCSharpToken, `
    Test-DocsCSharpName, `
    Get-DocsCSharpAttributeSection, `
    Get-DocsCSharpModifier, `
    Get-DocsCSharpTypeText, `
    Get-DocsCSharpParameterList, `
    Get-DocsCSharpTypeDeclaration, `
    Get-DocsCSharpMemberChain, `
    Get-DocsCSharpStringList, `
    Get-DocsCSharpNamespaceRange, `
    Get-DocsCSharpNamespaceName, `
    Get-DocsCSharpParameterScope
