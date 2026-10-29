#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Relative worktree_path record tests for Resolve-WorktreeRunTargetByRecord (issue #995).

.DESCRIPTION
    A run checkpoint records items[].worktree_path or features[].worktree_path relative to
    the main checkout, while a removal command names the absolute path. These rows drive the
    shipped record resolver with a relative record held in a non-main live root, and pin the
    unsafe-record, ambiguity, and pull-request-number boundaries.

    The live-root and checkpoint-text seams and Get-WorktreeRunMainCheckoutRoot are mocked
    with -ModuleName 'WorktreeRunResolution'. Synthetic roots use the
    /synthetic-worktrees/<name> form. No test creates or writes a file, reads a wall clock,
    starts a process, or touches the network.
#>

BeforeAll {
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')

    $script:Session = '/synthetic-worktrees/session'
    $script:Main = '/synthetic-worktrees/main'
    $script:Planning = '/synthetic-worktrees/planning'
    $script:Target = '/synthetic-worktrees/main/.claude/worktrees/agent-x'

    # Register the module-scoped seam mocks. Epic and Parallel map a root to the text of
    # that root's epic or parallel checkpoint; MainRoot is what the main-root seam returns.
    function Set-RecordTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Epic = @{}, [hashtable] $Parallel = @{}, [AllowNull()] [string] $MainRoot)
        $liveSet = $Live
        $mainRootValue = $MainRoot
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith {
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution -MockWith { $mainRootValue }.GetNewClosure()
    }

    function Get-ParallelRecordText {
        param([AllowEmptyString()] [string] $WorktreePath)
        return (@{ route_id = 'parallel'; items = @(@{ issue_num = 101; worktree_path = $WorktreePath; merge_status = 'merged'; pr_number = 812 }) } | ConvertTo-Json -Compress -Depth 5)
    }
}

Describe 'Resolve-WorktreeRunTargetByRecord with a relative worktree_path record' {
    It 'RR1 resolves a parallel record relative to the main checkout held in another live root' {
        # Arrange
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Planning = (Get-ParallelRecordText -WorktreePath '.claude/worktrees/agent-x') } -MainRoot $script:Main

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value $script:Target -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Planning
    }

    It 'RR2 resolves an epic features[] record relative to the main checkout' {
        # Arrange
        $epic = '{"route_id":"epic","features":[{"feature_folder":"child-a","worktree_path":".claude/worktrees/agent-x","merge_status":"merged"}]}'
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Epic @{ $script:Planning = $epic } -MainRoot $script:Main

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField worktree_path -Value $script:Target -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Planning
    }

    It 'RR3 resolves a record relative to the root that holds the checkpoint' {
        # Arrange: no main root is derivable, so only the checkpoint's own root can match.
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Planning = (Get-ParallelRecordText -WorktreePath 'wt/agent-y') } -MainRoot $null

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value '/synthetic-worktrees/planning/wt/agent-y' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:Planning
    }

    It 'RR4 resolves NoTarget for the unsafe relative record <Label>' -ForEach @(
        @{ Label = '..'; Recorded = '..'; Value = '/synthetic-worktrees' }
        @{ Label = 'a .. segment'; Recorded = '.claude/../../main/.claude/worktrees/agent-x'; Value = '/synthetic-worktrees/main/.claude/worktrees/agent-x' }
        @{ Label = 'blank'; Recorded = ''; Value = '/synthetic-worktrees/main' }
        @{ Label = 'a colon'; Recorded = 'c:.claude/worktrees/agent-x'; Value = '/synthetic-worktrees/main/c:.claude/worktrees/agent-x' }
    ) {
        # Arrange
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Planning = (Get-ParallelRecordText -WorktreePath $Recorded) } -MainRoot $script:Main

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value $Value -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be (Get-WorktreeResolutionNoTargetReasonCode)
    }

    It 'RR5 resolves Ambiguous when the same relative record is held in two live roots' {
        # Arrange
        $json = Get-ParallelRecordText -WorktreePath '.claude/worktrees/agent-x'
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Main = $json; $script:Planning = $json } -MainRoot $script:Main

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value $script:Target -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be (Get-WorktreeResolutionAmbiguityReasonCode)
    }

    It 'RR6 calls the main-root seam once for a worktree_path lookup across several live roots' {
        # Arrange
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Planning = (Get-ParallelRecordText -WorktreePath '.claude/worktrees/agent-x') } -MainRoot $script:Main

        # Act
        $null = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value $script:Target -SessionRoot $script:Session

        # Assert
        Should -Invoke Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution -Times 1 -Exactly
    }

    It 'RR7 never calls the main-root seam for a pr_number lookup' {
        # Arrange
        Set-RecordTopology -Live @($script:Main, $script:Planning) -Parallel @{ $script:Planning = (Get-ParallelRecordText -WorktreePath '.claude/worktrees/agent-x') } -MainRoot $script:Main

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        Should -Invoke Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }
}
