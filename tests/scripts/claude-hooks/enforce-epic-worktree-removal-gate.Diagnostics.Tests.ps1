#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Deny diagnostics and the single leading token of the epic worktree-removal gate (issues #789, #851).

.DESCRIPTION
    Covers the final deny's single EPIC_WORKTREE_REMOVAL_BLOCKED token, the diagnostics
    clause that names each run kind's status, checkpoint path, and matched record, the
    Path property of the read result, and the purity of the diagnostics builder.

    The rows mock the gate's resolution seam Resolve-EpicWorktreeGateRunTarget rather
    than run the record resolver, because the resolver resolves a kind only when its
    checkpoint records the target, while the "no record matched" and "unparseable"
    outcomes arise when the gate's second read differs from the resolver's first. Both
    read seams and the manifest reader are mocked in every row, so no row reads, creates,
    or writes a file, reads a wall clock, starts a process, or touches the network.
    Synthetic roots use the /synthetic-worktrees/<name> form.
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

    $script:Target = '/wt/item-a'
    $script:Command = "git worktree remove $($script:Target)"
    $script:EpicPath = '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
    $script:ParallelPath = '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json'

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

    # Mock the gate's resolution seam once per run kind with a fixed target result.
    function Set-RunTargetSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [pscustomobject] $Epic, [Parameter(Mandatory)] [pscustomobject] $Parallel)
        $epicTarget = $Epic
        $parallelTarget = $Parallel
        Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $epicTarget }.GetNewClosure() -ParameterFilter { $Kind -eq 'epic' }
        Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $parallelTarget }.GetNewClosure() -ParameterFilter { $Kind -eq 'parallel' }
    }
}

Describe 'epic worktree-removal gate deny diagnostics' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock -CommandName Test-CleanupWorktreeManifestAuthorizesRemoval -MockWith { $false }
    }

    It 'emits a single leading token when both run kinds are unresolved' {
        # Arrange
        Set-RunTargetSeam -Epic (New-WorktreeResolutionFixtureTarget -Status 'NoTarget') -Parallel (New-WorktreeResolutionFixtureTarget -Status 'NoTarget')
        Set-RemovalReadSeam -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith('EPIC_WORKTREE_REMOVAL_BLOCKED: ') | Should -BeTrue -Because 'the deny text begins with the gate token'
        ([regex]::Matches($reason, 'EPIC_WORKTREE_REMOVAL_BLOCKED:')).Count | Should -Be 1 -Because 'the gate token appears exactly once'
    }

    It "names each run kind's status and checkpoint path" {
        # Arrange
        Set-RunTargetSeam -Epic (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic') `
            -Parallel (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Epic '{"features":[{"worktree_path":"/wt/item-a","merge_status":"pr_open"}]}' -Parallel '{"route_id":"parallel","items":[]}'

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.Contains("epic run OtherWorktree (checkpoint '$($script:EpicPath)')") | Should -BeTrue -Because 'the clause names the epic status and checkpoint path'
        $reason.Contains("parallel run OtherWorktree (checkpoint '$($script:ParallelPath)')") | Should -BeTrue -Because 'the clause names the parallel status and checkpoint path'
    }

    It 'names the matched record merge_status' {
        # Arrange
        Set-RunTargetSeam -Epic (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic') `
            -Parallel (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Epic '{"features":[{"worktree_path":"/wt/item-a","merge_status":"pr_open"}]}' -Parallel '{"route_id":"parallel","items":[]}'

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason.Contains("merge_status 'pr_open'") | Should -BeTrue -Because 'the clause names the matched features[] record merge_status'
    }

    It 'states that no record matched' {
        # Arrange
        Set-RunTargetSeam -Epic (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic') `
            -Parallel (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-par')
        Set-RemovalReadSeam -Epic '{"features":[{"worktree_path":"/wt/item-a","merge_status":"pr_open"}]}' -Parallel '{"route_id":"parallel","items":[]}'

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason.Contains('no matching items[] record') | Should -BeTrue -Because 'the parallel checkpoint records no items[] entry for the target'
    }

    It 'states that the checkpoint was absent or unparseable' {
        # Arrange
        Set-RunTargetSeam -Epic (New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic') `
            -Parallel (New-WorktreeResolutionFixtureTarget -Status 'NoTarget')
        Set-RemovalReadSeam -Epic '{ broken json' -Parallel $null

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command $script:Command)
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.Contains('checkpoint absent or unparseable') | Should -BeTrue -Because 'the epic checkpoint text does not parse'
        $reason.Contains('parallel run NoTarget (no checkpoint read), not evaluated') | Should -BeTrue -Because 'an unresolved kind reads no checkpoint'
    }

    Context 'diagnostics builder and read result' {
        It 'returns the checkpoint path it read on the read result' {
            # Arrange
            $resolved = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic'
            Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $resolved }.GetNewClosure()
            Set-RemovalReadSeam -Epic $null -Parallel $null

            # Act
            $read = Read-EpicWorktreeGateRunCheckpoint -Kind epic -WorktreePath '/wt/item-a'

            # Assert
            $read.Path | Should -Be $script:EpicPath
        }

        It 'returns a null path when the target is unresolved' {
            # Arrange
            $unresolved = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
            Mock -CommandName Resolve-EpicWorktreeGateRunTarget -MockWith { $unresolved }.GetNewClosure()
            Set-RemovalReadSeam -Epic $null -Parallel $null

            # Act
            $read = Read-EpicWorktreeGateRunCheckpoint -Kind epic -WorktreePath '/wt/item-a'

            # Assert
            @($read.PSObject.Properties.Name) | Should -Contain 'Path'
            $read.Path | Should -BeNullOrEmpty
            $null -eq $read.Path | Should -BeTrue -Because 'an unresolved target composes no checkpoint path'
        }

        It 'builds the clause without reading any file' {
            # Arrange
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { throw 'the epic read seam must not be called' }
            Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { throw 'the parallel read seam must not be called' }
            $epicRead = [pscustomobject]@{
                Target     = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-epic'
                Checkpoint = ('{"features":[{"worktree_path":"/wt/item-a","merge_status":"merged"}]}' | ConvertFrom-Json)
                Path       = $script:EpicPath
            }
            $parallelRead = [pscustomobject]@{
                Target     = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
                Checkpoint = $null
                Path       = $null
            }
            $expected = "Diagnostics: epic run OtherWorktree (checkpoint '$($script:EpicPath)'), merge_status 'merged'; parallel run NoTarget (no checkpoint read), not evaluated."

            # Act
            $clause = Get-EpicWorktreeGateDenyDiagnostics -EpicRead $epicRead -ParallelRead $parallelRead -WorktreePath '/wt/item-a'

            # Assert
            $clause | Should -BeExactly $expected
            Should -Invoke Get-EpicWorktreeGateCheckpointContent -Times 0 -Exactly
            Should -Invoke Get-EpicWorktreeGateParallelCheckpointContent -Times 0 -Exactly
        }
    }
}
