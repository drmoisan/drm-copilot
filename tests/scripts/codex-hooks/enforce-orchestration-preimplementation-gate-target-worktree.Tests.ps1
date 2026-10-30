#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree resolution rows for the Codex preimplementation gate (issue #1010).

.DESCRIPTION
    The B rows drive the Codex building blocks in
    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, whose bodies
    are byte-identical to the Claude sibling: the command-operand parser, the recording
    invoker, and the reason-code pair restated from WorktreeResolution.psm1.

    The BeforeAll follows the Codex epic-state isolation pattern: the gate is dot-sourced
    (which loads the resolver twin through the -epic-scope file), then the baseline mocks
    are registered at script scope. The worktree-list wrapper is always mocked with an
    in-memory porcelain listing, so no row starts git. No row creates a file, reads a wall
    clock, or touches the network.
#>

Describe 'Codex gate target-worktree building blocks (issue #1010)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:ItemRoot = '/synthetic-worktrees/w-item'
        $script:OtherRoot = '/synthetic-worktrees/w-other'
        $script:ItemListing = "worktree /synthetic-worktrees/w-item`nbranch refs/heads/feature/item`n"
        $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
        $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:ItemRoot)`nbranch refs/heads/feature/item`n`nworktree $($script:OtherRoot)`nbranch refs/heads/feature/other`n"
        $script:ItemCheckpoint = "$($script:ItemRoot)/artifacts/orchestration/orchestrator-state.json"
        $script:SessionCheckpoint = "$($script:Session)/artifacts/orchestration/orchestrator-state.json"
        $script:ReadyItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":true}'
        $script:UnreadyItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":false}'
        $script:StringFalseItem = '{"issue-num":"1010","feature-folder":"docs/features/active/sample-1010","route_id":"large","lifecycle_ready":"false"}'

        function ConvertTo-MappedToolInput {
            # Return the mapped tool_input JSON the gate's entry tail produces for one leg.
            param([string] $FilePath = '', [string] $Command = '')
            if ($FilePath) { return (@{ file_path = $FilePath } | ConvertTo-Json -Compress) }
            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }

        function ConvertTo-PatchText {
            # Return an apply_patch body with one Update File marker per path.
            param([string[]] $Path)
            $markers = @($Path | ForEach-Object { "*** Update File: $_`n@@`n-old`n+new" })
            return ("*** Begin Patch`n" + ($markers -join "`n") + "`n*** End Patch")
        }

        # Register the three-root listing, a default empty checkpoint body plus per-path
        # bodies, and the epic-scope ascent seam, so no row reads a host checkpoint.
        function Set-TargetFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([AllowNull()][string] $ItemBody = '', [AllowNull()][string] $SessionBody = '')
            $listing = $script:Listing
            $session = $script:Session
            $itemText = [string]$ItemBody
            $sessionText = [string]$SessionBody
            Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
            Mock Find-WorktreeResolutionRoot { $session }.GetNewClosure()
            Mock Get-CheckpointContent { '' }
            Mock Get-CheckpointContent { $itemText }.GetNewClosure() -ParameterFilter { $Path -eq $script:ItemCheckpoint }
            Mock Get-CheckpointContent { $sessionText }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

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

    It 'B9 the Codex reason-code pair equals the WorktreeResolution.psm1 accessors' {
        # Arrange
        $module = Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeResolution.psm1') -PassThru

        # Act
        $ambiguous = & $module { Get-WorktreeResolutionAmbiguityReasonCode }
        $notDerivable = & $module { Get-WorktreeResolutionNoTargetReasonCode }

        # Assert
        $script:OrchestrationGateAmbiguousReasonCode | Should -BeExactly $ambiguous
        $script:OrchestrationGateNotDerivableReasonCode | Should -BeExactly $notDerivable
    }

    It 'C1 admits a mapped <Tool> into an item worktree whose checkpoint is ready, reading the item checkpoint' -ForEach @(
        @{ Tool = 'Write' }
        @{ Tool = 'Edit' }
    ) {
        # Arrange (Write and Edit both map to a file_path record)
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/$Tool.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C2 denies a mapped Write into an item worktree whose checkpoint is absent' {
        # Arrange
        Set-TargetFixture -ItemBody '' -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C3 denies a mapped Write into an item worktree whose checkpoint is not ready' {
        # Arrange
        Set-TargetFixture -ItemBody $script:UnreadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C4 admits git -c k=v -C `<wt`> commit against a ready item checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command "git -c user.name=sample -C $($script:ItemRoot) commit -m message")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C5 reads the item checkpoint for git add with an absolute operand' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command "git add $($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C6 reads the item checkpoint for a later-segment git -C selector' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command "echo start && git -C $($script:ItemRoot) add scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C7 admits an apply_patch whose absolute marker path lies in a ready item worktree, reading the item checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command (ConvertTo-PatchText -Path "$($script:ItemRoot)/scripts/Sample.ps1"))

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C8 denies an apply_patch whose markers lie in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command (ConvertTo-PatchText -Path "$($script:ItemRoot)/A.ps1", "$($script:OtherRoot)/B.ps1"))

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:OrchestrationGateAmbiguousReasonCode
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'C9 reads the session-root checkpoint for a target outside every registered worktree, a relative operand, and no operand (<Label>)' -ForEach @(
        @{ Label = 'outside'; FilePath = '/synthetic-elsewhere/scripts/Sample.ps1'; Command = '' }
        @{ Label = 'relative'; FilePath = ''; Command = 'git add scripts/Sample.ps1' }
        @{ Label = 'none'; FilePath = ''; Command = 'git commit -m message' }
    ) {
        # Arrange
        Set-TargetFixture -ItemBody $script:UnreadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath $FilePath -Command $Command)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C10 denies Bash operands in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command "git add $($script:ItemRoot)/A.ps1 $($script:OtherRoot)/B.ps1")

        # Assert
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -Match $script:OrchestrationGateAmbiguousReasonCode
        $reason | Should -Match 'CommandOperand'
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'C11 denies an absolute Write naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing throws, reading no checkpoint' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Get-OrchestrationGateWorktreeList { throw 'simulated listing failure (issue #1010)' }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:OrchestrationGateNotDerivableReasonCode
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'C12 denies an absolute git -C commit naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing names no worktree' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Get-OrchestrationGateWorktreeList { '' }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command "git -C $($script:ItemRoot) commit -m message")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:OrchestrationGateNotDerivableReasonCode
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'C13 denies a resolver result with no root naming TARGET_WORKTREE_NOT_DERIVABLE' {
        # Arrange
        Set-TargetFixture -ItemBody $script:ReadyItem -SessionBody $script:ReadyItem
        Mock Resolve-HookTargetWorktree { [pscustomobject]@{ WorktreeRoot = $null; Source = 'FilePath'; Ambiguous = $false; ReasonCode = $null; Detail = 'synthetic null root'; Candidates = [string[]]@() } }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match $script:OrchestrationGateNotDerivableReasonCode
        Should -Invoke Get-CheckpointContent -Times 0 -Exactly
    }

    It 'C14 denies an otherwise ready item checkpoint whose lifecycle_ready is the string false' {
        # Arrange
        Set-TargetFixture -ItemBody $script:StringFalseItem -SessionBody $script:ReadyItem

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath "$($script:ItemRoot)/scripts/Sample.ps1")

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemCheckpoint }
    }

    It 'C15 Get-CheckpointContent rejects a relative Path' {
        # Arrange: the real seam, not the baseline mock registered for it
        $seam = Get-Command -Name Get-CheckpointContent -CommandType Function

        # Act / Assert
        { & $seam -Path 'artifacts/orchestration/orchestrator-state.json' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-CheckpointContent'
    }

    It 'C16 denies naming hook-target-worktree.ps1 when its dot-source failed' {
        # Arrange
        Add-HookDependencyFailure -Name 'hook-target-worktree.ps1'
        try {
            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -Command 'git add scripts/Sample.ps1')
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'hook-target-worktree\.ps1'
    }

    It 'C17 the baseline helper intercepts the worktree-list wrapper on the Codex surface' {
        # Arrange: only the checkpoint bodies; the listing comes from the BeforeAll baseline helper
        $ready = $script:ReadyItem
        Mock Get-CheckpointContent { '' }
        Mock Get-CheckpointContent { $ready }.GetNewClosure() -ParameterFilter { $Path -eq $script:SessionCheckpoint }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-MappedToolInput -FilePath '/synthetic-elsewhere/scripts/Sample.ps1')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 1 -Exactly
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SessionCheckpoint }
    }
}
