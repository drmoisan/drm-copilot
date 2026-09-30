#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the parallel cohort barrier (issue #690).

.DESCRIPTION
    Covers a parallel checkpoint held only by another worktree, a kickoff without
    parallel_slug:, two matching checkpoints, the plain single-worktree regression guard,
    the fail-closed import guard, and the scope filter that keeps resolution off calls
    the barrier does not govern.

    "Real resolver" rows run the shipped resolver over the live-root and checkpoint-text
    seams mocked in module scope 'WorktreeRunResolution'; the others mock the barrier's
    resolution seam Resolve-ParallelCohortBarrierTarget. The read seam is mocked in every
    row that reaches it, so no row reads, creates, or writes a file, reads a wall clock,
    starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:ParallelRelative = 'artifacts/orchestration/parallel-orchestrator-state.json'
    $script:Prompt = 'Parallel mode: true. parallel_slug: wave-a. docs/features/active/item-b-102'
    $script:ClearParallel = '{"route_id":"parallel","parallel_slug":"wave-a","recolor_generation":2,"items":[' +
    '{"issue_num":101,"feature_folder":"docs/features/active/item-a-101","merge_status":"merged"},' +
    '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","merge_status":"not_started"}' +
    '],"cohorts":[{"index":0,"generation":2,"item_keys":[101]},{"index":1,"generation":2,"item_keys":[102]}],' +
    '"conflict_edges":[{"a":101,"b":102,"reason":"path_overlap"}]}'

    function ConvertTo-AgentPayload {
        param([string] $SubagentType = 'orchestrator', [string] $Prompt)
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $SubagentType; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Model the live worktrees for the real resolver.
    function Set-CohortRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Parallel = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    # Replace the barrier's resolution seam with a fixed target.
    function Set-CohortSeamTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Status, [string] $WorktreeRoot = '')
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot
        Mock -CommandName Resolve-ParallelCohortBarrierTarget -MockWith { $target }.GetNewClosure()
    }
}

Describe 'parallel cohort barrier target resolution' {
    It 'C1 admits a clear barrier by reading the parallel checkpoint under the other worktree' {
        # Arrange
        Set-CohortRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $script:ClearParallel }
        $clear = $script:ClearParallel
        Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { $clear }.GetNewClosure()

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelCohortBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-par/$script:ParallelRelative" }
    }

    It 'C2 denies a kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE' {
        # Arrange
        Set-CohortRunTopology -Live @($script:Session)

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt 'Parallel mode: true. docs/features/active/item-b-102')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'C3 denies two matching parallel checkpoints with TARGET_WORKTREE_AMBIGUOUS' {
        # Arrange
        Set-CohortRunTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') `
            -Parallel @{ '/synthetic-worktrees/a' = $script:ClearParallel; '/synthetic-worktrees/b' = $script:ClearParallel }

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }

    It 'C4 decides a session-root checkpoint exactly as before the change' {
        # Arrange
        Set-CohortSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session
        $clear = $script:ClearParallel
        Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { $clear }.GetNewClosure()

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert: the pre-change decision for this checkpoint is the allow decision.
        ($decision | ConvertTo-Json -Compress -Depth 5) | Should -BeExactly ((Get-ParallelCohortBarrierAllowDecision) | ConvertTo-Json -Compress -Depth 5)
        Should -Invoke Get-ParallelCohortBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$($script:Session)/$script:ParallelRelative" }
    }

    It 'C5 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-AgentPayload -Prompt $script:Prompt
        $script:ParallelCohortBarrierResolutionImportFailure = 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw $payload
            $output = @(Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:ParallelCohortBarrierResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }

    It 'C6 allows a non-orchestrator delegation without resolving' {
        # Arrange
        Set-CohortSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'parallel-planner' -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-ParallelCohortBarrierTarget -Times 0 -Exactly
    }

    It 'C7 allows an orchestrator delegation without the parallel marker without resolving' {
        # Arrange
        Set-CohortSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-ParallelCohortBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt 'Canonical issue number for this item is 102. docs/features/active/item-b-102')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-ParallelCohortBarrierTarget -Times 0 -Exactly
    }
}
