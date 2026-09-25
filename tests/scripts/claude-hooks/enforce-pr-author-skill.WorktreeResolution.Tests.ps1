#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    pr-author gate matrix over identity-resolved checkpoints (issue #673).

.DESCRIPTION
    Drives the pr-author gate through its production entrypoint for every row of the
    required matrix: the resolved own checkpoint ready and not ready, absent, empty, and
    unparseable; the sibling-only case; the epic base-branch verdict; and each unresolved
    target state. Rows labelled "identity" leave the hook's resolution seam unmocked and
    model only worktree liveness, so the real resolver and the real checkpoint reader run
    against committed fixture bytes. Rows labelled "seam" mock Resolve-PrAuthorWorktreeTarget
    to state a resolution outcome directly.

    Every row runs inside a committed fixture root through Invoke-WorktreeResolutionFixtureCall
    with an explicit working directory. That is required rather than tidy: the gate reads
    artifacts/pr_body_<N>.receipt.json, artifacts/pr_body_<N>.md, and the last-write time of
    artifacts/pr_context.summary.txt relative to the process directory, so a row that left
    the directory to the executing process would pass in a development worktree holding a
    root-level artifacts/ tree and fail on a clean checkout, before reaching its subject.

    No row mocks Get-PrContextArtifactExistence, Get-PrAuthorReceiptContent,
    Get-PrBodyFileBytes, or Get-PrContextSummaryLastWriteUtc, and no row supplies the
    context-existence flag to the bypass-reason function directly. The committed fixtures
    remove the need, and entering through the production entrypoint is what exercises the
    Case C branch rather than bypassing it.

.NOTES
    Schema coupling: the four pr-author fixture checkpoints must keep satisfying
    Invoke-OrchestratorStatePreflight in the states these rows require. That function reads
    the key set named by REQUIRED_STATE_KEYS in
    .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1, so a change to
    either the key set or the step-status rules can make a row fail on a preflight reason
    rather than on the behaviour it asserts.

    Both expected reason codes come only from the worktree-resolution accessors. No row
    creates, writes, or deletes a file, reads a wall clock, or touches the network.
#>

BeforeAll {
    # The hook is dot-sourced first, then the three library modules are imported without
    # -Force, so the suite binds to whichever module instance the hook already loaded.
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-pr-author-skill.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

    $script:SessionRootDir = Get-WorktreeResolutionFixturePath 'pr-author/session-root'
    $script:OwnReady = Get-WorktreeResolutionFixturePath 'pr-author/item-own-ready'
    $script:OwnNotReady = Get-WorktreeResolutionFixturePath 'pr-author/item-own-not-ready'
    $script:OwnEpicMode = Get-WorktreeResolutionFixturePath 'pr-author/item-own-epic-mode'
    $script:InvalidJson = Get-WorktreeResolutionFixturePath 'shared/item-own-invalid-json'
    $script:EmptyCheckpoint = Get-WorktreeResolutionFixturePath 'shared/item-own-empty'
    $script:NoCheckpoint = Get-WorktreeResolutionFixturePath 'shared/item-no-checkpoint'
    $script:CaptureRoot = ([System.IO.Path]::GetPathRoot($PSScriptRoot) + 'f5-seam-root/capture').Replace([string][char]92, '/')

    $script:BodyCommand = 'gh pr create --title "B" --body-file artifacts/pr_body_1.md'
    $script:OwnBranchCommand = 'gh pr create --head f5-fixture-own --title "B" --body-file artifacts/pr_body_1.md'

    # Return a Bash PreToolUse payload carrying one command string.
    function New-BashPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Command)
        return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
    }

    # Model worktree liveness for an identity row. BranchRoot is what the seam reports under
    # a branch filter and Live what it reports without one; the bodies close over local
    # copies because a module-scoped mock body cannot see this scope otherwise.
    function Set-LiveTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [string[]] $BranchRoot = @())
        $liveSet = $Live
        $branchSet = $BranchRoot
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
    }

    # Mock the hook's resolution seam to state one resolution outcome directly. The result is
    # built here and the closure captures the finished object, rather than calling the builder
    # from inside the mock body: GetNewClosure re-binds the body to a synthetic module scope
    # that cannot resolve a function defined in this dot-sourced scope.
    function Set-ResolvedSeam {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Status, [string] $WorktreeRoot, [string[]] $Candidate = @())
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate $Candidate
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { return $target }.GetNewClosure()
    }
}

Describe 'enforce-pr-author-skill.ps1 worktree-resolution matrix' {
    It 'pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root' {
        # Arrange: the seam resolves to the own ready worktree while the row runs in the sibling.
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:OwnReady
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: the verdict comes from the resolved checkpoint, not the session root's.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root' {
        # Arrange: identity only. The branch is live in the own ready worktree alone.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnReady) -BranchRoot @($script:OwnReady)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present' {
        # Arrange: no mock of the resolver, the checkpoint readers, or the artifact seams. The
        # command names no branch, so the call carries no identity and returns before any read.
        $payload = New-BashPayload -Command $script:BodyCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: the sibling checkpoint sitting at the session root is never the basis.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready' {
        # Arrange: the branch resolves to a worktree whose own checkpoint is not PR-ready.
        Set-LiveTopology -Live @($script:OwnNotReady) -BranchRoot @($script:OwnNotReady)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: a genuine-absence deny, carrying neither target-resolution code.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target' {
        # Arrange: the branch resolves to a worktree that holds no checkpoint at all.
        Set-LiveTopology -Live @($script:NoCheckpoint) -BranchRoot @($script:NoCheckpoint)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready' {
        # Arrange: both checkpoints are live. The sibling is ready; the branch names the one
        # that is not, so a verdict taken from the sibling would wrongly allow.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnNotReady) -BranchRoot @($script:OwnNotReady)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present' {
        # Arrange: the working directory is stated rather than defaulted, because this row is
        # the direct fail-before evidence for the epic base-branch binding and is the one row
        # that must traverse checks 1 to 5 to reach check 6. The resolved worktree carries no
        # artifact files, so the receipt, body, and context bytes come from the working
        # directory while the epic verdict comes from the resolved checkpoint.
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:OwnEpicMode
        $payload = New-BashPayload -Command 'gh pr create --head f5-fixture-own --base main --title "B" --body-file artifacts/pr_body_1.md'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: the resolved checkpoint is under epic mode and names a different integration
        # branch, so --base main is a mismatch. Reading the session root's checkpoint instead
        # would find no epic mode and allow.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_BASE_BRANCH_MISMATCH*'
    }

    It 'pr-author R5 denies with the no-target code when the command names no target' {
        # Arrange: the working directory is stated rather than defaulted so this row stays
        # distinct from R2. This root holds the context summary and no checkpoint at all, so
        # Case C is satisfied and the deny cannot come from a checkpoint the row did not mean
        # to consult. No identity is present, so checks 2 to 5 are never reached and the root's
        # lack of a body file and receipt is immaterial.
        $payload = New-BashPayload -Command $script:BodyCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:NoCheckpoint -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready' {
        # Arrange: cwd and target coincide, which is the standalone topology the spec requires
        # to behave exactly as before.
        Set-ResolvedSeam -Status 'SessionRoot' -WorktreeRoot $script:OwnReady
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:OwnReady -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable' {
        # Arrange: the branch resolves to a worktree whose checkpoint is not valid JSON.
        Set-LiveTopology -Live @($script:InvalidJson) -BranchRoot @($script:InvalidJson)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: fail closed on unreadable state, not fall back to the session root.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'pr-author R7 denies with the preflight reason when the resolved checkpoint is empty' {
        # Arrange: the branch resolves to a worktree whose checkpoint is zero bytes.
        Set-LiveTopology -Live @($script:EmptyCheckpoint) -BranchRoot @($script:EmptyCheckpoint)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
    }

    It 'pr-author R8 denies with the no-target code when the branch is checked out in no live worktree' {
        # Arrange: the branch filter matches nothing, so the identity places the call nowhere.
        Set-LiveTopology -Live @($script:SessionRootDir) -BranchRoot @()
        $payload = New-BashPayload -Command 'gh pr create --head f5-fixture-missing --title "B" --body-file artifacts/pr_body_1.md'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'pr-author R9 denies with the ambiguity code when the branch is checked out in two live worktrees' {
        # Arrange: the branch filter reports two live roots, which git cannot produce but a
        # stale administrative registration can, and which the gate must not choose between.
        Set-LiveTopology -Live @($script:OwnReady, $script:OwnNotReady) -BranchRoot @($script:OwnReady, $script:OwnNotReady)
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:AmbiguityCode)
    }

    It 'pr-author R10 allows a command that is not a gated gh pr invocation when the target is unresolvable' {
        # Arrange: a command outside the gate's scope filter, carrying no identity at all.
        $payload = New-BashPayload -Command 'git status --porcelain'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: the scope filter runs before target resolution, so an unresolvable target
        # never converts an out-of-scope command into a deny.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'pr-author genuine-absence and target-resolution reason codes never appear in each other''s decisions' {
        # Arrange: one deny per family, produced by the gate rather than asserted as text.
        Set-LiveTopology -Live @($script:OwnNotReady) -BranchRoot @($script:OwnNotReady)
        $withIdentity = New-BashPayload -Command $script:OwnBranchCommand
        $withoutIdentity = New-BashPayload -Command $script:BodyCommand

        # Act
        $pair = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            @(
                (Invoke-PrAuthorSkillDecision -ToolInputRaw $withIdentity),
                (Invoke-PrAuthorSkillDecision -ToolInputRaw $withoutIdentity)
            )
        }

        # Assert: the absence deny carries neither resolution code, and the resolution deny
        # carries no absence reason, so the two families cannot be confused in a report.
        $absenceReason = $pair[0].hookSpecificOutput.permissionDecisionReason
        $resolutionReason = $pair[1].hookSpecificOutput.permissionDecisionReason
        $absenceReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
        $absenceReason.Contains($script:NoTargetCode) | Should -BeFalse
        $absenceReason.Contains($script:AmbiguityCode) | Should -BeFalse
        $resolutionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
        $resolutionReason.Contains('ORCHESTRATOR_STATE_PREFLIGHT_FAILED') | Should -BeFalse
    }

    It 'pr-author denies an unresolved <Status> target without reaching the orchestrator-state preflight' -ForEach @(
        @{ Status = 'NoTarget' }
        @{ Status = 'Ambiguous' }
    ) {
        # Arrange: the preflight throws, so reaching it would fail the row rather than pass it.
        Set-ResolvedSeam -Status $Status
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the preflight must not be reached' }
        $payload = New-BashPayload -Command $script:OwnBranchCommand
        $expected = if ($Status -eq 'NoTarget') { $script:NoTargetCode } else { $script:AmbiguityCode }

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: the deny sits before the preflight, so the gate refuses to answer rather
        # than answering from state it could not attribute.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $expected)
        Should -Invoke -CommandName Invoke-OrchestratorStatePreflight -Times 0 -Exactly
    }

    It 'pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check' {
        # Arrange: both readers capture the path they were given, so the row proves the two
        # checks agree rather than merely that each succeeded.
        Set-ResolvedSeam -Status 'OtherWorktree' -WorktreeRoot $script:CaptureRoot
        $script:CapturedPreflightPath = $null
        $script:CapturedEpicPath = $null
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedPreflightPath = $CheckpointPath
            return @{ HasErrors = $false; ErrorText = '' }
        }
        Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedEpicPath = $CheckpointPath
            return $null
        }
        $payload = New-BashPayload -Command $script:OwnBranchCommand

        # Act
        $null = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        }

        # Assert: one resolved absolute path reaches both readers.
        $expected = "$($script:CaptureRoot)/artifacts/orchestration/orchestrator-state.json"
        $script:CapturedPreflightPath | Should -Be $expected
        $script:CapturedEpicPath | Should -Be $expected
    }
}
