#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for the docs-only exemption helpers of enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Exercises the helpers of enforce-pr-author-skill.docs-only.ps1 directly: the --base
    extraction, the checkpoint-presence seam, and the git seam (failure object and command
    injection). The path-set classifier and the NUL-list parser moved with their rows to
    hook-docs-only-diff.Tests.ps1 (issue #927). No row creates, writes, or deletes a file,
    starts a process, or runs the git executable.
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

        It 'denies the base or repository override <Name>' -ForEach @(
            @{ Name = 'B cluster -dB'; Command = 'gh pr create --base main -dB other --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B attached -Bother'; Command = 'gh pr create --base main -Bother --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B equals -B=main'; Command = 'gh pr create --base main -B=main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'B cluster with equals -dB=other'; Command = 'gh pr create --base main -dB=other --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R separate -R'; Command = 'gh pr create --base main -R o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R attached -Ro/r'; Command = 'gh pr create --base main -Ro/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'R cluster -dR'; Command = 'gh pr create --base main -dR o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'long --repo'; Command = 'gh pr create --base main --repo o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'long --repo='; Command = 'gh pr create --base main --repo=o/r --body-file artifacts/pr_body_1.md' }
            @{ Name = 'global -R before pr create'; Command = 'gh -R o/r pr create --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'global --repo before pr create'; Command = 'gh --repo o/r pr create --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'inline GH_REPO prefix'; Command = 'GH_REPO=o/r gh pr create --base main --body-file artifacts/pr_body_1.md' }
        ) {
            # Arrange: the row supplies a command that retargets the base or the repository.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeNullOrEmpty -Because "$Name retargets gh away from the diffed base"
        }

        It 'still resolves main for <Name>' -ForEach @(
            @{ Name = 'boolean -d'; Command = 'gh pr create -d --base main --body-file artifacts/pr_body_1.md' }
            @{ Name = 'head shorthand -H'; Command = 'gh pr create --base main -H feature/x --body-file artifacts/pr_body_1.md' }
            @{ Name = 'title shorthand -t'; Command = 'gh pr create --base main -t Docs --body-file artifacts/pr_body_1.md' }
            @{ Name = 'pr-author long-flag shape'; Command = 'gh pr create --title "docs: x" --body-file artifacts/pr_body_927.md --head bug/x --base main' }
        ) {
            # Arrange: the row supplies a command whose single-dash tokens carry neither B nor R.

            # Act
            $result = Get-PrAuthorDocsOnlyBaseName -CommandText $Command

            # Assert
            $result | Should -BeExactly 'main' -Because "$Name does not retarget the base or the repository"
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

    Context 'Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927)' {
        BeforeAll {
            # Test-local stand-ins for the git executable, passed as scriptblocks to the seam's
            # GitInvoker parameter, so the seam body runs without starting a process.
            function Invoke-DocsOnlyFakeGitEcho {
                $global:LASTEXITCODE = 0
                ($args -join '|') + "`0"
            }
            function Invoke-DocsOnlyFakeGitMultiLine {
                $global:LASTEXITCODE = 0
                'docs/a.md'
                'docs/b.md'
            }
            function Invoke-DocsOnlyFakeGitExit128 {
                $global:LASTEXITCODE = 128
            }
            function Invoke-DocsOnlyFakeGitThrow {
                throw 'simulated git start failure'
            }
        }

        BeforeEach {
            $global:LASTEXITCODE = 0
        }

        AfterEach {
            $global:LASTEXITCODE = 0
        }

        It 'returns exit code 0 and NUL-terminated output with -C, the root, and the arguments in order' {
            # Arrange
            $gitArgs = @('diff', '--name-only', '-z')
            $expected = '-C|' + $PSScriptRoot + '|diff|--name-only|-z' + "`0"

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitEcho}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly $expected -Because 'the seam passes -C, the root, then the arguments'
            $result.Output.EndsWith([char]0) | Should -BeTrue -Because 'NUL-terminated output is preserved'
        }

        It 'joins multi-line output with a line feed' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitMultiLine}

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly "docs/a.md`ndocs/b.md"
        }

        It 'returns the non-zero exit code of the injected command' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitExit128}

            # Assert
            $result.ExitCode | Should -Be 128
            $result.Output | Should -BeExactly ''
        }

        It 'returns the failure object when the injected command throws' {
            # Arrange
            $gitArgs = @('status')

            # Act
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs $gitArgs -GitInvoker ${function:Invoke-DocsOnlyFakeGitThrow}

            # Assert
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }
    }
}
