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

        function Invoke-CodexDocsOnlyFakeDocPath {
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

        # Test-local stand-ins for the process object and the starter of Invoke-DocsOnlyBoundedNative.
        function Get-CodexDocsOnlyFakeProcess {
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '')
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0 }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
            $drain | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $Milliseconds -ge 0 }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; Disposed = $false; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
            $process.StandardOutput | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process.StandardError | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value { $this.Task }
            $process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { param([int] $Milliseconds) $this.WaitLimit = $Milliseconds; $this.Exits }
            $process | Add-Member -MemberType ScriptMethod -Name Kill -Value {
                param([bool] $EntireTree)
                if ($this.KillThrows) {
                    throw 'simulated stop failure'
                }
                $this.Killed = $EntireTree
            }
            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true }
            return $process
        }
        function Invoke-CodexDocsOnlyFakeStart {
            param($StartInfo)
            $script:CodexDocsOnlyStartInfo = $StartInfo
            $script:CodexDocsOnlyFakeProcess
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

            # The parameters are read here, outside the mock scriptblocks, so each is used directly.
            $ghResult = [pscustomobject]@{ ExitCode = $GhExit; Output = $GhOutput }
            $baseResult = [pscustomobject]@{ ExitCode = $BaseExit; Output = $BaseOutput }
            $headResult = [pscustomobject]@{ ExitCode = $HeadExit; Output = $HeadOutput }
            $diffResult = [pscustomobject]@{ ExitCode = $DiffExit; Output = $DiffOutput }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ $ghResult }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith ({ $baseResult }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith ({ $headResult }.GetNewClosure())
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ $diffResult }.GetNewClosure())
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
        # Arrange: the row supplies the diff text and the expected result.

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
        @{ Name = 'a success'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeDocPath'; ExitCode = 0; Output = "docs/a.md`0" }
        @{ Name = 'a non-zero exit'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeExit2'; ExitCode = 2; Output = '' }
        @{ Name = 'a throw'; Root = 'exists'; Fake = 'Invoke-CodexDocsOnlyFakeThrow'; ExitCode = -1; Output = '' }
        @{ Name = 'a blank root'; Root = ''; Fake = 'Invoke-CodexDocsOnlyFakeMarker'; ExitCode = -1; Output = '' }
    ) {
        # Arrange
        $workingRoot = if ($Root -eq 'exists') { $PSScriptRoot } else { $Root }

        # Act
        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $workingRoot -GitArgs @('status') -GitInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock

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
        $result = Invoke-DocsOnlyGhExe -WorkingRoot $workingRoot -GhArgs @('pr', 'view', '5') -GhInvoker (Get-Command -Name $Fake -CommandType Function).ScriptBlock

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
        @{ Name = 'a pull-request URL selector'; Command = 'gh pr merge https://github.com/o/r/pull/5 --merge'; Pr = 5; Root = 'exists'; Seam = @{}; Expected = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED*' }
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

    It 'runs the bounded runner when <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'the process exits in time'; Exits = $true; OutputCompletes = $true; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 0; Output = "docs/a.md`0"; Killed = $false }
        @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $false }
        @{ Name = 'the process emits LF-terminated lines'; Exits = $true; OutputCompletes = $true; KillThrows = $false; Text = "a`nb`n"; ExitCode = 0; Output = 'a|b'; Killed = $false }
    ) {
        # Arrange: the row supplies the output text, which wait expires, and whether stopping the process throws.
        $script:CodexDocsOnlyFakeProcess = Get-CodexDocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text $Text

        # Act
        $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList @('-C', $PSScriptRoot, 'status') -ProcessStarter ${function:Invoke-CodexDocsOnlyFakeStart})

        # Assert
        ($lines -join '|') | Should -BeExactly $Output
        $global:LASTEXITCODE | Should -Be $ExitCode
        $script:CodexDocsOnlyFakeProcess.Killed | Should -Be $Killed
        $script:CodexDocsOnlyStartInfo.FileName | Should -BeExactly 'git'
        $script:CodexDocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
    }

    It 'routes the default git invoker through the bounded runner (codex copy, issue #927)' {
        # Arrange
        Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

        # Act
        $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status')

        # Assert
        $result.Output | Should -BeExactly 'routed'
        Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'git' -and $TimeoutMilliseconds -eq 3000 }
    }

    It 'routes the default gh invoker through the bounded runner (codex copy, issue #927)' {
        # Arrange
        Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

        # Act
        $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5')

        # Assert
        $result.Output | Should -BeExactly 'routed'
        Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'gh' -and $TimeoutMilliseconds -eq 7000 }
    }
}
