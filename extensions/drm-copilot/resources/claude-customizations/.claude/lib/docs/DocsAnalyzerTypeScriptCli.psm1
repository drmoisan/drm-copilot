<#
.SYNOPSIS
    typescript-cli scanner: Commander and yargs command and option registrations in TypeScript
    sources, emitted as cli-command and cli-option elements.

.DESCRIPTION
    Invoke-DocsAnalyzerTypeScriptCli selects *.ts, *.mts and *.cts inputs (declaration files
    excluded), tokenizes each with ConvertTo-DocsTypeScriptToken and follows member-call chains
    on tracked receivers: Commander's program import, new Command(...) and variables assigned
    from either; yargs(...) and the yargs import (applied by DocsTypeScriptCliSupport.psm1).
    Commander .command registers a subcommand (the two-argument form returns the parent),
    .option, .requiredOption, .addOption(new Option(...)) and .argument declare options and
    positionals, .addCommand parents a tracked command. The root name is a literal from
    new Command('x'), .name('x') or .scriptName('x') (name_source literal), else the module
    path of the file (name_source module). Elements are built only through
    New-DocsSurfaceElement -AnalysisMethod scanner -SourceText; the digest is never computed
    here. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of this scanner's precision limit
    (CLI_DYNAMIC_REGISTRATION, CLI_UNBOUND_REGISTRATION, CLI_COMMAND_MODULE_UNRESOLVED).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptCliSupport.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsCliAnalyzerId = 'typescript-cli'

function Invoke-DocsCliCommanderChain {
    <#
    .SYNOPSIS
        Applies the calls of a Commander chain and returns the command the chain evaluates to (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Chain,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Command,
        [Parameter(Mandatory = $true)] [int] $ReceiverIndex
    )

    $tokens = $State['Tokens']
    $path = [string] $State['Path']
    $set = $State['Set']
    $receiverLine = [int] $tokens[$ReceiverIndex]['Line']
    $inLoop = Test-DocsTypeScriptInRange -Range $State['Loop'] -Index $ReceiverIndex
    $current = $Command
    foreach ($call in $Chain['Call']) {
        $name = [string] $call['Name']
        $arguments = @($call['Argument'])
        $line = [int] $call['Line']
        if (@('command', 'addCommand', 'option', 'requiredOption', 'addOption', 'argument', 'name') -cnotcontains $name) { continue }
        if ($name -ceq 'name') {
            if ($null -ne $current -and $current['IsRoot'] -and $arguments.Count -ge 1) {
                $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0]
                if ($null -ne $literal) { $current['Name'] = $literal; $current['NameSource'] = 'literal' }
            }
            continue
        }
        if ($name -ceq 'addCommand') {
            $child = $null
            if ($arguments.Count -ge 1) {
                $firstIndex = [int] $arguments[0]['Start']
                if ((Test-DocsTypeScriptName -Tokens $tokens -Index $firstIndex) -and $firstIndex -eq [int] $arguments[0]['End'] -and $State['Tracked'].ContainsKey([string] $tokens[$firstIndex]['Text'])) { $child = $State['Tracked'][[string] $tokens[$firstIndex]['Text']] }
                elseif (Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'keyword' -Text @('new')) {
                    $inner = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex $firstIndex
                    if ($null -ne $inner) { $child = Invoke-DocsCliCommanderChain -State $State -Chain $inner -Command (New-DocsCliRootFromNew -State $State -StartIndex $firstIndex) -ReceiverIndex $firstIndex }
                }
            }
            if ($null -eq $child -or $null -eq $current -or $child['Framework'] -cne 'commander') { Add-DocsScannerDiagnostic -Set $set -Code 'CLI_UNBOUND_REGISTRATION' -Path $path -Line $line; continue }
            $child['Parent'] = $current
            $child['IsRoot'] = $false
            continue
        }
        $isSpread = ($arguments.Count -gt 0) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $arguments[0]['Start']) -Kind 'punct' -Text @('...'))
        $literal = $null
        if ($arguments.Count -ge 1 -and -not $isSpread) {
            if ($name -ceq 'addOption') {
                $firstIndex = [int] $arguments[0]['Start']
                if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'keyword' -Text @('new')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($firstIndex + 2) -Kind 'punct' -Text @('('))) {
                    [object[]] $optionArguments = Get-DocsScannerCallArgument -Tokens $tokens -OpenIndex ($firstIndex + 2)
                    if ($optionArguments.Count -ge 1) { $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $optionArguments[0] }
                }
            } else { $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0] }
        }
        [string[]] $words = @()
        if ($null -ne $literal) { $words = @([regex]::Split($literal.Trim(), '\s+') | Where-Object { $_.Length -gt 0 }) }
        if ($inLoop -or $words.Count -eq 0 -or $null -eq $current) {
            Add-DocsScannerDiagnostic -Set $set -Code 'CLI_DYNAMIC_REGISTRATION' -Path $path -Line $line
            if ($name -ceq 'command') { $current = $null }
            continue
        }
        $endLine = [int] $call['EndLine']
        switch ($name) {
            'command' {
                $child = New-DocsCliCommand -State $State -Name $words[0] -Parent $current -Line $receiverLine -EndLine $endLine
                $child['Framework'] = 'commander'
                if ($words.Count -gt 1) { Add-DocsCliPositional -Command $child -Word $words[1..($words.Count - 1)] -Line $receiverLine -EndLine $endLine }
                $returnsParent = ($arguments.Count -ge 2) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $arguments[1]['Start']) -Kind 'string')
                if (-not $returnsParent) { $current = $child }
            }
            'option' { Add-DocsCliFlagOption -Command $current -Flags $literal -Line $receiverLine -EndLine $endLine }
            'addOption' { Add-DocsCliFlagOption -Command $current -Flags $literal -Line $receiverLine -EndLine $endLine }
            'requiredOption' { Add-DocsCliFlagOption -Command $current -Flags $literal -Line $receiverLine -EndLine $endLine -Required $true }
            'argument' { Add-DocsCliPositional -Command $current -Word $words -Line $receiverLine -EndLine $endLine }
        }
    }
    return $current
}

function New-DocsCliRootFromNew {
    <#
    .SYNOPSIS
        Creates the root command of a 'new Command(...)' expression at StartIndex (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory record factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $StartIndex
    )

    $tokens = $State['Tokens']
    $name = $State['ModulePath']
    $source = 'module'
    $endLine = [int] $tokens[$StartIndex + 1]['EndLine']
    if (Test-DocsTypeScriptToken -Tokens $tokens -Index ($StartIndex + 2) -Kind 'punct' -Text @('(')) {
        $close = Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex ($StartIndex + 2)
        [object[]] $arguments = Get-DocsScannerCallArgument -Tokens $tokens -OpenIndex ($StartIndex + 2)
        if ($close -ge 0) { $endLine = [int] $tokens[$close]['Line'] }
        if ($arguments.Count -ge 1) { $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0]; if ($null -ne $literal) { $name = $literal; $source = 'literal' } }
    }
    $root = New-DocsCliCommand -State $State -Name $name -Parent $null -Line ([int] $tokens[$StartIndex]['Line']) -EndLine $endLine -NameSource $source -IsRoot
    $root['Framework'] = 'commander'
    return $root
}

function Get-DocsCliAssignedName {
    <#
    .SYNOPSIS
        Returns the variable name when the tokens before Index are 'const|let|var name =', else $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    if ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($Index - 1) -Kind 'punct' -Text @('=')) -and (Test-DocsTypeScriptName -Tokens $Tokens -Index ($Index - 2)) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($Index - 3) -Kind 'keyword' -Text @('const', 'let', 'var'))) { return [string] $Tokens[$Index - 2]['Text'] }
    return $null
}

function Get-DocsCliFileCommand {
    <#
    .SYNOPSIS
        Scans one tokenized file and returns its command records (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $ModulePath,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    [object[]] $loopRange = Get-DocsTypeScriptLoopRange -Tokens $Tokens
    $importedName = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $state = @{ Tokens = $Tokens; Path = $Path; ModulePath = $ModulePath; Set = $Set; Loop = $loopRange; Imported = $importedName; Tracked = [hashtable]::new([System.StringComparer]::Ordinal); Command = [System.Collections.Generic.List[object]]::new() }
    $pendingRoot = [hashtable]::new([System.StringComparer]::Ordinal)
    $commanderName = $null
    $hasCommander = $false
    $hasYargs = $false
    $bindings = Get-DocsTypeScriptImport -Tokens $Tokens
    foreach ($binding in $bindings) {
        [void]$importedName.Add([string] $binding['Local'])
        $module = [string] $binding['Module']
        if ($module -ceq 'commander' -or $module.EndsWith('/extra-typings')) {
            $hasCommander = $true
            if ([string] $binding['Imported'] -ceq 'program') { $pendingRoot[[string] $binding['Local']] = 'commander' }
            if ([string] $binding['Imported'] -ceq 'Command') { $commanderName = [string] $binding['Local'] }
        } elseif ($module -ceq 'yargs' -or $module -ceq 'yargs/yargs') {
            $hasYargs = $true
            $pendingRoot[[string] $binding['Local']] = 'yargs'
        }
    }
    if (-not $hasCommander -and -not $hasYargs) { return , [object[]]@() }
    $index = 0
    while ($index -lt $Tokens.Count) {
        $isMember = Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index - 1) -Kind 'punct' -Text @('.', '?.')
        $isNewCommand = $hasCommander -and $null -ne $commanderName -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index $index -Kind 'keyword' -Text @('new')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'identifier' -Text @($commanderName))
        if (-not $isNewCommand -and ($isMember -or -not (Test-DocsTypeScriptName -Tokens $Tokens -Index $index))) { $index++; continue }
        $text = [string] $Tokens[$index]['Text']
        $chain = Get-DocsTypeScriptMemberChain -Tokens $Tokens -StartIndex $index
        if ($null -eq $chain) { $index++; continue }
        $isBareName = ($chain['Call'].Count -eq 0 -and [int] $chain['ReceiverEnd'] -eq $index)
        $command = $null
        if ($isNewCommand) { $command = New-DocsCliRootFromNew -State $state -StartIndex $index }
        elseif ($isBareName -and -not (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('.'))) { $index++; continue }
        elseif ($state['Tracked'].ContainsKey($text)) { $command = $state['Tracked'][$text] }
        elseif ($pendingRoot.ContainsKey($text)) {
            $endLine = [int] $Tokens[[int] $chain['ReceiverEnd']]['EndLine']
            $command = New-DocsCliCommand -State $state -Name $ModulePath -Parent $null -Line ([int] $Tokens[$index]['Line']) -EndLine $endLine -NameSource 'module' -IsRoot
            $command['Framework'] = $pendingRoot[$text]
            $state['Tracked'][$text] = $command
            $pendingRoot.Remove($text)
        } elseif ((Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 1) -Kind 'punct' -Text @('.')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 2) -Kind 'identifier' -Text @('command', 'addCommand')) -and (Test-DocsTypeScriptToken -Tokens $Tokens -Index ($index + 3) -Kind 'punct' -Text @('('))) {
            Add-DocsScannerDiagnostic -Set $Set -Code 'CLI_UNBOUND_REGISTRATION' -Path $Path -Line ([int] $Tokens[$index + 2]['Line'])
            $index = [int] $chain['EndIndex'] + 1
            continue
        } else { $index++; continue }
        $result = $command
        if ($command['Framework'] -ceq 'yargs') { Invoke-DocsCliYargsChain -State $state -Chain $chain -Command $command -ReceiverIndex $index }
        else { $result = Invoke-DocsCliCommanderChain -State $state -Chain $chain -Command $command -ReceiverIndex $index }
        $assigned = Get-DocsCliAssignedName -Tokens $Tokens -Index $index
        if ($null -ne $assigned -and $null -ne $result) { $state['Tracked'][$assigned] = $result }
        $index = [int] $chain['EndIndex'] + 1
    }
    return , [object[]] $state['Command'].ToArray()
}

function Invoke-DocsAnalyzerTypeScriptCli {
    <#
    .SYNOPSIS
        Scans the captured TypeScript inputs for Commander and yargs registrations and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection.source_roots (optional) shortens the module path used as the root name when no
        literal name exists. Every element is built by New-DocsSurfaceElement with
        -AnalysisMethod scanner and the captured text; diagnostics are aggregated per
        (code, path) and emitted through ConvertTo-DocsScannerDiagnostic under typescript-cli.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $sourceRoots = $null
    if ($Selection -is [System.Collections.IDictionary] -and $Selection.Contains('source_roots')) { $sourceRoots = $Selection['source_roots'] }
    elseif ($null -ne $Selection -and $Selection -isnot [System.Collections.IDictionary] -and $null -ne $Selection.PSObject.Properties['source_roots']) { $sourceRoots = $Selection.PSObject.Properties['source_roots'].Value }
    $set = New-DocsScannerDiagnosticSet
    $elements = [System.Collections.Generic.List[object]]::new()
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.ts', '.mts', '.cts') -ExcludeSuffix @('.d.ts', '.d.mts', '.d.cts')
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        $text = $captured['text']
        if ($null -eq $text) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $lexed = ConvertTo-DocsTypeScriptToken -Text $text
        if ($lexed['Diagnostics'].Count -gt 0) {
            foreach ($diagnostic in $lexed['Diagnostics']) { Add-DocsScannerDiagnostic -Set $set -Code ([string] $diagnostic['Code']) -Path $path -Line ([int] $diagnostic['Line']) -Blocking $true }
            continue
        }
        $modulePath = Get-DocsScannerModulePath -Path $path -SourceRoot ([string[]] @($sourceRoots | ForEach-Object { [string] $_ }))
        $commands = Get-DocsCliFileCommand -Tokens $lexed['Tokens'] -Path $path -ModulePath $modulePath -Set $set
        foreach ($command in $commands) {
            $declaration = Get-DocsCliDeclaration -Command $command
            if ($null -eq $declaration) { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $command['Line']); continue }
            $property = [ordered]@{}
            if ($command['IsRoot']) { $property['name_source'] = [string] $command['NameSource'] }
            try {
                $parentId = $null
                if ($null -ne $command['Parent']) { $parentId = Get-DocsElementId -Kind 'cli-command' -Path $path -Declaration (Get-DocsCliDeclaration -Command $command['Parent']) }
                $element = New-DocsSurfaceElement -Kind 'cli-command' -Path $path -Declaration $declaration -Name ([string] $command['Name']) -AnalyzerId $script:DocsCliAnalyzerId -AnalysisMethod 'scanner' -SourceText $text -LineRange @([int] $command['Line'], [int] $command['EndLine']) -ParentId $parentId -Property $property
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $command['Line']); continue }
            $elements.Add($element)
            foreach ($option in $command['Option']) {
                $optionProperty = [ordered]@{}
                if (-not [string]::IsNullOrEmpty([string] $option['Short'])) { $optionProperty['short'] = [string] $option['Short'] }
                if ($option['Required']) { $optionProperty['required'] = $true }
                if ($option['Positional']) { $optionProperty['positional'] = $true }
                try {
                    $elements.Add((New-DocsSurfaceElement -Kind 'cli-option' -Path $path -Declaration ($declaration + ' ' + [string] $option['Name']) -Name ([string] $option['Name']) -AnalyzerId $script:DocsCliAnalyzerId -AnalysisMethod 'scanner' -SourceText $text -LineRange @([int] $option['Line'], [int] $option['EndLine']) -ParentId ([string] $element['element_id']) -Property $optionProperty))
                } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $option['Line']) }
            }
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsCliAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerTypeScriptCli
