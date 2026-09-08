#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping tests for Test-EpicBaseBranchOverride (issue #545).

.DESCRIPTION
    Test-EpicBaseBranchOverride used to decide scope by matching the raw command text
    against '\bgh\s+pr\s+create\b', which produced both directions of the issue #545 defect
    class: a relocating spelling carrying a gh global option between 'gh' and 'pr' was
    skipped entirely, and quoted prose that merely mentioned the phrase was gated.

    This is a new sibling file. The existing suite,
    enforce-pr-author-skill.epic-base-branch.Tests.ps1, is not extended: its nine cases are
    the unchanged-behaviour pins that [P7-T8] re-runs.

    Determinism: both cases mock Get-PrAuthorCheckpointContent, so neither reads the live
    orchestrator checkpoint from disk. No temporary file is written and no process is run.
#>

Describe 'Test-EpicBaseBranchOverride trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
    }

    Context 'under-match removal - a relocating spelling now classifies' {
        It 'classifies gh --repo drmoisan/drm-copilot pr create --base epic/x where it is skipped today' {
            # The --repo global option separates 'gh' from 'pr create'. The previous
            # adjacency regex did not match, so the check returned $null and an epic-mode
            # PR could be opened against the wrong base branch with no complaint. The
            # checkpoint names a DIFFERENT integration branch, so a classified command must
            # now report the mismatch.
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }

            $result = Test-EpicBaseBranchOverride -CommandText 'gh --repo drmoisan/drm-copilot pr create --base epic/x --body-file artifacts/pr_body_545.md'

            $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
        }
    }

    Context 'over-match removal - a quoted mention is not an invocation' {
        It 'no longer reports EPIC_BASE_BRANCH_MISMATCH for a quoted mention of the gh pr create phrase' {
            # The echo segment mentions the phrase inside a double-quoted span and invokes
            # nothing, so the epic-mode check must be out of scope and return $null.
            Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
                '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
            }

            $result = Test-EpicBaseBranchOverride -CommandText 'echo "gh pr create --base main"'

            $result | Should -BeNullOrEmpty
        }
    }
}
