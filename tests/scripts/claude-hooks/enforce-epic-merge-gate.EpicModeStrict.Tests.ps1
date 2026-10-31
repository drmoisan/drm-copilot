#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Strict epic_mode rows for the merge gate's child-feature branch (issue #1001).

.DESCRIPTION
    Only the JSON boolean true counts as epic mode in Test-ChildCheckpointAllowsEpicMerge. A string
    such as "false" or "true", or a number such as 1, is not epic mode, so branch 1 declines and the
    decision falls through to the later branches. The unit rows parse each checkpoint in memory with
    ConvertFrom-EpicMergeGateJson; the decision rows drive Invoke-EpicMergeGateDecision with mocked
    checkpoint-content and resolution seams. No row starts a process, runs git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate strict epic_mode (issue #1001)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-1001'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-1001'
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item SessionRoot (issue #1001)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1001)' } }
        Mock Get-EpicMergeGateLivePrHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }

        function Invoke-StrictDecision {
            <#
            .SYNOPSIS
                Run the gate decision for one command with session id session-1001.
            #>
            param([Parameter(Mandatory)][string] $Command)

            $envelope = @{ session_id = 'session-1001'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Test-ChildCheckpointAllowsEpicMerge value matrix' {
        It 'returns <Expected> when epic_mode is <Label>' -ForEach @(
            @{ Label = 'JSON true'; Fragment = '"epic_mode":true,'; Expected = $true }
            @{ Label = 'JSON false'; Fragment = '"epic_mode":false,'; Expected = $false }
            @{ Label = 'JSON null'; Fragment = '"epic_mode":null,'; Expected = $false }
            @{ Label = 'absent'; Fragment = ''; Expected = $false }
            @{ Label = 'string false'; Fragment = '"epic_mode":"false",'; Expected = $false }
            @{ Label = 'string true'; Fragment = '"epic_mode":"true",'; Expected = $false }
            @{ Label = 'integer 1'; Fragment = '"epic_mode":1,'; Expected = $false }
            @{ Label = 'integer 0'; Fragment = '"epic_mode":0,'; Expected = $false }
        ) {
            # Arrange
            $checkpoint = ConvertFrom-EpicMergeGateJson -Raw ('{' + $Fragment + '"step9_status":"passed"}')

            # Act
            $result = Test-ChildCheckpointAllowsEpicMerge -Checkpoint $checkpoint

            # Assert
            $result | Should -BeOfType ([bool])
            $result | Should -Be $Expected -Because "epic_mode is $Label"
        }
    }

    Context 'Invoke-EpicMergeGateDecision branch 1 with a child checkpoint bound to PR 42' {
        It 'returns <Expected> for gh pr merge 42 --merge when epic_mode is <Label>' -ForEach @(
            @{ Label = 'JSON true'; Value = 'true'; Expected = 'allow' }
            @{ Label = 'string false'; Value = '"false"'; Expected = 'deny' }
            @{ Label = 'string true'; Value = '"true"'; Expected = 'deny' }
        ) {
            # Arrange
            $checkpointText = '{"epic_mode":' + $Value + ',"step9_status":"passed","pr_gate":{"pr_number":42}}'
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $checkpointText }.GetNewClosure())

            # Act
            $decision = Invoke-StrictDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected -Because "reason: $reason"
            if ($Expected -eq 'deny') { $reason | Should -Match 'EPIC_MERGE_GATE_BLOCKED' }
        }

        It 'denies an otherwise green standalone checkpoint whose epic_mode is the string false without a live-head lookup' {
            # Arrange: every green-CI condition holds except the epic marker, which is a string.
            Mock Get-ChildOrchestratorCheckpointContent { '{"epic_mode":"false","step9_status":"passed","ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"},"pr_gate":{"pr_number":42}}' }

            # Act
            $decision = Invoke-StrictDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "reason: $reason"
            $reason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly -Scope It
        }
    }
}
