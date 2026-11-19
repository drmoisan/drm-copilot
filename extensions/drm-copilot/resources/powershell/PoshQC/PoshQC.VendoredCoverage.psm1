<#
.SYNOPSIS
Returns the canonical push-down content hash of a byte array (issue #1049).
.DESCRIPTION
Normalizes line endings at byte level, replacing each CR LF pair (0D 0A) with LF (0A) and then each
remaining CR (0D) with LF, and returns the lowercase hexadecimal SHA-256 of the result. Nothing else is
normalized; a byte-order mark is hashed as written. The digest uses SHA256.Create() so the function also
runs on Windows PowerShell 5.1. This is the hash the push-down records in .push-down-manifest.json.
.PARAMETER Bytes
Raw file bytes.
#>
function Get-PoshQCCanonicalContentHash {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]] $Bytes
    )

    # One pass is equivalent to the two-pass rule: each CR becomes LF and absorbs an immediately following LF.
    $normalized = New-Object byte[] $Bytes.Length
    $count = 0
    for ($index = 0; $index -lt $Bytes.Length; $index++) {
        $value = $Bytes[$index]
        if ($value -eq 0x0D) {
            $normalized[$count] = 0x0A
            if ($index + 1 -lt $Bytes.Length -and $Bytes[$index + 1] -eq 0x0A) { $index++ }
        } else {
            $normalized[$count] = $value
        }
        $count++
    }

    $hasher = [System.Security.Cryptography.SHA256]::Create()
    try {
        $digest = $hasher.ComputeHash($normalized, 0, $count)
    } finally {
        $hasher.Dispose()
    }
    return (-join @($digest | ForEach-Object { $_.ToString('x2') }))
}

<#
.SYNOPSIS
Reads the raw bytes of a file (default read seam, issue #1049).
.DESCRIPTION
Uses System.IO.File.ReadAllBytes, which keeps a byte-order mark, as the canonical hash rule requires.
.PARAMETER Path
Full path of the file.
#>
function Read-PoshQCFileByte {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    # -NoEnumerate keeps the array whole, so an empty file yields an empty array rather than no output.
    Write-Output -NoEnumerate -InputObject ([System.IO.File]::ReadAllBytes($Path))
}

<#
.SYNOPSIS
Reports whether a path is a symbolic link or other reparse point (default seam, issue #1049).
.PARAMETER Path
Full path of the file.
#>
function Test-PoshQCReparsePoint {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    $item = Get-Item -LiteralPath $Path -Force
    return [bool] ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

<#
.SYNOPSIS
Parses and validates the bytes of a destination .push-down-manifest.json (issue #1049).
.DESCRIPTION
Returns one record per files entry with Path and Sha256. Throws a message that names
.push-down-manifest.json for invalid UTF-8 or JSON, a missing or non-semver schema_version, a major
version other than 1, a missing files object, an entry whose sha256 is not 64 lowercase hexadecimal
characters, and a key that is empty, absolute, a drive-letter or UNC path, contains a backslash, or has a
'..' segment. Unknown top-level and per-file fields are ignored.
.PARAMETER Bytes
Raw manifest bytes.
#>
function ConvertFrom-PoshQCPushDownManifest {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]] $Bytes
    )

    $ErrorActionPreference = 'Stop'
    $name = '.push-down-manifest.json'

    try {
        $text = ([System.Text.UTF8Encoding]::new($false, $true)).GetString($Bytes)
        $parsed = $text | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Invalid $name`: not valid UTF-8 JSON ($($_.Exception.Message))."
    }
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) {
        throw "Invalid $name`: the document is not a JSON object."
    }

    $versionProperty = $parsed.PSObject.Properties['schema_version']
    if ($null -eq $versionProperty -or $versionProperty.Value -isnot [string] -or $versionProperty.Value -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
        throw "Invalid $name`: schema_version is missing or not a semantic version."
    }
    if ([int] $Matches[1] -ne 1) {
        throw "Invalid $name`: unknown major schema_version '$($versionProperty.Value)'."
    }

    $filesProperty = $parsed.PSObject.Properties['files']
    if ($null -eq $filesProperty -or $filesProperty.Value -isnot [System.Management.Automation.PSCustomObject]) {
        throw "Invalid $name`: files is missing or not an object."
    }

    foreach ($entry in $filesProperty.Value.PSObject.Properties) {
        $path = [string] $entry.Name
        $reason = $null
        if ($path -eq '') { $reason = 'is empty' }
        elseif ($path.StartsWith('/') -or $path.StartsWith('\\')) { $reason = 'is absolute or a UNC path' }
        elseif ($path -match '^[A-Za-z]:') { $reason = 'has a drive letter' }
        elseif ($path.Contains('\')) { $reason = 'contains a backslash' }
        elseif (@($path -split '/') -contains '..') { $reason = "has a '..' segment" }
        if ($null -ne $reason) {
            throw "Invalid $name`: files key '$path' $reason."
        }

        $value = $entry.Value
        $shaProperty = if ($value -is [System.Management.Automation.PSCustomObject]) { $value.PSObject.Properties['sha256'] } else { $null }
        if ($null -eq $shaProperty -or $shaProperty.Value -isnot [string] -or $shaProperty.Value -cnotmatch '^[0-9a-f]{64}$') {
            throw "Invalid $name`: files entry '$path' has no lowercase 64-character hex sha256."
        }
        [pscustomobject]@{ Path = $path; Sha256 = [string] $shaProperty.Value }
    }
}

<#
.SYNOPSIS
Classifies pushed-down files against the destination manifest (issue #1049).
.DESCRIPTION
Reads Root/.push-down-manifest.json through the ReadBytes seam and returns one record per manifest entry
and per candidate path that is not a manifest key, each with path, status, manifest_sha256 and
actual_sha256, sorted ordinally by path. Status is 'exempt' for a listed, present regular file whose
canonical hash equals the entry's sha256; 'modified' when the hash differs or the path is a reparse point
(actual_sha256 is then null for the reparse point); 'missing' for a listed absent file; and 'unlisted' for
a candidate that is not a manifest key. Matching is ordinal and case-sensitive. An absent manifest logs
exactly one warning and reports every candidate 'unlisted'. An invalid manifest throws.
.PARAMETER Root
Destination root.
.PARAMETER CandidatePaths
Root-relative POSIX paths of the coverage population.
.PARAMETER ReadBytes
Injectable byte-read seam. Defaults to Read-PoshQCFileByte.
.PARAMETER TestPathExists
Injectable file-existence seam. Defaults to Test-Path -PathType Leaf.
.PARAMETER TestReparsePoint
Injectable reparse-point seam. Defaults to Test-PoshQCReparsePoint.
.PARAMETER WarningLogger
Injectable warning seam. Defaults to Write-Warning.
#>
function Get-PoshQCVendoredCoverageStatus {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [AllowEmptyCollection()][string[]] $CandidatePaths = @(),
        [scriptblock] $ReadBytes = { param([string] $Path) Read-PoshQCFileByte -Path $Path },
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf },
        [scriptblock] $TestReparsePoint = { param([string] $Path) Test-PoshQCReparsePoint -Path $Path },
        [scriptblock] $WarningLogger = { param([string] $Message) Write-Warning $Message }
    )

    $ErrorActionPreference = 'Stop'
    $rootPrefix = ([string] $Root -replace '\\', '/').TrimEnd('/')
    $manifestPath = "$rootPrefix/.push-down-manifest.json"
    $records = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)

    if (& $TestPathExists $manifestPath) {
        $entries = @(ConvertFrom-PoshQCPushDownManifest -Bytes ([byte[]] (& $ReadBytes $manifestPath)))
        foreach ($entry in $entries) {
            $fullPath = "$rootPrefix/$($entry.Path)"
            $actual = $null
            if (-not (& $TestPathExists $fullPath)) {
                $status = 'missing'
            } elseif (& $TestReparsePoint $fullPath) {
                $status = 'modified'
            } else {
                $actual = Get-PoshQCCanonicalContentHash -Bytes ([byte[]] (& $ReadBytes $fullPath))
                $status = if ([string]::Equals($actual, $entry.Sha256, [StringComparison]::Ordinal)) { 'exempt' } else { 'modified' }
            }
            $records[$entry.Path] = [pscustomobject]@{ path = $entry.Path; status = $status; manifest_sha256 = $entry.Sha256; actual_sha256 = $actual }
        }
    } else {
        & $WarningLogger "No .push-down-manifest.json under '$Root'; no pushed-down file is exempt from coverage."
    }

    foreach ($candidate in @($CandidatePaths | Where-Object { -not [string]::IsNullOrEmpty($_) })) {
        if (-not $records.ContainsKey($candidate)) {
            $records[$candidate] = [pscustomobject]@{ path = $candidate; status = 'unlisted'; manifest_sha256 = $null; actual_sha256 = $null }
        }
    }

    [string[]] $keys = @($records.Keys)
    [Array]::Sort($keys, [StringComparer]::Ordinal)
    foreach ($key in $keys) { $records[$key] }
}

<#
.SYNOPSIS
Reads the exempt_unchanged_push_down_files opt-in from a parsed coverage configuration (issue #1049).
.DESCRIPTION
Returns $false when the key is absent and the value when it is a boolean; any other value throws a message
that names the configuration file.
.PARAMETER Parsed
The parsed configuration object.
.PARAMETER ConfigRelativePath
Configuration path used in the error message.
#>
function Get-PoshQCVendoredCoverageOptIn {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] $Parsed,
        [string] $ConfigRelativePath = 'config/poshqc-coverage.json'
    )

    $property = $Parsed.PSObject.Properties['exempt_unchanged_push_down_files']
    if ($null -eq $property) {
        return $false
    }
    if ($property.Value -isnot [bool]) {
        throw "Coverage configuration '$ConfigRelativePath' must declare 'exempt_unchanged_push_down_files' as a boolean."
    }
    return [bool] $property.Value
}

<#
.SYNOPSIS
Removes unchanged pushed-down files from a coverage file set (issue #1049).
.DESCRIPTION
Classifies the RelativePath of each file-set record through the GetStatus seam and removes each record
whose RelativePath ordinally equals a record with status 'exempt'. Returns Paths (the FullPath values that
remain, in input order) and Exemptions (every status record).
.PARAMETER Root
Destination root.
.PARAMETER Files
File-set records with RelativePath and FullPath.
.PARAMETER GetStatus
Injectable status seam. Defaults to Get-PoshQCVendoredCoverageStatus.
#>
function Resolve-PoshQCVendoredCoverageExemption {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [AllowEmptyCollection()][object[]] $Files = @(),
        [scriptblock] $GetStatus = { param([string] $RootPath, [string[]] $Candidates) Get-PoshQCVendoredCoverageStatus -Root $RootPath -CandidatePaths $Candidates }
    )

    $fileRecords = @($Files | Where-Object { $null -ne $_ })
    $candidates = [string[]] @($fileRecords | ForEach-Object { [string] $_.RelativePath })
    $statuses = @(& $GetStatus $Root $candidates)
    $exempt = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($record in $statuses) {
        if ($record.status -ceq 'exempt') { [void] $exempt.Add([string] $record.path) }
    }

    $paths = [string[]] @($fileRecords | Where-Object { -not $exempt.Contains([string] $_.RelativePath) } | ForEach-Object { [string] $_.FullPath })
    return [pscustomobject]@{ Paths = $paths; Exemptions = $statuses }
}

<#
.SYNOPSIS
Renders the vendored coverage exemption report as JSON (issue #1049).
.DESCRIPTION
Returns {"entries": [...]} with one object per status record (path, status, manifest_sha256,
actual_sha256), sorted ordinally by path, with LF line endings and a trailing LF. The report carries no
timestamp and no root path.
.PARAMETER Exemptions
Status records from Get-PoshQCVendoredCoverageStatus.
#>
function ConvertTo-PoshQCVendoredCoverageReportJson {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyCollection()][object[]] $Exemptions = @()
    )

    $byPath = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
    foreach ($record in @($Exemptions | Where-Object { $null -ne $_ })) { $byPath[[string] $record.path] = $record }
    [string[]] $keys = @($byPath.Keys)
    [Array]::Sort($keys, [StringComparer]::Ordinal)

    $quote = { param($Value) if ($null -eq $Value) { 'null' } else { ConvertTo-Json -InputObject ([string] $Value) -Compress } }
    $lines = foreach ($key in $keys) {
        $record = $byPath[$key]
        '    {{"path": {0}, "status": {1}, "manifest_sha256": {2}, "actual_sha256": {3}}}' -f (& $quote $record.path), (& $quote $record.status), (& $quote $record.manifest_sha256), (& $quote $record.actual_sha256)
    }
    if (@($lines).Count -eq 0) {
        return "{`n  `"entries`": []`n}`n"
    }
    return "{`n  `"entries`": [`n" + (@($lines) -join ",`n") + "`n  ]`n}`n"
}

<#
.SYNOPSIS
Writes vendored-coverage-exemptions.json beside the coverage output file (issue #1049).
.DESCRIPTION
Writes the report in the directory of CoverageOutputPath (a relative path resolves against Root), or in
artifacts/pester under Root when CoverageOutputPath is blank, and returns the written path.
.PARAMETER Root
Run root.
.PARAMETER CoverageOutputPath
Effective coverage output file of the run.
.PARAMETER Exemptions
Status records to report.
.PARAMETER EnsureDirectory
Injectable directory seam. Defaults to New-Item -ItemType Directory -Force.
.PARAMETER WriteContent
Injectable write seam. Defaults to Set-Content -NoNewline -Encoding utf8.
#>
function Write-PoshQCVendoredCoverageReport {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [string] $CoverageOutputPath,
        [AllowEmptyCollection()][object[]] $Exemptions = @(),
        [scriptblock] $EnsureDirectory = { param([string] $Path) New-Item -ItemType Directory -Path $Path -Force | Out-Null },
        [scriptblock] $WriteContent = { param([string] $Path, [string] $Content) Set-Content -LiteralPath $Path -Value $Content -NoNewline -Encoding utf8 }
    )

    $ErrorActionPreference = 'Stop'
    $directory = if ([string]::IsNullOrWhiteSpace($CoverageOutputPath)) {
        Join-Path -Path $Root -ChildPath 'artifacts/pester'
    } else {
        $coverageFile = if ([IO.Path]::IsPathRooted($CoverageOutputPath)) { $CoverageOutputPath } else { Join-Path -Path $Root -ChildPath $CoverageOutputPath }
        Split-Path -Parent $coverageFile
    }

    & $EnsureDirectory $directory
    $reportPath = Join-Path -Path $directory -ChildPath 'vendored-coverage-exemptions.json'
    & $WriteContent $reportPath (ConvertTo-PoshQCVendoredCoverageReportJson -Exemptions $Exemptions)
    return $reportPath
}
