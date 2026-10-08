<#
.SYNOPSIS
Returns the non-blank string entries of one list in a Pester settings table.
.DESCRIPTION
Reads Settings[Section][Key] and returns its non-blank string entries in their original order.
Returns nothing when Settings or the section is not a dictionary or when the key is absent.
Used for 'CodeCoverage.Path' and 'Run.Path' (issue #527).
.PARAMETER Settings
Settings table, normally the hashtable loaded from the Pester runsettings file.
.PARAMETER Section
Top-level section name, for example 'CodeCoverage' or 'Run'.
.PARAMETER Key
Key inside the section, for example 'Path'.
#>
function Get-PoshQCSettingsList {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        $Settings,
        [string] $Section,
        [string] $Key
    )

    if ($Settings -isnot [System.Collections.IDictionary]) {
        return
    }

    $sectionValue = $Settings[$Section]
    if ($sectionValue -isnot [System.Collections.IDictionary]) {
        return
    }

    if (-not $sectionValue.Contains($Key)) {
        return
    }

    foreach ($entry in @($sectionValue[$Key])) {
        if ($entry -is [string] -and -not [string]::IsNullOrWhiteSpace($entry)) {
            [string] $entry
        }
    }
}

<#
.SYNOPSIS
Reads and validates the workspace coverage configuration (issue #527).
.DESCRIPTION
Resolves the workspace-relative configuration file (default 'config/poshqc-coverage.json')
against Root. An absent file reports Present = $false. A present file must be a JSON object
with 'version' equal to 1 and a 'roots' array of workspace-relative paths; every validation
failure throws a message that names the configuration file. An empty 'roots' array is valid
and yields an empty coverage population.
.PARAMETER Root
Workspace root the configuration path resolves against.
.PARAMETER ConfigRelativePath
Workspace-relative path to the configuration file.
.PARAMETER TestPathExists
Injectable file-existence seam. Defaults to Test-Path -PathType Leaf.
.PARAMETER ReadContent
Injectable read seam returning the raw file text. Defaults to Get-Content -Raw.
#>
function Get-PoshQCCoverageConfigRoot {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $Root,
        [string] $ConfigRelativePath = 'config/poshqc-coverage.json',
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf },
        [scriptblock] $ReadContent = { param([string] $Path) Get-Content -LiteralPath $Path -Raw }
    )

    $ErrorActionPreference = 'Stop'

    $configPath = if ([IO.Path]::IsPathRooted($ConfigRelativePath)) {
        $ConfigRelativePath
    } else {
        Join-Path -Path $Root -ChildPath $ConfigRelativePath
    }

    if (-not (& $TestPathExists $configPath)) {
        return [pscustomobject]@{ Present = $false; Roots = [string[]] @() }
    }

    $raw = [string] (& $ReadContent $configPath)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "Coverage configuration '$ConfigRelativePath' is empty."
    }

    try {
        $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Invalid JSON in coverage configuration '$ConfigRelativePath': $($_.Exception.Message)"
    }

    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) {
        throw "Coverage configuration '$ConfigRelativePath' must contain a JSON object."
    }

    # Read properties through PSObject so a missing property yields $null under StrictMode.
    $versionProperty = $parsed.PSObject.Properties['version']
    $versionIsInteger = $null -ne $versionProperty -and ($versionProperty.Value -is [long] -or $versionProperty.Value -is [int])
    if (-not $versionIsInteger -or $versionProperty.Value -ne 1) {
        throw "Coverage configuration '$ConfigRelativePath' must declare 'version' equal to 1."
    }

    $rootsProperty = $parsed.PSObject.Properties['roots']
    if ($null -eq $rootsProperty) {
        throw "Coverage configuration '$ConfigRelativePath' must declare a 'roots' array."
    }
    if ($rootsProperty.Value -isnot [System.Array]) {
        throw "Coverage configuration '$ConfigRelativePath' must declare 'roots' as an array."
    }

    $validated = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $rootsProperty.Value) {
        if ($entry -isnot [string] -or [string]::IsNullOrWhiteSpace($entry)) {
            throw "Coverage configuration '$ConfigRelativePath' contains a blank or non-string 'roots' entry."
        }
        if ([IO.Path]::IsPathRooted($entry)) {
            throw "Coverage configuration '$ConfigRelativePath' entry '$entry' must be a workspace-relative path, not an absolute path."
        }
        if (@($entry -split '[\\/]+') -contains '..') {
            throw "Coverage configuration '$ConfigRelativePath' entry '$entry' must not contain '..' segments."
        }
        $validated.Add($entry)
    }

    return [pscustomobject]@{ Present = $true; Roots = [string[]] $validated.ToArray() }
}

<#
.SYNOPSIS
Enumerates the PowerShell production files under a set of coverage roots (issue #527).
.DESCRIPTION
Joins each non-rooted root to Root, skips a nonexistent root with one warning, and keeps
files with a .ps1 or .psm1 extension (case-insensitive) whose name does not match
'*.Tests.ps1', whose first root-relative segment is not 'tests', and whose root-relative
directory segments are not in ExcludeDirs. Root-relative paths use forward slashes. The result
is sorted ordinally on RelativePath and de-duplicated case-insensitively, keeping the
ordinally smallest variant.
.PARAMETER Root
Workspace root that relative roots and relative paths are computed against.
.PARAMETER Roots
Coverage roots, workspace-relative or absolute.
.PARAMETER ExcludeDirs
Directory names excluded from the population.
.PARAMETER TestPathExists
Injectable directory-existence seam. Defaults to Test-Path -PathType Container.
.PARAMETER EnumerateFiles
Injectable recursive file enumeration seam. Defaults to Get-ChildItem -Recurse -File -Force.
.PARAMETER WarningLogger
Injectable warning seam for skipped roots. Defaults to Write-Warning.
#>
function Get-PoshQCCoverageFileSet {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $Root,
        [string[]] $Roots,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Container },
        [scriptblock] $EnumerateFiles = { param([string] $Path) Get-ChildItem -LiteralPath $Path -Recurse -File -Force },
        [scriptblock] $WarningLogger = { param([string] $Message) Write-Warning $Message }
    )

    $ErrorActionPreference = 'Stop'

    $rootPrefix = ([string] $Root -replace '\\', '/').TrimEnd('/')
    $candidates = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
    foreach ($coverageRoot in @($Roots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
        $rootPath = if ([IO.Path]::IsPathRooted($coverageRoot)) { $coverageRoot } else { Join-Path -Path $Root -ChildPath $coverageRoot }
        if (-not (& $TestPathExists $rootPath)) {
            & $WarningLogger "Coverage root '$coverageRoot' does not exist under '$Root'; skipping."
            continue
        }

        foreach ($file in @(& $EnumerateFiles $rootPath)) {
            if ($null -eq $file) { continue }
            $extension = [string] $file.Extension
            if (-not ($extension -ieq '.ps1' -or $extension -ieq '.psm1')) { continue }
            if ([string] $file.Name -like '*.Tests.ps1') { continue }

            $fullPath = [string] $file.FullName
            $normalizedPath = $fullPath -replace '\\', '/'
            $relativePath = $normalizedPath
            if ($rootPrefix -and $normalizedPath.StartsWith("$rootPrefix/", [StringComparison]::OrdinalIgnoreCase)) {
                $relativePath = $normalizedPath.Substring($rootPrefix.Length + 1)
            }

            $segments = @($relativePath -split '/' | Where-Object { $_ -ne '' })
            if ($segments.Count -gt 0 -and $segments[0] -ieq 'tests') { continue }
            $directorySegments = if ($segments.Count -gt 1) { @($segments[0..($segments.Count - 2)]) } else { @() }
            $excludedSegments = @($directorySegments | Where-Object { $ExcludeDirs -contains $_ })
            if ($excludedSegments.Count -gt 0) { continue }

            if (-not $candidates.ContainsKey($relativePath)) {
                $candidates[$relativePath] = [pscustomobject]@{ RelativePath = $relativePath; FullPath = $fullPath }
            }
        }
    }

    [string[]] $keys = @($candidates.Keys)
    [Array]::Sort($keys, [StringComparer]::Ordinal)
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($key in $keys) {
        if ($seen.Add($key)) {
            $candidates[$key]
        }
    }
}

<#
.SYNOPSIS
Resolves the code-coverage population for one Invoke-PoshQCTest run (issue #527).
.DESCRIPTION
Applies the coverage precedence and returns the source name and the absolute file paths:
(1) 'settings': a caller-supplied settings file (one whose full path differs from the
module-default settings file) with a non-empty CodeCoverage.Path; relative entries are joined
to Root, rooted entries are kept as written, and each nonexistent entry is pruned and logged.
A non-empty CodeCoverage.Path in the module-default settings file is ignored and logged.
(2) 'config': the workspace coverage configuration reports Present.
(3) 'fallback': the effective scan-folder roots when non-empty, else the settings Run.Path.
.PARAMETER Root
Absolute workspace root.
.PARAMETER Settings
Settings table loaded from the Pester runsettings file.
.PARAMETER SettingsFile
Path of the settings file the table was loaded from.
.PARAMETER ScanFolderRoots
Effective test scan folders of the run (explicit -ScanFolders or the scan configuration).
.PARAMETER ExcludeDirs
Directory names excluded from the population.
.PARAMETER DefaultSettingsFile
The module-default settings file; a list in it is not honored.
.PARAMETER SettingsPathExists
Injectable existence seam for caller-supplied settings entries. Defaults to Test-Path.
.PARAMETER Logger
Injectable information seam. Defaults to Write-Information.
.PARAMETER WarningLogger
Injectable warning seam passed to the file-set seam. Defaults to Write-Warning.
.PARAMETER ReadConfig
Injectable configuration seam. Defaults to Get-PoshQCCoverageConfigRoot.
.PARAMETER GetFileSet
Injectable file-set seam. Defaults to Get-PoshQCCoverageFileSet.
#>
function Resolve-PoshQCCoveragePopulation {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $Root,
        $Settings,
        [string] $SettingsFile,
        [string[]] $ScanFolderRoots,
        [string[]] $ExcludeDirs = $script:DefaultExcludedDirs,
        [string] $DefaultSettingsFile = $script:PesterSettings,
        [scriptblock] $SettingsPathExists = { param([string] $Path) Test-Path $Path },
        [scriptblock] $Logger = { param([string] $Message) Write-Information $Message -InformationAction Continue },
        [scriptblock] $WarningLogger = { param([string] $Message) Write-Warning $Message },
        [scriptblock] $ReadConfig = { param([string] $RootPath) Get-PoshQCCoverageConfigRoot -Root $RootPath },
        [scriptblock] $GetFileSet = {
            param([string] $RootPath, [string[]] $Roots, [string[]] $Excluded, [scriptblock] $Warn)
            Get-PoshQCCoverageFileSet -Root $RootPath -Roots $Roots -ExcludeDirs $Excluded -WarningLogger $Warn
        }
    )

    $ErrorActionPreference = 'Stop'

    $settingsPaths = @(Get-PoshQCSettingsList -Settings $Settings -Section 'CodeCoverage' -Key 'Path')
    if ($settingsPaths.Count -gt 0) {
        # A settings file is caller-supplied custom when its full path differs from the module default.
        $isCustomSettingsFile = $false
        if (-not [string]::IsNullOrWhiteSpace($SettingsFile)) {
            $settingsFullPath = [IO.Path]::GetFullPath([IO.Path]::Combine($PWD.ProviderPath, $SettingsFile))
            $defaultFullPath = ''
            if (-not [string]::IsNullOrWhiteSpace($DefaultSettingsFile)) {
                $defaultFullPath = [IO.Path]::GetFullPath([IO.Path]::Combine($PWD.ProviderPath, $DefaultSettingsFile))
            }
            $isCustomSettingsFile = -not [string]::Equals($settingsFullPath, $defaultFullPath, [StringComparison]::OrdinalIgnoreCase)
        }

        if ($isCustomSettingsFile) {
            $survivingPaths = [System.Collections.Generic.List[string]]::new()
            foreach ($entry in $settingsPaths) {
                # Rooted entries are kept and tested as written; they are never re-joined to Root.
                $candidate = if ([IO.Path]::IsPathRooted($entry)) { $entry } else { Join-Path -Path $Root -ChildPath $entry }
                if (& $SettingsPathExists $candidate) {
                    $survivingPaths.Add($candidate)
                } else {
                    & $Logger "Pruned nonexistent code coverage path: $candidate"
                }
            }

            return [pscustomobject]@{ Source = 'settings'; Paths = [string[]] $survivingPaths.ToArray() }
        }

        & $Logger 'Ignored CodeCoverage.Path from the module-default settings file; the coverage population is derived from the workspace.'
    }

    $configRoot = & $ReadConfig $Root
    if ($null -ne $configRoot -and $configRoot.Present) {
        $source = 'config'
        $coverageRoots = @($configRoot.Roots)
    } else {
        $source = 'fallback'
        $coverageRoots = @($ScanFolderRoots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($coverageRoots.Count -eq 0) {
            $coverageRoots = @(Get-PoshQCSettingsList -Settings $Settings -Section 'Run' -Key 'Path')
        }
    }

    $files = @(& $GetFileSet $Root ([string[]] $coverageRoots) $ExcludeDirs $WarningLogger)
    $paths = [string[]] @($files | Where-Object { $null -ne $_ } | ForEach-Object { $_.FullPath })
    return [pscustomobject]@{ Source = $source; Paths = $paths }
}
