#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #786).

.DESCRIPTION
    Runs the gate through the & route with a non-merge Bash payload on stdin (restored in
    finally), so the tail after the dependency checks, including the final exit statement,
    executes in-process. No test creates, renames, moves, or deletes a file.
#>

Describe 'enforce-epic-merge-gate entry point (issue #786)' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-epic-merge-gate.ps1'))
        . $script:Hook
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    It 'exits 0 without a deny for a command that is not a merge' {
        # Arrange: a Bash payload outside the gate's trigger scope.
        $payload = '{"session_id":"c-786","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status"}}'
        $priorIn = [System.Console]::In
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new($payload))
            $global:LASTEXITCODE = 0
            # Act
            $stdout = @(& $script:Hook)
            $exitCode = $LASTEXITCODE
        }
        finally {
            [System.Console]::SetIn($priorIn)
        }
        # Assert
        $exitCode | Should -Be 0
        (($stdout | ForEach-Object { [string]$_ }) -join "`n") | Should -Not -Match '"permissionDecision":"deny"'
    }
}
