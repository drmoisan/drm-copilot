#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Early-start rows for the Codex epic wave-barrier gate (issue #1097).

.DESCRIPTION
    Runs every row of tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1 through
    Invoke-CodexEpicWaveDecision for a local epic child (issue 902), and compares each deny with
    today's literal reason. Further rows pin the launcher-bound path for a valid record and for
    an unmerged other dependency, and that a lifecycle-prefixed dependency fails closed, because
    Find-CodexWaveFeature keys by basename or issue number. The launch-authority check is mocked;
    no row writes a file, reads a clock, or starts a process.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1')
    $script:EarlyStartRow = @(Get-EpicWaveEarlyStartCase)
}

Describe 'Codex enforce-epic-wave-barrier early start (issue #1097)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-epic-wave-barrier.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }

        $script:Write = '{"tool_name":"Write","tool_input":{"file_path":"a.txt"}}'
        $script:LocalChild = '{"epic_mode":true,"issue-num":"902"}'
        $script:LocalDenyReason = "EPIC_WAVE_BARRIER_BLOCKED: '902' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."
        $script:LaunchDenyReason = "EPIC_WAVE_BARRIER_BLOCKED: '2026-11-08-dependent-902' cannot mutate until every depends_on edge is merged or worktree_removed in the receipt-bound epic checkpoint."
        $script:LaunchReceipt = '{"issue_num":902,"feature_folder":"2026-11-08-dependent-902"}'
        $script:LaunchEnvironment = [pscustomobject]@{ launch_id = 'l-1097'; execution_context = 'epic_execution_child' }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    It 'EWC-<Name> decides <Expected>' -ForEach $script:EarlyStartRow {
        # Act
        $decision = Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw $script:LocalChild -EpicCheckpointRaw $Json

        # Assert: a null decision allows; a deny carries today's literal reason.
        if ($Expected -ceq 'allow') {
            $decision | Should -BeNullOrEmpty
        }
        else {
            $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:LocalDenyReason
        }
    }

    It 'EWC-LAUNCH-BOUND-VALID-ALLOWED' {
        # Arrange
        Mock Test-CodexEpicChildRoutingLaunchAuthority { $true }
        $epicText = ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open'

        # Act
        $decision = Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $epicText -LauncherReceiptRaw $script:LaunchReceipt -LauncherEnvironment $script:LaunchEnvironment -RepositoryRoot '/synthetic-root/repo'

        # Assert
        $decision | Should -BeNullOrEmpty
    }

    It 'EWC-LAUNCH-BOUND-OTHER-DEPENDENCY-DENIED' {
        # Arrange: the record exempts 901, but the other dependency 903 is not merged.
        Mock Test-CodexEpicChildRoutingLaunchAuthority { $true }
        $epicText = ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open' -Other 'pr_open' -Dependent @{ depends_on = @(901, 903) }

        # Act
        $decision = Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $epicText -LauncherReceiptRaw $script:LaunchReceipt -LauncherEnvironment $script:LaunchEnvironment -RepositoryRoot '/synthetic-root/repo'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:LaunchDenyReason
    }

    It 'EWC-PREFIXED-REFERENCE-FAILS-CLOSED' {
        # Arrange: a lifecycle-prefixed dependency finds no record through Find-CodexWaveFeature.
        $record = Get-EpicWaveEarlyStartRecord -Override @{ dependency = 'docs/features/active/2026-11-08-upstream-901' }
        $epicText = ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open' -Dependent @{ early_start = $record }

        # Act
        $decision = Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw $script:LocalChild -EpicCheckpointRaw $epicText

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:LocalDenyReason
    }
}
