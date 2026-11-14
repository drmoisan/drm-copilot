<#
.SYNOPSIS
    Thin I/O adapter for the machine test-suite lock (issue #1158).

.DESCRIPTION
    Resolves the per-user lock directory, probes and holds the OS advisory lock on
    test-suite.lock (FileStream, OpenOrCreate, ReadWrite, FileShare.None), and reads, writes,
    and removes the holder record test-suite.holder.json. Every filesystem and process call
    goes through a scriptblock seam whose default performs the real operation. Starts no
    process. Nothing is written to any stream when the file is dot-sourced.

    Dot-sourced as: . (Join-Path $PSScriptRoot 'test-execution-lock.ps1')
#>

$script:TestExecutionLockFileName = 'test-suite.lock'
$script:TestExecutionHolderFileName = 'test-suite.holder.json'

function Get-TestExecutionLockDirectory {
    <#
    .SYNOPSIS
        Return the lock directory from injected platform values (pure).
    .DESCRIPTION
        Windows: LocalApplicationData joined with drm-copilot/test-execution. Other
        platforms: XDG_STATE_HOME, or HOME/.local/state when it is unset or blank, joined
        with drm-copilot/test-execution. XDG_RUNTIME_DIR is not used.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][bool] $IsWindowsPlatform,
        [AllowEmptyString()][string] $LocalApplicationData = '',
        [AllowEmptyString()][string] $XdgStateHome = '',
        [AllowEmptyString()][string] $HomeDirectory = ''
    )

    $base = $LocalApplicationData
    if (-not $IsWindowsPlatform) {
        $base = $XdgStateHome
        if ([string]::IsNullOrWhiteSpace($base)) { $base = [System.IO.Path]::Join($HomeDirectory, '.local', 'state') }
    }
    if ([string]::IsNullOrWhiteSpace($base)) { throw 'TEST_EXECUTION_POLICY_BLOCKED: the machine test-suite lock directory cannot be resolved (test-execution policy).' }
    return [System.IO.Path]::Join($base, 'drm-copilot', 'test-execution')
}

function Get-TestExecutionCurrentLockDirectory {
    <#
    .SYNOPSIS
        Return the lock directory for the current host from the environment.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return (Get-TestExecutionLockDirectory -IsWindowsPlatform $IsWindows -LocalApplicationData ([Environment]::GetFolderPath('LocalApplicationData')) -XdgStateHome ([string] $env:XDG_STATE_HOME) -HomeDirectory ([string] $env:HOME))
}

function Get-TestExecutionLockPath {
    <#
    .SYNOPSIS
        Return the lock file path or the holder record path in Directory.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Directory,
        [ValidateSet('Lock', 'Holder')][string] $Kind = 'Lock'
    )

    $leaf = $script:TestExecutionLockFileName
    if ($Kind -eq 'Holder') { $leaf = $script:TestExecutionHolderFileName }
    return [System.IO.Path]::Join($Directory, $leaf)
}

function Open-TestExecutionLock {
    <#
    .SYNOPSIS
        Probe and hold the lock: return Free with the held stream, or Busy with no stream.
    .DESCRIPTION
        OpenLockStream receives the lock path and returns an open exclusive stream; an
        IOException from it means another process holds the lock.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Directory,
        [scriptblock] $OpenLockStream = { param([string] $Path) $null = [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($Path)); [System.IO.FileStream]::new($Path, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None) }
    )

    $path = Get-TestExecutionLockPath -Directory $Directory -Kind 'Lock'
    if (-not $PSCmdlet.ShouldProcess($path, 'Open the machine test-suite lock')) { return [pscustomobject]@{ Result = 'Busy'; Stream = $null } }
    try {
        $stream = & $OpenLockStream $path
    } catch [System.IO.IOException] {
        return [pscustomobject]@{ Result = 'Busy'; Stream = $null }
    } catch {
        if ($_.Exception.InnerException -is [System.IO.IOException]) { return [pscustomobject]@{ Result = 'Busy'; Stream = $null } }
        throw
    }
    return [pscustomobject]@{ Result = 'Free'; Stream = $stream }
}

function Read-TestExecutionHolderText {
    <#
    .SYNOPSIS
        Return the holder record text, or $null when it is absent or unreadable.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Directory,
        [scriptblock] $ReadHolderText = { param([string] $Path) if (-not [System.IO.File]::Exists($Path)) { return $null }; $s = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete); try { [System.IO.StreamReader]::new($s).ReadToEnd() } finally { $s.Dispose() } }
    )

    $path = Get-TestExecutionLockPath -Directory $Directory -Kind 'Holder'
    try {
        return (& $ReadHolderText $path)
    } catch [System.IO.IOException] {
        return $null
    } catch {
        if ($_.Exception.InnerException -is [System.IO.IOException]) { return $null }
        throw
    }
}

function New-TestExecutionHolderRecord {
    <#
    .SYNOPSIS
        Return the holder record text with the seven fields of the specification.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that returns record text and changes no system state.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][int] $ProcessId,
        [Parameter(Mandatory)][datetime] $ProcessStartUtc,
        [Parameter(Mandatory)][string] $Suite,
        [AllowEmptyCollection()][string[]] $CommandLine = @(),
        [AllowEmptyString()][string] $WorktreeRoot = '',
        [Parameter(Mandatory)][datetime] $AcquiredAtUtc,
        [int] $PolicyVersion = 1
    )

    $record = [ordered]@{
        pid             = $ProcessId
        processStartUtc = $ProcessStartUtc.ToUniversalTime().ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
        suite           = $Suite
        commandLine     = @($CommandLine)
        worktreeRoot    = $WorktreeRoot
        acquiredAtUtc   = $AcquiredAtUtc.ToUniversalTime().ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
        policyVersion   = $PolicyVersion
    }
    return (ConvertTo-Json -InputObject $record -Depth 4 -Compress)
}

function Write-TestExecutionHolderRecord {
    <#
    .SYNOPSIS
        Write the holder record text, shared for reading by waiters (FileShare.Read).
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Directory,
        [Parameter(Mandatory)][string] $Text,
        [scriptblock] $WriteHolderText = { param([string] $Path, [string] $Content) $s = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read); try { $w = [System.IO.StreamWriter]::new($s); $w.Write($Content); $w.Flush() } finally { $s.Dispose() } }
    )

    $path = Get-TestExecutionLockPath -Directory $Directory -Kind 'Holder'
    if ($PSCmdlet.ShouldProcess($path, 'Write the test-suite holder record')) { & $WriteHolderText $path $Text }
}

function Remove-TestExecutionHolderRecord {
    <#
    .SYNOPSIS
        Remove the holder record.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Directory,
        [scriptblock] $RemoveHolderFile = { param([string] $Path) if ([System.IO.File]::Exists($Path)) { [System.IO.File]::Delete($Path) } }
    )

    $path = Get-TestExecutionLockPath -Directory $Directory -Kind 'Holder'
    if ($PSCmdlet.ShouldProcess($path, 'Remove the test-suite holder record')) { & $RemoveHolderFile $path }
}

function Get-TestExecutionProcessStartTime {
    <#
    .SYNOPSIS
        Return the UTC start time of ProcessId, or $null when the process does not exist.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param(
        [Parameter(Mandatory)][int] $ProcessId,
        [scriptblock] $GetProcessStartUtc = { param([int] $Id) $p = Get-Process -Id $Id -ErrorAction Ignore; if ($null -ne $p) { $p.StartTime.ToUniversalTime() } }
    )

    try {
        $start = & $GetProcessStartUtc $ProcessId
    } catch [System.ComponentModel.Win32Exception], [System.InvalidOperationException] {
        # The process exited or its start time is not readable; treat the record as stale.
        return $null
    }
    if ($start -is [datetime]) { return $start.ToUniversalTime() }
    return $null
}
