<#
.SYNOPSIS
Runs the bundled PoshQC suite in one pass.
.DESCRIPTION
Executes formatting, analysis, and Pester checks against the selected workspace root and scan folders.
#>
function Invoke-PoshQCSuite {
    [CmdletBinding()]
    param(
        [string] $Root,
        [string[]] $ScanFolders,
        [string] $PssaSettingsPath = $script:PssaSettings,
        [string] $PesterSettingsPath = $script:PesterSettings,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [switch] $DisableKoverageCopy,
        [string] $KoverageOutputPath
    )

    $ErrorActionPreference = 'Stop'

    Invoke-PoshQCFormat -Root $Root -ScanFolders $ScanFolders -SettingsPath $PssaSettingsPath -ExcludeDirs $ExcludeDirs
    Invoke-PoshQCAnalyze -Root $Root -ScanFolders $ScanFolders -SettingsPath $PssaSettingsPath -ExcludeDirs $ExcludeDirs
    Invoke-PoshQCTest -Root $Root -ScanFolders $ScanFolders -SettingsPath $PesterSettingsPath -ExcludeDirs $ExcludeDirs -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath
}

<#
.SYNOPSIS
Converts coverage XML paths from absolute to relative.
.DESCRIPTION
Rewrites Pester coverage XML file paths to be relative to the repo root for Koverage compatibility.
.PARAMETER InputPath
Path to input coverage XML file.
.PARAMETER OutputPath
Path to write relative-path coverage XML.
.PARAMETER RepoRoot
Repository root directory for path relativization.
.PARAMETER InputContent
Alternative to InputPath - provide XML content directly.
.PARAMETER PassThru
Return the converted XML content as output.
#>
function Convert-PoshQCCoverageToRelative {
    [CmdletBinding()]
    param(
        [Parameter()][string] $InputPath,
        [Parameter()][string] $OutputPath,
        [Parameter()][string] $RepoRoot,
        [Parameter()][string] $InputContent,
        [switch] $PassThru,
        [scriptblock] $ResolvePath = { param([string] $Path) (Resolve-Path -Path $Path -ErrorAction Stop).Path },
        [scriptblock] $JoinPath = { param([string] $Parent, [string] $Child) Join-Path -Path $Parent -ChildPath $Child },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $ReadContent = { param([string] $Path) Get-Content -Path $Path -Raw },
        [scriptblock] $WriteContent = { param([string] $Path, [string] $Content) Set-Content -Path $Path -Value $Content -Encoding UTF8 },
        [scriptblock] $EnsureDirectory = {
            param([string] $Path)
            $dir = Split-Path -Parent $Path
            if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        },
        [scriptblock] $GetDefaultOutputPath = {
            param([string] $ResolvedInputPath, [string] $ResolvedRoot)
            $coverageDir = if ($ResolvedInputPath) { Split-Path -Parent $ResolvedInputPath } else { $ResolvedRoot }
            $coverageBase = if ($ResolvedInputPath) { [IO.Path]::GetFileNameWithoutExtension($ResolvedInputPath) } else { 'powershell-coverage' }
            Join-Path -Path $coverageDir -ChildPath "$coverageBase.koverage.xml"
        },
        [scriptblock] $Logger = {
            param([string] $Message)
            Write-Information $Message -InformationAction Continue
        }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $RepoRoot) {
        $RepoRoot = $PWD.ProviderPath
    }

    if (-not $InputPath -and -not $InputContent) {
        & $Logger 'No coverage input provided; skipping conversion.'
        return
    }

    $resolvedRoot = $RepoRoot
    try {
        $maybeResolvedRoot = & $ResolvePath $RepoRoot
        if ($maybeResolvedRoot) {
            $resolvedRoot = if ($maybeResolvedRoot -is [string]) { $maybeResolvedRoot } else { $maybeResolvedRoot.Path }
        }
    }
    catch {
        $resolvedRoot = $RepoRoot
    }

    $resolvedInputPath = $null
    if ($InputPath) {
        $resolvedInputPath = if ([IO.Path]::IsPathRooted($InputPath)) { $InputPath } else { & $JoinPath $resolvedRoot $InputPath }
        if (-not (& $TestPathExists $resolvedInputPath)) {
            & $Logger "Coverage file not found; skipping Koverage output: $resolvedInputPath"
            return
        }

        if (-not $InputContent) {
            $InputContent = & $ReadContent $resolvedInputPath
        }
    }

    $repoRootClean = ConvertTo-PoshQCPath $resolvedRoot
    # Normalize to forward slashes for consistent regex matching across platforms
    $repoRootNormalized = $repoRootClean -replace '\\', '/'
    $escapedRoot = [regex]::Escape($repoRootNormalized)
    # Replace forward slashes with character class that matches both separators
    $flexiblePattern = $escapedRoot -replace '/', '[\\/]'
    # Match both forward and backslashes after the path
    $escapedPrefixPattern = "$flexiblePattern[\\/]"
    $fixedContent = $InputContent -replace $escapedPrefixPattern, ''

    if ($PassThru) {
        return $fixedContent
    }

    if (-not $OutputPath) {
        $OutputPath = & $GetDefaultOutputPath $resolvedInputPath $resolvedRoot
    }

    $resolvedOutputPath = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { & $JoinPath $resolvedRoot $OutputPath }
    & $EnsureDirectory $resolvedOutputPath
    & $WriteContent $resolvedOutputPath $fixedContent
    & $Logger "Wrote Koverage coverage copy: $resolvedOutputPath"
}

<#
.SYNOPSIS
Runs Pester tests with coverage reporting.
.DESCRIPTION
Executes Pester tests using repo configuration, generates coverage reports in multiple formats.
.PARAMETER Root
Root directory for test discovery. Defaults to current location.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
.PARAMETER SettingsPath
Path to Pester configuration file.
.PARAMETER ExcludeDirs
Directory names to exclude from test/coverage paths.
.PARAMETER KoverageOutputPath
Custom path for Koverage-compatible coverage XML output.
.PARAMETER DisableKoverageCopy
Skip creation of Koverage-friendly coverage copy.
.PARAMETER ScanFolders
Optional workspace-relative or workspace-contained folders to scan instead of the entire root.
#>
function Invoke-PoshQCTest {
    [CmdletBinding()]
    param(
        [string] $Root,
        [string[]] $ScanFolders,
        [string] $SettingsPath = $script:PesterSettings,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [string] $KoverageOutputPath,
        [switch] $DisableKoverageCopy,
        [scriptblock] $EnsureModule = {
            param([string] $Name, [string] $ErrorMessage)
            if (-not (Get-Module -ListAvailable -Name $Name)) { throw $ErrorMessage }
            Import-Module $Name -ErrorAction Stop
        },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $LoadSettings = { param([string] $Path) Import-PowerShellDataFile -Path $Path },
        [scriptblock] $BuildConfiguration = { param($Settings) New-PesterConfiguration -Hashtable $Settings },
        [scriptblock] $ExpandRunPaths = {
            param($Config, [string] $RootPath, [string[]] $Excluded)
            $initialPaths = if ($Config.Run.Path -is [System.Array]) { @($Config.Run.Path) } elseif ($Config.Run.Path -and $Config.Run.Path.Value) { @($Config.Run.Path.Value) } else { @() }
            if ($initialPaths) {
                $resolvedPaths = @(
                    $initialPaths |
                        ForEach-Object { Join-Path $RootPath $_ } |
                            Where-Object { $Excluded -notcontains (Split-Path -Path $_ -Leaf) }
                )
                $Config.Run.Path = $resolvedPaths
            }

            if ($Excluded) {
                $excludedPaths = @($Excluded | ForEach-Object { Join-Path $RootPath $_ })
                $existingExclude = if ($Config.Run.ExcludePath -is [System.Array]) { @($Config.Run.ExcludePath | ForEach-Object { Join-Path $RootPath $_ }) } elseif ($Config.Run.ExcludePath -and $Config.Run.ExcludePath.Value) { @($Config.Run.ExcludePath.Value | ForEach-Object { Join-Path $RootPath $_ }) } else { @() }
                $Config.Run.ExcludePath = $existingExclude + $excludedPaths
            }

            $Config
        },
        [scriptblock] $EnsureResultPath = {
            param($Config, [string] $RootPath)
            if ($Config.TestResult.Enabled.Value -and $Config.TestResult.OutputPath.Value) {
                $resultPath = $Config.TestResult.OutputPath.Value
                $resultDir = Split-Path -Parent $resultPath
                if (-not [string]::IsNullOrWhiteSpace($resultDir)) {
                    $resolvedResultDir = if ([IO.Path]::IsPathRooted($resultDir)) { $resultDir } else { Join-Path $RootPath $resultDir }
                    New-Item -ItemType Directory -Path $resolvedResultDir -Force | Out-Null
                }
                $Config.TestResult.OutputPath = if ([IO.Path]::IsPathRooted($resultPath)) {
                    $resultPath
                } else {
                    Join-Path $RootPath $resultPath
                }
            }
            $Config
        },
        [scriptblock] $ResolveScanFolders = {
            param([string] $RootPath, [string[]] $Folders)
            Resolve-PoshQCScanFolder -Root $RootPath -ScanFolders $Folders
        },
        [scriptblock] $ExpandCoveragePaths = {
            param($Config, [string] $RootPath)
            if (-not $Config.CodeCoverage) { return $Config }

            if ($Config.CodeCoverage.Path.Value) {
                $Config.CodeCoverage.Path = @(
                    $Config.CodeCoverage.Path.Value | ForEach-Object { if ([IO.Path]::IsPathRooted($_)) { $_ } else { Join-Path $RootPath $_ } }
                )
            }

            if ($Config.CodeCoverage.OutputPath.Value) {
                $coveragePath = $Config.CodeCoverage.OutputPath.Value
                $coverageDir = Split-Path -Parent $coveragePath
                if (-not [string]::IsNullOrWhiteSpace($coverageDir)) {
                    $resolvedCoverageDir = if ([IO.Path]::IsPathRooted($coverageDir)) { $coverageDir } else { Join-Path $RootPath $coverageDir }
                    New-Item -ItemType Directory -Path $resolvedCoverageDir -Force | Out-Null
                }
                $Config.CodeCoverage.OutputPath = if ([IO.Path]::IsPathRooted($coveragePath)) {
                    $coveragePath
                } else {
                    Join-Path $RootPath $coveragePath
                }
            }

            $Config
        },
        [scriptblock] $EnumerateTests = {
            param([string[]] $Paths, [string[]] $Excluded, [scriptblock] $TestPathFn)
            $tests = @()
            foreach ($path in $Paths) {
                if (-not (& $TestPathFn $path)) { continue }
                $tests += Get-ChildItem -Path $path -Recurse -Include *.Tests.ps1 | Where-Object {
                    $parts = $_.FullName -split '[\\/]+' | Where-Object { $_ -ne '' }
                    foreach ($dir in $Excluded) {
                        if ($parts -contains $dir) { return $false }
                    }
                    return $true
                }
            }
            @($tests | Sort-Object -Property FullName -Stable)
        },
        [scriptblock] $Logger = {
            param([string] $Message)
            # Use Write-Information so the replayed summary stays visible while respecting approved verbs.
            Write-Information $Message -InformationAction Continue
        },
        [scriptblock] $InvokePester = { param($Config) Invoke-Pester -Configuration $Config },
        [scriptblock] $CopyCoverage = {
            param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath)
            Convert-PoshQCCoverageToRelative -InputPath $CoveragePath -OutputPath $KoveragePath -RepoRoot $RepoRoot
        }
    )

    $ErrorActionPreference = 'Stop'

    if (-not $Root) {
        $Root = $PWD.ProviderPath
    }

    & $EnsureModule 'Pester' "Pester is not installed. Run Install-PoshQCTool (alias Install-PoshQCTools) first."

    if (-not (& $TestPathExists $SettingsPath)) {
        throw "Settings not found: $SettingsPath"
    }

    $settings = & $LoadSettings $SettingsPath
    $config = & $BuildConfiguration $settings
    $config = & $ExpandRunPaths $config $Root $ExcludeDirs
    $config = & $EnsureResultPath $config $Root
    $config = & $ExpandCoveragePaths $config $Root
    if ($ScanFolders -and $ScanFolders.Count -gt 0) {
        $resolvedScanFolders = @(& $ResolveScanFolders $Root $ScanFolders)
        if ($resolvedScanFolders.Count -gt 0) {
            $config.Run.Path = $resolvedScanFolders
            if ($config.CodeCoverage) {
                $config.CodeCoverage.Path = $resolvedScanFolders
            }
        }
    }

    # Reduce console noise from Pester while we replay a concise summary at the end.
    if ($config.Output -and $config.Output.Verbosity) {
        $config.Output.Verbosity = 'Normal'
    }

    if (-not $config.Run.PassThru) {
        $config.Run.PassThru = $true
    }

    $coverageEnabled = $false
    if ($config.CodeCoverage) {
        if ($config.CodeCoverage.Enabled -is [bool]) {
            $coverageEnabled = $config.CodeCoverage.Enabled
        } elseif ($config.CodeCoverage.Enabled -and $config.CodeCoverage.Enabled.Value) {
            $coverageEnabled = [bool]$config.CodeCoverage.Enabled.Value
        }
    }

    if ($coverageEnabled -and $config.CodeCoverage) {
        if ($config.CodeCoverage.Path.Value) {
            $resolvedCoveragePaths = @(
                $config.CodeCoverage.Path.Value |
                    ForEach-Object {
                        if ([IO.Path]::IsPathRooted($_)) { $_ } else { Join-Path $Root $_ }
                    }
            )
            $config.CodeCoverage.Path = $resolvedCoveragePaths
        }

        if ($config.CodeCoverage.OutputPath.Value) {
            $coveragePath = $config.CodeCoverage.OutputPath.Value
            $coverageDir = Split-Path -Parent $coveragePath
            if (-not [string]::IsNullOrWhiteSpace($coverageDir)) {
                $resolvedCoverageDir = if ([IO.Path]::IsPathRooted($coverageDir)) { $coverageDir } else { Join-Path $Root $coverageDir }
                New-Item -ItemType Directory -Path $resolvedCoverageDir -Force | Out-Null
            }
            $config.CodeCoverage.OutputPath = if ([IO.Path]::IsPathRooted($coveragePath)) {
                $coveragePath
            } else {
                Join-Path $Root $coveragePath
            }
        }
    }

    $coverageOutputPath = $null
    if ($config.CodeCoverage) {
        if ($config.CodeCoverage.OutputPath -is [string]) {
            $coverageOutputPath = $config.CodeCoverage.OutputPath
        } elseif ($config.CodeCoverage.OutputPath -and $config.CodeCoverage.OutputPath.Value) {
            $coverageOutputPath = $config.CodeCoverage.OutputPath.Value
        }
    }

    $runPaths = if ($config.Run.Path -is [System.Array]) { [string[]]$config.Run.Path } elseif ($config.Run.Path -and $config.Run.Path.Value) { [string[]]$config.Run.Path.Value } else { @() }
    $testFiles = & $EnumerateTests $runPaths $ExcludeDirs $TestPathExists
    if (-not $testFiles) {
        & $Logger "No Pester test files found under configured paths for root $Root"
        return
    }

    $pesterResult = & $InvokePester $config

    $shouldEmitKoverageCopy = -not $DisableKoverageCopy
    if ($shouldEmitKoverageCopy -and $coverageEnabled -and $coverageOutputPath) {
        $derivedKoveragePath = $null
        if ($coverageOutputPath) {
            $coverageBaseName = [IO.Path]::GetFileNameWithoutExtension($coverageOutputPath)
            $coverageParent = Split-Path -Parent $coverageOutputPath
            $derivedKoveragePath = Join-Path $coverageParent "$coverageBaseName.koverage.xml"
        }

        $effectiveKoveragePath = if ($PSBoundParameters.ContainsKey('KoverageOutputPath') -and -not [string]::IsNullOrWhiteSpace($KoverageOutputPath)) {
            $KoverageOutputPath
        } else {
            $derivedKoveragePath
        }

        & $CopyCoverage $coverageOutputPath $Root $effectiveKoveragePath
    }

    if ($pesterResult) {
        $durationSeconds = [math]::Round($pesterResult.Duration.TotalSeconds, 2)
        $testsSummary = "Tests completed in {0:N2}s" -f $durationSeconds
        $countsSummary = "Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}" -f `
            $pesterResult.PassedCount, `
            $pesterResult.FailedCount, `
            $pesterResult.SkippedCount, `
            $pesterResult.InconclusiveCount, `
            $pesterResult.NotRunCount

        $coverageLines = $null
        if ($coverageEnabled -and $pesterResult.CodeCoverage) {
            $coverageReport = $pesterResult.CodeCoverage.CoverageReport
            if ($coverageReport -is [string] -and -not [string]::IsNullOrWhiteSpace($coverageReport)) {
                $rawCoverageLines = @($coverageReport -split "`r?`n")
                $trimmedCoverageLines = @()

                foreach ($line in $rawCoverageLines) {
                    if ([string]::IsNullOrWhiteSpace($line)) { continue }
                    if ($line -match '^\s*Missed commands') { break }
                    $trimmedCoverageLines += $line.TrimEnd()
                }

                if (-not $trimmedCoverageLines -and $rawCoverageLines) {
                    $trimmedCoverageLines = @($rawCoverageLines[0])
                }

                if ($trimmedCoverageLines) {
                    $coverageLines = $trimmedCoverageLines
                }
            }
        }

        & $Logger ''
        & $Logger 'Pester summary (replayed for readability):'
        & $Logger $testsSummary
        & $Logger $countsSummary
        if ($coverageLines) {
            foreach ($line in $coverageLines) {
                & $Logger $line
            }
        }
    }
}
