#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the epic wave barrier (issue #690).

.DESCRIPTION
    Covers the reproduction admitted and denied at the barrier, ambiguous and other-worktree
    targets, the plain single-worktree regression guard, the stale-copy tie-break, the
    fail-closed import guard, and the scope filter that keeps resolution off calls the
    barrier does not govern.

    "Real resolver" rows run the shipped resolver over the live-root and checkpoint-text
    seams mocked in module scope 'WorktreeRunResolution'; the others mock the barrier's
    resolution seam Resolve-EpicWaveBarrierTarget. The read seam
    Get-EpicWaveBarrierCheckpointContent is mocked in every row that reaches it, so no row
    reads, creates, or writes a file, reads a wall clock, starts a process, or touches the
    network. Synthetic roots use the /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-EpicWaveBarrierCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Mock Test-CodexEpicChildRoutingLaunchAuthority { $null } }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:EpicRelative = 'artifacts/orchestration/epic-orchestrator-state.json'
    $script:Prompt = 'Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ' +
    'Upstream context for 2026-07-02-child-b-301: docs/features/active/2026-07-02-child-b-301/spec.md'
    $script:MergedEpic = '{"route_id":"epic","epic_feature_folder":"repro","integration_branch":"epic/repro-integration","features":[' +
    '{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"merged"},' +
    '{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}]}'
    $script:UnmergedEpic = $script:MergedEpic.Replace('"merge_status":"merged"', '"merge_status":"pr_open"')

    function ConvertTo-AgentPayload {
        param([string] $SubagentType = 'orchestrator', [string] $Prompt)
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $SubagentType; prompt = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Model the live worktrees for the real resolver.
    function Set-BarrierRunTopology {
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

    # Replace the barrier's resolution seam with a fixed target.
    function Set-BarrierSeamTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Status, [string] $WorktreeRoot = '')
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Resolve-EpicWaveBarrierTarget -MockWith { $target }.GetNewClosure()
    }
}

Describe 'epic wave barrier target resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'W1 admits the reproduction at the barrier by reading the epic checkpoint under the other worktree' {
        # Arrange
        Set-BarrierRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:MergedEpic }
        $merged = $script:MergedEpic
        Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $merged }.GetNewClosure()

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-EpicWaveBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-epic/$script:EpicRelative" }
    }

    It 'W2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint' {
        # Arrange
        Set-BarrierRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic')
        Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $null }

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
        Should -Invoke Get-EpicWaveBarrierCheckpointContent -Times 0 -Exactly
    }

    It 'W3 denies an ambiguous target with TARGET_WORKTREE_AMBIGUOUS' {
        # Arrange
        Set-BarrierSeamTarget -Status 'Ambiguous'

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
    }

    It 'W4 keeps the dependency deny text for a resolved target whose dependency is not merged' {
        # Arrange
        Set-BarrierSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic'
        $unmerged = $script:UnmergedEpic
        Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $unmerged }.GetNewClosure()

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match "cannot start until every dependency in its depends_on list"
        Should -Invoke Get-EpicWaveBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-epic/$script:EpicRelative" }
    }

    It 'W5 decides a session-root checkpoint exactly as before the change' {
        # Arrange: the seam resolves the session root and the read seam returns the same JSON.
        Set-BarrierSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session
        $merged = $script:MergedEpic
        Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $merged }.GetNewClosure()

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert: the pre-change decision for this checkpoint is the allow decision.
        ($decision | ConvertTo-Json -Compress -Depth 5) | Should -BeExactly ((Get-EpicWaveBarrierAllowDecision) | ConvertTo-Json -Compress -Depth 5)
        Should -Invoke Get-EpicWaveBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$($script:Session)/$script:EpicRelative" }
    }

    It 'W6 reads the worktree that has the integration branch checked out over a stale session-root copy' {
        # Arrange
        Set-BarrierRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -BranchRoot @('/synthetic-worktrees/w-epic') `
            -Epic @{ $script:Session = $script:MergedEpic; '/synthetic-worktrees/w-epic' = $script:MergedEpic }
        $merged = $script:MergedEpic
        Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $merged }.GetNewClosure()

        # Act
        $null = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt $script:Prompt)

        # Assert
        Should -Invoke Get-EpicWaveBarrierCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-epic/$script:EpicRelative" }
    }

    It 'W7 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange: reload the barrier with the WorktreeRunResolution.psm1 import throwing, so
        # its own import guard records the failure; every other import is a no-op.
        $payload = ConvertTo-AgentPayload -Prompt $script:Prompt
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated import failure (issue #690)' } -ParameterFilter { $Name -like '*WorktreeRunResolution.psm1' }
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
        try {
            # Act
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $payload
            $output = @(Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:EpicWaveBarrierResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }

    It 'W8 allows a non-orchestrator delegation without resolving' {
        # Arrange
        Set-BarrierSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -SubagentType 'atomic-planner' -Prompt $script:Prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-EpicWaveBarrierTarget -Times 0 -Exactly
    }

    It 'W9 allows an orchestrator delegation without the epic marker without resolving' {
        # Arrange
        Set-BarrierSeamTarget -Status 'SessionRoot' -WorktreeRoot $script:Session

        # Act
        $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw (ConvertTo-AgentPayload -Prompt 'Canonical issue number for this feature is 300. docs/features/active/child-a-300/spec.md')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-EpicWaveBarrierTarget -Times 0 -Exactly
    }
}
