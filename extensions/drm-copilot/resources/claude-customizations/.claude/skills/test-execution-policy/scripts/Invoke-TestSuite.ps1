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

    Run-scope record (issue #1228, spec D11): after a suite returns, whatever its exit code, the launcher
    writes artifacts/test-execution/run-scope.<suite>.json beneath the repository root with the keys
    schema_version, suite, runner, scope, started_utc, and completed_utc; scope is 'selection' when the
    caller's words select part of the suite (Get-TestSuiteRunScope) and 'full' otherwise, and the two
    instants are clock readings taken immediately before and after the suite runs. A refusal, a queue
    timeout, and a thrown suite write no record. A write failure prints one stderr line starting
    TEST_EXECUTION_RUN_SCOPE_UNWRITTEN: and leaves the exit code unchanged. The feature-review coverage
    hook reads the record to tell a selection report from a full report.

    The script-file entry runs only when the script is not dot-sourced; it reads the optional hashtable
    variable TestSuiteLauncherSeams from the caller's scope and splats it onto Invoke-TestSuiteLauncher.
    Through pwsh -File, PowerShell splits a word that starts with '-' and contains ':' into two $args
    elements and drops the colon, so the entry takes the words after this script's path on the process
    command line (Get-TestSuiteScriptArgument) and falls back to $args when the process was not started
    for this script.
#>

function Get-TestSuiteScriptArgument {
    <#
    .SYNOPSIS
        Return the launcher's script arguments as the process received them (D18).
    .DESCRIPTION
        Finds this script on the process command line: an element whose leaf name equals ScriptLeaf and
        that follows a -File form (-File, -f, -fi, -fil, case-insensitive) or is the host's first argument.
        Returns the elements after it unchanged, so --cov-report=json:C:/r.json stays one word. Returns the
        bound arguments, as strings, when no such element exists (a call through & or from another host).
    .PARAMETER BoundArgument
        The script's $args.
    .PARAMETER CommandLineArgument
        The process command line, element 0 being the host.
    .PARAMETER ScriptLeaf
        The leaf file name of this script.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [AllowEmptyCollection()][AllowNull()][object[]] $BoundArgument = @(),
        [AllowEmptyCollection()][AllowNull()][string[]] $CommandLineArgument = @(),
        [Parameter(Mandatory)][string] $ScriptLeaf
    )

    $commandLine = @($CommandLineArgument)
    # Walk the host's arguments for the first script operand that names this script; the words after it
    # are this script's arguments exactly as the caller passed them.
    for ($index = 1; $index -lt $commandLine.Count; $index++) {
        $leaf = ([string] $commandLine[$index] -split '[\\/]')[-1]
        if (-not [string]::Equals($leaf, $ScriptLeaf, [System.StringComparison]::OrdinalIgnoreCase)) { continue }
        $follows = ($index -eq 1) -or ([string] $commandLine[$index - 1] -match '^-(f|fi|fil|file)$')
        if ($follows) {
            return , [string[]] @($commandLine | Select-Object -Skip ($index + 1))
        }
    }
    return , [string[]] @(@($BoundArgument) | Where-Object { $null -ne $_ } | ForEach-Object { [string] $_ })
}

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

function Get-TestSuiteRunScope {
    <#
    .SYNOPSIS
        Return 'selection' when the caller's words select part of a suite, otherwise 'full' (issue #1228).
    .DESCRIPTION
        pester: a word equal to -TestPath, ignoring case. pytest: a word not starting with '-' that ends
        with .py or contains ::, a word -k or starting with -k, or a word --deselect or starting with
        --deselect=. jest: a word starting with --testPathPattern or --testNamePattern; a word -t, -o,
        --findRelatedTests, or --onlyChanged, or starting with --changedSince; or a word not starting with
        '-' that names a .test. or .spec. JavaScript or TypeScript file. Every other word list and every
        other runner is 'full'.
    .PARAMETER Runner
        The suite's runner.
    .PARAMETER ArgumentList
        The caller's extra words.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Runner,
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @()
    )

    $ordinal = [System.StringComparison]::Ordinal
    foreach ($word in @($ArgumentList)) {
        $operand = -not $word.StartsWith('-', $ordinal)
        $selects = switch -CaseSensitive ($Runner) {
            'pester' { [string]::Equals($word, '-TestPath', [System.StringComparison]::OrdinalIgnoreCase) }
            'pytest' {
                ($operand -and ($word.EndsWith('.py', $ordinal) -or $word.Contains('::'))) -or
                $word.StartsWith('-k', $ordinal) -or $word -ceq '--deselect' -or $word.StartsWith('--deselect=', $ordinal)
            }
            'jest' {
                $word.StartsWith('--testPathPattern', $ordinal) -or $word.StartsWith('--testNamePattern', $ordinal) -or
                $word.StartsWith('--changedSince', $ordinal) -or @('-t', '-o', '--findRelatedTests', '--onlyChanged') -ccontains $word -or
                ($operand -and $word -cmatch '\.(test|spec)\.[cm]?[jt]sx?$')
            }
            default { $false }
        }
        if ($selects) { return 'selection' }
    }
    return 'full'
}

function New-TestSuiteRunScopeRecord {
    <#
    .SYNOPSIS
        Return the compact JSON run-scope record of one suite run (issue #1228).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that writes no file.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Suite,
        [Parameter(Mandatory)][string] $Runner,
        [Parameter(Mandatory)][ValidateSet('selection', 'full')][string] $Scope,
        [Parameter(Mandatory)][datetime] $StartedUtc,
        [Parameter(Mandatory)][datetime] $CompletedUtc
    )

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $record = [ordered]@{
        schema_version = 1
        suite          = $Suite
        runner         = $Runner
        scope          = $Scope
        started_utc    = $StartedUtc.ToUniversalTime().ToString('o', $culture)
        completed_utc  = $CompletedUtc.ToUniversalTime().ToString('o', $culture)
    }
    return ($record | ConvertTo-Json -Compress)
}

function Write-TestSuiteRunScopeRecord {
    <#
    .SYNOPSIS
        Write a run-scope record as UTF-8 text without a byte-order mark, creating its folder (issue #1228).
    .PARAMETER Path
        The record path beneath the repository root.
    .PARAMETER Text
        The record text.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Text
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Write the test-suite run-scope record')) {
        $folder = Split-Path -Parent $Path
        if (-not (Test-Path -LiteralPath $folder -PathType Container)) { $null = New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop }
        Set-Content -LiteralPath $Path -Value $Text -NoNewline -Encoding utf8NoBOM -ErrorAction Stop
    }
}

function Invoke-TestSuiteLauncher {
    <#
    .SYNOPSIS
        Run launcher steps 1 through 7 and return the exit code.
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
    .PARAMETER WriteRunScope
        Seam that writes the run-scope record text to a path (issue #1228).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $ArgumentList = @(),
        [string] $RepositoryRoot = (Split-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) -Parent),
        [string] $LauncherDirectory = (Split-Path -Parent $PSCommandPath),
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
        [scriptblock] $RecordClassifierInput = { param([string[]] $ExtraArgument) [void] $ExtraArgument },
        [scriptblock] $WriteRunScope = { param([string] $Path, [string] $Text) Write-TestSuiteRunScopeRecord -Path $Path -Text $Text }
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
        $startedUtc = [datetime](& $Clock)
        $exitCode = [int](& $StartSuiteProcess $words[0] ([string[]]@($words | Select-Object -Skip 1)) $workingDirectory)
        $completedUtc = [datetime](& $Clock)
    } finally {
        if ($null -ne $lockState.Stream) {
            # Remove the record before releasing the lock, so a waiter that acquires next never loses its own record.
            $removeSeam = & $seamOf 'RemoveHolderFile'
            Remove-TestExecutionHolderRecord -Directory $lockState.Directory @removeSeam
            $lockState.Stream.Dispose()
        }
    }

    # Step 7 (issue #1228): record whether this run covered the whole suite or a selection of it.
    $runScopePath = Join-Path $RepositoryRoot "artifacts/test-execution/run-scope.$suiteName.json"
    $runScopeText = New-TestSuiteRunScopeRecord -Suite $suiteName -Runner $runner -Scope (Get-TestSuiteRunScope -Runner $runner -ArgumentList $extras) -StartedUtc $startedUtc -CompletedUtc $completedUtc
    try {
        & $WriteRunScope $runScopePath $runScopeText
    } catch {
        & $WriteStandardError "TEST_EXECUTION_RUN_SCOPE_UNWRITTEN: the run-scope record '$runScopePath' was not written ($(([string]$_.Exception.Message -split "`r?`n")[0])); the suite exit code is unchanged (test-execution policy)."
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
    $scriptArgument = Get-TestSuiteScriptArgument -BoundArgument $args -CommandLineArgument ([Environment]::GetCommandLineArgs()) -ScriptLeaf ([System.IO.Path]::GetFileName($PSCommandPath))
    exit (Invoke-TestSuiteLauncher -ArgumentList $scriptArgument @launcherSeamTable)
}
