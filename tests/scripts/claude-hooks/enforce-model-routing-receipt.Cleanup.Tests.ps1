#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cleanup consolidation delegation rows for the model-routing receipt gate (issue #1026).

.DESCRIPTION
    Drives Invoke-ModelRoutingReceiptDecision for Agent delegations. The resolution seam
    Resolve-ModelRoutingWorktreeTarget returns a synthetic worktree, the checkpoint reader
    Get-ModelRoutingCheckpoint returns $null (no checkpoint), the epic-scope read returns
    nothing, and the manifest and clock seams are mocked at script scope because the hook calls
    Get-CleanupWorktreeManifestContent and Get-CleanupWorktreeManifestUtcNow directly; the
    module-scope baseline mock of the manifest read is registered as well. No row creates a
    file, starts a process, reads a clock, or touches the network.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Get-ModelRoutingCheckpoint { $null }

    $script:Consolidation = '/synthetic-worktrees/documentationandmemories'
    $script:Manifest = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"run-1026","removals":[]}'
    $script:Now = [datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc)
    $script:CleanupPrompt = "Open the consolidation pull request with the absolute body path.`nbranch: documentationandmemories"

    function New-CleanupAgentPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param([Parameter(Mandatory)] [string] $Prompt, [string] $Subagent = 'pr-author')
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $Subagent; prompt = $Prompt } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function Set-CleanupRoutingFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Root = $script:Consolidation, [string] $Status = 'OtherWorktree', [AllowNull()][string] $Manifest = $script:Manifest, [AllowNull()][object] $Checkpoint = $null)
        $target = [pscustomobject]@{ Status = $Status; WorktreeRoot = $Root; ReasonCode = $null; Detail = 'synthetic cleanup root' }
        $manifestText = $Manifest
        $checkpointObject = $Checkpoint
        $now = $script:Now
        Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
        Mock Get-ModelRoutingCheckpoint { $checkpointObject }.GetNewClosure()
        Mock Get-CleanupWorktreeManifestContent { $manifestText }.GetNewClosure()
        Mock Get-CleanupWorktreeManifestUtcNow { $now }.GetNewClosure()
    }

    function Get-RoutingBlockedText {
        param([Parameter(Mandatory)] [string] $Subagent)
        return "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to '$Subagent' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."
    }
}

Describe 'model-routing gate cleanup consolidation delegation (issue #1026)' {
    BeforeEach {
        Set-CleanupRoutingFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows Agent(pr-author) with branch: documentationandmemories when the resolved worktree has no checkpoint and a fresh valid manifest exists' {
        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $script:CleanupPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CleanupWorktreeManifestContent -Times 1 -Exactly
    }

    It 'denies the delegation when the manifest is absent or invalid' {
        # Arrange
        $manifests = @(
            $null
            '{"tool":"other-tool","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
            '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-02T11:00:00Z","run_id":"r"}'
            '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":""}'
        )

        # Act
        $reasons = foreach ($manifest in $manifests) {
            Set-CleanupRoutingFixture -Manifest $manifest
            (Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $script:CleanupPrompt)).hookSpecificOutput.permissionDecisionReason
        }
        Mock Get-CleanupWorktreeManifestContent { throw 'simulated manifest read failure (issue #1026)' }
        $reasons += (Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $script:CleanupPrompt)).hookSpecificOutput.permissionDecisionReason

        # Assert
        foreach ($reason in $reasons) { $reason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'pr-author') }
    }

    It 'denies a non-pr-author subagent under the same conditions' {
        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $script:CleanupPrompt -Subagent 'atomic-executor')

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'atomic-executor')
        Should -Invoke Get-CleanupWorktreeManifestContent -Times 0 -Exactly
    }

    It 'denies a different branch label' {
        # Arrange
        $prompts = @(
            "Open the pull request.`nbranch: bug/example"
            "Open the pull request.`nbranch: DocumentationAndMemories"
            "Open the pull request.`nbranch: documentationandmemories`nbranch: documentationandmemories"
            "Open the pull request with --head bug/example.`nbranch: documentationandmemories"
        )

        # Act
        $reasons = foreach ($prompt in $prompts) { (Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $prompt)).hookSpecificOutput.permissionDecisionReason }

        # Assert
        foreach ($reason in $reasons) { $reason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'pr-author') }
        Should -Invoke Get-CleanupWorktreeManifestContent -Times 0 -Exactly -Because 'the label check runs before the manifest read'
    }

    It 'denies the consolidation delegation when the resolved worktree has a checkpoint without a pr-author receipt' {
        # Arrange
        Set-CleanupRoutingFixture -Checkpoint ([pscustomobject]@{ 'issue-num' = '1026'; model_routing_receipts = @() })

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $script:CleanupPrompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'pr-author')
    }

    It 'denies the delegation against a resolved feature worktree with no checkpoint' {
        # Arrange
        Set-CleanupRoutingFixture -Root '/synthetic-worktrees/bug-example'

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt "Open the pull request.`nbranch: bug/example")

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'pr-author')
    }

    It 'denies the delegation against the session root with no ready checkpoint' {
        # Arrange
        Set-CleanupRoutingFixture -Root '/synthetic-worktrees/main' -Status 'SessionRoot'
        $prompt = "Open the pull request.`nCanonical issue number for this feature is 1026. All artifact content, file paths, and cross-references must use this number."

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-CleanupAgentPayload -Prompt $prompt)

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-RoutingBlockedText -Subagent 'pr-author')
    }

    It 'answers false from the cleanup predicate when a seam throws' {
        # Arrange
        Mock Test-CleanupConsolidationBranchLabel { throw 'simulated predicate failure (issue #1026)' }

        # Act / Assert
        Test-ModelRoutingCleanupDelegation -PromptText $script:CleanupPrompt | Should -BeFalse
    }
}
