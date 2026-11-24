#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Run-scope record of the test-execution launcher Invoke-TestSuite.ps1 (issue #1228, spec D11).

.DESCRIPTION
    The launcher is dot-sourced, so its script-file entry does not run. Every launcher case injects the
    helper discovery, configuration, lock, clock, sleep, process, stderr, and run-scope write seams with
    in-memory values, and the writer cases mock Test-Path, New-Item, and Set-Content: no case starts a
    process, reads a lock or holder file, writes a file, or waits. The ImportHelper seam dot-sources the
    committed helper files of this repository. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    . (Join-Path $script:RepoRoot '.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1')
    $script:RecordPath = '/repo/artifacts/test-execution/run-scope.{0}.json'

    function Get-RunScopeCase {
        # Returns injected launcher seams; with Advance the clock moves one second per read and per suite start.
        param([int] $ExitCode = 0, [switch] $Throw, [switch] $Busy, [switch] $WriteFails, [switch] $Advance)
        $state = @{
            Now = [datetime]::new(2026, 11, 24, 12, 0, 0, [System.DateTimeKind]::Utc); StartedAt = $null; Repo = $script:RepoRoot
            Errors = [System.Collections.Generic.List[string]]::new(); RunScopes = [System.Collections.Generic.List[object]]::new()
        }
        $stream = [pscustomobject]@{ State = $state }
        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
        $exitValue = $ExitCode
        $throwValue = [bool]$Throw
        $busyValue = [bool]$Busy
        $failValue = [bool]$WriteFails
        $advanceValue = [bool]$Advance
        $arguments = @{
            RepositoryRoot     = '/repo'
            LauncherDirectory  = '/repo/.claude/skills/test-execution-policy/scripts'
            TestPath           = { param([string] $Path) $Path.Replace('\', '/').EndsWith('/.claude/hooks/test-execution-policy.ps1') }
            ImportHelper       = {
                param([string] $Path)
                # Not a closure: the launcher dot-invokes this seam, so the helper functions must land in its scope.
                . (Join-Path $runScopeState.Repo ".claude/hooks/$(Split-Path -Leaf $Path)")
            }
            ReadConfigText     = { param([string] $Path) [void] $Path; $null }
            GetLockDirectory   = { '/locks' }
            OpenLockStream     = { param([string] $Path) [void] $Path; if ($busyValue) { throw [System.IO.IOException]::new('busy') }; $stream }.GetNewClosure()
            ReadHolderText     = { param([string] $Path) [void] $Path; $null }
            WriteHolderText    = { param([string] $Path, [string] $Content) [void] $Path; [void] $Content }
            RemoveHolderFile   = { param([string] $Path) [void] $Path }
            GetProcessStartUtc = { param([int] $Id) [void] $Id; [datetime]::new(2026, 11, 24, 11, 0, 0, [System.DateTimeKind]::Utc) }
            Clock              = { $value = $state.Now; if ($advanceValue) { $state.Now = $state.Now.AddSeconds(1) }; $value }.GetNewClosure()
            Sleep              = { param([int] $Milliseconds) $state.Now = $state.Now.AddMilliseconds($Milliseconds) }.GetNewClosure()
            WriteStandardError = { param([string] $Line) $state.Errors.Add($Line) }.GetNewClosure()
            StartSuiteProcess  = {
                param([string] $FilePath, [string[]] $ArgumentList, [string] $WorkingDirectory)
                [void] $FilePath; [void] $ArgumentList; [void] $WorkingDirectory
                $state.StartedAt = $state.Now
                if ($advanceValue) { $state.Now = $state.Now.AddSeconds(1) }
                if ($throwValue) { throw 'suite crashed' }
                $exitValue
            }.GetNewClosure()
            WriteRunScope      = {
                param([string] $Path, [string] $Text)
                if ($failValue) { throw [System.UnauthorizedAccessException]::new('access denied') }
                $state.RunScopes.Add([pscustomobject]@{ Path = $Path.Replace('\', '/'); Text = $Text })
            }.GetNewClosure()
        }
        return [pscustomobject]@{ State = $state; Arguments = $arguments }
    }

    function Invoke-RunScopeCase {
        param([Parameter(Mandatory)] $Case, [string[]] $Word = @())
        Set-Variable -Name runScopeState -Value $Case.State
        $arguments = $Case.Arguments
        return (Invoke-TestSuiteLauncher @arguments -ArgumentList $Word)
    }
}

Describe 'Get-TestSuiteRunScope (issue #1228)' {
    It 'RSCOPE-LAUNCH-SCOPE: the <Runner> words <Words> give <Expected>' -ForEach @(
        @{ Runner = 'pester'; Words = @('-TestPath', 'tests/a.Tests.ps1'); Expected = 'selection' }
        @{ Runner = 'pester'; Words = @('-testpath', 'tests/a.Tests.ps1'); Expected = 'selection' }
        @{ Runner = 'pester'; Words = @('-Tag', 'Unit'); Expected = 'full' }
        @{ Runner = 'pester'; Words = @(); Expected = 'full' }
        @{ Runner = 'pytest'; Words = @('tests/test_a.py'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('tests/test_a.py::test_one'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('tests/folder::Case'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('-k', 'name'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('-kname'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('--deselect', 'tests/test_a.py::x'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('--deselect=tests/test_b.py::y'); Expected = 'selection' }
        @{ Runner = 'pytest'; Words = @('--cov=scripts', '--cov-report=term-missing'); Expected = 'full' }
        @{ Runner = 'pytest'; Words = @('-m', 'unit'); Expected = 'full' }
        @{ Runner = 'pytest'; Words = @('tests/scripts'); Expected = 'full' }
        @{ Runner = 'pytest'; Words = @('--junitxml=out.py'); Expected = 'full' }
        @{ Runner = 'jest'; Words = @('--testPathPattern', 'x'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--testPathPatterns=x'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--testNamePattern=y'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('-t', 'y'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('-o'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--findRelatedTests', 'src/a.ts'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--onlyChanged'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--changedSince=main'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('test/a.test.ts'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('test/b.spec.js'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('test/c.test.tsx'); Expected = 'selection' }
        @{ Runner = 'jest'; Words = @('--coverage'); Expected = 'full' }
        @{ Runner = 'jest'; Words = @('--testPathIgnorePatterns=x'); Expected = 'full' }
        @{ Runner = 'jest'; Words = @('test/folder'); Expected = 'full' }
        @{ Runner = 'jest'; Words = @('--outputFile=a.test.ts'); Expected = 'full' }
        @{ Runner = 'bats'; Words = @('-TestPath', 'tests/shell/a.bats'); Expected = 'full' }
        @{ Runner = 'mstest'; Words = @('-TestPath', 'tests/a'); Expected = 'full' }
    ) {
        # Act
        $scope = Get-TestSuiteRunScope -Runner $Runner -ArgumentList ([string[]]$Words)

        # Assert
        $scope | Should -BeExactly $Expected -Because "the $Runner words '$($Words -join ' ')' decide the scope"
    }
}

Describe 'New-TestSuiteRunScopeRecord (issue #1228)' {
    It 'RSCOPE-LAUNCH-RECORD-KEYS: holds exactly the six keys in order with round-trip UTC instants' {
        # Arrange
        $started = [datetime]::new(2026, 11, 24, 12, 0, 0, [System.DateTimeKind]::Utc)

        # Act
        $text = New-TestSuiteRunScopeRecord -Suite 'pester' -Runner 'pester' -Scope 'selection' -StartedUtc $started -CompletedUtc $started.AddSeconds(5)

        # Assert
        $text | Should -BeExactly '{"schema_version":1,"suite":"pester","runner":"pester","scope":"selection","started_utc":"2026-11-24T12:00:00.0000000Z","completed_utc":"2026-11-24T12:00:05.0000000Z"}'
    }
}

Describe 'Invoke-TestSuiteLauncher run-scope record (issue #1228)' {
    It 'RSCOPE-LAUNCH-WINDOW: started_utc precedes and completed_utc follows the instant the suite starts' {
        # Arrange
        $case = Get-RunScopeCase -Advance

        # Act
        $code = Invoke-RunScopeCase -Case $case -Word @('pester', '-TestPath', 'tests/a.Tests.ps1')

        # Assert
        $code | Should -Be 0
        $case.State.RunScopes.Count | Should -Be 1
        $record = ConvertFrom-Json -InputObject $case.State.RunScopes[0].Text -AsHashtable
        ([datetime]$record['started_utc']).ToUniversalTime() | Should -BeLessThan $case.State.StartedAt
        ([datetime]$record['completed_utc']).ToUniversalTime() | Should -BeGreaterThan $case.State.StartedAt
    }

    It 'RSCOPE-LAUNCH-PESTER-SELECTION: a pester -TestPath run writes scope selection at the record path' {
        # Arrange
        $case = Get-RunScopeCase

        # Act
        $null = Invoke-RunScopeCase -Case $case -Word @('pester', '-TestPath', 'tests/a.Tests.ps1')

        # Assert
        $case.State.RunScopes[0].Path | Should -BeExactly ($script:RecordPath -f 'pester')
        $record = ConvertFrom-Json -InputObject $case.State.RunScopes[0].Text -AsHashtable
        $record['schema_version'] | Should -Be 1
        $record['suite'] | Should -BeExactly 'pester'
        $record['runner'] | Should -BeExactly 'pester'
        $record['scope'] | Should -BeExactly 'selection'
    }

    It 'RSCOPE-LAUNCH-PYTEST-FULL: a bare pytest run writes scope full at the record path' {
        # Arrange
        $case = Get-RunScopeCase

        # Act
        $null = Invoke-RunScopeCase -Case $case -Word @('pytest')

        # Assert
        $case.State.RunScopes[0].Path | Should -BeExactly ($script:RecordPath -f 'pytest')
        (ConvertFrom-Json -InputObject $case.State.RunScopes[0].Text -AsHashtable)['scope'] | Should -BeExactly 'full'
    }

    It 'RSCOPE-LAUNCH-NONZERO-EXIT: a failing suite still writes its record and keeps its exit code' {
        # Arrange
        $case = Get-RunScopeCase -ExitCode 3

        # Act
        $code = Invoke-RunScopeCase -Case $case -Word @('pytest', 'tests/test_a.py')

        # Assert
        $code | Should -Be 3
        $case.State.RunScopes.Count | Should -Be 1
        (ConvertFrom-Json -InputObject $case.State.RunScopes[0].Text -AsHashtable)['scope'] | Should -BeExactly 'selection'
    }

    It 'RSCOPE-LAUNCH-NO-WRITE-REFUSAL: a refused command writes no record' {
        # Arrange
        $case = Get-RunScopeCase

        # Act
        $code = Invoke-RunScopeCase -Case $case -Word @('pytest', '-n', '1')

        # Assert
        $code | Should -Be 2
        $case.State.RunScopes.Count | Should -Be 0
    }

    It 'RSCOPE-LAUNCH-NO-WRITE-QUEUE-TIMEOUT: a queue timeout writes no record' {
        # Arrange
        $case = Get-RunScopeCase -Busy

        # Act
        $code = Invoke-RunScopeCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 75
        $case.State.RunScopes.Count | Should -Be 0
    }

    It 'RSCOPE-LAUNCH-NO-WRITE-THROWN-SUITE: a thrown suite writes no record' {
        # Arrange
        $case = Get-RunScopeCase -Throw

        # Act / Assert
        { Invoke-RunScopeCase -Case $case -Word @('pytest') } | Should -Throw '*suite crashed*'
        $case.State.RunScopes.Count | Should -Be 0
    }

    It 'RSCOPE-LAUNCH-WRITE-FAILURE: a write failure prints one TEST_EXECUTION_RUN_SCOPE_UNWRITTEN line and keeps the exit code' {
        # Arrange
        $case = Get-RunScopeCase -ExitCode 4 -WriteFails

        # Act
        $code = Invoke-RunScopeCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 4
        $case.State.Errors.Count | Should -Be 1
        $case.State.Errors[0] | Should -BeLike 'TEST_EXECUTION_RUN_SCOPE_UNWRITTEN:*run-scope.pytest.json*access denied*'
    }
}

Describe 'Write-TestSuiteRunScopeRecord (issue #1228)' {
    It 'RSCOPE-LAUNCH-WRITER-CREATES-FOLDER: creates an absent folder and writes UTF-8 text without a byte-order mark' {
        # Arrange
        Mock Test-Path { $false }
        Mock New-Item { }
        Mock Set-Content { }

        # Act
        Write-TestSuiteRunScopeRecord -Path '/repo/artifacts/test-execution/run-scope.pester.json' -Text '{"scope":"full"}'

        # Assert
        Should -Invoke New-Item -Times 1 -Exactly -ParameterFilter { $ItemType -eq 'Directory' -and "$Path".Replace('\', '/') -eq '/repo/artifacts/test-execution' }
        Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter {
            $LiteralPath -eq '/repo/artifacts/test-execution/run-scope.pester.json' -and "$Value" -eq '{"scope":"full"}' -and $NoNewline -and
            $Encoding.WebName -eq 'utf-8' -and $Encoding.GetPreamble().Length -eq 0
        }
    }

    It 'RSCOPE-LAUNCH-WRITER-EXISTING-FOLDER: writes into an existing folder without creating it' {
        # Arrange
        Mock Test-Path { $true }
        Mock New-Item { }
        Mock Set-Content { }

        # Act
        Write-TestSuiteRunScopeRecord -Path '/repo/artifacts/test-execution/run-scope.jest.json' -Text '{}'

        # Assert
        Should -Invoke New-Item -Times 0 -Exactly
        Should -Invoke Set-Content -Times 1 -Exactly
    }
}
