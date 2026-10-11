#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Run-target resolution rows for the epic merge gate (issue #690).

.DESCRIPTION
    Covers the epic and parallel branches resolved by pull request number to a checkpoint
    held by another worktree, the child branch's pr_gate.pr_number binding, the bare
    command evaluated at the session worktree, the unresolved and ambiguous deny prefixes,
    standalone authorization when neither run branch resolves, and the fail-closed import
    guard.

    "Real resolver" rows run the shipped record resolver over the live-root and
    checkpoint-text seams mocked in module scope 'WorktreeRunResolution'; the others mock
    the gate's seam Resolve-EpicMergeGateRunTarget. All three checkpoint read seams are
    mocked in every row, so no row reads, creates, or writes a file, reads a wall clock,
    starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.

    Issue #850: the per-feature checkpoint is now read beneath the item target the gate
    resolves by pull request number, and M5 records the #788 behavior change.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-ChildOrchestratorCheckpointContent { $null }
    Mock Get-EpicOrchestratorCheckpointContent { $null }
    Mock Get-ParallelOrchestratorCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:SessionId = 'session-690-merge'
    $script:ReadyEpic = '{"route_id":"epic","epic_merge_pr":{"pr_number":812,"ci_gate":{"conclusion":"success"}}}'
    $script:GreenParallel = '{"route_id":"parallel","items":[{"pr_number":812,"merge_status":"ci_green"}]}'
    $script:ChildPassed = '{"epic_mode":true,"step9_status":"passed"}'

    function ConvertTo-MergePayload {
        param([string] $Command)
        return ([ordered]@{ tool_name = 'Bash'; session_id = $script:SessionId; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Mock the three read seams with fixed text; each argument may be $null.
    function Set-MergeReadSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $Child, [AllowNull()] [string] $Epic, [AllowNull()] [string] $Parallel)
        $childText = $Child
        $epicText = $Epic
        $parallelText = $Parallel
        Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $childText }.GetNewClosure()
        Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $epicText }.GetNewClosure()
        Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $parallelText }.GetNewClosure()
    }

    # Model the live worktrees for the real record resolver.
    function Set-MergeRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Epic = @{}, [hashtable] $Parallel = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    $itemNone = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
    Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $itemNone }.GetNewClosure()
}

Describe 'epic merge gate run-target resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'M1 allows an epic integration merge whose ready checkpoint is only in another worktree' {
        # Arrange
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:ReadyEpic }
        Set-MergeReadSeam -Child $null -Epic $script:ReadyEpic -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-EpicOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
        }
    }

    It 'M2 allows a parallel item merge whose ci_green checkpoint is only in another worktree' {
        # Arrange
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $script:GreenParallel }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $script:GreenParallel

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json'
        }
    }

    It 'M3 denies a child merge whose pr_gate.pr_number differs from the command PR number' {
        # Arrange
        $item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-MergeReadSeam -Child '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":811}}' -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'M4 allows a child merge whose pr_gate.pr_number equals the command PR number' {
        # Arrange
        $item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-MergeReadSeam -Child '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":812}}' -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'M5 denies a child merge whose checkpoint records neither pr_gate nor a standalone record for the number' {
        # Arrange: the real item resolver runs over module-scoped seams; w-item records no binding.
        $childText = $script:ChildPassed
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { Resolve-WorktreeItemTargetByPrNumber -PrNumber $PrNumber -SessionRoot '/synthetic-worktrees/session' }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] @('/synthetic-worktrees/w-item') }
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Path)
            if ($Path -eq '/synthetic-worktrees/w-item/artifacts/orchestration/orchestrator-state.json') { return $childText }
            return $null
        }.GetNewClosure()
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-MergeReadSeam -Child $script:ChildPassed -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'M6 reads every checkpoint beneath the session worktree for a bare command without resolving' {
        # Arrange
        Mock -CommandName Get-EpicMergeGateSessionWorktreeRoot -MockWith { '/synthetic-worktrees/session' }
        Mock -CommandName Resolve-EpicMergeGateRunTarget -MockWith { throw 'a bare command must not resolve by record' }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $null = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge')

        # Assert
        Should -Invoke Resolve-EpicMergeGateRunTarget -Times 0 -Exactly
        Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json' }
        Should -Invoke Get-EpicOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/epic-orchestrator-state.json' }
        Should -Invoke Get-ParallelOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/parallel-orchestrator-state.json' }
    }

    It 'M7 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither run branch resolves and no record authorizes' {
        # Arrange
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'M8 denies with TARGET_WORKTREE_AMBIGUOUS when the epic branch is ambiguous' {
        # Arrange
        $ambiguous = New-WorktreeResolutionFixtureTarget -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        $none = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-EpicMergeGateRunTarget -MockWith { $ambiguous }.GetNewClosure() -ParameterFilter { $Kind -eq 'epic' }
        Mock -CommandName Resolve-EpicMergeGateRunTarget -MockWith { $none }.GetNewClosure() -ParameterFilter { $Kind -eq 'parallel' }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }

    It 'M9 allows a standalone-authorized merge when neither run branch resolves' {
        # Arrange: a well-formed record for 812 in the per-feature checkpoint, bound to this session.
        $record = '{"standalone_merge_authorizations":[{"pr_number":812,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/812",' +
        '"issue_num":690,"branch_name":"bug/agent-payload-gates-resolve-session-root-690","authorized_by":"orchestrator",' +
        '"authorized_at":"2026-09-29T21:04:00Z","session_id":"' + $script:SessionId + '",' +
        '"basis":"Standalone merge for #690 after every required check passed."}]}'
        $item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()
        Set-MergeRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-MergeReadSeam -Child $record -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'M10 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-MergePayload -Command 'gh pr merge --merge 812'
        Add-HookDependencyFailure -Name 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $payload
            $output = @(Invoke-EpicMergeGateEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }
}
