#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Fail-closed proof for the named import-failure handler exemption of the Codex
    preimplementation-gate modes sibling (issue #786).

.DESCRIPTION
    The control rows prove the epic and parallel payloads allow while feature-folder-resolution.ps1
    loads. The decision rows re-dot-source the Codex gate inside the It with Mock Join-Path throwing
    for feature-folder-resolution.ps1 and assert that the gate denies naming the readiness failure.
    Construction assertions carry -Because 'E-CONSTRUCTION'. Checkpoint content is a literal, so no
    case reads orchestration state, and no test creates, renames, moves, or deletes a file.

    Coverage attribution note (issue #936). The two H2 codex deny rows execute line 41 of
    .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, the catch body of
    the feature-folder-resolution.ps1 import guard. Their line-unique assertion checks that
    OrchestrationFeatureFolderResolutionImportFailure equals 'feature-folder-resolution.ps1';
    only line 41 assigns that value. A full-run CI coverage report can still show line 41
    with ci="0". The likely cause is Pester 5.x breakpoint mode: each line breakpoint binds
    to the first compiled instance of a script, and a later recompilation of the unchanged
    file leaves later executions of the line unattributed. A coverage run scoped to
    tests/scripts/codex-hooks attributes the line; the #936 evidence records both results.
#>

Describe 'preimplementation gate modes handler proof on the codex surface' {
    BeforeAll {
        $script:CodexGateHook = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . (Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        $script:GateEpicRaw = '{"route_id":"epic","epic_feature_folder":"x-family","epic_manifest_path":"docs/features/epics/x-family/epic.md","integration_branch":"epic/x-integration",' +
        '"features":[{"feature_folder":"docs/features/active/child-a-300","issue_num":300,"depends_on":[],"merge_status":"merged"},{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"depends_on":[300],"merge_status":"not_started"}]}'
        $script:GateParallelRaw = '{"route_id":"parallel","parallel_slug":"demo","parallel_manifest_path":"docs/features/parallel/demo/parallel.md",' +
        '"items":[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"}]}'
        # The flat mapped tool_input the Codex decision seam consumes.
        $script:GateEpicInput = @{ subagent_type = 'orchestrator'; prompt = 'Epic mode: true. Execute docs/features/active/child-b-301 now' } | ConvertTo-Json -Compress -Depth 3
        $script:GateParallelInput = @{ subagent_type = 'orchestrator'; prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301 now' } | ConvertTo-Json -Compress -Depth 3
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'H2 control: codex preimplementation gate allows a ready epic delegation when feature-folder-resolution.ps1 loads' {
        $script:OrchestrationFeatureFolderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateEpicInput -EpicCheckpointRaw $script:GateEpicRaw).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H2 control: codex preimplementation gate allows a ready parallel delegation when feature-folder-resolution.ps1 loads' {
        $script:OrchestrationFeatureFolderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateParallelInput -ParallelCheckpointRaw $script:GateParallelRaw).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H2 codex preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load' {
        # Arrange: re-dot-source the gate, which re-dot-sources the modes sibling, with the resolver forced to fail.
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:CodexGateHook
            $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            # Act
            $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateEpicInput -EpicCheckpointRaw $script:GateEpicRaw).hookSpecificOutput
        }
        finally {
            $script:OrchestrationFeatureFolderResolutionImportFailure = $null
        }
        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.Contains('feature-folder-resolution-import') | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'H2 codex preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load' {
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:CodexGateHook
            $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateParallelInput -ParallelCheckpointRaw $script:GateParallelRaw).hookSpecificOutput
        }
        finally {
            $script:OrchestrationFeatureFolderResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.Contains('feature-folder-resolution-import') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}
