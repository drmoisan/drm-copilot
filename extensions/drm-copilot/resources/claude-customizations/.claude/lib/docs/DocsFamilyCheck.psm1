<#
.SYNOPSIS
    The documentation family check of the docs-complete validation: family evidence, family
    status and the family findings.

.DESCRIPTION
    Read-DocsFamilyEvidence lists each distinct documentation family directory of a docs profile
    through the ListFile seam and, when the profile declares the security family, probes the
    repository-root files SECURITY.md and CODEOWNERS through the TestFile seam. It makes no seam
    call for a profile without documentation families.

    Get-DocsFamilyStatus returns one status entry per required_families item, in profile order,
    and the legacy exclusion list sorted by path. Get-DocsFamilyFinding returns the family
    findings: DOCS_FAMILY_PAGE_MISSING and DOCS_FAMILY_ROOT_FILE_MISSING (errors),
    DOCS_FAMILY_NOT_APPLICABLE and DOCS_LEGACY_EXCLUSIONS_REPORTED (info).

    A family page is a listed path that begins with the family directory followed by '/', ends
    with '.md', and is not a legacy_exclusions path. Every comparison is ordinal. Status and
    finding functions are pure; absent evidence is read as empty directories and absent root
    files, so a missing family is never reported as present.

.NOTES
    Issue #1221. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsFamilySecurityId = 'security'
$script:DocsFamilyRootFileName = [string[]]@('SECURITY.md', 'CODEOWNERS')
$script:DocsFamilyPageSuffix = '.md'
$script:DocsFamilyIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'

function Get-DocsFamilyCheckMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the table is not a dictionary or lacks the key (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and ([System.Collections.IDictionary] $Table).Contains($Name)) { return $Table[$Name] }
    return $null
}

function Get-DocsFamilyCheckList {
    <#
    .SYNOPSIS
        Returns a profile member as an array of dictionaries, or an empty array when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $value = Get-DocsFamilyCheckMember -Table $Table -Name $Name
    if ($null -eq $value) { return , [object[]]@() }
    return , [object[]]@(@($value) | Where-Object { $_ -is [System.Collections.IDictionary] })
}

function Get-DocsFamilyDirectoryKey {
    <#
    .SYNOPSIS
        Returns the family directory with trailing '/' characters removed (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $Family)

    return ([string] (Get-DocsFamilyCheckMember -Table $Family -Name 'directory')).TrimEnd('/')
}

function Get-DocsFamilyLegacyPath {
    <#
    .SYNOPSIS
        Returns the legacy_exclusions paths of a profile (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile)

    return , [string[]] @(foreach ($entry in (Get-DocsFamilyCheckList -Table $Profile -Name 'legacy_exclusions')) { [string] $entry['path'] })
}

function Read-DocsFamilyEvidence {
    <#
    .SYNOPSIS
        Reads the family evidence of a profile through the context seams; returns @{ PagePath; RootFile }.
    .DESCRIPTION
        PagePath maps each distinct family directory (trailing '/' removed, ordinal) to the paths
        ListFile returned for it; ListFile is called once per distinct directory. RootFile maps
        SECURITY.md and CODEOWNERS to the TestFile answer for the repository-root path, and is
        filled only when a required_families entry has the id security. A profile without
        required_families makes no seam call.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile
    )

    $pagePath = [System.Collections.Generic.Dictionary[string, string[]]]::new([System.StringComparer]::Ordinal)
    $rootFile = [System.Collections.Generic.Dictionary[string, bool]]::new([System.StringComparer]::Ordinal)
    $families = Get-DocsFamilyCheckList -Table $Profile -Name 'required_families'
    $hasSecurity = $false
    foreach ($family in $families) {
        if ([string] (Get-DocsFamilyCheckMember -Table $family -Name 'id') -ceq $script:DocsFamilySecurityId) { $hasSecurity = $true }
        $directory = Get-DocsFamilyDirectoryKey -Family $family
        if ($pagePath.ContainsKey($directory)) { continue }
        $listed = & $ListFile $directory
        $pagePath[$directory] = [string[]]@(@($listed) | Where-Object { $_ -is [string] })
    }
    if ($hasSecurity) {
        foreach ($name in $script:DocsFamilyRootFileName) { $rootFile[$name] = [bool] (& $TestFile $name) }
    }
    return @{ PagePath = $pagePath; RootFile = $rootFile }
}

function Get-DocsFamilyPageCount {
    <#
    .SYNOPSIS
        Returns the number of family pages of one family directory in the evidence (private helper).
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Directory,
        [AllowNull()] [System.Collections.IDictionary] $Evidence,
        [AllowEmptyCollection()] [string[]] $LegacyPath = @()
    )

    $map = Get-DocsFamilyCheckMember -Table $Evidence -Name 'PagePath'
    if ($map -isnot [System.Collections.IDictionary] -or -not ([System.Collections.IDictionary] $map).Contains($Directory)) { return [long] 0 }
    $prefix = $Directory + '/'
    $count = [long] 0
    foreach ($path in @($map[$Directory])) {
        if ($path -isnot [string]) { continue }
        if (-not $path.StartsWith($prefix, [System.StringComparison]::Ordinal)) { continue }
        if (-not $path.EndsWith($script:DocsFamilyPageSuffix, [System.StringComparison]::Ordinal)) { continue }
        if ($LegacyPath -ccontains $path) { continue }
        $count++
    }
    return $count
}

function Get-DocsFamilyMissingRootFile {
    <#
    .SYNOPSIS
        Returns SECURITY.md and CODEOWNERS, in that order, whose RootFile evidence is not $true (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([AllowNull()] [System.Collections.IDictionary] $Evidence)

    $map = Get-DocsFamilyCheckMember -Table $Evidence -Name 'RootFile'
    $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $script:DocsFamilyRootFileName) {
        $present = $map -is [System.Collections.IDictionary] -and ([System.Collections.IDictionary] $map).Contains($name) -and ($map[$name] -eq $true)
        if (-not $present) { $missing.Add($name) }
    }
    return , [string[]] $missing.ToArray()
}

function Get-DocsFamilyStatus {
    <#
    .SYNOPSIS
        Returns @{ entries; legacy_exclusions }: one status entry per required_families item and the sorted legacy list.
    .DESCRIPTION
        Each entry is { id, directory, required, template, status, page_count, missing_root_files,
        exclusion } in profile order. status is not-applicable when the entry carries an
        exclusion, otherwise present when it has at least one family page, otherwise missing.
        missing_root_files is filled only for the security entry without an exclusion. exclusion
        is $null or { reason, recorded_at }. legacy_exclusions is { path, reason } per entry,
        sorted ordinally by path. A $null Evidence reads every directory as empty and every root
        file as absent.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [AllowNull()] [System.Collections.IDictionary] $Evidence
    )

    [string[]] $legacyPath = Get-DocsFamilyLegacyPath -Profile $Profile
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($family in (Get-DocsFamilyCheckList -Table $Profile -Name 'required_families')) {
        $id = [string] (Get-DocsFamilyCheckMember -Table $family -Name 'id')
        $exclusionValue = Get-DocsFamilyCheckMember -Table $family -Name 'exclusion'
        $exclusion = $null
        if ($exclusionValue -is [System.Collections.IDictionary]) {
            $exclusion = [ordered]@{ reason = [string] (Get-DocsFamilyCheckMember -Table $exclusionValue -Name 'reason'); recorded_at = [string] (Get-DocsFamilyCheckMember -Table $exclusionValue -Name 'recorded_at') }
        }
        $pageCount = Get-DocsFamilyPageCount -Directory (Get-DocsFamilyDirectoryKey -Family $family) -Evidence $Evidence -LegacyPath $legacyPath
        $status = if ($null -ne $exclusion) { 'not-applicable' } elseif ($pageCount -gt 0) { 'present' } else { 'missing' }
        [string[]] $missingRoot = @()
        if ($null -eq $exclusion -and $id -ceq $script:DocsFamilySecurityId) { $missingRoot = Get-DocsFamilyMissingRootFile -Evidence $Evidence }
        $entries.Add([ordered]@{
                id                 = $id
                directory          = [string] (Get-DocsFamilyCheckMember -Table $family -Name 'directory')
                required           = [bool] (Get-DocsFamilyCheckMember -Table $family -Name 'required')
                template           = [string] (Get-DocsFamilyCheckMember -Table $family -Name 'template')
                status             = $status
                page_count         = $pageCount
                missing_root_files = [string[]] $missingRoot
                exclusion          = $exclusion
            })
    }
    $legacy = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in (Get-DocsFamilyCheckList -Table $Profile -Name 'legacy_exclusions')) {
        $legacy.Add([ordered]@{ path = [string] (Get-DocsFamilyCheckMember -Table $entry -Name 'path'); reason = [string] (Get-DocsFamilyCheckMember -Table $entry -Name 'reason') })
    }
    $legacy.Sort([System.Comparison[object]] { param($left, $right) [string]::CompareOrdinal([string] $left['path'], [string] $right['path']) })
    return [ordered]@{ entries = [object[]] $entries.ToArray(); legacy_exclusions = [object[]] $legacy.ToArray() }
}

function Get-DocsFamilyFinding {
    <#
    .SYNOPSIS
        Returns the documentation family findings of a profile for the docs-complete validation.
    .DESCRIPTION
        DOCS_FAMILY_PAGE_MISSING (error, /required_families/<i>/directory) for a required family
        without an exclusion and without a family page; DOCS_FAMILY_ROOT_FILE_MISSING (error,
        /required_families/<i>) per absent repository-root SECURITY.md or CODEOWNERS of a
        required security family without an exclusion; DOCS_FAMILY_NOT_APPLICABLE (info,
        /required_families/<i>/exclusion) per family with an exclusion; and one
        DOCS_LEGACY_EXCLUSIONS_REPORTED (info, /legacy_exclusions) naming every legacy path and its
        reason when legacy_exclusions is not empty. A family with required false and no exclusion
        produces no finding. artifact_path is ProfilePath.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [AllowNull()] [System.Collections.IDictionary] $Evidence,
        [AllowNull()] [AllowEmptyString()] [string] $ProfilePath
    )

    $artifactPath = if (Test-DocsRelativePath -Path $ProfilePath) { $ProfilePath } else { $null }
    $status = Get-DocsFamilyStatus -Profile $Profile -Evidence $Evidence
    $findings = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $status.entries.Count; $index++) {
        $entry = $status.entries[$index]
        $id = [string] $entry['id']
        $directory = ([string] $entry['directory']).TrimEnd('/')
        $relatedId = [string[]]@($id | Where-Object { $_ -cmatch $script:DocsFamilyIdentifierPattern })
        $relatedDirectory = [string[]]@($directory | Where-Object { Test-DocsRelativePath -Path $_ })
        if ($null -ne $entry['exclusion']) {
            $findings.Add((New-DocsFinding -Code 'DOCS_FAMILY_NOT_APPLICABLE' -Severity 'info' -Pointer "/required_families/$index/exclusion" -ArtifactPath $artifactPath -RelatedId $relatedId -Message "The documentation family $id is not applicable: $($entry['exclusion']['reason'])." -NextAction "Remove the exclusion of the documentation family $id when the family applies to the repository."))
            continue
        }
        if (-not $entry['required']) { continue }
        if ($entry['status'] -ceq 'missing') {
            $findings.Add((New-DocsFinding -Code 'DOCS_FAMILY_PAGE_MISSING' -Severity 'error' -Pointer "/required_families/$index/directory" -ArtifactPath $artifactPath -RelatedId $relatedId -RelatedPath $relatedDirectory -Message "The required documentation family $id has no Markdown page under $directory." -NextAction "Add a .md page under $directory, or record an exclusion with a reason on the documentation family $id."))
        }
        foreach ($name in @($entry['missing_root_files'])) {
            $findings.Add((New-DocsFinding -Code 'DOCS_FAMILY_ROOT_FILE_MISSING' -Severity 'error' -Pointer "/required_families/$index" -ArtifactPath $artifactPath -RelatedId @($script:DocsFamilySecurityId) -RelatedPath @($name) -Message "The required security documentation family needs the repository-root file $name, which does not exist." -NextAction "Add $name at the repository root, or record an exclusion with a reason on the security documentation family."))
        }
    }
    $legacy = @($status.legacy_exclusions)
    if ($legacy.Count -gt 0) {
        $listed = @($legacy | ForEach-Object { "$($_['path']) ($($_['reason']))" }) -join '; '
        $legacyPath = [string[]]@($legacy | ForEach-Object { [string] $_['path'] } | Where-Object { Test-DocsRelativePath -Path $_ })
        $findings.Add((New-DocsFinding -Code 'DOCS_LEGACY_EXCLUSIONS_REPORTED' -Severity 'info' -Pointer '/legacy_exclusions' -ArtifactPath $artifactPath -RelatedPath $legacyPath -Message "The docs profile lists $($legacy.Count) legacy exclusion(s): $listed." -NextAction 'Move or retire each legacy page and remove its entry from legacy_exclusions.'))
    }
    return , [object[]] $findings.ToArray()
}

Export-ModuleMember -Function `
    Read-DocsFamilyEvidence, `
    Get-DocsFamilyStatus, `
    Get-DocsFamilyFinding
