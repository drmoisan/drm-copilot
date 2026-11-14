#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command-level tests for a malformed link target in the documentation page checker (issue #1173 B7).

.DESCRIPTION
    A page links a target whose resolved path is not a docs common relative path (it holds '|').
    Invoke-DocsCheckCommand and Invoke-DocsCommandCli run over the in-memory command context of
    Docs.TestSupport.psm1 whose TestFile member applies the same relative-path check as the
    production context, which throws DOCS_CONTEXT_PATH_INVALID for such a path. The command must
    report DOCS_PAGE_LINK_BROKEN with exit 1, never exit 3, and must not ask TestFile about the
    malformed path. DocsPageCheck.Tests.ps1 is not extended because of its size. No file is read
    except the committed example profile, and no file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageCheck.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instances that DocsPageCheck imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $profileText = Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRoot -ChildPath 'examples/docs/v1/docs-profile.example.json') -Raw
    $profileValue = (ConvertFrom-DocsJsonText -Text $profileText).Value
    $profileValue['audiences'] = @([ordered]@{ id = 'developers'; description = 'People who change the code.' })
    $profileValue['documentation_roots'] = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
    $script:ProfileText = ConvertTo-DocsJsonText -Value $profileValue -Indented

    function New-TestMalformedPage {
        # Returns the text of one valid explanation page whose body holds the given lines.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Body)
        $lines = @('---', 'owner: "team-docs"', 'last_reviewed: "2026-10-30"', 'audience: ["developers"]', 'diataxis_mode: "explanation"', 'surface_refs: []', '---') + $Body
        return ($lines -join "`n") + "`n"
    }

    function New-TestMalformedContext {
        # Returns the in-memory context whose TestFile throws DOCS_CONTEXT_PATH_INVALID for a non-relative path, as the production member does.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param()
        $files = @{
            $script:ProfilePath = $script:ProfileText
            'docs/README.md'    = New-TestMalformedPage -Body @('# Documentation', 'See [the table](a|b.md) and [the guide](guide.md).')
            'docs/guide.md'     = New-TestMalformedPage -Body @('# Guide', 'Back to [the index](README.md).')
        }
        $test = New-DocsTestContext -File $files
        $testCalls = [System.Collections.Generic.List[string]]::new()
        $testFile = $test.Context.TestFile
        $test.Context.TestFile = {
            param($RelativePath)
            $testCalls.Add([string] $RelativePath)
            if (-not (Test-DocsRelativePath -Path $RelativePath)) { throw "DOCS_CONTEXT_PATH_INVALID: '$RelativePath' is not a repository-relative path." }
            & $testFile $RelativePath
        }.GetNewClosure()
        $test['TestCalls'] = $testCalls
        return $test
    }
}

AfterAll {
    Remove-Module -Name DocsPageCheck, DocsPageOrphans, DocsPageDiataxis, DocsPageLinks, DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestMalformedPage, Function:\New-TestMalformedContext -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsCheckCommand with a malformed link target (issue #1173 B7)' {
    It 'exits 1 with DOCS_PAGE_LINK_BROKEN and never asks TestFile about the malformed path' {
        # Arrange
        $test = New-TestMalformedContext

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_LINK_BROKEN')
        $result.Findings[0].artifact_path | Should -BeExactly 'docs/README.md'
        $result.Findings[0].message | Should -BeLike "*'a|b.md'*"
        $test.TestCalls | Should -Not -Contain 'docs/a|b.md'
    }
}

Describe 'check through Invoke-DocsCommandCli with a malformed link target (issue #1173 B7)' {
    BeforeAll {
        . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')
    }

    It 'exits 1, not 3, and the envelope holds DOCS_PAGE_LINK_BROKEN and no DOCS_CLI_RUNTIME' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'check' -CommandArgument @() -Context (New-TestMalformedContext).Context -Json
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value

        # Assert
        $outcome.ExitCode | Should -Be 1
        [string[]] $codes = @($envelope['findings'] | ForEach-Object { [string] $_['code'] })
        $codes | Should -Contain 'DOCS_PAGE_LINK_BROKEN'
        $codes | Should -Not -Contain 'DOCS_CLI_RUNTIME'
    }
}
