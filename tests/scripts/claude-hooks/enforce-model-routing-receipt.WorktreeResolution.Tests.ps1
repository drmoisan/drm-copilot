#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    model-routing gate matrix over identity-resolved checkpoints (issue #673).

.DESCRIPTION
    Drives the model-routing receipt deterrent through its decision entrypoint for every
    row of the required matrix: the resolved own checkpoint recording and not recording a
    receipt, absent, empty, and unparseable; the sibling-only case; the stale-attempt
    tie-break; and each unresolved target state. Rows labelled "identity" leave the hook's
    resolution seam unmocked and model only worktree liveness, so the real resolver and the
    real checkpoint reader run against committed fixture bytes.

    Every row runs inside a committed fixture root with an explicit working directory. The
    gate's checkpoint read is relative to the process directory before this change, so a
    row that left the directory to the executing process would be measuring the developer's
    tree rather than the fixture it names.

    The presence-only gating contract is preserved and asserted rather than assumed: the
    scope filter still allows a subagent type outside the gated set even when the target is
    unresolvable, and the unresolved-target deny sits between that filter and the checkpoint
    read.

.NOTES
    Schema coupling: the four model-routing fixture checkpoints are minimal objects carrying
    only issue-num and model_routing_receipts, which is all Test-ModelRoutingReceiptPresent
    reads. They are not orchestrator-state checkpoints in the sense REQUIRED_STATE_KEYS in
    .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 defines, and this gate
    never runs the orchestrator-state preflight against them.

    Both expected reason codes come only from the worktree-resolution accessors. No row
    creates, writes, or deletes a file, reads a wall clock, or touches the network.
#>

BeforeAll {
    # The hook is dot-sourced first, then the three library modules are imported without
    # -Force, so the suite binds to whichever module instance the hook already loaded.
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

    $script:SessionRootDir = Get-WorktreeResolutionFixturePath 'model-routing/session-root'
    $script:OwnReceipt = Get-WorktreeResolutionFixturePath 'model-routing/item-own-receipt'
    $script:OwnNoReceipt = Get-WorktreeResolutionFixturePath 'model-routing/item-own-no-receipt'
    $script:StaleReceipt = Get-WorktreeResolutionFixturePath 'model-routing/item-stale-receipt'
    $script:InvalidJson = Get-WorktreeResolutionFixturePath 'shared/item-own-invalid-json'
    $script:EmptyCheckpoint = Get-WorktreeResolutionFixturePath 'shared/item-own-empty'
    $script:NoCheckpoint = Get-WorktreeResolutionFixturePath 'shared/item-no-checkpoint'
    $script:CaptureRoot = ([System.IO.Path]::GetPathRoot($PSScriptRoot) + 'f5-seam-root/mr-capture').Replace([string][char]92, '/')

    $script:P901 = "Plan the change for the item.`nCanonical issue number for this feature is 901. All artifact content, file paths, and cross-references must use this number."
    $script:P902 = "Plan the change for the item.`nCanonical issue number for this feature is 902. All artifact content, file paths, and cross-references must use this number."
    $script:NoIdentityPrompt = 'Plan the change for the item.'
    # The prompt pinned by the archived reproduction control pair. Its only path token is a
    # repository-relative file path to a spec beneath a feature folder, not a folder token.
    $script:PinnedPathPrompt = 'docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md'

    # Return an Agent PreToolUse payload for one subagent type and prompt.
    function New-AgentPayload {
        param(
            [Parameter(Mandatory)] [string] $Prompt,
            [string] $Subagent = 'atomic-planner'
        )
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $Subagent; prompt = $Prompt } } |
                ConvertTo-Json -Depth 5 -Compress)
    }

    # Model worktree liveness for an identity row. The bodies close over local copies because
    # a module-scoped mock body cannot see this scope otherwise.
    function Set-LiveTopology {
        param([string[]] $Live = @(), [string[]] $BranchRoot = @())
        $liveSet = $Live
        $branchSet = $BranchRoot
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith {
            param([string] $SessionRoot, [string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
    }
}

Describe 'enforce-model-routing-receipt.ps1 worktree-resolution matrix' {
    It 'model-routing R1 allows when the resolved own checkpoint records the receipt' {
        # Arrange: two live roots; the issue resolves to the one recording the receipt.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnReceipt)
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present' {
        # Arrange: no mock of the resolver or the checkpoint reader. The prompt carries no
        # identity, so the call returns before any enumeration or file read.
        $payload = New-AgentPayload -Prompt $script:NoIdentityPrompt

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: the sibling receipt sitting at the session root is never the basis.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'model-routing R2 denies with the no-target code when the only signal is a repository-relative path' {
        # Arrange: the prompt is the one pinned by the archived reproduction control pair.
        # Neither a folder token nor a file path is an identity, so the verdict is the same.
        $payload = New-AgentPayload -Prompt $script:PinnedPathPrompt

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'model-routing R3 denies with the blocked reason when the resolved own checkpoint records no receipt' {
        # Arrange: the issue resolves to a worktree whose checkpoint records another agent.
        Set-LiveTopology -Live @($script:OwnNoReceipt)
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: a genuine-absence deny, not a target-resolution one.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R3 denies with the blocked reason when the checkpoint is absent at the resolved target' {
        # Arrange: the branch resolves to a worktree holding no checkpoint at all.
        Set-LiveTopology -Live @($script:NoCheckpoint) -BranchRoot @($script:NoCheckpoint)
        $payload = New-AgentPayload -Prompt 'Plan the change. branch: f5-fixture-own'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: the reader's fail-closed direction is preserved for a $null checkpoint.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt' {
        # Arrange: the sibling at the session root records the receipt and the own worktree
        # does not, so a verdict taken from the session root would wrongly allow.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnNoReceipt)
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R4 selects the branch-named worktree when a stale attempt records the same issue' {
        # Arrange: two live worktrees record issue 901, so the issue alone is ambiguous. The
        # branch names the one without a receipt, which is the stale-attempt tie-break.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:StaleReceipt, $script:OwnNoReceipt) -BranchRoot @($script:OwnNoReceipt)
        $payload = New-AgentPayload -Prompt ("{0}`nbranch: f5-fixture-own" -f $script:P901)

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: the branch-named worktree decides, so the stale attempt's receipt does not.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R5 denies with the no-target code when the prompt names no target' {
        # Arrange: a prompt with neither an issue line nor a branch label.
        $payload = New-AgentPayload -Prompt 'Continue with the work as previously discussed.'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'model-routing R6 allows when the working directory is the item worktree and its own receipt is present' {
        # Arrange: cwd and target coincide, the standalone topology that must be unchanged.
        Set-LiveTopology -Live @($script:OwnReceipt)
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:OwnReceipt -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'model-routing R7 denies with the blocked reason when the resolved checkpoint is unparseable' {
        # Arrange: the branch resolves to a worktree whose checkpoint is not valid JSON.
        Set-LiveTopology -Live @($script:InvalidJson) -BranchRoot @($script:InvalidJson)
        $payload = New-AgentPayload -Prompt 'Plan the change. branch: f5-fixture-own'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R7 denies with the blocked reason when the resolved checkpoint is empty' {
        # Arrange: the branch resolves to a worktree whose checkpoint is zero bytes.
        Set-LiveTopology -Live @($script:EmptyCheckpoint) -BranchRoot @($script:EmptyCheckpoint)
        $payload = New-AgentPayload -Prompt 'Plan the change. branch: f5-fixture-own'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
    }

    It 'model-routing R8 denies with the no-target code when the issue is recorded in no live worktree' {
        # Arrange: issue 902 is recorded by no fixture root.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnReceipt)
        $payload = New-AgentPayload -Prompt $script:P902

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
    }

    It 'model-routing R9 denies with the ambiguity code when the issue and the branch name different worktrees' {
        # Arrange: the branch places the call in the session root, whose checkpoint records a
        # different issue from the one the prompt names.
        Set-LiveTopology -Live @($script:SessionRootDir, $script:OwnReceipt) -BranchRoot @($script:SessionRootDir)
        $payload = New-AgentPayload -Prompt ("{0}`nbranch: f5-fixture-sibling" -f $script:P901)

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:AmbiguityCode)
    }

    It 'model-routing R9 denies with the ambiguity code when two live worktrees record the issue' {
        # Arrange: a stale attempt and the current one both record issue 901, with no branch
        # to break the tie, so the gate refuses rather than choosing.
        Set-LiveTopology -Live @($script:StaleReceipt, $script:OwnNoReceipt)
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:AmbiguityCode)
    }

    It 'model-routing R10 allows a subagent outside the gated set when the target is unresolvable' {
        # Arrange: the orchestrator type is the caller, not a receipt-gated delegate, and the
        # prompt carries no identity at all.
        $payload = New-AgentPayload -Prompt $script:NoIdentityPrompt -Subagent 'orchestrator'

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: the scope filter runs before target resolution, so the unresolved-target
        # deny never converts an out-of-scope delegation into a deny.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'model-routing genuine-absence and target-resolution reason codes never appear in each other''s decisions' {
        # Arrange: one deny per family, produced by the gate rather than asserted as text.
        Set-LiveTopology -Live @($script:OwnNoReceipt)
        $withIdentity = New-AgentPayload -Prompt $script:P901
        $withoutIdentity = New-AgentPayload -Prompt $script:NoIdentityPrompt

        # Act
        $pair = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            @(
                (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $withIdentity),
                (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $withoutIdentity)
            )
        }

        # Assert
        $absenceReason = $pair[0].hookSpecificOutput.permissionDecisionReason
        $resolutionReason = $pair[1].hookSpecificOutput.permissionDecisionReason
        $absenceReason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
        $absenceReason.Contains($script:NoTargetCode) | Should -BeFalse
        $absenceReason.Contains($script:AmbiguityCode) | Should -BeFalse
        $resolutionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode)
        $resolutionReason.Contains('MODEL_ROUTING_RECEIPT_BLOCKED') | Should -BeFalse
    }

    It 'model-routing denies an unresolved <Status> target without reaching the checkpoint read' -ForEach @(
        @{ Status = 'NoTarget' }
        @{ Status = 'Ambiguous' }
    ) {
        # Arrange: the seam is mocked inside this row only, because the function it names does
        # not exist until the model-routing implementation task adds it. The checkpoint reader
        # throws, so reaching it would fail the row rather than pass it.
        $target = New-WorktreeResolutionFixtureTarget -Status $Status
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { return $target }.GetNewClosure()
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { throw 'the checkpoint must not be read' }
        $payload = New-AgentPayload -Prompt $script:NoIdentityPrompt
        $expected = if ($Status -eq 'NoTarget') { $script:NoTargetCode } else { $script:AmbiguityCode }

        # Act
        $decision = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $expected)
        Should -Invoke -CommandName Get-ModelRoutingCheckpoint -Times 0 -Exactly
    }

    It 'model-routing reads the checkpoint at the resolved absolute path for a <Status> target' -ForEach @(
        @{ Status = 'SessionRoot' }
        @{ Status = 'OtherWorktree' }
    ) {
        # Arrange: the seam is mocked inside this row only, for the reason above. The reader
        # captures the path it was given, so the row proves the resolved root reaches it.
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $script:CaptureRoot
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { return $target }.GetNewClosure()
        $script:CapturedCheckpointPath = $null
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith {
            param([string] $CheckpointPath)
            $script:CapturedCheckpointPath = $CheckpointPath
            return $null
        }
        $payload = New-AgentPayload -Prompt $script:P901

        # Act
        $null = Invoke-WorktreeResolutionFixtureCall -WorkingDirectory $script:SessionRootDir -ScriptBlock {
            Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload
        }

        # Assert: both resolved states compose the absolute path, so neither reads a
        # process-directory-relative location.
        $script:CapturedCheckpointPath | Should -Be "$($script:CaptureRoot)/artifacts/orchestration/orchestrator-state.json"
    }
}
