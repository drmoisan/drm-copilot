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

    Context 'epic_mode is false or absent (no-op/allow)' {
        It 'allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
            $result | Should -BeNullOrEmpty
        }

        It 'allows when the checkpoint has epic_mode: false' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { '{"epic_mode":false}' }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
            $result | Should -BeNullOrEmpty
        }

        It 'allows a non-create command regardless of epic_mode (gh pr edit is out of scope)' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md'
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'epic_mode is true with the correct --base (allow)' {
        It 'allows when --base matches epic_context.integration_branch exactly' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md'
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)' {
        It 'denies when --base is absent from the command text' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }
    }

    Context 'epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)' {
        It 'denies when --base names a different branch than epic_context.integration_branch' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }

        It 'denies when epic_mode is true but epic_context.integration_branch is missing' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { '{"epic_mode":true}' }
            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
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
            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }

        It 'allows end-to-end when epic_mode is true and --base matches' {
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }
            $json = '{"command":"gh pr create --title \"foo\" --base epic/foo-integration --body-file artifacts/pr_body_1.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
