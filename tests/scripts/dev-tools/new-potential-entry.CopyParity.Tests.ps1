#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Byte identity of the repository and bundled copies of new-potential-entry.ps1 (issue #1035, D-P3).

.DESCRIPTION
    The repository copy under scripts/dev-tools and the bundled template copy under
    extensions/drm-copilot/resources/templates carry one text; the workspace rule inside the
    script distinguishes the two locations at run time. The suite reads both files and writes none.
#>

Describe 'new-potential-entry.ps1 copy parity (issue #1035)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:RepositoryCopy = Join-Path $script:RepoRoot 'scripts/dev-tools/new-potential-entry.ps1'
        $script:BundledCopy = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/templates/new-potential-entry.ps1'
    }

    It 'has equal SHA-256 hashes for the repository and bundled copies' {
        # Act
        $repositoryHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:RepositoryCopy).Hash
        $bundledHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:BundledCopy).Hash

        # Assert
        $bundledHash | Should -Be $repositoryHash -Because 'the two copies of new-potential-entry.ps1 are byte-identical'
    }

    It 'declares the -DevelopmentDocsRoot parameter with the two known roots and the docs/features default' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:RepositoryCopy, [ref]$null, [ref]$null)
        $parameter = @($ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -ceq 'DevelopmentDocsRoot' })

        # Act
        $validateSet = @($parameter[0].Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateSet' })

        # Assert
        $parameter.Count | Should -Be 1
        $parameter[0].DefaultValue.Value | Should -BeExactly 'docs/features'
        @($validateSet[0].PositionalArguments | ForEach-Object { $_.Value }) | Should -Be @('docs/features', '.dev')
    }
}
