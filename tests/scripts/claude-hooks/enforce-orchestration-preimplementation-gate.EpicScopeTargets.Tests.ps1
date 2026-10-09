#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Preimplementation gate epic-scope rows that resolve every segment and path target (issue #738).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision of the Claude gate. The epic-scope
    decision resolves the target of every command segment and path, denies a target it cannot
    resolve, an ambiguous target, or a target outside the session-root epic scope, and
    evaluates the epic readiness predicate against every target. The worktree ascent, the epic
    checkpoint read, the HEAD read, the MERGE_HEAD probe, and the epic target lookup are
    mocked inside EpicScopeResolution: the session root maps to
    /synthetic-worktrees/epic-coordinator, /outside/ paths do not resolve, and any other
    /synthetic-worktrees/<name>/ path resolves to its first two segments. Every row passes a
    not-ready single-feature checkpoint. The file creates no file and starts no child process.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')

    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"}]}'
    $script:NotReadySingleFeature = '{"issue-num":"738","route_id":"large","lifecycle_ready":false}'
    $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'

    function Set-TargetSeam {
        <#
            Mock the resolver seams inside EpicScopeResolution with the shared fixture model:
            per-root HEAD and merge maps, and an epic checkpoint text closed over by value.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $CheckpointText)
        $text = $CheckpointText
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/outside/*') { return $null }
            if ($Path -match '^(/synthetic-worktrees/[^/]+)') { return $Matches[1] }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $text }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution {
            if ($WorktreeRoot -eq '/synthetic-worktrees/epic-other') { return 'feature/standalone-item' }
            return 'epic/sample-epic-integration'
        }
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $WorktreeRoot -ne '/synthetic-worktrees/epic-child' }
        Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $SessionRoot; ReasonCode = $null; Detail = 'default SessionRoot target' } }
    }

    function Get-TargetGateDecision {
        # Single act step: decide one Bash command or one Write path against a not-ready checkpoint.
        param([string] $Command = '', [string] $FilePath = '')
        $toolInput = if ($FilePath) { @{ tool_name = 'Write'; tool_input = @{ file_path = $FilePath } } } else { @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } }
        return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($toolInput | ConvertTo-Json -Depth 5 -Compress) -CheckpointRaw $script:NotReadySingleFeature
    }

    Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }
}

Describe 'enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738)' {
    It '<Name>' -ForEach @(
        @{ Name = 'denies a second segment that targets a different not-ready worktree'; Command = 'git add scripts/powershell/A.ps1 && git -C /synthetic-worktrees/epic-child add scripts/powershell/B.ps1'; FilePath = ''; Code = 'target-not-ready' }
        @{ Name = 'denies a relative -C selector in epic scope'; Command = 'git -C subdir add scripts/powershell/Sample.ps1'; FilePath = ''; Code = 'target-unresolvable' }
        @{ Name = 'denies an unresolvable -C selector in epic scope'; Command = 'git -C /outside/elsewhere add scripts/powershell/Sample.ps1'; FilePath = ''; Code = 'target-unresolvable' }
        @{ Name = 'denies a directory-changing segment in epic scope'; Command = 'cd /synthetic-worktrees/epic-child && git add scripts/powershell/Sample.ps1'; FilePath = ''; Code = 'target-unresolvable' }
        @{ Name = 'denies a wrapper-led git segment in epic scope'; Command = 'nohup git -C /synthetic-worktrees/epic-child add scripts/powershell/Sample.ps1'; FilePath = ''; Code = 'target-unresolvable' }
        @{ Name = 'denies a Write into a not-ready epic worktree'; Command = ''; FilePath = '/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1'; Code = 'target-not-ready' }
        @{ Name = 'denies a target outside the epic scope of the session root'; Command = 'git -C /synthetic-worktrees/epic-other add scripts/powershell/Sample.ps1'; FilePath = ''; Code = 'target-mixed' }
    ) {
        # Arrange
        Set-TargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-TargetGateDecision -Command $Command -FilePath $FilePath

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "$Name in epic scope"
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains($Code) | Should -BeTrue -Because "the deny names $Code"
    }

    It 'evaluates every value of a repeated -C selector' {
        # Arrange
        Set-TargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-TargetGateDecision -Command 'git -C /synthetic-worktrees/epic-integration -C /synthetic-worktrees/epic-child add scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the second selector worktree has no merge in progress'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains('target-not-ready') | Should -BeTrue -Because 'the not-ready target is named'
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-integration' }
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-child' }
    }

    It 'allows when every target is epic scope and ready' {
        # Arrange
        Set-TargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-TargetGateDecision -Command 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/A.ps1 && git -C /synthetic-worktrees/epic-coordinator add scripts/powershell/B.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'both targets are epic scope with a merge in progress'
    }

    It 'keeps the single-feature decision for <Label> outside epic scope' -ForEach @(
        @{ Label = 'a relative -C selector'; Command = 'git -C subdir add scripts/powershell/Sample.ps1' }
        @{ Label = 'a directory change'; Command = 'cd /synthetic-worktrees/epic-child && git add scripts/powershell/Sample.ps1' }
    ) {
        # Arrange
        Set-TargetSeam -CheckpointText $null

        # Act
        $decision = Get-TargetGateDecision -Command $Command

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the not-ready single-feature checkpoint decides'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason -Because 'no epic checkpoint leaves the decision unchanged'
    }

    It 'denies an ambiguous epic target' {
        # Arrange
        Set-TargetSeam -CheckpointText $script:ReadyEpicJson
        Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = 'target-worktree-ambiguous'; Detail = 'two worktrees claim the branch' } }

        # Act
        $decision = Get-TargetGateDecision -Command 'git add scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'more than one worktree claims the integration branch'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains('target-ambiguous') | Should -BeTrue -Because 'the deny names target-ambiguous'
    }
}
