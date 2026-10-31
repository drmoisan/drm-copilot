#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Strict epic_mode rows for Test-EpicBaseBranchOverride (issue #1001).

.DESCRIPTION
    The --base <epic_context.integration_branch> requirement applies only when the per-feature
    checkpoint records epic_mode as the JSON boolean true. A string such as "false" or "true", or a
    number such as 1, is not epic mode, so a gh pr create without --base is not denied. Checkpoint
    text comes from a mock of the Get-PrAuthorCheckpointContent read seam, and the checkpoint path
    names a file that does not exist. No row creates a file, runs a process, or reads a checkpoint
    from disk.
#>

Describe 'enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride strict epic_mode (issue #1001)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        $script:MissingCheckpointPath = Join-Path $PSScriptRoot 'no-such-checkpoint-1001.json'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
        }
    }

    Context 'gh pr create without --base against an epic_context.integration_branch of epic/x' {
        It 'returns <Outcome> when epic_mode is <Label>' -ForEach @(
            @{ Label = 'JSON true'; Fragment = '"epic_mode":true,'; Outcome = 'EPIC_BASE_BRANCH_MISMATCH' }
            @{ Label = 'JSON false'; Fragment = '"epic_mode":false,'; Outcome = 'null' }
            @{ Label = 'JSON null'; Fragment = '"epic_mode":null,'; Outcome = 'null' }
            @{ Label = 'absent'; Fragment = ''; Outcome = 'null' }
            @{ Label = 'string false'; Fragment = '"epic_mode":"false",'; Outcome = 'null' }
            @{ Label = 'string true'; Fragment = '"epic_mode":"true",'; Outcome = 'null' }
            @{ Label = 'integer 1'; Fragment = '"epic_mode":1,'; Outcome = 'null' }
            @{ Label = 'integer 0'; Fragment = '"epic_mode":0,'; Outcome = 'null' }
        ) {
            # Arrange
            $checkpointText = '{' + $Fragment + '"epic_context":{"integration_branch":"epic/x"}}'
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith ({ $checkpointText }.GetNewClosure())

            # Act
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title x' -CheckpointPath $script:MissingCheckpointPath

            # Assert
            Should -Invoke Get-PrAuthorCheckpointContent -Times 1 -Exactly -Scope It
            if ($Outcome -eq 'null') {
                $result | Should -BeNullOrEmpty -Because "epic_mode is $Label"
            } else {
                $result | Should -Match $Outcome -Because "epic_mode is $Label"
            }
        }
    }
}
