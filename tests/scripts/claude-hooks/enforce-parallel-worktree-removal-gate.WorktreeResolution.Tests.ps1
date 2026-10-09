#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Run-target resolution rows for the parallel worktree-removal gate (issue #690).

.DESCRIPTION
    Covers a parallel and an epic record held only by another worktree, both kinds
    unresolved with the manifest declining or authorizing, an ambiguous target that
    denies before the manifest is consulted, and the fail-closed import guard.

    "Real resolver" rows run the shipped record resolver over the live-root and
    checkpoint-text seams mocked in module scope 'WorktreeRunResolution'; the others mock
    the gate's seam Resolve-ParallelWorktreeGateRunTarget. Both read seams and the manifest
    reader are mocked in every row, so no row reads, creates, or writes a file, reads a
    wall clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
    Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $null }
    Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:Target = '/wt/item-a'
    $script:Command = "git worktree remove $($script:Target)"
    $script:ParallelRecord = '{"route_id":"parallel","items":[{"issue_num":101,"worktree_path":"/wt/item-a","merge_status":"merged"}]}'
    $script:EpicRecord = '{"route_id":"epic","features":[{"feature_folder":"item-a","worktree_path":"/wt/item-a","merge_status":"merged"}]}'

    function ConvertTo-RemovalPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Mock both read seams with fixed text; each argument may be $null.
    function Set-RemovalReadSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $Parallel, [AllowNull()] [string] $Epic)
        $parallelText = $Parallel
        $epicText = $Epic
        Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $parallelText }.GetNewClosure()
        Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { $epicText }.GetNewClosure()
    }

    # Model the live worktrees for the real record resolver.
    function Set-RemovalRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Parallel = @{}, [hashtable] $Epic = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }
}

Describe 'parallel worktree-removal gate run-target resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock -CommandName Test-CleanupWorktreeManifestAuthorizesRemoval -MockWith { $false }
    }

    It 'Y1 allows a removal authorized by a parallel record held only in another worktree' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $script:ParallelRecord }
        Set-RemovalReadSeam -Parallel $script:ParallelRecord -Epic $null

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelWorktreeRemovalGateCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json'
        }
    }

    It 'Y2 allows a removal authorized by an epic record held only in another worktree' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:EpicRecord }
        Set-RemovalReadSeam -Parallel $null -Epic $script:EpicRecord

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ParallelWorktreeRemovalGateEpicCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
        }
    }

    It 'Y3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Parallel $null -Epic $null

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^PARALLEL_WORKTREE_REMOVAL_BLOCKED: '
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'Y4 denies an ambiguous parallel target before consulting the manifest' {
        # Arrange
        $ambiguous = New-WorktreeResolutionFixtureTarget -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        $none = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-ParallelWorktreeGateRunTarget -MockWith { $ambiguous }.GetNewClosure() -ParameterFilter { $Kind -eq 'parallel' }
        Mock -CommandName Resolve-ParallelWorktreeGateRunTarget -MockWith { $none }.GetNewClosure() -ParameterFilter { $Kind -eq 'epic' }
        Set-RemovalReadSeam -Parallel $null -Epic $null

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
        Should -Invoke Test-CleanupWorktreeManifestAuthorizesRemoval -Times 0 -Exactly
    }

    It 'Y5 allows a manifest-authorized removal when neither kind resolves' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Parallel $null -Epic $null
        Mock -CommandName Test-CleanupWorktreeManifestAuthorizesRemoval -MockWith { $true }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'Y6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-RemovalPayload -Command $script:Command
        $script:ParallelWorktreeGateResolutionImportFailure = 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $payload
            $output = @(Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:ParallelWorktreeGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }

    It 'Y7 emits a single leading token when both run kinds are unresolved' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Parallel $null -Epic $null

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $reason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED: ') | Should -BeTrue -Because 'the deny text begins with the gate token'
        ([regex]::Matches($reason, 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:')).Count | Should -Be 1 -Because 'the gate token appears exactly once'
    }
}
