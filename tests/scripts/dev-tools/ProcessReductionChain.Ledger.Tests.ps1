#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Committed-ledger chain tests for scripts/dev-tools/ProcessReductionChain.psm1 (issue #1097).

.DESCRIPTION
    Reads docs/engineering/process-reductions/ and the paths its entries name read-only
    through Read-ProcessReductionChainInput, then reverts every entry newest-first in
    memory. The chain must hold with no exception: no test here filters the errors.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionLedger.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionChain.psm1') -Force

    $script:ChainInput = Read-ProcessReductionChainInput -RepositoryRoot $script:RepoRoot
    $script:ChainResult = Invoke-ProcessReductionChain -Entry $script:ChainInput.Entries -PatchText $script:ChainInput.PatchText -LiveText $script:ChainInput.LiveText
}

AfterAll {
    Remove-Module ProcessReductionChain -ErrorAction SilentlyContinue
    Remove-Module ProcessReductionLedger -ErrorAction SilentlyContinue
}

Describe 'Committed process-reduction ledger chain' {
    It 'PRC-LEDGER-CHAIN-HOLDS reverts every entry newest-first with no error' {
        $script:ChainResult.IsValid | Should -BeTrue -Because ($script:ChainResult.Errors -join '; ')
        @($script:ChainResult.Errors).Count | Should -Be 0 -Because ($script:ChainResult.Errors -join '; ')
    }

    It 'PRC-LEDGER-END-STATE-RECORDED reports no end-state error and ends with each created path absent' {
        # Arrange
        $created = @(
            foreach ($patchName in @($script:ChainInput.PatchText.Keys)) {
                Get-ProcessReductionPatchHunk -PatchText $script:ChainInput.PatchText[$patchName] | Where-Object { $_.Kind -ceq 'create' } | ForEach-Object { $_.Path }
            }
        )

        # Act
        $endStateErrors = @($script:ChainResult.Errors | Where-Object { $_ -like '*the end state*' })

        # Assert
        $endStateErrors.Count | Should -Be 0 -Because ($endStateErrors -join '; ')
        $created.Count | Should -BeGreaterThan 0 -Because 'the stored patches create at least one file'
        foreach ($path in $created) {
            $script:ChainResult.FinalText.ContainsKey($path) | Should -BeTrue -Because "$path is in the chain state"
            $script:ChainResult.FinalText[$path] | Should -BeNullOrEmpty -Because "$path is absent before the entry that created it"
        }
    }

    It 'PRC-README-REVERT-ORDER-STATED states the newest-first revert order in the README' {
        $readme = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'docs/engineering/process-reductions/README.md')

        $section = Get-ProcessReductionSection -Text $readme -Heading 'Revert Order'

        $section | Should -Not -BeNullOrEmpty -Because 'the README has a Revert Order section'
        $section | Should -BeLike '*newest-first*'
        $section | Should -BeLike '*ProcessReductionChain.Ledger.Tests.ps1*'
    }

    It 'PRC-LEDGER-NO-EXCEPTIONS holds for the brief and carries no skip or allowed-error list' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'ProcessReductionChain.Ledger.Tests.ps1'), [ref]$null, [ref]$null)

        # Act
        $briefErrors = @($script:ChainResult.Errors | Where-Object { $_ -like '*.claude/skills/execution-environment/SKILL.md*' })
        $parameterHits = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandParameterAst] -and $node.ParameterName -in @('Skip', 'Pending') }, $true))
        $filterVariables = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.UserPath -match 'allow|skip|ignore|exempt|except|known' }, $true))

        # Assert
        $briefErrors.Count | Should -Be 0 -Because ($briefErrors -join '; ')
        $parameterHits.Count | Should -Be 0 -Because 'no ledger test is skipped'
        $filterVariables.Count | Should -Be 0 -Because 'no ledger test filters errors through an allow or skip list'
    }
}
