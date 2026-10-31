<#
.SYNOPSIS
Returns the default worker count of the local concurrent Pester runner (issue #1048).
.DESCRIPTION
Returns the floor of half the logical processor count, at least 1 and at most 8. Each worker is a pwsh
process that runs coverage instrumentation and, in some suites, starts further processes, so half the
logical processors leaves capacity for those children.
.PARAMETER LogicalProcessorCount
The logical processor count of the machine, for example [Environment]::ProcessorCount.
#>
function Get-PoshQCParallelWorkerCount {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][int] $LogicalProcessorCount
    )

    [int] [math]::Max(1, [math]::Min(8, [math]::Floor($LogicalProcessorCount / 2)))
}

<#
.SYNOPSIS
Loads one JUnit XML text into an XmlDocument for the merge and weight functions (issue #1048).
.DESCRIPTION
Disables external resolution and throws a message that names the report position when the text is not
well-formed XML or its root element is not testsuites.
.PARAMETER JunitText
The XML text of one JUnit report.
.PARAMETER Position
The one-based position of the report, used in error messages.
#>
function ConvertFrom-PoshQCJunitXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $JunitText,
        [Parameter(Mandatory)][int] $Position
    )

    $document = New-Object System.Xml.XmlDocument
    $document.XmlResolver = $null
    try {
        $document.LoadXml($JunitText)
    } catch {
        throw "JUnit report $Position is not well-formed XML: $($_.Exception.Message)"
    }
    if ($document.DocumentElement.LocalName -ne 'testsuites') {
        throw "JUnit report $Position has the root element '$($document.DocumentElement.LocalName)'; expected 'testsuites'."
    }
    $document
}

<#
.SYNOPSIS
Merges the JUnit reports written by the shards of one test run into one report (issue #1048).
.DESCRIPTION
Takes XML text only (no file I/O). The merged root keeps the attributes of the first report, carries every
testsuite element of every report in input order with id renumbered from 0, and sets tests, errors,
failures, and disabled to the sums over the reports. The root time is the largest root time of any report:
the shards run at the same time, so the longest shard is the wall-clock time of the run. Throws when no
report is supplied or a report is not well-formed JUnit XML. Returns the merged XML text.
.PARAMETER JunitText
The XML text of each shard's JUnit report; at least one is required.
#>
function Merge-PoshQCJunitReport {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $JunitText
    )

    if ($JunitText.Count -lt 1) {
        throw 'Merge-PoshQCJunitReport requires at least one JUnit report.'
    }

    $documents = @(for ($position = 0; $position -lt $JunitText.Count; $position++) {
            ConvertFrom-PoshQCJunitXml -JunitText $JunitText[$position] -Position ($position + 1)
        })
    # Capture every report's suites first, because the merged document is the first report and its suites are
    # removed from the root before all suites are appended again in input order.
    $suiteLists = @(foreach ($document in $documents) { , @($document.DocumentElement.SelectNodes('testsuite')) })
    $merged = $documents[0]
    $root = $merged.DocumentElement
    foreach ($suite in $suiteLists[0]) {
        [void] $root.RemoveChild($suite)
    }

    # Sum the root counters and keep the original text of the largest root time over all reports.
    $totals = [ordered]@{ tests = [long] 0; errors = [long] 0; failures = [long] 0; disabled = [long] 0 }
    $longestTime = [double] 0
    $longestTimeText = '0'
    $nextId = 0
    for ($position = 0; $position -lt $documents.Count; $position++) {
        $shardRoot = $documents[$position].DocumentElement
        foreach ($name in @($totals.Keys)) {
            $totals[$name] += [long] ('0' + $shardRoot.GetAttribute($name))
        }
        $timeText = $shardRoot.GetAttribute('time')
        $time = [double] 0
        if ([double]::TryParse($timeText, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref] $time) -and $time -gt $longestTime) {
            $longestTime = $time
            $longestTimeText = $timeText
        }
        foreach ($suite in $suiteLists[$position]) {
            $imported = $merged.ImportNode($suite, $true)
            $imported.SetAttribute('id', [string] $nextId)
            $nextId++
            [void] $root.AppendChild($imported)
        }
    }

    foreach ($name in $totals.Keys) {
        $root.SetAttribute($name, [string] $totals[$name])
    }
    $root.SetAttribute('time', $longestTimeText)
    $merged.OuterXml
}

<#
.SYNOPSIS
Converts shard JUnit reports into the measured shard-weights document (issue #1048).
.DESCRIPTION
Maps the name of each testsuite element, an absolute path on the machine that ran it, to a
repository-relative forward-slash path that starts at its first 'tests' or 'scripts' segment; a name with
neither segment is skipped. Sums the seconds of each file over every report and returns an ordered
dictionary with version 1, unit 'ms', and files keyed in ordinal order with values rounded to integer
milliseconds. Takes XML text only (no file I/O).
.PARAMETER JunitText
The XML text of each JUnit report to read.
#>
function ConvertTo-PoshQCShardWeight {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $JunitText
    )

    $seconds = New-Object 'System.Collections.Generic.Dictionary[string,double]' ([System.StringComparer]::Ordinal)
    for ($position = 0; $position -lt $JunitText.Count; $position++) {
        $document = ConvertFrom-PoshQCJunitXml -JunitText $JunitText[$position] -Position ($position + 1)
        foreach ($suite in @($document.DocumentElement.SelectNodes('testsuite'))) {
            $segments = @(($suite.GetAttribute('name') -replace '\\', '/') -split '/' | Where-Object { $_ -ne '' })
            # The repository-relative path starts at the first 'tests' or 'scripts' segment, the scan-folder roots.
            $anchor = -1
            for ($index = 0; $index -lt $segments.Count; $index++) {
                if ($segments[$index] -ceq 'tests' -or $segments[$index] -ceq 'scripts') {
                    $anchor = $index
                    break
                }
            }
            if ($anchor -lt 0) {
                continue
            }
            $relativePath = $segments[$anchor..($segments.Count - 1)] -join '/'
            $time = [double] 0
            [void] [double]::TryParse($suite.GetAttribute('time'), [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref] $time)
            $current = [double] 0
            [void] $seconds.TryGetValue($relativePath, [ref] $current)
            $seconds[$relativePath] = $current + $time
        }
    }

    [string[]] $keys = @($seconds.Keys)
    [System.Array]::Sort($keys, [System.StringComparer]::Ordinal)
    $files = [ordered]@{}
    foreach ($key in $keys) {
        $files[$key] = [long] [math]::Round($seconds[$key] * 1000, [System.MidpointRounding]::AwayFromZero)
    }
    [ordered]@{ version = 1; unit = 'ms'; files = $files }
}

<#
.SYNOPSIS
Writes config/poshqc-shard-weights.json from JUnit report files (issue #1048).
.DESCRIPTION
Reads each JUnit file through ReadText, converts the reports with ConvertTo-PoshQCShardWeight, and writes the
JSON document through WriteText. Use the shard JUnit files of a full CI run, because local durations differ
from the CI runner's.
.PARAMETER JunitPath
Paths of the JUnit report files to read.
.PARAMETER OutputPath
Path of the weights file to write.
.PARAMETER ReadText
Seam that returns the text of a file from its path. Defaults to Get-Content -Raw.
.PARAMETER WriteText
Seam that writes text to a path. Defaults to Set-Content with UTF-8 encoding.
#>
function Export-PoshQCShardWeight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]] $JunitPath,
        [Parameter(Mandatory)][string] $OutputPath,
        [scriptblock] $ReadText = { param([string] $Path) Get-Content -Raw -LiteralPath $Path },
        [scriptblock] $WriteText = { param([string] $Path, [string] $Text) Set-Content -LiteralPath $Path -Value $Text -Encoding utf8 }
    )

    $texts = [string[]] @($JunitPath | ForEach-Object { [string] (& $ReadText $_) })
    $document = ConvertTo-PoshQCShardWeight -JunitText $texts
    & $WriteText $OutputPath ($document | ConvertTo-Json -Depth 4)
}

<#
.SYNOPSIS
Returns the pwsh argument list that runs one shard of Invoke-PoshQCTest (issue #1048).
.DESCRIPTION
The command imports the PoshQC manifest and runs Invoke-PoshQCTest with the shard index and count and
the per-shard JUnit, coverage, and manifest paths, without the Koverage copy. Paths are single-quoted.
.PARAMETER ModuleManifestPath
Path of PoshQC.psd1.
.PARAMETER Root
Workspace root.
.PARAMETER ShardIndex
One-based shard index.
.PARAMETER ShardCount
Number of shards.
.PARAMETER ShardDirectory
Directory that receives the shard's JUnit, coverage, and manifest files.
#>
function Get-PoshQCParallelShardArgument {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][string] $ModuleManifestPath,
        [Parameter(Mandatory)][string] $Root,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [Parameter(Mandatory)][string] $ShardDirectory
    )

    $quote = { param([string] $Text) "'" + $Text.Replace("'", "''") + "'" }
    $values = @(
        (& $quote $ModuleManifestPath),
        (& $quote $Root),
        $ShardIndex,
        $ShardCount,
        (& $quote (Join-Path $ShardDirectory 'shard-files.json')),
        (& $quote (Join-Path $ShardDirectory 'pester-junit.xml')),
        (& $quote (Join-Path $ShardDirectory 'powershell-coverage.xml'))
    )
    $command = 'Import-Module {0}; Invoke-PoshQCTest -Root {1} -ShardIndex {2} -ShardCount {3} -ShardFileListPath {4} -TestResultPath {5} -CoverageOutputPath {6} -DisableKoverageCopy' -f $values
    [string[]] @('-NoLogo', '-NoProfile', '-NonInteractive', '-Command', $command)
}

<#
.SYNOPSIS
Starts one pwsh child process with its output redirected to a log file (issue #1048).
.DESCRIPTION
Wrapper seam around the pwsh executable, so tests mock this function instead of the process cmdlet.
Start-Process joins the arguments with spaces, so an argument that contains whitespace is double-quoted.
Standard output goes to LogPath and standard error to LogPath with '.err' appended. Returns the process.
.PARAMETER PwshArgs
Arguments passed to pwsh.
.PARAMETER LogPath
Path of the standard-output log file.
#>
function Invoke-PoshQCPwshExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]] $PwshArgs,
        [Parameter(Mandatory)][string] $LogPath
    )

    $quoted = @($PwshArgs | ForEach-Object { if ($_ -match '\s') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ } })
    $process = Start-Process -FilePath 'pwsh' -ArgumentList $quoted -RedirectStandardOutput $LogPath -RedirectStandardError ($LogPath + '.err') -NoNewWindow -PassThru
    # Reading Handle keeps the exit code available after the process has exited.
    $null = $process.Handle
    $process
}

<#
.SYNOPSIS
Checks and merges the outputs of the finished shards of a concurrent run (issue #1048).
.DESCRIPTION
Returns 1 without writing a merged artifact when a shard exited non-zero, when a shard wrote no JUnit,
coverage, or manifest file, when the manifests fail Test-PoshQCShardCompleteness, or when a merge fails,
so a partial result never replaces a full one. Otherwise writes artifacts/pester/pester-junit.xml,
artifacts/pester/powershell-coverage.xml, and its Koverage copy, and returns 0.
.PARAMETER Root
Workspace root.
.PARAMETER Shard
The shard records (ShardIndex, Directory, ExitCode) of the run.
.PARAMETER ReadText
Seam that returns the text of a file, or $null when it does not exist.
.PARAMETER WriteText
Seam that writes text to a path.
.PARAMETER Logger
Seam that receives progress and failure messages.
#>
function Invoke-PoshQCParallelMerge {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][string] $Root,
        [Parameter(Mandatory)][object[]] $Shard,
        [Parameter(Mandatory)][scriptblock] $ReadText,
        [Parameter(Mandatory)][scriptblock] $WriteText,
        [Parameter(Mandatory)][scriptblock] $Logger
    )

    $failed = @($Shard | Where-Object { $_.ExitCode -ne 0 })
    if ($failed.Count -gt 0) {
        & $Logger ("Shards {0} exited non-zero; see their logs. No merged artifact was written." -f (@($failed | ForEach-Object { $_.ShardIndex }) -join ', '))
        return 1
    }

    # Read every shard's three outputs; a missing output stops the merge before anything is written.
    $outputs = @(foreach ($record in $Shard) {
            [pscustomobject]@{
                ShardIndex = $record.ShardIndex
                Junit      = & $ReadText (Join-Path $record.Directory 'pester-junit.xml')
                Coverage   = & $ReadText (Join-Path $record.Directory 'powershell-coverage.xml')
                Manifest   = & $ReadText (Join-Path $record.Directory 'shard-files.json')
            }
        })
    foreach ($output in $outputs) {
        foreach ($name in @('Junit', 'Coverage', 'Manifest')) {
            if ([string]::IsNullOrWhiteSpace($output.$name)) {
                & $Logger "Shard $($output.ShardIndex) wrote no $name output. No merged artifact was written."
                return 1
            }
        }
    }

    try {
        $null = Test-PoshQCShardCompleteness -ShardManifest @($outputs | ForEach-Object { $_.Manifest | ConvertFrom-Json })
    } catch {
        & $Logger "Shard completeness check failed: $($_.Exception.Message) No merged artifact was written."
        return 1
    }

    try {
        $junit = Merge-PoshQCJunitReport -JunitText @($outputs | ForEach-Object { [string] $_.Junit })
        $coverage = Merge-PoshQCCoverageReport -CoverageXml @($outputs | ForEach-Object { [string] $_.Coverage })
        $koverage = Convert-PoshQCCoverageToRelative -InputContent $coverage -RepoRoot $Root -PassThru
    } catch {
        & $Logger "Merging the shard outputs failed: $($_.Exception.Message) No merged artifact was written."
        return 1
    }

    $outputDirectory = Join-Path $Root 'artifacts/pester'
    & $WriteText (Join-Path $outputDirectory 'pester-junit.xml') $junit
    & $WriteText (Join-Path $outputDirectory 'powershell-coverage.xml') $coverage
    & $WriteText (Join-Path $outputDirectory 'powershell-coverage.koverage.xml') ([string] $koverage)
    & $Logger "Wrote the merged JUnit and coverage reports under $outputDirectory."
    0
}

<#
.SYNOPSIS
Runs the Pester suite as concurrent shard processes on one machine and merges the results (issue #1048).
.DESCRIPTION
Starts one pwsh child per shard. Each child imports the PoshQC module and runs Invoke-PoshQCTest with
-ShardIndex, -ShardCount, and per-shard JUnit, coverage, and manifest paths under
artifacts/pester/parallel/shard-<i>/, writing its console output to shard.log in that directory. After
every child has exited, Invoke-PoshQCParallelMerge verifies completeness and writes the merged
artifacts/pester/pester-junit.xml, artifacts/pester/powershell-coverage.xml, and the Koverage copy, but
only when every child exited 0 and wrote all of its outputs. Never calls exit.
Returns an object with ExitCode (0 only on full success), WorkerCount, WallClockSeconds, and Shards
(ShardIndex, ExitCode, LogPath).
.PARAMETER Root
Workspace root. Defaults to the current location.
.PARAMETER WorkerCount
Number of shard processes. Defaults to Get-PoshQCParallelWorkerCount over [Environment]::ProcessorCount.
.PARAMETER ResetShardDirectory
Seam that empties or creates one shard directory.
.PARAMETER StartShardProcess
Seam that starts pwsh with an argument list and a log path and returns the process.
.PARAMETER WaitShardProcess
Seam that waits for a started process and returns its exit code.
.PARAMETER ReadText
Seam that returns the text of a file, or $null when it does not exist.
.PARAMETER WriteText
Seam that writes text to a path.
.PARAMETER Clock
Seam that returns the current UTC time.
.PARAMETER Logger
Seam that receives progress and summary messages.
#>
function Invoke-PoshQCParallelTest {
    [CmdletBinding()]
    param(
        [string] $Root,
        [ValidateRange(1, [int]::MaxValue)][int] $WorkerCount,
        [scriptblock] $ResetShardDirectory = {
            param([string] $Path)
            if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Recurse -Force }
            $null = New-Item -ItemType Directory -Path $Path -Force
        },
        [scriptblock] $StartShardProcess = { param([string[]] $ArgumentList, [string] $LogPath) Invoke-PoshQCPwshExe -PwshArgs $ArgumentList -LogPath $LogPath },
        [scriptblock] $WaitShardProcess = {
            param($Process)
            # Wait on the held process object: a lookup by id fails once a fast shard has already exited.
            $Process.WaitForExit()
            [int] $Process.ExitCode
        },
        [scriptblock] $ReadText = {
            param([string] $Path)
            if (Test-Path -LiteralPath $Path) { Get-Content -Raw -LiteralPath $Path } else { $null }
        },
        [scriptblock] $WriteText = { param([string] $Path, [string] $Text) Set-Content -LiteralPath $Path -Value $Text -Encoding utf8 },
        [scriptblock] $Clock = { [DateTime]::UtcNow },
        [scriptblock] $Logger = { param([string] $Message) Write-Information $Message -InformationAction Continue }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $Root) {
        $Root = $PWD.ProviderPath
    }
    if (-not [IO.Path]::IsPathRooted($Root)) {
        $Root = [IO.Path]::GetFullPath([IO.Path]::Combine($PWD.ProviderPath, $Root))
    }
    if (-not $PSBoundParameters.ContainsKey('WorkerCount')) {
        $WorkerCount = Get-PoshQCParallelWorkerCount -LogicalProcessorCount ([Environment]::ProcessorCount)
    }

    $started = & $Clock
    $manifestPath = Join-Path $script:ModuleRoot 'PoshQC.psd1'
    $parallelDirectory = Join-Path $Root 'artifacts/pester/parallel'

    # Start every shard before waiting for any, so the shards run at the same time.
    $shards = @(foreach ($index in 1..$WorkerCount) {
            $directory = Join-Path $parallelDirectory "shard-$index"
            & $ResetShardDirectory $directory
            $logPath = Join-Path $directory 'shard.log'
            $arguments = Get-PoshQCParallelShardArgument -ModuleManifestPath $manifestPath -Root $Root -ShardIndex $index -ShardCount $WorkerCount -ShardDirectory $directory
            [pscustomobject]@{
                ShardIndex = $index
                Directory  = $directory
                LogPath    = $logPath
                Process    = & $StartShardProcess $arguments $logPath
                ExitCode   = $null
            }
        })
    & $Logger "Started $WorkerCount shard processes; logs are under $parallelDirectory."

    foreach ($shard in $shards) {
        $shard.ExitCode = [int] (& $WaitShardProcess $shard.Process)
        & $Logger "Shard $($shard.ShardIndex) exited with code $($shard.ExitCode); log: $($shard.LogPath)"
    }

    $exitCode = Invoke-PoshQCParallelMerge -Root $Root -Shard $shards -ReadText $ReadText -WriteText $WriteText -Logger $Logger
    $wallClockSeconds = [math]::Round(((& $Clock) - $started).TotalSeconds, 2)
    & $Logger ('Invoke-PoshQCParallelTest: workers={0}; wall-clock={1}s; exit code={2}' -f $WorkerCount, $wallClockSeconds.ToString([System.Globalization.CultureInfo]::InvariantCulture), $exitCode)

    [pscustomobject]@{
        ExitCode         = [int] $exitCode
        WorkerCount      = $WorkerCount
        WallClockSeconds = $wallClockSeconds
        Shards           = @($shards | ForEach-Object { [pscustomobject]@{ ShardIndex = $_.ShardIndex; ExitCode = $_.ExitCode; LogPath = $_.LogPath } })
    }
}
