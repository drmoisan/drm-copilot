#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Import order of the development-docs root module in Codex hooks and scripts (issue #1035, D-P16).

.DESCRIPTION
    A Codex hook or script runs either in a destination repository, where the module is published at
    .codex/lib/development-docs/, or in this repository, where only the self-hosted
    .claude/lib/development-docs/ copy exists. Every .ps1 file under .codex/hooks and .codex/scripts
    that names DevelopmentDocsRoot.psm1 must therefore import it through exactly one if statement whose
    condition is a Test-Path of the ../lib/development-docs/ path, whose then-branch imports that path,
    and whose else-branch imports the .claude/lib/development-docs/ path. The files are read through
    their PowerShell AST; no test writes a file. Paths are joined with Join-Path from forward-slash
    relative paths because the suite also runs on the Linux hook-suite job.
#>

BeforeDiscovery {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:ImporterRows = @(foreach ($folder in @('.codex/hooks', '.codex/scripts')) {
            foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $repoRoot $folder) -Filter '*.ps1' -File | Sort-Object Name)) {
                if ((Get-Content -LiteralPath $file.FullName -Raw).Contains('DevelopmentDocsRoot.psm1')) {
                    @{ File = "$folder/$($file.Name)" }
                }
            }
        })
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:PublishedPath = '../lib/development-docs/DevelopmentDocsRoot.psm1'
    $script:SelfHostedPath = '.claude/lib/development-docs/DevelopmentDocsRoot.psm1'

    function Get-DevelopmentDocsImportIfStatement {
        # Returns every if statement whose condition names the development-docs module file.
        param([Parameter(Mandatory)] [string] $ScriptText)
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$null, [ref]$null)
        return @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.IfStatementAst] -and
                    $node.Clauses[0].Item1.Extent.Text.Contains('DevelopmentDocsRoot.psm1')
                }, $true))
    }

    function Test-ImportCommandNamesPath {
        # Returns $true when the statement block holds an Import-Module command naming the path.
        param([AllowNull()] $Block, [Parameter(Mandatory)] [string] $Path)
        if ($null -eq $Block) { return $false }
        $imports = @($Block.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Import-Module'
                }, $true))
        return @($imports | Where-Object { $_.Extent.Text.Contains("'$Path'") }).Count -gt 0
    }

    function Test-DevelopmentDocsImportOrder {
        # The published .codex/lib copy is probed and imported first; the self-hosted copy is the else-branch.
        param([Parameter(Mandatory)] $IfStatement)
        if ($IfStatement.Clauses.Count -ne 1 -or $null -eq $IfStatement.ElseClause) { return $false }
        $condition = $IfStatement.Clauses[0].Item1
        $probes = @($condition.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Test-Path'
                }, $true))
        $probesPublished = @($probes | Where-Object { $_.Extent.Text.Contains("'$script:PublishedPath'") }).Count -eq 1
        $thenImportsPublished = Test-ImportCommandNamesPath -Block $IfStatement.Clauses[0].Item2 -Path $script:PublishedPath
        $thenImportsSelfHosted = Test-ImportCommandNamesPath -Block $IfStatement.Clauses[0].Item2 -Path $script:SelfHostedPath
        $elseImportsSelfHosted = Test-ImportCommandNamesPath -Block $IfStatement.ElseClause -Path $script:SelfHostedPath
        return $probesPublished -and $thenImportsPublished -and -not $thenImportsSelfHosted -and $elseImportsSelfHosted
    }
}

Describe 'Codex development-docs module import order (issue #1035)' {
    It 'IMPORT-ORDER: <File> probes the published .codex/lib copy before the self-hosted .claude/lib copy' -ForEach $script:ImporterRows {
        # Arrange
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $File) -Raw

        # Act
        $statements = @(Get-DevelopmentDocsImportIfStatement -ScriptText $text)

        # Assert
        $statements.Count | Should -Be 1 -Because "$File imports the module through one if statement"
        Test-DevelopmentDocsImportOrder -IfStatement $statements[0] | Should -BeTrue -Because "$File keeps the published-first order"
    }

    It 'IMPORT-ORDER-DISCOVERY: finds the Codex importers' {
        # Arrange / Act: repeat the discovery scan in the run phase.
        $files = @(foreach ($folder in @('.codex/hooks', '.codex/scripts')) {
                foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot $folder) -Filter '*.ps1' -File | Sort-Object Name)) {
                    if ((Get-Content -LiteralPath $file.FullName -Raw).Contains('DevelopmentDocsRoot.psm1')) { "$folder/$($file.Name)" }
                }
            })

        # Assert: the discovered set is non-empty, holds the known importers, and each has one import statement.
        $files.Count | Should -BeGreaterThan 0
        $files | Should -Contain '.codex/hooks/enforce-completion-consistency.ps1'
        $files | Should -Contain '.codex/scripts/epic-child-launch-contract.ps1'
        foreach ($relative in $files) {
            $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $relative) -Raw
            @(Get-DevelopmentDocsImportIfStatement -ScriptText $text).Count | Should -Be 1 -Because $relative
        }
    }

    It 'IMPORT-ORDER-NEGATIVE: rejects a reversed sample' {
        # Arrange: the self-hosted copy is probed and imported first.
        $reversed = @'
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -PathType Leaf) {
    Import-Module (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) '.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
}
else {
    Import-Module (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
}
'@

        # Act
        $statements = @(Get-DevelopmentDocsImportIfStatement -ScriptText $reversed)

        # Assert
        $statements.Count | Should -Be 1
        Test-DevelopmentDocsImportOrder -IfStatement $statements[0] | Should -BeFalse
    }

    It 'IMPORT-ORDER-NEGATIVE: rejects a sample without the self-hosted else-branch' {
        $published = @'
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -PathType Leaf) {
    Import-Module (Join-Path $PSScriptRoot '../lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
}
'@
        $statements = @(Get-DevelopmentDocsImportIfStatement -ScriptText $published)
        Test-DevelopmentDocsImportOrder -IfStatement $statements[0] | Should -BeFalse
    }
}
