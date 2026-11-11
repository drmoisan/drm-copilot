<#
.SYNOPSIS
    Pure machine test-suite lock decision and wait driver (issue #1158).

.DESCRIPTION
    Get-TestExecutionLockDecision maps the lock-decision state model of the specification to
    Skip, Acquire, AcquireReplacingStaleRecord, Wait, or Timeout. The holder description
    names the holder only when the process seam confirms the recorded start time.
    Invoke-TestExecutionLockWait drives the decision through Clock, Sleep, Probe,
    ReadHolder, and GetProcessStartUtc seams, so no test waits in real time. Nothing is
    written to any stream when the file is dot-sourced.

    Dot-sourced as: . (Join-Path $PSScriptRoot 'test-execution-lock-decision.ps1')
#>

function ConvertTo-TestExecutionUtcTick {
    <#
    .SYNOPSIS
        Return the UTC ticks of a DateTime or a round-trip date string, or $null.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param([AllowNull()] $Value)

    if ($Value -is [datetime]) { return $Value.ToUniversalTime().Ticks }
    if ($Value -is [datetimeoffset]) { return $Value.UtcTicks }
    if ($Value -is [string] -and -not [string]::IsNullOrWhiteSpace($Value)) {
        $parsed = [datetime]::MinValue
        if ([datetime]::TryParse($Value, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind, [ref] $parsed)) {
            return $parsed.ToUniversalTime().Ticks
        }
    }
    return $null
}

function ConvertFrom-TestExecutionHolderText {
    <#
    .SYNOPSIS
        Parse holder-record text into a record with State Absent, Unparseable, or Parsed.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return [pscustomobject]@{ State = 'Absent'; Record = $null } }
    try {
        $record = ConvertFrom-Json -InputObject $Text -AsHashtable -ErrorAction Stop
    } catch {
        return [pscustomobject]@{ State = 'Unparseable'; Record = $null }
    }
    $pidValue = if ($record -is [System.Collections.IDictionary]) { $record['pid'] } else { $null }
    if ($pidValue -isnot [int] -and $pidValue -isnot [long]) { return [pscustomobject]@{ State = 'Unparseable'; Record = $null } }
    return [pscustomobject]@{ State = 'Parsed'; Record = $record }
}

function Get-TestExecutionLockHolderDescription {
    <#
    .SYNOPSIS
        Describe the lock holder for a busy-lock message.
    .DESCRIPTION
        Named holder (suite, pid, worktree) when ProcessStartUtc is less than one second from the
        recorded processStartUtc; "an unidentified process (stale record for pid N)" when the process
        is missing, its start time differs, or the record names the current process; and
        "an unidentified process" when no record is readable.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] $HolderRecord,
        [AllowNull()] $ProcessStartUtc,
        [int] $CurrentProcessId = -1
    )

    if ($null -eq $HolderRecord -or $HolderRecord.State -ne 'Parsed') { return 'an unidentified process' }
    $record = $HolderRecord.Record
    $holderPid = [long] $record['pid']
    $stale = "an unidentified process (stale record for pid $holderPid)"
    if ($holderPid -eq $CurrentProcessId) { return $stale }
    $recorded = ConvertTo-TestExecutionUtcTick $record['processStartUtc']
    $observed = ConvertTo-TestExecutionUtcTick $ProcessStartUtc
    # The start time is read again by another process; Linux derives it from boot time and clock ticks, so two
    # reads of one process can differ by milliseconds. Times less than one second apart identify the same process.
    if ($null -eq $recorded -or $null -eq $observed -or [math]::Abs($recorded - $observed) -ge [timespan]::TicksPerSecond) { return $stale }
    return "suite $($record['suite']) (pid $holderPid, worktree $($record['worktreeRoot']))"
}

function Get-TestExecutionLockDecision {
    <#
    .SYNOPSIS
        Return the lock decision and holder description for one probe.
    .OUTPUTS
        PSCustomObject with Decision (Skip, Acquire, AcquireReplacingStaleRecord, Wait,
        Timeout) and HolderDescription.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][bool] $Enabled,
        [ValidateSet('Free', 'Busy')][string] $ProbeResult = 'Free',
        [AllowNull()] $HolderRecord,
        [AllowNull()] $ProcessStartUtc,
        [datetime] $StartedAtUtc = [datetime]::MinValue,
        [datetime] $NowUtc = [datetime]::MinValue,
        [int] $WaitMilliseconds = 90000,
        [int] $CurrentProcessId = -1
    )

    if (-not $Enabled) { return [pscustomobject]@{ Decision = 'Skip'; HolderDescription = '' } }
    $hasRecord = $null -ne $HolderRecord -and $HolderRecord.State -ne 'Absent'
    if ($ProbeResult -eq 'Free') {
        $decision = 'Acquire'
        if ($hasRecord) { $decision = 'AcquireReplacingStaleRecord' }
        return [pscustomobject]@{ Decision = $decision; HolderDescription = '' }
    }
    $description = Get-TestExecutionLockHolderDescription -HolderRecord $HolderRecord -ProcessStartUtc $ProcessStartUtc -CurrentProcessId $CurrentProcessId
    $elapsed = ($NowUtc - $StartedAtUtc).TotalMilliseconds
    $decision = 'Wait'
    if ($elapsed -ge $WaitMilliseconds) { $decision = 'Timeout' }
    return [pscustomobject]@{ Decision = $decision; HolderDescription = $description }
}

function Get-TestExecutionQueueTimeoutMessage {
    <#
    .SYNOPSIS
        Return the queue-timeout stderr line of launcher step 5.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $HolderDescription, [int] $WaitedMilliseconds)

    return "TEST_EXECUTION_QUEUE_TIMEOUT: test-execution policy allows one suite per machine; lock held by $HolderDescription; waited $WaitedMilliseconds ms; retry later."
}

function Invoke-TestExecutionLockWait {
    <#
    .SYNOPSIS
        Probe the lock until it is acquired or the bounded wait elapses.
    .DESCRIPTION
        Probe returns Free or Busy; ReadHolder returns the holder text or $null;
        GetProcessStartUtc receives a pid and returns its start time or $null; Clock returns
        the current UTC time; Sleep receives the poll interval in milliseconds. Returns the
        final decision object (Skip, Acquire, AcquireReplacingStaleRecord, or Timeout).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][scriptblock] $Probe,
        [Parameter(Mandatory)][scriptblock] $ReadHolder,
        [Parameter(Mandatory)][scriptblock] $GetProcessStartUtc,
        [Parameter(Mandatory)][scriptblock] $Clock,
        [Parameter(Mandatory)][scriptblock] $Sleep,
        [bool] $Enabled = $true,
        [int] $WaitMilliseconds = 90000,
        [int] $PollMilliseconds = 2000,
        [int] $CurrentProcessId = -1
    )

    if (-not $Enabled) { return (Get-TestExecutionLockDecision -Enabled $false) }
    $started = [datetime] (& $Clock)
    while ($true) {
        $probeResult = [string] (& $Probe)
        $holder = ConvertFrom-TestExecutionHolderText -Text (& $ReadHolder)
        $processStart = $null
        if ($probeResult -eq 'Busy' -and $holder.State -eq 'Parsed') { $processStart = & $GetProcessStartUtc ([int] $holder.Record['pid']) }
        $result = Get-TestExecutionLockDecision -Enabled $true -ProbeResult $probeResult -HolderRecord $holder -ProcessStartUtc $processStart -StartedAtUtc $started -NowUtc ([datetime] (& $Clock)) -WaitMilliseconds $WaitMilliseconds -CurrentProcessId $CurrentProcessId
        if ($result.Decision -ne 'Wait') { return $result }
        & $Sleep $PollMilliseconds
    }
}
