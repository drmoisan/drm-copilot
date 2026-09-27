#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for Test-EpicBaseBranchOverride, the sixth ordered check added to
    enforce-pr-author-skill.ps1's Test-PrAuthorReceiptVerification.

.DESCRIPTION
    Split into a sibling file (rather than appended to
    enforce-pr-author-skill.Tests.ps1) because that file was already at 482 of the
    repository's 500-line hard cap; adding this matrix in place would have exceeded
    the limit. This file dot-sources the same production script and exercises only
    the epic-mode base-branch override check.
#>

Describe 'enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
    }

    # Issue #687 routes the checkpoint through a resolution seam. Defaulting it to the
    # session root keeps these tests exercising their own subject, and independent of
    # whichever worktrees exist on the machine running them.
    BeforeEach {
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
        }
    }

    Context 'epic_mode is false or absent (no-op/allow)' {
        It 'allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -BeNullOrEmpty
        }

        It 'allows when the checkpoint has epic_mode: false' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { '{"epic_mode":false}' }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -BeNullOrEmpty
        }

        It 'allows a non-create command regardless of epic_mode (gh pr edit is out of scope)' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'epic_mode is true with the correct --base (allow)' {
        It 'allows when --base matches epic_context.integration_branch exactly' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)' {
        It 'denies when --base is absent from the command text' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }
    }

    Context 'epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)' {
        It 'denies when --base names a different branch than epic_context.integration_branch' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }

        It 'denies when epic_mode is true but epic_context.integration_branch is missing' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { '{"epic_mode":true}' }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }
    }

    Context 'end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)' {
        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                '{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}'
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
            # Neutralize the orchestrator-state preflight check (added independently of the
            # epic-base-branch check) so these tests isolate check 6's behavior rather than
            # depending on a real on-disk checkpoint satisfying --require-pr-creation-ready.
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
        }

        It 'denies EPIC_BASE_BRANCH_MISMATCH end-to-end when epic_mode is true and --base is missing' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $json = '{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }

        It 'allows end-to-end when epic_mode is true and --base matches' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $json = '{"tool_input":{"command":"gh pr create --title \"foo\" --base epic/foo-integration --body-file artifacts/pr_body_1.md"}}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'issue #663 epic scope' {
        # In epic scope the integration pull request's base must be main. Check 6 receives the
        # scope object gate 1 resolved, so the epic checkpoint is read once per call and the
        # per-feature checkpoint seam is not read. The ascent maps the session root to a
        # synthetic root, so no host path reaches the checkpoint path.
        BeforeAll {
            # Imported without -Force so the Context binds to the instance the hook loaded.
            Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
        }

        BeforeEach {
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -CommandName Get-PrBodyFileBytes -MockWith { [byte[]]@(0x41) }
            Mock -CommandName Get-PrAuthorReceiptContent -MockWith {
                '{"number":1,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-06-27T12:00:00Z"}'
            }
            Mock -CommandName Get-PrContextSummaryLastWriteUtc -MockWith { [DateTime]::Parse('2026-06-27T11:00:00Z').ToUniversalTime() }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }
            Mock -CommandName Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution -MockWith {
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                return '/synthetic-worktrees/epic-coordinator'
            }
            Mock -CommandName Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -MockWith {
                '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
            }
        }

        It 'issue #663 epic scope allows --base main end-to-end' {
            # Arrange
            $json = @{ tool_input = @{ command = 'gh pr create --head epic/sample-epic-integration --base main --title "x" --body-file artifacts/pr_body_1.md' } } | ConvertTo-Json -Compress -Depth 5

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-OrchestratorStatePreflight -Times 0 -Exactly
            Should -Invoke Get-PrAuthorCheckpointContent -Times 0 -Exactly
        }

        It 'issue #663 epic scope denies --base <Base> with EPIC_BASE_BRANCH_MISMATCH' -ForEach @(
            @{ Base = 'development' }
            @{ Base = 'epic/sample-epic-integration' }
        ) {
            # Arrange
            $json = @{ tool_input = @{ command = "gh pr create --head epic/sample-epic-integration --base $Base --title `"x`" --body-file artifacts/pr_body_1.md" } } | ConvertTo-Json -Compress -Depth 5

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
            $decision.hookSpecificOutput.permissionDecisionReason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        }

        It 'issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH' {
            # Arrange
            $json = @{ tool_input = @{ command = 'gh pr create --head epic/sample-epic-integration --title "x" --body-file artifacts/pr_body_1.md' } } | ConvertTo-Json -Compress -Depth 5

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
            $decision.hookSpecificOutput.permissionDecisionReason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        }

        It 'issue #663 epic scope reads the epic checkpoint once per gh pr create call' {
            # Arrange
            $json = @{ tool_input = @{ command = 'gh pr create --head epic/sample-epic-integration --base main --title "x" --body-file artifacts/pr_body_1.md' } } | ConvertTo-Json -Compress -Depth 5

            # Act
            $null = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            # Assert: gate 1 resolves once and hands the scope object to check 6.
            Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
        }
    }
}
