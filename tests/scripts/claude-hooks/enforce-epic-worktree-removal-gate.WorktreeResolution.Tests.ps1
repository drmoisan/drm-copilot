#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Run-target resolution rows for the epic worktree-removal gate (issue #690).

.DESCRIPTION
    Covers an epic and a parallel record held only by another worktree, both kinds
    unresolved with the manifest declining or authorizing, an ambiguous target that
    denies before the manifest is consulted, and the fail-closed import guard.

    "Real resolver" rows run the shipped record resolver over the live-root and
    checkpoint-text seams mocked in module scope 'WorktreeRunResolution'; the others mock
    the gate's seam Resolve-EpicWorktreeGateRunTarget. Both read seams and the manifest
    reader are mocked in every row, so no row reads, creates, or writes a file, reads a
    wall clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
    Mock Get-EpicWorktreeGateCheckpointContent { $null }
    Mock Get-EpicWorktreeGateParallelCheckpointContent { $null }
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
    $script:Target = '/wt/child-a'
    $script:Command = "git worktree remove $($script:Target)"
    $script:EpicRecord = '{"route_id":"epic","features":[{"feature_folder":"child-a","worktree_path":"/wt/child-a","merge_status":"merged"}]}'
    $script:ParallelRecord = '{"route_id":"parallel","items":[{"issue_num":101,"worktree_path":"/wt/child-a","merge_status":"merged"}]}'

    function ConvertTo-RemovalPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Mock both read seams with fixed text; each argument may be $null.
    function Set-RemovalReadSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $Epic, [AllowNull()] [string] $Parallel)
        $epicText = $Epic
        $parallelText = $Parallel
        Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { $epicText }.GetNewClosure()
        Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { $parallelText }.GetNewClosure()
    }

    # Model the live worktrees for the real record resolver.
    function Set-RemovalRunTopology {
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
}

Describe 'epic worktree-removal gate run-target resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock -CommandName Test-CleanupWorktreeManifestAuthorizesRemoval -MockWith { $false }
    }

    It 'V1 allows a removal authorized by an epic record held only in another worktree' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:EpicRecord }
        Set-RemovalReadSeam -Epic $script:EpicRecord -Parallel $null

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-EpicWorktreeGateCheckpointContent -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
        }
    }

    It 'V2 allows a removal authorized by a parallel record held only in another worktree' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $script:ParallelRecord }
        Set-RemovalReadSeam -Epic $null -Parallel $script:ParallelRecord

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'V3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-RemovalReadSeam -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED: '
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:NoTargetCode
    }

    It 'V4 denies an ambiguous epic target before consulting the manifest' {
        # Arrange
        $ambiguous = New-WorktreeResolutionFixtureTarget -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        $none = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $ambiguous }.GetNewClosure() -ParameterFilter { $Kind -eq 'epic' }
        Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $none }.GetNewClosure() -ParameterFilter { $Kind -eq 'parallel' }
        Set-RemovalReadSeam -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:AmbiguityCode
        Should -Invoke Test-CleanupWorktreeManifestAuthorizesRemoval -Times 0 -Exactly
    }

    It 'V5 allows a manifest-authorized removal when neither kind resolves' {
        # Arrange
        Set-RemovalRunTopology -Live @('/synthetic-worktrees/w-epic')
        Set-RemovalReadSeam -Epic $null -Parallel $null
        Mock -CommandName Test-CleanupWorktreeManifestAuthorizesRemoval -MockWith { $true }

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'V6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-RemovalPayload -Command $script:Command
        $script:EpicWorktreeGateResolutionImportFailure = 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $payload
            $output = @(Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:EpicWorktreeGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }
}
