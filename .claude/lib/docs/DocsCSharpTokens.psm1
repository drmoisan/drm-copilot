<#
.SYNOPSIS
    Bounded lexical tokenizer for C# source text used by the documentation scanners.

.DESCRIPTION
    ConvertTo-DocsCSharpToken returns @{ Tokens; HasConditional; Diagnostics } for one file with
    the token record shared with the TypeScript tokenizer: Kind (identifier, keyword, string,
    number, punct), Text, Value (decoded for a string, a character literal and an identifier),
    Dynamic (an interpolated string with holes), Start, Line, EndLine and Depth. Comments and
    preprocessor directive lines produce no token; both branches of #if and #else are tokenized
    without evaluation and HasConditional is $true when any #if directive exists. Strings cover
    regular, verbatim, interpolated (with {{ escapes and nested holes), raw ("""...""" with the
    quote-run length and the $$ brace width; a single-line raw string decodes to its content, a
    multi-line one carries Value $null) and the u8 suffix. Contextual keywords (record, partial,
    required, file, var, async, await) are identifiers; '>' is always a single token so generic
    closers never merge. The scanner advances with \G-anchored regular expressions.

    An unterminated string, character, comment or raw string yields CSHARP_LEXICAL_INVALID; a
    token count above MaxTokens or a bracket depth above MaxDepth yields TOKEN_LIMIT. Each is
    blocking and returns no token. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:CsRegexOptions = [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
$script:CsWhitespace = [regex]::new('\G[\t\u000B\u000C \u00A0\uFEFF\r\n\u2028\u2029\p{Zs}]+', $script:CsRegexOptions)
$script:CsLineComment = [regex]::new('\G//[^\r\n\u2028\u2029]*', $script:CsRegexOptions)
$script:CsBlockComment = [regex]::new('\G/\*[\s\S]*?\*/', $script:CsRegexOptions)
$script:CsDirective = [regex]::new('\G#[^\r\n\u2028\u2029]*', $script:CsRegexOptions)
$script:CsIdentifier = [regex]::new('\G@?(?:[\p{L}\p{Nl}_]|\\u[0-9A-Fa-f]{4}|\\U[0-9A-Fa-f]{8})(?:[\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}\p{Cf}]|\\u[0-9A-Fa-f]{4}|\\U[0-9A-Fa-f]{8})*', $script:CsRegexOptions)
$script:CsNumber = [regex]::new('\G(?:0[xX][0-9A-Fa-f](?:_*[0-9A-Fa-f])*|0[bB][01](?:_*[01])*|(?:[0-9](?:_*[0-9])*(?:\.[0-9](?:_*[0-9])*)?|\.[0-9](?:_*[0-9])*)(?:[eE][+-]?[0-9]+)?)[uUlLfFdDmM]{0,2}', $script:CsRegexOptions)
$script:CsCharacter = [regex]::new("\G'(?:[^'\\\r\n]|\\(?:x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8}|[\s\S]))'", $script:CsRegexOptions)
$script:CsRegularString = [regex]::new('\G"((?:[^"\\\r\n\u2028\u2029]|\\[\s\S])*)"', $script:CsRegexOptions)
$script:CsVerbatimBody = [regex]::new('\G((?:[^"]|"")*)"', $script:CsRegexOptions)
$script:CsRawOpen = [regex]::new('\G"{3,}', $script:CsRegexOptions)
$script:CsPunct = [regex]::new('\G(?:\?\?=|<<=|=>|==|!=|<=|>=|&&|\|\||\?\?|\?\.|\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|\^=|<<|::|->|\.\.|[{}()\[\];,<>+\-*/%&|^!~?:=.])', $script:CsRegexOptions)
$script:CsNewline = [regex]::new('\r\n|\r|\n|\u2028|\u2029', $script:CsRegexOptions)
$script:CsEscape = [regex]::new('\\(?:x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8}|[\s\S])', $script:CsRegexOptions)
$script:CsIdentifierEscape = [regex]::new('\\(?:u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})', $script:CsRegexOptions)
$script:CsKeyword = [string[]]@('abstract', 'as', 'base', 'bool', 'break', 'byte', 'case', 'catch', 'char', 'checked', 'class', 'const', 'continue', 'decimal', 'default', 'delegate', 'do', 'double', 'else', 'enum', 'event', 'explicit', 'extern', 'false', 'finally', 'fixed', 'float', 'for', 'foreach', 'goto', 'if', 'implicit', 'in', 'int', 'interface', 'internal', 'is', 'lock', 'long', 'namespace', 'new', 'null', 'object', 'operator', 'out', 'override', 'params', 'private', 'protected', 'public', 'readonly', 'ref', 'return', 'sbyte', 'sealed', 'short', 'sizeof', 'stackalloc', 'static', 'string', 'struct', 'switch', 'this', 'throw', 'true', 'try', 'typeof', 'uint', 'ulong', 'unchecked', 'unsafe', 'ushort', 'using', 'virtual', 'void', 'volatile', 'while')

function Get-DocsCSharpNewlineCount {
    <#
    .SYNOPSIS
        Returns the number of line terminators in Text (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    return $script:CsNewline.Matches($Text).Count
}

function ConvertFrom-DocsCSharpEscape {
    <#
    .SYNOPSIS
        Decodes the escape sequences of a regular string or character literal body (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Body)

    return $script:CsEscape.Replace($Body, {
            param($match)
            $sequence = $match.Value.Substring(1)
            switch -CaseSensitive ($sequence[0]) {
                'n' { return "`n" }
                't' { return "`t" }
                'r' { return "`r" }
                'b' { return "`b" }
                'f' { return "`f" }
                'v' { return "`v" }
                'a' { return "`a" }
                '0' { return "`0" }
                'e' { return [string][char]27 }
                'x' { return [string][char][System.Convert]::ToInt32($sequence.Substring(1), 16) }
                'u' { return [string][char][System.Convert]::ToInt32($sequence.Substring(1), 16) }
                'U' { return [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32($sequence.Substring(1), 16)) }
            }
            return $sequence
        })
}

function Add-DocsCSharpToken {
    <#
    .SYNOPSIS
        Appends one token to the scanner state and advances the depth and bounds (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [AllowNull()] [object] $Value,
        [bool] $Dynamic = $false,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine
    )

    $depth = [int] $State['Depth']
    $isOpen = ($Kind -ceq 'punct') -and ($Text -ceq '(' -or $Text -ceq '[' -or $Text -ceq '{')
    $isClose = ($Kind -ceq 'punct') -and ($Text -ceq ')' -or $Text -ceq ']' -or $Text -ceq '}')
    if ($isClose -and $depth -gt 0) { $depth--; $State['Depth'] = $depth }
    $State['Tokens'].Add([ordered]@{ Kind = $Kind; Text = $Text; Value = $Value; Dynamic = $Dynamic; Start = $Start; Line = $Line; EndLine = $EndLine; Depth = $depth })
    if ($isOpen) {
        $State['Depth'] = $depth + 1
        if ($depth + 1 -gt [int] $State['MaxDepth']) { $State['Error'] = [ordered]@{ Code = 'TOKEN_LIMIT'; Line = $Line; Message = "Bracket depth exceeds the bound of $($State['MaxDepth'])." } }
    }
    if ($State['Tokens'].Count -gt [int] $State['MaxTokens']) { $State['Error'] = [ordered]@{ Code = 'TOKEN_LIMIT'; Line = $Line; Message = "Token count exceeds the bound of $($State['MaxTokens'])." } }
}

function Read-DocsCSharpRawString {
    <#
    .SYNOPSIS
        Reads a raw string literal whose opening quote run starts at Position; returns @{ Length; Value } or $null (private helper).
    .DESCRIPTION
        DollarCount is the number of leading '$' (the interpolation brace width); holes are not
        parsed, so an interpolated raw string is Dynamic when DollarCount is above zero and the
        content holds a brace run of that width.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Position,
        [int] $DollarCount = 0
    )

    $open = $script:CsRawOpen.Match($Text, $Position)
    if (-not $open.Success) { return $null }
    $quotes = $open.Length
    $contentStart = $Position + $quotes
    $search = $contentStart
    while ($true) {
        $close = $Text.IndexOf('"' * $quotes, $search, [System.StringComparison]::Ordinal)
        if ($close -lt 0) { return $null }
        $run = $close
        while ($run -lt $Text.Length -and $Text[$run] -eq [char]'"') { $run++ }
        if ($run - $close -eq $quotes) { break }
        $search = $run
    }
    $content = $Text.Substring($contentStart, $close - $contentStart)
    $isMultiLine = $script:CsNewline.IsMatch($content)
    $value = if ($isMultiLine) { $null } else { $content }
    $dynamic = ($DollarCount -gt 0) -and ($content.Contains('{' * $DollarCount))
    return @{ Length = ($close + $quotes) - $Position; Value = $value; Dynamic = $dynamic }
}

function Read-DocsCSharpInterpolatedString {
    <#
    .SYNOPSIS
        Reads an interpolated string body starting after its opening quote; returns @{ Length; Value; Dynamic } or $null (private helper).
    .DESCRIPTION
        Verbatim selects doubled-quote escaping; otherwise backslash escapes apply. {{ and }}
        decode to one brace; a hole is skipped to its matching brace across nested strings and
        character literals and makes the token Dynamic (Value $null).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Position,
        [switch] $Verbatim
    )

    $builder = [System.Text.StringBuilder]::new()
    $dynamic = $false
    $index = $Position
    while ($index -lt $Text.Length) {
        $character = $Text[$index]
        if ($character -eq [char]'"') {
            if ($Verbatim -and $index + 1 -lt $Text.Length -and $Text[$index + 1] -eq [char]'"') { [void]$builder.Append('"'); $index += 2; continue }
            $value = if ($dynamic) { $null } elseif ($Verbatim) { $builder.ToString() } else { ConvertFrom-DocsCSharpEscape -Body $builder.ToString() }
            return @{ Length = $index + 1 - $Position; Value = $value; Dynamic = $dynamic }
        }
        if (-not $Verbatim -and $character -eq [char]'\') {
            if ($index + 1 -ge $Text.Length) { return $null }
            [void]$builder.Append($Text.Substring($index, 2)); $index += 2; continue
        }
        if (-not $Verbatim -and ($character -eq [char]"`r" -or $character -eq [char]"`n")) { return $null }
        if ($character -eq [char]'{') {
            if ($index + 1 -lt $Text.Length -and $Text[$index + 1] -eq [char]'{') { [void]$builder.Append('{'); $index += 2; continue }
            $dynamic = $true
            $depth = 1
            $index++
            while ($index -lt $Text.Length -and $depth -gt 0) {
                $inner = $Text[$index]
                if ($inner -eq [char]'{') { $depth++; $index++; continue }
                if ($inner -eq [char]'}') { $depth--; $index++; continue }
                if ($inner -eq [char]'"') {
                    $nested = $script:CsRegularString.Match($Text, $index)
                    if (-not $nested.Success) { return $null }
                    $index += $nested.Length; continue
                }
                if ($inner -eq [char]"'") {
                    $nested = $script:CsCharacter.Match($Text, $index)
                    $index += $(if ($nested.Success) { $nested.Length } else { 1 }); continue
                }
                $index++
            }
            if ($depth -ne 0) { return $null }
            continue
        }
        if ($character -eq [char]'}' -and $index + 1 -lt $Text.Length -and $Text[$index + 1] -eq [char]'}') { [void]$builder.Append('}'); $index += 2; continue }
        [void]$builder.Append($character)
        $index++
    }
    return $null
}

function Read-DocsCSharpString {
    <#
    .SYNOPSIS
        Reads any string literal form at State.Pos and appends its token; returns $false when no string starts there (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $text = [string] $State['Text']
    $position = [int] $State['Pos']
    $line = [int] $State['Line']
    $index = $position
    $dollars = 0
    $verbatim = $false
    while ($index -lt $text.Length -and ($text[$index] -eq [char]'$' -or $text[$index] -eq [char]'@')) {
        if ($text[$index] -eq [char]'$') { $dollars++ } else { $verbatim = $true }
        $index++
    }
    if ($index -ge $text.Length -or $text[$index] -ne [char]'"') { return $false }
    $result = $null
    $raw = $script:CsRawOpen.Match($text, $index)
    if ($raw.Success) {
        $read = Read-DocsCSharpRawString -Text $text -Position $index -DollarCount $dollars
        if ($null -ne $read) { $result = @{ Length = $index - $position + $read['Length']; Value = $read['Value']; Dynamic = $read['Dynamic'] } }
    } elseif ($dollars -gt 0) {
        $read = Read-DocsCSharpInterpolatedString -Text $text -Position ($index + 1) -Verbatim:$verbatim
        if ($null -ne $read) { $result = @{ Length = $index - $position + 1 + $read['Length']; Value = $read['Value']; Dynamic = $read['Dynamic'] } }
    } elseif ($verbatim) {
        $match = $script:CsVerbatimBody.Match($text, $index + 1)
        if ($match.Success) { $result = @{ Length = $index - $position + 1 + $match.Length; Value = $match.Groups[1].Value.Replace('""', '"'); Dynamic = $false } }
    } else {
        $match = $script:CsRegularString.Match($text, $index)
        if ($match.Success) { $result = @{ Length = $match.Length; Value = (ConvertFrom-DocsCSharpEscape -Body $match.Groups[1].Value); Dynamic = $false } }
    }
    if ($null -eq $result) {
        $State['Error'] = [ordered]@{ Code = 'CSHARP_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated string literal or raw newline in a string.' }
        return $true
    }
    $length = [int] $result['Length']
    if ($position + $length + 1 -lt $text.Length -and $text.Substring($position + $length, 2) -ceq 'u8') { $length += 2 }
    $source = $text.Substring($position, $length)
    $endLine = $line + (Get-DocsCSharpNewlineCount -Text $source)
    $State['Pos'] = $position + $length
    $State['Line'] = $endLine
    Add-DocsCSharpToken -State $State -Kind 'string' -Text $source -Value $result['Value'] -Dynamic ([bool] $result['Dynamic']) -Start $position -Line $line -EndLine $endLine
    return $true
}

function Test-DocsCSharpLineStart {
    <#
    .SYNOPSIS
        Returns $true when only whitespace precedes Position on its line (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Position
    )

    $index = $Position - 1
    while ($index -ge 0) {
        $character = $Text[$index]
        if ($character -eq [char]"`n" -or $character -eq [char]"`r") { return $true }
        if (-not [char]::IsWhiteSpace($character)) { return $false }
        $index--
    }
    return $true
}

function ConvertTo-DocsCSharpToken {
    <#
    .SYNOPSIS
        Tokenizes C# text into @{ Tokens; HasConditional; Diagnostics } within the token and depth bounds.
    .DESCRIPTION
        A lexical error or a bound overflow returns no token and exactly one blocking diagnostic
        @{ Code; Line; Message } with code CSHARP_LEXICAL_INVALID or TOKEN_LIMIT.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [ValidateRange(1, 2147483647)] [int] $MaxTokens = 250000,
        [ValidateRange(1, 2147483647)] [int] $MaxDepth = 256
    )

    $source = $Text
    if ($source.StartsWith([char]0xFEFF)) { $source = $source.Substring(1) }
    $state = @{ Text = $source; Pos = 0; Line = 1; Depth = 0; Tokens = [System.Collections.Generic.List[object]]::new(); Error = $null; MaxTokens = $MaxTokens; MaxDepth = $MaxDepth }
    $hasConditional = $false
    while ([int] $state['Pos'] -lt $source.Length -and $null -eq $state['Error']) {
        $position = [int] $state['Pos']
        $line = [int] $state['Line']
        $match = $script:CsWhitespace.Match($source, $position)
        if ($match.Success) {
            $state['Pos'] = $position + $match.Length
            $state['Line'] = $line + (Get-DocsCSharpNewlineCount -Text $match.Value)
            continue
        }
        $character = $source[$position]
        if ($character -eq [char]'/' -and $position + 1 -lt $source.Length) {
            $next = $source[$position + 1]
            if ($next -eq [char]'/') { $match = $script:CsLineComment.Match($source, $position); $state['Pos'] = $position + $match.Length; continue }
            if ($next -eq [char]'*') {
                $match = $script:CsBlockComment.Match($source, $position)
                if (-not $match.Success) { $state['Error'] = [ordered]@{ Code = 'CSHARP_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated block comment.' }; break }
                $state['Pos'] = $position + $match.Length
                $state['Line'] = $line + (Get-DocsCSharpNewlineCount -Text $match.Value)
                continue
            }
        }
        if ($character -eq [char]'#' -and (Test-DocsCSharpLineStart -Text $source -Position $position)) {
            $match = $script:CsDirective.Match($source, $position)
            if ($match.Value -cmatch '^#\s*if\b') { $hasConditional = $true }
            $state['Pos'] = $position + $match.Length
            continue
        }
        if ($character -eq [char]"'") {
            $match = $script:CsCharacter.Match($source, $position)
            if (-not $match.Success) { $state['Error'] = [ordered]@{ Code = 'CSHARP_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated character literal.' }; break }
            $state['Pos'] = $position + $match.Length
            Add-DocsCSharpToken -State $state -Kind 'string' -Text $match.Value -Value (ConvertFrom-DocsCSharpEscape -Body $match.Value.Substring(1, $match.Length - 2)) -Start $position -Line $line -EndLine $line
            continue
        }
        if (($character -eq [char]'"' -or $character -eq [char]'$' -or $character -eq [char]'@') -and (Read-DocsCSharpString -State $state)) { continue }
        $match = $script:CsNumber.Match($source, $position)
        if ($match.Success -and $match.Length -gt 0) {
            $state['Pos'] = $position + $match.Length
            Add-DocsCSharpToken -State $state -Kind 'number' -Text $match.Value -Start $position -Line $line -EndLine $line
            continue
        }
        $match = $script:CsIdentifier.Match($source, $position)
        if ($match.Success -and $match.Length -gt 0) {
            $spelling = $match.Value
            $name = $script:CsIdentifierEscape.Replace($spelling.TrimStart('@'), { param($escape) [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32($escape.Value.Substring(2), 16)) })
            $kind = if (-not $spelling.StartsWith('@') -and $script:CsKeyword -ccontains $name) { 'keyword' } else { 'identifier' }
            $state['Pos'] = $position + $match.Length
            Add-DocsCSharpToken -State $state -Kind $kind -Text $spelling -Value $name -Start $position -Line $line -EndLine $line
            continue
        }
        $match = $script:CsPunct.Match($source, $position)
        if (-not $match.Success) { $state['Error'] = [ordered]@{ Code = 'CSHARP_LEXICAL_INVALID'; Line = $line; Message = "Unexpected character at offset $position." }; break }
        $state['Pos'] = $position + $match.Length
        Add-DocsCSharpToken -State $state -Kind 'punct' -Text $match.Value -Start $position -Line $line -EndLine $line
    }
    if ($null -ne $state['Error']) { return @{ Tokens = [object[]]@(); HasConditional = $hasConditional; Diagnostics = [object[]]@($state['Error']) } }
    return @{ Tokens = [object[]] $state['Tokens'].ToArray(); HasConditional = $hasConditional; Diagnostics = [object[]]@() }
}

Export-ModuleMember -Function ConvertTo-DocsCSharpToken
