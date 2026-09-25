#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    model-routing gate 3 epic-scope rows (issue #663).

.DESCRIPTION
    Drives Invoke-ModelRoutingReceiptDecision for an Agent(pr-author) delegation. When the
    delegation prompt's branch label equals the epic checkpoint's integration_branch, the
    receipt is looked up in artifacts/orchestration/epic-orchestrator-state.json and the
    per-feature identity resolution does not run. Any other branch leaves the delegation on
    the unchanged per-feature path.

    The hook is dot-sourced first and EpicScopeResolution.psm1 is imported without -Force,
    so the suite binds to the module instance the hook loaded. The epic checkpoint read and
    the worktree ascent are mocked inside that module; the ascent maps the session root to
    the synthetic root /synthetic-worktrees/epic-coordinator, so no host path reaches a
    checkpoint path or an assertion. The per-feature resolution seam and checkpoint reader
    are mocked so their invocation counts prove which path ran. No row creates a file or
    changes the working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
    $script:EpicPrompt = "Open the integration pull request for the sample epic.`nbranch: epic/sample-epic-integration"
    $script:FeaturePrompt = "Open the pull request for the item.`nCanonical issue number for this feature is 901. All artifact content, file paths, and cross-references must use this number.`nbranch: feature/standalone-item"

    # Return an Agent PreToolUse payload for one subagent type and prompt.
    function New-AgentPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param(
            [Parameter(Mandatory)] [string] $Prompt,
            [string] $Subagent = 'pr-author'
        )
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $Subagent; prompt = $Prompt } } |
                ConvertTo-Json -Depth 5 -Compress)
    }

    function Set-EpicCheckpointSeam {
        <#
            Mock the epic checkpoint read and the worktree ascent inside EpicScopeResolution.
            The body closes over a local copy because a module-scoped mock body cannot see
            this scope otherwise.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $Text)
        $checkpointText = $Text
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/synthetic-worktrees/*') { return $Path }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $checkpointText }.GetNewClosure()
    }

    function Set-FeatureCheckpointSeam {
        <#
            Mock the per-feature resolution to a resolved session-root target and the
            per-feature checkpoint reader to the supplied object.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [object] $Checkpoint)
        $featureCheckpoint = $Checkpoint
        $target = New-WorktreeResolutionFixtureTarget -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/epic-coordinator'
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { $target }.GetNewClosure()
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { $featureCheckpoint }.GetNewClosure()
    }
}

Describe 'enforce-model-routing-receipt.ps1 epic scope (issue #663)' {
    BeforeEach {
        # Default per-feature seams: a NoTarget resolution and no checkpoint. Their invocation
        # counts show whether the per-feature path ran.
        $noTarget = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { $noTarget }.GetNewClosure()
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { $null }
    }

    It 'epic scope allows Agent(pr-author) when the epic checkpoint records a pr-author receipt' {
        # Arrange
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        $payload = New-AgentPayload -Prompt $script:EpicPrompt

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert: allowed from the epic checkpoint alone; the per-feature resolution never ran.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the epic checkpoint records a pr-author routing receipt'
        Should -Invoke Resolve-ModelRoutingWorktreeTarget -Times 0 -Exactly
        Should -Invoke Get-ModelRoutingCheckpoint -Times 0 -Exactly
    }

    It 'epic scope denies Agent(pr-author) with MODEL_ROUTING_RECEIPT_BLOCKED when the epic checkpoint has no pr-author receipt' {
        # Arrange: the ready checkpoint with its receipt array emptied.
        $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
        $checkpoint.model_routing_receipts = @()
        Set-EpicCheckpointSeam -Text ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
        $payload = New-AgentPayload -Prompt $script:EpicPrompt

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -BeLike 'MODEL_ROUTING_RECEIPT_BLOCKED*'
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains('model_routing_receipts') | Should -BeTrue -Because 'the denial names the failed readiness predicate'
        Should -Invoke Resolve-ModelRoutingWorktreeTarget -Times 0 -Exactly
    }

    It 'a per-feature delegation is denied with the unchanged per-feature reason when its checkpoint lacks the receipt' {
        # Arrange: a ready epic checkpoint is present, but the branch label names another item.
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        Set-FeatureCheckpointSeam -Checkpoint ([pscustomobject]@{ model_routing_receipts = @([pscustomobject]@{ agent = 'atomic-planner' }) })
        $payload = New-AgentPayload -Prompt $script:FeaturePrompt
        $expected = "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert: the per-feature path ran and its reason is byte-identical to the pre-change literal.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $expected
        Should -Invoke Resolve-ModelRoutingWorktreeTarget -Times 1 -Exactly
    }

    It 'a per-feature delegation is allowed from the per-feature checkpoint when the epic branch does not match' {
        # Arrange: a ready epic checkpoint is present; the item's own checkpoint records the receipt.
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        Set-FeatureCheckpointSeam -Checkpoint ([pscustomobject]@{ model_routing_receipts = @([pscustomobject]@{ agent = 'pr-author' }) })
        $payload = New-AgentPayload -Prompt $script:FeaturePrompt

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-ModelRoutingWorktreeTarget -Times 1 -Exactly
        Should -Invoke Get-ModelRoutingCheckpoint -Times 1 -Exactly
    }
}
