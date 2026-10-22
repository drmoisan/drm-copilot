<#
.SYNOPSIS
    Input-manifest validation and freshness recomputation for native discovery hooks.

.DESCRIPTION
    A validation receipt carries the complete sorted set of inputs the runtime
    read (`service-result#/$defs/input-manifest`). Before a native stop or
    planning check trusts that receipt it re-enumerates the authorized input set,
    re-reads every path through an injected byte reader, recomputes the digests
    and sizes, confirms that paths reported missing are still missing, checks the
    protected profile binding, and classifies every difference as drift:
    `edited`, `deleted`, `appeared`, `renamed`, `evidence-replaced` or
    `profile-changed`. The rules mirror `discovery-input-manifest.ts` so the hook,
    the gateway and the runtime agree on the same digest for the same inputs.

    The module performs no writes, holds no authority and never reimplements
    schema or graph semantics; it only decides whether the inputs a receipt names
    are still the inputs on disk.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryAuthority module for hashing and canonical JSON.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop

$script:InputCategories = @(
    'profile', 'activation', 'scope', 'inventory', 'artifact', 'evidence',
    'source-snapshot', 'extension-schema', 'extension-result', 'source', 'test', 'documentation'
)
$script:ManifestKeys = 'entries,missing_paths,sha256,source_repositories,target_repositories'
$script:EntryKeys = 'category,path,sha256,size'
$script:RepositoryKeys = 'id,revision'
$script:IdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'
$script:RevisionPattern = '^(?:[0-9a-f]{40}|[0-9a-f]{64})$'
$script:DigestPattern = '^[0-9a-f]{64}$'

function Get-DiscoveryManifestFailureMessage {
    <#
    .SYNOPSIS
        Builds the typed INPUT_MANIFEST_INVALID message for one defect.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$Detail)

    return "INPUT_MANIFEST_INVALID: Input manifest is malformed: $Detail"
}

function Get-DiscoverySortedPropertyNameList {
    <#
    .SYNOPSIS
        Returns the ordinal-sorted member names of a hashtable or PSCustomObject joined by commas.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ($Value -is [System.Collections.IDictionary]) {
        [string[]]$names = @($Value.Keys | ForEach-Object { [string]$_ })
    } elseif ($Value -is [System.Management.Automation.PSCustomObject]) {
        [string[]]$names = @($Value.PSObject.Properties.Name)
    } else {
        return $null
    }
    [Array]::Sort($names, [System.StringComparer]::Ordinal)
    return ($names -join ',')
}

function Get-DiscoveryMemberValue {
    <#
    .SYNOPSIS
        Reads one member from a hashtable or PSCustomObject uniformly.
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param(
        [Parameter(Mandatory = $true)][object]$Value,
        [Parameter(Mandatory = $true)][string]$Name
    )

    # A direct assignment (no subexpression) and the unary comma keep an array
    # member intact across the function boundary instead of unrolling it.
    if ($Value -is [System.Collections.IDictionary]) {
        $member = $Value[$Name]
    } else {
        $member = $Value.PSObject.Properties[$Name].Value
    }
    if ($null -eq $member) { return $null }
    return , $member
}

function Test-DiscoveryIntegerValue {
    <#
    .SYNOPSIS
        True when Value is a non-negative integer (int32, int64, or an integral double from JSON).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ($Value -is [int32] -or $Value -is [int64]) { return [int64]$Value -ge 0 }
    if ($Value -is [double]) { return ([math]::Floor($Value) -eq $Value) -and $Value -ge 0 }
    return $false
}

function ConvertFrom-DiscoveryManifestEntry {
    <#
    .SYNOPSIS
        Decodes one manifest entry strictly (exact keys, digest, size, category, relative path).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ((Get-DiscoverySortedPropertyNameList -Value $Value) -ne $script:EntryKeys) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'entry keys')
    }
    $path = Get-DiscoveryMemberValue -Value $Value -Name 'path'
    $sha256 = Get-DiscoveryMemberValue -Value $Value -Name 'sha256'
    $size = Get-DiscoveryMemberValue -Value $Value -Name 'size'
    $category = Get-DiscoveryMemberValue -Value $Value -Name 'category'
    if ($sha256 -isnot [string] -or $sha256 -cnotmatch $script:DigestPattern -or
        -not (Test-DiscoveryIntegerValue -Value $size) -or
        $category -isnot [string] -or $script:InputCategories -notcontains $category) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'entry fields')
    }
    if ($path -isnot [string] -or -not (Test-DiscoveryRelativePath -Path $path)) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'entry path')
    }
    return [ordered]@{ category = $category; path = $path; sha256 = $sha256; size = [int64]$size }
}

function ConvertFrom-DiscoveryRepositoryReference {
    <#
    .SYNOPSIS
        Decodes one `{id, revision}` repository reference strictly.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ((Get-DiscoverySortedPropertyNameList -Value $Value) -ne $script:RepositoryKeys) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'repository reference')
    }
    $id = Get-DiscoveryMemberValue -Value $Value -Name 'id'
    $revision = Get-DiscoveryMemberValue -Value $Value -Name 'revision'
    if ($id -isnot [string] -or $id -cnotmatch $script:IdentifierPattern -or
        $revision -isnot [string] -or $revision -cnotmatch $script:RevisionPattern) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'repository reference')
    }
    return [ordered]@{ id = $id; revision = $revision }
}

function Assert-DiscoveryUniqueValueSet {
    <#
    .SYNOPSIS
        Throws the manifest failure when Values contains a duplicate.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Values,
        [Parameter(Mandatory = $true)][string]$Detail
    )

    $distinct = @($Values | Select-Object -Unique)
    if ($distinct.Count -ne $Values.Count) { throw (Get-DiscoveryManifestFailureMessage -Detail $Detail) }
}

function ConvertFrom-DiscoveryInputManifest {
    <#
    .SYNOPSIS
        Parses a runtime-reported input manifest strictly.
    .DESCRIPTION
        Accepts the parsed JSON (PSCustomObject or hashtable) of
        `service-result#/$defs/input-manifest` and returns a normalized ordered
        manifest, or throws `INPUT_MANIFEST_INVALID` naming the defect. A path cannot
        be both read and missing; entry paths, missing paths and repository ids are
        unique.
    .OUTPUTS
        [System.Collections.Specialized.OrderedDictionary] entries, missing_paths,
        source_repositories, target_repositories, sha256.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ((Get-DiscoverySortedPropertyNameList -Value $Value) -ne $script:ManifestKeys) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'manifest keys')
    }
    $entries = Get-DiscoveryMemberValue -Value $Value -Name 'entries'
    $missing = Get-DiscoveryMemberValue -Value $Value -Name 'missing_paths'
    $sources = Get-DiscoveryMemberValue -Value $Value -Name 'source_repositories'
    $targets = Get-DiscoveryMemberValue -Value $Value -Name 'target_repositories'
    $sha256 = Get-DiscoveryMemberValue -Value $Value -Name 'sha256'
    # Arrays must be real arrays; a string is also IEnumerable, so it is excluded.
    foreach ($member in @($entries, $missing, $sources, $targets)) {
        if ($null -eq $member -or $member -is [string] -or $member -isnot [System.Collections.IEnumerable]) {
            throw (Get-DiscoveryManifestFailureMessage -Detail 'manifest fields')
        }
    }
    if ($sha256 -isnot [string] -or $sha256 -cnotmatch $script:DigestPattern) {
        throw (Get-DiscoveryManifestFailureMessage -Detail 'manifest fields')
    }
    $decodedEntries = @(foreach ($entry in $entries) { ConvertFrom-DiscoveryManifestEntry -Value $entry })
    $missingPaths = @(foreach ($path in $missing) {
            if ($path -isnot [string] -or -not (Test-DiscoveryRelativePath -Path $path)) {
                throw (Get-DiscoveryManifestFailureMessage -Detail 'missing path')
            }
            [string]$path
        })
    Assert-DiscoveryUniqueValueSet -Values @($decodedEntries | ForEach-Object { $_.path }) -Detail 'duplicate entry paths'
    Assert-DiscoveryUniqueValueSet -Values $missingPaths -Detail 'duplicate missing paths'
    # A path cannot be both read and missing in one manifest.
    $listed = @($decodedEntries | ForEach-Object { $_.path })
    foreach ($path in $missingPaths) {
        if ($listed -contains $path) { throw (Get-DiscoveryManifestFailureMessage -Detail 'missing path also listed as an entry') }
    }
    $sourceRefs = @(foreach ($row in $sources) { ConvertFrom-DiscoveryRepositoryReference -Value $row })
    $targetRefs = @(foreach ($row in $targets) { ConvertFrom-DiscoveryRepositoryReference -Value $row })
    Assert-DiscoveryUniqueValueSet -Values @($sourceRefs | ForEach-Object { $_.id }) -Detail 'duplicate source repositories'
    Assert-DiscoveryUniqueValueSet -Values @($targetRefs | ForEach-Object { $_.id }) -Detail 'duplicate target repositories'
    return [ordered]@{
        entries             = $decodedEntries
        missing_paths       = $missingPaths
        source_repositories = $sourceRefs
        target_repositories = $targetRefs
        sha256              = $sha256
    }
}

function Get-DiscoveryInputManifestDigest {
    <#
    .SYNOPSIS
        Returns the digest of the four manifest members in canonical JSON.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][System.Collections.IDictionary]$Manifest)

    $body = [ordered]@{
        entries             = @($Manifest['entries'])
        missing_paths       = @($Manifest['missing_paths'])
        source_repositories = @($Manifest['source_repositories'])
        target_repositories = @($Manifest['target_repositories'])
    }
    return Get-DiscoverySha256Hex -Text (ConvertTo-DiscoveryCanonicalJson -Value $body)
}

function Get-DiscoveryWorkspacePath {
    <#
    .SYNOPSIS
        Joins a workspace-relative path to the absolute root with forward slashes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    return $WorkspaceRoot.TrimEnd('/', '\') + '/' + $RelativePath
}

function Compare-DiscoveryInputManifest {
    <#
    .SYNOPSIS
        Re-reads every input and classifies every difference from the manifest as drift.
    .DESCRIPTION
        Returns the recomputed manifest (same entry set with fresh digests and sizes,
        digest recomputed) together with the drift list. A changed digest or size is
        `edited` (`evidence-replaced` for the evidence category), an absent file is
        `deleted`, a missing path that now exists is `appeared` unless its bytes equal
        a deleted input (`renamed`), and a profile binding that is absent or differs
        from the activation digest is `profile-changed`.
    .PARAMETER ReadBytes
        Seam returning the raw bytes of an absolute path, or $null when no regular
        file exists. The default reads the real filesystem.
    .OUTPUTS
        [pscustomobject] Manifest (ordered dictionary with sha256) and Drift (array of
        kind/path/detail objects).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Manifest,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$ProfilePath,
        [Parameter(Mandatory = $true)][string]$ProfileSha256,
        [Parameter(Mandatory = $false)][scriptblock]$ReadBytes = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllBytes($Path)
        }
    )

    $drift = [System.Collections.Generic.List[object]]::new()
    $entries = [System.Collections.Generic.List[object]]::new()
    $deletedDigests = @{}
    # Every listed input is re-read; a changed digest or size is an edit, an
    # absent file is a deletion, and evidence edits are named separately.
    foreach ($entry in @($Manifest['entries'])) {
        $bytes = & $ReadBytes (Get-DiscoveryWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath $entry['path'])
        if ($null -eq $bytes) {
            $deletedDigests[$entry['sha256']] = $entry['path']
            $drift.Add([pscustomobject]@{ kind = 'deleted'; path = $entry['path']; detail = 'input no longer exists' })
            continue
        }
        [byte[]]$bytes = @($bytes)
        $digest = Get-DiscoveryBytesSha256Hex -Bytes $bytes
        if ($digest -ne $entry['sha256'] -or $bytes.Length -ne $entry['size']) {
            $kind = $(if ($entry['category'] -eq 'evidence') { 'evidence-replaced' } else { 'edited' })
            $drift.Add([pscustomobject]@{ kind = $kind; path = $entry['path']; detail = "digest $($entry['sha256']) is now $digest" })
        }
        $entries.Add([ordered]@{ category = $entry['category']; path = $entry['path']; sha256 = $digest; size = [int64]$bytes.Length })
    }
    $stillMissing = [System.Collections.Generic.List[string]]::new()
    # A path the runtime found absent that now exists was created after the
    # result; when its bytes equal a deleted input it is a rename.
    foreach ($path in @($Manifest['missing_paths'])) {
        $bytes = & $ReadBytes (Get-DiscoveryWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath $path)
        if ($null -eq $bytes) { $stillMissing.Add($path); continue }
        $digest = Get-DiscoveryBytesSha256Hex -Bytes ([byte[]]@($bytes))
        if ($deletedDigests.ContainsKey($digest)) {
            $drift.Add([pscustomobject]@{ kind = 'renamed'; path = $path; detail = "moved from $($deletedDigests[$digest])" })
        } else {
            $drift.Add([pscustomobject]@{ kind = 'appeared'; path = $path; detail = 'missing input now exists' })
        }
    }
    # The protected activation binding must be one of the inputs and unchanged.
    $profileEntry = @($entries | Where-Object { $_['path'] -eq $ProfilePath } | Select-Object -First 1)
    if ($profileEntry.Count -eq 0) {
        $drift.Add([pscustomobject]@{ kind = 'profile-changed'; path = $ProfilePath; detail = 'profile was not among the inputs read' })
    } elseif ($profileEntry[0]['sha256'] -ne $ProfileSha256) {
        $drift.Add([pscustomobject]@{ kind = 'profile-changed'; path = $ProfilePath; detail = "profile digest $($profileEntry[0]['sha256']) differs from activation $ProfileSha256" })
    }
    $recomputed = [ordered]@{
        entries             = @($entries)
        missing_paths       = @($stillMissing)
        source_repositories = @($Manifest['source_repositories'])
        target_repositories = @($Manifest['target_repositories'])
    }
    $recomputed['sha256'] = Get-DiscoveryInputManifestDigest -Manifest $recomputed
    return [pscustomobject]@{ Manifest = $recomputed; Drift = @($drift) }
}

function Assert-DiscoveryInputsFresh {
    <#
    .SYNOPSIS
        Recomputes the manifest and throws INPUT_DRIFT when any input moved.
    .OUTPUTS
        [System.Collections.Specialized.OrderedDictionary] The recomputed manifest.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Manifest,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$ProfilePath,
        [Parameter(Mandatory = $true)][string]$ProfileSha256,
        [Parameter(Mandatory = $false)][scriptblock]$ReadBytes
    )

    $arguments = @{ Manifest = $Manifest; WorkspaceRoot = $WorkspaceRoot; ProfilePath = $ProfilePath; ProfileSha256 = $ProfileSha256 }
    if ($PSBoundParameters.ContainsKey('ReadBytes')) { $arguments['ReadBytes'] = $ReadBytes }
    $result = Compare-DiscoveryInputManifest @arguments
    if ($result.Drift.Count -gt 0) {
        $summary = @($result.Drift | ForEach-Object { "$($_.kind):$($_.path)" }) -join ', '
        throw "INPUT_DRIFT: Inputs changed after the runtime result: $summary"
    }
    return $result.Manifest
}

Export-ModuleMember -Function `
    ConvertFrom-DiscoveryInputManifest, `
    Get-DiscoveryInputManifestDigest, `
    Get-DiscoveryWorkspacePath, `
    Compare-DiscoveryInputManifest, `
    Assert-DiscoveryInputsFresh
