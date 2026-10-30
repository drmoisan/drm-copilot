#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the Claude preimplementation gate (issue #1010).

.DESCRIPTION
    The B rows drive the building blocks in enforce-orchestration-preimplementation-gate-epic-scope.ps1:
    the command-operand parser Get-OrchestrationGateCommandOperandPath and the recording
    invoker Invoke-OrchestrationGateWorktreeList.

    The outermost BeforeAll follows the epic-state isolation pattern: the hook is
    dot-sourced first, then the baseline mocks are registered so no row reads an epic or
    item checkpoint on the host. The worktree-list wrapper Get-OrchestrationGateWorktreeList
    is always mocked at script scope with an in-memory porcelain listing, so no row starts
    git. No row creates a file, reads a wall clock, or touches the network.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

    $script:ItemRoot = '/synthetic-worktrees/w-item'
    $script:OtherRoot = '/synthetic-worktrees/w-other'
    $script:ItemListing = "worktree /synthetic-worktrees/w-item`nbranch refs/heads/feature/item`n"
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:ItemRoot)`nbranch refs/heads/feature/item`n`nworktree $($script:OtherRoot)`nbranch refs/heads/feature/other`n"
    $script:ItemCheckpoint = Get-WorktreeRunCheckpointPath -Kind 'item' -WorktreeRoot $script:ItemRoot
    $script:SessionCheckpoint = Get-WorktreeRunCheckpointPath -Kind 'item' -WorktreeRoot $script:Session
    $script:ReadyItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":true}'
    $script:UnreadyItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":false}'
    $script:StringFalseItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":"false"}'

    function ConvertTo-ToolPayload {
        param([string] $Tool, [string] $FilePath = '', [string] $Command = '')
        $toolInput = switch ($Tool) {
            'Write' { @{ file_path = $FilePath; content = 'x' } }
            'Edit' { @{ file_path = $FilePath; old_string = 'a'; new_string = 'b' } }
            default { @{ command = $Command } }
        }
        return (@{ tool_name = $Tool; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    # Register the three-root listing, the per-path checkpoint bodies, and the pre-fix
    # ascent seam (session root), so no row reads a host directory or checkpoint.
    function Set-TargetFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()][string] $ItemBody = '', [AllowNull()][string] $SessionBody = '')
        $listing = $script:Listing
        $session = $script:Session
        $itemText = [string]$ItemBody
        $sessionText = [string]$SessionBody
        Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
        Mock Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution { $session }.GetNewClosure()
        Mock Get-CheckpointContent { '' }
        Mock Get-CheckpointContent { $itemText }.GetNewClosure() -ParameterFilter { $Path -eq $script:ItemCheckpoint }
        Mock Get-CheckpointContent { $sessionText }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }
    }
}

Describe 'Claude gate target-worktree building blocks (issue #1010)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'B1 extracts the -C value of git -c k=v -C `<wt`> commit' {
        # Act
        $paths = @(Get-OrchestrationGateCommandOperandPath -Command "git -c user.name=sample -C $($script:ItemRoot) commit -m message")

        # Assert
        $paths | Should -Be @($script:ItemRoot)
    }

    It 'B2 extracts a -C value on a later command segment' {
        # Act
        $paths = @(Get-OrchestrationGateCommandOperandPath -Command "echo start && git -C $($script:ItemRoot) add scripts/Sample.ps1")

        # Assert
        $paths | Should -Be @($script:ItemRoot)
    }

    It 'B3 extracts absolute git add operands and drops relative ones' {
        # Act
        $paths = @(Get-OrchestrationGateCommandOperandPath -Command "git add $($script:ItemRoot)/scripts/A.ps1 scripts/B.ps1 $($script:OtherRoot)/C.ps1")

        # Assert
        $paths | Should -Be @("$($script:ItemRoot)/scripts/A.ps1", "$($script:OtherRoot)/C.ps1")
    }

    It 'B4 returns no path for a git commit with no selector and no absolute operand' {
        # Act
        $paths = @(Get-OrchestrationGateCommandOperandPath -Command 'git commit -m message')

        # Assert
        $paths.Count | Should -Be 0
    }

    It 'B5 returns no path for a -C on a git segment that invokes neither add nor commit' {
        # Act
        $paths = @(Get-OrchestrationGateCommandOperandPath -Command "git -C $($script:ItemRoot) status && git add scripts/Sample.ps1")

        # Assert
        $paths.Count | Should -Be 0
    }

    It 'B6 records no listing failure for a listing with a worktree entry' {
        # Arrange
        $listing = $script:ItemListing
        Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
        $script:OrchestrationGateWorktreeListFailed = $false

        # Act
        $text = Invoke-OrchestrationGateWorktreeList -SessionRoot '/synthetic-worktrees/session'

        # Assert
        $text | Should -BeExactly $listing
        $script:OrchestrationGateWorktreeListFailed | Should -BeFalse
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 1 -Exactly
    }

    It 'B7 records a listing failure and rethrows when the wrapper throws' {
        # Arrange
        Mock Get-OrchestrationGateWorktreeList { throw 'simulated listing failure (issue #1010)' }
        $script:OrchestrationGateWorktreeListFailed = $false

        # Act / Assert
        { Invoke-OrchestrationGateWorktreeList -SessionRoot '/synthetic-worktrees/session' } | Should -Throw '*simulated listing failure*'
        $script:OrchestrationGateWorktreeListFailed | Should -BeTrue
    }

    It 'B8 records a listing failure when the wrapper returns no worktree entry' {
        # Arrange
        Mock Get-OrchestrationGateWorktreeList { '' }
        $script:OrchestrationGateWorktreeListFailed = $false

        # Act
        $text = Invoke-OrchestrationGateWorktreeList -SessionRoot '/synthetic-worktrees/session'

        # Assert
        $text | Should -BeExactly ''
        $script:OrchestrationGateWorktreeListFailed | Should -BeTrue
    }
}

Describe 'Claude gate target-worktree decisions (issue #1010)' {

    It 'T1 admits a <Tool> into an item worktree whose checkpoint is ready, reading the item checkpoint' -ForEach @(
        @{ Tool = 'Write' }
        @{ Tool = 'Edit' }
    ) {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool $Tool -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T2 denies a Write into an item worktree whose checkpoint is absent' {
        # Arrange
        Set-TargetFixture -ItemBody '' -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T3 denies a Write into an item worktree whose checkpoint is not ready' {
        # Arrange
        Set-TargetFixture -ItemBody $script:UnreadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T4 admits git -c k=v -C `<wt`> commit against a ready item checkpoint, reading the item checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command "git -c user.name=sample -C $($script:ItemRoot) commit -m message")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T5 reads the item checkpoint for git add with an absolute operand inside the item worktree' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command "git add $($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T6 reads the item checkpoint for a git -C selector on a later command segment' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command "echo start && git -C $($script:ItemRoot) add scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T7 reads the session-root checkpoint for a target outside every registered worktree, a relative operand, and no operand (<Label>)' -ForEach @(
        @{ Label = 'outside'; Tool = 'Write'; FilePath = '/synthetic-elsewhere/scripts/Sample.ps1'; Command = '' }
        @{ Label = 'relative'; Tool = 'Bash'; FilePath = ''; Command = 'git add scripts/Sample.ps1' }
        @{ Label = 'none'; Tool = 'Bash'; FilePath = ''; Command = 'git commit -m message' }
    ) {
        # Arrange
        Set-TargetFixture -ItemBody $script:UnreadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool $Tool -FilePath $FilePath -Command $Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T8 denies operands in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS and the resolver Source' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command "git add $($script:ItemRoot)/A.ps1 $($script:OtherRoot)/B.ps1")

        # Assert
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -Match (Get-WorktreeResolutionAmbiguityReasonCode)
        $reason | Should -Match 'CommandOperand'
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'T9 denies an absolute Write naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing throws, reading no checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Get-OrchestrationGateWorktreeList { throw 'simulated listing failure (issue #1010)' }

        # Act (relative Write first: it needs no listing and reads the session-root checkpoint)
        $relative = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath 'scripts/Sample.ps1')
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 0 -Exactly
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
        $absolute = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $relative.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $absolute.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $absolute.hookSpecificOutput.permissionDecisionReason | Should -Match (Get-WorktreeResolutionNoTargetReasonCode)
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 1 -Exactly
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly
    }

    It 'T10 denies an absolute git -C commit naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing names no worktree, reading no checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Get-OrchestrationGateWorktreeList { '' }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command "git -C $($script:ItemRoot) commit -m message")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match (Get-WorktreeResolutionNoTargetReasonCode)
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'T11 denies a resolver result with no root naming TARGET_WORKTREE_NOT_DERIVABLE' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Resolve-HookTargetWorktree { [pscustomobject]@{ WorktreeRoot = $null; Source = 'FilePath'; Ambiguous = $false; ReasonCode = $null; Detail = 'synthetic null root'; Candidates = [string[]]@() } }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match (Get-WorktreeResolutionNoTargetReasonCode)
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'T12 denies an otherwise ready item checkpoint whose lifecycle_ready is the string false' {
        # Arrange
        Set-TargetFixture -ItemBody $script:StringFalseItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'T13 denies naming HookTargetWorktree.psm1 when that import failed' {
        # Arrange
        Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1'
        try {
            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Bash' -Command 'git add scripts/Sample.ps1')
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'HookTargetWorktree\.psm1'
    }

    It 'T14 the baseline helper intercepts the worktree-list wrapper for a suite that requests the Get-CheckpointContent baseline' {
        # Arrange: only the checkpoint bodies; the listing comes from the BeforeAll baseline helper
        $ready = $script:ReadyItem
        Mock Get-CheckpointContent { '' }
        Mock Get-CheckpointContent { $ready }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Tool 'Write' -FilePath '/synthetic-elsewhere/scripts/Sample.ps1')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 1 -Exactly
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
    }
}
