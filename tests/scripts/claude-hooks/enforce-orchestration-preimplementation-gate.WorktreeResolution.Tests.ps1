#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the preimplementation gate's delegation legs (issue #690).

.DESCRIPTION
    Covers the epic-mode, parallel-mode, and single-feature Agent legs: the reproduction
    admitted and denied, unresolved and ambiguous targets, resolution into another
    worktree, the plain single-worktree regression guard, the stale-copy tie-break, and
    the precedence of the three injection parameters.

    Rows marked "real resolver" run the shipped resolver over two mocks registered with
    -ModuleName 'WorktreeRunResolution' (the live-root enumeration and the checkpoint-text
    seam); the other rows mock the gate's resolution seam Resolve-OrchestrationGateTarget.
    Every checkpoint read seam is mocked, so no test reads, creates, or writes a file,
    reads a wall clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:EpicRelative = 'artifacts/orchestration/epic-orchestrator-state.json'
    $script:IssueLine = 'Canonical issue number for this feature is 301. All artifact content, file paths, and cross-references must use this number.'
    $script:EpicPrompt = 'Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ' +
    'epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. Execute docs/features/active/child-b-301. ' + $script:IssueLine
    $script:ParallelPrompt = 'Parallel mode: true. parallel_slug: wave-a. Execute docs/features/active/child-b-301.'
    $script:ReadyEpic = '{"route_id":"epic","epic_feature_folder":"repro","epic_manifest_path":"docs/features/epics/repro/epic.md",' +
    '"integration_branch":"epic/repro-integration","features":[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"merge_status":"not_started"}]}'
    $script:ReadyParallel = '{"route_id":"parallel","parallel_slug":"wave-a","parallel_manifest_path":"docs/features/parallel/wave-a/parallel.md",' +
    '"items":[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"state":"in_flight","merge_status":"not_started"}]}'
    $script:ReadyItem = '{"issue-num":"301","feature-folder":"docs/features/active/child-b-301","route_id":"large","lifecycle_ready":true}'

    # An Agent delegation envelope as JSON.
    function ConvertTo-AgentPayload {
        param([string] $SubagentType, [string] $Prompt)
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $SubagentType; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Model the live worktrees for the real resolver: Live is the unfiltered set,
    # BranchRoot the -Branch result, and Epic a root-to-epic-checkpoint-text map.
    function Set-GateRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [string[]] $BranchRoot = @(), [hashtable] $Epic = @{})
        $liveSet = $Live
        $branchSet = $BranchRoot
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    # Replace the gate's resolution seam with a fixed target.
    function Set-GateSeamTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Status, [string] $WorktreeRoot = '')
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Resolve-OrchestrationGateTarget -MockWith { $target }.GetNewClosure()
    }
}

Describe 'preimplementation gate epic-mode resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'R1 admits the reproduction by reading the epic checkpoint under the other worktree' {
        # Arrange: the ready epic checkpoint exists only at w-epic.
        Set-GateRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:ReadyEpic }
        $ready = $script:ReadyEpic
        Mock -CommandName Get-EpicCheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-EpicCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-epic/$script:EpicRelative" }
    }

    It 'R2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint' {
        # Arrange
        Set-GateRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic')
        Mock -CommandName Get-EpicCheckpointContent -MockWith { '' }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
        Should -Invoke Get-EpicCheckpointContent -Times 0 -Exactly
    }

    It 'R3 denies an ambiguous epic target with TARGET_WORKTREE_AMBIGUOUS' {
        # Arrange
        Set-GateSeamTarget -Status 'Ambiguous'

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }

    It 'R11 decides an epic checkpoint at the session root exactly as the injected checkpoint' {
        # Arrange: the only matching copy is at the session root.
        Set-GateRunTopology -Live @($script:Session) -Epic @{ $script:Session = $script:ReadyEpic }
        $ready = $script:ReadyEpic
        Mock -CommandName Get-EpicCheckpointContent -MockWith { $ready }.GetNewClosure()
        $payload = ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt

        # Act
        $resolved = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
        $injected = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -EpicCheckpointRaw $ready

        # Assert
        ($resolved | ConvertTo-Json -Compress -Depth 5) | Should -BeExactly ($injected | ConvertTo-Json -Compress -Depth 5)
    }

    It 'R12 reads the worktree that has the integration branch checked out over a stale session-root copy' {
        # Arrange
        Set-GateRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -BranchRoot @('/synthetic-worktrees/w-epic') `
            -Epic @{ $script:Session = $script:ReadyEpic; '/synthetic-worktrees/w-epic' = $script:ReadyEpic }
        $ready = $script:ReadyEpic
        Mock -CommandName Get-EpicCheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt)

        # Assert
        Should -Invoke Get-EpicCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-epic/$script:EpicRelative" }
    }
}

Describe 'preimplementation gate parallel-mode resolution' {
    It 'R4 reads the parallel checkpoint beneath another worktree and admits a ready run' {
        # Arrange
        Set-GateSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-par'
        $ready = $script:ReadyParallel
        Mock -CommandName Get-ParallelCheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:ParallelPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json'
        }
    }

    It 'R5 denies a parallel kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE' {
        # Arrange
        Set-GateRunTopology -Live @($script:Session)

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt 'Parallel mode: true. Execute docs/features/active/child-b-301.')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'R6 denies an ambiguous parallel target' {
        # Arrange
        Set-GateSeamTarget -Status 'Ambiguous'

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:ParallelPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }
}

Describe 'preimplementation gate single-feature delegation resolution' {
    It 'R7 reads an implementation agent''s checkpoint beneath its own worktree' {
        # Arrange
        Set-GateSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        $ready = $script:ReadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'powershell-typed-engineer' -Prompt $script:IssueLine)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-item/artifacts/orchestration/orchestrator-state.json'
        }
    }

    It 'R8 denies an implementation agent delegation that carries neither identity line without enumerating worktrees' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] @() }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'powershell-typed-engineer' -Prompt 'Implement the plan.')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED:'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -Times 0 -Exactly
    }

    It 'R9 denies an ambiguous implementation agent target' {
        # Arrange
        Set-GateSeamTarget -Status 'Ambiguous'

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'powershell-typed-engineer' -Prompt $script:IssueLine)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }

    It 'R10 denies a non-mode orchestrator delegation without identity lines' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] @() }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt 'Run the approved plan.')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }
}

Describe 'preimplementation gate injection precedence' {
    BeforeEach {
        Set-GateSeamTarget -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/default-session'
    }

    It 'R13 bypasses resolution for a bound non-empty CheckpointRaw' {
        # Arrange / Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'powershell-typed-engineer' -Prompt 'x') -CheckpointRaw $script:ReadyItem

        # Assert
        Should -Invoke Resolve-OrchestrationGateTarget -Times 0 -Exactly
    }

    It 'R14 bypasses resolution for a bound empty EpicCheckpointRaw' {
        # Arrange / Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:EpicPrompt) -EpicCheckpointRaw ''

        # Assert
        Should -Invoke Resolve-OrchestrationGateTarget -Times 0 -Exactly
    }

    It 'R15 bypasses resolution for a bound ParallelCheckpointRaw' {
        # Arrange / Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'orchestrator' -Prompt $script:ParallelPrompt) -ParallelCheckpointRaw $script:ReadyParallel

        # Assert
        Should -Invoke Resolve-OrchestrationGateTarget -Times 0 -Exactly
    }
}
