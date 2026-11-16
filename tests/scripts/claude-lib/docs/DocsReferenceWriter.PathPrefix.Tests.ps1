#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command tests of generate-reference -PathPrefix (issue #1173 B5).

.DESCRIPTION
    Every test runs Invoke-DocsCommandCli -Command generate-reference -Write (Invoke-DocsCommand.ps1
    is dot-sourced) against an in-memory command context from DocsReference.TestSupport.psm1 with
    three API elements under src/a, src/b and lib. Covered: one prefix, two prefixes, no prefix
    (every element), and a non-relative prefix (exit 2 with DOCS_CLI_ARGUMENTS and no context
    call). Selection is an ordinal prefix match on the element path.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibRoot -ChildPath 'Invoke-DocsCommand.ps1')

    $script:SchemaText = Get-DocsReferenceSchemaTextMap
    $script:Element = [object[]]@(
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'SymbolInA' -Path 'src/a/x.py')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'SymbolInB' -Path 'src/b/y.py')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'SymbolInLib' -Path 'lib/z.py')
    )
    $script:Api = 'docs/reference/api-reference.md'

    function Invoke-TestPrefixGenerate {
        # Runs generate-reference -Write with the given extra arguments; returns @{ Outcome; Memory }.
        param([string[]] $Argument = @())
        $map = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:Element -SchemaTextMap $script:SchemaText
        $memory = New-DocsReferenceMemoryContext -File $map
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument (@($Argument) + @('-Write')) -Context $memory.Context -Json
        return @{ Outcome = $outcome; Memory = $memory }
    }

    function Get-TestWrittenSymbol {
        # Returns the fixture declarations present in the written API page, in fixture order.
        param([hashtable] $Memory)
        $page = [string] $Memory.Files[$script:Api]
        return [string[]] @('SymbolInA', 'SymbolInB', 'SymbolInLib' | Where-Object { $page.Contains($_) })
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\Invoke-TestPrefixGenerate, Function:\Get-TestWrittenSymbol -ErrorAction SilentlyContinue
}

Describe 'generate-reference -PathPrefix' {
    It 'selects only the elements whose path starts with one prefix' {
        # Act
        $run = Invoke-TestPrefixGenerate -Argument @('-PathPrefix', 'src/a')

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Get-TestWrittenSymbol -Memory $run.Memory | Should -Be @('SymbolInA')
    }

    It 'selects the elements of either of two prefixes' {
        # Act
        $run = Invoke-TestPrefixGenerate -Argument @('-PathPrefix', 'src/b', '-PathPrefix', 'lib')

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Get-TestWrittenSymbol -Memory $run.Memory | Should -Be @('SymbolInB', 'SymbolInLib')
    }

    It 'selects every element when no prefix is given' {
        # Act
        $run = Invoke-TestPrefixGenerate

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        Get-TestWrittenSymbol -Memory $run.Memory | Should -Be @('SymbolInA', 'SymbolInB', 'SymbolInLib')
    }

    It 'exits 2 with DOCS_CLI_ARGUMENTS and no context call for the non-relative prefix <Prefix>' -ForEach @(
        @{ Prefix = '/src' }
        @{ Prefix = '../src' }
    ) {
        # Act
        $run = Invoke-TestPrefixGenerate -Argument @('-PathPrefix', 'src/a', '-PathPrefix', $Prefix)
        $envelope = (ConvertFrom-DocsJsonText -Text $run.Outcome.Stdout).Value

        # Assert
        $run.Outcome.ExitCode | Should -Be 2
        @($envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_ARGUMENTS')
        $envelope['findings'][0]['message'] | Should -BeLike "*PathPrefix '$Prefix'*"
        $run.Memory.CallLog.Count | Should -Be 0
    }
}
