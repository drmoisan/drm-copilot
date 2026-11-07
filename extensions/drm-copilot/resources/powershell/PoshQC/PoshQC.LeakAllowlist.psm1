# PoshQC.LeakAllowlist.psm1 - leak-scan allowlist validation and comparison, and the public scan entry
# point Invoke-PoshQCLeakScan (issue #1096). Get-PoshQCLeakFinding lives in PoshQC.LeakScan.psm1.

$script:LeakAllowlistRelativePath = 'config/poshqc-leak-allowlist.json'
$script:LeakKinds = @('env', 'global-variable', 'global-function', 'location', 'process-directory')
$script:LeakExemptGlobalVariables = @('LASTEXITCODE')

function Get-PoshQCLeakAllowlistField {
    # Reads a property through PSObject so a missing property is $null under strict mode, and returns
    # its text or an empty string.
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowNull()][object] $Item,
        [Parameter(Mandatory = $true)][string] $Name
    )

    if ($null -eq $Item -or $Item -isnot [System.Management.Automation.PSCustomObject]) { return '' }
    $property = $Item.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return '' }
    [string] $property.Value
}

function Get-PoshQCLeakAllowlistArray {
    # Returns the items of an optional array property; an absent property is an empty list.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object] $Document,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $SourceName
    )

    $property = $Document.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return }
    if ($property.Value -isnot [array]) { throw "Leak allowlist '$SourceName' property '$Name' must be an array." }
    foreach ($item in $property.Value) { $item }
}

function ConvertFrom-PoshQCLeakAllowlist {
    <#
    .SYNOPSIS
    Validates leak allowlist text and returns the exempt names and the entries.
    .DESCRIPTION
    Absent or blank text is an empty allowlist. Every validation failure throws and names SourceName.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory = $true)][string] $SourceName
    )

    $exempt = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $entries = [System.Collections.Generic.List[object]]::new()
    if ([string]::IsNullOrWhiteSpace($Text)) { return [pscustomobject]@{ Exempt = $exempt; Entries = $entries } }
    try {
        $document = $Text | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Invalid JSON in leak allowlist '$SourceName': $($_.Exception.Message)"
    }
    $version = if ($document -is [System.Management.Automation.PSCustomObject]) { $document.PSObject.Properties['version'] } else { $null }
    if ($null -eq $version -or $version.Value -isnot [long] -or $version.Value -ne 1) {
        throw "Leak allowlist '$SourceName' must declare 'version' equal to 1."
    }
    # Each exemption names an allowed global variable and states why it is exempt.
    foreach ($item in @(Get-PoshQCLeakAllowlistArray -Document $document -Name 'exemptGlobalVariables' -SourceName $SourceName)) {
        $name = Get-PoshQCLeakAllowlistField -Item $item -Name 'name'
        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace((Get-PoshQCLeakAllowlistField -Item $item -Name 'reason'))) {
            throw "Leak allowlist '$SourceName' has an exemptGlobalVariables item with a blank name or reason."
        }
        if ($script:LeakExemptGlobalVariables -notcontains $name) {
            throw "Leak allowlist '$SourceName' exempts '$name'; only LASTEXITCODE may be exempt."
        }
        if (-not $exempt.Add($name)) { throw "Leak allowlist '$SourceName' exempts '$name' more than once." }
    }
    # Each entry names one finding key with a reason; paths are repository-relative with forward slashes.
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($item in @(Get-PoshQCLeakAllowlistArray -Document $document -Name 'entries' -SourceName $SourceName)) {
        $fields = @{}
        foreach ($field in @('path', 'kind', 'name', 'reason')) {
            $fields[$field] = Get-PoshQCLeakAllowlistField -Item $item -Name $field
            if ([string]::IsNullOrWhiteSpace($fields[$field])) { throw "Leak allowlist '$SourceName' has an entry with a missing or blank '$field'." }
        }
        $path = $fields.path -replace '\\', '/'
        if ($path -match '^(?:[A-Za-z]:|/)') { throw "Leak allowlist '$SourceName' entry path '$path' must be repository-relative, not absolute." }
        if (($path -split '/') -contains '..') { throw "Leak allowlist '$SourceName' entry path '$path' must not contain '..' segments." }
        if ($script:LeakKinds -cnotcontains $fields.kind) { throw "Leak allowlist '$SourceName' entry for '$path' has unknown kind '$($fields.kind)'." }
        $key = '{0}|{1}|{2}' -f $path, $fields.kind, $fields.name.ToLowerInvariant()
        if (-not $seen.Add($key)) { throw "Leak allowlist '$SourceName' lists the entry '$path | $($fields.kind) | $($fields.name)' more than once." }
        $entries.Add([pscustomobject]@{ Path = $path; Kind = $fields.kind; Name = $fields.name; Reason = $fields.reason; Key = $key })
    }
    [pscustomobject]@{ Exempt = $exempt; Entries = $entries }
}

function Compare-PoshQCLeakAllowlist {
    <#
    .SYNOPSIS
    Compares raw findings with a validated allowlist.
    .DESCRIPTION
    Removes exempt global variables, then returns the findings no entry allowlists and the entries that
    match no raw finding (stale). Paths compare ordinally after normalization; names compare
    case-insensitively.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Finding,
        [Parameter(Mandatory = $true)][pscustomobject] $Allowlist
    )

    $rawKeys = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $exemptCount = 0
    $allowlistedCount = 0
    $unallowed = [System.Collections.Generic.List[object]]::new()
    $entryKeys = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($entry in $Allowlist.Entries) { [void] $entryKeys.Add($entry.Key) }
    # Classify each raw finding as exempt, allowlisted, or unallowed, and record its key for stale detection.
    foreach ($item in $Finding) {
        $key = '{0}|{1}|{2}' -f ($item.Path -replace '\\', '/'), $item.Kind, $item.Name.ToLowerInvariant()
        [void] $rawKeys.Add($key)
        if ($item.Kind -eq 'global-variable' -and $Allowlist.Exempt.Contains($item.Name)) {
            $exemptCount++
        } elseif ($entryKeys.Contains($key)) {
            $allowlistedCount++
        } else {
            $unallowed.Add($item)
        }
    }
    $stale = @($Allowlist.Entries | Where-Object { -not $rawKeys.Contains($_.Key) })
    [pscustomobject]@{ Unallowed = @($unallowed); Stale = $stale; ExemptCount = $exemptCount; AllowlistedCount = $allowlistedCount }
}

function Resolve-PoshQCLeakScanFolder {
    # Returns the scan folders under tests/, normalized to forward slashes. Without -ScanFolders the
    # configured folders are read; a throw from Get-PoshQCScanConfigFolder reaches the caller.
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [string[]] $ScanFolders,
        [bool] $FoldersSupplied
    )

    $folders = if ($FoldersSupplied) { @($ScanFolders) } else { @(Get-PoshQCScanConfigFolder -Root $Root) }
    foreach ($folder in $folders) {
        $normalized = ([string] $folder -replace '\\', '/').TrimEnd('/')
        if (($normalized + '/').StartsWith('tests/', [StringComparison]::Ordinal)) { $normalized }
    }
}

<#
.SYNOPSIS
Scans Pester test files and .ps1 helpers under tests/ for state that leaks between test files.
.DESCRIPTION
Reads each .ps1 file under the scan folders that lie beneath tests/, reports each unpaired state write
through Get-PoshQCLeakFinding, removes exempt names, and compares the rest with
config/poshqc-leak-allowlist.json. Each unallowlisted finding, stale entry, and parse error is logged
as one 'path | line | kind | name' message, and any of them ends in one throw. This function is the
only I/O in the scan; every reader is an injectable seam.
.PARAMETER Root
The repository root.
.PARAMETER ScanFolders
Repository-relative folders to scan; only folders under tests/ are used. Defaults to the configured
test scan folders under tests/.
#>
function Invoke-PoshQCLeakScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [string[]] $ScanFolders,
        [scriptblock] $ReadText = { param([string] $Path) Get-Content -Raw -LiteralPath $Path },
        [scriptblock] $ReadAllowlist = { param([string] $Path) if (Test-Path -LiteralPath $Path) { Get-Content -Raw -LiteralPath $Path } },
        [scriptblock] $EnumerateFiles = { param([string] $Path) Get-ChildItem -LiteralPath $Path -Recurse -File -Filter '*.ps1' | ForEach-Object FullName },
        [scriptblock] $Logger = { param([string] $Message) Write-Information $Message -InformationAction Continue }
    )

    $ErrorActionPreference = 'Stop'
    $rootPath = ([IO.Path]::GetFullPath($Root) -replace '\\', '/').TrimEnd('/')
    $allowlist = ConvertFrom-PoshQCLeakAllowlist -Text ([string] (& $ReadAllowlist "$rootPath/$script:LeakAllowlistRelativePath")) -SourceName $script:LeakAllowlistRelativePath
    $folders = @(Resolve-PoshQCLeakScanFolder -Root $rootPath -ScanFolders $ScanFolders -FoldersSupplied $PSBoundParameters.ContainsKey('ScanFolders'))

    # Collect the repository-relative .ps1 paths under every folder once, in ordinal order.
    $files = [System.Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
    foreach ($folder in $folders) {
        foreach ($fullPath in @(& $EnumerateFiles "$rootPath/$folder")) {
            $normalized = [string] $fullPath -replace '\\', '/'
            if (-not $normalized.EndsWith('.ps1', [StringComparison]::OrdinalIgnoreCase)) { continue }
            if ($normalized.StartsWith("$rootPath/", [StringComparison]::OrdinalIgnoreCase)) { $normalized = $normalized.Substring($rootPath.Length + 1) }
            [void] $files.Add($normalized)
        }
    }

    # Scan each file; a parse error is recorded as a failure, never skipped.
    $findings = [System.Collections.Generic.List[object]]::new()
    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($relativePath in $files) {
        try {
            foreach ($finding in @(Get-PoshQCLeakFinding -Content ([string] (& $ReadText "$rootPath/$relativePath")) -Path $relativePath)) { $findings.Add($finding) }
        } catch {
            $failures.Add(('{0} | 0 | parse-error | {1}' -f $relativePath, $_.Exception.Message))
        }
    }
    $comparison = Compare-PoshQCLeakAllowlist -Finding @($findings) -Allowlist $allowlist
    foreach ($item in $comparison.Unallowed) { $failures.Add(('{0} | {1} | {2} | {3}' -f $item.Path, $item.Line, $item.Kind, $item.Name)) }
    foreach ($entry in $comparison.Stale) { $failures.Add(('{0} | stale | {1} | {2}' -f $entry.Path, $entry.Kind, $entry.Name)) }
    foreach ($message in $failures) { & $Logger $message }
    & $Logger ("Leak scan: {0} files, {1} findings, {2} exempt, {3} allowlisted, {4} failures." -f $files.Count, $findings.Count, $comparison.ExemptCount, $comparison.AllowlistedCount, $failures.Count)
    if ($failures.Count -gt 0) {
        throw ("Invoke-PoshQCLeakScan found {0} failure(s):`n{1}" -f $failures.Count, ($failures -join "`n"))
    }
}
