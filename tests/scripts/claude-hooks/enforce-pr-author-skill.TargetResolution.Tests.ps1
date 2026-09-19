#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the pr-author gate's worktree target resolution (issue #687).

.DESCRIPTION
    Covers the defect this change exists to remove: the gate validated a call against
    whichever orchestrator checkpoint occupied the session root, so in a parallel or epic
    topology it could return allow on the strength of a sibling item's state.

    The resolution outcome is injected through the Resolve-PrAuthorWorktreeTarget seam. The
    resolver behind it reads real git state, so driving it directly would make these tests
    depend on whichever worktrees exist on the machine running them.

    Issue #673: both expected reason codes come from the worktree-resolution accessors rather
    than from a literal, and every synthetic root is composed at run time from the path root
    of $PSScriptRoot, so no drive-letter path is written here.
#>

Describe 'enforce-pr-author-skill.ps1 target resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest

        # The accessors resolve through the helpers the hook dot-sources, whose own module
        # import lands in this session state.
        $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
        $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

        $script:SeamRoot = ([System.IO.Path]::GetPathRoot($PSScriptRoot) + 'f5-seam-root').Replace([string][char]92, '/')
        $script:ItemRoot = "$($script:SeamRoot)/item-701"
        $script:SessionRootPath = "$($script:SeamRoot)/session"
        $script:CheckpointRelative = 'artifacts/orchestration/orchestrator-state.json'
    }

    Context 'the checkpoint is taken from the resolved target, not the session root' {
        It 'validates the sibling worktree checkpoint when --head names another worktree' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:ItemRoot; ReasonCode = $null; Detail = 'branch names item-701' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                $script:capturedPath = $CheckpointPath
                [pscustomobject]@{ HasErrors = $false; ErrorText = '' }
            }
            Mock -CommandName Test-PrAuthorReceiptVerification -MockWith { $null }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/item-701 --body-file artifacts/pr_body_701.md' -ContextExists $true

            $reason | Should -BeNullOrEmpty
            $script:capturedPath | Should -BeLike ("{0}*" -f $script:ItemRoot)
            $script:capturedPath | Should -BeLike ("*{0}" -f $script:CheckpointRelative)
        }

        It 'uses the absolute session-root checkpoint path when the target resolves to the session root' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $script:SessionRootPath; ReasonCode = $null; Detail = 'session root' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith {
                $script:capturedPath = $CheckpointPath
                [pscustomobject]@{ HasErrors = $false; ErrorText = '' }
            }
            Mock -CommandName Test-PrAuthorReceiptVerification -MockWith { $null }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/self --body-file artifacts/pr_body_1.md' -ContextExists $true

            $reason | Should -BeNullOrEmpty
            $script:capturedPath | Should -BeExactly "$($script:SessionRootPath)/$($script:CheckpointRelative)"
        }
    }

    Context 'an underivable target denies instead of answering from unrelated state' {
        It 'denies with the no-target code when the call names no target' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = 'the call names no feature folder, file path, or branch.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the gate must not consult any checkpoint for an underivable target' }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --title x --body-file artifacts/pr_body_1.md' -ContextExists $true

            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionNoTargetReasonCode))
            $reason | Should -BeLike '*--head*'
            Should -Invoke -CommandName Invoke-OrchestratorStatePreflight -Times 0 -Exactly
        }

        It 'denies with the ambiguity code when signals disagree' {
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionAmbiguityReasonCode); Detail = 'the branch matches two worktrees.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { throw 'the gate must not consult any checkpoint for an ambiguous target' }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --head feature/shared --body-file artifacts/pr_body_1.md' -ContextExists $true

            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionAmbiguityReasonCode))
            Should -Invoke -CommandName Invoke-OrchestratorStatePreflight -Times 0 -Exactly
        }

        It 'never reports success on a sibling checkpoint: the false-approval case of defect 3.2' {
            # The sibling's checkpoint is the only state present and would pass the preflight.
            # Before issue #687 the gate consulted it and allowed; it must now refuse.
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = 'no signal.' }
            }
            Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { [pscustomobject]@{ HasErrors = $false; ErrorText = '' } }

            $reason = Get-PrAuthorBypassReason -CommandText 'gh pr create --body-file artifacts/pr_body_838.md' -ContextExists $true

            $reason | Should -Not -BeNullOrEmpty
            $reason | Should -BeLike ("{0}*" -f (Get-WorktreeResolutionNoTargetReasonCode))
        }
    }
}