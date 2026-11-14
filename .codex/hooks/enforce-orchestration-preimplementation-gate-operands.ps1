<#
.SYNOPSIS
    Command-operand extraction for the single-feature command leg of the preimplementation gate (issue #1188).

.DESCRIPTION
    Get-OrchestrationGateCommandTargetOperand (called by Resolve-OrchestrationGateTarget in each
    surface's -epic-scope.ps1) returns the git add/commit selectors and absolute operands
    (Get-OrchestrationGateCommandOperandPath, rule 1) and, for every record carrying a governed
    word of the stage-1 patterns (rule 2), after the prefix walk (rule 3): the directory selector
    (git -C, poetry -C/--directory/-P/--project, npm and npx --prefix/-C, env -C/--chdir, pwsh
    -WorkingDirectory/-wd), the script operand of sh/bash/zsh/dash/ksh and pwsh -File/-f (rule 4),
    and every literal absolute operand that is not a redirection target or option value (rule 5).
    A shell-variable or substitution selector or path-like operand, a missing selector value, an
    unmodelled prefix or poetry option, an env split string, and an Unbalanced, DecodeFailure, or
    DepthLimit carrying record set Unresolved: the gate denies TARGET_WORKTREE_NOT_DERIVABLE before
    any listing or checkpoint read. Intended strengthening: git -C $W add x now denies even with a
    ready session-root checkpoint. Records split at $(, ${, or a backtick are harvested as one
    group. Prefix and poetry/npm option names follow test-execution-command-form.ps1 (not loaded).
.NOTES
    PowerShell 7+. Pure string logic (no file system, process, clock, or environment access; no
    dot-source); call-time dependencies are loaded by the gate. Byte-identical in .claude/hooks,
    .codex/hooks, and both bundles (enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1).
#>

# Rule 2: the whole-token governed words of the five stage-1 patterns, and the Pester path text.
$script:OrchestrationGateGovernedWords = @('git', 'black', 'ruff', 'pyright', 'pytest', 'prettier', 'lint', 'typecheck', 'test:unit', 'eslint', 'tsc', 'jest', 'Invoke-Pester')
$script:OrchestrationGateGovernedText = 'tests/scripts/'

# Delimiters after which the scanner continues the same shell word in a new record.
$script:OrchestrationGateJoiningDelimiters = @('(', ')', '{', '}', '$(', '`')
$script:OrchestrationGateAbsolutePattern = '^([A-Za-z]:[\\/]|/)'

# Rule 3: the prefix walk. Operand is the count of non-option tokens a prefix consumes.
$script:OrchestrationGatePrefixTable = @{
    env     = @{ Standalone = @('-i', '-', '-0', '-v', '--ignore-environment', '--null', '--debug'); Value = @('-u', '--unset'); Selector = @('-C', '--chdir'); Split = @('-S', '--split-string'); Assign = $true; Operand = 0 }
    timeout = @{ Standalone = @('-v', '--verbose', '--preserve-status', '--foreground'); Value = @('-s', '--signal', '-k', '--kill-after'); Selector = @(); Split = @(); Assign = $false; Operand = 1 }
    time    = @{ Standalone = @('-p', '-a', '-v', '--portability', '--append', '--verbose'); Value = @('-o', '--output', '-f', '--format'); Selector = @(); Split = @(); Assign = $false; Operand = 0 }
    command = @{ Standalone = @('-p'); Value = @(); Selector = @(); Split = @(); Assign = $false; Operand = 0 }
    nohup   = @{ Standalone = @(); Value = @(); Selector = @(); Split = @(); Assign = $false; Operand = 0 }
    nice    = @{ Standalone = @(); Value = @('-n', '--adjustment'); Selector = @(); Split = @(); Assign = $false; Operand = 0 }
}

# Rule 4: host selectors.
$script:OrchestrationGatePoetryOptionTable = @{
    Standalone = @('-v', '-vv', '-vvv', '--verbose', '-h', '--help', '-q', '--quiet', '--ansi', '--no-ansi', '-V', '--version', '-n', '--no-interaction', '--no-plugins', '--no-cache')
    Value      = @(); Selector = @('-C', '--directory', '-P', '--project'); Split = @(); Assign = $false; Operand = 0
}
$script:OrchestrationGateNpmSelectors = @('--prefix', '-C')
$script:OrchestrationGatePowerShellSelectors = @('-workingdirectory', '-wd')
$script:OrchestrationGatePowerShellFileFlags = @('-file', '-f')
$script:OrchestrationGatePowerShellValueFlags = @('-executionpolicy', '-ep', '-ex', '-windowstyle', '-w', '-inputformat', '-if', '-outputformat', '-of', '-configurationname', '-settingsfile')
$script:OrchestrationGatePowerShellPayloadFlags = @('-c', '-e', '-ec', '-cwa', '-commandwithargs')
$script:OrchestrationGatePosixShells = @('sh', 'bash', 'zsh', 'dash', 'ksh')

function Add-OrchestrationGateOperandFinding {
    <#
    .SYNOPSIS
        Records an unresolvable -Class (first Detail kept) or a selector value: missing or non-literal is
        unresolvable, a relative literal is ignored, an absolute literal is added once.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable] $State, [AllowEmptyString()][string] $Class = '', [AllowEmptyString()][string] $Token = '',
        [AllowEmptyString()][string] $SelectorName = '', [AllowNull()][object] $Value = $null)

    if (-not $Class -and [string]::IsNullOrEmpty([string]$Value)) {
        $Class = 'missing selector value'; $Token = $SelectorName
    } elseif (-not $Class -and -not (Test-CommandLineTokenLiteral -Token ([string]$Value))) {
        $Class = 'shell variable or substitution'; $Token = [string]$Value
    }
    if ($Class) {
        if (-not $State.Unresolved) { $State.Unresolved = $true; $State.Detail = "unresolvable operand ($Class): '$Token'" }
        return
    }
    $path = [string]$Value
    if ($path -match $script:OrchestrationGateAbsolutePattern -and $State.Paths -notcontains $path) { $State.Paths.Add($path) }
}

function Read-OrchestrationGateOptionRun {
    <#
    .SYNOPSIS
        Walks one option table from Index and returns the index of the first non-option token. Value and
        Selector options take a separate, inline, or attached value (Selector values are recorded); '--'
        ends the run; a Split or unmodelled dash token is unresolvable. Assign skips VAR=value tokens.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token, [Parameter(Mandatory)][int] $Index,
        [Parameter(Mandatory)][hashtable] $Table, [Parameter(Mandatory)][hashtable] $State, [switch] $AllowDigitOption)

    $position = $Index
    while ($position -lt $Token.Count -and -not $State.Unresolved) {
        $current = $Token[$position]
        if ($Table.Assign -and $current -match '^[A-Za-z_][A-Za-z0-9_]*=') { $position++; continue }
        if (-not $current.StartsWith('-')) { break }
        if ($current -ceq '--') { return $position + 1 }
        $equals = if ($current.StartsWith('--')) { $current.IndexOf('=') } else { -1 }
        $name = if ($equals -gt 0) { $current.Substring(0, $equals) } else { $current }
        $inline = if ($equals -gt 0) { $current.Substring($equals + 1) } else { $null }
        $short = if ($current -cmatch '^-[^-]' -and $current.Length -gt 2) { $current.Substring(0, 2) } else { '' }
        if ($Table.Standalone -ccontains $current) { $position++; continue }
        if ($Table.Split -ccontains $name -or ($short -and $Table.Split -ccontains $short)) {
            Add-OrchestrationGateOperandFinding -State $State -Class 'split string' -Token $current; break
        }
        if ($Table.Selector -ccontains $name -or $Table.Value -ccontains $name) {
            $value = $inline; $position++
            if ($null -eq $value -and $position -lt $Token.Count) { $value = $Token[$position]; $position++ }
            if ($Table.Selector -ccontains $name) { Add-OrchestrationGateOperandFinding -State $State -SelectorName $name -Value $value }
            continue
        }
        if ($short -and ($Table.Selector -ccontains $short -or $Table.Value -ccontains $short)) {
            if ($Table.Selector -ccontains $short) { Add-OrchestrationGateOperandFinding -State $State -SelectorName $short -Value $current.Substring(2) }
            $position++; continue
        }
        if ($AllowDigitOption -and $current -match '^-\d+$') { $position++; continue }
        Add-OrchestrationGateOperandFinding -State $State -Class 'unmodelled option' -Token $current; break
    }
    return $position
}

function Get-OrchestrationGateHostOperand {
    <#
    .SYNOPSIS
        Records one host's selectors and script operand and returns its operand tokens: git -C only (git
        operands come from rule 1); poetry options, then tokens after the subcommand; npm/npx --prefix/-C;
        pwsh -wd and -File/-f or a positional script (a payload flag ends the scan); a POSIX shell's
        first non-option token unless a -c cluster is present; any other host, every token.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)][string] $HostWord, [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token,
        [Parameter(Mandatory)][hashtable] $State)

    $operands = [System.Collections.Generic.List[string]]::new()
    if ($HostWord -eq 'git') {
        $git = Get-CommandLineGlobalOption -CommandWord 'git'
        for ($position = 0; $position -lt $Token.Count -and $Token[$position].StartsWith('-'); $position++) {
            $current = $Token[$position]
            $value = if ($position + 1 -lt $Token.Count) { $Token[$position + 1] } else { $null }
            if ($current -ceq '-C') { Add-OrchestrationGateOperandFinding -State $State -SelectorName '-C' -Value $value; $position++; continue }
            if ($git.WithArgument -ccontains $current) { $position++; continue }
            if ($git.Standalone -ccontains $current -or ($current.Contains('=') -and ($git.WithArgument + $git.Standalone) -ccontains $current.Split('=')[0])) { continue }
            break
        }
        return [string[]]@()
    }
    if ($HostWord -eq 'poetry') {
        $next = Read-OrchestrationGateOptionRun -Token $Token -Index 0 -Table $script:OrchestrationGatePoetryOptionTable -State $State
        return [string[]]@($Token | Select-Object -Skip ($next + 1))
    }
    for ($position = 0; $position -lt $Token.Count; $position++) {
        $current = $Token[$position]
        $value = if ($position + 1 -lt $Token.Count) { $Token[$position + 1] } else { $null }
        if ($HostWord -eq 'npm' -or $HostWord -eq 'npx') {
            if ($script:OrchestrationGateNpmSelectors -ccontains $current) {
                Add-OrchestrationGateOperandFinding -State $State -SelectorName $current -Value $value; $position++
            } elseif ($current.StartsWith('--prefix=')) {
                Add-OrchestrationGateOperandFinding -State $State -SelectorName '--prefix' -Value $current.Substring(9)
            } else { $operands.Add($current) }
            continue
        }
        if ($HostWord -eq 'pwsh' -or $HostWord -eq 'powershell') {
            $flag = $current.ToLowerInvariant()
            if (-not $current.StartsWith('-')) { $flag = '-file'; $value = $current; $position-- }
            if ($script:OrchestrationGatePowerShellSelectors -contains $flag) {
                Add-OrchestrationGateOperandFinding -State $State -SelectorName $current -Value $value; $position++
            } elseif ($script:OrchestrationGatePowerShellFileFlags -contains $flag) {
                Add-OrchestrationGateOperandFinding -State $State -SelectorName $current -Value $value
                foreach ($argument in @($Token | Select-Object -Skip ($position + 2))) { $operands.Add($argument) }
                break
            } elseif ($script:OrchestrationGatePowerShellValueFlags -contains $flag) {
                $position++
            } elseif ($script:OrchestrationGatePowerShellPayloadFlags -contains $flag -or ($flag.Length -ge 4 -and ('-command'.StartsWith($flag) -or '-encodedcommand'.StartsWith($flag)))) {
                break
            }
            continue
        }
        if ($script:OrchestrationGatePosixShells -contains $HostWord) {
            if ($current -cmatch '^-[A-Za-z]*c[A-Za-z]*$') { break }
            if ($current -ceq '-o' -or $current -ceq '+o') { $position++; continue }
            if ($current.StartsWith('-') -or $current.StartsWith('+')) { continue }
            Add-OrchestrationGateOperandFinding -State $State -SelectorName 'script operand' -Value $current
            foreach ($argument in @($Token | Select-Object -Skip ($position + 1))) { $operands.Add($argument) }
            break
        }
        $operands.Add($current)
    }
    return [string[]]$operands.ToArray()
}

function Add-OrchestrationGateRecordOperand {
    <#
    .SYNOPSIS
        Applies rules 3 to 5 to one harvested record: skips VAR=value tokens and the prefixes, records
        the host selectors, then every literal absolute operand. A redirection and its target are
        skipped; a non-literal operand that contains '/' or '\' is unresolvable.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token, [Parameter(Mandatory)][hashtable] $State)

    $position = 0
    while ($position -lt $Token.Count -and -not $State.Unresolved) {
        if ($Token[$position] -match '^[A-Za-z_][A-Za-z0-9_]*=') { $position++; continue }
        $leaf = (ConvertTo-CommandLineLeafWord -Word $Token[$position]).ToLowerInvariant()
        if (-not $script:OrchestrationGatePrefixTable.ContainsKey($leaf)) { break }
        $table = $script:OrchestrationGatePrefixTable[$leaf]
        $position = (Read-OrchestrationGateOptionRun -Token $Token -Index ($position + 1) -Table $table -State $State -AllowDigitOption:($leaf -eq 'nice')) + $table.Operand
    }
    if ($State.Unresolved -or $position -ge $Token.Count) { return }
    $hostWord = (ConvertTo-CommandLineLeafWord -Word $Token[$position]).ToLowerInvariant()
    $operands = @(Get-OrchestrationGateHostOperand -HostWord $hostWord -Token ([string[]]@($Token | Select-Object -Skip ($position + 1))) -State $State)
    for ($index = 0; $index -lt $operands.Count -and -not $State.Unresolved; $index++) {
        $current = [string]$operands[$index]
        if ($current -match '^(<|>|\d*>|&>)') { if ($current -match '^(\d*[<>]{1,2}&?|&>{1,2})$') { $index++ }; continue }
        if (-not (Test-CommandLineTokenLiteral -Token $current)) {
            if ($current -match '[\\/]') { Add-OrchestrationGateOperandFinding -State $State -Class 'shell variable or substitution' -Token $current }
            continue
        }
        if ($current -match $script:OrchestrationGateAbsolutePattern -and $State.Paths -notcontains $current) { $State.Paths.Add($current) }
    }
}

function Get-OrchestrationGateHarvestedRecordIndex {
    <#
    .SYNOPSIS
        Returns the indexes of the records that carry a governed word (rule 2): the raw text holds a
        governed word or tests/scripts/, or a payload record beneath it (greater Depth, before the next
        record of equal or lower Depth) does. Records joined by a grouping or substitution delimiter at
        one Depth form a group that carries when any member does.
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Record)

    $count = $Record.Count
    $own = [bool[]]::new($count)
    for ($index = 0; $index -lt $count; $index++) {
        $text = [string]$Record[$index].RawText
        $own[$index] = $text.IndexOf($script:OrchestrationGateGovernedText, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        foreach ($word in $script:OrchestrationGateGovernedWords) {
            if ($own[$index]) { break }
            $own[$index] = Test-CommandLineWordPresent -RawText $text -Word $word
        }
    }
    $group = [int[]]::new($count)
    $groupCarries = @{}
    for ($index = 0; $index -lt $count; $index++) {
        if ($group[$index] -eq 0) { $group[$index] = $index + 1 }
        $carries = $own[$index]
        for ($inner = $index + 1; $inner -lt $count -and $Record[$inner].Depth -gt $Record[$index].Depth; $inner++) {
            if ($own[$inner]) { $carries = $true }
        }
        if ($carries) { $groupCarries[$group[$index]] = $true }
        if ($script:OrchestrationGateJoiningDelimiters -ccontains [string]$Record[$index].Delimiter) {
            for ($inner = $index + 1; $inner -lt $count -and $Record[$inner].Depth -ge $Record[$index].Depth; $inner++) {
                if ($Record[$inner].Depth -eq $Record[$index].Depth) { $group[$inner] = $group[$index]; break }
            }
        }
    }
    return [int[]]@(0..($count - 1) | Where-Object { $count -gt 0 -and $groupCarries.ContainsKey($group[$_]) })
}

function Get-OrchestrationGateCommandTargetOperand {
    <#
    .SYNOPSIS
        Returns Paths (distinct, first-seen order: selectors, script operands, absolute operands, then the
        git staging operands), Unresolved, and Detail (empty unless Unresolved) for a gated Bash command.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

    $state = @{ Paths = [System.Collections.Generic.List[string]]::new(); Unresolved = $false; Detail = '' }
    $staged = @(Get-OrchestrationGateCommandOperandPath -Command $Command)
    foreach ($value in $staged) {
        if (-not (Test-CommandLineTokenLiteral -Token $value)) { Add-OrchestrationGateOperandFinding -State $state -Class 'shell variable or substitution' -Token $value }
    }
    $records = @(Read-CommandLineInvocationSegment -CommandText $Command)
    foreach ($index in @(Get-OrchestrationGateHarvestedRecordIndex -Record $records)) {
        if ($state.Unresolved) { break }
        $record = $records[$index]
        $raw = ([string]$record.RawText).Trim()
        if ($record.Unbalanced -or ($record.Opaque -and @('DecodeFailure', 'DepthLimit') -contains $record.OpaqueReason)) {
            Add-OrchestrationGateOperandFinding -State $state -Class 'malformed record' -Token $raw
        } elseif (@('$(', '`') -ccontains [string]$record.Delimiter -or ([string]$record.Delimiter -ceq '{' -and $raw.EndsWith('$'))) {
            Add-OrchestrationGateOperandFinding -State $state -Class 'shell variable or substitution' -Token $raw
        } else {
            Add-OrchestrationGateRecordOperand -Token ([string[]]@($record.Tokens)) -State $state
        }
    }
    if ($state.Unresolved) { return [pscustomobject]@{ Paths = [string[]]@(); Unresolved = $true; Detail = [string]$state.Detail } }
    foreach ($value in $staged) {
        if ($state.Paths -notcontains $value) { $state.Paths.Add($value) }
    }
    return [pscustomobject]@{ Paths = [string[]]$state.Paths.ToArray(); Unresolved = $false; Detail = '' }
}
