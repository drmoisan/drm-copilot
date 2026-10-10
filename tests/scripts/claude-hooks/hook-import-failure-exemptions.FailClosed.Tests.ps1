#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Fail-closed proofs for the named import-failure handler exemptions on the Claude surface (issue #786).

.DESCRIPTION
    One Describe per handler. Each control row proves the payload and seams allow while the shared
    dependency loads; each decision row re-dot-sources the hook inside the It with
    Mock Join-Path throwing for feature-folder-resolution.ps1 (or Mock Import-Module throwing for
    the SubagentStop rows) and asserts that the hook denies or blocks and never allows.

    Vacuity guards: a loaded-state row asserts the handler variable is empty before it acts, a
    failure-state row asserts the variable names the dependency after the re-dot-source, and every
    failure-state row resets the variable in finally. Those construction assertions carry
    -Because 'E-CONSTRUCTION'. No test creates, renames, moves, or deletes a file.
#>

Describe 'feature-folder-order handler proof' {
    BeforeAll {
        $script:FeatureFolderOrderHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-feature-folder-order.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-feature-folder-order.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        $script:PlanJson = '{"tool_input":{"file_path":"docs/features/active/foo/plan.md"}}'
        $script:IssueJson = '{"tool_input":{"file_path":"docs/features/active/foo/issue.md"}}'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'H1 control: enforce-feature-folder-order.ps1 allows a full-bug plan write whose prerequisites exist when feature-folder-resolution.ps1 loads' {
        # Arrange: the F19 scenario with the resolver loaded.
        $script:FeatureFolderOrderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Get-FeatureFolderIssueContent { "# Issue`n- Work Mode: full-bug`n" }
        Mock Get-FeatureFolderFileExistence { param([string] $Path) @('issue.md', 'spec.md') -contains (($Path -split '/')[-1]) }

        # Act
        $decision = (Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:PlanJson).hookSpecificOutput

        # Assert
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H1 enforce-feature-folder-order.ps1 denies that plan write with FEATURE_FOLDER_ORDER_BLOCKED: when feature-folder-resolution.ps1 fails to load' {
        # Arrange: re-dot-source the hook with the resolver dot-source forced to fail.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:FeatureFolderOrderHook
            $script:FeatureFolderOrderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            Mock Get-FeatureFolderIssueContent { "# Issue`n- Work Mode: full-bug`n" }
            Mock Get-FeatureFolderFileExistence { param([string] $Path) @('issue.md', 'spec.md') -contains (($Path -split '/')[-1]) }

            # Act
            $decision = (Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:PlanJson).hookSpecificOutput
        }
        finally {
            $script:FeatureFolderOrderResolutionImportFailure = $null
        }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('FEATURE_FOLDER_ORDER_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('feature-folder-resolution.ps1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'H1 enforce-feature-folder-order.ps1 calls no resolver function for a non-plan write when feature-folder-resolution.ps1 loads' {
        # Arrange: the resolver is loaded and every resolver function is mocked for counting.
        $script:FeatureFolderOrderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Resolve-FeatureFolderWorkMode { 'full-bug' }
        Mock Get-FeatureFolderPlanPrerequisite { @('issue.md') }
        Mock Find-FeatureFolderCandidate { }
        Mock Select-FeatureFolderTarget { }
        Mock Find-FeatureFolderRecord { }
        Mock ConvertTo-FeatureFolderBasename { }

        # Act
        $decision = (Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:IssueJson).hookSpecificOutput

        # Assert: the non-plan write is allowed without any resolver call.
        $decision.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-FeatureFolderWorkMode -Times 0 -Exactly
        Should -Invoke Get-FeatureFolderPlanPrerequisite -Times 0 -Exactly
        Should -Invoke Find-FeatureFolderCandidate -Times 0 -Exactly
        Should -Invoke Select-FeatureFolderTarget -Times 0 -Exactly
        Should -Invoke Find-FeatureFolderRecord -Times 0 -Exactly
        Should -Invoke ConvertTo-FeatureFolderBasename -Times 0 -Exactly

        # Act and Assert: the plan path reaches the resolver call, so the mock is proven to intercept.
        Mock Get-FeatureFolderIssueContent { "# Issue`n- Work Mode: full-bug`n" }
        Mock Get-FeatureFolderFileExistence { param([string] $Path) @('issue.md', 'spec.md') -contains (($Path -split '/')[-1]) }
        $null = Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:PlanJson
        Should -Invoke Resolve-FeatureFolderWorkMode -Times 1 -Exactly
    }

    It 'H1 enforce-feature-folder-order.ps1 returns the same allow for a non-plan write whether or not feature-folder-resolution.ps1 loads' {
        # Arrange and Act: loaded state.
        $script:FeatureFolderOrderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        $loaded = (Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:IssueJson).hookSpecificOutput

        # Arrange and Act: failure state.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:FeatureFolderOrderHook
            $script:FeatureFolderOrderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            $failed = (Invoke-FeatureFolderOrderDecision -ToolInputRaw $script:IssueJson).hookSpecificOutput
        }
        finally {
            $script:FeatureFolderOrderResolutionImportFailure = $null
        }

        # Assert
        $loaded.permissionDecision | Should -Be 'allow'
        $failed.permissionDecision | Should -Be 'allow'
    }
}

Describe 'preimplementation gate modes handler proof on the claude surface' {
    BeforeAll {
        $script:ClaudeGateHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        $script:GateEpicRaw = '{"route_id":"epic","epic_feature_folder":"x-family","epic_manifest_path":"docs/features/epics/x-family/epic.md","integration_branch":"epic/x-integration",' +
        '"features":[{"feature_folder":"docs/features/active/child-a-300","issue_num":300,"depends_on":[],"merge_status":"merged"},{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"depends_on":[300],"merge_status":"not_started"}]}'
        $script:GateParallelRaw = '{"route_id":"parallel","parallel_slug":"demo","parallel_manifest_path":"docs/features/parallel/demo/parallel.md",' +
        '"items":[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"}]}'
        $script:GateEpicPayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = 'Epic mode: true. Execute docs/features/active/child-b-301 now' } } | ConvertTo-Json -Compress -Depth 5
        $script:GateParallelPayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = 'Parallel mode: true. Execute docs/features/active/child-b-301 now' } } | ConvertTo-Json -Compress -Depth 5
    }

    It 'H2 control: claude preimplementation gate allows a ready epic delegation when feature-folder-resolution.ps1 loads' {
        $script:OrchestrationFeatureFolderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateEpicPayload -EpicCheckpointRaw $script:GateEpicRaw).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H2 control: claude preimplementation gate allows a ready parallel delegation when feature-folder-resolution.ps1 loads' {
        $script:OrchestrationFeatureFolderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateParallelPayload -ParallelCheckpointRaw $script:GateParallelRaw).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H2 claude preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load' {
        # Arrange: re-dot-source the gate, which re-dot-sources the modes sibling, with the resolver forced to fail.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:ClaudeGateHook
            $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            # Act
            $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateEpicPayload -EpicCheckpointRaw $script:GateEpicRaw).hookSpecificOutput
        }
        finally {
            $script:OrchestrationFeatureFolderResolutionImportFailure = $null
        }
        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.Contains('feature-folder-resolution-import') | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'H2 claude preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:ClaudeGateHook
            $script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            $decision = (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $script:GateParallelPayload -ParallelCheckpointRaw $script:GateParallelRaw).hookSpecificOutput
        }
        finally {
            $script:OrchestrationFeatureFolderResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.Contains('feature-folder-resolution-import') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}

Describe 'prd-feature planner handler proof' {
    BeforeAll {
        $script:PrdPlannerHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Mock Get-PrdFeatureCheckpointFolder { $null }
        Mock Resolve-PrdFeatureWorktreeTarget { New-WorktreeResolutionTargetResult -Status 'SessionRoot' -SessionRoot '/synthetic-worktrees/session-root' -WorktreeRoot '/synthetic-worktrees/session-root' -Signal 'Branch' -SignalValue 'proof-own' -Candidate @('/synthetic-worktrees/session-root') -Detail 'synthetic session-root target' }
        $script:PlannerPayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1 for details.' } } | ConvertTo-Json -Compress -Depth 5
    }

    It 'H3 control: enforce-prd-feature-before-planner.ps1 allows a planner delegation whose prerequisites exist when feature-folder-resolution.ps1 loads' {
        $script:PrdFeatureFolderResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Get-PrdFeatureIssueContent { "- Work Mode: full-feature`n## Overview" }
        Mock Get-PrdFeatureFileExistence { $true }
        $decision = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $script:PlannerPayload).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H3 enforce-prd-feature-before-planner.ps1 denies that delegation with PRD_FEATURE_BLOCKED: when feature-folder-resolution.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:PrdPlannerHook
            $script:PrdFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            Mock Get-PrdFeatureIssueContent { "- Work Mode: full-feature`n## Overview" }
            Mock Get-PrdFeatureFileExistence { $true }
            $decision = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $script:PlannerPayload).hookSpecificOutput
        }
        finally {
            $script:PrdFeatureFolderResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('PRD_FEATURE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('work mode could not be determined') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}

Describe 'epic wave barrier handler proof' {
    BeforeAll {
        $script:WaveBarrierHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Mock Resolve-EpicWaveBarrierTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        # The W10 scenario: lifecycle-prefixed record values with a merged upstream dependency.
        $script:WaveCheckpoint = '{"features":[{"issue_num":300,"feature_folder":"docs/features/active/2026-07-02-upstream-300","depends_on":[],"merge_status":"merged"},' +
        '{"issue_num":301,"feature_folder":"active/2026-07-02-target-301","depends_on":["docs/features/active/2026-07-02-upstream-300"],"merge_status":"not_started"}]}'
        $script:WavePayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = 'Epic mode: true. integration_branch: epic/x-integration. Execute docs/features/active/2026-07-02-target-301.' } } | ConvertTo-Json -Compress -Depth 5
    }

    It 'H4 control: enforce-epic-wave-barrier.ps1 allows the W10 delegation when feature-folder-resolution.ps1 loads' {
        $script:EpicWaveBarrierResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Get-EpicWaveBarrierCheckpointContent { $script:WaveCheckpoint }
        $decision = (Invoke-EpicWaveBarrierDecision -ToolInputRaw $script:WavePayload).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H4 enforce-epic-wave-barrier.ps1 denies that delegation with EPIC_WAVE_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:WaveBarrierHook
            $script:EpicWaveBarrierResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            Mock Get-EpicWaveBarrierCheckpointContent { $script:WaveCheckpoint }
            $decision = (Invoke-EpicWaveBarrierDecision -ToolInputRaw $script:WavePayload).hookSpecificOutput
        }
        finally {
            $script:EpicWaveBarrierResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('EPIC_WAVE_BARRIER_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('feature-folder-resolution.ps1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}

Describe 'parallel drift gate handler proof' {
    BeforeAll {
        $script:DriftGateHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-drift-gate.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-drift-gate.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Mock Resolve-ParallelDriftGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        # The D1 scenario: the target item has no drift event.
        $script:DriftCheckpoint = '{"items":[{"issue_num":501,"feature_folder":"2026-08-07-parallel-alpha-501","state":"in_flight","worktree_path":"/worktrees/alpha",' +
        '"blast_radius":{"paths":["scripts/declared/"],"modules":[],"shared_surfaces":[],"contracts":[],"source":"declared","computed_at":"2026-01-01T00-00"}},' +
        '{"issue_num":502,"feature_folder":"2026-08-07-parallel-bravo-502","state":"in_flight"}],"drift_events":[]}'
        $script:DriftPayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'feature-review'; prompt = 'Parallel mode: true. parallel_slug: demo. Review docs/features/active/2026-08-07-parallel-alpha-501 now' } } | ConvertTo-Json -Compress -Depth 5
    }

    It 'H5 control: enforce-parallel-drift-gate.ps1 allows the D1 delegation when feature-folder-resolution.ps1 loads' {
        $script:ParallelDriftGateResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Get-ParallelDriftGateCheckpointContent { $script:DriftCheckpoint }
        $decision = (Invoke-ParallelDriftGateDecision -ToolInputRaw $script:DriftPayload).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H5 enforce-parallel-drift-gate.ps1 denies that delegation with PARALLEL_DRIFT_GATE_BLOCKED: when feature-folder-resolution.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:DriftGateHook
            $script:ParallelDriftGateResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            Mock Get-ParallelDriftGateCheckpointContent { $script:DriftCheckpoint }
            $decision = (Invoke-ParallelDriftGateDecision -ToolInputRaw $script:DriftPayload).hookSpecificOutput
        }
        finally {
            $script:ParallelDriftGateResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('PARALLEL_DRIFT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('feature-folder-resolution.ps1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}

Describe 'parallel cohort barrier handler proof' {
    BeforeAll {
        $script:CohortBarrierHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        Mock Resolve-ParallelCohortBarrierTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        # The C1 scenario: the target sits in cohort 1 behind a merged cohort-0 conflict.
        $script:CohortCheckpoint = '{"recolor_generation":2,"items":[{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"},' +
        '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}],' +
        '"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'
        $script:CohortPayload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'orchestrator'; prompt = 'Parallel mode: true. parallel_slug: demo. Execute docs/features/active/item-b-102 now' } } | ConvertTo-Json -Compress -Depth 5
    }

    It 'H6 control: enforce-parallel-cohort-barrier.ps1 allows the C1 delegation when feature-folder-resolution.ps1 loads' {
        $script:ParallelCohortBarrierResolutionImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'
        Mock Get-ParallelCohortBarrierCheckpointContent { $script:CohortCheckpoint }
        $decision = (Invoke-ParallelCohortBarrierDecision -ToolInputRaw $script:CohortPayload).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'H6 enforce-parallel-cohort-barrier.ps1 denies that delegation with PARALLEL_COHORT_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: feature-folder-resolution.ps1' } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }
        try {
            . $script:CohortBarrierHook
            $script:ParallelCohortBarrierResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1' -Because 'E-CONSTRUCTION'
            Mock Get-ParallelCohortBarrierCheckpointContent { $script:CohortCheckpoint }
            $decision = (Invoke-ParallelCohortBarrierDecision -ToolInputRaw $script:CohortPayload).hookSpecificOutput
        }
        finally {
            $script:ParallelCohortBarrierResolutionImportFailure = $null
        }
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('PARALLEL_COHORT_BARRIER_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('feature-folder-resolution.ps1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }
}

Describe 'orchestrator output validator handler proof' {
    BeforeAll {
        $script:OrchestratorOutputHook = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-EpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicScopeCheckpointText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex' }
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelCohortBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelCohortBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelDriftGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrdFeatureCheckpointFolder -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex' }
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-WorktreeResolutionGitFileText' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }

        function Invoke-OrchestratorOutputHookProcess {
            # Drives the hook through the & route with stdin and stderr redirected and the
            # payload environment variable set for this one invocation; all are restored in finally.
            param([hashtable] $HookParameter = @{})
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $priorInput = $env:CLAUDE_HOOK_INPUT
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new(''))
                [System.Console]::SetError($errorWriter)
                $env:CLAUDE_HOOK_INPUT = '{"output":"Final summary."}'
                $global:LASTEXITCODE = 0
                try { $null = & $script:OrchestratorOutputHook @HookParameter } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
                $env:CLAUDE_HOOK_INPUT = $priorInput
            }
            return [pscustomobject]@{ Thrown = $thrown; ExitCode = $exitCode; Stderr = $errorWriter.ToString() }
        }
    }

    It 'H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails' {
        # Arrange
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: WorktreeRunResolution.psm1' } -ParameterFilter { $Name -like '*WorktreeRunResolution.psm1' }
        try {
            # Act
            $result = Invoke-OrchestratorOutputHookProcess
        }
        finally {
            $script:OrchestratorOutputResolverImportFailure = $null
        }
        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Stderr
    }

    It 'H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails' {
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: OrchestratorStateEpicWaveBarrier.psm1' } -ParameterFilter { $Name -like '*OrchestratorStateEpicWaveBarrier.psm1' }
        try {
            $result = Invoke-OrchestratorOutputHookProcess -HookParameter @{ ArtifactType = 'epic-orchestrator-state' }
        }
        finally {
            $script:OrchestratorOutputWaveBarrierImportFailure = $null
        }
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Stderr
    }
}
