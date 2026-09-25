#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    pr-author gate 1 epic-scope rows (issue #663).

.DESCRIPTION
    Drives Invoke-PrAuthorSkillDecision for the epic integration pull request. In epic
    scope the PR-creation readiness predicate is evaluated on
    artifacts/orchestration/epic-orchestrator-state.json instead of the per-feature
    orchestrator-state preflight, so no per-feature checkpoint is needed or read.

    The hook is dot-sourced first and EpicScopeResolution.psm1 is imported without -Force,
    so the suite binds to the module instance the hook loaded. The epic checkpoint read and
    the worktree ascent are mocked inside that module; the ascent maps the session root to
    the synthetic root /synthetic-worktrees/epic-coordinator, so no host path reaches a
    checkpoint path or an assertion. The per-feature seams are mocked so their invocation
    counts prove which path ran. No row creates a file or changes the working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-pr-author-skill.ps1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
    $script:EpicCommand = 'gh pr create --head epic/sample-epic-integration --base main --title "Integrate sample epic" --body-file artifacts/pr_body_1.md'
    $script:StandaloneCommand = 'gh pr create --head feature/standalone-item --base main --title "Standalone item" --body-file artifacts/pr_body_1.md'

    function ConvertTo-EpicScopeBashPayload {
        # Return a Bash PreToolUse payload carrying one command string.
        param([Parameter(Mandatory)] [string] $Command)
        return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
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

    function ConvertTo-MutatedEpicJson {
        # Return the ready epic checkpoint JSON after one scripted change.
        param([Parameter(Mandatory)] [scriptblock] $Mutate)
        $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
        & $Mutate $checkpoint
        return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
    }
}

Describe 'enforce-pr-author-skill.ps1 epic scope (issue #663)' {
    BeforeEach {
        # Parent-hook read seams, as the end-to-end context of the base-branch suite sets them.
        Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
        Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
        Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
            '{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}'
        }
        Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }

        # Per-feature seams: a NoTarget resolution, a passing preflight, and no checkpoint.
        # Their invocation counts show whether the per-feature path ran.
        $noTarget = New-WorktreeResolutionFixtureTarget -Status 'NoTarget'
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith { $noTarget }.GetNewClosure()
        Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }
    }

    It 'epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed' {
        # Arrange
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        $payload = ConvertTo-EpicScopeBashPayload -Command $script:EpicCommand

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert: allowed from the epic checkpoint alone; no per-feature seam ran (RS-6).
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the epic checkpoint satisfies every PR-creation readiness conjunct'
        Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 0 -Exactly
        Should -Invoke Invoke-OrchestratorStatePreflight -Times 0 -Exactly
        Should -Invoke Get-PrAuthorCheckpointContent -Times 0 -Exactly
    }

    It 'epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status' {
        # Arrange
        Set-EpicCheckpointSeam -Text (ConvertTo-MutatedEpicJson -Mutate { param($c) $c.features[1].merge_status = 'pr_open' })
        $payload = ConvertTo-EpicScopeBashPayload -Command $script:EpicCommand

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains("'merge_status'") | Should -BeTrue -Because 'the denial names the failed conjunct'
    }

    It 'epic scope denies when features is empty and names the epic checkpoint and features' {
        # Arrange
        Set-EpicCheckpointSeam -Text (ConvertTo-MutatedEpicJson -Mutate { param($c) $c.features = @() })
        $payload = ConvertTo-EpicScopeBashPayload -Command $script:EpicCommand

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
        $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        $reason.Contains("'features'") | Should -BeTrue -Because 'the denial names the failed conjunct'
    }

    It 'without an epic checkpoint the call takes the unchanged per-feature path and is denied by its resolution' {
        # Arrange
        Set-EpicCheckpointSeam -Text $null
        $payload = ConvertTo-EpicScopeBashPayload -Command $script:EpicCommand

        # Act
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert: the per-feature resolution ran and its NoTarget reason is returned unchanged.
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "$(Get-WorktreeResolutionNoTargetReasonCode)*"
        Should -Invoke Resolve-PrAuthorWorktreeTarget -Times 1 -Exactly
    }

    It 'a per-feature pull request whose --head differs from integration_branch gets the same decision and reason as with no epic checkpoint' {
        # Arrange
        $payload = ConvertTo-EpicScopeBashPayload -Command $script:StandaloneCommand

        # Act: once with no epic checkpoint, once with a ready epic checkpoint present.
        Set-EpicCheckpointSeam -Text $null
        $withoutEpic = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload
        Set-EpicCheckpointSeam -Text $script:ReadyEpicJson
        $withEpic = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

        # Assert: a non-matching --head is never epic scope, so the decision is unchanged.
        $withEpic.hookSpecificOutput.permissionDecision | Should -Be $withoutEpic.hookSpecificOutput.permissionDecision
        $withEpic.hookSpecificOutput.permissionDecisionReason | Should -Be $withoutEpic.hookSpecificOutput.permissionDecisionReason
    }
}
