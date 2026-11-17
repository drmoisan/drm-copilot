#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Stage-1 classification supplement rows for the Codex preimplementation gate (issues #1188 and #1195).

.DESCRIPTION
    Issue #1195 adds the wrapped-payload rows: ClassifyWrappedGateRows drive Test-ImplementationCommand
    of the Codex gate, and ClassifyWrappedFunctionRows drive Get-OrchestrationGateWrappedPatternIndex
    of the Codex sibling with the Codex gate's own stage-1 patterns, read through the PowerShell parser.

    Runs the shared tables of tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1
    against the Codex surface. The classification rows drive Test-ImplementationCommand of
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1; the function rows drive
    Get-OrchestrationGateSupplementalPatternIndex from
    .codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1, dot-sourced in their own
    Context BeforeAll; I2 asserts the fail-closed deny for a failed dot-source of the classify
    sibling, fed the mapped tool_input that the Codex gate's entry tail produces.

    The BeforeAll follows the Codex epic-state isolation pattern of
    enforce-orchestration-preimplementation-gate-operands.Tests.ps1. No row creates a file, reads a
    clock, starts git, or touches the network.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1')
}

Describe 'Codex gate stage-1 classification supplement (issue #1188)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        function ConvertTo-MappedToolInput {
            # Return the mapped tool_input JSON the gate's entry tail produces for a Bash command.
            param([string] $Command)
            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'classifies <Kind> row <Command> as <Expected>' -ForEach $script:ClassifyGateRows {
        # Act
        $result = Test-ImplementationCommand -Command $Command

        # Assert
        $result | Should -Be $Expected -Because "the $Kind row's classification is pinned by issue #1188"
    }

    Context 'Get-OrchestrationGateSupplementalPatternIndex alone (function rows)' {
        BeforeAll {
            . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1')
            if (-not (Get-Command Get-OrchestrationGateSupplementalPatternIndex -ErrorAction SilentlyContinue)) {
                throw 'Get-OrchestrationGateSupplementalPatternIndex is not defined by the Codex sibling.'
            }
        }

        It 'F <Name>' -ForEach $script:ClassifyFunctionRows {
            # Act
            $result = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $Command)

            # Assert
            ($result -join ',') | Should -BeExactly (@($Indexes) -join ',') -Because 'the supplement returns exactly the stage-1 indexes its two forms match'
        }
    }

    It 'classifies wrapped <Kind> row <Command> as <Expected>' -ForEach $script:ClassifyWrappedGateRows {
        # Act
        $result = Test-ImplementationCommand -Command $Command

        # Assert
        $result | Should -Be $Expected -Because "the wrapped $Kind row's classification is pinned by issue #1195"
    }

    Context 'Get-OrchestrationGateWrappedPatternIndex alone (wrapped function rows)' {
        BeforeAll {
            . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1')
            $gateAst = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'), [ref]$null, [ref]$null)
            $gateFunction = $gateAst.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Test-ImplementationCommand' }, $true)
            $patternAssignment = $gateFunction.Body.Find({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -ceq '$implementationCommandPatterns' }, $true)
            $script:WrappedGatePattern = [string[]]@($patternAssignment.Right.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true) | ForEach-Object { $_.Value })
            if ($script:WrappedGatePattern.Count -ne 5) { throw "Expected five stage-1 patterns in Test-ImplementationCommand; read $($script:WrappedGatePattern.Count)." }
        }

        It 'W <Name>' -ForEach $script:ClassifyWrappedFunctionRows {
            # Act
            $result = @(Get-OrchestrationGateWrappedPatternIndex -CommandText $Command -Pattern $script:WrappedGatePattern)

            # Assert
            ($result -join ',') | Should -BeExactly (@($Indexes) -join ',') -Because 'the wrapped-payload function returns exactly the stage-1 indexes its literal payloads match'
        }
    }

    It 'I2 denies naming enforce-orchestration-preimplementation-gate-classify.ps1 when its dot-source failed' {
        # Arrange
        Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-classify.ps1'
        try {
            # Act
            $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command 'npm run lint')
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        # Assert
        $gateResult.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $gateResult.hookSpecificOutput.permissionDecisionReason | Should -Match 'enforce-orchestration-preimplementation-gate-classify\.ps1'
    }
}
