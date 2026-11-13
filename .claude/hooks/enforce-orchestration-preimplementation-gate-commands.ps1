<#
.SYNOPSIS
    Stage-2 confirmation of the preimplementation gate's command classification (issue #1160).

.DESCRIPTION
    Dot-sourced, guarded, by .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1. Test-ImplementationCommand keeps
    its five stage-1 patterns and its structural staging check unchanged. A regex hit (including
    the regex half of the staging pattern when the structural check found no git add or git
    commit) is passed to Test-OrchestrationGateInvocationConfirmed, which keeps the hit unless
    every occurrence of the governed word is an operand of a known non-executing mention host
    and no later stage of the same pipeline can execute it.
    Stage 2 runs only after a stage-1 hit, so the change can only remove classifications: a
    command that no stage-1 pattern matches is never classified (decisions D1 to D3).

    The rule (decisions D2 and D16) works over the records of Read-CommandLineInvocationSegment,
    which expands sh/bash -c, pwsh -c and -EncodedCommand, eval, substitution bodies, and xargs.
    The hit is confirmed when any of the following holds:
      1. A record is Unbalanced, or Opaque with DecodeFailure or DepthLimit, or an Opaque
         NoPayload wrapper (a shell reading stdin or a heredoc, pwsh -File) while its own text or
         the whole command carries a governed word.
      2. A record's command word is an evaluator (Invoke-Expression, iex, Invoke-Command, icm,
         Start-Process, saps, start, cmd, cmd.exe, source, .) while the whole command carries a
         governed word.
      3. A record that carries the governed word as a whole token is not a mention-host record
         (Test-OrchestrationGateMentionHostRecord): it is not led by a host of
         Get-OrchestrationGateMentionHostTable, it is led by a NotHost command word, or it
         carries an executing option (rg --pre, git -O or --open-files-in-pager, sort
         --compress-program). A PowerShell non-command expression record is accepted only when
         its text contains neither '::' nor '.Invoke'. An expanded wrapper record is judged
         through its payload records, and it confirms the hit when no payload record carries
         the word.
      4. No record carries the governed word at all.
      5. A record that does not carry the governed word is a pipeline consumer of a carrying
         record and is not an accepted consumer (decision D16). A consumer follows the carrying
         record at the same Depth with no record of lower Depth between them (nested payload
         records are skipped); for a Posix carrying record every same-depth record up to the
         consumer ended with '|', and for a PowerShell carrying record every later record of
         the same payload qualifies. An accepted consumer is a mention-host record or a
         PowerShell expression record without '::' or '.Invoke'.
    The governed words are git for the staging pattern; black, ruff, pyright, and pytest;
    prettier, lint, typecheck, and test:unit; prettier, eslint, tsc, and jest; and, for the pwsh
    pattern, Invoke-Pester as a whole token or the text tests/scripts/.

    This is a policy-level control, not a security control: the mention-host table is a
    negative model that fails closed for any launcher it does not name, so an unmodelled
    launcher (conda run, hatch run, coverage run -m, tox) or pipeline consumer stays classified.

.NOTES
    PowerShell 7+. Pure string logic: no disk, process, network, clock, or environment access,
    and no StrictMode or preference assignment, because a dot-sourced file changes its caller's
    scope. Call-time dependencies, loaded by each gate through hook-command-invocation.ps1:
    Read-CommandLineInvocationSegment, Skip-CommandLineTransparentWrapper,
    ConvertTo-CommandLineLeafWord, and Test-CommandLineWordPresent (hook-command-payload.ps1).
    Byte-identical at .claude/hooks/, .codex/hooks/, and both bundle mirrors under
    extensions/drm-copilot/resources/.
    AUTHORITY: PowerShell-authoritative. This hook file starts no interpreter process.
#>

function Get-OrchestrationGateMentionHostTable {
    <#
    .SYNOPSIS
        Return the decision D2 mention-host table, as amended by D16 (issue #1160).
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
            rg   = @('--pre')
            git  = @('-O', '--open-files-in-pager')
            sort = @('--compress-program')
        }
        NotHost         = @('ForEach-Object', '%', 'foreach', 'find')
    }
}

function Test-OrchestrationGateMentionHostRecord {
    <#
    .SYNOPSIS
        Report whether a record is led by a non-executing mention host (decisions D2 and D16).
    .DESCRIPTION
        Returns $true when the command word of the record, after transparent wrappers, is a
        host of the table (a group host, or a subcommand-scoped host with a listed
        subcommand), is not listed in NotHost, and no later token starts with an executing
        option of that host. Returns $false for a record with no command word. Used for a
        record that carries the governed word (rule 3) and for a pipeline consumer (rule 5).
    .PARAMETER Record
        A record of Read-CommandLineInvocationSegment.
    .PARAMETER HostTable
        The table returned by Get-OrchestrationGateMentionHostTable.
    .OUTPUTS
        System.Boolean
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
        $subcommand = ''
        for ($next = $wordIndex + 1; $next -lt $tokens.Count; $next++) {
            if (-not $tokens[$next].StartsWith('-', [System.StringComparison]::Ordinal)) { $subcommand = $tokens[$next]; break }
        }
        $isHost = @($HostTable.Subcommand[$leafKey]) -ccontains $subcommand
    }
    if ($isHost -and $HostTable.ExecutingOption.Contains($leafKey)) {
        for ($next = $wordIndex + 1; $next -lt $tokens.Count; $next++) {
            foreach ($option in @($HostTable.ExecutingOption[$leafKey])) {
                if ($tokens[$next].StartsWith($option, [System.StringComparison]::Ordinal)) { $isHost = $false }
            }
        }
    }
    return $isHost
}

function Test-OrchestrationGateInvocationConfirmed {
    <#
    .SYNOPSIS
        Report whether a stage-1 pattern hit is a real invocation (decisions D2 and D16, issue #1160).
    .DESCRIPTION
        Returns $true (the hit stands and the command is classified) unless every record of
        Read-CommandLineInvocationSegment that carries the governed word of the pattern is a
        mention-host record (Test-OrchestrationGateMentionHostRecord) or a PowerShell
        expression record without '::' or '.Invoke', every pipeline consumer of a carrying
        record is an accepted consumer (decision D16), and no fallback of the file header
        applies. Returns $false only when the hit is a mention. The caller invokes it only
        after a stage-1 hit.
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
            $consumerTokens = [string[]]@($consumer.Tokens)
            if ($consumer.Dialect -eq 'PowerShell' -and [string]::IsNullOrEmpty([string]$consumer.CommandWord) -and $consumerTokens.Count -eq 0) {
                if ($consumer.RawText.Contains('::') -or $consumer.RawText.IndexOf('.Invoke', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
                continue
            }
            if (-not (Test-OrchestrationGateMentionHostRecord -Record $consumer -HostTable $hostTable)) { return $true }
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
    return ($carrying -eq 0)
}
