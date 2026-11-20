#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command-operand resolution rows for the Claude preimplementation gate (issue #1188).

.DESCRIPTION
    The G rows drive Get-OrchestrationGateCommandTargetOperand from
    .claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1 alone; their Context
    dot-sources that file in its own BeforeAll, so a missing file fails only the G rows. The gate
    rows drive Invoke-OrchestrationPreimplementationGateDecision with a Bash payload and assert the
    decision, the reason code, and the exact checkpoint-read and worktree-listing call counts.
    Both tables live in enforce-orchestration-preimplementation-gate-operands.Cases.ps1, which the
    Codex suite shares.

    The outermost BeforeAll follows the epic-state isolation pattern of
    enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1: the gate is dot-sourced
    first, then the baseline mocks are registered. The worktree listing and every checkpoint body
    are in-memory mocks registered per row. No row creates a file, reads a clock, starts git, or
    touches the network.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-operands.Cases.ps1')
}

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

    $script:ItemRoot = '/synthetic-worktrees/w-item'
    $script:OtherRoot = '/synthetic-worktrees/w-other'
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:ItemRoot)`nbranch refs/heads/feature/item`n`nworktree $($script:OtherRoot)`nbranch refs/heads/feature/other`n"
    $script:ItemCheckpoint = Get-WorktreeRunCheckpointPath -Kind 'item' -WorktreeRoot $script:ItemRoot
    $script:SessionCheckpoint = Get-WorktreeRunCheckpointPath -Kind 'item' -WorktreeRoot $script:Session
    $script:Bodies = @{
        Ready   = '{"issue-num":"1188","feature-folder":".dev/active/sample-1188","route_id":"large","lifecycle_ready":true}'
        Unready = '{"issue-num":"1188","feature-folder":".dev/active/sample-1188","route_id":"large","lifecycle_ready":false}'
        Absent  = ''
    }

    function ConvertTo-ToolPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Register the three-root listing (or a failing or empty one), the per-path checkpoint
    # bodies, and the ascent seam, so no row reads a host directory or checkpoint.
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
        Mock Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution { $session }.GetNewClosure()
        Mock Get-CheckpointContent { '' }
        Mock Get-CheckpointContent { $itemText }.GetNewClosure() -ParameterFilter { $Path -eq $script:ItemCheckpoint }
        Mock Get-CheckpointContent { $sessionText }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }
    }
}

Describe 'Claude gate command-operand resolution (issue #1188)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Get-OrchestrationGateCommandTargetOperand alone (G rows)' {
        BeforeAll {
            . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1").Path
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
            $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Command $Command)

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
                $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Command 'pytest tests/x.py')
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
