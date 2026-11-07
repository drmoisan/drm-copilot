<#
.SYNOPSIS
    Candidate test and merge target reader of the docs-complete gate (issue #1034).
.DESCRIPTION
    Dot-sourced only by enforce-docs-complete-gate.ps1, which loads the shared functions this
    file calls: the command scanner and invocation reader, and the merge scope predicates of
    enforce-epic-merge-gate-command.ps1. This file holds function definitions only and
    dot-sources nothing.

    A command is first classified as a merge candidate by a test over its text. A candidate
    reaches the selector lookup only when the reader accepts the whole command as one plain
    gh pr merge, and every other candidate denies PR_UNRESOLVED. A command the candidate test
    does not recognize is not gated, as the Residual limits paragraph of the hook header states.

    Pure string logic only: no disk, process, network, clock, or environment access.
#>

function Read-DocsCompleteGatePlainCommand {
    <#
    .SYNOPSIS
        Reads a command under the closed grammar of one plain command.
    .DESCRIPTION
        Returns @{ IsPlain; Words }. A word is a run of unquoted characters from
        A-Za-z0-9_./:=@%+,#-, single-quoted spans, and double-quoted spans holding no dollar sign,
        backtick or backslash; spans concatenate as in bash, and Words holds each word with its
        quotes removed. At the start of a word an unquoted # ends the operands, and that comment
        must hold no newline. A redirection is [n]>, [n]>>, [n]<, &> or &>> followed by one
        literal word, or [n]>& followed by digits or a dash; digits directly before the operator
        are the file descriptor, as bash reads them. Redirections are removed from Words, and a
        word after a redirection is not plain. Any other character is not plain.

        Two rules read the raw text, because the shared normalizer turns a backslash-newline into
        a space before the scan. Bash does not continue a comment at a backslash, so a comment in
        text holding a backslash-newline is not plain. Bash joins the two halves of a word split
        by a backslash-newline, so a backslash-newline with a non-blank character on both sides
        is not plain.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $CommandText)

    $notPlain = @{ IsPlain = $false; Words = @() }
    if ([regex]::IsMatch($CommandText, '\S\\\r?\n\S')) { return $notPlain }
    $hasContinuation = [regex]::IsMatch($CommandText, '\\\r?\n')
    $wordCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_./:=@%+,#-'
    $text = (ConvertTo-CommandLineNormalizedText -CommandText $CommandText).Trim()
    $words = [System.Collections.Generic.List[string]]::new()
    $sawRedirection = $false
    $awaitingTarget = $false
    $index = 0

    while ($index -lt $text.Length) {
        $character = $text[$index]
        if ($character -eq ' ' -or $character -eq "`t") { $index++; continue }
        if ($character -eq '#') {
            if ($awaitingTarget -or $hasContinuation -or $text.IndexOf("`n", $index) -ge 0) { return $notPlain }
            break
        }
        if (-not $awaitingTarget) {
            $redirection = [regex]::Match($text.Substring($index), '^(?:\d*>&|\d*>>|\d*>|\d*<|&>>|&>)')
            if ($redirection.Success) {
                $index += $redirection.Length
                if ($redirection.Value.EndsWith('>&')) {
                    $descriptor = [regex]::Match($text.Substring($index), '^(?:\d+|-)(?=\s|$)')
                    if (-not $descriptor.Success) { return $notPlain }
                    $index += $descriptor.Length
                    $sawRedirection = $true
                } else {
                    $awaitingTarget = $true
                }
                continue
            }
        }

        $word = [System.Text.StringBuilder]::new()
        $hasWord = $false
        while ($index -lt $text.Length) {
            $current = $text[$index]
            if ($current -eq "'" -or $current -eq '"') {
                $close = $text.IndexOf($current, $index + 1)
                if ($close -lt 0) { return $notPlain }
                $span = $text.Substring($index + 1, $close - $index - 1)
                if ($current -eq '"' -and $span -match '[$`\\]') { return $notPlain }
                [void]$word.Append($span)
                $index = $close + 1
                $hasWord = $true
                continue
            }
            if (-not $wordCharacters.Contains($current)) { break }
            [void]$word.Append($current)
            $index++
            $hasWord = $true
        }
        if (-not $hasWord) { return $notPlain }
        if ($awaitingTarget) {
            $awaitingTarget = $false
            $sawRedirection = $true
            continue
        }
        if ($sawRedirection) { return $notPlain }
        $words.Add($word.ToString())
        if ($index -lt $text.Length) {
            $after = $text[$index]
            $endsWord = $after -eq ' ' -or $after -eq "`t" -or $after -eq '>' -or $after -eq '<'
            if (-not $endsWord -and -not ($after -eq '&' -and $index + 1 -lt $text.Length -and $text[$index + 1] -eq '>')) { return $notPlain }
        }
    }

    if ($awaitingTarget) { return $notPlain }
    return @{ IsPlain = $true; Words = $words.ToArray() }
}

function Get-DocsCompleteGateUnquotedView {
    <#
    .SYNOPSIS
        Returns the unquoted text of a command.
    .DESCRIPTION
        Joins the MaskedText of every Read-CommandLineSegment record over the normalized text
        with a space, then removes every backslash, because bash drops the backslash of an escaped
        character in a word and g\h runs gh. Quoted spans and heredoc bodies are blank in this
        view; operators and leading words do not affect it.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $CommandText)

    $normalized = ConvertTo-CommandLineNormalizedText -CommandText $CommandText
    return ((@(Read-CommandLineSegment -CommandText $normalized | ForEach-Object { $_.MaskedText }) -join ' ').Replace('\', ''))
}

function Test-DocsCompleteGateMergeText {
    <#
    .SYNOPSIS
        Reports whether text holds the words of a gh merge.
    .DESCRIPTION
        True when Text holds the whole words gh, pr, merge in that order, or the whole words gh,
        api in that order while Test-EpicMergeGateApiMutationText is true for MutationText. The
        words match in any case.
    .PARAMETER Text
        The text searched for the words.
    .PARAMETER MutationText
        The text searched for a merge mutation or endpoint. It can differ from Text because a
        merge endpoint or mutation name is usually quoted.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $MutationText
    )

    $options = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant -bor [System.Text.RegularExpressions.RegexOptions]::Singleline
    if ([regex]::IsMatch($Text, '(?<![\w-])gh(?![\w-]).*(?<![\w-])pr(?![\w-]).*(?<![\w-])merge(?![\w-])', $options)) { return $true }
    if ([regex]::IsMatch($Text, '(?<![\w-])gh(?![\w-]).*(?<![\w-])api(?![\w-])', $options)) {
        return (Test-EpicMergeGateApiMutationText -Text $MutationText)
    }
    return $false
}

function Test-DocsCompleteGateMergeCandidate {
    <#
    .SYNOPSIS
        Reports whether the text of a command reads as a gh merge.
    .DESCRIPTION
        Decides in this order. A plain command whose first word is gh is read with the structural
        walk: on a match it is a candidate unless its operands are --disable-auto only, and on any
        other outcome Test-EpicMergeGateCommandInScope decides, because the walk does not read
        gh api. Otherwise that predicate being true means candidate.

        Otherwise the text decides, for two forms of the command: the raw text, and the raw text
        with each backslash-newline deleted. A comment ending in a backslash needs the first form
        and a split word needs the second. In each form the view is the unquoted view, and the
        spelled text is the normalized text with every single quote, double quote and backslash
        removed, so it includes quoted spans and heredoc bodies. The command is a candidate when
        Test-DocsCompleteGateMergeText is true for the view, with the spelled text as its mutation
        text, or when the view holds an evaluator word and that test is true for the spelled text.
        The evaluator words are whole words in any case: sh, bash, zsh, dash, ksh, pwsh,
        powershell, eval, source.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $CommandText)

    $plain = Read-DocsCompleteGatePlainCommand -CommandText $CommandText
    if ($plain.IsPlain -and @($plain.Words).Count -gt 0 -and $plain.Words[0] -ceq 'gh') {
        $walk = Get-CommandLineStructuralWalk -Token $plain.Words -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -Option (Get-CommandLineGlobalOption -CommandWord 'gh')
        if ($walk.Outcome -eq 'Match') {
            $operand = Read-DocsCompleteGateMergeOperand -Token $plain.Words -StartIndex $walk.OperandIndex
            return (-not $operand.DisableAutoOnly)
        }
        return (Test-EpicMergeGateCommandInScope -CommandText $CommandText)
    }
    if (Test-EpicMergeGateCommandInScope -CommandText $CommandText) { return $true }

    $evaluator = '(?<![\w-])(?:sh|bash|zsh|dash|ksh|pwsh|powershell|eval|source)(?![\w-])'
    $options = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    foreach ($form in @($CommandText, [regex]::Replace($CommandText, '\\\r?\n', ''))) {
        $view = Get-DocsCompleteGateUnquotedView -CommandText $form
        $spelled = (ConvertTo-CommandLineNormalizedText -CommandText $form) -replace '[''"\\]', ''
        if (Test-DocsCompleteGateMergeText -Text $view -MutationText $spelled) { return $true }
        if ([regex]::IsMatch($view, $evaluator, $options) -and (Test-DocsCompleteGateMergeText -Text $spelled -MutationText $spelled)) { return $true }
    }
    return $false
}

function Read-DocsCompleteGateMergeOperand {
    <#
    .SYNOPSIS
        Reads the selector, repository values and head pin of one plain gh pr merge.
    .DESCRIPTION
        Walks the words with a closed flag table and returns @{ Readable; Selector; Repository;
        MatchHeadCommit; DisableAutoOnly }. A flag outside the table, a value flag with no value,
        more than one selector, and a dash-led or non-literal selector are unreadable. A short
        cluster is read letter by letter; a value letter takes the rest of the word, without one
        leading '=', or the next word.

        gh parses the value of a boolean flag and the last spelling wins, so a --flag=value
        spelling is never read as the bare flag. DisableAutoOnly is true only when the bare word
        --disable-auto was read, no --disable-auto=<value> spelling was read, and no flag of
        $script:EpicMergeGateActionFlags was read in either spelling. --merge=<value> supplies a
        selector only when the value is not 1 or 0, which gh reads as booleans.
    .PARAMETER Token
        The words of the command.
    .PARAMETER StartIndex
        The position just past the subcommand path.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Token,
        [Parameter(Mandatory)] [int] $StartIndex
    )

    $standalone = @('--merge', '-m', '--squash', '-s', '--rebase', '-r', '-d', '--delete-branch', '--auto', '--admin', '--disable-auto', '--help', '-h')
    $unreadable = @{ Readable = $false; Selector = $null; Repository = @(); MatchHeadCommit = $null; DisableAutoOnly = $false }
    $positional = [System.Collections.Generic.List[string]]::new()
    $repository = [System.Collections.Generic.List[string]]::new()
    $pin = $null
    $afterSeparator = $false
    $sawBareDisableAuto = $false
    $sawDisableAutoValue = $false
    $sawAction = $false
    $index = $StartIndex
    while ($index -lt $Token.Count) {
        $current = $Token[$index]
        $index++
        if ($afterSeparator -or -not $current.StartsWith('-') -or $current -ceq '-') { $positional.Add($current); continue }
        if ($current -ceq '--') { $afterSeparator = $true; continue }

        $name = Get-EpicMergeGateFlagName -Token $current
        $value = if ($name.Length -lt $current.Length) { $current.Substring($name.Length + 1) } else { $null }
        if (-not $current.StartsWith('--')) {
            $name = $null
            $value = $null
            for ($position = 1; $position -lt $current.Length -and $null -eq $name; $position++) {
                $letter = "-$($current[$position])"
                if ($script:EpicMergeGateValueFlags -ccontains $letter) {
                    $name = $letter
                    if ($position + 1 -lt $current.Length) { $value = $current.Substring($position + 1) -replace '^=', '' }
                } elseif ($standalone -cnotcontains $letter) {
                    return $unreadable
                } elseif ($script:EpicMergeGateActionFlags -ccontains $letter) {
                    $sawAction = $true
                }
            }
            if ($null -eq $name) { continue }
        }
        if ($standalone -ccontains $name) {
            if ($script:EpicMergeGateActionFlags -ccontains $name) { $sawAction = $true }
            if ($name -ceq '--disable-auto') {
                if ($null -eq $value) { $sawBareDisableAuto = $true } else { $sawDisableAutoValue = $true }
            }
            if ($name -ceq '--merge' -and $value -cne '1' -and $value -cne '0' -and $null -ne (ConvertFrom-EpicMergeGateSelector -Selector ([string] $value))) { $positional.Add($value) }
            continue
        }
        if ($script:EpicMergeGateValueFlags -cnotcontains $name) { return $unreadable }
        if ($null -eq $value) {
            if ($index -ge $Token.Count) { return $unreadable }
            $value = $Token[$index]
            $index++
        }
        if ($name -ceq '-R' -or $name -ceq '--repo') { $repository.Add($value) }
        if ($name -ceq '--match-head-commit') { $pin = $value }
    }

    if ($positional.Count -gt 1) { return $unreadable }
    $selector = if ($positional.Count -eq 1) { $positional[0] } else { $null }
    if ($null -ne $selector -and ($selector.Length -eq 0 -or $selector.StartsWith('-') -or -not (Test-CommandLineTokenLiteral -Token $selector))) { return $unreadable }
    $disableAutoOnly = $sawBareDisableAuto -and -not $sawDisableAutoValue -and -not $sawAction
    return @{ Readable = $true; Selector = $selector; Repository = $repository.ToArray(); MatchHeadCommit = $pin; DisableAutoOnly = $disableAutoOnly }
}

function Get-DocsCompleteGateMergeTarget {
    <#
    .SYNOPSIS
        Binds a merge candidate to the pull request it merges.
    .DESCRIPTION
        Returns @{ Reason; Message; Selector; Repository; MatchHeadCommit }. Reason is $null only
        when the command is plain, its first word is exactly gh, the structural walk returns
        Match, the operands are readable, and the merged repository values are one OWNER/REPO or
        HOST/OWNER/REPO value at most. Every other case is PR_UNRESOLVED, and no gh call is made.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [string] $CommandText)

    $unresolved = @{ Reason = 'PR_UNRESOLVED'; Message = 'The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call.'; Selector = $null; Repository = $null; MatchHeadCommit = $null }
    $plain = Read-DocsCompleteGatePlainCommand -CommandText $CommandText
    if (-not $plain.IsPlain -or @($plain.Words).Count -eq 0 -or $plain.Words[0] -cne 'gh') { return $unresolved }
    $walk = Get-CommandLineStructuralWalk -Token $plain.Words -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -Option (Get-CommandLineGlobalOption -CommandWord 'gh')
    if ($walk.Outcome -ne 'Match') { return $unresolved }
    $operand = Read-DocsCompleteGateMergeOperand -Token $plain.Words -StartIndex $walk.OperandIndex
    if (-not $operand.Readable) { return $unresolved }

    $repositories = @(@(@($walk.GlobalOptions | ForEach-Object { [string] $_.Value }) + @($operand.Repository)) | Select-Object -Unique)
    if ($repositories.Count -gt 1 -or ($repositories.Count -eq 1 -and $repositories[0] -cnotmatch '^[\w.-]+/[\w.-]+(?:/[\w.-]+)?$')) { return $unresolved }
    $repository = if ($repositories.Count -eq 1) { $repositories[0] } else { $null }
    return @{ Reason = $null; Message = $null; Selector = $operand.Selector; Repository = $repository; MatchHeadCommit = $operand.MatchHeadCommit }
}
