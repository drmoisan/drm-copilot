#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Text and JSON parity of the inventory diagnostics count through Invoke-DocsCommandCli (issue #1173 B10).

.DESCRIPTION
    One in-memory command context holds a profile, valid Python sources and one input that is not
    valid UTF-8, at a path outside the B8 default exclusions. The inventory command runs with and
    without -Json; the diagnostics=<n> count of the text report equals the count of
    result.snapshot.diagnostics in the envelope, and the envelope holds the DOCS_INPUT_NOT_UTF8
    entry. This proves the refuted B10 verdict: both outputs are built from one command result.
    No file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:BadPath = 'src/legacy/latin1.py'
    $script:BadBytes = [byte[]]@(0x6E, 0x61, 0x6D, 0x65, 0x20, 0x3D, 0x20, 0x27, 0xE9, 0x27, 0x0A)

    function New-TestParityContext {
        # Returns an in-memory context whose ReadBytes returns non-UTF-8 bytes for the bad path.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param()
        $starter = New-DocsStarterProfile -RepositoryId 'repo'
        $files = @{
            (Get-DocsDefaultProfilePath) = (ConvertTo-DocsJsonText -Value $starter -Indented)
            'src/app.py'                 = "def main():`n    pass`n"
            'src/pkg/mod.py'             = "value = 1`n"
            $script:BadPath              = 'placeholder'
        }
        $test = New-DocsTestContext -File $files
        $inner = $test.Context.ReadBytes
        $badPath = $script:BadPath
        $badBytes = $script:BadBytes
        $test.Context.ReadBytes = {
            param($RelativePath)
            if ([string] $RelativePath -ceq $badPath) { return , [byte[]] $badBytes.Clone() }
            return , (& $inner $RelativePath)
        }.GetNewClosure()
        return $test.Context
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestParityContext -ErrorAction SilentlyContinue
}

Describe 'inventory text and JSON diagnostics parity (issue #1173 B10)' {
    It 'reports the same diagnostics count in the text report and the envelope, including DOCS_INPUT_NOT_UTF8' {
        # Act
        $json = Invoke-DocsCommandCli -Command 'inventory' -CommandArgument @() -Context (New-TestParityContext) -Json
        $text = Invoke-DocsCommandCli -Command 'inventory' -CommandArgument @() -Context (New-TestParityContext)
        $envelope = (ConvertFrom-DocsJsonText -Text $json.Stdout).Value
        $diagnostics = @($envelope['result']['snapshot']['diagnostics'])
        $match = [regex]::Match($text.Stdout, 'diagnostics=(?<count>\d+)')

        # Assert
        $json.ExitCode | Should -Be $text.ExitCode
        $match.Success | Should -BeTrue -Because 'the text report carries the diagnostics count'
        [int] $match.Groups['count'].Value | Should -Be $diagnostics.Count
        @($diagnostics | Where-Object { $_['code'] -ceq 'DOCS_INPUT_NOT_UTF8' -and $_['path'] -ceq $script:BadPath }).Count | Should -Be 1
        $diagnostics.Count | Should -BeGreaterOrEqual 1
    }
}
