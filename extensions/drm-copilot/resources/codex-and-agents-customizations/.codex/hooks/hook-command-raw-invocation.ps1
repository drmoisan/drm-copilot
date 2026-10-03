<#
.SYNOPSIS
    Token-aware raw-text invocation matcher for wrapper-led and live-substitution segments.
.DESCRIPTION
    Realizes the corrected R2 fail-closed rule of issue #824. A wrapper-led or
    live-substitution segment carries its nested command line inside its raw text, often
    inside a quoted -Command or -c argument, so the structural token walk cannot see it.
    This module answers whether that raw text contains the command word followed by every
    subcommand element as a token-bounded, ordered sequence, rather than merely containing
    each word somewhere as a substring.

    Matching rules, applied case-insensitively and culture-invariantly:
      - A command or subcommand position is bounded on both sides: no word character or
        hyphen may touch it, so 'gh' inside 'through' and 'new' inside 'New-Object' do not
        match.
      - The command word may carry a '.exe' suffix and may be followed by a closing quote,
        optionally backslash-escaped, so quoted and path-qualified spellings still match.
      - Before each subcommand element, a run of dash-leading options is skipped, each with
        an optional quoted or unquoted value, so 'gh -R o/r issue create' still matches.
      - A shell expansion ('$name', '${...}', '$(...)', or a backtick span) may stand in for
        any position, because its run-time value is unknown. A match counts only when at
        least one position matched its literal, so a sequence made only of expansions does
        not classify.

    Pure string logic only: no disk, process, network, clock, or environment access. It is
    dot-sourced by hook-command-invocation.ps1 as:
    . (Join-Path $PSScriptRoot 'hook-command-raw-invocation.ps1')
#>

function Get-CommandLineRawInvocationPattern {
    <#
    .SYNOPSIS
        Build the token-aware sequence pattern for one command word and subcommand path.
    .DESCRIPTION
        Returns a regular expression wrapped in a zero-width lookahead, so that every start
        index of the raw text is tried. Each literal position is captured in a named group
        'literalN' (N = 0 for the command word, 1.. for the subcommand elements); an
        expansion standing in for a position leaves that group unmatched.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )

    $expansion = '\$[A-Za-z_]\w*|\$\{[^}]*\}|\$\([^)]*\)|`[^`]*`'
    $closingQuote = '(?:\\?[''"])?'
    $trailingBoundary = '(?![\w-])'
    $optionRun = '(?:\s+-[^\s''"]*(?:\s+(?:"[^"]*"|''[^'']*''|[^\s''"-][^\s''"]*))?)*'

    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append('(?<![\w-])(?:(?<literal0>')
    [void]$builder.Append([regex]::Escape($CommandWord))
    [void]$builder.Append('(?:\.exe)?)|(?:' + $expansion + '))' + $trailingBoundary + $closingQuote)

    for ($position = 0; $position -lt $SubcommandPath.Count; $position++) {
        $groupName = 'literal' + ($position + 1)
        [void]$builder.Append($optionRun + '\s+' + $closingQuote)
        [void]$builder.Append('(?:(?<' + $groupName + '>' + [regex]::Escape($SubcommandPath[$position]) + ')')
        [void]$builder.Append('|(?:' + $expansion + '))' + $trailingBoundary + $closingQuote)
    }

    return '(?=' + $builder.ToString() + ')'
}

function Test-CommandLineRawInvocation {
    <#
    .SYNOPSIS
        Report whether a raw text invokes a command word with a subcommand path as a
        token-bounded, ordered sequence.
    .DESCRIPTION
        The R2 predicate of Resolve-CommandLineInvocation for a wrapper-led or
        live-substitution segment. Returns $true when some start index of RawText begins the
        command word followed by every subcommand element in order, with only modeled
        whitespace, options, and quotes between them, and with at least one position matched
        by its literal rather than by a shell expansion. Returns $false otherwise.
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

    $pattern = Get-CommandLineRawInvocationPattern -CommandWord $CommandWord -SubcommandPath $SubcommandPath
    $options = [System.Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'

    foreach ($match in [regex]::Matches($RawText, $pattern, $options)) {
        for ($position = 0; $position -le $SubcommandPath.Count; $position++) {
            if ($match.Groups['literal' + $position].Success) {
                return $true
            }
        }
    }

    return $false
}
