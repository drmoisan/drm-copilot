#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit coverage for Invoke-DocsOnlyBoundedNative in .claude/hooks/hook-docs-only-diff.ps1 (issue #927).

.DESCRIPTION
    Exercises the time-bounded runner behind the default git and gh invokers through a
    test-local process starter that returns a fake process object, so no row starts a process,
    runs git or gh, waits on a clock, or writes a file. An expired wait stops the process tree
    and reports exit code 124, which the seams return and the docs-only exemption denies.
#>

Describe 'hook-docs-only-diff bounded runner (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/hook-docs-only-diff.ps1')

        # Test-local stand-ins for the process object and the starter of Invoke-DocsOnlyBoundedNative.
        function Get-DocsOnlyFakeProcess {
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '', [bool] $ReadFaults = $false)
            $events = [System.Collections.Generic.List[string]]::new()
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0; Events = $events }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Events.Add("output-wait $Milliseconds"); $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text'; Faults = $ReadFaults; Events = $events }
            $drain | Add-Member -MemberType ScriptMethod -Name Wait -Value {
                param([int] $Milliseconds)
                $this.Events.Add("error-wait $Milliseconds")
                if ($this.Faults) {
                    throw 'simulated read fault'
                }
                return $true
            }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; Disposed = $false; Events = $events; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
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
            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true; $this.Events.Add('dispose') }
            return $process
        }
        function Invoke-DocsOnlyFakeStart {
            param($StartInfo)
            $script:DocsOnlyStartInfo = $StartInfo
            $script:DocsOnlyFakeProcess
        }
        function Invoke-DocsOnlyFakeStartThrow {
            $script:DocsOnlyStartAttempted = $true
            throw 'simulated process start failure'
        }
        function Invoke-DocsOnlyFakeBoundedGit {
            Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $args -TimeoutMilliseconds 2500 -ProcessStarter $script:DocsOnlyStarter
        }
    }

    BeforeEach {
        $global:LASTEXITCODE = 0
        $script:DocsOnlyStartInfo = $null
        $script:DocsOnlyStartAttempted = $false
        $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess
        $script:DocsOnlyStarter = ${function:Invoke-DocsOnlyFakeStart}
    }

    AfterEach {
        $global:LASTEXITCODE = 0
    }

    Context 'Invoke-DocsOnlyBoundedNative' {
        It 'starts the executable in the current location with each argument and redirected streams (issue #927)' {
            # Arrange
            $arguments = @('-C', 'root with space', 'status')

            # Act
            $null = Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList $arguments -TimeoutMilliseconds 2500 -ProcessStarter ${function:Invoke-DocsOnlyFakeStart}

            # Assert
            $info = $script:DocsOnlyStartInfo
            $info.FileName | Should -BeExactly 'git'
            (@($info.ArgumentList) -join '|') | Should -BeExactly '-C|root with space|status'
            $info.WorkingDirectory | Should -Be (Get-Location).ProviderPath
            $info.UseShellExecute | Should -BeFalse
            $info.RedirectStandardOutput | Should -BeTrue
            $info.RedirectStandardError | Should -BeTrue
            $info.StandardOutputEncoding.WebName | Should -Be 'utf-8'
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 2500
            $script:DocsOnlyFakeProcess.StandardOutput.Task.Limit | Should -Be 1000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
            ($script:DocsOnlyFakeProcess.Events -join '|') | Should -BeExactly 'output-wait 1000|dispose' -Because 'a read is checked without waiting only after an expired wait'
        }

        It 'emits <Name> as output lines (issue #927)' -ForEach @(
            @{ Name = 'two LF-terminated lines'; Text = "a`nb`n"; Expected = 'a|b' }
            @{ Name = 'CRLF-terminated lines'; Text = "a`r`nb`r`n"; Expected = 'a|b' }
            @{ Name = 'NUL-terminated diff output'; Text = "docs/a.md`0docs/b.md`0"; Expected = "docs/a.md`0docs/b.md`0" }
            @{ Name = 'empty output'; Text = ''; Expected = '' }
        ) {
            # Arrange: the row supplies the output text of a process that exits 0 in time.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Text $Text

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'git' -ArgumentList @('status') -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            ($lines -join '|') | Should -BeExactly $Expected
            $global:LASTEXITCODE | Should -Be 0
            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
        }

        It 'reports the non-zero exit code of a process that exits in time (issue #927)' {
            # Arrange
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -ExitCode 2

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList @('pr', 'view', '5') -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            $lines.Count | Should -Be 0
            $global:LASTEXITCODE | Should -Be 2
            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
        }

        It 'stops the process tree, emits nothing, and reports 124 when <Name> (issue #927)' -ForEach @(
            @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ReadFaults = $false; Killed = $true; Order = 'output-wait 0|error-wait 0|dispose' }
            @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; ReadFaults = $false; Killed = $true; Order = 'output-wait 1000|output-wait 0|error-wait 0|dispose' }
            @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; ReadFaults = $false; Killed = $false; Order = 'output-wait 0|error-wait 0|dispose' }
            @{ Name = 'a read check faults'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ReadFaults = $true; Killed = $true; Order = 'output-wait 0|error-wait 0|dispose' }
        ) {
            # Arrange: the row supplies which wait expires, whether stopping the process throws, and whether checking a read faults.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -ReadFaults $ReadFaults -Text 'docs/a.md'

            # Act
            $lines = @(Invoke-DocsOnlyBoundedNative -FileName 'gh' -ArgumentList @('pr', 'view', '5') -TimeoutMilliseconds 7000 -ProcessStarter ${function:Invoke-DocsOnlyFakeStart})

            # Assert
            $lines.Count | Should -Be 0 -Because 'an expired wait emits no output'
            $global:LASTEXITCODE | Should -Be 124
            $script:DocsOnlyFakeProcess.Killed | Should -Be $Killed
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 7000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
            ($script:DocsOnlyFakeProcess.Events -join '|') | Should -BeExactly $Order -Because 'each read is checked once without waiting before the process object is disposed'
        }

        It 'returns the seam failure object when the process cannot start (issue #927)' {
            # Arrange
            $script:DocsOnlyStarter = ${function:Invoke-DocsOnlyFakeStartThrow}

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status') -GitInvoker ${function:Invoke-DocsOnlyFakeBoundedGit}

            # Assert
            $script:DocsOnlyStartAttempted | Should -BeTrue -Because 'the bounded runner reached the process starter'
            $result.ExitCode | Should -Be -1
            $result.Output | Should -BeExactly ''
        }

        It 'returns exit code 124 through the git seam when the bounded call expires (issue #927)' {
            # Arrange
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $false -Text "docs/a.md`0"

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('diff', '--name-only', '-z') -GitInvoker ${function:Invoke-DocsOnlyFakeBoundedGit}

            # Assert
            $result.ExitCode | Should -Be 124
            $result.Output | Should -BeExactly ''
            (@($script:DocsOnlyStartInfo.ArgumentList) -join '|') | Should -BeExactly ('-C|' + $PSScriptRoot + '|diff|--name-only|-z')
            $script:DocsOnlyFakeProcess.Killed | Should -BeTrue
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
        }

        It 'routes the default git invoker through the bounded runner with a 3000 ms limit (issue #927)' {
            # Arrange
            Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

            # Act
            $result = Invoke-DocsOnlyGitExe -WorktreeRoot $PSScriptRoot -GitArgs @('status')

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'routed'
            Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'git' -and $TimeoutMilliseconds -eq 3000 -and $ArgumentList[0] -ceq '-C' -and $ArgumentList[-1] -ceq 'status' }
        }

        It 'routes the default gh invoker through the bounded runner with a 7000 ms limit (issue #927)' {
            # Arrange
            Mock Invoke-DocsOnlyBoundedNative { $global:LASTEXITCODE = 0; 'routed' }

            # Act
            $result = Invoke-DocsOnlyGhExe -WorkingRoot $PSScriptRoot -GhArgs @('pr', 'view', '5')

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeExactly 'routed'
            Should -Invoke Invoke-DocsOnlyBoundedNative -Times 1 -Exactly -ParameterFilter { $FileName -ceq 'gh' -and $TimeoutMilliseconds -eq 7000 -and ($ArgumentList -join ' ') -ceq 'pr view 5' }
        }
    }
}
