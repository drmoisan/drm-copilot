#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for the docs-only exemption helpers of enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Exercises the pure helpers of enforce-pr-author-skill.docs-only.ps1 directly: the path-set
    classifier, the NUL-list parser, the --base extraction, the checkpoint-presence seam, and
    the git seam's failure object for a root that does not exist. No row creates, writes, or
    deletes a file, starts a process, or runs the git executable.
#>

Describe 'enforce-pr-author-skill docs-only helpers (issue #901)' {
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
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Get-PrAuthorDocsOnlyPathViolation' {
        It 'returns null for an all-docs set' {
            # Arrange
            $paths = @('docs/a.md', 'docs/features/x/plan.md')

            # Act
            $result = Get-PrAuthorDocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeNullOrEmpty -Because 'every path is under docs/'
        }

        It 'returns NON_DOCS_PATH for <Path>' -ForEach @(
            @{ Path = '.claude/hooks/x.ps1' }
            @{ Path = '.github/workflows/ci.yml' }
            @{ Path = 'README.md' }
            @{ Path = 'docsx/a.md' }
            @{ Path = 'doc/a.md' }
            @{ Path = 'Docs/a.md' }
            @{ Path = 'docs' }
        ) {
            # Arrange
            $paths = @($Path)

            # Act
            $result = Get-PrAuthorDocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*'
            $result.Contains($Path) | Should -BeTrue -Because 'the denial names the offending path'
        }

        It 'names the first offending path of a mixed set' {
            # Arrange
            $paths = @('docs/a.md', 'src/b.ps1', '.github/c.yml')

            # Act
            $result = Get-PrAuthorDocsOnlyPathViolation -Path $paths

            # Assert
            $result.Contains('src/b.ps1') | Should -BeTrue -Because 'the first non-docs path is reported'
            $result.Contains('.github/c.yml') | Should -BeFalse -Because 'evaluation stops at the first violation'
        }

        It 'returns EMPTY_DIFF for an empty set' {
            # Arrange
            $paths = @()

            # Act
            $result = Get-PrAuthorDocsOnlyPathViolation -Path $paths

            # Assert
            $result | Should -BeLike 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*'
        }
    }

    Context 'ConvertFrom-PrAuthorDocsOnlyNameList' {
        It 'splits a NUL list with spaces and non-ASCII names' {
            # Arrange
            $accented = 'docs/' + [char]0x00E9 + '.md'
            $text = "docs/a b.md`0" + $accented + "`0"

            # Act
            $result = @(ConvertFrom-PrAuthorDocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 2
            $result[0] | Should -BeExactly 'docs/a b.md'
            $result[1] | Should -BeExactly $accented
        }

        It 'keeps a line feed inside a name as one element' {
            # Arrange
            $text = "docs/line`nbreak.md`0"

            # Act
            $result = @(ConvertFrom-PrAuthorDocsOnlyNameList -Text $text)

            # Assert
            $result.Count | Should -Be 1 -Because 'only NUL separates entries'
            $result[0].Contains("`n") | Should -BeTrue
        }

        It 'returns no element for empty and null text' {
            # Arrange and Act
            $fromEmpty = @(ConvertFrom-PrAuthorDocsOnlyNameList -Text '')
            $fromNull = @(ConvertFrom-PrAuthorDocsOnlyNameList -Text $null)

            # Assert
            $fromEmpty.Count | Should -Be 0
            $fromNull.Count | Should -Be 0
        }
    }

    Context 'Get-PrAuthorDocsOnlyBaseName' {
        It 'accepts <Command>' -ForEach @(
            @{ Command = 'gh pr create --base main --body-file artifacts/pr_body_1.md'; Expected = 'main' }
            @{ Command = 'gh pr create --base=main --body-file artifacts/pr_body_1.md'; Expected = 'main' }
            @{ Command = 'gh pr create --base epic/x-integration --body-file artifacts/pr_body_1.md'; Expected = 'epic/x-integration' }
        ) {
            # Arrange: the row supplies the command and the expected branch.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeExactly $Expected
        }

        It 'rejects <Name>' -ForEach @(
            @{ Name = 'no --base'; Command = 'gh pr create --title "Docs" --body-file artifacts/pr_body_1.md' }
            @{ Name = 'the -B short form'; Command = 'gh pr create -B main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'a dash-leading value'; Command = 'gh pr create --base -x --body-file artifacts/pr_body_1.md' }
            @{ Name = 'a value containing ..'; Command = 'gh pr create --base a..b --body-file artifacts/pr_body_1.md' }
            @{ Name = 'two --base flags'; Command = 'gh pr create --base main --base dev --body-file artifacts/pr_body_1.md' }
            @{ Name = 'a trailing --base with no value'; Command = 'gh pr create --body-file artifacts/pr_body_1.md --base' }
        ) {
            # Arrange: the row supplies the command.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeNullOrEmpty -Because "$Name must not resolve a base"
        }

        It 'returns null for gh pr edit' {
            # Arrange
            $command = 'gh pr edit 12 --base main --body-file artifacts/pr_body_1.md'

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $command

            # Assert
            $result | Should -BeNullOrEmpty -Because 'only gh pr create is read'
        }
    }

    Context 'Test-PrAuthorDocsOnlyCheckpointPresence' {
        It 'reports an existing file' {
            # Arrange: this test file is a permanently existing leaf.
            $path = $PSCommandPath

            # Act
            $result = Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $path

            # Assert
            $result | Should -BeTrue
        }

        It 'reports a missing file as absent' {
            # Arrange
            $path = Join-Path $PSScriptRoot 'no-such-checkpoint-901.json'

            # Act
            $result = Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $path

            # Assert
            $result | Should -BeFalse
        }

        It 'reports a blank path as present (fail closed)' {
            # Arrange and Act
            $result = Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath ''

            # Assert
            $result | Should -BeTrue -Because 'a blank path cannot prove absence'
        }
    }

    Context 'Invoke-PrAuthorDocsOnlyGitExe' {
        It 'returns the failure object for a nonexistent root' {
            # Arrange
            $root = '/synthetic-worktrees/no-such-root-901'

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $root -GitArgs @('status')

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }
    }
}
