#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    model-routing gate author-asserted autoclose rows for Agent(pr-author) (issue #989, AA-01 to AA-12).

.DESCRIPTION
    Drives Invoke-ModelRoutingReceiptDecision for an Agent(pr-author) delegation whose
    per-feature checkpoint records a pr-author routing receipt. When that checkpoint records an
    issue-num and epic_mode is not true, the delegation prompt must carry the line
    'Author-asserted autoclose issues: #<issue-num>' at the start of a line, with the number not
    followed by a further digit. Otherwise the gate denies with the
    AUTHOR_ASSERTED_AUTOCLOSE_MISSING sub-code inside the MODEL_ROUTING_RECEIPT_BLOCKED family.

    The suite follows enforce-model-routing-receipt.EpicScope.Tests.ps1: the hook is
    dot-sourced first and the library modules are imported without -Force, so the mocks bind to
    the module instances the hook loaded. The per-feature resolution seam and the checkpoint
    reader are mocked, so no row reads a checkpoint from disk. The epic checkpoint text seam
    returns $null by default, which keeps every row except AA-11 on the per-feature path.

.NOTES
    No row creates a file, changes the working directory, spawns a process, reads a wall clock,
    or touches the network.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Mock Get-ModelRoutingCheckpoint { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
    $script:EpicPrompt = "Open the integration pull request for the sample epic.`nbranch: epic/sample-epic-integration"
    $script:PromptHead = "Open the pull request for the item.`nCanonical issue number for this feature is 989. All artifact content, file paths, and cross-references must use this number.`nbranch: bug/sample-item-989"
    $script:ReceiptMissingReason = "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."

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

    # Return a per-feature checkpoint object. IssueNum and EpicMode are added only when supplied,
    # so a row can model an absent property as well as a present one.
    function New-FeatureCheckpoint {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory checkpoint factory in a test file; it changes no system state.')]
        param(
            [string] $IssueNum,
            [AllowNull()] [object] $EpicMode,
            [string[]] $ReceiptAgent = @('pr-author')
        )
        $checkpoint = [ordered]@{ model_routing_receipts = @($ReceiptAgent | ForEach-Object { [pscustomobject]@{ agent = $_ } }) }
        if ($PSBoundParameters.ContainsKey('IssueNum')) { $checkpoint['issue-num'] = $IssueNum }
        if ($PSBoundParameters.ContainsKey('EpicMode')) { $checkpoint['epic_mode'] = $EpicMode }
        return [pscustomobject] $checkpoint
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
        $target = New-WorktreeResolutionFixtureTarget -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/item-989'
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { $target }.GetNewClosure()
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { $featureCheckpoint }.GetNewClosure()
    }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $SessionRoot; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
}

Describe 'enforce-model-routing-receipt.ps1 author-asserted autoclose line (issue #989)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        # Default per-feature seams: a NoTarget resolution and no checkpoint.
        $noTarget = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith { $noTarget }.GetNewClosure()
        Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { $null }
    }

    It 'AA-01 allows Agent(pr-author) when the prompt carries the author-asserted line for the checkpoint issue-num' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #989")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AA-02 denies Agent(pr-author) with AUTHOR_ASSERTED_AUTOCLOSE_MISSING when the line is absent' {
        # Arrange: the checkpoint records issue-num 989 and carries no epic_mode property.
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt $script:PromptHead

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert: the reason stays in the gate's family and names the exact expected line.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('MODEL_ROUTING_RECEIPT_BLOCKED:') | Should -BeTrue -Because $reason
        $reason.Contains('AUTHOR_ASSERTED_AUTOCLOSE_MISSING') | Should -BeTrue -Because $reason
        $reason.Contains('Author-asserted autoclose issues: #989') | Should -BeTrue -Because $reason
    }

    It 'AA-03 denies when the author-asserted line names a different issue number' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #990")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'AA-04 denies when the line names a prefix of the checkpoint number (#98 against 989)' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #98")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'AA-05 denies when the checkpoint number is a prefix of the line number (#989 against 98)' {
        # Arrange: '#98' is present in '#989' only when the digit boundary is ignored.
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '98')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #989")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'AA-06 allows when the checkpoint records no issue-num and the prompt carries no line' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint)
        $payload = New-AgentPayload -Prompt $script:PromptHead

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AA-07 allows an epic child (epic_mode true) whose prompt carries no line' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989' -EpicMode $true)
        $payload = New-AgentPayload -Prompt $script:PromptHead

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AA-08 denies when epic_mode is present and false and the prompt carries no line' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989' -EpicMode $false)
        $payload = New-AgentPayload -Prompt $script:PromptHead

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'AA-09 denies when the line text appears mid-line rather than at the start of a line' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nNote: Author-asserted autoclose issues: #989")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'AA-10 allows a non-pr-author subagent (atomic-planner) with an issue-num and no line' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989' -ReceiptAgent @('atomic-planner'))
        $payload = New-AgentPayload -Prompt $script:PromptHead -Subagent 'atomic-planner'

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AA-11 allows an epic-scope delegation without reading the per-feature checkpoint' {
        # Arrange: the per-feature reader would return a checkpoint that requires the line.
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt $script:EpicPrompt

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert: the epic-scope early return is unchanged.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-ModelRoutingCheckpoint -Times 0 -Exactly
    }

    It 'AA-12 returns the unchanged receipt-missing reason when the checkpoint has an issue-num and no pr-author receipt' {
        # Arrange
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989' -ReceiptAgent @('atomic-planner'))
        $payload = New-AgentPayload -Prompt $script:PromptHead

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert: receipt presence is checked before the author-asserted line.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:ReceiptMissingReason
    }

    It 'AA-13 allows a combined item line naming two issues with the checkpoint number first (issue #1013)' {
        # Arrange: a combined item's child names every member issue on one line.
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '989')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #989 #990")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AA-14 allows a combined item line naming two issues with the checkpoint number second (issue #1013)' {
        # Arrange: the checkpoint records the second member's number.
        Set-FeatureCheckpointSeam -Checkpoint (New-FeatureCheckpoint -IssueNum '990')
        $payload = New-AgentPayload -Prompt ($script:PromptHead + "`nAuthor-asserted autoclose issues: #989 #990")

        # Act
        $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}
