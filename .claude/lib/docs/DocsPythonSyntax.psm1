<#
.SYNOPSIS
    Python syntax helpers over the bounded lexer for the issue #1022 scanners: logical lines,
    enclosing blocks, literal strings, dotted chains, comma splitting and call reading. The
    import table, receiver table and definition headers live in DocsPythonBindings.psm1 (split
    under the 500-line module rule).

.DESCRIPTION
    Every function takes the hashtable tokens of Get-DocsPythonToken, or the logical lines of
    Get-DocsPythonLogicalLine, and returns new hashtables; lexer tokens are copied, never
    mutated. Diagnostics are records with Code, Severity, Blocking and Line; the analyzers
    attach the path. Names are compared ordinally, so App and app stay distinct.

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

$script:DocsPythonBlockKeywordList = [string[]]@('if', 'elif', 'else', 'try', 'except', 'finally', 'for', 'while', 'with', 'def', 'class', 'async')
$script:DocsPythonTopLevelBranchList = [string[]]@('if', 'elif', 'else', 'try', 'except', 'finally')

function Get-DocsPythonIndentWidth {
    <#
    .SYNOPSIS
        Returns the indentation column of leading whitespace (tabs to multiples of 8, form feed resets) (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Whitespace)

    $column = 0
    foreach ($character in $Whitespace.ToCharArray()) {
        if ($character -eq "`t") { $column = ([math]::Floor($column / 8) + 1) * 8 }
        elseif ($character -eq [char]0x0C) { $column = 0 }
        else { $column++ }
    }
    return $column
}

function Get-DocsPythonLogicalLine {
    <#
    .SYNOPSIS
        Groups lexer tokens into logical lines and returns @{ Lines; Diagnostics }.
    .DESCRIPTION
        A logical line has Index, StartLine, EndLine, Indent and Tokens (significant tokens, each
        with Level, the bracket depth it sits in). A newline at depth 0 not preceded by a
        continuation ends the line; a ';' at depth 0 splits it. Blank and comment-only lines are
        not logical lines. A dedent to a column not on the indentation stack yields the blocking
        diagnostic PYTHON_INDENTATION_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token)

    $state = @{
        Lines       = [System.Collections.Generic.List[object]]::new()
        Diagnostics = [System.Collections.Generic.List[object]]::new()
        Current     = [System.Collections.Generic.List[object]]::new()
        Indent      = 0
        Stack       = [System.Collections.Generic.List[int]]::new()
    }
    $state['Stack'].Add(0)
    $leading = ''
    $level = 0
    $previousType = 'NEWLINE'

    foreach ($item in $Token) {
        $type = $item['Type']
        if ($type -ceq 'WHITESPACE') {
            if ($item['Column'] -eq 0) { $leading = $item['Text'] }
            continue
        }
        if ($type -ceq 'COMMENT' -or $type -ceq 'CONTINUATION') { $previousType = $type; continue }
        if ($type -ceq 'NEWLINE') {
            if ($level -eq 0 -and $previousType -cne 'CONTINUATION') { Complete-DocsPythonLogicalLine -State $state }
            $leading = ''
            $previousType = $type
            continue
        }
        if ($state['Current'].Count -eq 0) { $state['Indent'] = if ($item['Column'] -eq 0) { 0 } else { Get-DocsPythonIndentWidth -Whitespace $leading } }
        $copy = $item.Clone()
        $text = $copy['Text']
        if ($type -ceq 'OP' -and ($text -ceq '(' -or $text -ceq '[' -or $text -ceq '{')) { $copy['Level'] = $level; $level++ }
        elseif ($type -ceq 'OP' -and ($text -ceq ')' -or $text -ceq ']' -or $text -ceq '}')) { $level--; $copy['Level'] = $level }
        else { $copy['Level'] = $level }
        if ($type -ceq 'OP' -and $text -ceq ';' -and $level -eq 0) { Complete-DocsPythonLogicalLine -State $state; $previousType = $type; continue }
        $state['Current'].Add($copy)
        $previousType = $type
    }
    Complete-DocsPythonLogicalLine -State $state
    return @{ Lines = $state['Lines'].ToArray(); Diagnostics = $state['Diagnostics'].ToArray() }
}

function Complete-DocsPythonLogicalLine {
    <#
    .SYNOPSIS
        Closes the logical line held in State, checking the indentation stack (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $current = $State['Current']
    if ($current.Count -eq 0) { return }
    $stack = $State['Stack']
    $indent = [int] $State['Indent']
    $first = $current[0]
    $last = $current[$current.Count - 1]
    if ($indent -gt $stack[$stack.Count - 1]) { $stack.Add($indent) }
    elseif ($indent -lt $stack[$stack.Count - 1]) {
        while ($stack.Count -gt 1 -and $stack[$stack.Count - 1] -gt $indent) { $stack.RemoveAt($stack.Count - 1) }
        if ($stack[$stack.Count - 1] -ne $indent -and $State['Diagnostics'].Count -eq 0) {
            $State['Diagnostics'].Add(@{ Code = 'PYTHON_INDENTATION_INVALID'; Severity = 'error'; Blocking = $true; Line = $first['Line'] })
        }
    }
    $State['Lines'].Add(@{ Index = $State['Lines'].Count; StartLine = $first['Line']; EndLine = $last['EndLine']; Indent = $indent; Tokens = $current.ToArray() })
    $current.Clear()
}

function Test-DocsPythonBlockOpener {
    <#
    .SYNOPSIS
        Returns the block keyword of a logical line that opens a block, else $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [hashtable] $Line)

    $tokens = $Line['Tokens']
    if ($tokens.Count -lt 2) { return $null }
    $first = $tokens[0]
    if ($first['Type'] -cne 'NAME' -or -not $first['IsKeyword'] -or $script:DocsPythonBlockKeywordList -cnotcontains $first['Text']) { return $null }
    $keyword = $first['Text']
    if ($keyword -ceq 'async' -and $tokens.Count -gt 2 -and $tokens[1]['Type'] -ceq 'NAME') { $keyword = $tokens[1]['Text'] }
    $last = $tokens[$tokens.Count - 1]
    if ($last['Type'] -ceq 'OP' -and $last['Text'] -ceq ':' -and $last['Level'] -eq 0) { return $keyword }
    foreach ($token in $tokens) { if ($token['Type'] -ceq 'OP' -and $token['Text'] -ceq ':' -and $token['Level'] -eq 0) { return $keyword } }
    return $null
}

function Get-DocsPythonEnclosingBlock {
    <#
    .SYNOPSIS
        Returns the blocks enclosing a logical line: @{ Kinds; InLoop; InDef; InClass; InComprehension; TopLevelOnly }.
    .DESCRIPTION
        Kinds lists the opener keywords from the outermost block inward. With -TokenIndex the
        same-line body after a ':' of a for or while line counts as a loop, and the comprehension
        check is restricted to the bracket group holding that token. TopLevelOnly is $true when
        every enclosing block is a top-level if, elif, else, try, except or finally.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [int] $Index,
        [int] $TokenIndex = -1
    )

    $kinds = [System.Collections.Generic.List[string]]::new()
    $indent = $Line[$Index]['Indent']
    for ($cursor = $Index - 1; $cursor -ge 0 -and $indent -gt 0; $cursor--) {
        if ($Line[$cursor]['Indent'] -ge $indent) { continue }
        $indent = $Line[$cursor]['Indent']
        $opener = Test-DocsPythonBlockOpener -Line $Line[$cursor]
        if ($null -ne $opener) { $kinds.Insert(0, $opener) }
    }
    $tokens = $Line[$Index]['Tokens']
    $ownOpener = Test-DocsPythonBlockOpener -Line $Line[$Index]
    if ($TokenIndex -ge 0 -and $null -ne $ownOpener) {
        for ($cursor = 0; $cursor -lt $TokenIndex; $cursor++) {
            if ($tokens[$cursor]['Type'] -ceq 'OP' -and $tokens[$cursor]['Text'] -ceq ':' -and $tokens[$cursor]['Level'] -eq 0) { $kinds.Add($ownOpener); break }
        }
    }
    $inComprehension = $false
    for ($cursor = 0; $cursor -lt $tokens.Count; $cursor++) {
        $token = $tokens[$cursor]
        if ($token['Type'] -cne 'NAME' -or $token['Text'] -cne 'for' -or $token['Level'] -lt 1) { continue }
        if ($TokenIndex -lt 0) { $inComprehension = $true; break }
        $outer = $token['Level'] - 1
        $open = -1
        for ($back = $cursor - 1; $back -ge 0; $back--) { if ($tokens[$back]['Type'] -ceq 'OP' -and $tokens[$back]['Level'] -eq $outer -and $tokens[$back]['Text'] -cin @('(', '[', '{')) { $open = $back; break } }
        $close = $tokens.Count
        for ($forward = $cursor + 1; $forward -lt $tokens.Count; $forward++) { if ($tokens[$forward]['Type'] -ceq 'OP' -and $tokens[$forward]['Level'] -eq $outer -and $tokens[$forward]['Text'] -cin @(')', ']', '}')) { $close = $forward; break } }
        if ($TokenIndex -gt $open -and $TokenIndex -lt $close) { $inComprehension = $true; break }
    }
    $topLevelOnly = $true
    foreach ($kind in $kinds) { if ($script:DocsPythonTopLevelBranchList -cnotcontains $kind) { $topLevelOnly = $false } }
    return @{
        Kinds           = $kinds.ToArray()
        InLoop          = ($kinds -ccontains 'for') -or ($kinds -ccontains 'while')
        InDef           = ($kinds -ccontains 'def')
        InClass         = ($kinds -ccontains 'class')
        InComprehension = $inComprehension
        TopLevelOnly    = $topLevelOnly
    }
}

function ConvertFrom-DocsPythonStringToken {
    <#
    .SYNOPSIS
        Returns the literal value of one or more adjacent STRING tokens, or $null when dynamic.
    .DESCRIPTION
        A bytes or f-string, a non-raw string carrying a backslash, a non-string token, or an
        implicit concatenation with such a part yields $null. Raw-string bodies are verbatim.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token)

    if ($Token.Count -eq 0) { return $null }
    $builder = [System.Text.StringBuilder]::new()
    foreach ($item in $Token) {
        if ($item['Type'] -cne 'STRING' -or $item['IsBytes'] -or $item['IsFormat'] -or ($item['HasEscape'] -and -not $item['IsRaw'])) { return $null }
        $text = [string] $item['Text']
        $quote = [string] $item['Quote']
        $start = ([string] $item['Prefix']).Length + $quote.Length
        [void] $builder.Append($text.Substring($start, $text.Length - $start - $quote.Length))
    }
    return $builder.ToString()
}

function Read-DocsPythonDottedChain {
    <#
    .SYNOPSIS
        Reads NAME(.NAME)* from Index and returns @{ Text; Parts; End } or $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [Parameter(Mandatory = $true)] [int] $Index)

    if ($Index -ge $Token.Count -or $Token[$Index]['Type'] -cne 'NAME' -or $Token[$Index]['IsKeyword']) { return $null }
    $parts = [System.Collections.Generic.List[string]]::new()
    $parts.Add($Token[$Index]['Text'])
    $cursor = $Index + 1
    while ($cursor + 1 -lt $Token.Count -and $Token[$cursor]['Type'] -ceq 'OP' -and $Token[$cursor]['Text'] -ceq '.' -and $Token[$cursor + 1]['Type'] -ceq 'NAME' -and -not $Token[$cursor + 1]['IsKeyword']) {
        $parts.Add($Token[$cursor + 1]['Text'])
        $cursor += 2
    }
    return @{ Text = ($parts -join '.'); Parts = $parts.ToArray(); End = $cursor }
}

function Read-DocsPythonArgument {
    <#
    .SYNOPSIS
        Classifies one argument token slice (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token)

    $record = @{ Tokens = $Token; Kind = 'other'; Value = $null; Items = $null; StartLine = $Token[0]['Line']; EndLine = $Token[$Token.Count - 1]['EndLine'] }
    if ($Token[0]['Type'] -ceq 'OP' -and ($Token[0]['Text'] -ceq '*' -or $Token[0]['Text'] -ceq '**')) { $record['Kind'] = 'star'; return $record }
    $allStrings = $true
    foreach ($item in $Token) { if ($item['Type'] -cne 'STRING') { $allStrings = $false; break } }
    if ($allStrings) { $record['Kind'] = 'string'; $record['Value'] = ConvertFrom-DocsPythonStringToken -Token $Token; return $record }
    if ($Token[0]['Type'] -ceq 'NUMBER' -and $Token.Count -eq 1) { $record['Kind'] = 'number'; return $record }
    $chain = Read-DocsPythonDottedChain -Token $Token -Index 0
    if ($null -ne $chain) {
        if ($chain['End'] -eq $Token.Count) { $record['Kind'] = if ($chain['Parts'].Count -eq 1) { 'name' } else { 'attribute' }; $record['Value'] = $chain['Text']; return $record }
        if ($Token[$chain['End']]['Type'] -ceq 'OP' -and $Token[$chain['End']]['Text'] -ceq '(') { $record['Kind'] = 'call'; $record['Value'] = $chain['Text']; return $record }
    }
    $open = $Token[0]
    $close = $Token[$Token.Count - 1]
    if ($open['Type'] -ceq 'OP' -and $close['Type'] -ceq 'OP' -and (($open['Text'] -ceq '[' -and $close['Text'] -ceq ']') -or ($open['Text'] -ceq '(' -and $close['Text'] -ceq ')'))) {
        $record['Kind'] = if ($open['Text'] -ceq '[') { 'list' } else { 'tuple' }
        $items = [System.Collections.Generic.List[object]]::new()
        $dynamic = $false
        foreach ($piece in (Split-DocsPythonTokenList -Token $Token -Start 1 -End ($Token.Count - 1) -Level ($open['Level'] + 1))) {
            $value = ConvertFrom-DocsPythonStringToken -Token $piece
            if ($null -eq $value) { $dynamic = $true }
            $items.Add($value)
        }
        $record['Items'] = if ($dynamic) { $null } else { $items.ToArray() }
    }
    return $record
}

function Split-DocsPythonTokenList {
    <#
    .SYNOPSIS
        Splits Token[Start..End) at commas sitting at Level into non-empty slices.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [int] $Start, [int] $End, [int] $Level)

    $pieces = [System.Collections.Generic.List[object]]::new()
    $current = [System.Collections.Generic.List[object]]::new()
    for ($cursor = $Start; $cursor -lt $End; $cursor++) {
        $item = $Token[$cursor]
        if ($item['Type'] -ceq 'OP' -and $item['Text'] -ceq ',' -and $item['Level'] -eq $Level) {
            if ($current.Count -gt 0) { $pieces.Add($current.ToArray()); $current.Clear() }
            continue
        }
        $current.Add($item)
    }
    if ($current.Count -gt 0) { $pieces.Add($current.ToArray()) }
    return , $pieces.ToArray()
}

function Read-DocsPythonCall {
    <#
    .SYNOPSIS
        Reads a call expression starting at the callee NAME at Index, or returns $null.
    .DESCRIPTION
        Returns @{ Callee; CalleeParts; Start; OpenIndex; CloseIndex; Positional; Keyword;
        HasStar; EndLine }. Positional is the ordered argument list and Keyword an ordinal map of
        keyword name to argument; each argument carries Tokens, Kind (string, name, attribute,
        number, list, tuple, call, star, other), Value (the literal string, or the dotted name
        for name, attribute and call), Items (list or tuple of literal strings, else $null),
        StartLine and EndLine. A keyword argument is a NAME followed by '=' at the call's level.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [Parameter(Mandatory = $true)] [int] $Index)

    $chain = Read-DocsPythonDottedChain -Token $Token -Index $Index
    if ($null -eq $chain) { return $null }
    $open = $chain['End']
    if ($open -ge $Token.Count -or $Token[$open]['Type'] -cne 'OP' -or $Token[$open]['Text'] -cne '(') { return $null }
    $level = $Token[$open]['Level']
    $close = -1
    for ($cursor = $open + 1; $cursor -lt $Token.Count; $cursor++) {
        if ($Token[$cursor]['Type'] -ceq 'OP' -and $Token[$cursor]['Text'] -ceq ')' -and $Token[$cursor]['Level'] -eq $level) { $close = $cursor; break }
    }
    if ($close -lt 0) { return $null }
    $positional = [System.Collections.Generic.List[object]]::new()
    $keyword = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $hasStar = $false
    foreach ($piece in (Split-DocsPythonTokenList -Token $Token -Start ($open + 1) -End $close -Level ($level + 1))) {
        if ($piece.Count -ge 3 -and $piece[0]['Type'] -ceq 'NAME' -and $piece[1]['Type'] -ceq 'OP' -and $piece[1]['Text'] -ceq '=') {
            $argument = Read-DocsPythonArgument -Token $piece[2..($piece.Count - 1)]
            $keyword[[string] $piece[0]['Text']] = $argument
            continue
        }
        $argument = Read-DocsPythonArgument -Token $piece
        if ($argument['Kind'] -ceq 'star') { $hasStar = $true }
        $positional.Add($argument)
    }
    return @{
        Callee      = $chain['Text']
        CalleeParts = $chain['Parts']
        Start       = $Index
        OpenIndex   = $open
        CloseIndex  = $close
        Positional  = $positional.ToArray()
        Keyword     = $keyword
        HasStar     = $hasStar
        StartLine   = $Token[$Index]['Line']
        EndLine     = $Token[$close]['EndLine']
    }
}

Export-ModuleMember -Function `
    Get-DocsPythonLogicalLine, `
    Get-DocsPythonEnclosingBlock, `
    ConvertFrom-DocsPythonStringToken, `
    Read-DocsPythonDottedChain, `
    Split-DocsPythonTokenList, `
    Read-DocsPythonCall
