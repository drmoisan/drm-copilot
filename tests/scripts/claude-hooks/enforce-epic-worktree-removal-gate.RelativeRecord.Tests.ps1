#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Relative worktree_path record rows for the epic worktree-removal gate (issue #995).

.DESCRIPTION
    A run checkpoint records worktree_path relative to the main checkout, while the
    removal command names the absolute path. These rows drive
    Invoke-EpicWorktreeRemovalGateDecision end to end through the shipped record resolver
    for both of the gate's branches: a parallel item (Test-ParallelCheckpointAllowsWorktreeRemoval)
    and an epic feature (Find-EpicWorktreeFeatureRecord). The checkpoint is held in a
    planning worktree and the main checkout root is supplied by a mock of
    Get-WorktreeRunMainCheckoutRoot. A diagnostics row calls
    Get-EpicWorktreeGateDenyDiagnostics directly for a relative pr_open record.

    The resolution seams are mocked with -ModuleName 'WorktreeRunResolution', the gate's
    checkpoint seams and Get-WorktreeRunMainCheckoutRoot in script scope, and the manifest
    reader with -ModuleName 'CleanupWorktreeManifest'. A mock of a command that is not yet
    defined is skipped, so the deny rows evaluate the unchanged gate. Synthetic roots use
    the /synthetic-worktrees/<name> form and Join-Path, because this folder also runs in
    the Linux hook-suite job. No row reads, creates, or writes a file, reads a wall clock,
    starts a process, or touches the network.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    # Baseline null mocks for every read seam in the loaded closure (epic-state isolation guard).
    Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
    Mock Get-EpicWorktreeGateCheckpointContent { $null }
    Mock Get-EpicWorktreeGateParallelCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Get-WorktreeRunMainCheckoutRoot { $null }
    Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }

    $script:Main = '/synthetic-worktrees/main'
    $script:Planning = '/synthetic-worktrees/planning'
    $script:Relative = '.claude/worktrees/agent-x'
    $script:Target = (Join-Path -Path $script:Main -ChildPath $script:Relative).Replace([string][char]92, '/')

    function ConvertTo-RemovalPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # One run checkpoint holding a single record. Kind parallel writes items[], epic writes features[].
    function Get-RunCheckpointText {
        param([ValidateSet('epic', 'parallel')] [string] $Kind, [AllowEmptyString()] [string] $WorktreePath, [AllowNull()] [string] $MergeStatus)
        $record = [ordered]@{ worktree_path = $WorktreePath }
        if ($Kind -eq 'parallel') { $record.issue_num = 101 } else { $record.feature_folder = 'child-a' }
        if ($null -ne $MergeStatus) { $record.merge_status = $MergeStatus }
        $document = if ($Kind -eq 'parallel') { [ordered]@{ route_id = 'parallel'; items = @($record) } } else { [ordered]@{ route_id = 'epic'; features = @($record) } }
        return ($document | ConvertTo-Json -Compress -Depth 5)
    }

    # True when the module-scope session state of a loaded module resolves the command.
    function Test-ModuleScopeCommand {
        param([string] $ModuleName, [string] $CommandName)
        $module = Get-Module -Name $ModuleName | Select-Object -First 1
        if ($null -eq $module) { return $false }
        return [bool] (& $module { param($Name) Get-Command -Name $Name -ErrorAction SilentlyContinue } $CommandName)
    }

    # Model the topology: live roots, the epic and parallel checkpoint text each root
    # holds, and the main checkout root. The same text feeds the gate's own read seams.
    function Set-RelativeTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([hashtable] $Epic = @{}, [hashtable] $Parallel = @{}, [string[]] $Live = @('/synthetic-worktrees/main', '/synthetic-worktrees/planning'))
        $liveSet = $Live
        $mainRoot = $script:Main
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
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
        $reader = {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith $reader
        Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith $reader
    }
}

Describe 'epic worktree-removal gate with a relative worktree_path record' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'RE1 allows removal through the <Kind> branch when the relative record has merge_status <Status>' -ForEach @(
        @{ Kind = 'parallel'; Status = 'merged' }
        @{ Kind = 'parallel'; Status = 'worktree_removed' }
        @{ Kind = 'epic'; Status = 'merged' }
        @{ Kind = 'epic'; Status = 'worktree_removed' }
    ) {
        # Arrange
        $text = Get-RunCheckpointText -Kind $Kind -WorktreePath $script:Relative -MergeStatus $Status
        if ($Kind -eq 'parallel') { Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = $text } }
        else { Set-RelativeTopology -Epic @{ '/synthetic-worktrees/planning' = $text } }

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'RE2 denies the parallel-item branch when <Label>' -ForEach @(
        @{ Label = 'the relative record has merge_status pr_open'; Recorded = '.claude/worktrees/agent-x'; Status = 'pr_open' }
        @{ Label = 'the relative record has merge_status worktree_created'; Recorded = '.claude/worktrees/agent-x'; Status = 'worktree_created' }
        @{ Label = 'the relative record has no merge_status'; Recorded = '.claude/worktrees/agent-x'; Status = $null }
        @{ Label = 'the relative record names a different agent directory'; Recorded = '.claude/worktrees/agent-y'; Status = 'merged' }
        @{ Label = 'the relative record is ..'; Recorded = '..'; Status = 'merged' }
        @{ Label = 'the relative record is blank'; Recorded = ''; Status = 'merged' }
    ) {
        # Arrange
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/planning' = (Get-RunCheckpointText -Kind parallel -WorktreePath $Recorded -MergeStatus $Status) }

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('EPIC_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RE3 denies when the same merged relative parallel record is held in both live roots (ambiguous)' {
        # Arrange
        $text = Get-RunCheckpointText -Kind parallel -WorktreePath $script:Relative -MergeStatus 'merged'
        Set-RelativeTopology -Parallel @{ '/synthetic-worktrees/main' = $text; '/synthetic-worktrees/planning' = $text }

        # Act
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RemovalPayload -Command "git worktree remove $($script:Target)")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('EPIC_WORKTREE_REMOVAL_BLOCKED') | Should -BeTrue
    }

    It 'RE4 names the relative pr_open parallel record in the deny diagnostics' {
        # Arrange
        $parallelCheckpoint = (Get-RunCheckpointText -Kind parallel -WorktreePath $script:Relative -MergeStatus 'pr_open') | ConvertFrom-Json
        $parallelRead = [pscustomobject]@{
            Target     = [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:Planning }
            Checkpoint = $parallelCheckpoint
            Path       = '/synthetic-worktrees/planning/artifacts/orchestration/parallel-orchestrator-state.json'
        }
        $epicRead = [pscustomobject]@{ Target = [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null }; Checkpoint = $null; Path = $null }

        # Act
        $diagnostics = Get-EpicWorktreeGateDenyDiagnostics -EpicRead $epicRead -ParallelRead $parallelRead -WorktreePath $script:Target -MainRoot $script:Main

        # Assert
        $diagnostics | Should -Match "parallel run OtherWorktree .*merge_status 'pr_open'"
    }
}
