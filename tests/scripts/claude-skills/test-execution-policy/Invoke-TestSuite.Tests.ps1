#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the test-execution launcher Invoke-TestSuite.ps1 (issue #1158, spec ### Launcher, D12, D18,
    D26, D27, D32).

.DESCRIPTION
    The launcher is dot-sourced, so its script-file entry does not run. Every case injects the helper
    discovery, configuration, lock, clock, sleep, process, and stderr seams with in-memory values: no case
    starts a process, reads a lock or holder file, writes a file, or waits. The ImportHelper seam
    dot-sources the committed helper files of this repository and records each requested path in the
    variable $caseState of the running It block (set through Set-Variable).
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:LauncherPath = Join-Path $script:RepoRoot '.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1'
    $script:PesterSuitePath = Join-Path $script:RepoRoot '.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'
    . $script:LauncherPath
    $script:RepoConfigText = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'config/test-execution-policy.json') -Raw

    $modulePath = Join-Path $script:RepoRoot 'scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) { Remove-Module -ModuleInfo $module -Force }
    }
    Import-Module -Name $resolvedModulePath -Force
    $script:ParallelParameterName = @((Get-Command -Name Invoke-PoshQCParallelTest).Parameters.Keys)

    $script:ForeignHolder = '{"pid":4242,"processStartUtc":"2026-01-01T00:00:00.0000000Z","suite":"pester","commandLine":[],"worktreeRoot":"/other","acquiredAtUtc":"2026-01-01T00:00:00.0000000Z","policyVersion":1}'

    function Get-LauncherCase {
        param(
            [AllowNull()][object] $ConfigText = $null,
            [string] $HelperFolder = '.claude/hooks',
            [string[]] $Present = @('.claude/hooks'),
            [switch] $Busy,
            [AllowNull()][object] $HolderText = $null,
            [int] $ExitCode = 0,
            [switch] $Throw,
            [string] $LauncherDirectory = '/repo/.claude/skills/test-execution-policy/scripts'
        )

        $state = @{
            Imported = [System.Collections.Generic.List[string]]::new(); Events = [System.Collections.Generic.List[string]]::new()
            Starts = [System.Collections.Generic.List[object]]::new(); Errors = [System.Collections.Generic.List[string]]::new()
            Sleeps = [System.Collections.Generic.List[int]]::new(); Written = [System.Collections.Generic.List[string]]::new()
            Classified = $null; ProbeCount = 0; HelperFolder = $HelperFolder; Repo = $script:RepoRoot
            Now = [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        }
        $stream = [pscustomobject]@{ State = $state }
        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.State.Events.Add('dispose') }
        $configValue = $ConfigText
        $presentValue = $Present
        $busyValue = [bool]$Busy
        $holderValue = $HolderText
        $exitValue = $ExitCode
        $throwValue = [bool]$Throw
        $arguments = @{
            RepositoryRoot        = '/repo'
            LauncherDirectory     = $LauncherDirectory
            TestPath              = { param([string] $Path) $normalized = $Path.Replace('\', '/'); @($presentValue | Where-Object { $normalized.EndsWith("/$_/test-execution-policy.ps1") }).Count -gt 0 }.GetNewClosure()
            ImportHelper          = {
                param([string] $Path)
                # Not a closure: the launcher dot-invokes this seam, so the helper functions must land in its scope.
                $caseState.Imported.Add($Path.Replace('\', '/'))
                . (Join-Path $caseState.Repo "$($caseState.HelperFolder)/$(Split-Path -Leaf $Path)")
            }
            ReadConfigText        = { param([string] $Path) [void] $Path; $configValue }.GetNewClosure()
            GetLockDirectory      = { '/locks' }
            OpenLockStream        = {
                param([string] $Path)
                [void] $Path
                $state.ProbeCount++
                if ($busyValue) { throw [System.IO.IOException]::new('busy') }
                $state.Events.Add('open')
                $stream
            }.GetNewClosure()
            ReadHolderText        = { param([string] $Path) [void] $Path; $holderValue }.GetNewClosure()
            WriteHolderText       = { param([string] $Path, [string] $Content) [void] $Path; $state.Events.Add('write'); $state.Written.Add($Content) }.GetNewClosure()
            RemoveHolderFile      = { param([string] $Path) [void] $Path; $state.Events.Add('remove') }.GetNewClosure()
            GetProcessStartUtc    = { param([int] $Id) [void] $Id; [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc) }
            Clock                 = { $state.Now }.GetNewClosure()
            Sleep                 = { param([int] $Milliseconds) $state.Sleeps.Add($Milliseconds); $state.Now = $state.Now.AddMilliseconds($Milliseconds) }.GetNewClosure()
            WriteStandardError    = { param([string] $Line) $state.Errors.Add($Line) }.GetNewClosure()
            RecordClassifierInput = { param([string[]] $ExtraArgument) $state.Classified = @($ExtraArgument) }.GetNewClosure()
            StartSuiteProcess     = {
                param([string] $FilePath, [string[]] $ArgumentList, [string] $WorkingDirectory)
                $state.Events.Add('start')
                $state.Starts.Add([pscustomobject]@{ FilePath = $FilePath; ArgumentList = @($ArgumentList); WorkingDirectory = $WorkingDirectory })
                if ($throwValue) { throw 'suite crashed' }
                $exitValue
            }.GetNewClosure()
        }
        return [pscustomobject]@{ State = $state; Arguments = $arguments }
    }

    function Invoke-LauncherCase {
        param([Parameter(Mandatory)] $Case, [string[]] $Word = @())
        Set-Variable -Name caseState -Value $Case.State
        $arguments = $Case.Arguments
        return (Invoke-TestSuiteLauncher @arguments -ArgumentList $Word)
    }
}

Describe 'Invoke-TestSuiteLauncher lock (issue #1158)' {
    It 'exits 75 with one queue-timeout line naming the holder when the lock stays busy' {
        # Arrange
        $case = Get-LauncherCase -Busy -HolderText $script:ForeignHolder

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 75
        $case.State.Starts.Count | Should -Be 0
        $case.State.Errors.Count | Should -Be 1
        $case.State.Errors[0] | Should -BeLike 'TEST_EXECUTION_QUEUE_TIMEOUT:*'
        $case.State.Errors[0] | Should -BeLike '*suite pester*pid 4242*'
        $case.State.Errors[0] | Should -BeLike '*waited 90000 ms*retry later*'
    }

    It 'writes the holder record with seven fields before the start and propagates a non-zero exit' {
        # Arrange
        $case = Get-LauncherCase -ExitCode 3

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 3
        ($case.State.Events -join ',') | Should -BeExactly 'open,write,start,remove,dispose'
        $record = $case.State.Written[0] | ConvertFrom-Json -AsHashtable
        @($record.Keys | Sort-Object) -join ',' | Should -BeExactly 'acquiredAtUtc,commandLine,pid,policyVersion,processStartUtc,suite,worktreeRoot'
        $record['suite'] | Should -BeExactly 'pytest'
    }

    It 'disposes the stream and deletes the record when the suite throws' {
        # Arrange
        $case = Get-LauncherCase -Throw

        # Act / Assert
        { Invoke-LauncherCase -Case $case -Word @('pytest') } | Should -Throw '*suite crashed*'
        ($case.State.Events -join ',') | Should -BeExactly 'open,write,start,remove,dispose'
    }

    It 'overwrites a stale record with the current process id' {
        # Arrange
        $case = Get-LauncherCase -HolderText $script:ForeignHolder

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        ($case.State.Written[0] | ConvertFrom-Json -AsHashtable)['pid'] | Should -Be $PID
    }

    It 'never probes the lock when machineLock.enabled is false and still starts the suite' {
        # Arrange
        $case = Get-LauncherCase -ConfigText '{"version":1,"machineLock":{"enabled":false}}'

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 0
        $case.State.ProbeCount | Should -Be 0
        $case.State.Starts.Count | Should -Be 1
    }

    It 'honors waitMilliseconds 4000 and pollMilliseconds 1000 on a busy lock' {
        # Arrange
        $case = Get-LauncherCase -Busy -ConfigText '{"version":1,"machineLock":{"waitMilliseconds":4000,"pollMilliseconds":1000}}'

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 75
        ($case.State.Sleeps -join ',') | Should -BeExactly '1000,1000,1000,1000'
        $case.State.Errors[0] | Should -BeLike '*waited 4000 ms*'
    }

    It 'records the config version as the holder policyVersion' {
        # Arrange
        $case = Get-LauncherCase -ConfigText $script:RepoConfigText

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        ($case.State.Written[0] | ConvertFrom-Json -AsHashtable)['policyVersion'] | Should -Be 1
    }

    It 'reports a child exit of 75 as 1 with one TEST_EXECUTION_SUITE_EXIT line' {
        # Arrange
        $case = Get-LauncherCase -ExitCode 75

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 1
        $case.State.Errors.Count | Should -Be 1
        $case.State.Errors[0] | Should -BeLike 'TEST_EXECUTION_SUITE_EXIT:*75*'
    }

    It 'returns a child exit of 2 unchanged with no launcher stderr line' {
        # Arrange
        $case = Get-LauncherCase -ExitCode 2

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 2
        $case.State.Errors.Count | Should -Be 0
    }
}

Describe 'Invoke-TestSuiteLauncher helper discovery (issue #1158, D32)' {
    It 'loads the three helpers from .codex/hooks when only that copy is present' {
        # Arrange
        $case = Get-LauncherCase -Present @('.codex/hooks') -HelperFolder '.codex/hooks'

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 0
        $case.State.Imported.Count | Should -Be 3
        @($case.State.Imported | Where-Object { $_ -like '/repo/.codex/hooks/*' }).Count | Should -Be 3
        @($case.State.Imported | Where-Object { $_ -like '*.claude/hooks*' }).Count | Should -Be 0
        $case.State.Starts.Count | Should -Be 1
    }

    It 'loads the three helpers from .claude/hooks when both copies are present' {
        # Arrange
        $case = Get-LauncherCase -Present @('.claude/hooks', '.codex/hooks')

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        @($case.State.Imported | Where-Object { $_ -like '/repo/.claude/hooks/*' }).Count | Should -Be 3
    }

    It 'exits 2 naming both folders when neither copy is present' {
        # Arrange
        $case = Get-LauncherCase -Present @()

        # Act
        $code = Invoke-LauncherCase -Case $case -Word @('pytest')

        # Assert
        $code | Should -Be 2
        $case.State.Errors[0] | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*.claude/hooks*.codex/hooks*'
        $case.State.Imported.Count | Should -Be 0
        $case.State.ProbeCount | Should -Be 0
        $case.State.Starts.Count | Should -Be 0
    }
}

Describe 'Invoke-TestSuiteLauncher refusals (issue #1158, D12)' {
    It 'refuses <Name> with a first stderr line containing <Expected>' -ForEach @(
        @{ Name = 'invalid config'; Config = '{"version":2}'; Word = @('pytest'); Expected = '*config/test-execution-policy.json*version*' }
        @{ Name = 'an empty argument list'; Config = $null; Word = @(); Expected = '*no test suite named*' }
        @{ Name = 'an unknown suite'; Config = $null; Word = @('nope'); Expected = '*pytest, pester, jest, dotnet-test*' }
        @{ Name = 'an integration path'; Config = $null; Word = @('pytest', 'tests/x_integration.py'); Expected = '*local integration lane is CI-only evidence*' }
        @{ Name = 'a golden marker'; Config = $null; Word = @('pytest', '-m', 'golden'); Expected = '*local golden lane is CI-only evidence*' }
        @{ Name = 'a worker token'; Config = $null; Word = @('pytest', '-n', '2'); Expected = '*-n 2*' }
    ) {
        # Arrange
        $case = Get-LauncherCase -ConfigText $Config

        # Act
        $code = Invoke-LauncherCase -Case $case -Word $Word

        # Assert
        $code | Should -Be 2
        $case.State.Errors[0] | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*'
        $case.State.Errors[0] | Should -BeLike $Expected
        $case.State.ProbeCount | Should -Be 0
        $case.State.Starts.Count | Should -Be 0
    }
}

Describe 'Invoke-TestSuiteLauncher argument and field reach (issue #1158, D26, D27)' {
    It 'passes the pytest extras -v, -s, --, and -i unchanged after the suite words and exclusions' {
        # Arrange
        $case = Get-LauncherCase

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('pytest', '-v', '-s', '--', '-i')

        # Assert
        $start = $case.State.Starts[0]
        $start.FilePath | Should -BeExactly 'poetry'
        ($start.ArgumentList -join '|') | Should -BeExactly 'run|pytest|-n|auto|-m|not integration and not golden|--ignore-glob=*.integration.test.ts|--ignore-glob=*.integration.test.js|--ignore-glob=*_integration.py|--ignore-glob=*.integration.tests.ps1|--ignore-glob=*.golden.test.ts|--ignore-glob=*.golden.test.js|--ignore-glob=*_golden.py|--ignore-glob=*.golden.tests.ps1|-v|-s|--|-i'
    }

    It 'starts jest-extension in extensions/drm-copilot with node run-jest.cjs' {
        # Arrange
        $case = Get-LauncherCase -ConfigText $script:RepoConfigText

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('jest-extension')

        # Assert
        $start = $case.State.Starts[0]
        $start.WorkingDirectory | Should -BeExactly (Join-Path '/repo' 'extensions/drm-copilot')
        $start.FilePath | Should -BeExactly 'node'
        $start.ArgumentList[0] | Should -BeExactly 'run-jest.cjs'
    }

    It 'starts the built-in <Suite> suite in the repository root' -ForEach @(
        @{ Suite = 'pytest' }
        @{ Suite = 'pester' }
    ) {
        # Arrange
        $case = Get-LauncherCase -ConfigText $script:RepoConfigText

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @($Suite)

        # Assert
        $case.State.Starts[0].WorkingDirectory | Should -BeExactly '/repo'
    }

    It 'starts the bats suite with bash scripts/bash/shell-qc.sh test' {
        # Arrange
        $case = Get-LauncherCase -ConfigText $script:RepoConfigText

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('bats', '--coverage')

        # Assert
        $start = $case.State.Starts[0]
        $start.FilePath | Should -BeExactly 'bash'
        ($start.ArgumentList -join '|') | Should -BeExactly 'scripts/bash/shell-qc.sh|test|--coverage'
    }

    It 'applies the runner of a configured suite to its exclusions and worker tokens' {
        # Arrange
        $config = '{"version":1,"suites":{"web":{"command":["npx","jest"],"runner":"jest"},"tool":{"command":["poetry","run","pytest"],"runner":"pytest"}}}'
        $jestCase = Get-LauncherCase -ConfigText $config
        $refusedCase = Get-LauncherCase -ConfigText $config
        $pytestCase = Get-LauncherCase -ConfigText $config

        # Act
        $null = Invoke-LauncherCase -Case $jestCase -Word @('web')
        $refusedCode = Invoke-LauncherCase -Case $refusedCase -Word @('web', '--runInBand')
        $null = Invoke-LauncherCase -Case $pytestCase -Word @('tool', '-i')

        # Assert
        @($jestCase.State.Starts[0].ArgumentList | Where-Object { $_ -like '--testPathIgnorePatterns=*' }).Count | Should -BeGreaterThan 0
        $refusedCode | Should -Be 2
        $pytestCase.State.Starts[0].ArgumentList[-1] | Should -BeExactly '-i'
    }

    It 'excludes only the integration lane when localLanes.exclude names integration' {
        # Arrange
        $config = '{"version":1,"localLanes":{"exclude":["integration"]}}'
        $goldenCase = Get-LauncherCase -ConfigText $config
        $integrationCase = Get-LauncherCase -ConfigText $config

        # Act
        $goldenCode = Invoke-LauncherCase -Case $goldenCase -Word @('pytest', 'tests/x_golden.py')
        $integrationCode = Invoke-LauncherCase -Case $integrationCase -Word @('pytest', 'tests/x_integration.py')

        # Assert
        $goldenCode | Should -Be 0
        $integrationCode | Should -Be 2
    }

    It 'starts the pester suite through -File with the launcher-sibling Invoke-PesterSuite.ps1 and binds its words' -ForEach @(
        @{ Injected = 0 }
        @{ Injected = 1 }
    ) {
        # Arrange
        $case = Get-LauncherCase -ConfigText $script:RepoConfigText -LauncherDirectory '/repo/.agents/skills/test-execution-policy/scripts'
        $recorded = @{}
        $injectedCode = $Injected
        $parameterNames = $script:ParallelParameterName
        $PesterSuiteSeams = @{
            ImportModule       = { param([string] $Path) [void] $Path }
            GetParameterName   = { $parameterNames }.GetNewClosure()
            InvokeParallelTest = { param([hashtable] $Parameter) foreach ($key in $Parameter.Keys) { $recorded[$key] = $Parameter[$key] }; [pscustomobject]@{ ExitCode = $injectedCode } }.GetNewClosure()
        }
        [void] $PesterSuiteSeams

        # Act
        $null = Invoke-LauncherCase -Case $case -Word @('pester')
        $start = $case.State.Starts[0]
        $fileIndex = [array]::IndexOf([string[]]$start.ArgumentList, '-File')
        $after = [string[]]@($start.ArgumentList | Select-Object -Skip ($fileIndex + 2))
        & $script:PesterSuitePath @after

        # Assert
        $start.FilePath | Should -BeExactly 'pwsh'
        $start.ArgumentList[$fileIndex + 1] | Should -BeExactly '.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'
        @($start.ArgumentList | Where-Object { $_ -eq '-Command' }).Count | Should -Be 0
        ($recorded['ExcludeTag'] -join ',') | Should -BeExactly 'Integration,Golden'
        ($recorded['ExcludeTestFileSuffix'] -join ',') | Should -BeExactly '.integration.test.ts,.integration.test.js,_integration.py,.integration.tests.ps1,-integration.test.ts,integration.tests.ps1,.golden.test.ts,.golden.test.js,_golden.py,.golden.tests.ps1'
        $recorded['Root'] | Should -BeExactly '.'
        $recorded.ContainsKey('WorkerCount') | Should -BeFalse
        $LASTEXITCODE | Should -Be $Injected
    }
}

Describe 'Invoke-TestSuite.ps1 script-file entry (issue #1158, D18)' {
    It 'binds the call-operator tokens as $args and refuses the worker token without starting a suite' {
        # Arrange
        $captured = @{ Extras = $null; Errors = [System.Collections.Generic.List[string]]::new(); Started = $false }
        $repoRoot = $script:RepoRoot
        $TestSuiteLauncherSeams = @{
            RepositoryRoot        = '/repo'
            TestPath              = { param([string] $Path) $Path.Replace('\', '/').EndsWith('/.claude/hooks/test-execution-policy.ps1') }
            ImportHelper          = { param([string] $Path) . (Join-Path $repoRoot ".claude/hooks/$(Split-Path -Leaf $Path)") }
            ReadConfigText        = { param([string] $Path) [void] $Path; $null }
            OpenLockStream        = { param([string] $Path) [void] $Path; [pscustomobject]@{} }
            StartSuiteProcess     = { param([string] $FilePath, [string[]] $ArgumentList, [string] $WorkingDirectory) [void] $FilePath; [void] $ArgumentList; [void] $WorkingDirectory; $captured.Started = $true; 0 }.GetNewClosure()
            RecordClassifierInput = { param([string[]] $ExtraArgument) $captured.Extras = @($ExtraArgument) }.GetNewClosure()
            WriteStandardError    = { param([string] $Line) $captured.Errors.Add($Line) }.GetNewClosure()
        }
        [void] $TestSuiteLauncherSeams
        $reference = { $args }
        $expected = @(& $reference -v -s -p no:xdist -- -i)

        # Act
        & $script:LauncherPath pytest -v -s -p no:xdist -- -i

        # Assert
        ($captured.Extras -join '|') | Should -BeExactly ($expected -join '|')
        foreach ($token in @('-v', '-s', '-p', 'no:xdist', '-i')) { $captured.Extras | Should -Contain $token }
        $LASTEXITCODE | Should -Be 2
        $captured.Errors[0] | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*'
        $captured.Started | Should -BeFalse
    }
}

Describe 'New-TestSuiteProcessStartInfo (issue #1158, D27)' {
    It 'keeps one ArgumentList entry per word with no shell and no Arguments string' {
        # Arrange
        $words = @('run', 'pytest', '-m', 'not integration and not golden', '--ignore-glob=*_integration.py', '-integration.test.ts')

        # Act
        $info = New-TestSuiteProcessStartInfo -FilePath 'poetry' -ArgumentList $words -WorkingDirectory '/work'

        # Assert
        $info.UseShellExecute | Should -BeFalse
        $info.Arguments | Should -BeExactly ''
        (@($info.ArgumentList) -join '|') | Should -BeExactly ($words -join '|')
        $info.WorkingDirectory | Should -BeExactly '/work'
    }
}

Describe 'Get-TestSuiteScriptArgument (issue #1158, D18)' {
    # Through pwsh -File, PowerShell splits a word that starts with '-' and contains ':' into two $args
    # elements; the launcher therefore reads its arguments from the process command line.
    It 'returns the words after the script operand of <Form> unchanged' -ForEach @(
        @{ Form = '-File'; HostWords = @('pwsh.dll', '-NoProfile', '-File', '/repo/.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1') }
        @{ Form = '-f with a backslash path'; HostWords = @('pwsh.dll', '-NoProfile', '-f', 'C:\short\DANMOI~1\Invoke-TestSuite.ps1') }
        @{ Form = 'the first positional'; HostWords = @('pwsh.dll', '.agents/skills/test-execution-policy/scripts/invoke-testsuite.ps1') }
    ) {
        # Arrange
        $words = @('pytest', '--cov-report=json:C:/r/report.json', '--cov-report=lcov:artifacts/python/lcov.info', '-m:x', '-v')

        # Act
        $result = Get-TestSuiteScriptArgument -BoundArgument @('pytest', '--cov-report=json', 'C:/r/report.json') -CommandLineArgument ($HostWords + $words) -ScriptLeaf 'Invoke-TestSuite.ps1'

        # Assert
        ($result -join '|') | Should -BeExactly ($words -join '|')
    }

    It 'returns an empty list when the script operand is the last word' {
        $result = Get-TestSuiteScriptArgument -BoundArgument @('ignored') -CommandLineArgument @('pwsh.dll', '-File', 'x/Invoke-TestSuite.ps1') -ScriptLeaf 'Invoke-TestSuite.ps1'

        @($result).Count | Should -Be 0
    }

    It 'falls back to the bound arguments when <Case>' -ForEach @(
        @{ Case = 'the host ran a -Command payload'; Line = @('pwsh.dll', '-NoProfile', '-Command', '& ./x.ps1') }
        @{ Case = 'the leaf follows an option other than -File'; Line = @('pwsh.dll', '-Command', 'x/Invoke-TestSuite.ps1', 'pytest') }
        @{ Case = 'the command line is empty'; Line = @() }
    ) {
        $result = Get-TestSuiteScriptArgument -BoundArgument @('pytest', '-v', 7) -CommandLineArgument $Line -ScriptLeaf 'Invoke-TestSuite.ps1'

        ($result -join '|') | Should -BeExactly 'pytest|-v|7'
    }
}
