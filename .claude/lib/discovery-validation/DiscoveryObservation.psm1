<#
.SYNOPSIS
    Host observations and the sentinel decision of the native discovery PreToolUse adapters.

.DESCRIPTION
    The capability probe cannot assume what a host places in its hook payloads.
    Instead, a sentinel agent calls the sentinel MCP tool and runs one harmless
    shell command, and the PreToolUse gate records what it received as a
    `host-observation` under `sessions/<sha256(session id)>/observations/`: the
    payload identity fields as received (`agent_id` and `agent_type` may be null),
    whether a tool-call identifier was present, the decision and its code, and the
    handler hash. The sentinel tool observation also carries the one-use sentinel
    grant fields the MCP server consumes. The probe then proves attribution from
    these records and reports `unsupported` otherwise.

    Store access flows through injected seams; the module never invokes a process.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority and DiscoveryToolRouting modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryToolRouting.psm1') -ErrorAction Stop

$script:ObservationSchema = 'urn:drm-copilot:discovery:2.0.0:host-observation'
$script:ObservationPartition = 'observations'
$script:SentinelAgentType = 'discovery-capability-sentinel'
$script:SentinelToolName = 'discovery_capability_sentinel'
$script:SentinelOperation = 'sentinel'
$script:SentinelCommandPrefix = 'drm-copilot discovery capability probe '
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
# Schema timestamp spelling for observed_at and expires_at.
$script:TimestampFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

function Get-DiscoverySentinelCommandPrefix {
    <#
    .SYNOPSIS
        Returns the prefix of the harmless sentinel shell command the gate must deny.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return $script:SentinelCommandPrefix
}

function Get-DiscoveryObservationDirectory {
    <#
    .SYNOPSIS
        Returns `<session>/observations` for SessionId under the resolved location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$SessionId
    )

    return "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $SessionId)/$($script:ObservationPartition)"
}

function Test-DiscoverySentinelEnvelope {
    <#
    .SYNOPSIS
        True when the envelope comes from the sentinel agent type, names the sentinel tool, or runs the sentinel command.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][pscustomobject]$Tool
    )

    if ($Normalized.AgentType -is [string] -and $Normalized.AgentType -ceq $script:SentinelAgentType) { return $true }
    if ($Tool.Family -eq 'mcp-discovery' -and $Tool.Name -ceq $script:SentinelToolName) { return $true }
    if ($Tool.Family -eq 'shell' -and $null -ne $Normalized.ToolInput) {
        $command = Get-DiscoveryInputMember -ToolInput $Normalized.ToolInput -Name 'command'
        if ($command -is [string] -and $command.StartsWith($script:SentinelCommandPrefix, [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function ConvertTo-DiscoveryHostObservationRecord {
    <#
    .SYNOPSIS
        Builds one `host-observation` record from the payload as received and the gate's decision.
    .DESCRIPTION
        The reference is derived from the host's tool-call identifier when one is
        present (one record per tool call), else from the nonce. When
        SentinelInputSha256 is supplied the record also carries the one-use sentinel
        grant fields (tool, input digest, expiry, state `issued`).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$ToolName,
        [Parameter(Mandatory = $true)][ValidateSet('allow', 'deny')][string]$Decision,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $false)][AllowNull()][string]$SentinelInputSha256 = $null,
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 300
    )

    $toolUseId = $(if ($Normalized.ToolUseId -is [string] -and $Normalized.ToolUseId -cmatch $script:CorrelationIdPattern) { [string]$Normalized.ToolUseId } else { $null })
    $suffix = $(if ($null -ne $toolUseId) { (Get-DiscoverySha256Hex -Text $toolUseId).Substring(0, 20) } else { $Nonce })
    $record = [ordered]@{
        '$schema'           = $script:ObservationSchema
        schema_version      = '2.0.0'
        artifact_kind       = 'host-observation'
        id                  = "observation-$suffix"
        observation_ref     = "observation-$suffix"
        host                = $Principal.HostName
        session_id          = $Principal.SessionId
        agent_id            = $(if ($Normalized.AgentId -is [string] -and $Normalized.AgentId -cmatch $script:CorrelationIdPattern) { [string]$Normalized.AgentId } else { $null })
        agent_type          = $(if ($Normalized.AgentType -is [string] -and $Normalized.AgentType -cmatch $script:CorrelationIdPattern) { [string]$Normalized.AgentType } else { $null })
        parent_agent_id     = $Principal.ParentAgentId
        tool_name           = $ToolName
        tool_use_id_present = ($null -ne $toolUseId)
        decision            = $Decision
        code                = $Code
        handler_sha256      = $HandlerSha256
        observed_at         = $Now.ToUniversalTime().ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
    }
    if (-not [string]::IsNullOrEmpty($SentinelInputSha256)) {
        $record['tool'] = $script:SentinelToolName
        $record['input_sha256'] = $SentinelInputSha256
        $record['expires_at'] = $Now.ToUniversalTime().AddSeconds($TtlSeconds).ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
        $record['state'] = 'issued'
    }
    return $record
}

function Write-DiscoveryHostObservation {
    <#
    .SYNOPSIS
        Writes one observation exclusively under `<session>/observations` and returns its path.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][System.Collections.Specialized.OrderedDictionary]$Record,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = Get-DiscoveryObservationDirectory -Location $Location -SessionId ([string]$Record['session_id'])
    $path = "$directory/$($Record['observation_ref']).json"
    if (-not $PSCmdlet.ShouldProcess($path, 'write host observation')) { return $path }
    Invoke-DiscoveryStoreSeam -Seam $Store.EnsureDirectory -Arguments @($directory)
    Invoke-DiscoveryStoreSeam -Seam $Store.WriteText -Arguments @($path, (($Record | ConvertTo-Json -Depth 8) + "`n"))
    return $path
}

function Get-DiscoverySentinelDecision {
    <#
    .SYNOPSIS
        Decides a sentinel envelope: deny the sentinel shell command, allow the sentinel tool with a grant, deny anything else.
    .DESCRIPTION
        Every branch records an observation; the sentinel tool observation carries the
        one-use grant fields. A failed observation write denies with STORE so no
        unobserved sentinel call proceeds. No root grant and no tool authorization is
        ever written for a sentinel envelope.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Record, RecordPath.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][pscustomobject]$Tool,
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 300
    )

    $toolName = [string]$Normalized.ToolName
    $digest = $null
    # Routing: the shell sentinel is denied, the sentinel tool is allowed with a grant, anything else is denied.
    if ($Tool.Family -eq 'shell') {
        $decision = 'deny'; $code = 'SHELL'; $reason = "the sentinel shell command is denied; shell tools are not available to $($script:SentinelAgentType)"
    } elseif ($Tool.Family -eq 'mcp-discovery' -and $Tool.Name -ceq $script:SentinelToolName) {
        $decision = 'allow'; $code = 'SENTINEL'; $reason = 'the sentinel tool call is observed and granted once'
        $digest = Get-DiscoveryInputDigest -Tool $script:SentinelToolName -Operation $script:SentinelOperation -Inputs $Normalized.ToolInput
    } else {
        $decision = 'deny'; $code = 'UNKNOWN_TOOL'; $reason = "tool $toolName is outside the sentinel grant"
    }
    $record = ConvertTo-DiscoveryHostObservationRecord -Normalized $Normalized -Principal $Principal -ToolName $toolName -Decision $decision -Code $code `
        -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce -SentinelInputSha256 $digest -TtlSeconds $TtlSeconds
    try {
        $path = Write-DiscoveryHostObservation -Location $Location -Record $record -Store $Store
    } catch {
        return [pscustomobject]@{ Decision = 'deny'; Code = 'STORE'; Reason = "the host observation could not be recorded: $($_.Exception.Message)"; Record = $null; RecordPath = $null }
    }
    return [pscustomobject]@{ Decision = $decision; Code = $code; Reason = $reason; Record = $record; RecordPath = $path }
}

Export-ModuleMember -Function `
    Get-DiscoverySentinelCommandPrefix, `
    Get-DiscoveryObservationDirectory, `
    Test-DiscoverySentinelEnvelope, `
    ConvertTo-DiscoveryHostObservationRecord, `
    Write-DiscoveryHostObservation, `
    Get-DiscoverySentinelDecision
