#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Conditions M1 to M9 of Get-DocsOnlyMergeExemption in .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Both process seams are mocked by name; no row starts a process, runs git or gh, or writes
    a file. A guard mock makes any git call whose first argument is fetch throw, so a row that
    reached a fetch would fail.
#>

Describe 'Get-DocsOnlyMergeExemption (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-command-invocation.ps1')
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')
        $script:Merge = 'gh pr merge 5 --merge'
    }

    BeforeEach {
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "docs/a.md`0" } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'fetch' } -MockWith { throw 'a docs-only exemption row reached git fetch' }
    }

    Context 'M1 command shape' {
        It 'denies <Name> before any process (issue #927)' -ForEach @(
            @{ Name = 'a missing PR number'; Command = 'gh pr merge --merge'; Pr = $null }
            @{ Name = 'a non-positive PR number'; Command = 'gh pr merge 0 --merge'; Pr = 0 }
            @{ Name = 'a separate -R override'; Command = 'gh pr merge 5 --merge -R o/r'; Pr = 5 }
            @{ Name = 'a -dR cluster'; Command = 'gh pr merge 5 --merge -dR o/r'; Pr = 5 }
            @{ Name = 'a long --repo override'; Command = 'gh pr merge 5 --merge --repo o/r'; Pr = 5 }
            @{ Name = 'a --repo= override'; Command = 'gh pr merge 5 --merge --repo=o/r'; Pr = 5 }
            @{ Name = 'a global -R before pr merge'; Command = 'gh -R o/r pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'an inline GH_REPO prefix'; Command = 'GH_REPO=o/r gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'an inline GH_HOST prefix'; Command = 'GH_HOST=h gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'a cd chain'; Command = 'cd x && gh pr merge 5 --merge'; Pr = 5 }
            @{ Name = 'two merges in one command'; Command = 'gh pr merge 5 --merge; gh pr merge 6 --merge'; Pr = 5 }
            @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5 }
            @{ Name = 'an --auto= value'; Command = 'gh pr merge 5 --merge --auto=true'; Pr = 5 }
            @{ Name = 'a bash -c wrapper'; Command = 'bash -c "gh pr merge 5 --merge"'; Pr = 5 }
        ) {
            # Arrange: the row supplies the command and the number the gate read.

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber $Pr -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a pull-request URL selector before any process (issue #952)' {
            # Arrange: a /pull/<n> URL can name another repository, while gh pr view would read
            # pull request 5 of the session repository.
            $command = 'gh pr merge https://github.com/o/r/pull/5 --merge'

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeExactly "DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the URL selector 'https://github.com/o/r/pull/5' is not accepted."
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'M2 worktree root' {
        It 'denies <Name> with no process call (issue #927)' -ForEach @(
            @{ Name = 'a blank root'; Root = '' }
            @{ Name = 'a nonexistent root'; Root = '/synthetic-worktrees/no-such-root-927' }
        ) {
            # Arrange: the row supplies a blank or nonexistent root.

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $Root

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'M3 pull request lookup' {
        It 'denies <Name> with PR_UNRESOLVED and no git call (issue #927)' -ForEach @(
            @{ Name = 'a failing gh lookup'; Command = 'gh pr merge 5 --merge'; GhExit = 1; GhOutput = '' }
            @{ Name = 'unparseable lookup output'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = 'not json' }
            @{ Name = 'a short head oid'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"abc123"}' }
            @{ Name = 'an uppercase head oid'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789ABCDEF0123456789ABCDEF01234567"}' }
            @{ Name = 'a mismatched --match-head-commit'; Command = 'gh pr merge 5 --merge --match-head-commit 1111111111111111111111111111111111111111'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a --match-head-commit with no value'; Command = 'gh pr merge 5 --merge --match-head-commit'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a mismatched --match-head-commit= value'; Command = 'gh pr merge 5 --merge --match-head-commit=1111111111111111111111111111111111111111'; GhExit = 0; GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a timed-out gh lookup (exit 124)'; Command = 'gh pr merge 5 --merge'; GhExit = 124; GhOutput = '' }
            @{ Name = 'a JSON array lookup result'; Command = 'gh pr merge 5 --merge'; GhExit = 0; GhOutput = '[]' }
        ) {
            # Arrange
            $exitCode = $GhExit
            $output = $GhOutput
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies <Name> with BASE_UNRESOLVED and no git call (issue #927)' -ForEach @(
            @{ Name = 'a base containing two dots'; GhOutput = '{"baseRefName":"a..b","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
            @{ Name = 'a dash-leading base'; GhOutput = '{"baseRefName":"-x","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }
        ) {
            # Arrange
            $output = $GhOutput
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'does not deny a matching --match-head-commit (issue #927)' {
            # Arrange
            $command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567'

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "a matching head pin is accepted (OD-2); reason: $($result.Reason)"
        }

        It 'does not deny a matching --match-head-commit= value (issue #927)' {
            # Arrange
            $command = 'gh pr merge 5 --merge --match-head-commit=0123456789abcdef0123456789abcdef01234567'

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $command -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "a matching head pin in the equals form is accepted (OD-2); reason: $($result.Reason)"
        }

        It 'calls gh pr view with the number and the two JSON fields in the root (issue #927)' {
            # Arrange: the BeforeEach mocks return a valid pull request.

            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' -and $WorkingRoot -like '*claude-hooks' }
        }
    }

    Context 'M4 to M9 git checks' {
        It 'denies <Name> with BASE_UNRESOLVED and no diff call (issue #927)' -ForEach @(
            @{ Name = 'a failing base rev-parse'; RevExit = 128; RevOutput = '' }
            @{ Name = 'a non-hex base rev-parse'; RevExit = 0; RevOutput = 'main' }
            @{ Name = 'a timed-out base rev-parse (exit 124)'; RevExit = 124; RevOutput = '' }
        ) {
            # Arrange
            $exitCode = $RevExit
            $output = $RevOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' }
        }

        It 'denies <Name> with DIFF_FAILED naming the head and no diff call (issue #927)' -ForEach @(
            @{ Name = 'a failing head rev-parse'; RevExit = 128; RevOutput = '' }
            @{ Name = 'a different head rev-parse value'; RevExit = 0; RevOutput = 'ffffffffffffffffffffffffffffffffffffffff' }
        ) {
            # Arrange
            $exitCode = $RevExit
            $output = $RevOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*'
            $result.Reason.Contains('0123456789abcdef0123456789abcdef01234567') | Should -BeTrue -Because 'the reason names the missing head commit'
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' }
        }

        It 'denies <Name> (issue #927)' -ForEach @(
            @{ Name = 'a failing merge diff'; DiffExit = 1; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*could not be computed*' }
            @{ Name = 'merge diff output without a trailing NUL'; DiffExit = 0; DiffOutput = 'docs/a.md'; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*NUL-terminated*' }
            @{ Name = 'an empty merge diff'; DiffExit = 0; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*' }
            @{ Name = 'a merge diff with a path outside docs'; DiffExit = 0; DiffOutput = "docs/a.md`0src/b.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
            @{ Name = 'a timed-out merge diff (exit 124)'; DiffExit = 124; DiffOutput = ''; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*could not be computed*' }
        ) {
            # Arrange
            $exitCode = $DiffExit
            $output = $DiffOutput
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = $exitCode; Output = $output } }.GetNewClosure())

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike $Expected
        }

        It 'allows a NUL-terminated docs-only diff (issue #927)' {
            # Arrange: the BeforeEach mocks resolve both commits and return a NUL-terminated docs-only diff.

            # Act
            $result = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            $result.Exempt | Should -BeTrue -Because "reason: $($result.Reason)"
            $result.Reason | Should -BeNullOrEmpty
        }

        It 'runs the diff with -z, --no-renames, and the base...head range (issue #927)' {
            # Arrange: the BeforeEach mocks resolve the base commit and the head commit.

            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative fedcba9876543210fedcba9876543210fedcba98...0123456789abcdef0123456789abcdef01234567' }
        }

        It 'never runs git fetch on the allow path (issue #927)' {
            # Arrange: the BeforeEach mocks include a fetch guard that throws.

            # Act
            $null = Get-DocsOnlyMergeExemption -CommandText $script:Merge -PrNumber 5 -WorktreeRoot $PSScriptRoot

            # Assert
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -eq 'fetch' }
        }
    }
}
