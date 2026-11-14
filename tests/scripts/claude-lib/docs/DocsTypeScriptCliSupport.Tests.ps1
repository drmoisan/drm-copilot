#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTypeScriptCliSupport.psm1.

.DESCRIPTION
    Covers the command and option record model (creation, first-declared option wins,
    positional word parsing, Commander flag parsing, the command-path declaration and its cycle
    guard) and the yargs chain recognition over in-memory token streams: scriptName, string and
    object command forms, builder objects and functions, option key rules, alias and demandOption,
    and the module-unresolved and dynamic diagnostics. No file is written and no process is
    started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptSyntax.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsScannerCommon.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptCliSupport.psm1') -Force -ErrorAction Stop

    function Get-TestState {
        param([string] $Text, [string[]] $Imported = @())
        $result = ConvertTo-DocsTypeScriptToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        [object[]] $tokens = $result['Tokens']
        [object[]] $loops = Get-DocsTypeScriptLoopRange -Tokens $tokens
        $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($name in $Imported) { [void]$names.Add($name) }
        @{ Tokens = $tokens; Path = 'cli.ts'; ModulePath = 'cli'; Set = (New-DocsScannerDiagnosticSet); Loop = $loops; Imported = $names; Tracked = @{}; Command = [System.Collections.Generic.List[object]]::new() }
    }

    function Invoke-TestYargsChain {
        param([hashtable] $State)
        $root = New-DocsCliCommand -State $State -Name 'cli' -Parent $null -Line 1 -EndLine 1 -NameSource 'module' -IsRoot
        $chain = Get-DocsTypeScriptMemberChain -Tokens $State['Tokens'] -StartIndex 0
        Invoke-DocsCliYargsChain -State $State -Chain $chain -Command $root -ReceiverIndex 0
        $root
    }

    function Get-TestOptionName {
        param([hashtable] $Command)
        @($Command['Option'] | ForEach-Object { $_['Name'] })
    }

    function Get-TestCode {
        param([hashtable] $State)
        @($State['Set'].Values | ForEach-Object { "$($_['Code']):$($_['Count'])@$($_['FirstLine'])" } | Sort-Object { $_ })
    }
}

AfterAll {
    Remove-Module -Name DocsTypeScriptCliSupport, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'command and option record model' {
    It 'creates commands, keeps the first option of a name, parses positional words and Commander flags' {
        # Arrange
        $state = Get-TestState -Text 'x'
        $root = New-DocsCliCommand -State $state -Name 'tool' -Parent $null -Line 1 -EndLine 2 -IsRoot

        # Act
        $child = New-DocsCliCommand -State $state -Name 'serve' -Parent $root -Line 3 -EndLine 4
        Add-DocsCliPositional -Command $child -Word @('<dir>', '[port]', '<files...>', '') -Line 3 -EndLine 4
        Add-DocsCliOption -Command $child -Name 'dir' -Line 9 -EndLine 9 -Positional $false
        Add-DocsCliFlagOption -Command $child -Flags '-p, --port <n>' -Line 5 -EndLine 5
        Add-DocsCliFlagOption -Command $child -Flags '--host <h>' -Line 6 -EndLine 6 -Required $true
        Add-DocsCliFlagOption -Command $child -Flags '-d' -Line 7 -EndLine 7
        Add-DocsCliFlagOption -Command $child -Flags '<nothing>' -Line 8 -EndLine 8

        # Assert
        $state['Command'].Count | Should -Be 2
        $root['IsRoot'] | Should -BeTrue
        $root['NameSource'] | Should -Be 'literal'
        $child['IsRoot'] | Should -BeFalse
        Get-TestOptionName -Command $child | Should -Be @('dir', 'port', 'files', '--port', '--host', '-d')
        $child['Option'][0]['Positional'] | Should -BeTrue
        $child['Option'][0]['Line'] | Should -Be 3
        $child['Option'][3]['Short'] | Should -Be '-p'
        $child['Option'][3]['Required'] | Should -BeFalse
        $child['Option'][4]['Required'] | Should -BeTrue
        $child['Option'][4]['Short'] | Should -BeNullOrEmpty
        $child['Option'][5]['Short'] | Should -Be '-d'
        Get-DocsCliDeclaration -Command $child | Should -Be 'tool serve'
        Get-DocsCliDeclaration -Command $root | Should -Be 'tool'
    }

    It 'returns null for a declaration whose parent chain is a cycle' {
        $state = Get-TestState -Text 'x'
        $a = New-DocsCliCommand -State $state -Name 'a' -Parent $null -Line 1 -EndLine 1
        $b = New-DocsCliCommand -State $state -Name 'b' -Parent $a -Line 1 -EndLine 1
        $a['Parent'] = $b
        Get-DocsCliDeclaration -Command $b | Should -BeNullOrEmpty
    }

    It 'spells yargs option names by key length' {
        Get-DocsCliYargsOptionName -Key 'port' | Should -Be '--port'
        Get-DocsCliYargsOptionName -Key 'p' | Should -Be '-p'
    }
}

Describe 'Invoke-DocsCliYargsChain' {
    It 'applies scriptName, root options with alias and demandOption, string commands with positionals and a builder function' {
        # Arrange
        $state = Get-TestState -Text "y.scriptName('tool').option('verbose', { alias: 'v', demandOption: true }).command('serve [port]', 'd', (b) => { b.option('host', { demand: true }).positional('port', {}); b.command('nested'); return b; }).command('`$0 <file>', 'default')"

        # Act
        $root = Invoke-TestYargsChain -State $state

        # Assert
        $root['Name'] | Should -Be 'tool'
        $root['NameSource'] | Should -Be 'literal'
        Get-TestOptionName -Command $root | Should -Be @('--verbose', 'file')
        $root['Option'][0]['Short'] | Should -Be '-v'
        $root['Option'][0]['Required'] | Should -BeTrue
        $commands = @($state['Command'] | ForEach-Object { Get-DocsCliDeclaration -Command $_ })
        $commands | Should -Be @('tool', 'tool serve', 'tool serve nested')
        $serve = $state['Command'][1]
        Get-TestOptionName -Command $serve | Should -Be @('port', '--host')
        $serve['Option'][0]['Positional'] | Should -BeTrue
        $serve['Option'][1]['Required'] | Should -BeTrue
        @(Get-TestCode -State $state).Count | Should -Be 0
    }

    It 'applies the object command form with an array name and an object builder, and the options key rules' {
        $state = Get-TestState -Text "y.command({ command: ['build <target>', 'b'], builder: { out: { alias: 'o' }, k: {} } }).options({ q: {}, long: { required: true } }).command({ command: 'plain' }).command({ describe: 'no name' })"
        $root = Invoke-TestYargsChain -State $state
        @($state['Command'] | ForEach-Object { Get-DocsCliDeclaration -Command $_ }) | Should -Be @('cli', 'cli build', 'cli plain')
        $build = $state['Command'][1]
        Get-TestOptionName -Command $build | Should -Be @('target', '--out', '-k')
        $build['Option'][1]['Short'] | Should -Be '-o'
        Get-TestOptionName -Command $root | Should -Be @('-q', '--long')
        $root['Option'][1]['Required'] | Should -BeTrue
        Get-TestCode -State $state | Should -Be @('CLI_DYNAMIC_REGISTRATION:1@1')
    }

    It 'reports module-loaded commands, commandDir, and dynamic names, keys, spreads, empty strings and loop bodies' {
        $state = Get-TestState -Text "y.command(require('./x')).command(imported).commandDir('c').command(notImported).command(`"`").command(...rest).option(dyn).options(notObject).options({ ['k']: {} }).command()" -Imported @('imported')
        $null = Invoke-TestYargsChain -State $state
        $state['Command'].Count | Should -Be 1
        Get-TestCode -State $state | Should -Be @('CLI_COMMAND_MODULE_UNRESOLVED:3@1', 'CLI_DYNAMIC_REGISTRATION:7@1')
        $loopState = Get-TestState -Text "for (const n of names) { y.command('inside'); }"
        $root = New-DocsCliCommand -State $loopState -Name 'cli' -Parent $null -Line 1 -EndLine 1 -IsRoot
        $receiver = -1
        for ($index = 0; $index -lt $loopState['Tokens'].Count; $index++) { if ([string] $loopState['Tokens'][$index]['Text'] -ceq 'y') { $receiver = $index } }
        $loopState['Tokens'][$receiver]['Text'] | Should -Be 'y'
        $chain = Get-DocsTypeScriptMemberChain -Tokens $loopState['Tokens'] -StartIndex $receiver
        Invoke-DocsCliYargsChain -State $loopState -Chain $chain -Command $root -ReceiverIndex $receiver
        $loopState['Command'].Count | Should -Be 1
        Get-TestCode -State $loopState | Should -Be @('CLI_DYNAMIC_REGISTRATION:1@1')
    }

    It 'ignores a builder that is not an object or a function with a parameter and scriptName on a non-root' {
        $state = Get-TestState -Text "y.command('a', 'd', builderRef).command('b', 'd', () => 1).command('c', 'd', function () { })"
        $null = Invoke-TestYargsChain -State $state
        @($state['Command'] | ForEach-Object { Get-DocsCliDeclaration -Command $_ }) | Should -Be @('cli', 'cli a', 'cli b', 'cli c')
        $child = $state['Command'][1]
        $chain = Get-DocsTypeScriptMemberChain -Tokens (Get-TestState -Text "z.scriptName('renamed')")['Tokens'] -StartIndex 0
        $childState = Get-TestState -Text "z.scriptName('renamed')"
        Invoke-DocsCliYargsChain -State $childState -Chain $chain -Command $child -ReceiverIndex 0
        $child['Name'] | Should -Be 'a'
    }
}
