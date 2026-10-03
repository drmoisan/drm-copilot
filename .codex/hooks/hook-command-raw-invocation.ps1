<#
.SYNOPSIS
    Token-aware raw-text invocation matcher for wrapper-led and live-substitution segments.
.DESCRIPTION
    Realizes the corrected R2 fail-closed rule of issue #824 and its remediation cycle 1
    corrections. A wrapper-led or live-substitution segment carries its nested command line
    inside its raw text, often inside a quoted -Command or -c argument, so the structural
    token walk cannot see it. This module answers whether that raw text contains the
    command word followed by every subcommand element as a token-bounded, ordered sequence,
    rather than merely containing each word somewhere as a substring.

    Matching rules, applied case-insensitively and culture-invariantly:
      - A command or subcommand position is bounded on both sides: no word character or
        hyphen may touch it, so 'gh' inside 'through' and 'new' inside 'New-Object' do not
        match.
      - The command word may carry a '.exe' suffix and may be followed by a closing quote,
        optionally backslash-escaped, so quoted and path-qualified spellings still match.
      - Positions are separated by whitespace or by a backslash-newline continuation.
      - Before each subcommand element, a run of dash-leading options is skipped, each with
        an optional quoted or unquoted value, so 'gh -R o/r issue create' still matches.
      - Sequence form: a shell expansion ('$name', '${...}', '$(...)', or a backtick span)
        may stand in for any position, because its run-time value is unknown. A match
        counts only when at least one position matched its literal, and, when the command
        position is an expansion, only when the command word also occurs token-bounded
        somewhere in the raw text.
      - Absorption form: the literal command word, the first k subcommand elements as
        literals, then one absorbing token (an expansion, '@name', or '@(...)') that may
        carry the remaining elements. A match counts only when every remaining element
        occurs token-bounded somewhere in the raw text, so 'gh $cmd' classifies when the
        script that assigns $cmd names 'issue' and 'create'.

    Get-CommandLineRawInvocationOperand reads the operand of such an invocation, and
    Resolve-CommandLineWrappedInvocationOperand applies it to the segment a wrapped removal
    classified on. The latter calls Resolve-CommandLineInvocation, which is defined in
    hook-command-invocation.ps1; that module dot-sources this file, so the function resolves
    at call time (a runtime dependency, not a load-time one).

    Pure string logic only: no disk, process, network, clock, or environment access. It is
    dot-sourced by hook-command-invocation.ps1 as:
    . (Join-Path $PSScriptRoot 'hook-command-raw-invocation.ps1')
#>

function Get-CommandLineRawInvocationPattern {
    <#
    .SYNOPSIS
        Build the token-aware sequence or absorption pattern for one command word and
        subcommand path.
    .DESCRIPTION
        Without AbsorbAt, returns the sequence pattern: each literal position is captured in
        a named group 'literalN' (N = 0 for the command word, 1.. for the subcommand
        elements), and a shell expansion standing in for a position leaves that group
        unmatched. With AbsorbAt k, returns the absorption pattern: the literal command
        word, the first k subcommand elements as literals, then one absorbing token. Both
        patterns capture the whole invocation in the group 'seq' and are wrapped in a
        zero-width lookahead, so that every start index of the raw text is tried.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath,
        [ValidateRange(-1, 64)][int] $AbsorbAt = -1
    )

    $separator = '(?:\s|\\\r?\n)+'
    $expansion = '\$[A-Za-z_]\w*|\$\{[^}]*\}|\$\([^)]*\)|`[^`]*`'
    $absorber = $expansion + '|@[A-Za-z_]\w*|@\([^)]*\)'
    $quote = '(?:\\?[''"])?'
    $boundary = '(?![\w-])'
    $optionRun = '(?:' + $separator + '-[^\s''"]*(?:' + $separator + '(?:"[^"]*"|''[^'']*''|[^\s''"-][^\s''"]*))?)*'
    $absorbing = $AbsorbAt -ge 0
    $standIn = if ($absorbing) { '' } else { '|(?:' + $expansion + ')' }
    $literalCount = if ($absorbing) { $AbsorbAt } else { $SubcommandPath.Count }

    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append('(?<![\w-])(?<seq>(?:(?<literal0>' + [regex]::Escape($CommandWord) + '(?:\.exe)?)')
    [void]$builder.Append($standIn + ')' + $boundary + $quote)

    for ($position = 0; $position -lt $literalCount; $position++) {
        $groupName = 'literal' + ($position + 1)
        [void]$builder.Append($optionRun + $separator + $quote)
        [void]$builder.Append('(?:(?<' + $groupName + '>' + [regex]::Escape($SubcommandPath[$position]) + ')')
        [void]$builder.Append($standIn + ')' + $boundary + $quote)
    }

    if ($absorbing) {
        [void]$builder.Append($optionRun + $separator + $quote + '(?:' + $absorber + ')' + $boundary)
    }

    return '(?=' + $builder.ToString() + '))'
}

function Test-CommandLineRawWordPresent {
    <#
    .SYNOPSIS
        Report whether a word occurs token-bounded somewhere in a raw text.
    .DESCRIPTION
        Token-bounded means that no word character or hyphen touches the word on either
        side; the word may carry a '.exe' suffix. Compared case-insensitively.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
        [Parameter(Mandatory)][string] $Word
    )

    $pattern = '(?<![\w-])' + [regex]::Escape($Word) + '(?:\.exe)?(?![\w-])'
    $options = [System.Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'
    return [regex]::IsMatch($RawText, $pattern, $options)
}

function Get-CommandLineRawInvocationMatch {
    <#
    .SYNOPSIS
        Return every accepted sequence or absorption match of an invocation in a raw text.
    .DESCRIPTION
        A sequence match is accepted when at least one position matched its literal and,
        when the command position was an expansion, the command word also occurs
        token-bounded in the raw text. An absorption match is accepted when every subcommand
        element after the absorbed position occurs token-bounded in the raw text. Each
        result carries FullLiteral ($true only for a sequence match in which every position
        matched its literal) and End (the index just past the matched invocation).
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )

    $options = [System.Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'
    $accepted = [System.Collections.Generic.List[object]]::new()
    $commandPresent = Test-CommandLineRawWordPresent -RawText $RawText -Word $CommandWord

    $sequence = Get-CommandLineRawInvocationPattern -CommandWord $CommandWord -SubcommandPath $SubcommandPath
    foreach ($match in [regex]::Matches($RawText, $sequence, $options)) {
        $literals = @(0..$SubcommandPath.Count | Where-Object { $match.Groups['literal' + $_].Success }).Count
        if ($literals -eq 0) { continue }
        if (-not $match.Groups['literal0'].Success -and -not $commandPresent) { continue }
        $span = $match.Groups['seq']
        $accepted.Add([pscustomobject]@{ FullLiteral = ($literals -eq $SubcommandPath.Count + 1); End = $span.Index + $span.Length })
    }

    for ($absorbAt = 0; $absorbAt -lt $SubcommandPath.Count; $absorbAt++) {
        $remaining = @($SubcommandPath[$absorbAt..($SubcommandPath.Count - 1)])
        $absent = @($remaining | Where-Object { -not (Test-CommandLineRawWordPresent -RawText $RawText -Word $_) })
        if ($absent.Count -gt 0) { continue }
        $absorption = Get-CommandLineRawInvocationPattern -CommandWord $CommandWord -SubcommandPath $SubcommandPath -AbsorbAt $absorbAt
        foreach ($match in [regex]::Matches($RawText, $absorption, $options)) {
            $span = $match.Groups['seq']
            $accepted.Add([pscustomobject]@{ FullLiteral = $false; End = $span.Index + $span.Length })
        }
    }

    return $accepted.ToArray()
}

function Test-CommandLineRawInvocation {
    <#
    .SYNOPSIS
        Report whether a raw text invokes a command word with a subcommand path as a
        token-bounded, ordered sequence.
    .DESCRIPTION
        The R2 predicate of Resolve-CommandLineInvocation for a wrapper-led or
        live-substitution segment. Returns $true when Get-CommandLineRawInvocationMatch
        accepts at least one sequence or absorption match in RawText, and $false otherwise.
    .PARAMETER RawText
        The segment's raw text, including the contents of any quoted -Command or -c argument.
    .PARAMETER CommandWord
        The command name, e.g. 'git' or 'gh'. Compared case-insensitively.
    .PARAMETER SubcommandPath
        One or more ordered subcommand tokens. Compared case-insensitively.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )

    $found = @(Get-CommandLineRawInvocationMatch -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath)
    return $found.Count -gt 0
}

function Get-CommandLineRawInvocationOperand {
    <#
    .SYNOPSIS
        Read the operand of the invocation that the token-aware matcher finds in a raw text.
    .DESCRIPTION
        Status is NoMatch when no match is accepted, and Indeterminate when any accepted
        match is not fully literal (an expansion stood in for a position, or a token
        absorbed the remaining subcommand elements). For each fully literal match, tokens
        are read from the match end: separators are skipped; a token is the longest run of
        characters that are neither whitespace nor one of ; & | < > ( ); leading and
        trailing backslash and quote characters are stripped. '--force' and '-f' are
        skipped; '--' is skipped and the next token is the operand; any other dash-leading
        token, and any token carrying '$' or a backtick, is Indeterminate; an empty token
        means that match names no operand. Across matches, one distinct operand (ordinal
        comparison) gives Operand, more than one gives Indeterminate, and none gives
        NoOperand.
    .OUTPUTS
        System.Management.Automation.PSCustomObject - Status and Operand.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )

    $found = @(Get-CommandLineRawInvocationMatch -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath)
    if ($found.Count -eq 0) {
        return [pscustomobject]@{ Status = 'NoMatch'; Operand = $null }
    }

    $indeterminate = [pscustomobject]@{ Status = 'Indeterminate'; Operand = $null }
    $operands = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $stripped = [char[]]@('\', '''', '"')

    foreach ($entry in $found) {
        if (-not $entry.FullLiteral) { return $indeterminate }

        $index = $entry.End
        $afterSeparator = $false
        while ($true) {
            $index += [regex]::Match($RawText.Substring($index), '^(?:\s|\\\r?\n)*').Length
            $rawToken = [regex]::Match($RawText.Substring($index), '^[^\s;&|<>()]*').Value
            $index += $rawToken.Length
            $token = $rawToken.Trim($stripped)
            if ($token.Length -eq 0) { break }
            if (-not $afterSeparator -and ($token -eq '--force' -or $token -eq '-f')) { continue }
            if (-not $afterSeparator -and $token -eq '--') {
                $afterSeparator = $true
                continue
            }
            if ((-not $afterSeparator -and $token.StartsWith('-')) -or $token.Contains('$') -or $token.Contains('`')) {
                return $indeterminate
            }
            [void]$operands.Add($token)
            break
        }
    }

    if ($operands.Count -gt 1) { return $indeterminate }
    if ($operands.Count -eq 1) {
        return [pscustomobject]@{ Status = 'Operand'; Operand = @($operands)[0] }
    }
    return [pscustomobject]@{ Status = 'NoOperand'; Operand = $null }
}

function Resolve-CommandLineWrappedInvocationOperand {
    <#
    .SYNOPSIS
        Read the raw-text operand of an invocation that classified through a wrapper-led or
        live-substitution segment.
    .DESCRIPTION
        Calls Resolve-CommandLineInvocation. Returns Status NotApplicable when nothing
        classified, when the match is structural (OperandIndex 0 or greater, so the
        structural operand reader applies), when the matched segment is Unbalanced (rule R1
        stays fail-closed), or when the segment is neither wrapper-led nor substituted.
        Otherwise returns Get-CommandLineRawInvocationOperand applied to the segment's raw
        text. Like the structural reader, it reads the first classifying segment only.
    .OUTPUTS
        System.Management.Automation.PSCustomObject - Status and Operand.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )

    $notApplicable = [pscustomobject]@{ Status = 'NotApplicable'; Operand = $null }
    $resolved = Resolve-CommandLineInvocation -CommandText $CommandText -CommandWord $CommandWord -SubcommandPath $SubcommandPath
    if ($null -eq $resolved -or $resolved.OperandIndex -ge 0) {
        return $notApplicable
    }

    $segment = $resolved.Segment
    if ($segment.Unbalanced -or -not ($segment.IsWrapperLed -or $segment.HasLiveSubstitution)) {
        return $notApplicable
    }

    return Get-CommandLineRawInvocationOperand -RawText $segment.RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath
}
