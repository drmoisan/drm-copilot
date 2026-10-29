#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Relative worktree_path record rows for the parallel worktree-removal gate (issue #995).

.DESCRIPTION
    A parallel run checkpoint records items[].worktree_path relative to the main checkout,
    while the removal command names the absolute path. These rows drive
    Invoke-ParallelWorktreeRemovalGateDecision end to end through the shipped record
    resolver: the checkpoint is held in a planning worktree, the main checkout root is
    supplied by a mock of Get-WorktreeRunMainCheckoutRoot, and the command names the target
    under that root. The allow rows cover merge_status merged and worktree_removed; the deny
    rows cover every unsafe status, a different agent directory, unsafe relative records,
    and an ambiguous checkpoint copy.

    The resolution seams are mocked with -ModuleName 'WorktreeRunResolution', the gate's
    checkpoint seams and Get-WorktreeRunMainCheckoutRoot in script scope, and the manifest
    reader with -ModuleName 'CleanupWorktreeManifest'. A mock of a command that is not yet
    defined is skipped, so the deny rows evaluate the unchanged gate. Synthetic roots use
    the /synthetic-worktrees/<name> form and Join-Path, because this folder also runs in
    the Linux hook-suite job. No row reads, creates, or writes a file, reads a wall clock,
    starts a process, or touches the network.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    # The shipped epic read seam, captured before the baseline mock below replaces it by name.
    $script:ShippedCheckpointReader = ${function:Get-ParallelWorktreeRemovalGateEpicCheckpointContent}
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    # Baseline null mocks for every read seam in the loaded closure (epic-state isolation guard).
    Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
    Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $null }
    Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Get-WorktreeRunMainCheckoutRoot { $null }
    Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }

    $script:Main = '/synthetic-worktrees/main'
    $script:Planning = '/synthetic-worktrees/planning'
    $script:Relative = '.claude/worktrees/agent-x'
    $script:Target = Join-Path -Path $script:Main -ChildPath $script:Relative
    $script:Target = $script:Target.Replace([string][char]92, '/')

    function ConvertTo-RemovalPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    function Get-ItemCheckpointText {
        param([AllowEmptyString()] [string] $WorktreePath, [AllowNull()] [string] $MergeStatus)
        $item = [ordered]@{ issue_num = 101; worktree_path = $WorktreePath }
        if ($null -ne $MergeStatus) { $item.merge_status = $MergeStatus }
        return ([ordered]@{ route_id = 'parallel'; items = @($item) } | ConvertTo-Json -Compress -Depth 5)
    }

    # True when the module-scope session state of a loaded module resolves the command.
    function Test-ModuleScopeCommand {
        param([string] $ModuleName, [string] $CommandName)
        $module = Get-Module -Name $ModuleName | Select-Object -First 1
        if ($null -eq $module) { return $false }
        return [bool] (& $module { param($Name) Get-Command -Name $Name -ErrorAction SilentlyContinue } $CommandName)
    }

    # Model the topology: the live roots, the checkpoint text held by each root, and the
    # main checkout root. The same text feeds the gate's own read seam.
    function Set-RelativeTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([hashtable] $Parallel = @{}, [string[]] $Live = @('/synthetic-worktrees/main', '/synthetic-worktrees/planning'))
        $liveSet = $Live
        $mainRoot = $script:Main
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        if (Test-ModuleScopeCommand -ModuleName WorktreeRunResolution -CommandName Get-WorktreeRunMainCheckoutRoot) {
            Mock -CommandName Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution -MockWith { $mainRoot }.GetNewClosure()
        }
        if (Get-Command -Name Get-WorktreeRunMainCheckoutRoot -ErrorAction SilentlyContinue) {
            Mock -CommandName Get-WorktreeRunMainCheckoutRoot -MockWith { $mainRoot }.GetNewClosure()
        }
        Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { $null }
    }
}

Describe 'parallel worktree-removal gate with a relative worktree_path record' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'RP1 allows removal of the absolute target when the relative record has merge_status <Status>' -ForEach @(
        @{ Status = 'merged' }
        @{ Status = 'worktree_removed' }
    ) {
        # Arrange
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = (Get-ItemCheckpointText -WorktreePath $script:Relative -MergeStatus $Status) }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'RP2 denies when <Label>' -ForEach @(
        @{ Label = 'the relative record has merge_status pr_open'; Recorded = '.claude/worktrees/agent-x'; Status = 'pr_open' }
        @{ Label = 'the relative record has merge_status worktree_created'; Recorded = '.claude/worktrees/agent-x'; Status = 'worktree_created' }
        @{ Label = 'the relative record has no merge_status'; Recorded = '.claude/worktrees/agent-x'; Status = $null }
        @{ Label = 'the relative record names a different agent directory'; Recorded = '.claude/worktrees/agent-y'; Status = 'merged' }
        @{ Label = 'the relative record is ..'; Recorded = '..'; Status = 'merged' }
        @{ Label = 'the relative record is blank'; Recorded = ''; Status = 'merged' }
    ) {
        # Arrange
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = (Get-ItemCheckpointText -WorktreePath $Recorded -MergeStatus $Status) }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RP3 denies when the same merged relative record is held in both live roots (ambiguous)' {
        # Arrange
        $text = Get-ItemCheckpointText -WorktreePath $script:Relative -MergeStatus 'merged'
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/main' = $text; '/synthetic-worktrees/planning' = $text }

        # Act
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PARALLEL_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RP4 finds a relative epic features[] record through Find-ParallelWorktreeItemRecord -BaseRoot' {
        # Arrange
        $checkpoint = '{"route_id":"epic","features":[{"feature_folder":"child-a","worktree_path":".claude/worktrees/agent-x","merge_status":"merged"}]}' | ConvertFrom-Json

        # Act
        $record = Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath $script:Target -RecordArrayName 'features' -BaseRoot @($script:Main, $script:Planning)

        # Assert
        $record | Should -Not -BeNullOrEmpty
        $record.feature_folder | Should -Be 'child-a'
    }

    It 'RP5 returns no text from the shipped epic checkpoint reader when the checkpoint file is absent' {
        # Arrange: the file-system probe is mocked, so no file is read.
        Mock -CommandName Test-Path -MockWith { $false }
        Mock -CommandName Get-Content -MockWith { 'unexpected' }

        # Act
        $text = & $script:ShippedCheckpointReader -Path '/synthetic-worktrees/planning/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -BeNullOrEmpty
        Should -Invoke -CommandName Get-Content -Times 0 -Exactly
    }

    It 'RP6 returns the checkpoint text from the shipped epic checkpoint reader when the file is present' {
        # Arrange: both the probe and the read are mocked, so no file is read.
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Content -MockWith { '{"route_id":"epic"}' }

        # Act
        $text = & $script:ShippedCheckpointReader -Path '/synthetic-worktrees/planning/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -Be '{"route_id":"epic"}'
    }
}
