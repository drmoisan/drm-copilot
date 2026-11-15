<#
.SYNOPSIS
    Selects and verifies the pytest files of one coverage shard for the Python 3.13 CI legs (issue #1190).

.DESCRIPTION
    Select mode (the shard job): enumerates tests/**/test_*.py, orders the files by ordinal root-relative
    forward-slash path, weighs each file by its LF-normalized UTF-8 byte count, and assigns the files to
    shards with Select-PoshQCShardTestFile of PoshQC.Shard.psm1 (the module is reused unchanged). It writes
    the manifest artifacts/python/shard-files.json and the file list artifacts/python/shard-files.txt, and
    throws when the shard selects no file.

    Verify mode (the combine job): loads every shard manifest and JUnit report, checks with
    Test-PoshQCShardCompleteness that the shards cover every test file exactly once, and checks with
    Test-PoshQCShardTestCount that the JUnit test counts sum to the count that pytest --collect-only -q
    prints in its "N tests collected" summary.

    The logic lives in functions with injected seams (enumeration, file read, file write, file search), and a
    thin guarded entry call follows the Invoke-CiRequiredGate.ps1 pattern: the entry runs only when the script
    is executed, never when it is dot-sourced by the tests.
.PARAMETER Mode
    Select or Verify.
.PARAMETER RootPath
    Repository root. Defaults to the current location.
.PARAMETER ShardIndex
    One-based shard index (Select mode).
.PARAMETER ShardCount
    Total number of shards (Select mode).
.PARAMETER ShardRoot
    Folder searched recursively for shard-files.json and junit-shard-*.xml (Verify mode).
.PARAMETER CollectCountText
    The text printed by pytest --collect-only -q (Verify mode).
#>
param(
    [ValidateSet('Select', 'Verify')][string] $Mode = 'Select',
    [string] $RootPath = (Get-Location).Path,
    [int] $ShardIndex = 1,
    [int] $ShardCount = 1,
    [string] $ShardRoot = 'artifacts/shards',
    [string] $CollectCountText = ''
)

Set-StrictMode -Version Latest
Import-Module (Join-Path -Path (Join-Path -Path (Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'powershell') -ChildPath 'PoshQC') -ChildPath 'PoshQC.Shard.psm1')

function Get-PythonTestFilePath {
    <#
    .SYNOPSIS
        Returns the full paths of tests/**/test_*.py under a root; the only enumeration boundary of Select mode.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)][string] $RootPath
    )

    $testRoot = Join-Path -Path $RootPath -ChildPath 'tests'
    [string[]] @(Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter 'test_*.py' | ForEach-Object { $_.FullName })
}

function Read-PythonShardFileText {
    <#
    .SYNOPSIS
        Returns the text of one file; the default read boundary of both modes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    [System.IO.File]::ReadAllText($Path)
}

function Write-PythonShardFileText {
    <#
    .SYNOPSIS
        Writes text to a file, creating its folder first; the default write boundary of Select mode.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Write shard file')) {
        $folder = Split-Path -Parent $Path
        if ($folder) {
            New-Item -ItemType Directory -Force -Path $folder | Out-Null
        }
        Set-Content -LiteralPath $Path -Value $Text -NoNewline -Encoding utf8NoBOM
    }
}

function Find-PythonShardFile {
    <#
    .SYNOPSIS
        Returns the full paths of files named by a filter under a folder, in ordinal order; the search boundary of Verify mode.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)][string] $Folder,
        [Parameter(Mandatory = $true)][string] $Filter
    )

    [string[]] @(Get-ChildItem -LiteralPath $Folder -Recurse -File -Filter $Filter | ForEach-Object { $_.FullName } | Sort-Object)
}

function Get-PythonTestShardSelection {
    <#
    .SYNOPSIS
        Selects this shard's pytest files and writes the shard manifest and file list.
    .DESCRIPTION
        Orders the enumerated files by ordinal root-relative forward-slash path, reads each file's text through
        ReadTestFileText, and builds items whose Length is the UTF-8 byte count of the text with CRLF replaced
        by LF, so a CRLF checkout and an LF checkout produce one assignment. The items go to
        Select-PoshQCShardTestFile with a ReadWeightsText seam that returns $null, so the PowerShell millisecond
        weights file is never read. Returns this shard's root-relative forward-slash paths in manifest order.
        Throws when the shard selects no file.
    .PARAMETER RootPath
        Repository root.
    .PARAMETER ShardIndex
        One-based shard index.
    .PARAMETER ShardCount
        Total number of shards.
    .PARAMETER OutputDirectory
        Root-relative folder that receives shard-files.json and shard-files.txt.
    .PARAMETER EnumerateTestFile
        Seam returning the full paths of the test files under RootPath.
    .PARAMETER ReadTestFileText
        Seam returning the text of a test file from its full path.
    .PARAMETER WriteFile
        Seam receiving a path and text to write.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)][string] $RootPath,
        [Parameter(Mandatory = $true)][int] $ShardIndex,
        [Parameter(Mandatory = $true)][int] $ShardCount,
        [string] $OutputDirectory = 'artifacts/python',
        [scriptblock] $EnumerateTestFile = { param([string] $Root) Get-PythonTestFilePath -RootPath $Root },
        [scriptblock] $ReadTestFileText = { param([string] $Path) Read-PythonShardFileText -Path $Path },
        [scriptblock] $WriteFile = { param([string] $Path, [string] $Text) Write-PythonShardFileText -Path $Path -Text $Text }
    )

    $prefix = ($RootPath -replace '\\', '/').TrimEnd('/') + '/'
    $toRelative = {
        param([string] $FullPath)
        $normalized = $FullPath -replace '\\', '/'
        if ($normalized.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { $normalized.Substring($prefix.Length) } else { $normalized }
    }

    [string[]] $fullPaths = @(& $EnumerateTestFile $RootPath)
    $fullByRelative = @{}
    foreach ($fullPath in $fullPaths) {
        $fullByRelative[[string] (& $toRelative $fullPath)] = $fullPath
    }
    [string[]] $relativeOrder = @($fullByRelative.Keys)
    [System.Array]::Sort($relativeOrder, [System.StringComparer]::Ordinal)

    # Weigh each file by the byte size of its LF-normalized text, in ordinal path order.
    $items = @(foreach ($relative in $relativeOrder) {
            $text = [string] (& $ReadTestFileText $fullByRelative[$relative])
            [pscustomobject]@{
                FullName = $fullByRelative[$relative]
                Length   = [long] [System.Text.Encoding]::UTF8.GetByteCount($text.Replace("`r`n", "`n"))
            }
        })

    $writeManifest = { param([string] $Path, [string] $Json) & $WriteFile $Path $Json }.GetNewClosure()
    $selectedFullPath = Select-PoshQCShardTestFile -RootPath $RootPath -TestFile $items -ShardIndex $ShardIndex -ShardCount $ShardCount `
        -ShardFileListPath "$OutputDirectory/shard-files.json" -WriteShardFileList $writeManifest -ReadWeightsText { $null }
    [string[]] $selected = @($selectedFullPath | ForEach-Object { & $toRelative $_ })
    & $WriteFile "$OutputDirectory/shard-files.txt" (($selected -join "`n") + "`n")
    $selected
}

function Get-PythonCollectedTestCount {
    <#
    .SYNOPSIS
        Parses the "N tests collected" summary of pytest --collect-only -q and returns N.
    .DESCRIPTION
        Throws when the text carries no such summary line.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $CollectCountText
    )

    $match = [regex]::Match($CollectCountText, '(?m)^\s*(\d+) tests? collected')
    if (-not $match.Success) {
        throw 'The pytest collection output carries no "N tests collected" summary line.'
    }
    [int] $match.Groups[1].Value
}

function Test-PythonTestShardResult {
    <#
    .SYNOPSIS
        Verifies shard completeness and that the JUnit test counts sum to the collected count.
    .DESCRIPTION
        Parses each manifest JSON, calls Test-PoshQCShardCompleteness, sums the tests attribute of every
        testsuite element across the JUnit texts, and calls Test-PoshQCShardTestCount against the count parsed
        from CollectCountText. Any failure throws; returns $true otherwise.
    .PARAMETER ManifestJson
        The texts of the shard-files.json manifests.
    .PARAMETER JUnitXml
        The texts of the shard JUnit reports.
    .PARAMETER CollectCountText
        The text printed by pytest --collect-only -q.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string[]] $ManifestJson,
        [Parameter(Mandatory = $true)][string[]] $JUnitXml,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $CollectCountText
    )

    $manifests = @($ManifestJson | ForEach-Object { $_ | ConvertFrom-Json })
    Test-PoshQCShardCompleteness -ShardManifest $manifests | Out-Null
    [int[]] $shardTestCounts = @(foreach ($text in $JUnitXml) {
            $suiteTotal = 0
            foreach ($suite in ([xml] $text).SelectNodes('//testsuite')) {
                $suiteTotal += [int] $suite.GetAttribute('tests')
            }
            $suiteTotal
        })
    $collected = Get-PythonCollectedTestCount -CollectCountText $CollectCountText
    Test-PoshQCShardTestCount -ShardTestCount $shardTestCounts -DiscoveryCount $collected | Out-Null
    $true
}

function Invoke-PythonTestShardEntry {
    <#
    .SYNOPSIS
        Runs the selected mode with the default seams and returns the process exit code (0 or 1).
    .DESCRIPTION
        Select mode writes the manifest artifacts and reports the selected count; Verify mode reads the
        manifests and JUnit reports under ShardRoot. A throw is reported on the error stream and maps to 1.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Select', 'Verify')][string] $Mode,
        [Parameter(Mandatory = $true)][string] $RootPath,
        [int] $ShardIndex = 1,
        [int] $ShardCount = 1,
        [string] $ShardRoot = 'artifacts/shards',
        [AllowEmptyString()][string] $CollectCountText = '',
        [scriptblock] $FindFile = { param([string] $Folder, [string] $Filter) Find-PythonShardFile -Folder $Folder -Filter $Filter },
        [scriptblock] $ReadText = { param([string] $Path) Read-PythonShardFileText -Path $Path },
        [scriptblock] $OutputWriter = { param([string] $Text) Write-Information -MessageData $Text -InformationAction Continue }
    )

    try {
        if ($Mode -ceq 'Select') {
            $selected = @(Get-PythonTestShardSelection -RootPath $RootPath -ShardIndex $ShardIndex -ShardCount $ShardCount)
            & $OutputWriter "Shard $ShardIndex of $ShardCount selected $($selected.Count) test files."
            return 0
        }
        [string[]] $manifestJson = @(& $FindFile $ShardRoot 'shard-files.json' | ForEach-Object { & $ReadText $_ })
        [string[]] $junitXml = @(& $FindFile $ShardRoot 'junit-shard-*.xml' | ForEach-Object { & $ReadText $_ })
        Test-PythonTestShardResult -ManifestJson $manifestJson -JUnitXml $junitXml -CollectCountText $CollectCountText | Out-Null
        & $OutputWriter "Python shard completeness verified for $($manifestJson.Count) shards."
        return 0
    }
    catch {
        Write-Error -Message $_.Exception.Message
        return 1
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $entryParameters = @{ Mode = $Mode; RootPath = $RootPath; ShardIndex = $ShardIndex; ShardCount = $ShardCount; ShardRoot = $ShardRoot; CollectCountText = $CollectCountText }
    if ((Invoke-PythonTestShardEntry @entryParameters) -eq 0) {
        exit 0
    }
    exit 1
}
