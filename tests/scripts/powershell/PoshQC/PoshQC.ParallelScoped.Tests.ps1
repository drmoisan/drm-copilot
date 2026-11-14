Set-StrictMode -Version Latest

# Unit tests for the scoped entry of scripts/powershell/PoshQC/PoshQC.Parallel.psm1 (issue #1158, C1): the TestPath
# parameter of Get-PoshQCParallelShardArgument and Invoke-PoshQCParallelTest, and the default ResolveTestFile seam.
# Process start, wait, directory reset, file read, file write, the clock, and the logger are injected seams; the
# default seam's Test-Path and Get-ChildItem calls are mocked in module scope, so no process is started and no file
# is read or written.

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

    $script:Root = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'parallel-scoped-root'
    $script:ShardArguments = @{
        ModuleManifestPath = (Join-Path $script:Root 'PoshQC.psd1')
        Root               = $script:Root
        ShardIndex         = 1
        ShardCount         = 2
        ShardDirectory     = (Join-Path $script:Root 'artifacts/pester/parallel/shard-1')
    }

    # Returns the AST binding of the Invoke-PoshQCTest command in a shard argument list, and the parse errors.
    $script:BindShardCommand = {
        param([string[]] $ArgumentList)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($ArgumentList[-1], [ref]$tokens, [ref]$errors)
        $invocation = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Invoke-PoshQCTest' }, $true))[0]
        [pscustomobject]@{
            Errors = @($errors)
            Bound  = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($invocation, $false)
        }
    }

    # Returns the string constants bound to ScanFolders in a shard argument list, in order.
    $script:GetScanFolder = {
        param([string[]] $ArgumentList)
        $binding = & $script:BindShardCommand $ArgumentList
        $expression = $binding.Bound.BoundParameters['ScanFolders'].Value
        @($expression.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true) | ForEach-Object { $_.Value })
    }

    # Returns a recording state and the Invoke-PoshQCParallelTest seam splat bound to it. Every shard succeeds and
    # writes no output, so the merge returns 1; the tests read the recorded shard starts and seam calls.
    $script:NewRun = {
        param([object[]] $ResolvedFile = @())
        $state = @{
            Started  = New-Object 'System.Collections.Generic.List[object]'
            Resolved = New-Object 'System.Collections.Generic.List[object]'
            Log      = New-Object 'System.Collections.Generic.List[string]'
            Files    = $ResolvedFile
        }
        $runState = $state
        $seams = @{
            Root                = $script:Root
            ResetShardDirectory = { param([string] $Path) $null = $Path }
            StartShardProcess   = {
                param([string[]] $ArgumentList, [string] $LogPath)
                $runState.Started.Add([pscustomobject]@{ Arguments = $ArgumentList; LogPath = $LogPath })
                [pscustomobject]@{ Index = $runState.Started.Count }
            }.GetNewClosure()
            WaitShardProcess    = { param($Process) $null = $Process; 0 }
            ReadText            = { param([string] $Path) $null = $Path; $null }
            WriteText           = { param([string] $Path, [string] $Text) $null = $Path, $Text }
            Clock               = { [datetime]::new(2026, 11, 14, 12, 0, 0, [System.DateTimeKind]::Utc) }
            Logger              = { param([string] $Message) $runState.Log.Add($Message) }.GetNewClosure()
            ResolveTestFile     = {
                param([string] $RootPath, [string[]] $Paths, [string[]] $Suffixes)
                $runState.Resolved.Add([pscustomobject]@{ Root = $RootPath; Paths = $Paths; Suffixes = $Suffixes })
                $runState.Files
            }.GetNewClosure()
        }
        [pscustomobject]@{ State = $state; Seams = $seams }
    }
}

Describe 'Get-PoshQCParallelShardArgument scoped entry (issue #1158)' {
    It 'PS01-SHARD-TEXT-BINDS-SCANFOLDERS writes the test paths as an array constant in order' {
        # Arrange
        $paths = @('tests/a.Tests.ps1', "it's dir")

        # Act
        $arguments = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments; Paths = $paths } {
            param($Splat, $Paths)
            Get-PoshQCParallelShardArgument @Splat -TestPath $Paths
        }
        $binding = & $script:BindShardCommand $arguments

        # Assert
        $binding.Errors.Count | Should -Be 0
        $binding.Bound.BoundParameters['ScanFolders'].Value | Should -BeOfType ([System.Management.Automation.Language.ArrayExpressionAst])
        (& $script:GetScanFolder $arguments) -join '|' | Should -BeExactly "tests/a.Tests.ps1|it's dir"
    }

    It 'PS02-SHARD-TEXT-UNCHANGED-WITHOUT-TESTPATH leaves the command text unchanged when TestPath is empty' {
        # Act
        $default = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments } { param($Splat) Get-PoshQCParallelShardArgument @Splat }
        $empty = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments } { param($Splat) Get-PoshQCParallelShardArgument @Splat -TestPath @() }

        # Assert
        ($empty -join "`n") | Should -BeExactly ($default -join "`n")
        $default[-1] | Should -Not -Match 'ScanFolders'
    }
}

Describe 'Invoke-PoshQCParallelTest scoped entry (issue #1158)' {
    It 'PS03-WORKERS-CAPPED-BY-FILES starts one shard per resolved file when WorkerCount is larger' {
        # Arrange
        $run = & $script:NewRun @('tests/x/a.Tests.ps1', 'tests/x/b.Tests.ps1')
        $seams = $run.Seams

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 8 -TestPath @('tests/x')

        # Assert
        $result.WorkerCount | Should -Be 2
        $run.State.Started.Count | Should -Be 2
        foreach ($start in $run.State.Started) {
            (& $script:GetScanFolder $start.Arguments) -join '|' | Should -BeExactly 'tests/x/a.Tests.ps1|tests/x/b.Tests.ps1' -Because 'every shard receives the resolved files, not the raw TestPath'
        }
    }

    It 'PS04-WORKERS-ONE-KEPT starts one shard when WorkerCount is 1' {
        # Arrange
        $run = & $script:NewRun @('tests/x/a.Tests.ps1', 'tests/x/b.Tests.ps1')
        $seams = $run.Seams

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 1 -TestPath @('tests/x')

        # Assert
        $result.WorkerCount | Should -Be 1
        $run.State.Started.Count | Should -Be 1
        (& $script:GetScanFolder $run.State.Started[0].Arguments) -join '|' | Should -BeExactly 'tests/x/a.Tests.ps1|tests/x/b.Tests.ps1'
    }

    It 'PS05-SEAM-RECEIVES-ROOT-PATHS-SUFFIXES calls the seam once with the root, the paths, and the lane suffixes' {
        # Arrange
        $run = & $script:NewRun @('tests/x/a.Tests.ps1')
        $seams = $run.Seams

        # Act
        $null = Invoke-PoshQCParallelTest @seams -WorkerCount 2 -TestPath @('tests/x', 'tests/y.Tests.ps1') -ExcludeTestFileSuffix @('.integration.tests.ps1')

        # Assert
        $run.State.Resolved.Count | Should -Be 1
        $run.State.Resolved[0].Root | Should -BeExactly $script:Root
        ($run.State.Resolved[0].Paths -join '|') | Should -BeExactly 'tests/x|tests/y.Tests.ps1'
        ($run.State.Resolved[0].Suffixes -join '|') | Should -BeExactly '.integration.tests.ps1'
    }

    It 'PS06-NO-FILES-EXITS-ONE returns exit code 1, starts no shard, and names each given path' {
        # Arrange
        $run = & $script:NewRun @()
        $seams = $run.Seams

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 4 -TestPath @('tests/none', 'tests/also-none.Tests.ps1')

        # Assert
        $result.ExitCode | Should -Be 1
        $run.State.Started.Count | Should -Be 0
        $message = $run.State.Log -join "`n"
        $message | Should -Match ([regex]::Escape('tests/none'))
        $message | Should -Match ([regex]::Escape('tests/also-none.Tests.ps1'))
    }

    It 'PS07-NO-TESTPATH-NEVER-CALLS-SEAM leaves the run unscoped when TestPath is omitted' {
        # Arrange
        $run = & $script:NewRun @('tests/x/a.Tests.ps1')
        $seams = $run.Seams

        # Act
        $result = Invoke-PoshQCParallelTest @seams -WorkerCount 3

        # Assert
        $run.State.Resolved.Count | Should -Be 0
        $result.WorkerCount | Should -Be 3
        $run.State.Started.Count | Should -Be 3
        $run.State.Started[0].Arguments[-1] | Should -Not -Match 'ScanFolders'
    }

    It 'PS08-DEFAULT-SEAM-DEDUPLICATES binds the unique file list when a folder and a file inside it are given' {
        # Arrange: the mocks are registered inside the module scope, so they hold when the suite runs in a PoshQC shard.
        $run = & $script:NewRun @()
        $seams = $run.Seams
        $seams.Remove('ResolveTestFile')

        # Act
        $result = InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param($Seams)
            Mock Test-Path { $PathType -eq 'Container' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Mock Test-Path { $PathType -eq 'Leaf' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir?a.Tests.ps1' }
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'a.Tests.ps1') }, [pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'b.Tests.ps1') }) } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Invoke-PoshQCParallelTest @Seams -WorkerCount 8 -TestPath @('tests/dir', 'tests/dir/a.Tests.ps1')
        }

        # Assert
        $result.WorkerCount | Should -Be 2
        $run.State.Started.Count | Should -Be 2
        foreach ($start in $run.State.Started) {
            (& $script:GetScanFolder $start.Arguments) -join '|' | Should -BeExactly 'tests/dir/a.Tests.ps1|tests/dir/b.Tests.ps1'
        }
    }
}

Describe 'Resolve-PoshQCParallelTestFile default seam (issue #1158)' {
    It 'PS09-FILE-RETURNS-ITSELF returns a test file as itself in root-relative form' {
        # Act
        $files = InModuleScope PoshQC -Parameters @{ Root = $script:Root } {
            param($Root)
            Mock Test-Path { $PathType -eq 'Leaf' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?one.Tests.ps1' }
            Resolve-PoshQCParallelTestFile -Root $Root -TestPath @('tests/one.Tests.ps1')
        }

        # Assert
        @($files) -join '|' | Should -BeExactly 'tests/one.Tests.ps1'
    }

    It 'PS10-FOLDER-EXPANDS expands a folder to its test files, sorted, and keeps a file inside it once' {
        # Act
        $files = InModuleScope PoshQC -Parameters @{ Root = $script:Root } {
            param($Root)
            Mock Test-Path { $PathType -eq 'Container' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Mock Test-Path { $PathType -eq 'Leaf' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir?a.Tests.ps1' }
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'b.Tests.ps1') }, [pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'a.Tests.ps1') }) } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Resolve-PoshQCParallelTestFile -Root $Root -TestPath @('tests/dir/a.Tests.ps1', 'tests/dir')
        }

        # Assert
        @($files) -join '|' | Should -BeExactly 'tests/dir/a.Tests.ps1|tests/dir/b.Tests.ps1'
    }

    It 'PS11-ABSENT-AND-NON-TEST-DROPPED drops an absent path and a file that is not a test file' {
        # Act
        $outcome = InModuleScope PoshQC -Parameters @{ Root = $script:Root } {
            param($Root)
            Mock Test-Path { $false }
            Mock Test-Path { $PathType -eq 'Leaf' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?helper.ps1' }
            $files = @(Resolve-PoshQCParallelTestFile -Root $Root -TestPath @('tests/missing', 'tests/helper.ps1'))
            Should -Invoke Test-Path -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?helper.ps1' -and $PathType -eq 'Leaf' } -Times 1 -Exactly
            [pscustomobject]@{ Count = $files.Count }
        }

        # Assert
        $outcome.Count | Should -Be 0
    }

    It 'PS12-LANE-SUFFIX-DROPPED drops a file whose name ends with a supplied lane suffix, ignoring case' {
        # Act
        $files = InModuleScope PoshQC -Parameters @{ Root = $script:Root } {
            param($Root)
            Mock Test-Path { $PathType -eq 'Container' } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'a.Tests.ps1') }, [pscustomobject]@{ FullName = (Join-Path $LiteralPath[0] 'c.integration.tests.ps1') }) } -ParameterFilter { $LiteralPath -like '*parallel-scoped-root?tests?dir' }
            Resolve-PoshQCParallelTestFile -Root $Root -TestPath @('tests/dir') -ExcludeTestFileSuffix @('.INTEGRATION.tests.ps1')
        }

        # Assert
        @($files) -join '|' | Should -BeExactly 'tests/dir/a.Tests.ps1'
    }
}
