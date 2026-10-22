<#
.SYNOPSIS
    Narrow protected-authority primitives shared by every native discovery hook.

.DESCRIPTION
    Resolves the fixed external discovery authority location from trusted host
    values and decodes the protected activation record, with the same rules the
    TypeScript gateway (`discovery-authority-paths.ts`, `discovery-authority-record.ts`)
    and the Python runtime (`RegistryLocation.for_host`, `ActivationRecord`) apply:

        <user-state>/drm-copilot/discovery/workspaces/<sha256(canonical workspace)>

    Windows hashes the invariant-lowercase native spelling; POSIX preserves case.
    Session and invocation partitions are the digest of their correlation id.
    Hashing and canonical JSON come from the sibling DiscoveryEncoding module so
    hooks reproduce the runtime's digests byte for byte.

    The module performs no writes, invokes no process and never reads a profile,
    locator or request field to decide a location; every input is a trusted host
    value or an injected seam. A malformed or foreign record is a typed failure,
    never a silent pass.

.NOTES
    Issue #980. Compatible with PowerShell 7+. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/
    and published to the Codex bundle under .codex/lib/discovery-validation/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -Force -ErrorAction Stop

$script:AuthorityRootSegments = @('drm-copilot', 'discovery')
$script:ActivationRecordFile = 'activation.json'
$script:ActivationSchemaVersion = '2.0.0'
$script:ActivationRecordKeys = @(
    'action', 'generation', 'locator_sha256', 'previous_sha256',
    'profile_path', 'profile_sha256', 'schema_version', 'workspace_sha256'
)
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
$script:Sha256Pattern = '^[0-9a-f]{64}$'
$script:RelativePathPattern = '^(?!/)(?!.*(?:^|/)\.{1,2}(?:/|$))[^/\\:\u2028\u2029*?<>|]+(?:/[^/\\:\u2028\u2029*?<>|]+)*$'
$script:ReservedDevicePattern = '^(?:CON|PRN|AUX|NUL|CONIN\$|CONOUT\$|CLOCK\$|(?:COM|LPT)[1-9\u00b9\u00b2\u00b3])$'
$script:MaxRecordBytes = 65536

function ConvertTo-DiscoveryCanonicalPath {
    <#
    .SYNOPSIS
        Splits a trusted absolute path into anchor and segments the way pathlib does.
    .DESCRIPTION
        Separators collapse, `.` segments vanish, trailing separators are dropped and
        `..` is rejected because an unresolved alias cannot identify a workspace.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][ValidateSet('windows', 'macos', 'linux')][string]$Platform,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $windowsPlatform = $Platform -eq 'windows'
    $driveRooted = $windowsPlatform -and ($Path -match '^[A-Za-z]:[\\/]')
    $uncRooted = $windowsPlatform -and ($Path -match '^[\\/]{2}[^\\/]+[\\/][^\\/]+')
    if (-not ($driveRooted -or $uncRooted -or ((-not $windowsPlatform) -and $Path.StartsWith('/')))) {
        throw "AUTHORITY_PATH_NOT_CANONICAL: $Label must be an absolute path: $Path"
    }
    $unified = $(if ($windowsPlatform) { $Path.Replace('\', '/') } else { $Path })
    # The anchor is the drive, the UNC share or the POSIX root (two leading
    # slashes stay a distinct root, as pathlib treats them).
    if ($driveRooted) {
        $anchor = $unified.Substring(0, 2) + '/'
        $rest = $unified.Substring(3)
    } elseif ($uncRooted) {
        $match = [regex]::Match($unified, '^//([^/]+)/([^/]+)/?')
        $anchor = '//' + $match.Groups[1].Value + '/' + $match.Groups[2].Value + '/'
        $rest = $unified.Substring($match.Length)
    } else {
        $anchor = $(if ($unified -match '^//(?!/)') { '//' } else { '/' })
        $rest = $unified.TrimStart('/')
    }
    $parts = [System.Collections.Generic.List[string]]::new()
    # Drop empty and current-directory segments; reject parent references.
    foreach ($segment in $rest.Split('/')) {
        if ($segment -eq '' -or $segment -eq '.') { continue }
        if ($segment -eq '..') {
            throw "AUTHORITY_PATH_NOT_CANONICAL: $Label must not contain parent references: $Path"
        }
        $parts.Add($segment)
    }
    return @{ Platform = $Platform; Anchor = $anchor; Parts = $parts.ToArray() }
}

function ConvertTo-DiscoveryPosixPath {
    <#
    .SYNOPSIS
        Renders a canonical path in POSIX spelling (what PurePath.as_posix prints).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][hashtable]$CanonicalPath)

    $joined = ($CanonicalPath.Parts -join '/')
    if ($joined -eq '') { return $CanonicalPath.Anchor }
    return $CanonicalPath.Anchor + $joined
}

function Test-DiscoveryCanonicalPathWithin {
    <#
    .SYNOPSIS
        True when Candidate equals or descends from Ancestor (case-insensitive on Windows).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Candidate,
        [Parameter(Mandatory = $true)][hashtable]$Ancestor
    )

    $fold = $Candidate.Platform -eq 'windows'
    $comparison = $(if ($fold) { [System.StringComparison]::OrdinalIgnoreCase } else { [System.StringComparison]::Ordinal })
    if (-not [string]::Equals($Candidate.Anchor, $Ancestor.Anchor, $comparison)) { return $false }
    if ($Candidate.Parts.Count -lt $Ancestor.Parts.Count) { return $false }
    # Every ancestor segment must match the candidate prefix segment-wise.
    for ($index = 0; $index -lt $Ancestor.Parts.Count; $index++) {
        if (-not [string]::Equals($Candidate.Parts[$index], $Ancestor.Parts[$index], $comparison)) { return $false }
    }
    return $true
}

function Resolve-DiscoveryAuthorityLocation {
    <#
    .SYNOPSIS
        Resolves the protected authority location for a workspace from trusted host values.
    .DESCRIPTION
        Mirrors `RegistryLocation.for_host`: the workspace, home and state roots must
        be absolute without parent references, the state root is fixed platform
        policy (LocalApplicationData, ~/Library/Application Support, or
        $XDG_STATE_HOME / ~/.local/state), and the authority root must lie outside
        the workspace. No directory is created or read.
    .OUTPUTS
        [pscustomobject] Platform, Workspace, WorkspaceSha256, Root, Directory (POSIX spelling).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][ValidateSet('windows', 'macos', 'linux')][string]$Platform,
        [Parameter(Mandatory = $true)][string]$UserHome,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$LocalAppData,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$XdgStateHome
    )

    $workspace = ConvertTo-DiscoveryCanonicalPath -Path $WorkspaceRoot -Platform $Platform -Label 'Workspace root'
    $userHomePath = ConvertTo-DiscoveryCanonicalPath -Path $UserHome -Platform $Platform -Label 'User home'
    # Platform state locations are fixed policy; profiles cannot redirect them.
    switch ($Platform) {
        'windows' {
            if ([string]::IsNullOrEmpty($LocalAppData)) {
                throw 'AUTHORITY_STATE_ROOT_MISSING: Trusted LocalApplicationData is required on Windows.'
            }
            $base = ConvertTo-DiscoveryCanonicalPath -Path $LocalAppData -Platform $Platform -Label 'LocalApplicationData'
        }
        'macos' {
            $base = @{ Platform = $Platform; Anchor = $userHomePath.Anchor; Parts = @($userHomePath.Parts + @('Library', 'Application Support')) }
        }
        default {
            if (-not [string]::IsNullOrEmpty($XdgStateHome)) {
                $base = ConvertTo-DiscoveryCanonicalPath -Path $XdgStateHome -Platform $Platform -Label 'XDG_STATE_HOME'
            } else {
                $base = @{ Platform = $Platform; Anchor = $userHomePath.Anchor; Parts = @($userHomePath.Parts + @('.local', 'state')) }
            }
        }
    }
    $root = @{ Platform = $Platform; Anchor = $base.Anchor; Parts = @($base.Parts + $script:AuthorityRootSegments) }
    if (Test-DiscoveryCanonicalPathWithin -Candidate $root -Ancestor $workspace) {
        throw 'AUTHORITY_INSIDE_WORKSPACE: Activation authority must remain outside the workspace.'
    }
    $posixWorkspace = ConvertTo-DiscoveryPosixPath -CanonicalPath $workspace
    # Windows identity uses native separators and invariant lowercase, matching
    # the Python runtime and the TypeScript gateway; POSIX preserves case.
    $identity = $(if ($Platform -eq 'windows') { $posixWorkspace.Replace('/', '\').ToLowerInvariant() } else { $posixWorkspace })
    $digest = Get-DiscoverySha256Hex -Text $identity
    $directory = @{ Platform = $Platform; Anchor = $root.Anchor; Parts = @($root.Parts + @('workspaces', $digest)) }
    return [pscustomobject]@{
        Platform        = $Platform
        Workspace       = $posixWorkspace
        WorkspaceSha256 = $digest
        Root            = ConvertTo-DiscoveryPosixPath -CanonicalPath $root
        Directory       = ConvertTo-DiscoveryPosixPath -CanonicalPath $directory
    }
}

function Get-DiscoveryTrustedHostEnvironment {
    <#
    .SYNOPSIS
        Returns the trusted host environment (platform, home, state roots) with injectable seams.
    .DESCRIPTION
        Defaults read the running host, never a profile or request value. Tests pass
        every value explicitly so no assertion depends on the machine.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][string]$Platform,
        [Parameter(Mandatory = $false)][AllowNull()][string]$UserHome,
        [Parameter(Mandatory = $false)][AllowNull()][string]$LocalAppData,
        [Parameter(Mandatory = $false)][AllowNull()][string]$XdgStateHome
    )

    if ([string]::IsNullOrEmpty($Platform)) {
        $Platform = $(if ($IsWindows) { 'windows' } elseif ($IsMacOS) { 'macos' } else { 'linux' })
    }
    if ([string]::IsNullOrEmpty($UserHome)) { $UserHome = [System.Environment]::GetFolderPath('UserProfile') }
    if ($null -eq $LocalAppData) { $LocalAppData = [System.Environment]::GetFolderPath('LocalApplicationData') }
    if ($null -eq $XdgStateHome) { $XdgStateHome = [string]$env:XDG_STATE_HOME }
    return @{ Platform = $Platform; UserHome = $UserHome; LocalAppData = $LocalAppData; XdgStateHome = $XdgStateHome }
}

function Get-DiscoveryPartitionName {
    <#
    .SYNOPSIS
        Returns the digest partition name for a correlation identifier.
    .DESCRIPTION
        Correlation identifiers may contain `:` and are case-sensitive, so the
        partition is the SHA-256 of the identifier rather than the identifier itself.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$CorrelationId)

    if ($CorrelationId -cnotmatch $script:CorrelationIdPattern -or $CorrelationId.Length -gt 256) {
        throw "AUTHORITY_PARTITION_INVALID: Partition identifier is not a valid correlation id: $CorrelationId"
    }
    return Get-DiscoverySha256Hex -Text $CorrelationId
}

function Get-DiscoverySessionDirectory {
    <#
    .SYNOPSIS
        Returns `<directory>/sessions/<sha256(sessionId)>`.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$SessionId
    )

    return "$($Location.Directory)/sessions/$(Get-DiscoveryPartitionName -CorrelationId $SessionId)"
}

function Get-DiscoveryInvocationDirectory {
    <#
    .SYNOPSIS
        Returns `<session>/invocations/<sha256(invocationId)>`.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][string]$InvocationId
    )

    $session = Get-DiscoverySessionDirectory -Location $Location -SessionId $SessionId
    return "$session/invocations/$(Get-DiscoveryPartitionName -CorrelationId $InvocationId)"
}

function Get-DiscoveryActivationRecordPath {
    <#
    .SYNOPSIS
        Returns the path of the fixed activation record for a location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][pscustomobject]$Location)

    return "$($Location.Directory)/$($script:ActivationRecordFile)"
}

function Test-DiscoveryProtectedPath {
    <#
    .SYNOPSIS
        True only when Candidate lies inside the protected directory and outside the workspace.
    .DESCRIPTION
        Analyst-authored reports, invocation mirrors and workspace copies of the
        registry are editable; a path anywhere other than the protected directory
        can never be read as native authority.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$Candidate
    )

    $target = ConvertTo-DiscoveryCanonicalPath -Path $Candidate -Platform $Location.Platform -Label 'Candidate path'
    $workspace = ConvertTo-DiscoveryCanonicalPath -Path $Location.Workspace -Platform $Location.Platform -Label 'Workspace root'
    $directory = ConvertTo-DiscoveryCanonicalPath -Path $Location.Directory -Platform $Location.Platform -Label 'Authority directory'
    if (Test-DiscoveryCanonicalPathWithin -Candidate $target -Ancestor $workspace) { return $false }
    return Test-DiscoveryCanonicalPathWithin -Candidate $target -Ancestor $directory
}

function Test-DiscoveryRelativePath {
    <#
    .SYNOPSIS
        True when Path is a normalized workspace-relative path (no root, no `.`/`..`, no reserved device).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path)

    if ($Path -cnotmatch $script:RelativePathPattern) { return $false }
    # Every segment, with and without its extension, must avoid Windows device names.
    foreach ($segment in $Path.Split('/')) {
        $stem = $segment.Split('.')[0]
        if ($segment -cmatch $script:ReservedDevicePattern -or $stem -cmatch $script:ReservedDevicePattern) { return $false }
    }
    return $true
}

function Test-DiscoveryDigestText {
    <#
    .SYNOPSIS
        True when Value is a lowercase 64-hex SHA-256 string.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    return ($Value -is [string]) -and ($Value -cmatch $script:Sha256Pattern)
}

function ConvertFrom-DiscoveryActivationRecord {
    <#
    .SYNOPSIS
        Decodes protected activation text, rejecting malformed data and foreign workspaces.
    .DESCRIPTION
        Field rules mirror `ActivationRecord.__post_init__` and the TypeScript
        decoder: exactly the eight keys, schema version 2.0.0, action activate or
        deactivate, a positive integer generation whose textual literal is a plain
        integer, lowercase digests, a workspace-relative profile path, and
        all-or-nothing profile/locator bindings. A workspace digest that differs from
        WorkspaceSha256 is `ACTIVATION_WORKSPACE`; every other defect is
        `ACTIVATION_INVALID`.
    .OUTPUTS
        [pscustomobject] The validated record with the eight snake_case members.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][string]$WorkspaceSha256
    )

    if ([System.Text.Encoding]::UTF8.GetByteCount($Text) -gt $script:MaxRecordBytes) {
        throw 'ACTIVATION_INVALID: Protected activation record exceeds the size limit.'
    }
    try {
        $parsed = ConvertFrom-Json -InputObject $Text -Depth 4 -NoEnumerate
    } catch {
        throw 'ACTIVATION_INVALID: Protected activation record is not JSON.'
    }
    if ($null -eq $parsed -or $parsed -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'ACTIVATION_INVALID: Protected activation record is malformed.'
    }
    [string[]]$keys = @($parsed.PSObject.Properties.Name)
    [Array]::Sort($keys, [System.StringComparer]::Ordinal)
    if (($keys -join ',') -ne ($script:ActivationRecordKeys -join ',')) {
        throw 'ACTIVATION_INVALID: Protected activation record is malformed.'
    }
    $generation = $parsed.generation
    # ConvertFrom-Json turns `1.0` into a double, so the textual literal is checked
    # as well to keep parity with Python's exact-int rule.
    $integerLiteral = [regex]::IsMatch($Text, '"generation"\s*:\s*[1-9][0-9]*\s*[,}]')
    if ($parsed.schema_version -ne $script:ActivationSchemaVersion -or
        ($parsed.action -ne 'activate' -and $parsed.action -ne 'deactivate') -or
        -not ($generation -is [int32] -or $generation -is [int64]) -or $generation -lt 1 -or -not $integerLiteral) {
        throw 'ACTIVATION_INVALID: Invalid activation version, action or generation.'
    }
    $digests = @($parsed.workspace_sha256, $parsed.profile_sha256, $parsed.locator_sha256, $parsed.previous_sha256)
    foreach ($digest in $digests) {
        if ($null -ne $digest -and -not (Test-DiscoveryDigestText -Value $digest)) {
            throw 'ACTIVATION_INVALID: Activation digests must be lowercase SHA-256.'
        }
    }
    if (-not (Test-DiscoveryDigestText -Value $parsed.workspace_sha256)) {
        throw 'ACTIVATION_INVALID: Activation requires a canonical workspace digest.'
    }
    if ($null -ne $parsed.profile_path) {
        if ($parsed.profile_path -isnot [string]) {
            throw 'ACTIVATION_INVALID: Activation profile path must be a string or null.'
        }
        if (-not (Test-DiscoveryRelativePath -Path $parsed.profile_path)) {
            throw 'ACTIVATION_INVALID: Activation profile path is not workspace-relative.'
        }
    }
    # Bindings are all-or-nothing, and activation always carries them.
    $linked = @($parsed.profile_path, $parsed.profile_sha256, $parsed.locator_sha256)
    $incomplete = @($linked | Where-Object { $null -eq $_ }).Count -gt 0
    $anyBound = @($linked | Where-Object { $null -ne $_ }).Count -gt 0
    if ($incomplete -and ($parsed.action -eq 'activate' -or $anyBound)) {
        throw 'ACTIVATION_INVALID: Activation profile and locator bindings must be complete.'
    }
    if ($parsed.workspace_sha256 -ne $WorkspaceSha256) {
        throw 'ACTIVATION_WORKSPACE: Protected activation belongs to another workspace.'
    }
    return [pscustomobject]@{
        action           = [string]$parsed.action
        generation       = [int64]$generation
        locator_sha256   = $parsed.locator_sha256
        previous_sha256  = $parsed.previous_sha256
        profile_path     = $parsed.profile_path
        profile_sha256   = $parsed.profile_sha256
        schema_version   = $script:ActivationSchemaVersion
        workspace_sha256 = [string]$parsed.workspace_sha256
    }
}

function Read-DiscoveryActivationState {
    <#
    .SYNOPSIS
        Reads the protected activation record and classifies the workspace state.
    .DESCRIPTION
        Status is `missing` when no record exists, `invalid` when the text fails the
        decoder (Reason carries the typed message), `inactive` when the record is a
        deactivate tombstone, and `active` otherwise. The read goes through the
        ReadText seam, which returns the file text or $null; the default reads the
        path with UTF-8 and returns $null for a missing file.
    .OUTPUTS
        [pscustomobject] Status, Record, Reason, Path.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $false)][scriptblock]$ReadText = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        }
    )

    $path = Get-DiscoveryActivationRecordPath -Location $Location
    $text = & $ReadText $path
    if ($null -eq $text) {
        return [pscustomobject]@{ Status = 'missing'; Record = $null; Reason = 'no protected activation record exists'; Path = $path }
    }
    try {
        $record = ConvertFrom-DiscoveryActivationRecord -Text ([string]$text) -WorkspaceSha256 $Location.WorkspaceSha256
    } catch {
        return [pscustomobject]@{ Status = 'invalid'; Record = $null; Reason = $_.Exception.Message; Path = $path }
    }
    $status = $(if ($record.action -eq 'deactivate') { 'inactive' } else { 'active' })
    return [pscustomobject]@{ Status = $status; Record = $record; Reason = $null; Path = $path }
}

Export-ModuleMember -Function `
    Resolve-DiscoveryAuthorityLocation, `
    Get-DiscoveryTrustedHostEnvironment, `
    Get-DiscoveryPartitionName, `
    Get-DiscoverySessionDirectory, `
    Get-DiscoveryInvocationDirectory, `
    Get-DiscoveryActivationRecordPath, `
    Test-DiscoveryProtectedPath, `
    Test-DiscoveryRelativePath, `
    ConvertFrom-DiscoveryActivationRecord, `
    Read-DiscoveryActivationState
