Set-StrictMode -Version Latest

# Unit tests for Invoke-PoshQCParallelTest in scripts/powershell/PoshQC/PoshQC.Parallel.psm1 (issue #1048).
# Process start, wait, directory reset, file read, file write, and the clock are injected seams. The
# default-seam case mocks the pwsh wrapper seam (Invoke-PoshQCPwshExe) and the file cmdlets by name, so no
# process is started and no file is read or written.

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force

    $script:Root = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'parallel-runner-root'
    $script:OutputPath = { param([string] $Leaf) Join-Path (Join-Path $script:Root 'artifacts/pester') $Leaf }
    $script:ShardDirectory = { param([int] $Index) Join-Path (Join-Path $script:Root 'artifacts/pester/parallel') "shard-$Index" }
    $script:ShardPath = { param([int] $Index, [string] $Leaf) Join-Path (& $script:ShardDirectory $Index) $Leaf }

    # Returns the three output texts of one shard of a run over the test files a and b.
    $script:NewShardOutput = {
        param([int] $Index, [int] $Count, [string[]] $Selected)
        $suite = '<testsuite name="{0}" tests="2" errors="0" failures="0" hostname="h" id="0" skipped="0" disabled="0" package="{0}" time="1.5" />' -f "C:\r\tests\s$Index.Tests.ps1"
        $covered = if ($Index -eq 1) { 1 } else { 0 }
        @{
            'pester-junit.xml'        = '<?xml version="1.0" encoding="utf-8"?><testsuites name="Pester" tests="2" errors="0" failures="0" disabled="0" time="{0}">{1}</testsuites>' -f ($Index * 10), $suite
            'powershell-coverage.xml' = '<report name="Pester"><package name="scripts"><sourcefile name="x.ps1"><line nr="1" mi="{1}" ci="{0}" mb="0" cb="0" /><counter type="LINE" missed="{1}" covered="{0}" /></sourcefile><counter type="LINE" missed="{1}" covered="{0}" /></package><counter type="LINE" missed="{1}" covered="{0}" /></report>' -f $covered, (1 - $covered)
            'shard-files.json'        = [ordered]@{ shardIndex = $Index; shardCount = $Count; all = @('tests/a.Tests.ps1', 'tests/b.Tests.ps1'); selected = $Selected } | ConvertTo-Json -Depth 4
        }
    }

    # Returns the in-memory state of a two-shard run in which every shard succeeds and writes its outputs.
    $script:NewState = {
        $files = @{}
        $outputs = @{ 1 = (& $script:NewShardOutput 1 2 @('tests/a.Tests.ps1')); 2 = (& $script:NewShardOutput 2 2 @('tests/b.Tests.ps1')) }
        foreach ($index in $outputs.Keys) {
            foreach ($leaf in $outputs[$index].Keys) {
                $files[(& $script:ShardPath $index $leaf)] = $outputs[$index][$leaf]
            }
        }
        $clock = New-Object 'System.Collections.Generic.Queue[datetime]'
        $clock.Enqueue([datetime]::new(2026, 10, 31, 12, 0, 0, [System.DateTimeKind]::Utc))
        $clock.Enqueue([datetime]::new(2026, 10, 31, 12, 1, 30, 500, [System.DateTimeKind]::Utc))
        @{
            Files     = $files
            ExitCodes = @{}
            Started   = New-Object 'System.Collections.Generic.List[object]'
            Resets    = New-Object 'System.Collections.Generic.List[string]'
            Written   = @{}
            Log       = New-Object 'System.Collections.Generic.List[string]'
            Clock     = $clock
        }
    }

    # Returns the splat of every Invoke-PoshQCParallelTest seam, bound to the supplied state.
    $script:NewSeams = {
        param([hashtable] $State)
        $runState = $State
        @{
            Root                = $script:Root
            ResetShardDirectory = { param([string] $Path) $runState.Resets.Add($Path) }.GetNewClosure()
            StartShardProcess   = {
                param([string[]] $ArgumentList, [string] $LogPath)
                $runState.Started.Add([pscustomobject]@{ Arguments = $ArgumentList; LogPath = $LogPath })
                [pscustomobject]@{ Index = $runState.Started.Count }
            }.GetNewClosure()
            WaitShardProcess    = { param($Process) if ($runState.ExitCodes.ContainsKey($Process.Index)) { $runState.ExitCodes[$Process.Index] } else { 0 } }.GetNewClosure()
            ReadText            = { param([string] $Path) $runState.Files[$Path] }.GetNewClosure()
            WriteText           = { param([string] $Path, [string] $Text) $runState.Written[$Path] = $Text }.GetNewClosure()
            Clock               = { $runState.Clock.Dequeue() }.GetNewClosure()
            Logger              = { param([string] $Message) $runState.Log.Add($Message) }.GetNewClosure()
        }
    }
}

Describe 'Invoke-PoshQCParallelTest' {
    It 'PR01-STARTS-ONE-PROCESS-PER-SHARD starts one pwsh process per shard with the per-shard paths and log' {
        # Arrange
        $state = & $script:NewState
        $seams = & $script:NewSeams $state

        # Act
        $null = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $state.Started.Count | Should -Be 2
        ($state.Resets -join ',') | Should -BeExactly ((& $script:ShardDirectory 1) + ',' + (& $script:ShardDirectory 2))
        $second = $state.Started[1]
        $second.LogPath | Should -BeExactly (& $script:ShardPath 2 'shard.log')
        (@($second.Arguments[0..3]) -join ' ') | Should -BeExactly '-NoLogo -NoProfile -NonInteractive -Command'
        $command = $second.Arguments[4]
        $command | Should -Match ([regex]::Escape('-ShardIndex 2 -ShardCount 2'))
        $command | Should -Match ([regex]::Escape("-ShardFileListPath '$(& $script:ShardPath 2 'shard-files.json')'"))
        $command | Should -Match ([regex]::Escape("-TestResultPath '$(& $script:ShardPath 2 'pester-junit.xml')'"))
        $command | Should -Match ([regex]::Escape("-CoverageOutputPath '$(& $script:ShardPath 2 'powershell-coverage.xml')'"))
        $command | Should -Match '-DisableKoverageCopy$'
        $command | Should -Match "^Import-Module '.*PoshQC\.psd1';"
    }

    It 'PR02-ALL-PASS-MERGES-AND-EXITS-ZERO writes the merged JUnit, coverage, and Koverage files and returns exit code 0' {
        # Arrange
        $state = & $script:NewState
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.ExitCode | Should -Be 0
        (@($result.Shards | ForEach-Object { $_.ExitCode }) -join ',') | Should -BeExactly '0,0'
        (@($state.Written.Keys | Sort-Object) -join ',') | Should -BeExactly ((@((& $script:OutputPath 'pester-junit.xml'), (& $script:OutputPath 'powershell-coverage.koverage.xml'), (& $script:OutputPath 'powershell-coverage.xml')) | Sort-Object) -join ',')
        $junit = [xml] $state.Written[(& $script:OutputPath 'pester-junit.xml')]
        $junit.testsuites.tests | Should -Be '4'
        $junit.testsuites.time | Should -Be '20' -Because 'the merged root time is the longest shard'
        $coverage = [xml] $state.Written[(& $script:OutputPath 'powershell-coverage.xml')]
        $coverage.report.package.sourcefile.line.ci | Should -Be '1' -Because 'coverage is merged by maximum hit count'
    }

    It 'PR03-FAILED-SHARD-EXITS-NONZERO returns a non-zero exit code and writes no merged artifact when a shard fails' {
        # Arrange
        $state = & $script:NewState
        $state.ExitCodes[2] = 3
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.ExitCode | Should -Be 1
        $result.Shards[1].ExitCode | Should -Be 3
        $state.Written.Count | Should -Be 0
        ($state.Log -join "`n") | Should -Match 'Shards 2 exited non-zero'
    }

    It 'PR04-MISSING-SHARD-OUTPUT-WRITES-NO-MERGED-ARTIFACT stops before writing when a shard wrote no JUnit file' {
        # Arrange
        $state = & $script:NewState
        $state.Files.Remove((& $script:ShardPath 2 'pester-junit.xml'))
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.ExitCode | Should -Be 1
        $state.Written.Count | Should -Be 0
        ($state.Log -join "`n") | Should -Match 'Shard 2 wrote no Junit output'
    }

    It 'PR05-INCOMPLETE-MANIFESTS-EXIT-NONZERO returns a non-zero exit code when the manifests do not cover every file once' {
        # Arrange: both shards select a, so b is never run.
        $state = & $script:NewState
        $state.Files[(& $script:ShardPath 2 'shard-files.json')] = (& $script:NewShardOutput 2 2 @('tests/a.Tests.ps1'))['shard-files.json']
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.ExitCode | Should -Be 1
        $state.Written.Count | Should -Be 0
        ($state.Log -join "`n") | Should -Match 'Shard completeness check failed'
    }

    It 'PR06-MERGE-FAILURE-EXITS-NONZERO returns a non-zero exit code when a shard report cannot be merged' {
        # Arrange
        $state = & $script:NewState
        $state.Files[(& $script:ShardPath 2 'powershell-coverage.xml')] = '<report><unclosed>'
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.ExitCode | Should -Be 1
        $state.Written.Count | Should -Be 0
        ($state.Log -join "`n") | Should -Match 'Merging the shard outputs failed'
    }

    It 'PR07-WORKERCOUNT-OVERRIDE starts the requested number of shards and defaults to half the logical processors' {
        # Arrange
        $overrideState = & $script:NewState
        $defaultState = & $script:NewState
        $overrideSeams = & $script:NewSeams $overrideState
        $defaultSeams = & $script:NewSeams $defaultState
        $rejectedSeams = & $script:NewSeams (& $script:NewState)
        $expectedDefault = Get-PoshQCParallelWorkerCount -LogicalProcessorCount ([Environment]::ProcessorCount)

        # Act
        $override = Invoke-PoshQCParallelTest @overrideSeams -WorkerCount 3
        $default = Invoke-PoshQCParallelTest @defaultSeams

        # Assert
        $override.WorkerCount | Should -Be 3
        $overrideState.Started.Count | Should -Be 3
        $default.WorkerCount | Should -Be $expectedDefault
        $defaultState.Started.Count | Should -Be $expectedDefault
        { Invoke-PoshQCParallelTest @rejectedSeams -WorkerCount 0 } | Should -Throw
    }

    It 'PR08-SUMMARY-LOGS-WORKERS-AND-WALLCLOCK logs the worker count, the wall-clock seconds, and the exit code' {
        # Arrange: the clock advances by 90.5 seconds between the start and the end of the run.
        $state = & $script:NewState
        $seams = & $script:NewSeams $state

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 2

        # Assert
        $result.WallClockSeconds | Should -Be 90.5
        $state.Log[$state.Log.Count - 1] | Should -BeExactly 'Invoke-PoshQCParallelTest: workers=2; wall-clock=90.5s; exit code=0'
    }

    It 'PR09-DEFAULT-SEAMS runs every default seam through mocked cmdlets and the mocked pwsh wrapper' {
        # Arrange: each shard output is served by a Get-Content mock filtered on its path.
        $outputs = @{ 1 = (& $script:NewShardOutput 1 2 @('tests/a.Tests.ps1')); 2 = (& $script:NewShardOutput 2 2 @('tests/b.Tests.ps1')) }

        $result = InModuleScope PoshQC -Parameters @{ Root = $script:Root; Outputs = $outputs } {
            param([string] $Root, [hashtable] $Outputs)
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Remove-Item -MockWith { }
            Mock -CommandName New-Item -MockWith { }
            # The fake process reports exit code 99 until its WaitForExit method runs, so an overall exit code of 0
            # proves the default WaitShardProcess seam waited on every shard's process object.
            Mock -CommandName Invoke-PoshQCPwshExe -MockWith {
                $fakeProcess = [pscustomobject]@{ Id = 4242; ExitCode = 99 }
                $fakeProcess | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { $this.ExitCode = 0 }
                $fakeProcess
            }
            Mock -CommandName Set-Content -MockWith { }
            Mock -CommandName Write-Information -MockWith { }
            Mock -CommandName Get-Content -MockWith { $null }
            foreach ($index in $Outputs.Keys) {
                foreach ($leaf in $Outputs[$index].Keys) {
                    $filter = [scriptblock]::Create("`$LiteralPath -like '*shard-$index*$leaf'")
                    $body = [scriptblock]::Create("'" + ([string] $Outputs[$index][$leaf]).Replace("'", "''") + "'")
                    Mock -CommandName Get-Content -ParameterFilter $filter -MockWith $body
                }
            }

            # Act
            $run = Invoke-PoshQCParallelTest -Root $Root -WorkerCount 2

            # Assert
            Should -Invoke -CommandName Remove-Item -Times 2 -Exactly
            Should -Invoke -CommandName New-Item -Times 2 -Exactly -ParameterFilter { $ItemType -eq 'Directory' }
            Should -Invoke -CommandName Invoke-PoshQCPwshExe -Times 2 -Exactly -ParameterFilter { $PwshArgs[0] -eq '-NoLogo' -and $LogPath -like '*shard.log' }
            Should -Invoke -CommandName Set-Content -Times 3 -Exactly
            Should -Invoke -CommandName Write-Information -ParameterFilter { [string] $MessageData -like 'Invoke-PoshQCParallelTest: workers=2;*' }
            $run
        }

        # Assert
        $result.ExitCode | Should -Be 0
        $result.WallClockSeconds | Should -BeGreaterOrEqual 0
    }

    It 'PR10-OMITTED-ROOT-USES-CURRENT-LOCATION defaults the root to the current location when -Root is omitted' {
        # Arrange
        $state = & $script:NewState
        $seams = & $script:NewSeams $state
        $seams.Remove('Root')

        # Act
        Push-Location -LiteralPath $PSScriptRoot
        try {
            $expectedRoot = (Get-Location).ProviderPath
            $null = Invoke-PoshQCParallelTest @seams -WorkerCount 1
        } finally {
            Pop-Location
        }

        # Assert
        $state.Started[0].Arguments[4] | Should -Match ([regex]::Escape("-Root '$expectedRoot'"))
        $state.Resets[0].StartsWith((Join-Path $expectedRoot 'artifacts/pester/parallel'), [System.StringComparison]::Ordinal) | Should -BeTrue -Because 'the shard directories live under the current location'
    }

    It 'PR11-RELATIVE-ROOT-RESOLVES-AGAINST-CURRENT-LOCATION resolves a relative -Root against the current location' {
        # Arrange
        $state = & $script:NewState
        $seams = & $script:NewSeams $state
        $seams.Root = 'relative-root'

        # Act
        Push-Location -LiteralPath $PSScriptRoot
        try {
            $expectedRoot = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location).ProviderPath, 'relative-root'))
            $null = Invoke-PoshQCParallelTest @seams -WorkerCount 1
        } finally {
            Pop-Location
        }

        # Assert
        $state.Started[0].Arguments[4] | Should -Match ([regex]::Escape("-Root '$expectedRoot'"))
    }
}
