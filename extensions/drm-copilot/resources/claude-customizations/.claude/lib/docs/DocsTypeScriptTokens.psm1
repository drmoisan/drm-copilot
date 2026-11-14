<#
.SYNOPSIS
    Bounded lexical tokenizer for TypeScript source text used by the documentation scanners.

.DESCRIPTION
    ConvertTo-DocsTypeScriptToken returns @{ Tokens; Diagnostics } for one file. The scanner
    advances with \G-anchored regular-expression matches, one pattern per lexical state, so the
    PowerShell loop runs once per token. Tokens are ordered hashtables with Kind (identifier,
    keyword, string, template, number, regex, punct), Text, Value (decoded for a string and for a
    template without substitutions), Dynamic (a template with substitutions), Start, Line,
    EndLine and Depth (bracket depth at the token). Comments, whitespace, a leading U+FEFF and a
    line-1 hashbang produce no token. With -Jsx, a '<' where an expression can start that is
    followed by a tag name or '>' (and is not a type parameter list such as <T,> or <T extends U>)
    begins a JSX element: tag punctuators, names, '=' and attribute strings are tokens, expression
    containers are scanned by the normal tokenizer, and text runs produce no token.

    A raw newline in an ordinary string, an unterminated string, template, comment or regular
    expression yields TS_LEXICAL_INVALID; more than MaxTokens tokens or a bracket depth above
    MaxDepth yields TOKEN_LIMIT. Each is blocking and returns no token. Diagnostics carry no
    analyzer identifier: @{ Code; Line; Message }. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:TsRegexOptions = [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
$script:TsWhitespace = [regex]::new('\G[\t\u000B\u000C \u00A0\uFEFF\r\n\u2028\u2029\p{Zs}]+', $script:TsRegexOptions)
$script:TsLineComment = [regex]::new('\G//[^\r\n\u2028\u2029]*', $script:TsRegexOptions)
$script:TsBlockComment = [regex]::new('\G/\*[\s\S]*?\*/', $script:TsRegexOptions)
$script:TsIdentifier = [regex]::new('\G#?(?:[\p{L}\p{Nl}$_]|\\u[0-9A-Fa-f]{4}|\\u\{[0-9A-Fa-f]+\})(?:[\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}$_\u200C\u200D]|\\u[0-9A-Fa-f]{4}|\\u\{[0-9A-Fa-f]+\})*', $script:TsRegexOptions)
$script:TsNumber = [regex]::new('\G(?:0[xX][0-9A-Fa-f](?:_?[0-9A-Fa-f])*n?|0[oO][0-7](?:_?[0-7])*n?|0[bB][01](?:_?[01])*n?|(?:[0-9](?:_?[0-9])*(?:\.(?:[0-9](?:_?[0-9])*)?)?|\.[0-9](?:_?[0-9])*)(?:[eE][+-]?[0-9](?:_?[0-9])*)?n?)', $script:TsRegexOptions)
$script:TsSingleString = [regex]::new("\G'((?:[^'\\\r\n\u2028\u2029]|\\(?:\r\n|[\s\S]))*)'", $script:TsRegexOptions)
$script:TsDoubleString = [regex]::new('\G"((?:[^"\\\r\n\u2028\u2029]|\\(?:\r\n|[\s\S]))*)"', $script:TsRegexOptions)
$script:TsTemplateChunk = [regex]::new('\G(?:[^`\\$]|\\[\s\S]|\$(?!\{))*', $script:TsRegexOptions)
$script:TsRegexLiteral = [regex]::new('\G/(?:[^/\\\[\r\n]|\\[^\r\n]|\[(?:[^\]\\\r\n]|\\[^\r\n])*\])+/[A-Za-z]*', $script:TsRegexOptions)
$script:TsPunct = [regex]::new('\G(?:\.\.\.|===|!==|\*\*=|<<=|&&=|\|\|=|\?\?=|=>|==|!=|<=|>=|&&|\|\||\?\?|\?\.|\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|\^=|\*\*|<<|[{}()\[\];,<>+\-*/%&|^!~?:=.@])', $script:TsRegexOptions)
$script:TsNewline = [regex]::new('\r\n|\r|\n|\u2028|\u2029', $script:TsRegexOptions)
$script:TsEscape = [regex]::new('\\(?:\r\n|\r|\n|\u2028|\u2029|x[0-9A-Fa-f]{2}|u\{[0-9A-Fa-f]+\}|u[0-9A-Fa-f]{4}|[\s\S])', $script:TsRegexOptions)
$script:TsKeyword = [string[]]@('break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', 'default', 'delete', 'do', 'else', 'enum', 'export', 'extends', 'false', 'finally', 'for', 'function', 'if', 'import', 'in', 'instanceof', 'new', 'null', 'return', 'super', 'switch', 'this', 'throw', 'true', 'try', 'typeof', 'var', 'void', 'while', 'with', 'yield', 'let', 'static', 'await', 'implements', 'interface', 'package', 'private', 'protected', 'public')
$script:TsRegexKeyword = [string[]]@('return', 'typeof', 'instanceof', 'in', 'of', 'new', 'delete', 'void', 'throw', 'case', 'do', 'else', 'yield', 'await')
$script:TsJsxStart = [regex]::new('\G<(?:>|[\p{L}$_][\p{L}\p{Nd}$_.:\-]*)', $script:TsRegexOptions)
$script:TsJsxTypeParameter = [regex]::new('\G<[\p{L}$_][\p{L}\p{Nd}$_]*\s*(?:,|extends\b)', $script:TsRegexOptions)
$script:TsJsxName = [regex]::new('\G[\p{L}$_][\p{L}\p{Nd}$_.:\-]*', $script:TsRegexOptions)
$script:TsJsxString = [regex]::new('\G(?:"[^"]*"|''[^'']*'')', $script:TsRegexOptions)
$script:TsJsxText = [regex]::new('\G[^{<]+', $script:TsRegexOptions)

function Get-DocsTypeScriptNewlineCount {
    <#
    .SYNOPSIS
        Returns the number of line terminators in Text (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    return $script:TsNewline.Matches($Text).Count
}

function ConvertFrom-DocsTypeScriptEscape {
    <#
    .SYNOPSIS
        Decodes the escape sequences of a string or template body (private helper).
    .DESCRIPTION
        Handles \n \t \r \b \f \v \0 \xHH \uHHHH \u{H...}, a line continuation (removed), and any
        other escaped character (kept without the backslash). Line terminators are normalized to LF.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Body)

    $decoded = $script:TsEscape.Replace($Body, {
            param($match)
            $sequence = $match.Value.Substring(1)
            switch -CaseSensitive ($sequence[0]) {
                'n' { if ($sequence.Length -eq 1) { return "`n" } }
                't' { if ($sequence.Length -eq 1) { return "`t" } }
                'r' { if ($sequence.Length -eq 1) { return "`r" } }
                'b' { if ($sequence.Length -eq 1) { return "`b" } }
                'f' { if ($sequence.Length -eq 1) { return "`f" } }
                'v' { if ($sequence.Length -eq 1) { return "`v" } }
                '0' { if ($sequence.Length -eq 1) { return "`0" } }
                'x' { return [string][char][System.Convert]::ToInt32($sequence.Substring(1), 16) }
                'u' {
                    $hex = if ($sequence.StartsWith('u{')) { $sequence.Substring(2, $sequence.Length - 3) } else { $sequence.Substring(1) }
                    return [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32($hex, 16))
                }
            }
            if ($script:TsNewline.IsMatch($sequence)) { return '' }
            return $sequence
        })
    return $script:TsNewline.Replace($decoded, "`n")
}

function Add-DocsTypeScriptToken {
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
    $token = [ordered]@{ Kind = $Kind; Text = $Text; Value = $Value; Dynamic = $Dynamic; Start = $Start; Line = $Line; EndLine = $EndLine; Depth = $depth }
    $State['Tokens'].Add($token)
    $State['Previous'] = $token
    if ($isOpen) {
        $State['Depth'] = $depth + 1
        if ($depth + 1 -gt [int] $State['MaxDepth']) { $State['Error'] = [ordered]@{ Code = 'TOKEN_LIMIT'; Line = $Line; Message = "Bracket depth exceeds the bound of $($State['MaxDepth'])." } }
    }
    if ($State['Tokens'].Count -gt [int] $State['MaxTokens']) { $State['Error'] = [ordered]@{ Code = 'TOKEN_LIMIT'; Line = $Line; Message = "Token count exceeds the bound of $($State['MaxTokens'])." } }
}

function Test-DocsTypeScriptExpressionStart {
    <#
    .SYNOPSIS
        Returns $true when an expression can start after the previous significant token (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $previous = $State['Previous']
    if ($null -eq $previous) { return $true }
    $kind = [string] $previous['Kind']
    $text = [string] $previous['Text']
    if ($kind -ceq 'punct') { return -not ($text -ceq ')' -or $text -ceq ']' -or $text -ceq '}') }
    if ($kind -ceq 'keyword') { return $script:TsRegexKeyword -ccontains $text }
    return $false
}

function Read-DocsTypeScriptTemplate {
    <#
    .SYNOPSIS
        Reads one template literal starting at the backtick at State.Pos (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $text = [string] $State['Text']
    $start = [int] $State['Pos']
    $line = [int] $State['Line']
    $position = $start + 1
    $cooked = [System.Text.StringBuilder]::new()
    $dynamic = $false
    while ($true) {
        $chunk = $script:TsTemplateChunk.Match($text, $position)
        [void]$cooked.Append($chunk.Value)
        $position += $chunk.Length
        if ($position -ge $text.Length) {
            $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated template literal.' }
            return
        }
        if ($text[$position] -eq [char]'`') { $position++; break }
        # A substitution: tokenize the expression up to its closing brace with the normal scanner.
        $dynamic = $true
        $State['Pos'] = $position + 2
        $State['Line'] = $line + (Get-DocsTypeScriptNewlineCount -Text $text.Substring($start, $position - $start))
        $saved = $State['Previous']
        $count = $State['Tokens'].Count
        $State['Previous'] = $null
        Invoke-DocsTypeScriptTokenRun -State $State -StopAtBrace
        $State['Previous'] = $saved
        if ($null -ne $State['Error']) { return }
        # The substitution's tokens only delimit the template; the template is one token.
        $State['Tokens'].RemoveRange($count, $State['Tokens'].Count - $count)
        $position = [int] $State['Pos']
        if ($position -ge $text.Length -or $text[$position] -ne [char]'}') {
            $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated template substitution.' }
            return
        }
        $position++
    }
    $source = $text.Substring($start, $position - $start)
    $endLine = $line + (Get-DocsTypeScriptNewlineCount -Text $source)
    $value = if ($dynamic) { $null } else { ConvertFrom-DocsTypeScriptEscape -Body $cooked.ToString() }
    $State['Pos'] = $position
    $State['Line'] = $endLine
    Add-DocsTypeScriptToken -State $State -Kind 'template' -Text $source -Value $value -Dynamic $dynamic -Start $start -Line $line -EndLine $endLine
}

function Test-DocsTypeScriptJsxStart {
    <#
    .SYNOPSIS
        Returns $true when the '<' at Position begins a JSX element or fragment rather than a type parameter list (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Position
    )

    if (-not $script:TsJsxStart.IsMatch($Text, $Position)) { return $false }
    return -not $script:TsJsxTypeParameter.IsMatch($Text, $Position)
}

function Read-DocsTypeScriptJsxSkip {
    <#
    .SYNOPSIS
        Advances the scanner over a match of Pattern (whitespace or JSX text) without emitting a token (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [regex] $Pattern
    )

    $match = $Pattern.Match([string] $State['Text'], [int] $State['Pos'])
    if (-not $match.Success) { return }
    $State['Pos'] = [int] $State['Pos'] + $match.Length
    $State['Line'] = [int] $State['Line'] + (Get-DocsTypeScriptNewlineCount -Text $match.Value)
}

function Read-DocsTypeScriptJsxExpression {
    <#
    .SYNOPSIS
        Reads a '{ ... }' JSX expression container at State.Pos with the normal scanner (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $text = [string] $State['Text']
    $open = [int] $State['Pos']
    $State['Pos'] = $open + 1
    Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '{' -Start $open -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
    $saved = $State['Previous']
    $State['Previous'] = $null
    Invoke-DocsTypeScriptTokenRun -State $State -StopAtBrace
    $State['Previous'] = $saved
    if ($null -ne $State['Error']) { return }
    $close = [int] $State['Pos']
    if ($close -ge $text.Length -or $text[$close] -ne [char]'}') { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = [int] $State['Line']; Message = 'Unterminated JSX expression container.' }; return }
    $State['Pos'] = $close + 1
    Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '}' -Start $close -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
}

function Read-DocsTypeScriptJsxElement {
    <#
    .SYNOPSIS
        Reads one JSX element or fragment starting at the '<' at State.Pos, including nested elements (private helper).
    .DESCRIPTION
        Tag punctuators ('<', '</', '>', '/>'), tag and attribute names (identifier), '=' and
        attribute strings (string, raw value) are emitted; expression containers are tokenized by
        the normal scanner; text runs produce no token, so an apostrophe in text is not a string
        delimiter. Element nesting counts against the depth bound.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $text = [string] $State['Text']
    $open = [int] $State['Pos']
    $State['Pos'] = $open + 1
    Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '<' -Start $open -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
    $State['Depth'] = [int] $State['Depth'] + 1
    if ([int] $State['Depth'] -gt [int] $State['MaxDepth']) { $State['Error'] = [ordered]@{ Code = 'TOKEN_LIMIT'; Line = [int] $State['Line']; Message = "Bracket depth exceeds the bound of $($State['MaxDepth'])." }; return }
    $name = $script:TsJsxName.Match($text, [int] $State['Pos'])
    if ($name.Success) {
        Add-DocsTypeScriptToken -State $State -Kind 'identifier' -Text $name.Value -Start ([int] $State['Pos']) -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
        $State['Pos'] = [int] $State['Pos'] + $name.Length
    }
    # Attributes until '>' or '/>'.
    while ($null -eq $State['Error']) {
        Read-DocsTypeScriptJsxSkip -State $State -Pattern $script:TsWhitespace
        $position = [int] $State['Pos']
        $line = [int] $State['Line']
        if ($position -ge $text.Length) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated JSX tag.' }; return }
        $character = $text[$position]
        if ($character -eq [char]'/' -and $position + 1 -lt $text.Length -and $text[$position + 1] -eq [char]'>') {
            $State['Pos'] = $position + 2
            Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '/>' -Start $position -Line $line -EndLine $line
            $State['Depth'] = [int] $State['Depth'] - 1
            return
        }
        if ($character -eq [char]'>') { $State['Pos'] = $position + 1; Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '>' -Start $position -Line $line -EndLine $line; break }
        if ($character -eq [char]'{') { Read-DocsTypeScriptJsxExpression -State $State; continue }
        if ($character -eq [char]'=') { $State['Pos'] = $position + 1; Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '=' -Start $position -Line $line -EndLine $line; continue }
        if ($character -eq [char]'"' -or $character -eq [char]"'") {
            $match = $script:TsJsxString.Match($text, $position)
            if (-not $match.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated JSX attribute string.' }; return }
            $endLine = $line + (Get-DocsTypeScriptNewlineCount -Text $match.Value)
            $State['Pos'] = $position + $match.Length
            $State['Line'] = $endLine
            Add-DocsTypeScriptToken -State $State -Kind 'string' -Text $match.Value -Value $match.Value.Substring(1, $match.Length - 2) -Start $position -Line $line -EndLine $endLine
            continue
        }
        if ($character -eq [char]'<') { Read-DocsTypeScriptJsxElement -State $State; continue }
        $attribute = $script:TsJsxName.Match($text, $position)
        if (-not $attribute.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = "Unexpected character in a JSX tag at offset $position." }; return }
        $State['Pos'] = $position + $attribute.Length
        Add-DocsTypeScriptToken -State $State -Kind 'identifier' -Text $attribute.Value -Start $position -Line $line -EndLine $line
    }
    # Children until the closing tag.
    while ($null -eq $State['Error']) {
        Read-DocsTypeScriptJsxSkip -State $State -Pattern $script:TsJsxText
        $position = [int] $State['Pos']
        $line = [int] $State['Line']
        if ($position -ge $text.Length) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated JSX element.' }; return }
        if ($text[$position] -eq [char]'{') { Read-DocsTypeScriptJsxExpression -State $State; continue }
        if ($position + 1 -lt $text.Length -and $text[$position + 1] -eq [char]'/') {
            $State['Pos'] = $position + 2
            Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '</' -Start $position -Line $line -EndLine $line
            Read-DocsTypeScriptJsxSkip -State $State -Pattern $script:TsWhitespace
            $closing = $script:TsJsxName.Match($text, [int] $State['Pos'])
            if ($closing.Success) {
                Add-DocsTypeScriptToken -State $State -Kind 'identifier' -Text $closing.Value -Start ([int] $State['Pos']) -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
                $State['Pos'] = [int] $State['Pos'] + $closing.Length
            }
            Read-DocsTypeScriptJsxSkip -State $State -Pattern $script:TsWhitespace
            $end = [int] $State['Pos']
            if ($end -ge $text.Length -or $text[$end] -ne [char]'>') { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = [int] $State['Line']; Message = 'Unterminated JSX closing tag.' }; return }
            $State['Pos'] = $end + 1
            Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text '>' -Start $end -Line ([int] $State['Line']) -EndLine ([int] $State['Line'])
            $State['Depth'] = [int] $State['Depth'] - 1
            return
        }
        Read-DocsTypeScriptJsxElement -State $State
    }
}

function Invoke-DocsTypeScriptTokenRun {
    <#
    .SYNOPSIS
        Scans tokens from State.Pos until the end of the text or, with -StopAtBrace, an unmatched '}' (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [switch] $StopAtBrace
    )

    $text = [string] $State['Text']
    $braces = 0
    while ([int] $State['Pos'] -lt $text.Length -and $null -eq $State['Error']) {
        $position = [int] $State['Pos']
        $line = [int] $State['Line']
        $match = $script:TsWhitespace.Match($text, $position)
        if ($match.Success) {
            $State['Pos'] = $position + $match.Length
            $State['Line'] = $line + (Get-DocsTypeScriptNewlineCount -Text $match.Value)
            continue
        }
        $character = $text[$position]
        if ($character -eq [char]'/' -and $position + 1 -lt $text.Length) {
            $next = $text[$position + 1]
            if ($next -eq [char]'/') { $match = $script:TsLineComment.Match($text, $position); $State['Pos'] = $position + $match.Length; continue }
            if ($next -eq [char]'*') {
                $match = $script:TsBlockComment.Match($text, $position)
                if (-not $match.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated block comment.' }; return }
                $State['Pos'] = $position + $match.Length
                $State['Line'] = $line + (Get-DocsTypeScriptNewlineCount -Text $match.Value)
                continue
            }
        }
        if ($character -eq [char]'`') { Read-DocsTypeScriptTemplate -State $State; continue }
        if ($character -eq [char]"'" -or $character -eq [char]'"') {
            $pattern = if ($character -eq [char]"'") { $script:TsSingleString } else { $script:TsDoubleString }
            $match = $pattern.Match($text, $position)
            if (-not $match.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated string literal or raw newline in a string.' }; return }
            $endLine = $line + (Get-DocsTypeScriptNewlineCount -Text $match.Value)
            $State['Pos'] = $position + $match.Length
            $State['Line'] = $endLine
            Add-DocsTypeScriptToken -State $State -Kind 'string' -Text $match.Value -Value (ConvertFrom-DocsTypeScriptEscape -Body $match.Groups[1].Value) -Start $position -Line $line -EndLine $endLine
            continue
        }
        $match = $script:TsNumber.Match($text, $position)
        if ($match.Success -and $match.Length -gt 0) {
            $State['Pos'] = $position + $match.Length
            Add-DocsTypeScriptToken -State $State -Kind 'number' -Text $match.Value -Start $position -Line $line -EndLine $line
            continue
        }
        $match = $script:TsIdentifier.Match($text, $position)
        if ($match.Success -and $match.Length -gt 0) {
            $kind = if ($script:TsKeyword -ccontains $match.Value) { 'keyword' } else { 'identifier' }
            $State['Pos'] = $position + $match.Length
            Add-DocsTypeScriptToken -State $State -Kind $kind -Text $match.Value -Start $position -Line $line -EndLine $line
            continue
        }
        $expressionStart = Test-DocsTypeScriptExpressionStart -State $State
        if ($character -eq [char]'/' -and $expressionStart) {
            $match = $script:TsRegexLiteral.Match($text, $position)
            if (-not $match.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = 'Unterminated regular expression literal.' }; return }
            $State['Pos'] = $position + $match.Length
            Add-DocsTypeScriptToken -State $State -Kind 'regex' -Text $match.Value -Start $position -Line $line -EndLine $line
            continue
        }
        if ($character -eq [char]'<' -and [bool] $State['Jsx'] -and $expressionStart -and (Test-DocsTypeScriptJsxStart -Text $text -Position $position)) {
            Read-DocsTypeScriptJsxElement -State $State
            continue
        }
        $match = $script:TsPunct.Match($text, $position)
        if (-not $match.Success) { $State['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = $line; Message = "Unexpected character at offset $position." }; return }
        if ($match.Value -ceq '{') { $braces++ }
        if ($match.Value -ceq '}') {
            if ($StopAtBrace -and $braces -eq 0) { return }
            $braces--
        }
        $State['Pos'] = $position + $match.Length
        Add-DocsTypeScriptToken -State $State -Kind 'punct' -Text $match.Value -Start $position -Line $line -EndLine $line
    }
}

function ConvertTo-DocsTypeScriptToken {
    <#
    .SYNOPSIS
        Tokenizes TypeScript text into @{ Tokens; Diagnostics } within the token and depth bounds.
    .DESCRIPTION
        -Jsx enables the JSX lexical state for .tsx inputs. A lexical error or a bound overflow
        returns no token and exactly one blocking diagnostic @{ Code; Line; Message } with code
        TS_LEXICAL_INVALID or TOKEN_LIMIT.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [switch] $Jsx,
        [ValidateRange(1, 2147483647)] [int] $MaxTokens = 250000,
        [ValidateRange(1, 2147483647)] [int] $MaxDepth = 256
    )

    $source = $Text
    if ($source.StartsWith([char]0xFEFF)) { $source = $source.Substring(1) }
    $state = @{ Text = $source; Pos = 0; Line = 1; Depth = 0; Tokens = [System.Collections.Generic.List[object]]::new(); Previous = $null; Error = $null; MaxTokens = $MaxTokens; MaxDepth = $MaxDepth; Jsx = [bool] $Jsx }
    if ($source.StartsWith('#!')) {
        $end = $source.IndexOfAny([char[]]@("`r", "`n", [char]0x2028, [char]0x2029))
        $state['Pos'] = if ($end -lt 0) { $source.Length } else { $end }
    }
    Invoke-DocsTypeScriptTokenRun -State $state
    if ($null -eq $state['Error'] -and [int] $state['Pos'] -lt $source.Length) {
        $state['Error'] = [ordered]@{ Code = 'TS_LEXICAL_INVALID'; Line = [int] $state['Line']; Message = 'Unexpected closing brace.' }
    }
    if ($null -ne $state['Error']) { return @{ Tokens = [object[]]@(); Diagnostics = [object[]]@($state['Error']) } }
    return @{ Tokens = [object[]] $state['Tokens'].ToArray(); Diagnostics = [object[]]@() }
}

Export-ModuleMember -Function ConvertTo-DocsTypeScriptToken
