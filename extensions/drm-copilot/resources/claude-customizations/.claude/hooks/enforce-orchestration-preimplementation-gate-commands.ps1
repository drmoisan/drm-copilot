<#
.SYNOPSIS
    Stage-2 confirmation of the preimplementation gate's command classification (issue #1160).

.DESCRIPTION
    Dot-sourced, guarded, by .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1. Test-ImplementationCommand keeps
    its five stage-1 patterns and its structural staging check unchanged. A regex hit (including
    the regex half of the staging pattern when the structural check found no git add or git
    commit) is passed to Test-OrchestrationGateInvocationConfirmed, which keeps the hit unless
    every occurrence of the governed word is an operand of a known non-executing mention host,
    no stage of the same pipeline can execute it, and the whole command is modelled.
    Stage 2 runs only after a stage-1 hit, so the change can only remove classifications: a
    command that no stage-1 pattern matches is never classified (decisions D1 to D3).

    The rule (decisions D2, D16, and D17) works over the records of
    Read-CommandLineInvocationSegment, which expands sh/bash -c, pwsh -c and -EncodedCommand,
    eval, substitution bodies, and xargs. The hit is confirmed when any of the following holds:
      1. A record is Unbalanced, or Opaque with DecodeFailure or DepthLimit, or an Opaque
         NoPayload wrapper (a shell reading stdin or a heredoc, pwsh -File) while its own text or
         the whole command carries a governed word.
      2. A record's command word is an evaluator (Invoke-Expression, iex, Invoke-Command, icm,
         Start-Process, saps, start, cmd, cmd.exe, source, .) while the whole command carries a
         governed word.
      3. A record that carries the governed word as a whole token is not a mention-host record
         (Test-OrchestrationGateMentionHostRecord): it is not led by a host of
         Get-OrchestrationGateMentionHostTable (a subcommand-scoped host counts only when its
         listed subcommand is the token directly after its command word, decision D19), it is
         led by a NotHost command word, or it carries an executing option (rg --pre or
         --hostname-bin, git -O, a git short-option bundle holding O, or --open-files-in-pager,
         sort --compress-program, or a GNU abbreviation of an executing long option). A PowerShell non-command expression record
         is accepted only when its text contains neither '::' nor '.Invoke'. An expanded
         wrapper record is judged through its payload records, and it confirms the hit when no
         payload record carries the word.
      4. No record carries the governed word at all.
      5. A record that does not carry the governed word is a pipeline consumer of a carrying
         record and is not an accepted consumer (decision D16, Test-OrchestrationGateAcceptedConsumer):
         a later same-Depth record, joined by '|' for a Posix carrying record, or any later
         record of the same PowerShell payload (nested payload records are skipped).
      6. Decision D17: where rules 1 to 5 would drop the hit, the command is not modelled
         (Test-OrchestrationGateCommandModelled, whose help lists the allowlists), or an
         earlier record of the same pipeline is not an accepted consumer.
    The governed words are git for the staging pattern; black, ruff, pyright, and pytest;
    prettier, lint, typecheck, and test:unit; prettier, eslint, tsc, and jest; and, for the pwsh
    pattern, Invoke-Pester as a whole token or the text tests/scripts/.

    This is a policy-level control, not a security control: the mention-host table is a
    negative model that fails closed for any launcher it does not name, and any construct the
    model does not decode keeps the hit, so an unmodelled launcher (conda run, hatch run,
    coverage run -m, tox) or pipeline consumer stays classified.
    Deliberately obfuscated commands are out of scope (decision D18): a later finding that is only a further obfuscation variant is dispositioned out of scope, while a misclassified ordinary invocation remains a defect.

.NOTES
    PowerShell 7+. Pure string and AST logic (the parser never executes): no disk, process,
    network, clock, or environment access, and no StrictMode or preference assignment, because
    a dot-sourced file changes its caller's scope. Call-time dependencies, loaded by each gate
    through hook-command-invocation.ps1: Read-CommandLineInvocationSegment,
    Skip-CommandLineTransparentWrapper, ConvertTo-CommandLineLeafWord,
    Test-CommandLineWordPresent, ConvertTo-CommandLineNormalizedText,
    Split-CommandLinePosixWord, and Get-CommandLineWrapperPayload (hook-command-payload.ps1).
    Byte-identical at .claude/hooks/, .codex/hooks/, and both extensions/drm-copilot/resources/ mirrors.
    AUTHORITY: PowerShell-authoritative. This hook file starts no interpreter process.
#>

function Get-OrchestrationGateMentionHostTable {
    <#
    .SYNOPSIS
        Return the decision D2 mention-host table, as amended by D16 and D17 (issue #1160).
    .DESCRIPTION
        Search, Process, Output, ReadAndFilter, and Lookup list hosts that never execute their
        operands. Subcommand maps a command to the subcommands under which it is a host.
        ExecutingOption maps a host to the option prefixes that make it execute an operand.
        NotHost lists commands that can execute their arguments; a NotHost command word is
        never a host, even when a host group lists it. A new table is built on every call, so
        no caller can change another caller's table.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        Search          = @('grep', 'egrep', 'fgrep', 'rg', 'ag', 'ack', 'findstr', 'Select-String', 'sls')
        Process         = @('ps', 'pgrep', 'pidof', 'pkill', 'kill', 'killall', 'tasklist', 'taskkill', 'Get-Process', 'gps', 'Stop-Process', 'Get-CimInstance', 'gcim', 'Get-WmiObject')
        Output          = @('echo', 'printf', 'Write-Output', 'Write-Host', 'Write-Verbose')
        ReadAndFilter   = @('cat', 'Get-Content', 'head', 'tail', 'less', 'more', 'wc', 'sort', 'uniq', 'Where-Object', 'Select-Object', 'Sort-Object', 'Measure-Object', 'Format-Table', 'Format-List', 'Out-String', 'Get-ChildItem', 'Test-Path')
        Lookup          = @('which', 'where', 'where.exe', 'type', 'Get-Command', 'gcm')
        Subcommand      = [ordered]@{
            git    = @('grep', 'log', 'show', 'diff', 'blame', 'ls-files', 'status')
            npm    = @('ls', 'list', 'view', 'info', 'show', 'outdated', 'explain', 'why', 'search', 'help')
            pip    = @('show', 'list', 'freeze')
            pip3   = @('show', 'list', 'freeze')
            poetry = @('show', 'search')
        }
        ExecutingOption = [ordered]@{
            rg   = @('--pre', '--hostname-bin')
            git  = @('-O', '--open-files-in-pager')
            sort = @('--compress-program')
        }
        NotHost         = @('ForEach-Object', '%', 'foreach', 'find')
    }
}

function Test-OrchestrationGateMentionHostRecord {
    <#
    .SYNOPSIS
        Report whether a record is led by a non-executing mention host (decisions D2, D16, D17, D19).
    .DESCRIPTION
        Returns $true when the command word of the record, after transparent wrappers, is a
        host of the table (a group host, or a subcommand-scoped host whose token directly
        after the command word is a listed subcommand, so an option or option value before
        the subcommand keeps the hit, decision D19), is not listed in NotHost, and no later
        token is an executing option of that host: a token that starts with a listed option,
        a long option whose nonempty name is a prefix of a listed long option's name (GNU
        abbreviation), or, for git, a single-dash token whose option letters contain the
        uppercase O. Returns $false for a record with no command word. HostTable is
        Get-OrchestrationGateMentionHostTable.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][object] $Record,
        [Parameter(Mandatory)][System.Collections.IDictionary] $HostTable
    )

    $tokens = [string[]]@($Record.Tokens)
    $wordIndex = 0
    if ($tokens.Count -gt 0) { $wordIndex = (Skip-CommandLineTransparentWrapper -Token $tokens).Index }
    if ($wordIndex -ge $tokens.Count) { return $false }
    $leaf = ConvertTo-CommandLineLeafWord -Word $tokens[$wordIndex]
    if (@($HostTable.NotHost) -contains $leaf) { return $false }

    $leafKey = $leaf.ToLowerInvariant()
    $flatHosts = @($HostTable.Search) + @($HostTable.Process) + @($HostTable.Output) + @($HostTable.ReadAndFilter) + @($HostTable.Lookup)
    $isHost = $flatHosts -contains $leaf
    if (-not $isHost -and $HostTable.Subcommand.Contains($leafKey)) {
        $subcommand = if ($wordIndex + 1 -lt $tokens.Count) { $tokens[$wordIndex + 1] } else { '' }
        $isHost = @($HostTable.Subcommand[$leafKey]) -ccontains $subcommand
    }
    if ($isHost -and $HostTable.ExecutingOption.Contains($leafKey)) {
        for ($next = $wordIndex + 1; $next -lt $tokens.Count; $next++) {
            $token = $tokens[$next]
            $longName = if ($token.StartsWith('--', [System.StringComparison]::Ordinal)) { $token.Substring(2).Split('=')[0] } else { '' }
            foreach ($option in @($HostTable.ExecutingOption[$leafKey])) {
                if ($token.StartsWith($option, [System.StringComparison]::Ordinal)) { $isHost = $false }
                if ($longName -and $option.StartsWith('--', [System.StringComparison]::Ordinal) -and $option.Substring(2).StartsWith($longName, [System.StringComparison]::Ordinal)) { $isHost = $false }
            }
            if ($leafKey -eq 'git' -and $token.Length -gt 1 -and $token[0] -eq '-' -and $token[1] -ne '-' -and $token.Substring(1).Contains('O')) { $isHost = $false }
        }
    }
    return $isHost
}

function Test-OrchestrationGateAcceptedConsumer {
    <#
    .SYNOPSIS
        Report whether a non-carrying pipeline record is an accepted consumer (decisions D16, D17).
    .DESCRIPTION
        Returns $true for a PowerShell non-command expression record whose text contains
        neither '::' nor '.Invoke', and for a mention-host record. Shared by the forward
        consumer walk (rule 5) and the backward walk of decision D17.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][object] $Record,
        [Parameter(Mandatory)][System.Collections.IDictionary] $HostTable
    )

    if ($Record.Dialect -eq 'PowerShell' -and [string]::IsNullOrEmpty([string]$Record.CommandWord) -and @($Record.Tokens).Count -eq 0) {
        return -not ($Record.RawText.Contains('::') -or $Record.RawText.IndexOf('.Invoke', [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
    }
    return (Test-OrchestrationGateMentionHostRecord -Record $Record -HostTable $HostTable)
}

function Test-OrchestrationGatePosixTextModelled {
    <#
    .SYNOPSIS
        Report whether POSIX text (a command or a Posix payload) uses only D17 constructs.
    .DESCRIPTION
        Scans the normalized text with the quote rules of Read-CommandLineSegment. Returns
        $false for an unquoted ( ) { } < > backtick # or lone &, an unquoted $' (ANSI-C), '$('
        or a backtick inside double quotes, and, unless AllowDollarUnderscore is set (the text
        has at most one record at its own top depth), a '$_' expansion outside single quotes.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory)][bool] $AllowDollarUnderscore
    )

    $normalized = ConvertTo-CommandLineNormalizedText -CommandText $Text
    $quote = [char]0
    for ($index = 0; $index -lt $normalized.Length; $index++) {
        $character = $normalized[$index]
        $next = if ($index + 1 -lt $normalized.Length) { $normalized[$index + 1] } else { [char]0 }
        if ($quote -eq "'") {
            if ($character -eq "'") { $quote = [char]0 }
            continue
        }
        if (-not $AllowDollarUnderscore -and $character -eq '$' -and $next -eq '_') {
            $after = if ($index + 2 -lt $normalized.Length) { $normalized[$index + 2] } else { [char]0 }
            if (-not ([char]::IsLetterOrDigit($after) -or $after -eq '_')) { return $false }
        }
        if ($quote -eq '"') {
            if ($character -eq '\') { $index++ }
            elseif ($character -eq '"') { $quote = [char]0 }
            elseif ($character -eq '`' -or ($character -eq '$' -and $next -eq '(')) { return $false }
            continue
        }
        if ($character -eq '\') { $index++; continue }
        if ($character -eq '$' -and $next -eq "'") { return $false }
        if ($character -eq "'" -or $character -eq '"') { $quote = $character; continue }
        if ('(){}<>`#'.IndexOf($character) -ge 0) { return $false }
        if ($character -eq '&') {
            if ($next -ne '&') { return $false }
            $index++
        }
    }
    return $true
}

function Test-OrchestrationGatePowerShellPayloadModelled {
    <#
    .SYNOPSIS
        Report whether a PowerShell payload uses only the AST nodes of the D17 allowlist.
    .DESCRIPTION
        Parses (never executes) the payload. Allowed: a ScriptBlockAst with only an unnamed end
        block, PipelineAst, a CommandAst with a constant name, no & or . operator, and no
        redirection, parameters, constants, strings, variables, unary and binary expressions,
        a non-static member access with a constant member, CommandExpressionAst (outside a host
        scriptblock it must not carry a governed word), and a ScriptBlockExpressionAst that is
        an element of a mention-host CommandAst. A parse error or any other node is $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Payload,
        [Parameter(Mandatory)][string[]] $GovernedWord,
        [Parameter(Mandatory)][AllowEmptyString()][string] $PathMarker,
        [Parameter(Mandatory)][System.Collections.IDictionary] $HostTable
    )

    $parseTokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Payload, [ref]$parseTokens, [ref]$parseErrors)
    if (@($parseErrors).Count -gt 0) { return $false }
    $flatHosts = @($HostTable.Search) + @($HostTable.Process) + @($HostTable.Output) + @($HostTable.ReadAndFilter) + @($HostTable.Lookup)
    $constant = [System.Management.Automation.Language.StringConstantExpressionAst]
    $plainNodes = @('PipelineAst', 'CommandParameterAst', 'StringConstantExpressionAst', 'ConstantExpressionAst', 'ExpandableStringExpressionAst', 'VariableExpressionAst', 'UnaryExpressionAst', 'BinaryExpressionAst')
    foreach ($node in $ast.FindAll({ $true }, $true)) {
        $nodeType = $node.GetType().Name
        if ($plainNodes -ccontains $nodeType) { continue }
        switch ($nodeType) {
            'ScriptBlockAst' {
                if ($node.ParamBlock -or $node.BeginBlock -or $node.ProcessBlock -or $node.DynamicParamBlock -or @($node.UsingStatements).Count -gt 0) { return $false }
            }
            'NamedBlockAst' { if (-not $node.Unnamed) { return $false } }
            'CommandAst' {
                if ($node.CommandElements[0] -isnot $constant -or $node.InvocationOperator -ne 'Unknown' -or $node.Redirections.Count -gt 0) { return $false }
            }
            'MemberExpressionAst' { if ($node.Static -or $node.Member -isnot $constant) { return $false } }
            'CommandExpressionAst' {
                $inHostBlock = $false
                for ($parent = $node.Parent; $parent; $parent = $parent.Parent) {
                    if ($parent -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { $inHostBlock = $true; break }
                }
                if (-not $inHostBlock) {
                    $text = $node.Extent.Text
                    foreach ($governed in $GovernedWord) { if (Test-CommandLineWordPresent -RawText $text -Word $governed) { return $false } }
                    if ($PathMarker -and $text.IndexOf($PathMarker, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $false }
                }
            }
            'ScriptBlockExpressionAst' {
                $owner = $node.Parent
                if ($owner -isnot [System.Management.Automation.Language.CommandAst]) { return $false }
                if ($flatHosts -notcontains (ConvertTo-CommandLineLeafWord -Word ([string]$owner.CommandElements[0].Extent.Text))) { return $false }
            }
            default { return $false }
        }
    }
    return $true
}

function Test-OrchestrationGateCommandModelled {
    <#
    .SYNOPSIS
        Report whether a whole command is modelled under decision D17 (conditions 1 and 2).
    .DESCRIPTION
        Modelled: words, quoted words, escapes, '$name' operands, the quoted '{}' placeholder,
        the separators '|', ';', '&&', '||', and newline, the transparent wrappers, the payload
        wrappers with their payload as the last word, and mention hosts. Returns $false for a
        raw backslash before a newline, a text or Posix payload that fails
        Test-OrchestrationGatePosixTextModelled, an Opaque or Unbalanced record, a Posix record
        whose first token or command word is a reserved word, eval, source, '.', or a
        shell-state builtin, printf -v, the env split-string option, an assignment word, a
        word after a payload, or a PowerShell payload that fails
        Test-OrchestrationGatePowerShellPayloadModelled. Condition 2 holds once rule 3 has
        dropped every carrying record and the PowerShell allowlist has judged each expression.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Record,
        [Parameter(Mandatory)][string[]] $GovernedWord,
        [Parameter(Mandatory)][AllowEmptyString()][string] $PathMarker,
        [Parameter(Mandatory)][System.Collections.IDictionary] $HostTable
    )

    $unmodelledWords = @('if', 'then', 'else', 'elif', 'fi', 'case', 'esac', 'for', 'select', 'while', 'until', 'do', 'done', 'function', '!', '[[', ']]', 'coproc',
        'eval', 'source', '.', 'alias', 'unalias', 'hash', 'enable', 'builtin', 'exec', 'trap', 'set', 'shopt', 'export', 'declare', 'typeset', 'readonly', 'local', 'unset')
    if ($CommandText -match '\\\r?\n') { return $false }
    $topRecords = @($Record | Where-Object { $_.Depth -eq 0 }).Count
    if (-not (Test-OrchestrationGatePosixTextModelled -Text $CommandText -AllowDollarUnderscore ($topRecords -le 1))) { return $false }

    for ($position = 0; $position -lt $Record.Count; $position++) {
        $current = $Record[$position]
        if ($current.Unbalanced -or $current.Opaque) { return $false }
        $tokens = [string[]]@($current.Tokens)
        if ($current.Dialect -eq 'Posix' -and $tokens.Count -gt 0) {
            $wordIndex = (Skip-CommandLineTransparentWrapper -Token $tokens).Index
            $commandWord = if ($wordIndex -lt $tokens.Count) { ConvertTo-CommandLineLeafWord -Word $tokens[$wordIndex] } else { '' }
            if ($unmodelledWords -ccontains $tokens[0] -or $unmodelledWords -ccontains $commandWord) { return $false }
            if ($commandWord -ceq 'printf' -and @($tokens | Where-Object { $_.StartsWith('-v', [System.StringComparison]::Ordinal) }).Count -gt 0) { return $false }
            $inEnv = $false
            for ($index = 0; $index -lt $tokens.Count; $index++) {
                $token = $tokens[$index]
                if ($token -match '^[A-Za-z_][A-Za-z0-9_]*=') { return $false }
                if ($index -ge $wordIndex) { continue }
                if ((ConvertTo-CommandLineLeafWord -Word $token) -ceq 'env') { $inEnv = $true; continue }
                $splitString = $token -cmatch '^-[A-Za-z0-9]*S' -or ($token.StartsWith('--s', [System.StringComparison]::Ordinal) -and '--split-string'.StartsWith($token.Split('=')[0], [System.StringComparison]::Ordinal))
                if ($inEnv -and $splitString) { return $false }
            }
        }

        $words = if ($current.Dialect -eq 'Posix' -and $current.Origin -ne 'ArgumentInjector') { [string[]](Split-CommandLinePosixWord -Text ([string]$current.RawText)) } else { $tokens }
        if ($words.Count -eq 0) { continue }
        $payload = Get-CommandLineWrapperPayload -Word $words
        if ($payload.Kind -eq 'Posix') {
            if ($words[$words.Count - 1] -cne $payload.Payload) { return $false }
            $payloadRecords = 0
            for ($next = $position + 1; $next -lt $Record.Count -and $Record[$next].Depth -gt $current.Depth; $next++) {
                if ($Record[$next].Depth -eq $current.Depth + 1) { $payloadRecords++ }
            }
            if (-not (Test-OrchestrationGatePosixTextModelled -Text $payload.Payload -AllowDollarUnderscore ($payloadRecords -le 1))) { return $false }
        } elseif ($payload.Kind -eq 'PowerShell') {
            $rest = [string[]]@($words | Select-Object -Skip ((Skip-CommandLineTransparentWrapper -Token $words).Index + 1))
            for ($index = 0; $index -lt $rest.Count; $index++) {
                $flag = $rest[$index].ToLowerInvariant()
                if ($flag -eq '-c' -or ($flag.Length -ge 4 -and '-command'.StartsWith($flag, [System.StringComparison]::Ordinal))) { break }
                $argumentFlag = $flag -in @('-cwa', '-commandwithargs', '-e', '-ec') -or ($flag.Length -ge 3 -and '-encodedcommand'.StartsWith($flag, [System.StringComparison]::Ordinal))
                if ($argumentFlag) {
                    if ($index + 2 -ne $rest.Count) { return $false }
                    break
                }
            }
            if (-not (Test-OrchestrationGatePowerShellPayloadModelled -Payload $payload.Payload -GovernedWord $GovernedWord -PathMarker $PathMarker -HostTable $HostTable)) { return $false }
        }
    }
    return $true
}

function Test-OrchestrationGateInvocationConfirmed {
    <#
    .SYNOPSIS
        Report whether a stage-1 pattern hit is a real invocation (decisions D2, D16, D17, issue #1160).
    .DESCRIPTION
        Returns $true (the hit stands and the command is classified) unless every carrying
        record is a mention-host record or a PowerShell expression record without '::' or
        '.Invoke', every pipeline consumer of a carrying record is an accepted consumer
        (D16), no fallback of the file header applies, the command is modelled, and every
        earlier stage of the same pipeline is an accepted consumer (D17). Returns $false only
        when the hit is a mention. The caller invokes it only after a stage-1 hit.
    .PARAMETER CommandText
        The trimmed command text that stage 1 matched.
    .PARAMETER PatternIndex
        The index of the stage-1 pattern that matched: 0 staging, 1 Python tools, 2 npm
        scripts, 3 npx tools, 4 pwsh Pester.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][ValidateRange(0, 4)][int] $PatternIndex
    )

    $governedWords = @(switch ($PatternIndex) {
            0 { 'git' }
            1 { 'black', 'ruff', 'pyright', 'pytest' }
            2 { 'prettier', 'lint', 'typecheck', 'test:unit' }
            3 { 'prettier', 'eslint', 'tsc', 'jest' }
            default { 'Invoke-Pester' }
        })
    $pathMarker = if ($PatternIndex -eq 4) { 'tests/scripts/' } else { '' }
    $evaluators = @('Invoke-Expression', 'iex', 'Invoke-Command', 'icm', 'Start-Process', 'saps', 'start', 'cmd', 'cmd.exe', 'source', '.')
    $wrappers = @('sh', 'bash', 'zsh', 'dash', 'ksh', 'pwsh', 'powershell', 'eval', 'xargs')
    $hostTable = Get-OrchestrationGateMentionHostTable

    # Presence of a governed word, decided once per record and once for the whole command:
    # a whole token for a word, and ordinal ignore-case containment for the tests/scripts/ text.
    $records = @(Read-CommandLineInvocationSegment -CommandText $CommandText)
    $carries = [bool[]]::new($records.Count)
    for ($position = 0; $position -lt $records.Count; $position++) {
        $text = [string]$records[$position].RawText
        foreach ($governed in $governedWords) {
            if (Test-CommandLineWordPresent -RawText $text -Word $governed) { $carries[$position] = $true }
        }
        if ($pathMarker -and $text.IndexOf($pathMarker, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { $carries[$position] = $true }
    }
    $textCarries = [bool]($pathMarker -and $CommandText.IndexOf($pathMarker, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
    foreach ($governed in $governedWords) {
        if (Test-CommandLineWordPresent -RawText $CommandText -Word $governed) { $textCarries = $true }
    }

    $carrying = 0
    for ($position = 0; $position -lt $records.Count; $position++) {
        $record = $records[$position]
        if ($record.Unbalanced) { return $true }
        if ($record.Opaque) {
            if ($record.OpaqueReason -ne 'NoPayload' -or $carries[$position] -or $textCarries) { return $true }
            continue
        }
        $tokens = [string[]]@($record.Tokens)
        $isExpression = $record.Dialect -eq 'PowerShell' -and [string]::IsNullOrEmpty([string]$record.CommandWord) -and $tokens.Count -eq 0
        $leaf = ''
        if (-not $isExpression -and $tokens.Count -gt 0) {
            $wordIndex = (Skip-CommandLineTransparentWrapper -Token $tokens).Index
            if ($wordIndex -lt $tokens.Count) { $leaf = ConvertTo-CommandLineLeafWord -Word $tokens[$wordIndex] }
        }
        if ($leaf -and $evaluators -contains $leaf -and $textCarries) { return $true }
        if (-not $carries[$position]) { continue }

        $carrying++
        # Decision D16: a later stage of the same pipeline that does not carry the word is a
        # consumer, and it confirms the hit unless it is an accepted consumer. Records of
        # greater depth are nested payloads and are skipped; a record of lower depth ends the
        # search. A Posix pipeline ends at the first same-depth delimiter other than '|'; a
        # PowerShell payload carries no pipeline delimiter, so every later record qualifies.
        $previous = $record
        for ($next = $position + 1; $next -lt $records.Count; $next++) {
            $consumer = $records[$next]
            if ($consumer.Depth -lt $record.Depth) { break }
            if ($consumer.Depth -gt $record.Depth) { continue }
            if ($record.Dialect -ne 'PowerShell' -and $previous.Delimiter -ne '|') { break }
            $previous = $consumer
            if ($carries[$next]) { continue }
            if (-not (Test-OrchestrationGateAcceptedConsumer -Record $consumer -HostTable $hostTable)) { return $true }
        }

        if ($isExpression) {
            if ($record.RawText.Contains('::') -or $record.RawText.IndexOf('.Invoke', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
            continue
        }
        if ($wrappers -contains $leaf) {
            # An expanded wrapper is judged through its payload records (the following records
            # at a greater depth); a wrapper whose payload never carries the word confirms.
            $payloadCarries = $false
            for ($next = $position + 1; $next -lt $records.Count -and $records[$next].Depth -gt $record.Depth; $next++) {
                if ($carries[$next]) { $payloadCarries = $true }
            }
            if (-not $payloadCarries) { return $true }
            continue
        }
        if (-not (Test-OrchestrationGateMentionHostRecord -Record $record -HostTable $hostTable)) { return $true }
    }
    if ($carrying -eq 0) { return $true }

    # Decision D17: rules 1 to 5 would drop the hit, so it is dropped only for a modelled
    # command whose earlier pipeline stages are accepted consumers as well (backward walk).
    if (-not (Test-OrchestrationGateCommandModelled -CommandText $CommandText -Record $records -GovernedWord $governedWords -PathMarker $pathMarker -HostTable $hostTable)) { return $true }
    for ($position = 0; $position -lt $records.Count; $position++) {
        if (-not $carries[$position]) { continue }
        $record = $records[$position]
        for ($earlier = $position - 1; $earlier -ge 0; $earlier--) {
            $stage = $records[$earlier]
            if ($stage.Depth -gt $record.Depth) { continue }
            if ($stage.Depth -lt $record.Depth) { break }
            if ($record.Dialect -ne 'PowerShell' -and $stage.Delimiter -ne '|') { break }
            if ($carries[$earlier]) { continue }
            if (-not (Test-OrchestrationGateAcceptedConsumer -Record $stage -HostTable $hostTable)) { return $true }
        }
    }
    return $false
}
