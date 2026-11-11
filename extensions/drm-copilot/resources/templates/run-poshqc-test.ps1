[CmdletBinding()]
param(
    [Parameter()]
    [string] $WorkspaceRoot = ".",

    [Parameter()]
    [string[]] $ScanFolders,

    [Parameter()]
    [string] $ScanFoldersJson,

    [Parameter()]
    [switch] $DisableKoverageCopy,

    [Parameter()]
    [string] $KoverageOutputPath,

    # Issue #1158 (spec D7, D32): seams of the machine test-suite lock branch. Each default is the real call.
    [Parameter()]
    [scriptblock] $TestPath = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf },

    [Parameter()]
    [scriptblock] $ImportHelper = { param([string] $Path) . $Path },

    [Parameter()]
    [scriptblock] $ReadConfigText = { param([string] $Path) if (Test-Path -LiteralPath $Path -PathType Leaf) { Get-Content -LiteralPath $Path -Raw } else { $null } },

    [Parameter()]
    [scriptblock] $GetLockDirectory = { Get-TestExecutionCurrentLockDirectory },

    [Parameter()]
    [hashtable] $LockSeams = @{},

    [Parameter()]
    [scriptblock] $Clock = { [datetime]::UtcNow },

    [Parameter()]
    [scriptblock] $Sleep = { param([int] $Milliseconds) Start-Sleep -Milliseconds $Milliseconds },

    [Parameter()]
    [scriptblock] $WriteStandardError = { param([string] $Line) [Console]::Error.WriteLine($Line) }
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$poshQcModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"
Import-Module $poshQcModulePath -Force

$resolvedScanFolders = $ScanFolders
if (-not [string]::IsNullOrWhiteSpace($ScanFoldersJson)) {
    $resolvedScanFolders = @(
        ConvertFrom-Json -InputObject $ScanFoldersJson
    ) | ForEach-Object { [string] $_ }
}

# Issue #1158: when the test-execution helpers exist in the workspace (.claude/hooks, else .codex/hooks),
# the run holds the machine test-suite lock and excludes the configured local lanes; otherwise it runs as before.
$helperFolder = $null
foreach ($candidateFolder in @('.claude/hooks', '.codex/hooks')) {
    if (& $TestPath (Join-Path $WorkspaceRoot "$candidateFolder/test-execution-lock.ps1")) { $helperFolder = $candidateFolder; break }
}
if ($null -eq $helperFolder) {
    Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders $resolvedScanFolders -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath
    return
}

foreach ($helperName in @('test-execution-policy.ps1', 'test-execution-lock-decision.ps1', 'test-execution-lock.ps1')) {
    . $ImportHelper (Join-Path $WorkspaceRoot "$helperFolder/$helperName")
}
$configText = & $ReadConfigText (Join-Path $WorkspaceRoot 'config/test-execution-policy.json')
$policy = Get-TestExecutionPolicy -ReadText { $configText }
$excludedLanes = @(Get-TestExecutionExcludedLane -Policy $policy)
$laneArguments = @{}
$laneTags = @($excludedLanes | ForEach-Object { @($_.Lane['pesterTags']) })
$laneSuffixes = @($excludedLanes | ForEach-Object { @($_.Lane['fileNameSuffixes']) })
if ($laneTags.Count -gt 0) { $laneArguments['ExcludeTag'] = [string[]]$laneTags }
if ($laneSuffixes.Count -gt 0) { $laneArguments['ExcludeTestFileSuffix'] = [string[]]$laneSuffixes }

$machineLock = $policy['machineLock']
$lockState = @{ Stream = $null; Directory = $null }
$lockSeamTable = $LockSeams
$seamOf = { param([string] $Name) $splat = @{}; if ($lockSeamTable.ContainsKey($Name)) { $splat[$Name] = $lockSeamTable[$Name] }; $splat }
if ([bool] $machineLock['enabled']) {
    $lockState.Directory = & $GetLockDirectory
    $decision = Invoke-TestExecutionLockWait -Enabled $true -WaitMilliseconds ([int] $machineLock['waitMilliseconds']) -PollMilliseconds ([int] $machineLock['pollMilliseconds']) -CurrentProcessId $PID -Clock $Clock -Sleep $Sleep -Probe {
        $openSeam = & $seamOf 'OpenLockStream'
        $opened = Open-TestExecutionLock -Directory $lockState.Directory @openSeam
        if ($opened.Result -eq 'Free') { $lockState.Stream = $opened.Stream }
        $opened.Result
    } -ReadHolder {
        $readSeam = & $seamOf 'ReadHolderText'
        Read-TestExecutionHolderText -Directory $lockState.Directory @readSeam
    } -GetProcessStartUtc {
        param([int] $Id)
        $startSeam = & $seamOf 'GetProcessStartUtc'
        Get-TestExecutionProcessStartTime -ProcessId $Id @startSeam
    }
    if ($decision.Decision -eq 'Timeout') {
        & $WriteStandardError (Get-TestExecutionQueueTimeoutMessage -HolderDescription $decision.HolderDescription -WaitedMilliseconds ([int] $machineLock['waitMilliseconds']))
        exit 75
    }
}

try {
    if ($null -ne $lockState.Stream) {
        $startSeam = & $seamOf 'GetProcessStartUtc'
        $processStart = Get-TestExecutionProcessStartTime -ProcessId $PID @startSeam
        if ($null -eq $processStart) { $processStart = [datetime] (& $Clock) }
        $holderText = New-TestExecutionHolderRecord -ProcessId $PID -ProcessStartUtc $processStart -Suite 'pester' -CommandLine @('run-poshqc-test.ps1') -WorktreeRoot $WorkspaceRoot -AcquiredAtUtc ([datetime] (& $Clock)) -PolicyVersion ([int] $policy['version'])
        $writeSeam = & $seamOf 'WriteHolderText'
        Write-TestExecutionHolderRecord -Directory $lockState.Directory -Text $holderText @writeSeam
    }
    Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders $resolvedScanFolders -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath @laneArguments
} finally {
    if ($null -ne $lockState.Stream) {
        # Remove the record before releasing the lock, so a waiter that acquires next never loses its own record.
        $removeSeam = & $seamOf 'RemoveHolderFile'
        Remove-TestExecutionHolderRecord -Directory $lockState.Directory @removeSeam
        $lockState.Stream.Dispose()
    }
}
