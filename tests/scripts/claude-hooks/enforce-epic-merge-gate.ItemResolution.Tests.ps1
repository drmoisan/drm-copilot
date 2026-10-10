#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Item-worktree resolution and pull request binding of the epic merge gate (issues #850, #788).

.DESCRIPTION
    Covers the per-feature checkpoint read beneath the live worktree whose orchestrator
    checkpoint records the command's pull request number, the unresolved and ambiguous
    item-target denies, the fail-closed import guard for WorktreeItemResolution.psm1, the
    bare command that resolves no item target, and the child-branch binding that requires
    pr_gate.pr_number or a standalone record to name the number.

    Rows marked "item seam unmocked" run the shipped item resolver over the live-root and
    checkpoint-text seams mocked in module scope 'WorktreeItemResolution'; the others mock
    the gate's seam Resolve-EpicMergeGateItemTarget. Every checkpoint read seam is mocked,
    so no row reads, creates, or writes a file, reads a wall clock, starts a process, or
    touches the network. Synthetic roots use the /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-ChildOrchestratorCheckpointContent { $null }
    Mock Get-EpicOrchestratorCheckpointContent { $null }
    Mock Get-ParallelOrchestratorCheckpointContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:SessionId = 'session-850-merge'
    $script:ItemPath = '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json'
    $script:SessionPath = '/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json'
    $script:Standalone = '{"standalone_merge_authorizations":[{"pr_number":812,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/812",' +
    '"issue_num":690,"branch_name":"bug/agent-payload-gates-resolve-session-root-690","authorized_by":"orchestrator",' +
    '"authorized_at":"2026-09-29T21:04:00Z","session_id":"' + $script:SessionId + '",' +
    '"basis":"Standalone merge for #690 after every required check passed."}]}'

    $runNone = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
    Mock -CommandName Resolve-EpicMergeGateRunTarget -MockWith { $runNone }.GetNewClosure()
    Mock -CommandName Get-EpicMergeGateSessionWorktreeRoot -MockWith { '/synthetic-worktrees/session' }

    function ConvertTo-MergePayload {
        param([string] $Command)
        return ([ordered]@{ tool_name = 'Bash'; session_id = $script:SessionId; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Mock the three read seams with fixed text; each argument may be $null.
    function Set-MergeReadSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $Child, [AllowNull()] [string] $Epic, [AllowNull()] [string] $Parallel)
        $childText = $Child
        $epicText = $Epic
        $parallelText = $Parallel
        Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $childText }.GetNewClosure()
        Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $epicText }.GetNewClosure()
        Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $parallelText }.GetNewClosure()
    }

    # Model the live worktrees and the orchestrator checkpoint text the item resolver reads.
    function Set-ItemPrTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Text = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Text.Keys) { $textMap["$root/artifacts/orchestration/orchestrator-state.json"] = $Text[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }
}

Describe 'epic merge gate item-worktree resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'authorizes a standalone merge from the item worktree checkpoint' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a', '/synthetic-worktrees/session') -Text @{ '/synthetic-worktrees/item-a' = $script:Standalone }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null
        $record = $script:Standalone
        Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $record }.GetNewClosure() -ParameterFilter { $Path -eq '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json' }

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json' }
        Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 0 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json' }
    }

    It "does not authorize from a session-root copy of another worktree's checkpoint" {
        # Arrange
        $itemText = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":812}}'
        $record = $script:Standalone
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a', '/synthetic-worktrees/session') -Text @{
            '/synthetic-worktrees/item-a'  = $itemText
            '/synthetic-worktrees/session' = $record
        }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null
        Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $itemText }.GetNewClosure() -ParameterFilter { $Path -eq '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json' }
        Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $record }.GetNewClosure() -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json' }

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith("EPIC_MERGE_GATE_BLOCKED: $($script:AmbiguityCode)") | Should -BeTrue -Because 'two live checkpoints record the number'
    }

    It 'denies an unresolvable item target with the no-target code' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = '{}' }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')
        $reason = $decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: ') | Should -BeTrue
        $reason.Contains($script:NoTargetCode) | Should -BeTrue -Because 'no live checkpoint records the number'
        $reason.Contains('pull request 812 is recorded in pr_gate.pr_number') | Should -BeTrue -Because 'the item detail names the number'
    }

    It 'denies an ambiguous item target with the ambiguity code' {
        # Arrange
        $ambiguous = New-WorktreeResolutionFixtureTarget -Status 'Ambiguous' -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $ambiguous }.GetNewClosure()
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith("EPIC_MERGE_GATE_BLOCKED: $($script:AmbiguityCode)") | Should -BeTrue
    }

    It 'observes module-scoped WorktreeItemResolution mocks' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = '{}' }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $null = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        Should -Invoke Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 1 -Exactly
    }

    It 'does not resolve an item target for a bare merge command' {
        # Arrange
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { throw 'a bare command must not resolve an item target' }
        Set-MergeReadSeam -Child $null -Epic $null -Parallel $null

        # Act
        $null = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge')

        # Assert
        Should -Invoke Resolve-EpicMergeGateItemTarget -Times 0 -Exactly
        Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/session/artifacts/orchestration/orchestrator-state.json' }
    }

    It 'denies a merge when no checkpoint records the pull request number' {
        # Arrange: a session-root read of this text would allow through the unbound child branch.
        $childPassed = '{"epic_mode":true,"step9_status":"passed"}'
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = $childPassed }
        Set-MergeReadSeam -Child $childPassed -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.Contains($script:NoTargetCode) | Should -BeTrue
    }

    It 'denies a merge whose pull request number differs from pr_gate' {
        # Arrange
        $item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/item-a'
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()
        Set-MergeReadSeam -Child '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":811}}' -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('EPIC_MERGE_GATE_BLOCKED:') | Should -BeTrue
    }

    It 're-checks the binding on the checkpoint the gate reads' {
        # Arrange: the resolver is modelled as having matched 812, but the checkpoint read records no binding.
        $item = New-WorktreeResolutionFixtureTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/item-a'
        Mock -CommandName Resolve-EpicMergeGateItemTarget -MockWith { $item }.GetNewClosure()
        Set-MergeReadSeam -Child '{"epic_mode":true,"step9_status":"passed"}' -Epic $null -Parallel $null

        # Act
        $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergePayload -Command 'gh pr merge --merge 812')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'denies naming WorktreeItemResolution.psm1 when its import failed' {
        # Arrange
        $payload = ConvertTo-MergePayload -Command 'gh pr merge --merge 812'
        $script:EpicMergeGateResolutionImportFailure = 'WorktreeItemResolution.psm1'
        try {
            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $payload
        }
        finally {
            $script:EpicMergeGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeItemResolution\.psm1'
    }

    Context 'child checkpoint pull request binding' {
        It 'returns true for a bare command' {
            # Arrange
            $checkpoint = '{"epic_mode":true}' | ConvertFrom-Json

            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $checkpoint -CommandPrNumber $null

            # Assert
            $result | Should -BeTrue
        }

        It 'returns false for a null checkpoint' {
            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $null -CommandPrNumber 812

            # Assert
            $result | Should -BeFalse
        }

        It 'returns the pr_gate equality result' -ForEach @(
            @{ Name = 'equal'; Recorded = 812; Expected = $true }
            @{ Name = 'different'; Recorded = 811; Expected = $false }
        ) {
            # Arrange
            $checkpoint = ('{"pr_gate":{"pr_number":' + $Recorded + '}}') | ConvertFrom-Json

            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $checkpoint -CommandPrNumber 812

            # Assert
            $result | Should -Be $Expected -Because "pr_gate.pr_number is $Name to the command number"
        }

        It 'returns true for a matching positive-integer standalone entry' {
            # Arrange
            $checkpoint = '{"standalone_merge_authorizations":[{"pr_number":812}]}' | ConvertFrom-Json

            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $checkpoint -CommandPrNumber 812

            # Assert
            $result | Should -BeTrue
        }

        It 'returns false for a standalone pr_number that is <Name>' -ForEach @(
            @{ Name = 'string'; Value = '"812"' }
            @{ Name = 'zero'; Value = '0' }
            @{ Name = 'fractional'; Value = '812.5' }
        ) {
            # Arrange
            $checkpoint = ('{"standalone_merge_authorizations":[{"pr_number":' + $Value + '}]}') | ConvertFrom-Json

            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $checkpoint -CommandPrNumber 812

            # Assert
            $result | Should -BeFalse -Because "a standalone pr_number that is $Name is not a positive JSON integer"
        }

        It 'returns false when neither field records the number' {
            # Arrange
            $checkpoint = '{"epic_mode":true,"step9_status":"passed"}' | ConvertFrom-Json

            # Act
            $result = Test-ChildCheckpointPrGateBinding -Checkpoint $checkpoint -CommandPrNumber 812

            # Assert
            $result | Should -BeFalse
        }
    }
}
