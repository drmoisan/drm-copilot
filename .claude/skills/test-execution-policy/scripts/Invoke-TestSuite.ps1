<#
.SYNOPSIS
    The test-execution launcher (issue #1158, spec ### Launcher, D18, D26, D27, D32): runs one configured
    test suite under the machine test-suite lock with the local integration and golden lanes excluded.

.DESCRIPTION
    Usage: pwsh -NoProfile -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 <suite> [extra arguments]
    (or sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh <suite> [extra arguments]).

    The script has no param block and no CmdletBinding: the suite name is the first element of $args and
    the remaining elements reach the classifier and the suite unchanged. Exit codes: the suite's own code;
    2 with a first stderr line starting TEST_EXECUTION_POLICY_BLOCKED: for invalid configuration, a missing
    or unknown suite, a lane selection, or a worker-reduction token; 75 with TEST_EXECUTION_QUEUE_TIMEOUT:
    when the lock stays busy; a suite's own 75 is reported as 1 with a TEST_EXECUTION_SUITE_EXIT: line.

    The script-file entry runs only when the script is not dot-sourced; it reads the optional hashtable
    variable TestSuiteLauncherSeams from the caller's scope and splats it onto Invoke-TestSuiteLauncher.
#>

function New-TestSuiteProcessStartInfo {
    <#
    .SYNOPSIS
        Return the ProcessStartInfo of one suite: no shell, one ArgumentList entry per word, inherited streams.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that starts no process.')]
    [CmdletBinding()]
    [OutputType([System.Diagnostics.ProcessStartInfo])]
    param(
        [Parameter(Mandatory)][string] $FilePath,
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @(),
        [Parameter(Mandatory)][string] $WorkingDirectory
    )

    $info = [System.Diagnostics.ProcessStartInfo]::new($FilePath)
    $info.UseShellExecute = $false
    $info.WorkingDirectory = $WorkingDirectory
    foreach ($word in $ArgumentList) { $info.ArgumentList.Add($word) }
    return $info
}

function Invoke-TestSuiteLauncher {
    <#
    .SYNOPSIS
        Run launcher steps 1 through 6 and return the exit code.
    .PARAMETER ArgumentList
        The suite name followed by the extra arguments.
    .PARAMETER RepositoryRoot
        The repository root; defaults to the fourth parent directory of the script folder.
    .PARAMETER LauncherDirectory
        The launcher's own folder; its repository-relative path joined with Invoke-PesterSuite.ps1 is the
        pester suite script.
    .PARAMETER StartSuiteProcess
        Seam that starts FilePath with ArgumentList in WorkingDirectory, waits, and returns the exit code.
    .PARAMETER ReadConfigText
        Seam that returns the text of config/test-execution-policy.json, or $null when it is absent.
    .PARAMETER TestPath
        Seam that reports whether a helper file exists.
    .PARAMETER ImportHelper
        Seam, dot-invoked, that loads one helper file.
    .PARAMETER GetLockDirectory
        Seam that returns the machine lock directory.
    .PARAMETER OpenLockStream
        Optional lock adapter seam (Open-TestExecutionLock).
    .PARAMETER ReadHolderText
        Optional lock adapter seam (Read-TestExecutionHolderText).
    .PARAMETER WriteHolderText
        Optional lock adapter seam (Write-TestExecutionHolderRecord).
    .PARAMETER RemoveHolderFile
        Optional lock adapter seam (Remove-TestExecutionHolderRecord).
    .PARAMETER GetProcessStartUtc
        Optional lock adapter seam (Get-TestExecutionProcessStartTime).
    .PARAMETER Clock
        Seam that returns the current UTC time.
    .PARAMETER Sleep
        Seam that waits the poll interval in milliseconds.
    .PARAMETER WriteStandardError
        Seam that writes one line to standard error.
    .PARAMETER RecordClassifierInput
        Seam that receives the extra arguments exactly as the classifier receives them.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @(),
        [string] $RepositoryRoot = (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))),
        [string] $LauncherDirectory = $PSScriptRoot,
        [scriptblock] $StartSuiteProcess = {
            param([string] $FilePath, [string[]] $ArgumentList, [string] $WorkingDirectory)
            $process = [System.Diagnostics.Process]::Start((New-TestSuiteProcessStartInfo -FilePath $FilePath -ArgumentList $ArgumentList -WorkingDirectory $WorkingDirectory))
            try { $process.WaitForExit(); $process.ExitCode } finally { $process.Dispose() }
        },
        [scriptblock] $ReadConfigText = { param([string] $Path) if (Test-Path -LiteralPath $Path -PathType Leaf) { Get-Content -LiteralPath $Path -Raw } else { $null } },
        [scriptblock] $TestPath = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf },
        [scriptblock] $ImportHelper = { param([string] $Path) . $Path },
        [scriptblock] $GetLockDirectory = { Get-TestExecutionCurrentLockDirectory },
        [scriptblock] $OpenLockStream,
        [scriptblock] $ReadHolderText,
        [scriptblock] $WriteHolderText,
        [scriptblock] $RemoveHolderFile,
        [scriptblock] $GetProcessStartUtc,
        [scriptblock] $Clock = { [datetime]::UtcNow },
        [scriptblock] $Sleep = { param([int] $Milliseconds) Start-Sleep -Milliseconds $Milliseconds },
        [scriptblock] $WriteStandardError = { param([string] $Line) [Console]::Error.WriteLine($Line) },
        [scriptblock] $RecordClassifierInput = { param([string[]] $ExtraArgument) [void] $ExtraArgument }
    )

    # Step 0 (spec D32): load the helpers from .claude/hooks, else .codex/hooks.
    $helperFolder = $null
    foreach ($candidateFolder in @('.claude/hooks', '.codex/hooks')) {
        if (& $TestPath (Join-Path $RepositoryRoot "$candidateFolder/test-execution-policy.ps1")) { $helperFolder = $candidateFolder; break }
    }
    if ($null -eq $helperFolder) {
        & $WriteStandardError 'TEST_EXECUTION_POLICY_BLOCKED: the test-execution helpers were not found under .claude/hooks or .codex/hooks (test-execution policy).'
        return 2
    }
    foreach ($helperName in @('test-execution-policy.ps1', 'test-execution-lock-decision.ps1', 'test-execution-lock.ps1')) {
        . $ImportHelper (Join-Path $RepositoryRoot "$helperFolder/$helperName")
    }

    # Step 1: load the policy.
    $relativeLauncher = [System.IO.Path]::GetRelativePath($RepositoryRoot, $LauncherDirectory).Replace('\', '/')
    $configText = & $ReadConfigText (Join-Path $RepositoryRoot 'config/test-execution-policy.json')
    try {
        $policy = Get-TestExecutionPolicy -ReadText { $configText } -PesterSuiteScript "$relativeLauncher/Invoke-PesterSuite.ps1"
    } catch {
        & $WriteStandardError $_.Exception.Message
        return 2
    }

    # Step 2: resolve the suite.
    $knownSuites = (@($policy['suites'].Keys) -join ', ')
    if ($ArgumentList.Count -eq 0 -or [string]::IsNullOrWhiteSpace($ArgumentList[0])) {
        & $WriteStandardError "TEST_EXECUTION_POLICY_BLOCKED: no test suite named; known suites: $knownSuites (test-execution policy)."
        return 2
    }
    $suiteName = $ArgumentList[0]
    if (-not $policy['suites'].Contains($suiteName)) {
        & $WriteStandardError "TEST_EXECUTION_POLICY_BLOCKED: unknown test suite '$suiteName'; known suites: $knownSuites (test-execution policy)."
        return 2
    }
    $suite = $policy['suites'][$suiteName]
    $runner = [string]$suite['runner']

    # Step 3: classify the extra arguments.
    $extras = [string[]]@($ArgumentList | Select-Object -Skip 1)
    & $RecordClassifierInput $extras
    $lane = Get-TestExecutionLaneSelection -Policy $policy -Runner $runner -ArgumentList $extras
    if ($lane) {
        & $WriteStandardError "TEST_EXECUTION_POLICY_BLOCKED: local $lane lane is CI-only evidence (test-execution policy)."
        return 2
    }
    $workerToken = Get-TestExecutionWorkerReductionToken -Runner $runner -ArgumentList $extras
    if ($workerToken) {
        & $WriteStandardError "TEST_EXECUTION_POLICY_BLOCKED: worker-reduction token '$workerToken' is not allowed for the $runner runner; the machine test-suite lock serializes suites instead (test-execution policy)."
        return 2
    }

    # Step 4: build the command.
    $words = [string[]]@(New-TestExecutionSuiteCommand -Policy $policy -SuiteName $suiteName -ExtraArgument $extras)
    $workingDirectory = if ($suite.Contains('workingDirectory') -and $suite['workingDirectory']) { Join-Path $RepositoryRoot ([string]$suite['workingDirectory']) } else { $RepositoryRoot }

    # Step 5: acquire the machine lock.
    $adapterSeams = @{ OpenLockStream = $OpenLockStream; ReadHolderText = $ReadHolderText; WriteHolderText = $WriteHolderText; RemoveHolderFile = $RemoveHolderFile; GetProcessStartUtc = $GetProcessStartUtc }
    $seamOf = { param([string] $Name) $splat = @{}; if ($null -ne $adapterSeams[$Name]) { $splat[$Name] = $adapterSeams[$Name] }; $splat }
    $machineLock = $policy['machineLock']
    $lockState = @{ Stream = $null; Directory = $null }
    if ([bool]$machineLock['enabled']) {
        $lockState.Directory = & $GetLockDirectory
        $decision = Invoke-TestExecutionLockWait -Enabled $true -WaitMilliseconds ([int]$machineLock['waitMilliseconds']) -PollMilliseconds ([int]$machineLock['pollMilliseconds']) -CurrentProcessId $PID -Clock $Clock -Sleep $Sleep -Probe {
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
            & $WriteStandardError (Get-TestExecutionQueueTimeoutMessage -HolderDescription $decision.HolderDescription -WaitedMilliseconds ([int]$machineLock['waitMilliseconds']))
            return 75
        }
    }

    # Step 6: run the suite, then release the lock.
    try {
        if ($null -ne $lockState.Stream) {
            $startSeam = & $seamOf 'GetProcessStartUtc'
            $processStart = Get-TestExecutionProcessStartTime -ProcessId $PID @startSeam
            if ($null -eq $processStart) { $processStart = [datetime](& $Clock) }
            $holderText = New-TestExecutionHolderRecord -ProcessId $PID -ProcessStartUtc $processStart -Suite $suiteName -CommandLine $words -WorktreeRoot $RepositoryRoot -AcquiredAtUtc ([datetime](& $Clock)) -PolicyVersion ([int]$policy['version'])
            $writeSeam = & $seamOf 'WriteHolderText'
            Write-TestExecutionHolderRecord -Directory $lockState.Directory -Text $holderText @writeSeam
        }
        $exitCode = [int](& $StartSuiteProcess $words[0] ([string[]]@($words | Select-Object -Skip 1)) $workingDirectory)
    } finally {
        if ($null -ne $lockState.Stream) {
            # Remove the record before releasing the lock, so a waiter that acquires next never loses its own record.
            $removeSeam = & $seamOf 'RemoveHolderFile'
            Remove-TestExecutionHolderRecord -Directory $lockState.Directory @removeSeam
            $lockState.Stream.Dispose()
        }
    }
    if ($exitCode -eq 75) {
        & $WriteStandardError "TEST_EXECUTION_SUITE_EXIT: suite '$suiteName' exited with code 75, reported as 1 because 75 is reserved for the queue timeout (test-execution policy)."
        return 1
    }
    return $exitCode
}

if ($MyInvocation.InvocationName -ne '.') {
    $launcherSeamTable = Get-Variable -Name TestSuiteLauncherSeams -ValueOnly -ErrorAction Ignore
    if ($launcherSeamTable -isnot [hashtable]) { $launcherSeamTable = @{} }
    exit (Invoke-TestSuiteLauncher -ArgumentList $args @launcherSeamTable)
}
