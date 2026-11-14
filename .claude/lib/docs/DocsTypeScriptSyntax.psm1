<#
.SYNOPSIS
    Shared pure syntax helpers over the TypeScript token stream used by the typescript-cli,
    typescript-http and typescript-exports scanners: import bindings, member-call chains,
    object-literal members, array literals, function parameters, loop bodies and relative
    module resolution against the captured input set.

.DESCRIPTION
    Every function reads the token records of ConvertTo-DocsTypeScriptToken and returns plain
    hashtables of token indices and decoded strings. Nothing here evaluates an expression: a
    construct that is not a literal, a plain identifier or a literal-only container is reported
    as $null or as a computed member so that the calling scanner emits its precision-limit
    diagnostic. Every function is pure: no filesystem, clock, process, environment or
    module-scope mutable state; inputs are not mutated.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from the analyzer modules under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

function Test-DocsTypeScriptToken {
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

function Test-DocsTypeScriptName {
    <#
    .SYNOPSIS
        Returns $true when the token at Index is an identifier or keyword (a member or binding name).
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

function Test-DocsTypeScriptStatementStart {
    <#
    .SYNOPSIS
        Returns $true when the token at Index begins a statement: first token, after ';' or '}', or on a new line.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    if ($Index -le 0) { return $true }
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($Index - 1) -Kind 'punct' -Text @(';', '}', '{')) { return $true }
    return ([int] $Tokens[$Index - 1]['EndLine'] -lt [int] $Tokens[$Index]['Line'])
}

function Get-DocsTypeScriptStatementEnd {
    <#
    .SYNOPSIS
        Returns the index of the last token of the statement that starts at Index.
    .DESCRIPTION
        The statement ends at the first ';' at the starting depth; at a '}' at that depth that is
        followed by ';' (included) or by a token on a later line; before a token at that depth
        on a later line that begins a declaration (export, import, const, let, var, class,
        function, interface, enum, a decorator, or type, declare, namespace, abstract or async
        followed by a name); before the first token at a lower depth; or at the last token.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $depth = [int] $Tokens[$Index]['Depth']
    for ($cursor = $Index; $cursor -lt $Tokens.Count; $cursor++) {
        $tokenDepth = [int] $Tokens[$cursor]['Depth']
        if ($tokenDepth -lt $depth) { return $cursor - 1 }
        if ($tokenDepth -ne $depth) { continue }
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @(';')) { return $cursor }
        if ($cursor -gt $Index -and [int] $Tokens[$cursor]['Line'] -gt [int] $Tokens[$cursor - 1]['EndLine']) {
            $startsDeclaration = (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'keyword' -Text @('export', 'import', 'const', 'let', 'var', 'class', 'function', 'interface', 'enum')) -or (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('@')) -or ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'identifier' -Text @('type', 'declare', 'namespace', 'abstract', 'async')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($cursor + 1)))
            if ($startsDeclaration) { return $cursor - 1 }
        }
        if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('}')) -and $cursor -gt $Index) {
            if ($cursor + 1 -ge $Tokens.Count) { return $cursor }
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @(';')) { return $cursor + 1 }
            if ([int] $Tokens[$cursor + 1]['Line'] -gt [int] $Tokens[$cursor]['EndLine']) { return $cursor }
        }
    }
    return $Tokens.Count - 1
}

function Get-DocsTypeScriptBindingList {
    <#
    .SYNOPSIS
        Returns the @{ Imported; Local; TypeOnly; Line } pairs of a '{ a, b as c, type d, e: f }' import, export or binding clause at OpenIndex.
    .DESCRIPTION
        Imported is the name before 'as' or ':' (the module's export name in an import clause,
        the local name in an export clause); Local is the name after it, or the same name.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $OpenIndex
    )

    $pairs = [System.Collections.Generic.List[object]]::new()
    $spans = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $OpenIndex
    foreach ($span in $spans) {
        $index = [int] $span['Start']
        $typeOnly = $false
        if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'identifier' -Text @('type')) -and $index -lt [int] $span['End'] -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 1))) { $typeOnly = $true; $index++ }
        if (-not (Test-DocsTypeScriptName -Tokens $Tokens -Index $index) -and -not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'string')) { continue }
        $imported = if ([string] $Tokens[$index]['Kind'] -ceq 'string') { [string] $Tokens[$index]['Value'] } else { [string] $Tokens[$index]['Text'] }
        $local = $imported
        if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'identifier' -Text @('as')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 2))) { $local = [string] $Tokens[$index + 2]['Text'] }
        elseif ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'identifier' -Text @('as')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 2) -Kind 'string')) { $local = [string] $Tokens[$index + 2]['Value'] }
        elseif ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @(':')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 2))) { $local = [string] $Tokens[$index + 2]['Text'] }
        $pairs.Add(@{ Imported = $imported; Local = $local; TypeOnly = $typeOnly; Line = [int] $Tokens[$index]['Line'] })
    }
    return , $pairs.ToArray()
}

function Get-DocsTypeScriptImport {
    <#
    .SYNOPSIS
        Returns the import bindings of a file: @{ Local; Imported; Module; Line } per bound name.
    .DESCRIPTION
        Covers 'import x from', 'import * as x from', 'import { a, b as c } from', 'import type',
        'import x = require(...)', and 'const x = require(...)' or 'const { a } = require(...)'.
        Imported is 'default', '*' or the exported name. A side-effect import binds nothing.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens)

    $bindings = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        if (-not (Test-DocsTypeScriptStatementStart -Tokens $Tokens -Index $index)) { continue }
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('import')) {
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('(', '.')) { continue }
            $cursor = $index + 1
            $pending = [System.Collections.Generic.List[object]]::new()
            if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'identifier' -Text @('type')) -and -not (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'identifier' -Text @('from'))) { $cursor++ }
            if (Test-DocsTypeScriptName -Tokens $Tokens -Index $cursor) {
                $local = [string] $Tokens[$cursor]['Text']
                if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('=')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 2) -Kind 'identifier' -Text @('require')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 4) -Kind 'string')) {
                    $bindings.Add(@{ Local = $local; Imported = '*'; Module = [string] $Tokens[$cursor + 4]['Value']; Line = [int] $Tokens[$index]['Line'] })
                    continue
                }
                $pending.Add(@{ Imported = 'default'; Local = $local })
                $cursor++
                if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @(',')) { $cursor++ }
            }
            if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('*')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($cursor + 2))) {
                $pending.Add(@{ Imported = '*'; Local = [string] $Tokens[$cursor + 2]['Text'] })
                $cursor += 3
            } elseif (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('{')) {
                $pairs = Get-DocsTypeScriptBindingList -Tokens $Tokens -OpenIndex $cursor
                foreach ($pair in $pairs) { $pending.Add($pair) }
                $cursor = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $cursor
                if ($cursor -lt 0) { continue }
                $cursor++
            }
            if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'identifier' -Text @('from')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'string')) {
                foreach ($pair in $pending) { $bindings.Add(@{ Local = $pair['Local']; Imported = $pair['Imported']; Module = [string] $Tokens[$cursor + 1]['Value']; Line = [int] $Tokens[$index]['Line'] }) }
            }
            continue
        }
        if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('const', 'let', 'var'))) { continue }
        $cursor = $index + 1
        $pending = [System.Collections.Generic.List[object]]::new()
        if (Test-DocsTypeScriptName -Tokens $Tokens -Index $cursor) {
            $pending.Add(@{ Imported = '*'; Local = [string] $Tokens[$cursor]['Text'] })
            $cursor++
        } elseif (Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('{')) {
            $pairs = Get-DocsTypeScriptBindingList -Tokens $Tokens -OpenIndex $cursor
            foreach ($pair in $pairs) { $pending.Add(@{ Imported = $pair['Imported']; Local = $pair['Local'] }) }
            $cursor = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $cursor
            if ($cursor -lt 0) { continue }
            $cursor++
        } else { continue }
        if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('=')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'identifier' -Text @('require')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 2) -Kind 'punct' -Text @('(')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 3) -Kind 'string') -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($cursor + 4) -Kind 'punct' -Text @(')'))) {
            foreach ($pair in $pending) { $bindings.Add(@{ Local = $pair['Local']; Imported = $pair['Imported']; Module = [string] $Tokens[$cursor + 3]['Value']; Line = [int] $Tokens[$index]['Line'] }) }
        }
    }
    return , $bindings.ToArray()
}

function Get-DocsTypeScriptMemberChain {
    <#
    .SYNOPSIS
        Returns the member-call chain starting at StartIndex: @{ ReceiverEnd; Call; EndIndex }, or $null.
    .DESCRIPTION
        The receiver is an identifier, an identifier call 'f(...)', or 'new T(...)'. Each call is
        @{ Name; OpenIndex; CloseIndex; Argument; Line; EndLine }; the chain stops at a member
        without a call or at an unbalanced call.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $StartIndex
    )

    if ($StartIndex -lt 0 -or $StartIndex -ge $Tokens.Count) { return $null }
    $end = $StartIndex
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $StartIndex -Kind 'keyword' -Text @('new')) {
        $end = $StartIndex + 1
        if (-not (Test-DocsTypeScriptName -Tokens $Tokens -Index $end)) { return $null }
        while ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($end + 1) -Kind 'punct' -Text @('.')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($end + 2))) { $end += 2 }
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($end + 1) -Kind 'punct' -Text @('(')) {
            $end = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($end + 1)
            if ($end -lt 0) { return $null }
        }
    } elseif (Test-DocsTypeScriptName -Tokens $Tokens -Index $StartIndex) {
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($StartIndex + 1) -Kind 'punct' -Text @('(')) {
            $end = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($StartIndex + 1)
            if ($end -lt 0) { return $null }
        }
    } else { return $null }

    $calls = [System.Collections.Generic.List[object]]::new()
    $index = $end + 1
    while ((Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('.', '?.')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 1)) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 2) -Kind 'punct' -Text @('('))) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex ($index + 2)
        if ($close -lt 0) { break }
        [object[]] $arguments = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex ($index + 2)
        $calls.Add(@{ Name = [string] $Tokens[$index + 1]['Text']; OpenIndex = $index + 2; CloseIndex = $close; Argument = $arguments; Line = [int] $Tokens[$index + 1]['Line']; EndLine = [int] $Tokens[$close]['Line'] })
        $index = $close + 1
    }
    return @{ ReceiverEnd = $end; Call = $calls.ToArray(); EndIndex = ($index - 1) }
}

function Get-DocsTypeScriptObjectMember {
    <#
    .SYNOPSIS
        Returns the members of the object literal opened at OpenIndex: @{ Key; Computed; Spread; KeyIndex; ValueStart; ValueEnd; Line }.
    .DESCRIPTION
        Key is the identifier, keyword, string value or number text of a literal key and $null for
        a computed '[...]' key or a '...' spread. ValueStart is -1 when no value follows the key.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $OpenIndex
    )

    $members = [System.Collections.Generic.List[object]]::new()
    if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $OpenIndex -Kind 'punct' -Text @('{'))) { return , $members.ToArray() }
    $spans = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $OpenIndex
    foreach ($span in $spans) {
        $index = [int] $span['Start']
        $member = @{ Key = $null; Computed = $false; Spread = $false; KeyIndex = $index; ValueStart = -1; ValueEnd = [int] $span['End']; Line = [int] $Tokens[$index]['Line'] }
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('...')) {
            $member['Spread'] = $true
        } elseif (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('[')) {
            $member['Computed'] = $true
            $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $index
            if ($close -ge 0 -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($close + 1) -Kind 'punct' -Text @(':'))) { $member['ValueStart'] = $close + 2 }
        } else {
            $kind = [string] $Tokens[$index]['Kind']
            if ($kind -ceq 'string') { $member['Key'] = [string] $Tokens[$index]['Value'] }
            elseif ($kind -ceq 'identifier' -or $kind -ceq 'keyword' -or $kind -ceq 'number') { $member['Key'] = [string] $Tokens[$index]['Text'] }
            else { $member['Computed'] = $true }
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @(':')) { $member['ValueStart'] = $index + 2 }
            elseif (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('(')) { $member['ValueStart'] = $index + 1 }
            elseif ($index -eq [int] $span['End']) { $member['ValueStart'] = $index }
        }
        if ($member['ValueStart'] -gt [int] $span['End']) { $member['ValueStart'] = -1 }
        $members.Add($member)
    }
    return , $members.ToArray()
}

function Get-DocsTypeScriptArrayLiteral {
    <#
    .SYNOPSIS
        Returns the decoded strings of an array literal of string literals filling Span, else $null.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $start = [int] $Span['Start']
    if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $start -Kind 'punct' -Text @('['))) { return $null }
    if ((Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $start) -ne [int] $Span['End']) { return $null }
    $items = [System.Collections.Generic.List[string]]::new()
    $elements = Get-DocsScannerCallArgument -Tokens $Tokens -OpenIndex $start
    foreach ($element in $elements) {
        $literal = Get-DocsScannerLiteral -Tokens $Tokens -Span $element
        if ($null -eq $literal) { return $null }
        $items.Add($literal)
    }
    return , [string[]] $items.ToArray()
}

function Get-DocsTypeScriptFunctionParameter {
    <#
    .SYNOPSIS
        Returns @{ Parameter; BodyStart; BodyEnd } for a function or arrow expression filling Span, else $null.
    .DESCRIPTION
        Parameter is the first parameter's identifier, or $null when it is a pattern or absent.
        The body is the token span after the parameter list and arrow (or the function keyword's
        parameter list) through the end of Span.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $index = [int] $Span['Start']
    $end = [int] $Span['End']
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'identifier' -Text @('async')) { $index++ }
    $parameter = $null
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('function')) {
        $index++
        if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('*')) { $index++ }
        if (Test-DocsTypeScriptName -Tokens $Tokens -Index $index) { $index++ }
        if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('('))) { return $null }
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $index
        if ($close -lt 0 -or $close -gt $end) { return $null }
        if ($close -gt $index + 1 -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 1))) { $parameter = [string] $Tokens[$index + 1]['Text'] }
        return @{ Parameter = $parameter; BodyStart = $close + 1; BodyEnd = $end }
    }
    if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'punct' -Text @('(')) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $index
        if ($close -lt 0 -or $close -gt $end) { return $null }
        if ($close -gt $index + 1 -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($index + 1))) { $parameter = [string] $Tokens[$index + 1]['Text'] }
        for ($arrow = $close + 1; $arrow -le $end; $arrow++) {
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $arrow -Kind 'punct' -Text @('=>')) { return @{ Parameter = $parameter; BodyStart = $arrow + 1; BodyEnd = $end } }
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $arrow -Kind 'punct' -Text @('{', '(', ';', ',')) { return $null }
        }
        return $null
    }
    if ((Test-DocsTypeScriptName -Tokens $Tokens -Index $index) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('=>'))) {
        return @{ Parameter = [string] $Tokens[$index]['Text']; BodyStart = $index + 2; BodyEnd = $end }
    }
    return $null
}

function Get-DocsTypeScriptLoopRange {
    <#
    .SYNOPSIS
        Returns the token-index ranges @{ Start; End } of every brace-delimited for, while and do loop body.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens)

    $ranges = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('for', 'while', 'do'))) { continue }
        $open = $index + 1
        if ([string] $Tokens[$index]['Text'] -cne 'do') {
            if (Test-DocsTypeScriptToken -Tokens $Tokens -Index $open -Kind 'keyword' -Text @('await')) { $open++ }
            if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $open -Kind 'punct' -Text @('('))) { continue }
            $headClose = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $open
            if ($headClose -lt 0) { continue }
            $open = $headClose + 1
        }
        if (-not (Test-DocsTypeScriptToken -Tokens $Tokens -Index $open -Kind 'punct' -Text @('{'))) { continue }
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $open
        if ($close -lt 0) { continue }
        $ranges.Add(@{ Start = $open; End = $close })
    }
    return , $ranges.ToArray()
}

function Test-DocsTypeScriptInRange {
    <#
    .SYNOPSIS
        Returns $true when Index lies inside any of the @{ Start; End } ranges.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Range,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    foreach ($entry in @($Range)) {
        if ($null -eq $entry) { continue }
        if ($Index -ge [int] $entry['Start'] -and $Index -le [int] $entry['End']) { return $true }
    }
    return $false
}

function Resolve-DocsTypeScriptRelativeModule {
    <#
    .SYNOPSIS
        Resolves a relative specifier imported from FromPath to a captured path, or $null.
    .DESCRIPTION
        Only './' and '../' specifiers resolve. A JavaScript extension maps to its TypeScript
        counterpart; an extensionless specifier tries .ts, .tsx, .mts, .cts, .d.ts, /index.ts and
        /index.tsx in that order. The first candidate present in CapturedPath (ordinal) wins.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $FromPath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Specifier,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $CapturedPath
    )

    if (-not ($Specifier.StartsWith('./') -or $Specifier.StartsWith('../') -or $Specifier -ceq '.' -or $Specifier -ceq '..')) { return $null }
    $segments = [System.Collections.Generic.List[string]]::new()
    $slash = $FromPath.LastIndexOf('/')
    if ($slash -gt 0) { foreach ($segment in $FromPath.Substring(0, $slash).Split('/')) { $segments.Add($segment) } }
    foreach ($segment in $Specifier.Split('/')) {
        if ($segment -ceq '.' -or $segment.Length -eq 0) { continue }
        if ($segment -ceq '..') {
            if ($segments.Count -eq 0) { return $null }
            $segments.RemoveAt($segments.Count - 1)
            continue
        }
        $segments.Add($segment)
    }
    $base = $segments -join '/'
    if ($base.Length -eq 0) { return $null }
    $candidates = [System.Collections.Generic.List[string]]::new()
    $extensionMap = @{ '.js' = @('.ts', '.tsx'); '.mjs' = @('.mts'); '.cjs' = @('.cts'); '.jsx' = @('.tsx') }
    $mapped = $false
    foreach ($extension in @('.js', '.mjs', '.cjs', '.jsx')) {
        if ($base.EndsWith($extension, [System.StringComparison]::Ordinal)) {
            $stem = $base.Substring(0, $base.Length - $extension.Length)
            foreach ($target in $extensionMap[$extension]) { $candidates.Add($stem + $target) }
            $mapped = $true
            break
        }
    }
    if (-not $mapped) {
        $hasTypeScriptExtension = $false
        foreach ($extension in @('.ts', '.tsx', '.mts', '.cts')) { if ($base.EndsWith($extension, [System.StringComparison]::Ordinal)) { $hasTypeScriptExtension = $true } }
        if ($hasTypeScriptExtension) { $candidates.Add($base) }
        else { foreach ($suffix in @('.ts', '.tsx', '.mts', '.cts', '.d.ts', '/index.ts', '/index.tsx')) { $candidates.Add($base + $suffix) } }
    }
    foreach ($candidate in $candidates) {
        foreach ($path in $CapturedPath) { if ($path -ceq $candidate) { return $candidate } }
    }
    return $null
}

Export-ModuleMember -Function `
    Test-DocsTypeScriptToken, `
    Test-DocsTypeScriptName, `
    Test-DocsTypeScriptStatementStart, `
    Get-DocsTypeScriptStatementEnd, `
    Get-DocsTypeScriptBindingList, `
    Get-DocsTypeScriptImport, `
    Get-DocsTypeScriptMemberChain, `
    Get-DocsTypeScriptObjectMember, `
    Get-DocsTypeScriptArrayLiteral, `
    Get-DocsTypeScriptFunctionParameter, `
    Get-DocsTypeScriptLoopRange, `
    Test-DocsTypeScriptInRange, `
    Resolve-DocsTypeScriptRelativeModule
