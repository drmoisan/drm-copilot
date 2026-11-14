#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the machine test-suite lock adapter (issue #1158).

.DESCRIPTION
    Every case runs against both byte-identical copies under .claude/hooks and .codex/hooks.
    Directory values are injected, and every lock-stream, holder-record, and process call is
    replaced by a recording seam, so no case touches the filesystem or starts a process. Two
    default-seam rows read values only: the start time of the current process, and the platform
    folder and environment values that resolve the current lock directory.
#>

BeforeDiscovery {
    $script:LockCopies = @(
        @{ Copy = '.claude/hooks/test-execution-lock.ps1' }
        @{ Copy = '.codex/hooks/test-execution-lock.ps1' }
    )
}

Describe 'test-execution-lock adapter <Copy> (issue #1158)' -ForEach $script:LockCopies {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot $Copy)
        $script:Directory = '/state/drm-copilot/test-execution'
    }

    Context 'directory resolution' {
        It 'resolves <Case>' -ForEach @(
            @{ Case = 'Windows from LocalApplicationData'; IsWin = $true; Local = 'C:\Users\u\AppData\Local'; Xdg = '/x'; HomeDir = '/home/u'; Expected = 'C:/Users/u/AppData/Local/drm-copilot/test-execution' }
            @{ Case = 'XDG_STATE_HOME'; IsWin = $false; Local = ''; Xdg = '/home/u/state'; HomeDir = '/home/u'; Expected = '/home/u/state/drm-copilot/test-execution' }
            @{ Case = 'HOME when XDG_STATE_HOME is unset'; IsWin = $false; Local = ''; Xdg = ''; HomeDir = '/home/u'; Expected = '/home/u/.local/state/drm-copilot/test-execution' }
        ) {
            # Act
            $directory = Get-TestExecutionLockDirectory -IsWindowsPlatform $IsWin -LocalApplicationData $Local -XdgStateHome $Xdg -HomeDirectory $HomeDir

            # Assert
            ($directory -replace '\\', '/') | Should -BeExactly $Expected
        }

        It 'ignores XDG_RUNTIME_DIR and resolves under HOME when XDG_STATE_HOME is unset' {
            # Arrange: the function has no runtime-directory input, so an injected XDG_RUNTIME_DIR value cannot reach it.
            $parameterNames = (Get-Command Get-TestExecutionLockDirectory).Parameters.Keys

            # Act
            $directory = Get-TestExecutionLockDirectory -IsWindowsPlatform $false -XdgStateHome '' -HomeDirectory '/home/u'

            # Assert
            $parameterNames | Should -Not -Contain 'XdgRuntimeDir'
            ($directory -replace '\\', '/') | Should -BeExactly '/home/u/.local/state/drm-copilot/test-execution'
        }

        It 'throws when no base directory is available' {
            # Act / Assert
            { Get-TestExecutionLockDirectory -IsWindowsPlatform $true -LocalApplicationData '' } | Should -Throw 'TEST_EXECUTION_POLICY_BLOCKED:*'
        }
    }

    Context 'lock probe and hold' {
        It 'returns Free with the stream and passes the test-suite.lock path to OpenLockStream' {
            # Arrange
            $opened = [System.Collections.Generic.List[string]]::new()
            $stream = [System.IO.MemoryStream]::new()

            # Act
            $result = Open-TestExecutionLock -Directory $script:Directory -OpenLockStream { param([string] $Path) $null = $Path; $opened.Add($Path); $stream }.GetNewClosure()

            # Assert
            $result.Result | Should -Be 'Free'
            [object]::ReferenceEquals($result.Stream, $stream) | Should -BeTrue
            @($opened) | Should -Be @([System.IO.Path]::Join($script:Directory, 'test-suite.lock'))
            $stream.Dispose()
        }

        It 'returns Busy when OpenLockStream throws an IOException' {
            # Act
            $result = Open-TestExecutionLock -Directory $script:Directory -OpenLockStream { param([string] $Path) $null = $Path; throw [System.IO.IOException]::new('locked') }

            # Assert
            $result.Result | Should -Be 'Busy'
            $result.Stream | Should -BeNullOrEmpty
        }

        It 'returns Busy when the IOException arrives wrapped in a method-invocation exception' {
            # Act
            $result = Open-TestExecutionLock -Directory $script:Directory -OpenLockStream { param([string] $Path) $null = $Path; throw [System.Management.Automation.MethodInvocationException]::new('wrapped', [System.IO.IOException]::new('locked')) }

            # Assert
            $result.Result | Should -Be 'Busy'
        }

        It 'rethrows a non-IO failure' {
            # Act / Assert
            { Open-TestExecutionLock -Directory $script:Directory -OpenLockStream { param([string] $Path) $null = $Path; throw [System.UnauthorizedAccessException]::new('denied') } } | Should -Throw '*denied*'
        }

        It 'does not open the lock under WhatIf' {
            # Arrange
            $script:Opened = $false

            # Act
            $result = Open-TestExecutionLock -Directory $script:Directory -WhatIf -OpenLockStream { param([string] $Path) $null = $Path; $script:Opened = $true }

            # Assert
            $script:Opened | Should -BeFalse
            $result.Result | Should -Be 'Busy'
        }
    }

    Context 'holder record' {
        It 'round-trips all seven fields through WriteHolderText and ReadHolderText on test-suite.holder.json' {
            # Arrange
            $script:Store = @{}
            $text = New-TestExecutionHolderRecord -ProcessId 4242 -ProcessStartUtc ([datetime]::new(2026, 11, 9, 11, 0, 0, [System.DateTimeKind]::Utc)) -Suite 'pytest' -CommandLine @('poetry', 'run', 'pytest') -WorktreeRoot '/repo/wt' -AcquiredAtUtc ([datetime]::new(2026, 11, 9, 11, 0, 1, [System.DateTimeKind]::Utc)) -PolicyVersion 1
            $holderPath = [System.IO.Path]::Join($script:Directory, 'test-suite.holder.json')

            # Act
            Write-TestExecutionHolderRecord -Directory $script:Directory -Text $text -WriteHolderText { param([string] $Path, [string] $Content) $script:Store[$Path] = $Content }
            $read = Read-TestExecutionHolderText -Directory $script:Directory -ReadHolderText { param([string] $Path) $null = $Path; $script:Store[$Path] }
            $record = ConvertFrom-Json -InputObject $read -AsHashtable -DateKind String

            # Assert
            @($script:Store.Keys) | Should -Be @($holderPath)
            (@($record.Keys) | Sort-Object) -join ',' | Should -Be 'acquiredAtUtc,commandLine,pid,policyVersion,processStartUtc,suite,worktreeRoot'
            $record['pid'] | Should -Be 4242
            $record['processStartUtc'] | Should -BeExactly '2026-11-09T11:00:00.0000000Z'
            $record['suite'] | Should -Be 'pytest'
            ($record['commandLine'] -join ' ') | Should -Be 'poetry run pytest'
            $record['worktreeRoot'] | Should -Be '/repo/wt'
            $record['acquiredAtUtc'] | Should -BeExactly '2026-11-09T11:00:01.0000000Z'
            $record['policyVersion'] | Should -Be 1
        }

        It 'passes the test-suite.holder.json path to RemoveHolderFile' {
            # Arrange
            $script:Removed = $null

            # Act
            Remove-TestExecutionHolderRecord -Directory $script:Directory -RemoveHolderFile { param([string] $Path) $null = $Path; $script:Removed = $Path }

            # Assert
            $script:Removed | Should -BeExactly ([System.IO.Path]::Join($script:Directory, 'test-suite.holder.json'))
        }

        It 'returns $null when ReadHolderText throws an IOException' {
            # Act
            $read = Read-TestExecutionHolderText -Directory $script:Directory -ReadHolderText { param([string] $Path) $null = $Path; throw [System.IO.IOException]::new('sharing') }

            # Assert
            $read | Should -BeNullOrEmpty
        }

        It 'returns $null when the IOException arrives wrapped' {
            # Act
            $read = Read-TestExecutionHolderText -Directory $script:Directory -ReadHolderText { param([string] $Path) $null = $Path; throw [System.Management.Automation.MethodInvocationException]::new('wrapped', [System.IO.IOException]::new('sharing')) }

            # Assert
            $read | Should -BeNullOrEmpty
        }

        It 'rethrows a non-IO read failure' {
            # Act / Assert
            { Read-TestExecutionHolderText -Directory $script:Directory -ReadHolderText { param([string] $Path) $null = $Path; throw [System.UnauthorizedAccessException]::new('denied') } } | Should -Throw '*denied*'
        }

        It 'writes and removes nothing under WhatIf' {
            # Arrange
            $script:Touched = 0

            # Act
            Write-TestExecutionHolderRecord -Directory $script:Directory -Text '{}' -WhatIf -WriteHolderText { param([string] $Path, [string] $Content) $null = $Path, $Content; $script:Touched++ }
            Remove-TestExecutionHolderRecord -Directory $script:Directory -WhatIf -RemoveHolderFile { param([string] $Path) $null = $Path; $script:Touched++ }

            # Assert
            $script:Touched | Should -Be 0
        }
    }

    Context 'process start time' {
        It 'returns $null for a missing process' {
            # Act / Assert
            Get-TestExecutionProcessStartTime -ProcessId 4242 -GetProcessStartUtc { param([int] $Id) $null = $Id; $null } | Should -BeNullOrEmpty
        }

        It 'returns $null when the start time is not readable' {
            # Act / Assert
            Get-TestExecutionProcessStartTime -ProcessId 4242 -GetProcessStartUtc { param([int] $Id) $null = $Id; throw [System.InvalidOperationException]::new('exited') } | Should -BeNullOrEmpty
        }

        It 'returns the UTC start time reported by the seam' {
            # Arrange
            $start = [datetime]::new(2026, 11, 9, 11, 0, 0, [System.DateTimeKind]::Utc)

            # Act
            $result = Get-TestExecutionProcessStartTime -ProcessId 4242 -GetProcessStartUtc { param([int] $Id) $null = $Id; $start }.GetNewClosure()

            # Assert
            $result | Should -Be $start
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'reads the start time of the current process through the default seam' {
            # Arrange: the current process is read, never started or stopped.
            $expected = (Get-Process -Id $PID).StartTime.ToUniversalTime()

            # Act
            $result = Get-TestExecutionProcessStartTime -ProcessId $PID

            # Assert
            $result | Should -Be $expected
        }
    }

    Context 'current lock directory' {
        It 'resolves the per-user lock directory from the current platform values' {
            # Act: the default reads the platform flag and the folder and environment values, and writes nothing.
            $directory = (Get-TestExecutionCurrentLockDirectory) -replace '\\', '/'

            # Assert
            $directory | Should -BeLike '*/drm-copilot/test-execution'
            [System.IO.Path]::IsPathRooted($directory) | Should -BeTrue
        }
    }
}
