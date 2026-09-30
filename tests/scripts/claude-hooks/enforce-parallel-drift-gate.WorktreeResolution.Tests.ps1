#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the parallel drift gate (issue #690).

.DESCRIPTION
    Covers a parallel checkpoint held only by another worktree, a review delegation without
    parallel_slug:, an ambiguous target, the scope filter that keeps resolution off calls the
    gate does not govern, and the fail-closed import guard.

    "Real resolver" rows run the shipped resolver over the live-root and checkpoint-text
    seams mocked in module scope 'WorktreeRunResolution'; the others mock the gate's
    resolution seam Resolve-ParallelDriftGateTarget. The checkpoint-read seam is mocked in
    every row that reaches it, so no row reads, creates, or writes a file, reads a wall
    clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-drift-gate.ps1").Path
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:ParallelRelative = 'artifacts/orchestration/parallel-orchestrator-state.json'
    $script:Prompt = 'Parallel mode: true. parallel_slug: wave-a. docs/features/active/item-b-102/spec.md'
    $script:ClearParallel = '{"route_id":"parallel","parallel_slug":"wave-a","items":[' +
    '{"issue_num":102,"feature_folder":"docs/features/active/item-b-102","state":"in_flight","worktree_path":"/wt/item-b",' +
    '"blast_radius":{"paths":["scripts/declared/"],"modules":[],"shared_surfaces":[],"contracts":[],"source":"declared","computed_at":"2026-01-01T00-00"}}' +
    '],"drift_events":[]}'

    function ConvertTo-AgentPayload {
        param([string] $SubagentType = 'feature-review', [string] $Prompt)
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $SubagentType; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Model the live worktrees for the real resolver.
    function Set-DriftRunTopology {
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

    # Replace the gate's resolution seam with a fixed target.
    function Set-DriftSeamTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Status, [string] $WorktreeRoot = '', [string[]] $Candidate = @())
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate $Candidate
        Mock -CommandName Resolve-ParallelDriftGateTarget -MockWith { $target }.GetNewClosure()
    }
}

Describe 'parallel drift gate target resolution' {
    It 'D1 allows an undrifted item by reading the parallel checkpoint under the other worktree' {
        # Arrange
        Set-DriftRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $script:ClearParallel }
        $clear = $script:ClearParallel
        Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { $clear }.GetNewClosure()

        # Act
        $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelDriftGateCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-par/$script:ParallelRelative" }
    }

    It 'D2 denies a review delegation without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE' {
        # Arrange
        Set-DriftRunTopology -Live @($script:Session)
        Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { $null }

        # Act
        $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt 'Parallel mode: true. docs/features/active/item-b-102/spec.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_DRIFT_GATE_BLOCKED'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'D3 denies an ambiguous target' {
        # Arrange
        Set-DriftSeamTarget -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { $null }

        # Act
        $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_DRIFT_GATE_BLOCKED'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
        Should -Invoke Get-ParallelDriftGateCheckpointContent -Times 0 -Exactly
    }

    It 'D4 allows a non-feature-review delegation without resolving' {
        # Arrange
        Set-DriftSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-ParallelDriftGateTarget -Times 0 -Exactly
    }

    It 'D5 allows a feature-review delegation without the parallel marker without resolving' {
        # Arrange
        Set-DriftSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt 'Review docs/features/active/item-b-102/spec.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-ParallelDriftGateTarget -Times 0 -Exactly
    }

    It 'D6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-AgentPayload -Prompt $script:Prompt
        $script:ParallelDriftGateResolutionImportFailure = 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $output = @(Invoke-ParallelDriftGateEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:ParallelDriftGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }
}
