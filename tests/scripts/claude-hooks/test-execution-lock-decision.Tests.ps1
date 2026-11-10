#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the pure machine test-suite lock decision helper (issue #1158).

.DESCRIPTION
    Every case runs against both byte-identical copies under .claude/hooks and .codex/hooks.
    The wait driver receives Clock and Sleep seams whose clock advances by the slept
    interval, so no case waits in real time, starts a process, or touches a file.
#>

BeforeDiscovery {
    $script:DecisionCopies = @(
        @{ Copy = '.claude/hooks/test-execution-lock-decision.ps1' }
        @{ Copy = '.codex/hooks/test-execution-lock-decision.ps1' }
    )
}

Describe 'test-execution-lock-decision helper <Copy> (issue #1158)' -ForEach $script:DecisionCopies {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot $Copy)
        $script:Start = [datetime]::new(2026, 11, 9, 12, 0, 0, [System.DateTimeKind]::Utc)
        $script:HolderText = '{"pid":4242,"processStartUtc":"2026-11-09T11:00:00.0000000Z","suite":"pytest","commandLine":["poetry","run","pytest"],"worktreeRoot":"/repo/wt","acquiredAtUtc":"2026-11-09T11:00:01.0000000Z","policyVersion":1}'
        $script:HolderStart = [datetime]::new(2026, 11, 9, 11, 0, 0, [System.DateTimeKind]::Utc)
    }

    Context 'state model' {
        It 'returns <Expected> for enabled <Enabled>, probe <Probe>, record <Record>, elapsed <Elapsed> ms' -ForEach @(
            @{ Enabled = $false; Probe = 'Busy'; Record = 'parsed'; Elapsed = 0; Expected = 'Skip' }
            @{ Enabled = $true; Probe = 'Free'; Record = 'absent'; Elapsed = 0; Expected = 'Acquire' }
            @{ Enabled = $true; Probe = 'Free'; Record = 'parsed'; Elapsed = 0; Expected = 'AcquireReplacingStaleRecord' }
            @{ Enabled = $true; Probe = 'Free'; Record = 'unparseable'; Elapsed = 0; Expected = 'AcquireReplacingStaleRecord' }
            @{ Enabled = $true; Probe = 'Busy'; Record = 'parsed'; Elapsed = 89999; Expected = 'Wait' }
            @{ Enabled = $true; Probe = 'Busy'; Record = 'parsed'; Elapsed = 90000; Expected = 'Timeout' }
            @{ Enabled = $true; Probe = 'Busy'; Record = 'absent'; Elapsed = 95000; Expected = 'Timeout' }
        ) {
            # Arrange
            $text = switch ($Record) { 'absent' { $null } 'unparseable' { '{not json' } default { $script:HolderText } }
            $holder = ConvertFrom-TestExecutionHolderText -Text $text

            # Act
            $result = Get-TestExecutionLockDecision -Enabled $Enabled -ProbeResult $Probe -HolderRecord $holder -ProcessStartUtc $script:HolderStart -StartedAtUtc $script:Start -NowUtc $script:Start.AddMilliseconds($Elapsed) -WaitMilliseconds 90000

            # Assert
            $result.Decision | Should -Be $Expected
        }

        It 'returns Timeout on the first busy probe when WaitMilliseconds is 0' {
            # Act
            $result = Get-TestExecutionLockDecision -Enabled $true -ProbeResult 'Busy' -HolderRecord $null -StartedAtUtc $script:Start -NowUtc $script:Start -WaitMilliseconds 0

            # Assert
            $result.Decision | Should -Be 'Timeout'
            $result.HolderDescription | Should -Be 'an unidentified process'
        }
    }

    Context 'holder description' {
        It 'describes <Case>' -ForEach @(
            @{ Case = 'a matching start time'; Text = 'holder'; Start = 'match'; CurrentPid = 1; Expected = 'suite pytest (pid 4242, worktree /repo/wt)' }
            @{ Case = 'a missing process'; Text = 'holder'; Start = 'missing'; CurrentPid = 1; Expected = 'an unidentified process (stale record for pid 4242)' }
            @{ Case = 'a differing start time'; Text = 'holder'; Start = 'differs'; CurrentPid = 1; Expected = 'an unidentified process (stale record for pid 4242)' }
            @{ Case = 'an absent record'; Text = 'absent'; Start = 'match'; CurrentPid = 1; Expected = 'an unidentified process' }
            @{ Case = 'an unparseable record'; Text = 'bad'; Start = 'match'; CurrentPid = 1; Expected = 'an unidentified process' }
            @{ Case = 'a record without a numeric pid'; Text = 'nopid'; Start = 'match'; CurrentPid = 1; Expected = 'an unidentified process' }
            @{ Case = 'the current process'; Text = 'holder'; Start = 'match'; CurrentPid = 4242; Expected = 'an unidentified process (stale record for pid 4242)' }
        ) {
            # Arrange
            $text = switch ($Text) { 'holder' { $script:HolderText } 'bad' { '[1,' } 'nopid' { '{"pid":"x"}' } default { $null } }
            $observed = switch ($Start) { 'match' { $script:HolderStart } 'differs' { $script:HolderStart.AddSeconds(1) } default { $null } }

            # Act
            $description = Get-TestExecutionLockHolderDescription -HolderRecord (ConvertFrom-TestExecutionHolderText -Text $text) -ProcessStartUtc $observed -CurrentProcessId $CurrentPid

            # Assert
            $description | Should -BeExactly $Expected
        }

        It 'accepts a round-trip start-time string from the process seam' {
            # Act
            $description = Get-TestExecutionLockHolderDescription -HolderRecord (ConvertFrom-TestExecutionHolderText -Text $script:HolderText) -ProcessStartUtc '2026-11-09T11:00:00.0000000Z'

            # Assert
            $description | Should -BeLike 'suite pytest (pid 4242*'
        }

        It 'formats the queue-timeout line' {
            # Act
            $line = Get-TestExecutionQueueTimeoutMessage -HolderDescription 'an unidentified process' -WaitedMilliseconds 4000

            # Assert
            $line | Should -BeExactly 'TEST_EXECUTION_QUEUE_TIMEOUT: test-execution policy allows one suite per machine; lock held by an unidentified process; waited 4000 ms; retry later.'
        }
    }

    Context 'wait driver' {
        BeforeEach {
            $script:Now = $script:Start
            $script:Slept = [System.Collections.Generic.List[int]]::new()
            $script:Clock = { $script:Now }
            $script:Sleep = { param([int] $Milliseconds) $script:Slept.Add($Milliseconds); $script:Now = $script:Now.AddMilliseconds($Milliseconds) }
        }

        It 'waits with the defaults until the clock reaches 90000 ms and then times out' {
            # Act
            $result = Invoke-TestExecutionLockWait -Probe { 'Busy' } -ReadHolder { $script:HolderText } -GetProcessStartUtc { param([int] $ProcessId) $null = $ProcessId; $script:HolderStart } -Clock $script:Clock -Sleep $script:Sleep

            # Assert
            $result.Decision | Should -Be 'Timeout'
            $result.HolderDescription | Should -BeLike 'suite pytest (pid 4242*'
            ($script:Now - $script:Start).TotalMilliseconds | Should -Be 90000
            $script:Slept.Count | Should -Be 45
            @($script:Slept | Select-Object -Unique) | Should -Be @(2000)
        }

        It 'acquires after two sleeps when the probe reports Busy twice then Free' {
            # Arrange
            $script:Probes = [System.Collections.Generic.Queue[string]]::new([string[]] @('Busy', 'Busy', 'Free'))

            # Act
            $result = Invoke-TestExecutionLockWait -Probe { $script:Probes.Dequeue() } -ReadHolder { $null } -GetProcessStartUtc { param([int] $ProcessId) $null = $ProcessId; $null } -Clock $script:Clock -Sleep $script:Sleep

            # Assert
            $result.Decision | Should -Be 'Acquire'
            $script:Slept.Count | Should -Be 2
        }

        It 'returns Skip without probing when the lock is disabled' {
            # Arrange
            $script:Probed = 0

            # Act
            $result = Invoke-TestExecutionLockWait -Enabled $false -Probe { $script:Probed++; 'Busy' } -ReadHolder { $null } -GetProcessStartUtc { param([int] $ProcessId) $null = $ProcessId; $null } -Clock $script:Clock -Sleep $script:Sleep

            # Assert
            $result.Decision | Should -Be 'Skip'
            $script:Probed | Should -Be 0
        }

        It 'honors a custom wait and poll interval' {
            # Act
            $result = Invoke-TestExecutionLockWait -WaitMilliseconds 4000 -PollMilliseconds 1000 -Probe { 'Busy' } -ReadHolder { $null } -GetProcessStartUtc { param([int] $ProcessId) $null = $ProcessId; $null } -Clock $script:Clock -Sleep $script:Sleep

            # Assert
            $result.Decision | Should -Be 'Timeout'
            $script:Slept.Count | Should -Be 4
            @($script:Slept | Select-Object -Unique) | Should -Be @(1000)
        }
    }
}
