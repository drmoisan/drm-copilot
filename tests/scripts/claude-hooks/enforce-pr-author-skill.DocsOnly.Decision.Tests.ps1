#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end decisions for the docs-only exemption of enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Every row enters through Invoke-PrAuthorSkillDecision. The target resolves to a synthetic
    session root, the context summary exists, the orchestrator-state preflight fails, no
    checkpoint file exists, origin/main resolves, the branch diff lists only docs/ paths, and
    the receipt seams describe a valid receipt for pr_body_1.md. Each row overrides one seam
    or the command. No row creates, writes, or deletes a file, starts a process, or runs the
    git executable.
#>

Describe 'enforce-pr-author-skill.ps1 docs-only exemption decision (issue #901)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:Create = 'gh pr create --base main --title "Docs" --body-file artifacts/pr_body_1.md'

        # Return a Bash PreToolUse payload carrying one command string.
        function ConvertTo-DocsOnlyPayload {
            param([Parameter(Mandatory)] [string] $Command)
            return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'non-epic preflight failure' {
        BeforeEach {
            Mock Resolve-PrAuthorWorktreeTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/docs-only-901'; ReasonCode = $null; Detail = 'synthetic docs-only root' } }
            Mock Get-PrContextArtifactExistence { $true }
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $true; ErrorText = '' } }
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('a' * 40) } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "docs/a.md`0docs/b.md`0" } }
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x41) }
            Mock Get-PrAuthorReceiptContent { '{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}' }
            Mock Get-PrContextSummaryLastWriteUtc { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
            Mock Get-PrAuthorCheckpointContent { $null }
        }

        It 'allows a docs-only gh pr create with no checkpoint (AC-1)' {
            # Arrange
            $payload = ConvertTo-DocsOnlyPayload -Command $script:Create

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a branch that changes a .claude path' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ".claude/hooks/x.ps1`0" } }
            $payload = ConvertTo-DocsOnlyPayload -Command $script:Create

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH'
        }

        It 'keeps the preflight verdict when a checkpoint file exists' {
            # Arrange
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $true }
            $payload = ConvertTo-DocsOnlyPayload -Command $script:Create

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'never consults the exemption when the preflight passes (AC-3)' {
            # Arrange
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $false; ErrorText = '' } }
            $payload = ConvertTo-DocsOnlyPayload -Command $script:Create

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Test-PrAuthorDocsOnlyCheckpointPresence -Times 0 -Exactly
        }

        It 'denies gh pr edit --body-file' {
            # Arrange
            $payload = ConvertTo-DocsOnlyPayload -Command 'gh pr edit 12 --base main --body-file artifacts/pr_body_1.md'

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_NOT_CREATE'
        }

        It 'still runs the receipt checks on an exempt branch' {
            # Arrange: the body bytes no longer match the receipt hash.
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x42) }
            $payload = ConvertTo-DocsOnlyPayload -Command $script:Create

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_RECEIPT_HASH_MISMATCH*'
        }

        It 'denies a create without --base' {
            # Arrange
            $payload = ConvertTo-DocsOnlyPayload -Command 'gh pr create --title "Docs" --body-file artifacts/pr_body_1.md'

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED'
        }

        It 'denies a --repo override before the diff (issue #927)' {
            # Arrange
            $payload = ConvertTo-DocsOnlyPayload -Command 'gh pr create --title "Docs" --body-file artifacts/pr_body_1.md --repo o/r --base main'

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }
    }
}
