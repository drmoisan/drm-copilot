#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Preimplementation gate 4 epic-scope rows for the command and path legs (issue #663).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision for implementation-classified
    staging commands and Write/Edit calls. When the effective worktree's HEAD equals the
    epic checkpoint's integration_branch, the call is epic scope and is decided by the epic
    command-leg readiness predicate on artifacts/orchestration/epic-orchestrator-state.json;
    under decision D2 a production path may be staged or edited only while a merge is in
    progress. Anything that is not epic scope takes the unchanged single-feature path.

    The gate is dot-sourced first and EpicScopeResolution.psm1 is imported without -Force,
    so the suite binds to the module instance the gate loaded. The worktree ascent, the
    epic checkpoint read, the HEAD read, and the MERGE_HEAD probe are mocked inside that
    module; the ascent maps the session root to /synthetic-worktrees/epic-coordinator and
    returns any /synthetic-worktrees/ path unchanged, so no host path reaches an assertion.
    Every row passes -CheckpointRaw a not-ready single-feature checkpoint, so a
    single-feature decision is always a deny with the pre-change reason. No row creates a
    file or changes the working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')

    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
    $script:NotReadySingleFeature = '{"issue-num":"663","route_id":"large","lifecycle_ready":false}'
    $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:ProductionPath = 'scripts/powershell/Sample.ps1'
    $script:StageCommand = 'git add scripts/powershell/Sample.ps1'

    function ConvertTo-GateBashPayload {
        # Return a Bash PreToolUse payload carrying one command string.
        param([Parameter(Mandatory)] [string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function ConvertTo-GateFilePayload {
        # Return a Write or Edit PreToolUse payload for one file path.
        param([Parameter(Mandatory)] [string] $ToolName, [Parameter(Mandatory)] [string] $FilePath)
        return (@{ tool_name = $ToolName; tool_input = @{ file_path = $FilePath } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function ConvertTo-EpicJsonWithout {
        # Return the ready epic checkpoint JSON with one property removed.
        param([Parameter(Mandatory)] [string] $Property)
        $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
        $checkpoint.PSObject.Properties.Remove($Property)
        return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
    }

    function Set-EpicScopeSeam {
        <#
            Mock the four resolver seams inside EpicScopeResolution. The bodies close over
            local copies because a module-scoped mock body cannot see this scope otherwise.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()] [string] $CheckpointText,
            [string] $HeadBranch = 'epic/sample-epic-integration',
            [bool] $MergeInProgress = $true
        )
        $text = $CheckpointText
        $head = $HeadBranch
        $merge = $MergeInProgress
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/synthetic-worktrees/*') { return $Path }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $text }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $head }.GetNewClosure()
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $merge }.GetNewClosure()
    }
}

Describe 'enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663)' {
    It 'epic scope allows git add of a production path while a merge is in progress' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits staging a production path (D2)'
    }

    It 'epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $false
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains("'merge-in-progress'") | Should -BeTrue -Because 'the denial names the failed conjunct'
    }

    It 'epic scope denies git add of a production path when <Conjunct> is missing and names it' -ForEach @(
        @{ Conjunct = 'epic_feature_folder' }
        @{ Conjunct = 'epic_manifest_path' }
        @{ Conjunct = 'features' }
    ) {
        # Arrange
        Set-EpicScopeSeam -CheckpointText (ConvertTo-EpicJsonWithout -Property $Conjunct) -MergeInProgress $true
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains("'$Conjunct'") | Should -BeTrue -Because 'the denial names the failed conjunct'
    }

    It 'a checkpoint missing <Conjunct> is not epic scope and the command leg denies through the single-feature path' -ForEach @(
        @{ Conjunct = 'route_id' }
        @{ Conjunct = 'integration_branch' }
    ) {
        # Arrange: route_id and integration_branch are scope-defining (RS-2).
        Set-EpicScopeSeam -CheckpointText (ConvertTo-EpicJsonWithout -Property $Conjunct) -MergeInProgress $true
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
    }

    It 'epic scope resolves the -C selector worktree for the command leg' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true
        $payload = ConvertTo-GateBashPayload -Command 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/Sample.ps1'

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert: the HEAD read targets the selector worktree, not the session root.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter {
            $WorktreeRoot -eq '/synthetic-worktrees/epic-integration'
        }
    }

    It 'epic scope allows an Edit of a production path while a merge is in progress' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true
        $payload = ConvertTo-GateFilePayload -ToolName 'Edit' -FilePath $script:ProductionPath

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the path leg follows the same readiness decision as the command leg'
    }

    It 'epic scope denies a Write of a production path when no merge is in progress' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $false
        $payload = ConvertTo-GateFilePayload -ToolName 'Write' -FilePath $script:ProductionPath

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains("'merge-in-progress'") | Should -BeTrue -Because 'the denial names the failed conjunct'
    }

    It 'without an epic checkpoint the command leg returns the unchanged single-feature decision and reason' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $null
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
    }

    It 'without an epic checkpoint the path leg returns the unchanged single-feature decision and reason' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $null
        $payload = ConvertTo-GateFilePayload -ToolName 'Write' -FilePath $script:ProductionPath

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
    }

    It 'an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path' {
        # Arrange
        Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -HeadBranch 'feature/standalone-item' -MergeInProgress $true
        $payload = ConvertTo-GateBashPayload -Command $script:StageCommand

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $script:NotReadySingleFeature

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
    }
}
