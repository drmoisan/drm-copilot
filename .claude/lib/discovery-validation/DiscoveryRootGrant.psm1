<#
.SYNOPSIS
    One-use root grants written by the native discovery PreToolUse adapters for root calls.

.DESCRIPTION
    When the PreToolUse payload carries no agent identity, the caller is the root
    of its session. For `prepare_discovery_agent`, `run_discovery_doctor` and every
    controlled discovery tool called by the root, the gate writes one short-lived,
    one-use `root-grant` record under `<authority root>/root-grants/`, bound to the
    tool, the derived operation and the request digest. The MCP server consumes the
    grant by tool, operation and digest and takes the host, session and parent from
    it; nothing in tool input selects or supplies those values.

    A root grant for prepare and for a controlled tool is written only when the
    session's protected capability attestation is `supported` and unexpired, which
    is the same reading the start decision performs. The doctor grant has no
    precondition, because the probe is what produces that attestation.

    Store access flows through injected seams; the module never invokes a process.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority and DiscoveryStartRecord modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStartRecord.psm1') -ErrorAction Stop

$script:RootGrantSchema = 'urn:drm-copilot:discovery:2.0.0:root-grant'
$script:RootGrantPartition = 'root-grants'
$script:CapabilityAttestationFile = 'capability-attestation.json'
# Schema timestamp spelling for issued_at and expires_at.
$script:TimestampFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

function Get-DiscoveryRootGrantDirectory {
    <#
    .SYNOPSIS
        Returns `<authority root>/root-grants` for the resolved workspace location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][pscustomobject]$Location)

    return "$($Location.Directory)/$($script:RootGrantPartition)"
}

function ConvertTo-DiscoveryRootGrantRecord {
    <#
    .SYNOPSIS
        Builds one `root-grant` record bound to the root principal, tool, operation and request digest.
    .DESCRIPTION
        State is always `issued`; the server consumes it exactly once. `issued_at`
        and `expires_at` come from the injected instant and TTL, never from the
        request. The record is state in the protected store; no file is changed here.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$InputSha256,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolUseId = $null,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 300
    )

    $toolUse = $(if ([string]::IsNullOrWhiteSpace($ToolUseId)) { $null } else { $ToolUseId })
    return [ordered]@{
        '$schema'       = $script:RootGrantSchema
        schema_version  = '2.0.0'
        artifact_kind   = 'root-grant'
        id              = "grant-$Nonce"
        grant_ref       = "grant-$Nonce"
        host            = $Principal.HostName
        session_id      = $Principal.SessionId
        parent_agent_id = $Principal.ParentAgentId
        tool            = $Tool
        operation       = $Operation
        input_sha256    = $InputSha256
        tool_use_id     = $toolUse
        handler_sha256  = $HandlerSha256
        issued_at       = $Now.ToUniversalTime().ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
        expires_at      = $Now.ToUniversalTime().AddSeconds($TtlSeconds).ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
        state           = 'issued'
    }
}

function Test-DiscoveryRootGrantPrecondition {
    <#
    .SYNOPSIS
        Returns the deficiency that forbids a root grant, or $null when the session capability is current.
    .DESCRIPTION
        Reads `<session>/capability-attestation.json` through the store seam, as the
        start decision does, and requires a `capability-attestation` record whose
        status is `supported`, whose expiry is after Now, and whose host, session and
        workspace equal the principal's and the resolved location's.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][datetime]$Now
    )

    $path = "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $Principal.SessionId)/$($script:CapabilityAttestationFile)"
    $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($path)
    if ($null -eq $text) { return 'the session has no readable protected capability attestation' }
    try { $capability = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { return 'the session capability attestation is not readable JSON' }
    if ($capability -isnot [System.Management.Automation.PSCustomObject]) { return 'the session capability attestation is not an object' }
    $names = @($capability.PSObject.Properties.Name)
    foreach ($required in @('artifact_kind', 'status', 'host', 'session_id', 'workspace', 'expires_at')) {
        if ($names -notcontains $required) { return "the capability attestation lacks '$required'" }
    }
    $expires = ConvertTo-DiscoveryUtcInstant -Value $capability.expires_at
    # A grant needs a current supported attestation bound to this host, session and workspace.
    if ($capability.artifact_kind -ne 'capability-attestation' -or $capability.status -ne 'supported' -or $null -eq $expires -or $expires -le $Now.ToUniversalTime()) {
        return 'the capability attestation is not a current supported attestation'
    }
    if ($capability.host -ne $Principal.HostName -or $capability.session_id -ne $Principal.SessionId -or [string]$capability.workspace.workspace_sha256 -ne $Location.WorkspaceSha256) {
        return 'the capability attestation is bound to another host, session or workspace'
    }
    return $null
}

function Write-DiscoveryRootGrant {
    <#
    .SYNOPSIS
        Writes one root-grant record exclusively under `root-grants/` and returns its path.
    .DESCRIPTION
        The directory is created when absent and the record is written through the
        exclusive WriteText seam, so a second writer for the same reference fails
        instead of replacing a record. The seam's error propagates to the caller.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][System.Collections.Specialized.OrderedDictionary]$Record,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = Get-DiscoveryRootGrantDirectory -Location $Location
    $path = "$directory/$($Record['grant_ref']).json"
    if (-not $PSCmdlet.ShouldProcess($path, 'write root grant')) { return $path }
    Invoke-DiscoveryStoreSeam -Seam $Store.EnsureDirectory -Arguments @($directory)
    Invoke-DiscoveryStoreSeam -Seam $Store.WriteText -Arguments @($path, (($Record | ConvertTo-Json -Depth 8) + "`n"))
    return $path
}

Export-ModuleMember -Function `
    Get-DiscoveryRootGrantDirectory, `
    ConvertTo-DiscoveryRootGrantRecord, `
    Test-DiscoveryRootGrantPrecondition, `
    Write-DiscoveryRootGrant
