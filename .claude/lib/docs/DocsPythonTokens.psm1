<#
.SYNOPSIS
    Bounded Python lexer for the issue #1022 scanners: one \G-anchored regex alternation over
    the normalized source text producing a flat token list with line and column.

.DESCRIPTION
    Get-DocsPythonToken returns @{ Tokens; Diagnostics }. Token classes in match order are
    NEWLINE, CONTINUATION, COMMENT, STRING, NAME, NUMBER, OP and WHITESPACE; concatenating the
    token texts reproduces the normalized text. A STRING token records Prefix, IsTriple,
    HasEscape, IsBytes, IsFormat and IsRaw; a NAME token records IsKeyword (case-sensitive);
    an OP bracket records the running Depth. Diagnostics (each blocking, severity error, with
    the line) are PYTHON_ENCODING_UNSUPPORTED (a coding cookie naming another encoding),
    PYTHON_LEXER_UNTERMINATED (an unterminated string, an unbalanced bracket or a backslash
    continuation at end of input), PYTHON_LEXER_UNCLASSIFIED (a character outside the grammar
    outside strings and comments, bracket depth above 64, or f-string replacement fields nested
    more than two levels) and PYTHON_TOKEN_LIMIT (more than 262,144 non-whitespace tokens). The
    scan-record pattern of the Mermaid line scanner is followed; its functions are not called.
    The token loop lexes a bounded window of the source, re-sliced after a string token and near
    the window end, so no call in the loop passes the whole source as an argument.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1022. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
    Issue #1019: the measured per-call cost that grows with string argument length is in the
    PowerShell method-invocation layer (the same .NET call from compiled C# is flat). The AMSI
    attribution in the retained comments in Read-DocsPythonStringEnd and at the token loop head
    is unverified.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop

$script:DocsPythonTokenLimit = 262144
$script:DocsPythonBracketLimit = 64
$script:DocsPythonTokenWindowSize = 1024
$script:DocsPythonTokenWindowMargin = 8
$script:DocsPythonKeywordList = [string[]]@('def', 'class', 'async', 'import', 'from', 'as', 'for', 'while', 'if', 'elif', 'else', 'try', 'except', 'finally', 'with', 'lambda', 'return')
$script:DocsPythonOperatorAlternation = '\*\*=|//=|>>=|<<=|\.\.\.|->|:=|\*\*|//|>>|<<|<=|>=|==|!=|\+=|-=|\*=|/=|%=|&=|\|=|\^=|@=|[-+*/%&|^~<>()\[\]{},:.;=@]'
$script:DocsPythonNumberAlternation = '0[xX][0-9a-fA-F_]+|0[oO][0-7_]+|0[bB][01_]+|(?:[0-9][0-9_]*)?\.[0-9][0-9_]*(?:[eE][-+]?[0-9][0-9_]*)?[jJ]?|[0-9][0-9_]*\.?(?:[eE][-+]?[0-9][0-9_]*)?[jJ]?'
$script:DocsPythonTokenPattern = [regex]::new(
    '\G(?:' +
    '(?<newline>\n)|' +
    '(?<continuation>\\(?:\n|\z))|' +
    '(?<comment>#[^\n]*)|' +
    '(?<string>(?<prefix>[rR][bBfF]?|[bBfF][rR]?|[uU])?(?<quote>''''''|"""|''|"))|' +
    '(?<name>[\p{L}\p{Nl}_][\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}]*)|' +
    '(?<number>' + $script:DocsPythonNumberAlternation + ')|' +
    '(?<op>' + $script:DocsPythonOperatorAlternation + ')|' +
    '(?<whitespace>[ \t\f]+)' +
    ')',
    [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:DocsPythonCodingCookiePattern = [regex]::new('^[ \t\f]*#.*?coding[:=][ \t]*([-\w.]+)')

function Read-DocsPythonStringEnd {
    <#
    .SYNOPSIS
        Scans a string body from the character after its opening quote (private helper).
    .DESCRIPTION
        Returns @{ End (index after the closing quote, or -1 when unterminated); HasEscape;
        NestingExceeded }. A backslash consumes the next character in every string so it protects
        the quote in a raw string as well. An f-string tracks replacement-field braces and the
        strings nested inside them, up to two nesting levels.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [string] $Quote,
        [Parameter(Mandatory = $true)] [bool] $IsFormat,
        [Parameter(Mandatory = $true)] [int] $Level
    )

    $isTriple = $Quote.Length -eq 3
    $index = $Start
    $hasEscape = $false
    $nestingExceeded = $false
    $braceDepth = 0
    while ($index -lt $Text.Length) {
        $character = $Text[$index]
        if ($character -eq '\') {
            $hasEscape = $true
            $index += 2
            continue
        }
        # Compare a slice: passing $Text itself to a .NET method costs time proportional to its length per call on an AMSI-enabled host.
        if ($braceDepth -eq 0 -and $index + $Quote.Length -le $Text.Length -and [string]::CompareOrdinal($Text.Substring($index, $Quote.Length), $Quote) -eq 0) {
            return @{ End = $index + $Quote.Length; HasEscape = $hasEscape; NestingExceeded = $nestingExceeded }
        }
        if (-not $isTriple -and $character -eq "`n" -and $braceDepth -eq 0) { break }
        if ($IsFormat) {
            if ($character -eq '{') {
                if ($braceDepth -eq 0 -and $index + 1 -lt $Text.Length -and $Text[$index + 1] -eq '{') { $index += 2; continue }
                if ($braceDepth -eq 0 -and $Level -ge 2) { return @{ End = -1; HasEscape = $hasEscape; NestingExceeded = $true } }
                $braceDepth++
                $index++
                continue
            }
            if ($character -eq '}') {
                if ($braceDepth -eq 0) {
                    if ($index + 1 -lt $Text.Length -and $Text[$index + 1] -eq '}') { $index += 2; continue }
                } else { $braceDepth-- }
                $index++
                continue
            }
            if ($braceDepth -gt 0 -and ($character -eq '''' -or $character -eq '"')) {
                $innerQuote = if ($index + 3 -le $Text.Length -and [string]::CompareOrdinal($Text.Substring($index, 3), [string] $character * 3) -eq 0) { [string] $character * 3 } else { [string] $character }
                $inner = Read-DocsPythonStringEnd -Text $Text -Start ($index + $innerQuote.Length) -Quote $innerQuote -IsFormat $true -Level ($Level + 1)
                if ($inner['NestingExceeded']) { return @{ End = -1; HasEscape = $hasEscape; NestingExceeded = $true } }
                if ($inner['End'] -lt 0) { return @{ End = -1; HasEscape = $hasEscape; NestingExceeded = $false } }
                $index = $inner['End']
                continue
            }
        }
        $index++
    }
    return @{ End = -1; HasEscape = $hasEscape; NestingExceeded = $nestingExceeded }
}

function Get-DocsPythonToken {
    <#
    .SYNOPSIS
        Tokenizes normalized Python text and returns @{ Tokens; Diagnostics }.
    .DESCRIPTION
        Text is normalized with ConvertTo-DocsSourceLine (BOM, CRLF and CR). Each token is a
        hashtable with Type, Text, Line (1-based), Column (0-based) and EndLine, plus the
        class-specific members described in the module description. A diagnostic is a hashtable
        with Code, Severity 'error', Blocking $true and Line; the first blocking condition ends
        the scan.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $lines = ConvertTo-DocsSourceLine -Text $Text
    $sourceText = $lines -join "`n"
    $tokens = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()

    for ($cookieLine = 0; $cookieLine -lt [math]::Min(2, $lines.Count); $cookieLine++) {
        $cookie = $script:DocsPythonCodingCookiePattern.Match($lines[$cookieLine])
        if ($cookie.Success -and $cookie.Groups[1].Value -notmatch '^(?:utf-8|utf8|utf_8)$') {
            $diagnostics.Add(@{ Code = 'PYTHON_ENCODING_UNSUPPORTED'; Severity = 'error'; Blocking = $true; Line = $cookieLine + 1 })
            return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
        }
    }

    $windowStart = 0
    $windowSize = $script:DocsPythonTokenWindowSize
    # $source is a bounded window of $sourceText inside the loop, so "the whole source" in the loop-head comment means that window; Match also runs after a margin rebase.
    $source = $sourceText.Substring(0, [math]::Min($windowSize, $sourceText.Length))
    $position = 0
    $line = 1
    $lineStart = 0
    $depth = 0
    $counted = 0
    $match = $null
    while ($position -lt $source.Length) {
        # NextMatch continues at the previous match end through \G and passes no argument. A Match call passes
        # the whole source, which costs time proportional to its length per call on an AMSI-enabled host, so it
        # runs only for the first token and after a string token, whose body the pattern does not consume.
        if ($null -ne $match -and $match.Index + $match.Length -eq $position) {
            $match = $match.NextMatch()
        } else {
            $match = $script:DocsPythonTokenPattern.Match($source, $position)
        }
        if (-not $match.Success) {
            $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNCLASSIFIED'; Severity = 'error'; Blocking = $true; Line = $line })
            return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
        }
        if ($windowStart + $source.Length -lt $sourceText.Length -and $match.Index + $match.Length -gt $source.Length - $script:DocsPythonTokenWindowMargin) {
            $windowSize = if ($position -eq 0) { $windowSize * 2 } else { $script:DocsPythonTokenWindowSize }
            $windowStart += $position
            $lineStart -= $position
            $position = 0
            $source = $sourceText.Substring($windowStart, [math]::Min($windowSize, $sourceText.Length - $windowStart))
            $match = $null
            continue
        }
        $column = $position - $lineStart
        $token = $null
        if ($match.Groups['string'].Success) {
            $prefix = $match.Groups['prefix'].Value
            $quote = $match.Groups['quote'].Value
            $isFormat = $prefix.IndexOfAny([char[]]@('f', 'F')) -ge 0
            $scan = Read-DocsPythonStringEnd -Text $sourceText -Start ($windowStart + $match.Index + $match.Length) -Quote $quote -IsFormat $isFormat -Level 0
            if ($scan['NestingExceeded']) {
                $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNCLASSIFIED'; Severity = 'error'; Blocking = $true; Line = $line })
                return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
            }
            if ($scan['End'] -lt 0) {
                $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNTERMINATED'; Severity = 'error'; Blocking = $true; Line = $line })
                return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
            }
            $text = $sourceText.Substring($windowStart + $position, $scan['End'] - $windowStart - $position)
            $token = @{ Type = 'STRING'; Text = $text; Prefix = $prefix; Quote = $quote; IsTriple = ($quote.Length -eq 3); HasEscape = $scan['HasEscape']; IsBytes = ($prefix.IndexOfAny([char[]]@('b', 'B')) -ge 0); IsFormat = $isFormat; IsRaw = ($prefix.IndexOfAny([char[]]@('r', 'R')) -ge 0) }
        } elseif ($match.Groups['name'].Success) {
            $token = @{ Type = 'NAME'; Text = $match.Value; IsKeyword = ($script:DocsPythonKeywordList -ccontains $match.Value) }
        } elseif ($match.Groups['op'].Success) {
            $text = $match.Value
            if ($text -eq '(' -or $text -eq '[' -or $text -eq '{') {
                $depth++
                if ($depth -gt $script:DocsPythonBracketLimit) {
                    $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNCLASSIFIED'; Severity = 'error'; Blocking = $true; Line = $line })
                    return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
                }
            } elseif ($text -eq ')' -or $text -eq ']' -or $text -eq '}') {
                if ($depth -eq 0) {
                    $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNTERMINATED'; Severity = 'error'; Blocking = $true; Line = $line })
                    return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
                }
                $depth--
            }
            $token = @{ Type = 'OP'; Text = $text; Depth = $depth }
        } elseif ($match.Groups['number'].Success) {
            $token = @{ Type = 'NUMBER'; Text = $match.Value }
        } elseif ($match.Groups['comment'].Success) {
            $token = @{ Type = 'COMMENT'; Text = $match.Value }
        } elseif ($match.Groups['newline'].Success) {
            $token = @{ Type = 'NEWLINE'; Text = $match.Value; Depth = $depth }
        } elseif ($match.Groups['continuation'].Success) {
            $token = @{ Type = 'CONTINUATION'; Text = $match.Value }
        } else {
            $token = @{ Type = 'WHITESPACE'; Text = $match.Value }
        }
        $token['Line'] = $line
        $token['Column'] = $column
        $position += $token['Text'].Length
        $newlineCount = 0
        $lastNewline = $token['Text'].LastIndexOf("`n")
        if ($lastNewline -ge 0) {
            foreach ($character in $token['Text'].ToCharArray()) { if ($character -eq "`n") { $newlineCount++ } }
            $lineStart = $position - ($token['Text'].Length - $lastNewline - 1)
        }
        $line += $newlineCount
        $token['EndLine'] = $line - $(if ($token['Type'] -eq 'NEWLINE' -or $token['Type'] -eq 'CONTINUATION') { 1 } else { 0 })
        if ($token['Type'] -ne 'WHITESPACE') {
            $counted++
            if ($counted -gt $script:DocsPythonTokenLimit) {
                $diagnostics.Add(@{ Code = 'PYTHON_TOKEN_LIMIT'; Severity = 'error'; Blocking = $true; Line = $token['Line'] })
                return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
            }
        }
        $tokens.Add($token)
        if ($token['Type'] -ceq 'STRING') {
            $windowSize = $script:DocsPythonTokenWindowSize
            $windowStart += $position
            $lineStart -= $position
            $position = 0
            $source = $sourceText.Substring($windowStart, [math]::Min($windowSize, $sourceText.Length - $windowStart))
            $match = $null
        }
    }

    if ($tokens.Count -gt 0 -and $tokens[$tokens.Count - 1]['Type'] -eq 'CONTINUATION') {
        $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNTERMINATED'; Severity = 'error'; Blocking = $true; Line = $tokens[$tokens.Count - 1]['Line'] })
    } elseif ($depth -gt 0) {
        $diagnostics.Add(@{ Code = 'PYTHON_LEXER_UNTERMINATED'; Severity = 'error'; Blocking = $true; Line = $line })
    }
    return @{ Tokens = $tokens.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsPythonToken
