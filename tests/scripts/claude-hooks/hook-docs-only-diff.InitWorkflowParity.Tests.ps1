#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pins the docs-only workflow constant to the docs-init workflow destination (issue #1169).

.DESCRIPTION
    A hook cannot import the docs library, so .claude/hooks/hook-docs-only-diff.ps1 restates the
    workflow path that docs-init writes as $script:DocsOnlyInitWorkflowPath. This suite reads the
    destination of the workflow row of Get-DocsInitTemplate (DocsProfileCommands.psm1) and
    asserts the two values are ordinally equal, following the hook-cleanup-context.Parity.Tests.ps1
    precedent. Only committed files located from $PSScriptRoot are read; no row writes a file or
    starts a process. The dot-sourced hook functions and the imported modules are removed in
    AfterAll.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:HookPath = Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1'
    . $script:HookPath
    Import-Module -Name (Join-Path $script:RepoRoot '.claude/lib/docs/DocsProfileCommands.psm1') -Force -ErrorAction Stop
}

AfterAll {
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookPath, [ref]$tokens, [ref]$parseErrors)
    foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
        Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
    }
    Remove-Module -Name DocsProfileCommands, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'docs-init workflow path parity (issue #1169)' {
    It 'holds the workflow destination of Get-DocsInitTemplate in $script:DocsOnlyInitWorkflowPath' {
        # Arrange: the template returns its rows as one array, so it is assigned before filtering.
        $template = Get-DocsInitTemplate
        $rows = @($template | Where-Object { [string] $_.Destination -clike '.github/workflows/*' })

        # Act
        $destination = [string] $rows[0].Destination

        # Assert
        $rows.Count | Should -Be 1 -Because 'docs-init writes exactly one workflow file'
        $script:DocsOnlyInitWorkflowPath | Should -BeExactly $destination -Because 'the hook constant must name the file docs-init writes'
    }

    It 'admits the docs-init workflow destination in Get-DocsOnlyPathViolation' {
        # Arrange
        $template = Get-DocsInitTemplate
        $destination = [string] @($template | Where-Object { [string] $_.Destination -clike '.github/workflows/*' })[0].Destination

        # Act
        $result = Get-DocsOnlyPathViolation -Path @('docs/a.md', $destination)

        # Assert
        $result | Should -BeNullOrEmpty -Because 'the workflow docs-init writes is the admitted non-docs path'
    }
}
