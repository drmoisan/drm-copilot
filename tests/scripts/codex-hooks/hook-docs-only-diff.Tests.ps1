#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Drives the Codex copy .codex/hooks/hook-docs-only-diff.ps1 so that copy is covered (issue #927).

.DESCRIPTION
    Loads the Codex command parsers and the Codex copy of the helper. Process seams are mocked
    by name for the decision rows and driven through test-local functions for the seam rows;
    no row starts a process or writes a file.
#>

Describe 'Codex hook-docs-only-diff copy (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/hook-command-invocation.ps1')
        . (Join-Path $script:RepoRoot '.codex/hooks/hook-docs-only-diff.ps1')

        function Invoke-CodexDocsOnlyFakeDocs {
            $global:LASTEXITCODE = 0
            "docs/a.md`0"
        }
        function Invoke-CodexDocsOnlyFakeLocation {
            $global:LASTEXITCODE = 0
            (Split-Path -Leaf -Path (Get-Location).Path) + '|' + ($args -join '|')
        }
        function Invoke-CodexDocsOnlyFakeExit2 {
            $global:LASTEXITCODE = 2
        }
        function Invoke-CodexDocsOnlyFakeThrow {
            throw 'simulated process start failure'
        }
        function Invoke-CodexDocsOnlyFakeMarker {
            $global:LASTEXITCODE = 77
            'invoked'
        }

        function Set-CodexDocsOnlySeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams; each argument overrides one default result.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [int] $GhExit = 0,
                [string] $GhOutput = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}',
                [int] $BaseExit = 0,
                [string] $BaseOutput = 'fedcba9876543210fedcba9876543210fedcba98',
                [int] $HeadExit = 0,
                [string] $HeadOutput = '0123456789abcdef0123456789abcdef01234567',
                [int] $DiffExit = 0,
                [string] $DiffOutput = "docs/a.md`0"
            )

            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = $GhExit; Output = $GhOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $BaseExit; Output = $BaseOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith ({ [pscustomobject]@{ ExitCode = $HeadExit; Output = $HeadOutput } }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput } }.GetNewClosure())
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    It 'classifies <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'output without a trailing NUL'; Text = 'docs/a.md'; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'empty output'; Text = ''; Expected = 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF*' }
        @{ Name = 'a path outside docs'; Text = "src/a.ps1`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'the bare docs directory'; Text = "docs`0"; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'docs-only paths'; Text = "docs/a.md`0docs/b.md`0"; Expected = 'NONE' }
    ) {
        # Act
        $result = Get-DocsOnlyDiffTextViolation -DiffText $Text -BaseName 'main'

        # Assert
        if ($Expected -eq 'NONE') {
            $result | Should -BeNullOrEmpty
        }
        else {
            $result | Should -BeLike $Expected
        }
    }

    It 'runs the git seam for <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'a success'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeDocs'; ExitCode = 0; Output = "docs/a.md`0" }
        @{ Name = 'a non-zero exit'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeExit2'; ExitCode = 2; Output = '' }
        @{ Name = 'a throw'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeThrow'; ExitCode = -1; Output = '' }
        @{ Name = 'a blank root'; Root = ''; Fake = 'Invoke-CodexDocsOnlyFakeMarker'; ExitCode = -1; Output = '' }
    ) {
        # Arrange
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }

        # Act
        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $workingRoot -GitArgs @('status') -GitCommand $Fake

        # Assert
        $result.ExitCode | Should -Be $ExitCode
        $result.Output | Should -BeExactly $Output
    }

    It 'runs the gh seam for <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'a success'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeLocation'; ExitCode = 0; Output = 'codex-hooks|pr|view|5' }
        @{ Name = 'a non-zero exit'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeExit2'; ExitCode = 2; Output = '' }
        @{ Name = 'a throw'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeThrow'; ExitCode = -1; Output = '' }
        @{ Name = 'a blank root'; Root = ''; Fake = 'Invoke-CodexDocsOnlyFakeMarker'; ExitCode = -1; Output = '' }
    ) {
        # Arrange
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }
        $before = (Get-Location).Path

        # Act
        $result = Invoke-DocsOnlyGhExe -WorkingRoot $workingRoot -GhArgs @('pr', 'view', '5') -GhCommand $Fake

        # Assert
        $result.ExitCode | Should -Be $ExitCode
        $result.Output | Should -BeExactly $Output
        (Get-Location).Path | Should -Be $before
    }

    It 'decides <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'no PR number'; Command = 'gh pr merge --merge'; Pr = $null; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a single-dash R token'; Command = 'gh pr merge 5 --merge -R o/r'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a --repo token'; Command = 'gh pr merge 5 --merge --repo o/r'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an inline prefix'; Command = 'GH_HOST=h gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an --auto flag'; Command = 'gh pr merge 5 --merge --auto'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a chained command'; Command = 'gh pr merge 5 --merge; echo x'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a non-merge command'; Command = 'gh pr view 5'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a blank root'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = ''; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a failing lookup'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhExit = 1; GhOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an unparseable lookup'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = 'not json' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'an invalid base'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = '{"baseRefName":"a..b","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' }; Expected = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*' }
        @{ Name = 'an invalid head'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ GhOutput = '{"baseRefName":"main","headRefOid":"abc"}' }; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a mismatched head pin'; Command = 'gh pr merge 5 --merge --match-head-commit 1111111111111111111111111111111111111111'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
        @{ Name = 'a missing base ref'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ BaseExit = 128; BaseOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED*' }
        @{ Name = 'a missing head commit'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ HeadExit = 128; HeadOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'a failing diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ DiffExit = 1; DiffOutput = '' }; Expected = 'DOCS_ONLY_EXEMPTION_DIFF_FAILED*' }
        @{ Name = 'a non-docs diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{ DiffOutput = "src/a.ps1`0" }; Expected = 'DOCS_ONLY_EXEMPTION_NON_DOCS_PATH*' }
        @{ Name = 'a docs-only diff'; Command = 'gh pr merge 5 --merge'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'EXEMPT' }
        @{ Name = 'a matching head pin'; Command = 'gh pr merge 5 --merge --match-head-commit 0123456789abcdef0123456789abcdef01234567'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'EXEMPT' }
    ) {
        # Arrange
        Set-CodexDocsOnlySeam @Seam
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }

        # Act
        $result = Get-DocsOnlyMergeExemption -CommandText $Command -PrNumber $Pr -WorktreeRoot $workingRoot

        # Assert
        if ($Expected -eq 'EXEMPT') {
            $result.Exempt | Should -BeTrue -Because "reason: $($result.Reason)"
        }
        else {
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike $Expected
        }
    }
}
