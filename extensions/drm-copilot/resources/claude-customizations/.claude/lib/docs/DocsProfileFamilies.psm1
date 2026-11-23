<#
.SYNOPSIS
    Documentation family defaults and the semantic rules for documentation families and legacy exclusions.

.DESCRIPTION
    Get-DocsDefaultFamilySet returns the default documentation family records that a starter
    profile declares in required_families, each placed under one documentation root.
    Test-DocsProfileFamilySemantic returns the cross-field error findings for the
    required_families and legacy_exclusions members of a schema-valid docs profile.

    A documentation family is a named group of pages with one directory, one Diataxis mode, one
    page template, its audiences, and a review interval. The family diataxis_mode is the default
    mode of the family's pages, not a constraint on every page inside the family directory.

    Every function is pure: no file, clock, environment, or process is read.

.NOTES
    Issue #1218. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

function Get-DocsDefaultFamilySet {
    <#
    .SYNOPSIS
        Returns the default documentation family records under DocumentationRoot.
    .DESCRIPTION
        Returns ten ordered records in this order: product-overview, getting-started,
        user-guides, administration, security, operations, service-management, architecture,
        adr, reference. Each record has the keys id, directory, diataxis_mode, template,
        audience, review_interval_days, and required, in that order, and no exclusion key. The
        directory of each documentation family is DocumentationRoot followed by '/' and the id.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()] [string] $DocumentationRoot
    )

    $rows = @(
        , @('product-overview', 'explanation', 'product-overview', @('product-owners', 'end-users', 'maintainers'), 90L)
        , @('getting-started', 'how-to', 'onboarding', @('end-users', 'maintainers', 'operators'), 90L)
        , @('user-guides', 'how-to', 'how-to', @('end-users'), 90L)
        , @('administration', 'how-to', 'how-to', @('operators'), 90L)
        , @('security', 'explanation', 'security', @('security-reviewers'), 90L)
        , @('operations', 'how-to', 'runbook', @('operators'), 90L)
        , @('service-management', 'explanation', 'service-management', @('operators', 'product-owners'), 90L)
        , @('architecture', 'explanation', 'architecture-overview', @('maintainers', 'security-reviewers'), 180L)
        , @('adr', 'explanation', 'adr', @('maintainers'), 180L)
        , @('reference', 'reference', 'api-reference', @('maintainers', 'operators'), 90L)
    )
    $families = foreach ($row in $rows) {
        [ordered]@{
            id                   = [string] $row[0]
            directory            = "$DocumentationRoot/$($row[0])"
            diataxis_mode        = [string] $row[1]
            template             = [string] $row[2]
            audience             = [string[]] @($row[3])
            review_interval_days = [long] $row[4]
            required             = $true
        }
    }
    return , [object[]] @($families)
}

function Get-DocsFamilyList {
    <#
    .SYNOPSIS
        Returns a profile member as an array, or an empty array when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [object] $Container,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Container -isnot [System.Collections.IDictionary] -or -not $Container.Contains($Name) -or $null -eq $Container[$Name]) { return , [object[]]@() }
    return , [object[]]@($Container[$Name])
}

function New-DocsFamilyFinding {
    <#
    .SYNOPSIS
        Builds one documentation family error finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Pointer $Pointer -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath
}

function Test-DocsFamilyDirectoryUnderRoot {
    <#
    .SYNOPSIS
        Returns $true when Directory equals a root path or begins with it followed by '/' (private helper).
    .DESCRIPTION
        The comparison is ordinal and segment-wise on forward-slash relative paths: no path is
        joined, resolved, or case-folded.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Directory,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $RootPath
    )

    foreach ($root in $RootPath) {
        if ([string]::Equals($Directory, $root, [System.StringComparison]::Ordinal)) { return $true }
        if ($Directory.StartsWith($root + '/', [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function Test-DocsProfileFamilySemantic {
    <#
    .SYNOPSIS
        Returns the documentation family and legacy exclusion error findings of a schema-valid profile.
    .DESCRIPTION
        Rules, each an error finding at the pointer shown, with ordinal comparisons:
        F1 DOCS_PROFILE_FAMILY_DUPLICATE (/required_families/<n>/id): an id repeats an earlier
        documentation family id. F2 DOCS_PROFILE_FAMILY_DUPLICATE (/required_families/<n>/directory):
        a directory repeats an earlier documentation family directory. F3
        DOCS_PROFILE_AUDIENCE_UNKNOWN (/required_families/<n>/audience/<m>): an audience is not
        declared in audiences. F4 DOCS_PROFILE_MODE_NOT_IN_POLICY
        (/required_families/<n>/diataxis_mode): the mode is not listed in diataxis_policy.modes;
        the mode is the default for the family's pages and constrains no page. F5
        DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT (/required_families/<n>/directory): the
        directory neither equals a documentation_roots path nor begins with it followed by '/'.
        L1 DOCS_PROFILE_LEGACY_DUPLICATE (/legacy_exclusions/<n>/path): a legacy path repeats an
        earlier legacy path. Duplicate findings point at the later entry. Template files, legacy
        paths against roots, and exclusion against required are not checked.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $declared = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($audience in (Get-DocsFamilyList -Container $Profile -Name 'audiences')) { [void] $declared.Add([string] $audience['id']) }
    $rootPaths = [string[]] @(foreach ($root in (Get-DocsFamilyList -Container $Profile -Name 'documentation_roots')) { [string] $root['path'] })
    $policy = if ($Profile.Contains('diataxis_policy')) { $Profile['diataxis_policy'] } else { $null }
    $modes = Get-DocsFamilyList -Container $policy -Name 'modes'

    $ids = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $directories = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $families = Get-DocsFamilyList -Container $Profile -Name 'required_families'
    for ($index = 0; $index -lt $families.Count; $index++) {
        $family = $families[$index]
        $id = [string] $family['id']
        $directory = [string] $family['directory']
        $mode = [string] $family['diataxis_mode']
        if (-not $ids.Add($id)) {
            $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_FAMILY_DUPLICATE' -Pointer "/required_families/$index/id" -ArtifactPath $ArtifactPath -Message "Field id repeats the documentation family $id." -NextAction 'Give every documentation family a distinct id.'))
        }
        if (-not $directories.Add($directory)) {
            $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_FAMILY_DUPLICATE' -Pointer "/required_families/$index/directory" -ArtifactPath $ArtifactPath -Message "Field directory repeats the documentation family directory $directory." -NextAction 'Give every documentation family a distinct directory.'))
        }
        $audiences = Get-DocsFamilyList -Container $family -Name 'audience'
        for ($position = 0; $position -lt $audiences.Count; $position++) {
            if (-not $declared.Contains([string] $audiences[$position])) {
                $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_AUDIENCE_UNKNOWN' -Pointer "/required_families/$index/audience/$position" -ArtifactPath $ArtifactPath -Message "Field audience references the audience $($audiences[$position]), which the profile does not declare in audiences." -NextAction 'Declare the audience in audiences or remove it from the documentation family.'))
            }
        }
        if ($modes -cnotcontains $mode) {
            $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_MODE_NOT_IN_POLICY' -Pointer "/required_families/$index/diataxis_mode" -ArtifactPath $ArtifactPath -Message "Field diataxis_mode uses the mode $mode, which diataxis_policy.modes does not list." -NextAction 'Add the mode to diataxis_policy.modes or change the documentation family mode.'))
        }
        if (-not (Test-DocsFamilyDirectoryUnderRoot -Directory $directory -RootPath $rootPaths)) {
            $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT' -Pointer "/required_families/$index/directory" -ArtifactPath $ArtifactPath -Message "Field directory places the documentation family at $directory, outside every documentation_roots path." -NextAction 'Move the documentation family directory under a documentation root or add a documentation root that contains it.'))
        }
    }

    $legacyPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $legacy = Get-DocsFamilyList -Container $Profile -Name 'legacy_exclusions'
    for ($index = 0; $index -lt $legacy.Count; $index++) {
        $path = [string] $legacy[$index]['path']
        if (-not $legacyPaths.Add($path)) {
            $findings.Add((New-DocsFamilyFinding -Code 'DOCS_PROFILE_LEGACY_DUPLICATE' -Pointer "/legacy_exclusions/$index/path" -ArtifactPath $ArtifactPath -Message "Field path repeats the legacy exclusion $path." -NextAction 'List every legacy page once in legacy_exclusions.'))
        }
    }
    return , [object[]] $findings.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsDefaultFamilySet, `
    Test-DocsProfileFamilySemantic
