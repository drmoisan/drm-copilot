#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    The ReadStdin context member and the update-ledger -Operations option of Invoke-DocsCommand.ps1 (issue #1173 B2.3).

.DESCRIPTION
    Checks that New-DocsCommandContext carries a ReadStdin member placed after InvokeProcess and
    before ResolveRevision (it is not invoked, because the production member reads the console),
    that the in-memory New-DocsTestContext -Stdin member returns its text, that the update-ledger
    row of Get-DocsCommandTable carries Operations as a value option, and that the -Help usage
    text lists -Operations on the update-ledger line. No file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'ReadStdin context member (issue #1173)' {
    It 'places ReadStdin in the real context after InvokeProcess and before ResolveRevision' {
        # Act
        $context = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath
        $names = @($context.PSObject.Properties | ForEach-Object { $_.Name })

        # Assert
        $context.ReadStdin | Should -BeOfType [scriptblock]
        [array]::IndexOf($names, 'ReadStdin') | Should -Be ([array]::IndexOf($names, 'InvokeProcess') + 1)
        [array]::IndexOf($names, 'ResolveRevision') | Should -Be ([array]::IndexOf($names, 'ReadStdin') + 1)
        $names[-3..-1] | Should -Be @('ReadRevisionText', 'TestAncestor', 'ListChangedPath')
    }

    It 'returns the in-memory standard input of New-DocsTestContext -Stdin, and an empty string without it' {
        # Act
        $withText = & (New-DocsTestContext -Stdin '{"operations":[]}').Context.ReadStdin
        $without = & (New-DocsTestContext).Context.ReadStdin

        # Assert
        $withText | Should -BeExactly '{"operations":[]}'
        $without | Should -BeExactly ''
    }
}

Describe 'update-ledger -Operations option (issue #1173)' {
    It 'carries Operations as a value option of the update-ledger row' {
        # Act
        $row = @((Get-DocsCommandTable) | Where-Object { $_.Name -ceq 'update-ledger' })[0]

        # Assert
        $row.Option['Operations'] | Should -BeExactly 'value'
        (Test-DocsCommandTable -Table (Get-DocsCommandTable)).Count | Should -Be 0
    }

    It 'lists -Operations on the update-ledger line of the -Help usage text' {
        # Act
        $outcome = Invoke-DocsCommandCli -Help -Context (New-DocsTestContext).Context
        $line = @($outcome.Stdout -split "`n" | Where-Object { $_.StartsWith('  update-ledger ', [System.StringComparison]::Ordinal) })

        # Assert
        $line.Count | Should -Be 1
        $line[0].Contains('[-Operations <value>]', [System.StringComparison]::Ordinal) | Should -BeTrue
    }
}
