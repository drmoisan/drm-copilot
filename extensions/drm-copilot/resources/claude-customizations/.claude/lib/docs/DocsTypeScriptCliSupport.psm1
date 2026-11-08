<#
.SYNOPSIS
    Support for the typescript-cli scanner: the in-memory command and option record model shared
    by the Commander and yargs recognizers, Commander flag-string parsing, the command-path
    declaration, and the yargs chain and builder recognition.

.DESCRIPTION
    A command record is a hashtable @{ Name; NameSource; Parent; Line; EndLine; IsRoot; Option }
    kept in the per-file state list State['Command']; an option record is
    @{ Name; Short; Required; Positional; Line; EndLine }. Invoke-DocsCliYargsChain applies the
    calls of a member chain whose receiver denotes a yargs command: .scriptName sets the root
    name, .command (string and object forms, with a builder object or function) declares a
    subcommand, .option, .options and .positional declare options; .commandDir, require(...)
    and imported command modules are CLI_COMMAND_MODULE_UNRESOLVED and non-literal names, loop
    bodies, spread arguments and computed keys are CLI_DYNAMIC_REGISTRATION. Every function is
    pure apart from the explicit State and Command records it is given.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from DocsAnalyzerTypeScriptCli.psm1 under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

function New-DocsCliCommand {
    <#
    .SYNOPSIS
        Creates one command record in State['Command'] and returns it.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory record factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Name,
        [AllowNull()] [hashtable] $Parent,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [string] $NameSource = 'literal',
        [switch] $IsRoot
    )

    $command = @{ Name = $Name; NameSource = $NameSource; Parent = $Parent; Line = $Line; EndLine = $EndLine; IsRoot = [bool] $IsRoot; Option = [System.Collections.Generic.List[object]]::new() }
    $State['Command'].Add($command)
    return $command
}

function Add-DocsCliOption {
    <#
    .SYNOPSIS
        Adds one option or positional record to a command; a name already present on the command is kept as first declared.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Name,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [AllowNull()] [string] $Short,
        [bool] $Required = $false,
        [bool] $Positional = $false
    )

    foreach ($existing in $Command['Option']) { if ([string] $existing['Name'] -ceq $Name) { return } }
    $Command['Option'].Add(@{ Name = $Name; Short = $Short; Required = $Required; Positional = $Positional; Line = $Line; EndLine = $EndLine })
}

function Add-DocsCliPositional {
    <#
    .SYNOPSIS
        Adds the '<arg>', '[opt]' and '<files...>' words of a command string as positional records.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Word,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine
    )

    foreach ($word in $Word) {
        $name = $word.Trim('<', '>', '[', ']').TrimEnd('.')
        if ($name.Length -eq 0) { continue }
        Add-DocsCliOption -Command $Command -Name $name -Line $Line -EndLine $EndLine -Positional $true
    }
}

function Add-DocsCliFlagOption {
    <#
    .SYNOPSIS
        Parses a Commander flags string ('-p, --port <n>') and adds the option named by its long flag (or its short flag alone).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Flags,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [bool] $Required = $false
    )

    $long = $null
    $short = $null
    foreach ($part in [regex]::Split($Flags, '[\s,|]+')) {
        if ($part.StartsWith('--')) { if ($null -eq $long) { $long = $part } }
        elseif ($part.StartsWith('-') -and $part.Length -gt 1) { if ($null -eq $short) { $short = $part } }
    }
    $name = if ($null -ne $long) { $long } else { $short }
    if ($null -eq $name) { return }
    Add-DocsCliOption -Command $Command -Name $name -Line $Line -EndLine $EndLine -Short $short -Required $Required
}

function Get-DocsCliDeclaration {
    <#
    .SYNOPSIS
        Returns the full command path of a command record ('tool serve'), or $null on a parent cycle.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [hashtable] $Command)

    $words = [System.Collections.Generic.List[string]]::new()
    $cursor = $Command
    for ($depth = 0; $null -ne $cursor; $depth++) {
        if ($depth -gt 64) { return $null }
        $words.Insert(0, [string] $cursor['Name'])
        $cursor = $cursor['Parent']
    }
    return ($words -join ' ')
}

function Get-DocsCliYargsOptionName {
    <#
    .SYNOPSIS
        Returns the yargs option spelling of a key: '--key' for a multi-character key, '-k' for one character.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Key)

    if ($Key.Length -eq 1) { return '-' + $Key }
    return '--' + $Key
}

function Add-DocsCliYargsOption {
    <#
    .SYNOPSIS
        Adds a yargs option; a single-character literal alias gives short and demandOption, demand or required true gives required.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Key,
        [AllowNull()] [System.Collections.IDictionary] $ConfigSpan,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine
    )

    $short = $null
    $required = $false
    if ($null -ne $ConfigSpan -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ([int] $ConfigSpan['Start']) -Kind 'punct' -Text @('{'))) {
        $members = Get-DocsTypeScriptObjectMember -Tokens $Tokens -OpenIndex ([int] $ConfigSpan['Start'])
        foreach ($member in $members) {
            if ($null -eq $member['Key'] -or [int] $member['ValueStart'] -lt 0) { continue }
            if ([string] $member['Key'] -ceq 'alias') {
                $alias = Get-DocsScannerLiteral -Tokens $Tokens -Span @{ Start = [int] $member['ValueStart']; End = [int] $member['ValueEnd'] }
                if ($null -ne $alias -and $alias.Length -eq 1) { $short = '-' + $alias }
            } elseif (@('demandOption', 'demand', 'required') -ccontains [string] $member['Key']) {
                if (Test-DocsTypeScriptToken -Tokens $Tokens -Index ([int] $member['ValueStart']) -Kind 'keyword' -Text @('true')) { $required = $true }
            }
        }
    }
    Add-DocsCliOption -Command $Command -Name (Get-DocsCliYargsOptionName -Key $Key) -Line $Line -EndLine $EndLine -Short $short -Required $required
}

function Add-DocsCliObjectOption {
    <#
    .SYNOPSIS
        Adds one yargs option per literal key of the object literal at OpenIndex; a computed key or spread is CLI_DYNAMIC_REGISTRATION.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [int] $OpenIndex,
        [Parameter(Mandatory = $true)] [int] $ReceiverLine
    )

    $tokens = $State['Tokens']
    $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex $OpenIndex
    foreach ($member in $members) {
        if ($null -eq $member['Key']) {
            Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'CLI_DYNAMIC_REGISTRATION' -Path $State['Path'] -Line ([int] $member['Line'])
            continue
        }
        $configSpan = if ([int] $member['ValueStart'] -ge 0) { @{ Start = [int] $member['ValueStart']; End = [int] $member['ValueEnd'] } } else { $null }
        Add-DocsCliYargsOption -Command $Command -Tokens $tokens -Key ([string] $member['Key']) -ConfigSpan $configSpan -Line $ReceiverLine -EndLine ([int] $tokens[[int] $member['ValueEnd']]['EndLine'])
    }
}

function Invoke-DocsCliYargsBuilder {
    <#
    .SYNOPSIS
        Applies a yargs builder argument (an object literal of options or a function whose parameter receives option calls) to a command.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span,
        [Parameter(Mandatory = $true)] [int] $ReceiverLine
    )

    $tokens = $State['Tokens']
    $start = [int] $Span['Start']
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'punct' -Text @('{')) {
        Add-DocsCliObjectOption -State $State -Command $Command -OpenIndex $start -ReceiverLine $ReceiverLine
        return
    }
    $function = Get-DocsTypeScriptFunctionParameter -Tokens $tokens -Span $Span
    if ($null -eq $function -or $null -eq $function['Parameter']) { return }
    $parameter = [string] $function['Parameter']
    $index = [int] $function['BodyStart']
    while ($index -le [int] $function['BodyEnd']) {
        if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'identifier' -Text @($parameter)) -and -not (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @('.', '?.'))) {
            $chain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex $index
            if ($null -ne $chain -and $chain['Call'].Count -gt 0) {
                Invoke-DocsCliYargsChain -State $State -Chain $chain -Command $Command -ReceiverIndex $index
                $index = [int] $chain['EndIndex'] + 1
                continue
            }
        }
        $index++
    }
}

function Get-DocsCliCommandWord {
    <#
    .SYNOPSIS
        Splits a command string into its words, or returns an empty array for a blank string (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    [string[]] $words = @([regex]::Split($Text.Trim(), '\s+') | Where-Object { $_.Length -gt 0 })
    return , $words
}

function Invoke-DocsCliYargsChain {
    <#
    .SYNOPSIS
        Applies the calls of a yargs member chain to the command the receiver denotes, recording diagnostics in State['Set'].
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Chain,
        [Parameter(Mandatory = $true)] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [int] $ReceiverIndex
    )

    $tokens = $State['Tokens']
    $path = [string] $State['Path']
    $set = $State['Set']
    $receiverLine = [int] $tokens[$ReceiverIndex]['Line']
    $inLoop = Test-DocsTypeScriptInRange -Range $State['Loop'] -Index $ReceiverIndex
    foreach ($call in $Chain['Call']) {
        $name = [string] $call['Name']
        $arguments = @($call['Argument'])
        $line = [int] $call['Line']
        if (@('command', 'option', 'options', 'positional', 'commandDir') -cnotcontains $name) {
            if ($name -ceq 'scriptName' -and $arguments.Count -ge 1 -and $Command['IsRoot']) {
                $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0]
                if ($null -ne $literal) { $Command['Name'] = $literal; $Command['NameSource'] = 'literal' }
            }
            continue
        }
        if ($name -ceq 'commandDir') { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_COMMAND_MODULE_UNRESOLVED' -Path $path -Line $line; continue }
        $isSpread = ($arguments.Count -gt 0) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $arguments[0]['Start']) -Kind 'punct' -Text @('...'))
        if ($inLoop -or $isSpread -or $arguments.Count -eq 0) { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path $path -Line $line; continue }
        $first = $arguments[0]
        $firstIndex = [int] $first['Start']
        $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $first
        if ($name -ceq 'options') {
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'punct' -Text @('{')) { Add-DocsCliObjectOption -State $State -Command $Command -OpenIndex $firstIndex -ReceiverLine $receiverLine }
            else { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path $path -Line $line }
            continue
        }
        if ($name -ceq 'option' -or $name -ceq 'positional') {
            if ($null -eq $literal) { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path $path -Line $line; continue }
            if ($name -ceq 'positional') { Add-DocsCliOption -Command $Command -Name $literal -Line $receiverLine -EndLine ([int] $call['EndLine']) -Positional $true }
            else { Add-DocsCliYargsOption -Command $Command -Tokens $tokens -Key $literal -ConfigSpan $(if ($arguments.Count -ge 2) { $arguments[1] } else { $null }) -Line $receiverLine -EndLine ([int] $call['EndLine']) }
            continue
        }
        # .command(...): string form, object form, module-loaded, or dynamic
        [string[]] $words = @()
        $builderSpan = $null
        if ($null -ne $literal) {
            $words = Get-DocsCliCommandWord -Text $literal
            if ($arguments.Count -ge 3) { $builderSpan = $arguments[2] }
        } elseif (Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'punct' -Text @('{')) {
            $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex $firstIndex
            foreach ($member in $members) {
                if ($null -eq $member['Key'] -or [int] $member['ValueStart'] -lt 0) { continue }
                $valueSpan = @{ Start = [int] $member['ValueStart']; End = [int] $member['ValueEnd'] }
                if ([string] $member['Key'] -ceq 'command') {
                    $value = Get-DocsScannerLiteral -Tokens $tokens -Span $valueSpan
                    if ($null -eq $value) { $array = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span $valueSpan; if ($null -ne $array -and $array.Count -gt 0) { $value = $array[0] } }
                    if ($null -ne $value) { $words = Get-DocsCliCommandWord -Text $value }
                } elseif ([string] $member['Key'] -ceq 'builder') { $builderSpan = $valueSpan }
            }
        } elseif ((Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'identifier' -Text @('require')) -or ((Test-DocsTypeScriptName -Tokens $tokens -Index $firstIndex) -and $firstIndex -eq [int] $first['End'] -and $State['Imported'].Contains([string] $tokens[$firstIndex]['Text']))) {
            Add-DocsScannerDiagnostic -Set $set -Code 'CLI_COMMAND_MODULE_UNRESOLVED' -Path $path -Line $line
            continue
        }
        if ($words.Count -eq 0) { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path $path -Line $line; continue }
        $target = if ($words[0] -ceq '$0') { $Command } else { New-DocsCliCommand -State $State -Name $words[0] -Parent $Command -Line $receiverLine -EndLine ([int] $call['EndLine']) }
        if ($words.Count -gt 1) { Add-DocsCliPositional -Command $target -Word $words[1..($words.Count - 1)] -Line $receiverLine -EndLine ([int] $call['EndLine']) }
        if ($null -ne $builderSpan) { Invoke-DocsCliYargsBuilder -State $State -Command $target -Span $builderSpan -ReceiverLine $receiverLine }
    }
}

Export-ModuleMember -Function `
    New-DocsCliCommand, `
    Add-DocsCliOption, `
    Add-DocsCliPositional, `
    Add-DocsCliFlagOption, `
    Get-DocsCliDeclaration, `
    Get-DocsCliYargsOptionName, `
    Add-DocsCliYargsOption, `
    Add-DocsCliObjectOption, `
    Invoke-DocsCliYargsBuilder, `
    Invoke-DocsCliYargsChain
