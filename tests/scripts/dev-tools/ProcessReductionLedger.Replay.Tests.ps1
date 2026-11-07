#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Replays the hook blocks of the policy-read removal entry (issue #1097).

.DESCRIPTION
    Finds the ledger entry by the stem `*-policy-read-removal.md`, so no entry number is
    hard-coded, applies its blocks for `.claude/hooks/validate-planner-output.ps1` to the
    live hook text in memory, and runs the reverted and the live plan-structure check on
    in-memory plans. Each run parses its hook text, extracts the two functions it needs,
    and defines them only inside a child script block, so reverted and live definitions
    never meet and nothing remains defined afterwards. Tracked files are read; nothing is
    written.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionLedger.psm1') -Force

    $script:HookRelativePath = '.claude/hooks/validate-planner-output.ps1'
    $script:PolicyReadError = 'Phase 0 must include a policy-read task.'
    $script:MissingPhaseZeroError = 'Plan must include Phase 0 with at least one baseline task.'

    $ledgerPath = Join-Path $script:RepoRoot 'docs/engineering/process-reductions'
    $script:EntryFile = @(Get-ChildItem -LiteralPath $ledgerPath -File -Filter '*-policy-read-removal.md')
    $script:HookBlock = @()
    if ($script:EntryFile.Count -eq 1) {
        $entryText = [System.IO.File]::ReadAllText($script:EntryFile[0].FullName)
        $script:HookBlock = @(Get-ProcessReductionRevertBlock -Text $entryText | Where-Object { $_.Path -ceq $script:HookRelativePath })
    }
    $script:LiveHookText = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $script:HookRelativePath))

    <#
    .SYNOPSIS
        Returns the live hook text with every hook block of the entry reverted.
    #>
    function Get-PrrRevertedHookText {
        [CmdletBinding()]
        [OutputType([string])]
        param()

        $text = $script:LiveHookText
        foreach ($block in $script:HookBlock) {
            $text = Invoke-ProcessReductionRevert -Text $text -Block $block
        }
        return $text
    }

    <#
    .SYNOPSIS
        Runs the plan-structure check of a hook text on plan lines, in a child scope.
    .PARAMETER HookText
        The full text of a version of the planner hook.
    .PARAMETER PlanLine
        The plan lines to validate.
    .OUTPUTS
        [string[]] The errors the check reports.
    #>
    function Invoke-PrrPlanStructureReport {
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            [Parameter(Mandatory = $true)][string] $HookText,
            [Parameter(Mandatory = $true)][string[]] $PlanLine
        )

        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($HookText, [ref]$tokens, [ref]$parseErrors)
        if ($parseErrors.Count -gt 0) {
            throw "The hook text does not parse: $($parseErrors[0].Message)"
        }
        $wanted = @('Get-PlanStructureValidationReport', 'Test-TaskContainsExplicitPath')
        $definitions = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -in $wanted
                }, $true))
        if ($definitions.Count -ne $wanted.Count) {
            throw "Expected $($wanted.Count) function definitions in the hook text but found $($definitions.Count)."
        }

        # The definitions live only in the child scope of this script block invocation.
        $body = (@($definitions | ForEach-Object { $_.Extent.Text }) -join "`n") + "`nGet-PlanStructureValidationReport -Lines `$args[0]"
        return [string[]]@(& ([scriptblock]::Create($body)) $PlanLine)
    }

    $script:BaselineOnlyPlan = @(
        "### Phase 0 `u{2014} Baseline",
        '- [ ] [P0-T1] Capture baseline for docs/features/active/foo/issue.md',
        "### Phase 1 `u{2014} QA",
        '- [ ] [P1-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
    )
    $script:NoPhaseZeroPlan = @(
        "### Phase 1 `u{2014} Implement",
        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1',
        "### Phase 2 `u{2014} QA",
        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
    )
}

Describe 'Process-reduction ledger replay of the policy-read removal' {
    It 'PRR-ENTRY-FOUND finds one entry with at least one hook block' {
        # Arrange and Act happen in BeforeAll, which reads the ledger folder once.

        # Assert
        $script:EntryFile.Count | Should -Be 1 -Because 'exactly one entry carries the policy-read-removal stem'
        $script:HookBlock.Count | Should -BeGreaterThan 0 -Because 'the entry must hold the hook blocks a revert applies'
    }

    It 'PRR-REVERTED-RETURNS-POLICY-READ-ERROR reports the policy-read error from the reverted hook' {
        # Arrange
        $reverted = Get-PrrRevertedHookText
        $functionCount = @(Get-ChildItem -Path Function:).Count

        # Act
        $errors = Invoke-PrrPlanStructureReport -HookText $reverted -PlanLine $script:BaselineOnlyPlan

        # Assert
        $errors | Should -Contain $script:PolicyReadError -Because 'the reverted hook restores the policy-read check'
        @(Get-ChildItem -Path Function:).Count | Should -Be $functionCount -Because 'the replay must leave no function defined'
    }

    It 'PRR-LIVE-RETURNS-NO-POLICY-READ-ERROR reports no policy-read error from the live hook' {
        # Arrange
        $functionCount = @(Get-ChildItem -Path Function:).Count

        # Act
        $errors = Invoke-PrrPlanStructureReport -HookText $script:LiveHookText -PlanLine $script:BaselineOnlyPlan

        # Assert
        $errors | Should -Not -Contain $script:PolicyReadError -Because 'the live hook no longer requires the policy-read task'
        @(Get-ChildItem -Path Function:).Count | Should -Be $functionCount -Because 'the replay must leave no function defined'
    }

    It 'PRR-BASELINE-ERROR-SURVIVES-REVERT reports the missing Phase 0 baseline from both hooks' {
        # Arrange
        $reverted = Get-PrrRevertedHookText

        # Act
        $revertedErrors = Invoke-PrrPlanStructureReport -HookText $reverted -PlanLine $script:NoPhaseZeroPlan
        $liveErrors = Invoke-PrrPlanStructureReport -HookText $script:LiveHookText -PlanLine $script:NoPhaseZeroPlan

        # Assert
        $revertedErrors | Should -Contain $script:MissingPhaseZeroError -Because 'the revert does not touch the baseline check'
        $liveErrors | Should -Contain $script:MissingPhaseZeroError -Because 'the removal does not touch the baseline check'
    }
}
