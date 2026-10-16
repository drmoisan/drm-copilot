#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Get-PrAuthorDocsOnlyExemption decision rows for enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Each row evaluates the exemption predicate E1 to E7 with the checkpoint-presence seam and
    the git seam Invoke-PrAuthorDocsOnlyGitExe mocked. The default arrangement is a docs-only
    branch with no checkpoint file and a resolvable origin/main; each row overrides one seam
    or the command and asserts the sub-code that results. No row creates, writes, or deletes
    a file, starts a process, or runs the git executable.
#>

Describe 'Get-PrAuthorDocsOnlyExemption (issue #901)' {
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
        $script:CreateWithoutBase = 'gh pr create --title "Docs" --body-file artifacts/pr_body_1.md'
        $script:Root = '/synthetic-worktrees/docs-only-901'
        $script:CheckpointPath = '/synthetic-worktrees/docs-only-901/checkpoint-901.json'

        # Evaluate the exemption for one command against the synthetic root and checkpoint path.
        function Invoke-DocsOnlyExemptionRow {
            param([Parameter(Mandatory)] [string] $Command)
            return (Get-PrAuthorDocsOnlyExemption -CommandText $Command -WorktreeRoot $script:Root -CheckpointPath $script:CheckpointPath)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'predicate rows' {
        BeforeEach {
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('a' * 40) } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "docs/a.md`0" } }
        }

        It 'exempts a docs-only create' {
            # Arrange: default seams describe a docs-only branch.

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Exempt | Should -BeTrue
            $result.Reason | Should -BeNullOrEmpty
        }

        It 'denies gh pr edit' {
            # Arrange
            $command = 'gh pr edit 12 --base main --body-file artifacts/pr_body_1.md'

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $command

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_NOT_CREATE*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies when a checkpoint file exists' {
            # Arrange
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $true }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies without an explicit --base' {
            # Arrange: the create command carries no --base.

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:CreateWithoutBase

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies when rev-parse fails' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
        }

        It 'denies when rev-parse prints no object id' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'not-an-object-id' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
        }

        It 'denies when rev-parse throws' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { throw 'simulated rev-parse failure' }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
        }

        It 'denies when the diff fails' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 128; Output = '' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
        }

        It 'denies when the diff throws' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { throw 'simulated diff failure' }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
        }

        It 'denies an empty diff' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }

        It 'denies a non-docs path' {
            # Arrange
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ".claude/hooks/x.ps1`0" } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
        }

        It 'denies a rename from outside docs reported as delete plus add' {
            # Arrange: --no-renames reports the old path and the new path separately.
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ".claude/x.md`0docs/x.md`0" } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Reason.Contains('.claude/x.md') | Should -BeTrue -Because 'the old path outside docs/ is reported'
        }

        It 'runs the diff with -z, --no-renames, --no-relative, and the three-dot range' {
            # Arrange: default seams.

            # Act
            $null = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' -and $GitArgs -contains '-z' -and $GitArgs -contains '--no-renames' -and $GitArgs -contains '--no-relative' -and $GitArgs[-1] -ceq (('a' * 40) + '...HEAD') }
        }

        It 'resolves the base on origin in the target worktree' {
            # Arrange: default seams.

            # Act
            $null = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' -and $WorktreeRoot -eq '/synthetic-worktrees/docs-only-901' }
        }

        It 'denies diff output that is not NUL-terminated (issue #927)' {
            # Arrange: the diff exits 0 but its output lacks the trailing NUL.
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'docs/a.md' } }

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:Create

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result.Reason | Should -Match 'NUL'
        }

        It 'denies a -R repository override before any git call (issue #927)' {
            # Arrange
            $command = 'gh pr create --base main -R o/r --title "Docs" --body-file artifacts/pr_body_1.md'

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $command

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a -dB shorthand cluster before any git call (issue #927)' {
            # Arrange
            $command = 'gh pr create --base main -dB other --title "Docs" --body-file artifacts/pr_body_1.md'

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $command

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'names every rejected override form in the E3 reason (issue #927)' {
            # Arrange: the create command carries no --base.

            # Act
            $result = Invoke-DocsOnlyExemptionRow -Command $script:CreateWithoutBase

            # Assert
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            foreach ($form in @('--base <branch>', '-B,', '-R,', '--repo,', 'shorthand cluster containing B or R', 'GH_REPO=')) {
                $result.Reason.Contains($form) | Should -BeTrue -Because "the reason names $form"
            }
        }
    }
}
