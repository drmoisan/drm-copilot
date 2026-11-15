#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command-operand resolution rows for the Codex preimplementation gate (issue #1188).

.DESCRIPTION
    Runs the shared tables of tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1
    against the Codex surface. The G rows drive Get-OrchestrationGateCommandTargetOperand from
    .codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1, dot-sourced in their
    own Context BeforeAll. The gate rows feed the mapped tool_input that the Codex gate's entry
    tail produces to Invoke-OrchestrationPreimplementationGateDecision and assert the decision,
    the reason code, and the exact checkpoint-read and worktree-listing call counts.

    The BeforeAll follows the Codex epic-state isolation pattern of
    enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1. Checkpoint paths are
    composed as <root>/artifacts/orchestration/orchestrator-state.json. No row creates a file,
    reads a clock, starts git, or touches the network.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1')
}

Describe 'Codex gate command-operand resolution (issue #1188)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:ItemRoot = '/synthetic-worktrees/w-item'
        $script:OtherRoot = '/synthetic-worktrees/w-other'
        $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
        $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:ItemRoot)`nbranch refs/heads/feature/item`n`nworktree $($script:OtherRoot)`nbranch refs/heads/feature/other`n"
        $script:ItemCheckpoint = "$($script:ItemRoot)/artifacts/orchestration/orchestrator-state.json"
        $script:SessionCheckpoint = "$($script:Session)/artifacts/orchestration/orchestrator-state.json"
        $script:Bodies = @{
            Ready   = '{"issue-num":"1188","feature-folder":"docs/features/active/sample-1188","route_id":"large","lifecycle_ready":true}'
            Unready = '{"issue-num":"1188","feature-folder":"docs/features/active/sample-1188","route_id":"large","lifecycle_ready":false}'
            Absent  = ''
        }

        function ConvertTo-MappedToolInput {
            # Return the mapped tool_input JSON the gate's entry tail produces for a Bash command.
            param([string] $Command)
            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }

        # Register the three-root listing (or a failing or empty one), a default empty checkpoint
        # body plus per-path bodies, and the epic-scope ascent seam, so no row reads a host checkpoint.
        function Set-OperandFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([string] $ItemKind, [string] $SessionKind, [string] $Mode)
            $listing = $script:Listing
            $session = $script:Session
            $itemText = [string]$script:Bodies[$ItemKind]
            $sessionText = [string]$script:Bodies[$SessionKind]
            switch ($Mode) {
                'Throws' { Mock Get-OrchestrationGateWorktreeList { throw 'simulated listing failure (issue #1188)' } }
                'Empty' { Mock Get-OrchestrationGateWorktreeList { '' } }
                default { Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure() }
            }
            Mock Find-WorktreeResolutionRoot { $session }.GetNewClosure()
            Mock Get-CheckpointContent { '' }
            Mock Get-CheckpointContent { $itemText }.GetNewClosure() -ParameterFilter { $Path -eq $script:ItemCheckpoint }
            Mock Get-CheckpointContent { $sessionText }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'Get-OrchestrationGateCommandTargetOperand alone (G rows)' {
        BeforeAll {
            . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1')
            if (-not (Get-Command Get-OrchestrationGateCommandTargetOperand -ErrorAction SilentlyContinue)) {
                throw 'Get-OrchestrationGateCommandTargetOperand is not defined by the Codex sibling.'
            }
        }

        It 'G <Name>' -ForEach $script:OperandGRows {
            # Act
            $result = Get-OrchestrationGateCommandTargetOperand -Command $Command

            # Assert
            (@($result.Paths) -join '|') | Should -BeExactly (@($Paths) -join '|') -Because 'Paths holds the distinct selectors and absolute operands in first-seen order'
            $result.Unresolved | Should -Be $Unresolved
            if ($Unresolved) {
                $result.Detail | Should -Match 'unresolvable operand'
            } else {
                $result.Detail | Should -BeExactly ''
            }
        }
    }

    Context 'gate decisions for the single-feature command leg' {
        AfterEach {
            $script:OrchestrationGateWorktreeListFailed = $false
        }

        It '<Id> <Label>' -ForEach $script:OperandGateRows {
            # Arrange
            Set-OperandFixture -ItemKind $ItemBody -SessionKind $SessionBody -Mode $ListingMode

            # Act
            $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command $Command)

            # Assert
            $reason = [string]$gateResult.hookSpecificOutput.permissionDecisionReason
            $gateResult.hookSpecificOutput.permissionDecision | Should -Be $Decision
            if ($ReasonCode) { $reason | Should -Match $ReasonCode }
            if ($DetailPattern) { $reason | Should -Match $DetailPattern }
            Should -Invoke Get-CheckpointContent -Times $ItemReads -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
            Should -Invoke Get-CheckpointContent -Times $SessionReads -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
            Should -Invoke Get-CheckpointContent -Times ($ItemReads + $SessionReads) -Exactly
            if ($ListingCalls -ge 0) { Should -Invoke Get-OrchestrationGateWorktreeList -Times $ListingCalls -Exactly }
        }

        It 'I1 denies naming enforce-orchestration-preimplementation-gate-operands.ps1 when its dot-source failed' {
            # Arrange
            Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-operands.ps1'
            try {
                # Act
                $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command 'pytest tests/x.py')
            }
            finally {
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            }

            # Assert
            $gateResult.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $gateResult.hookSpecificOutput.permissionDecisionReason | Should -Match 'enforce-orchestration-preimplementation-gate-operands\.ps1'
        }
    }
}
