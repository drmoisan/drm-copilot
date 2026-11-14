<#
.SYNOPSIS
    Pure command-form normalization, runner matching, launcher matching, and hidden-wrapper
    text rules for the test-execution policy hook (issue #1158, spec D25).

.DESCRIPTION
    Dot-sources nothing. The caller loads hook-command-invocation.ps1 first, which provides
    Read-CommandLineInvocationSegment, Add-CommandLinePowerShellRecord,
    ConvertTo-CommandLineLeafWord, and the option tables this file reads. Every function is
    pure over its inputs: no disk, process, network, clock, or environment access, and nothing
    is written to any stream when the file is dot-sourced.

    Dot-sourced as: . (Join-Path $PSScriptRoot 'test-execution-command-form.ps1')
#>

# Prefix commands skipped by normalization (spec ## Hook, D25). Option names are compared
# case-sensitively. Value options take the next token, an '=' value, or (for a two-character
# option) an attached value.
$script:TestExecutionPrefixTable = @{
    env     = @{ Standalone = @('-i', '-', '-0', '-v', '--ignore-environment', '--null', '--debug'); Value = @('-u', '--unset', '-C', '--chdir'); Split = @('-S', '--split-string'); Operand = 0 }
    timeout = @{ Standalone = @('-v', '--verbose', '--preserve-status', '--foreground'); Value = @('-s', '--signal', '-k', '--kill-after'); Split = @(); Operand = 1 }
    time    = @{ Standalone = @('-p', '-a', '-v', '--portability', '--append', '--verbose'); Value = @('-o', '--output', '-f', '--format'); Split = @(); Operand = 0 }
    command = @{ Standalone = @('-p'); Value = @(); Split = @(); Operand = 0 }
    nohup   = @{ Standalone = @(); Value = @(); Split = @(); Operand = 0 }
    exec    = @{ Standalone = @('-c', '-l'); Value = @('-a'); Split = @(); Operand = 0 }
    nice    = @{ Standalone = @(); Value = @('-n', '--adjustment'); Split = @(); Operand = 0 }
    stdbuf  = @{ Standalone = @(); Value = @('-i', '-o', '-e', '--input', '--output', '--error'); Split = @(); Operand = 0 }
    sudo    = @{ Standalone = @('-E', '-H', '-n', '-S', '-k'); Value = @('-u', '-g'); Split = @(); Operand = 0 }
}

$script:TestExecutionPoetryOption = @{ Standalone = @('-q', '-v', '-n', '--no-interaction', '--quiet'); Value = @('-C', '--directory', '-P', '--project'); Split = @(); Operand = 0 }
$script:TestExecutionNpmOption = @{ Standalone = @('-s', '--silent', '-q', '--quiet', '--if-present'); Value = @('--prefix', '-w', '--workspace'); Split = @(); Operand = 0 }
$script:TestExecutionPythonStandalone = @('-B', '-E', '-I', '-O', '-OO', '-q', '-s', '-S', '-u', '-v', '-b')
$script:TestExecutionPythonValue = @('-X', '-W')
$script:TestExecutionShellName = @('sh', 'bash', 'zsh', 'dash', 'ksh')
$script:TestExecutionPowerShellName = @('pwsh', 'powershell')
$script:TestExecutionExemptTail = @('--version', '--help', '-h')

# Leaf command words that start a suite, mapped to their runner. Used for the unmodeled-option
# rule and the variable-assignment rule.
$script:TestExecutionRunnerWord = @{
    'pytest' = 'pytest'; 'py.test' = 'pytest'; 'jest' = 'jest'; 'bats' = 'bats'
    'invoke-pester' = 'pester'; 'invoke-poshqctest' = 'pester'; 'invoke-poshqcparalleltest' = 'pester'
    'invoke-poshqcsuite' = 'pester'; 'invoke-pestersuite.ps1' = 'pester'; 'run-jest.cjs' = 'jest'
}

function ConvertTo-TestExecutionLeafWord {
    <#
    .SYNOPSIS
        Return the lower-case leaf of a command word (path and '.exe' removed).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()][AllowNull()][string] $Word)

    if ([string]::IsNullOrEmpty($Word)) { return '' }
    return (ConvertTo-CommandLineLeafWord -Word $Word).ToLowerInvariant()
}

function ConvertTo-TestExecutionQuotedText {
    <#
    .SYNOPSIS
        Re-quote words as POSIX single-quoted words joined by spaces.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    $quoted = foreach ($current in $Word) { "'" + $current.Replace("'", "'\''") + "'" }
    return (@($quoted) -join ' ')
}

function Skip-TestExecutionOption {
    <#
    .SYNOPSIS
        Skip the options of one command from Index, using one option table.
    .DESCRIPTION
        Returns Index (the first operand), Unmodeled (an option outside the table), and
        SplitText (the value of a -S style option that is a command line).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token,
        [Parameter(Mandatory)][int] $Index,
        [Parameter(Mandatory)][hashtable] $Table,
        [switch] $AllowDigitOption
    )

    $position = $Index
    $splitText = ''
    while ($position -lt $Token.Count -and $Token[$position].StartsWith('-')) {
        $option = $Token[$position]
        if ($option -ceq '--') { $position++; break }
        if ($Table.Standalone -ccontains $option) { $position++; continue }
        if ($Table.Value -ccontains $option) { $position += 2; continue }
        if ($Table.Split -ccontains $option) {
            if ($position + 1 -lt $Token.Count) { $splitText = $Token[$position + 1] }
            $position += 2
            continue
        }
        $equals = $option.IndexOf('=')
        if ($equals -gt 0) {
            $name = $option.Substring(0, $equals)
            if ($Table.Value -ccontains $name) { $position++; continue }
            if ($Table.Split -ccontains $name) { $splitText = $option.Substring($equals + 1); $position++; continue }
        }
        if ($option.Length -gt 2 -and -not $option.StartsWith('--') -and ($Table.Value -ccontains $option.Substring(0, 2))) { $position++; continue }
        if ($AllowDigitOption -and $option -match '^-\d+$') { $position++; continue }
        return [pscustomobject]@{ Index = $position; Unmodeled = $true; SplitText = $splitText }
    }
    return [pscustomobject]@{ Index = $position; Unmodeled = $false; SplitText = $splitText }
}

function Get-TestExecutionFindExecText {
    <#
    .SYNOPSIS
        Return the command text after each -exec, -execdir, -ok, or -okdir of a find record.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    $texts = [System.Collections.Generic.List[string]]::new()
    for ($position = 0; $position -lt $Token.Count; $position++) {
        if (@('-exec', '-execdir', '-ok', '-okdir') -cnotcontains $Token[$position]) { continue }
        $words = [System.Collections.Generic.List[string]]::new()
        $position++
        while ($position -lt $Token.Count -and @(';', '\;', '+') -cnotcontains $Token[$position]) { $words.Add($Token[$position]); $position++ }
        if ($words.Count -gt 0) { $texts.Add((ConvertTo-TestExecutionQuotedText -Word $words.ToArray())) }
    }
    return [string[]]$texts.ToArray()
}

function Get-TestExecutionCommandForm {
    <#
    .SYNOPSIS
        Normalize one record's tokens to the words of the command that runs (spec D25).
    .DESCRIPTION
        Skips VAR=value tokens and the prefix commands of spec ## Hook, replaces the launch
        commands (poetry run, uv run, uvx, pipx run, npx, npm exec, npm x) by the command they
        launch, and returns Words, Lookup (command -v or -V), Unmodeled (an option outside a
        table, with Words holding every token after the prefix command), ReRead (command texts
        to read again: env -S, npx -c, find -exec, and a shell, PowerShell, eval, or xargs
        wrapper reached after a prefix), and VariableCommand (the command word carries '$' or
        a backtick).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    $form = [pscustomobject]@{ Words = [string[]]@(); Lookup = $false; Unmodeled = $false; ReRead = [string[]]@(); VariableCommand = $false }
    $reRead = [System.Collections.Generic.List[string]]::new()
    $position = 0
    $skippedAny = $false
    while ($position -lt $Token.Count) {
        if ($Token[$position] -match '^[A-Za-z_][A-Za-z0-9_]*=') { $position++; continue }
        $leaf = ConvertTo-TestExecutionLeafWord -Word $Token[$position]
        $skip = $null
        if ($script:TestExecutionPrefixTable.ContainsKey($leaf)) {
            if ($leaf -eq 'command' -and $position + 1 -lt $Token.Count -and @('-v', '-V') -ccontains $Token[$position + 1]) {
                $form.Lookup = $true
                $form.Words = [string[]]@($Token | Select-Object -Skip $position)
                return $form
            }
            $table = $script:TestExecutionPrefixTable[$leaf]
            $skip = Skip-TestExecutionOption -Token $Token -Index ($position + 1) -Table $table -AllowDigitOption:($leaf -eq 'nice')
            if (-not $skip.Unmodeled) { $skip.Index += $table.Operand }
        } elseif ($leaf -eq 'poetry') {
            $skip = Skip-TestExecutionOption -Token $Token -Index ($position + 1) -Table $script:TestExecutionPoetryOption
            if (-not $skip.Unmodeled) {
                if ($skip.Index -ge $Token.Count -or $Token[$skip.Index] -cne 'run') { break }
                $skip.Index++
            }
        } elseif ($leaf -eq 'uv' -or $leaf -eq 'pipx' -or $leaf -eq 'uvx') {
            $next = $position + 1
            if ($leaf -ne 'uvx') {
                if ($next -ge $Token.Count -or $Token[$next] -cne 'run') { break }
                $next++
            }
            while ($next -lt $Token.Count -and $Token[$next].StartsWith('-')) {
                $next += if (@('--with', '--python', '--spec', '-p') -ccontains $Token[$next]) { 2 } else { 1 }
            }
            $skip = [pscustomobject]@{ Index = $next; Unmodeled = $false; SplitText = '' }
        } elseif ($leaf -eq 'npx') {
            $npx = Get-CommandLineGlobalOption -CommandWord 'npx'
            $table = @{ Standalone = [string[]]$npx.Standalone; Value = [string[]]@($npx.WithArgument | Where-Object { @('-c', '--call') -cnotcontains $_ }); Split = @('-c', '--call') }
            $skip = Skip-TestExecutionOption -Token $Token -Index ($position + 1) -Table $table
        } elseif ($leaf -eq 'npm') {
            $skip = Skip-TestExecutionOption -Token $Token -Index ($position + 1) -Table $script:TestExecutionNpmOption
            if ($skip.Unmodeled -or $skip.Index -ge $Token.Count -or @('exec', 'x') -cnotcontains $Token[$skip.Index]) { break }
            $skip.Index++
            if ($skip.Index -lt $Token.Count -and $Token[$skip.Index] -ceq '--') { $skip.Index++ }
        } elseif ($leaf -eq 'find') {
            foreach ($text in @(Get-TestExecutionFindExecText -Token ([string[]]@($Token | Select-Object -Skip $position)))) { $reRead.Add($text) }
            break
        } else {
            $rest = [string[]]@($Token | Select-Object -Skip $position)
            $wrapper = ($script:TestExecutionShellName -contains $leaf -and (Get-TestExecutionShellFileOperand -Word $rest) -lt 0) -or
            ($script:TestExecutionPowerShellName -contains $leaf -and (Get-TestExecutionHostFileOperand -Word $rest) -lt 0) -or $leaf -eq 'eval' -or $leaf -eq 'xargs'
            if ($wrapper -and $skippedAny) { $reRead.Add((ConvertTo-TestExecutionQuotedText -Word ([string[]]@($Token | Select-Object -Skip $position)))) }
            break
        }

        if ($skip.Unmodeled) {
            $form.Unmodeled = $true
            $form.Words = [string[]]@($Token | Select-Object -Skip ($position + 1))
            $form.ReRead = [string[]]$reRead.ToArray()
            return $form
        }
        if (-not [string]::IsNullOrEmpty($skip.SplitText)) {
            $remainder = [string[]]@($Token | Select-Object -Skip $skip.Index)
            $reRead.Add(($skip.SplitText + ' ' + (ConvertTo-TestExecutionQuotedText -Word $remainder)).Trim())
            $position = $Token.Count
            break
        }
        $skippedAny = $true
        $position = $skip.Index
    }

    $form.Words = [string[]]@($Token | Select-Object -Skip $position)
    if ($form.Words.Count -gt 0) { $form.VariableCommand = $form.Words[0].Contains('$') -or $form.Words[0].Contains('`') }
    $form.ReRead = [string[]]$reRead.ToArray()
    return $form
}

function Read-TestExecutionPowerShellRecord {
    <#
    .SYNOPSIS
        Return the reader records of PowerShell text (one per command and non-command node).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [ValidateRange(0, 64)][int] $MaxDepth = 4
    )

    $records = [System.Collections.Generic.List[pscustomobject]]::new()
    if ([string]::IsNullOrWhiteSpace($Text)) { return $records.ToArray() }
    $readerContext = @{ Records = $records; MaxDepth = $MaxDepth; NormalizedText = $Text }
    Add-CommandLinePowerShellRecord -Context $readerContext -Text $Text -Depth 0 -Wrapper '' -RootIndex -1 -RootRawText $Text -ArgumentInjected $false
    return $records.ToArray()
}

function Get-TestExecutionCommandRecord {
    <#
    .SYNOPSIS
        Return each reader record with its normalized form, plus the records of every ReRead
        text, within MaxDepth.
    .OUTPUTS
        System.Management.Automation.PSCustomObject[] with Record and Form.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [ValidateSet('Posix', 'PowerShell')][string] $Dialect = 'Posix',
        [ValidateRange(0, 64)][int] $MaxDepth = 4
    )

    $entries = [System.Collections.Generic.List[pscustomobject]]::new()
    if ([string]::IsNullOrWhiteSpace($CommandText)) { return $entries.ToArray() }
    $records = if ($Dialect -eq 'PowerShell') { @(Read-TestExecutionPowerShellRecord -Text $CommandText -MaxDepth $MaxDepth) } else { @(Read-CommandLineInvocationSegment -CommandText $CommandText -MaxDepth $MaxDepth) }
    foreach ($record in $records) {
        $form = Get-TestExecutionCommandForm -Token ([string[]]@($record.Tokens))
        $entries.Add([pscustomobject]@{ Record = $record; Form = $form })
        if ($MaxDepth -le 0) { continue }
        foreach ($text in $form.ReRead) {
            foreach ($child in @(Get-TestExecutionCommandRecord -CommandText $text -MaxDepth ($MaxDepth - 1))) { $entries.Add($child) }
        }
    }
    return $entries.ToArray()
}

function Get-TestExecutionHostFileOperand {
    <#
    .SYNOPSIS
        Return the -File operand index of a pwsh or powershell word list, or -1.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    $position = 1
    while ($position -lt $Word.Count -and $Word[$position].StartsWith('-')) {
        $flag = $Word[$position].ToLowerInvariant()
        if ($flag -eq '-file' -or $flag -eq '-f') { return $(if ($position + 1 -lt $Word.Count) { $position + 1 } else { -1 }) }
        if ($script:CommandLinePowerShellStandaloneFlags -contains $flag) { $position++; continue }
        if ($script:CommandLinePowerShellValueFlags -contains $flag) { $position += 2; continue }
        return -1
    }
    return -1
}

function Get-TestExecutionShellFileOperand {
    <#
    .SYNOPSIS
        Return the script-file operand index of a POSIX shell word list, or -1 when the shell
        runs a -c payload or has no operand.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    $position = 1
    while ($position -lt $Word.Count -and $Word[$position].StartsWith('-')) {
        if ($Word[$position] -cmatch '^-[A-Za-z]*c[A-Za-z]*$') { return -1 }
        $position++
    }
    return $(if ($position -lt $Word.Count) { $position } else { -1 })
}

function Get-TestExecutionLauncherMatch {
    <#
    .SYNOPSIS
        Match the sanctioned launcher: sh or bash with a run-test-suite.sh operand, or pwsh or
        powershell -File with an Invoke-TestSuite.ps1 operand, under .claude or .agents.
    .OUTPUTS
        PSCustomObject with Path, Suite, and Extras, or $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][pscustomobject] $Form)

    $words = [string[]]$Form.Words
    if ($Form.Lookup -or $Form.Unmodeled -or $words.Count -eq 0) { return $null }
    $leaf = ConvertTo-TestExecutionLeafWord -Word $words[0]
    $operand = -1
    $pattern = ''
    if (@('sh', 'bash') -contains $leaf) {
        $operand = Get-TestExecutionShellFileOperand -Word $words
        $pattern = '(^|/)\.(claude|agents)/skills/test-execution-policy/scripts/run-test-suite\.sh$'
    } elseif ($script:TestExecutionPowerShellName -contains $leaf) {
        $operand = Get-TestExecutionHostFileOperand -Word $words
        $pattern = '(^|/)\.(claude|agents)/skills/test-execution-policy/scripts/Invoke-TestSuite\.ps1$'
    }
    if ($operand -lt 0) { return $null }
    $path = $words[$operand].Replace('\', '/')
    if ($path -cnotmatch $pattern) { return $null }
    $suite = if ($operand + 1 -lt $words.Count) { $words[$operand + 1] } else { '' }
    return [pscustomobject]@{ Path = $path; Suite = $suite; Extras = [string[]]@($words | Select-Object -Skip ($operand + 2)) }
}

function Test-TestExecutionExemptTail {
    <#
    .SYNOPSIS
        Report whether the words after a runner word are only --version, --help, or -h.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word, [Parameter(Mandatory)][int] $Start)

    if ($Start -ge $Word.Count) { return $false }
    for ($position = $Start; $position -lt $Word.Count; $position++) {
        if ($script:TestExecutionExemptTail -cnotcontains $Word[$position]) { return $false }
    }
    return $true
}

function Get-TestExecutionNpmRunner {
    <#
    .SYNOPSIS
        Apply the D19 npm script rule: test, t, or run/run-script with a test or test: script.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    $skip = Skip-TestExecutionOption -Token $Word -Index 1 -Table $script:TestExecutionNpmOption
    if ($skip.Unmodeled -or $skip.Index -ge $Word.Count) { return '' }
    $subcommand = $Word[$skip.Index]
    if ($subcommand -ceq 'test' -or $subcommand -ceq 't') { return 'jest' }
    if ($subcommand -cne 'run' -and $subcommand -cne 'run-script') { return '' }
    $scriptSkip = Skip-TestExecutionOption -Token $Word -Index ($skip.Index + 1) -Table $script:TestExecutionNpmOption
    if ($scriptSkip.Unmodeled -or $scriptSkip.Index -ge $Word.Count) { return '' }
    $name = $Word[$scriptSkip.Index]
    if ($name -ceq 'test' -or $name.StartsWith('test:', [System.StringComparison]::Ordinal)) { return 'jest' }
    return ''
}

function Get-TestExecutionPythonRunner {
    <#
    .SYNOPSIS
        Match python, python3, or py with -m pytest, -m coverage run -m pytest, or -c code.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word, [int] $Depth = 0)

    $position = 1
    while ($position -lt $Word.Count -and $Word[$position].StartsWith('-')) {
        $option = $Word[$position]
        if ($option -ceq '-m' -and $position + 1 -lt $Word.Count) {
            $module = $Word[$position + 1]
            if ($module -ceq 'pytest') { return $(if (Test-TestExecutionExemptTail -Word $Word -Start ($position + 2)) { '' } else { 'pytest' }) }
            if ($module -ceq 'coverage') { return (Get-TestExecutionCoverageRunner -Word ([string[]]@($Word | Select-Object -Skip ($position + 1)))) }
            return ''
        }
        if ($option -ceq '-c' -and $position + 1 -lt $Word.Count) { return (Get-TestExecutionCodeRunner -Language 'Python' -Text $Word[$position + 1] -Depth ($Depth + 1)) }
        if ($script:TestExecutionPythonStandalone -ccontains $option) { $position++; continue }
        if ($script:TestExecutionPythonValue -ccontains $option) { $position += 2; continue }
        if ($option.Length -gt 2 -and $script:TestExecutionPythonValue -ccontains $option.Substring(0, 2)) { $position++; continue }
        return ''
    }
    return ''
}

function Get-TestExecutionCoverageRunner {
    <#
    .SYNOPSIS
        Match coverage run [options] -m pytest.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    if ($Word.Count -lt 2 -or $Word[1] -cne 'run') { return '' }
    for ($position = 2; $position + 1 -lt $Word.Count; $position++) {
        if ($Word[$position] -ceq '-m') { return $(if ($Word[$position + 1] -ceq 'pytest') { 'pytest' } else { '' }) }
        if (-not $Word[$position].StartsWith('-')) { return '' }
    }
    return ''
}

function Get-TestExecutionNodeRunner {
    <#
    .SYNOPSIS
        Match node with a code argument that starts a suite, a run-jest.cjs operand, or an
        operand under node_modules/jest/ or node_modules/jest-cli/.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word, [int] $Depth = 0)

    for ($position = 1; $position -lt $Word.Count; $position++) {
        $current = $Word[$position]
        if (@('-e', '--eval', '-p', '--print') -ccontains $current) {
            if ($position + 1 -ge $Word.Count) { return '' }
            return (Get-TestExecutionCodeRunner -Language 'JavaScript' -Text $Word[$position + 1] -Depth ($Depth + 1))
        }
        if ($current.StartsWith('-')) { continue }
        $path = $current.Replace('\', '/')
        if ((ConvertTo-TestExecutionLeafWord -Word $path) -eq 'run-jest.cjs') { return 'jest' }
        if ($path -match '(^|/)node_modules/(jest|jest-cli)/') { return 'jest' }
        return ''
    }
    return ''
}

function Get-TestExecutionRunnerMatch {
    <#
    .SYNOPSIS
        Return the runner (pytest, jest, pester, bats, mstest) a normalized form starts, or ''.
    .PARAMETER CommandText
        The whole command text, read only when the command word is not literal, to find a
        runner word assigned to a variable.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Form,
        [AllowEmptyString()][string] $CommandText = '',
        [int] $Depth = 0
    )

    $words = [string[]]$Form.Words
    if ($Form.Lookup -or $words.Count -eq 0) { return '' }
    if ($Form.Unmodeled) {
        foreach ($current in $words) {
            $leaf = ConvertTo-TestExecutionLeafWord -Word $current
            if ($script:TestExecutionRunnerWord.ContainsKey($leaf)) { return $script:TestExecutionRunnerWord[$leaf] }
        }
        return ''
    }
    if ($Form.VariableCommand) {
        foreach ($assignment in [regex]::Matches($CommandText, '(?:^|[\s;&|(])[A-Za-z_][A-Za-z0-9_]*=([''"]?)([^\s;&|)''"]+)\1')) {
            $leaf = ConvertTo-TestExecutionLeafWord -Word $assignment.Groups[2].Value
            if ($script:TestExecutionRunnerWord.ContainsKey($leaf)) { return $script:TestExecutionRunnerWord[$leaf] }
        }
        return ''
    }

    $leaf = ConvertTo-TestExecutionLeafWord -Word $words[0]
    if ($Depth -gt 4) { return '' }
    switch ($leaf) {
        { $_ -in @('pytest', 'py.test', 'jest', 'bats') } {
            if (Test-TestExecutionExemptTail -Word $words -Start 1) { return '' }
            return $script:TestExecutionRunnerWord[$leaf]
        }
        { $_ -in @('invoke-pester', 'invoke-poshqctest', 'invoke-poshqcparalleltest', 'invoke-poshqcsuite', 'invoke-pestersuite.ps1') } { return 'pester' }
        'shell-qc.sh' { return $(if ($words.Count -gt 1 -and $words[1] -ceq 'test') { 'bats' } else { '' }) }
        { $_ -in @('sh', 'bash') } {
            $operand = Get-TestExecutionShellFileOperand -Word $words
            $isShellQc = $operand -ge 0 -and (ConvertTo-TestExecutionLeafWord -Word $words[$operand]) -eq 'shell-qc.sh'
            return $(if ($isShellQc -and $operand + 1 -lt $words.Count -and $words[$operand + 1] -ceq 'test') { 'bats' } else { '' })
        }
        { $_ -in $script:TestExecutionPowerShellName } {
            $operand = Get-TestExecutionHostFileOperand -Word $words
            return $(if ($operand -ge 0 -and (ConvertTo-TestExecutionLeafWord -Word $words[$operand]) -eq 'invoke-pestersuite.ps1') { 'pester' } else { '' })
        }
        { $_ -in @('python', 'python3', 'py') } { return (Get-TestExecutionPythonRunner -Word $words -Depth $Depth) }
        'coverage' { return (Get-TestExecutionCoverageRunner -Word $words) }
        'node' { return (Get-TestExecutionNodeRunner -Word $words -Depth $Depth) }
        'dotnet' { return $(if ($words.Count -gt 1 -and $words[1] -ceq 'test') { 'mstest' } else { '' }) }
        'npm' { return (Get-TestExecutionNpmRunner -Word $words) }
    }
    return ''
}

function Get-TestExecutionRunnerSuite {
    <#
    .SYNOPSIS
        Return the D20 suite for a runner: the first suite of the merged policy whose runner
        equals it (built-in suites first), or '' when none has that runner.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Runner,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Policy
    )

    foreach ($name in @($Policy['suites'].Keys)) {
        if ([string]$Policy['suites'][$name]['runner'] -ceq $Runner) { return [string]$name }
    }
    return ''
}

function Get-TestExecutionCodeRunner {
    <#
    .SYNOPSIS
        Apply the Python or JavaScript text rules: pytest.main( (Python), run-jest.cjs or
        runCLI( (JavaScript), and any quoted string that is a runner command.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateSet('Python', 'JavaScript')][string] $Language,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [int] $Depth = 0
    )

    $commentPattern = if ($Language -eq 'Python') { '^\s*#' } else { '^\s*//' }
    $code = (@($Text -split "`r?`n" | Where-Object { $_ -notmatch $commentPattern }) -join "`n")
    if ($Language -eq 'Python' -and $code.Contains('pytest.main(')) { return 'pytest' }
    if ($Language -eq 'JavaScript') {
        if ($code.Contains('run-jest.cjs') -or $code.Contains('runCLI(')) { return 'jest' }
        if ($code -match '[''"`]dotnet[''"`]\s*,\s*\[\s*[''"`]test[''"`]') { return 'mstest' }
    }
    if ($Depth -gt 4) { return '' }
    $quotes = if ($Language -eq 'Python') { '"''' } else { '"''`' }
    foreach ($literal in [regex]::Matches($code, "([$quotes])((?:\\.|(?!\1)[^\\\r\n])*)\1")) {
        foreach ($entry in @(Get-TestExecutionCommandRecord -CommandText $literal.Groups[2].Value -MaxDepth 2)) {
            $runner = Get-TestExecutionRunnerMatch -Form $entry.Form -CommandText $literal.Groups[2].Value -Depth ($Depth + 1)
            if ($runner) { return $runner }
        }
    }
    return ''
}

function Get-TestExecutionHiddenWrapperMatch {
    <#
    .SYNOPSIS
        Return the runner a script file's text starts outside the sanctioned launcher, or ''.
    .DESCRIPTION
        Shell and PowerShell text are read through the same records and normalization as a
        Bash command; Python and JavaScript text through the code text rules.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateSet('Shell', 'PowerShell', 'Python', 'JavaScript')][string] $Language,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text
    )

    if ($Language -eq 'Python' -or $Language -eq 'JavaScript') { return (Get-TestExecutionCodeRunner -Language $Language -Text $Text) }
    $dialect = if ($Language -eq 'PowerShell') { 'PowerShell' } else { 'Posix' }
    foreach ($entry in @(Get-TestExecutionCommandRecord -CommandText $Text -Dialect $dialect)) {
        if ($null -ne (Get-TestExecutionLauncherMatch -Form $entry.Form)) { continue }
        $runner = Get-TestExecutionRunnerMatch -Form $entry.Form -CommandText $Text
        if ($runner) { return $runner }
    }
    return ''
}

function Get-TestExecutionScriptOperand {
    <#
    .SYNOPSIS
        Return the script file a normalized form runs (Language and Path), or $null.
    .DESCRIPTION
        sh, bash, zsh, dash, or ksh with a file operand (Shell); pwsh or powershell -File
        (PowerShell); python or python3 with a .py operand (Python); node with a .js, .cjs, or
        .mjs operand other than run-jest.cjs (JavaScript).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][pscustomobject] $Form)

    $words = [string[]]$Form.Words
    if ($Form.Lookup -or $Form.Unmodeled -or $words.Count -eq 0) { return $null }
    $leaf = ConvertTo-TestExecutionLeafWord -Word $words[0]
    if ($script:TestExecutionShellName -contains $leaf) {
        $operand = Get-TestExecutionShellFileOperand -Word $words
        return $(if ($operand -ge 0) { [pscustomobject]@{ Language = 'Shell'; Path = $words[$operand] } } else { $null })
    }
    if ($script:TestExecutionPowerShellName -contains $leaf) {
        $operand = Get-TestExecutionHostFileOperand -Word $words
        return $(if ($operand -ge 0) { [pscustomobject]@{ Language = 'PowerShell'; Path = $words[$operand] } } else { $null })
    }
    $candidate = @($words | Select-Object -Skip 1 | Where-Object { -not $_.StartsWith('-') } | Select-Object -First 1)
    if ($candidate.Count -eq 0 -or @($words | Select-Object -Skip 1 | Where-Object { @('-m', '-c', '-e', '--eval', '-p', '--print') -ccontains $_ }).Count -gt 0) { return $null }
    $path = [string]$candidate[0]
    if (@('python', 'python3') -contains $leaf -and $path.EndsWith('.py', [System.StringComparison]::OrdinalIgnoreCase)) { return [pscustomobject]@{ Language = 'Python'; Path = $path } }
    if ($leaf -eq 'node' -and $path -match '\.(js|cjs|mjs)$' -and (ConvertTo-TestExecutionLeafWord -Word $path) -ne 'run-jest.cjs') { return [pscustomobject]@{ Language = 'JavaScript'; Path = $path } }
    return $null
}

function Get-TestExecutionSeamOverrideMatch {
    <#
    .SYNOPSIS
        Report whether a text names a launcher seam variable (spec D33), ordinal
        case-insensitive.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return $false }
    return ($Text.IndexOf('TestSuiteLauncherSeams', [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
        $Text.IndexOf('PesterSuiteSeams', [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
}
