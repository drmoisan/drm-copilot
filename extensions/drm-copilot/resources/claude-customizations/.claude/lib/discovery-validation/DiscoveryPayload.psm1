<#
.SYNOPSIS
    Host event-envelope normalization and trusted principal attribution for discovery hooks.

.DESCRIPTION
    Claude Code, Codex and the GitHub Copilot local harness deliver hook events as
    JSON envelopes with host-specific key spellings. This module normalizes each
    supported envelope into one shape (host, event, session, agent, tool name,
    tool input, working directory) and derives the trusted principal from the
    attested host context: the envelope's session plus the `DRM_DISCOVERY_*`
    values the native host adapter places in the process environment. Identity
    never comes from caller arguments or tool input; when the attested context is
    missing or contradicts the envelope the principal is unattributed and the
    calling hook fails closed.

    Malformed envelopes are typed anomalies, never silent nulls, so a hook can emit
    one deny reason per contract leg that drifted.

.NOTES
    Issue #980. Compatible with PowerShell 7+. No filesystem access, no subprocess,
    no network, no wall-clock read.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:SupportedHosts = @('claude-code', 'codex', 'github-copilot')
$script:EnvironmentKeys = @{
    Host          = 'DRM_DISCOVERY_HOST'
    SessionId     = 'DRM_DISCOVERY_SESSION_ID'
    ParentAgentId = 'DRM_DISCOVERY_PARENT_AGENT_ID'
    ParentRole    = 'DRM_DISCOVERY_PARENT_ROLE'
    AgentId       = 'DRM_DISCOVERY_AGENT_ID'
    AgentRole     = 'DRM_DISCOVERY_AGENT_ROLE'
}
# Per-host envelope key spellings, most specific first. Claude Code and Codex use
# snake_case; the Copilot local harness uses camelCase and may fall back to
# snake_case for fields it shares with the Claude shape.
$script:EnvelopeKeys = @{
    'claude-code'    = @{ SessionId = @('session_id'); Event = @('hook_event_name'); ToolName = @('tool_name'); ToolInput = @('tool_input'); Cwd = @('cwd'); AgentId = @('agent_id'); AgentType = @('agent_type') }
    'codex'          = @{ SessionId = @('session_id'); Event = @('hook_event_name'); ToolName = @('tool_name'); ToolInput = @('tool_input'); Cwd = @('cwd'); AgentId = @('agent_id'); AgentType = @('agent_type') }
    'github-copilot' = @{ SessionId = @('sessionId', 'session_id'); Event = @('hookEventName', 'hook_event_name'); ToolName = @('toolName', 'tool_name'); ToolInput = @('toolInput', 'tool_input'); Cwd = @('cwd'); AgentId = @('agentId', 'agent_id'); AgentType = @('agentType', 'agent_type') }
}
$script:AnomalyReasonText = @{
    'EmptyEnvelope'      = 'the hook received no envelope object'
    'UnsupportedHost'    = 'the hook received an envelope for a host that has no native discovery adapter'
    'MissingSessionId'   = 'the hook received an envelope without a trusted session identifier'
    'MissingEvent'       = 'the hook received an envelope without a hook event name'
    'NonObjectToolInput' = 'the hook received a tool event whose tool input is not an object'
}

function Get-DiscoveryEnvelopeMember {
    <#
    .SYNOPSIS
        Returns the first present member among Names on a hashtable or PSCustomObject, else $null.
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param(
        [Parameter(Mandatory = $true)][object]$Envelope,
        [Parameter(Mandatory = $true)][string[]]$Names
    )

    # The first spelling that exists wins, even when its value is null; the unary
    # comma keeps an array value intact across the function boundary.
    foreach ($name in $Names) {
        if ($Envelope -is [System.Collections.IDictionary]) {
            if ($Envelope.Contains($name)) {
                if ($null -eq $Envelope[$name]) { return $null }
                return , $Envelope[$name]
            }
        } elseif ($null -ne $Envelope.PSObject.Properties[$name]) {
            $member = $Envelope.PSObject.Properties[$name].Value
            if ($null -eq $member) { return $null }
            return , $member
        }
    }
    return $null
}

function Get-DiscoveryPayloadAnomalyReason {
    <#
    .SYNOPSIS
        Maps an anomaly code to the deny reason text a hook emits.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$Code)

    if (-not $script:AnomalyReasonText.ContainsKey($Code)) {
        throw "Unknown discovery payload anomaly code: $Code"
    }
    return $script:AnomalyReasonText[$Code]
}

function Test-DiscoverySupportedHost {
    <#
    .SYNOPSIS
        True when HostName names a host with a native discovery adapter.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$HostName)

    return $script:SupportedHosts -contains $HostName
}

function ConvertFrom-DiscoveryHostEnvelope {
    <#
    .SYNOPSIS
        Normalizes one host event envelope into the shared discovery shape.
    .DESCRIPTION
        Returns an object with HostName, Event, SessionId, AgentId, AgentType,
        ToolName, ToolInput, Cwd and Anomaly. Anomaly is $null for a usable envelope
        or one of EmptyEnvelope, UnsupportedHost, MissingSessionId, MissingEvent and
        NonObjectToolInput (a PreToolUse event whose tool input is absent or not an
        object). Property-level absence in a well-formed tool input is not an
        anomaly; that is each hook's own scope filter.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$HostName,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Envelope
    )

    $result = [ordered]@{
        HostName = $HostName; Event = $null; SessionId = $null; AgentId = $null; AgentType = $null
        ToolName = $null; ToolInput = $null; Cwd = $null; Anomaly = $null
    }
    # Decision order: host support, envelope presence, then the trusted fields
    # a hook cannot proceed without (session, event), then tool-input shape.
    if (-not (Test-DiscoverySupportedHost -HostName $HostName)) {
        $result.Anomaly = 'UnsupportedHost'
        return [pscustomobject]$result
    }
    $isObject = ($Envelope -is [System.Collections.IDictionary]) -or ($Envelope -is [System.Management.Automation.PSCustomObject])
    if (-not $isObject) {
        $result.Anomaly = 'EmptyEnvelope'
        return [pscustomobject]$result
    }
    $keys = $script:EnvelopeKeys[$HostName]
    $result.SessionId = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.SessionId
    $result.Event = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.Event
    $result.ToolName = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.ToolName
    $result.ToolInput = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.ToolInput
    $result.Cwd = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.Cwd
    $result.AgentId = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.AgentId
    $result.AgentType = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.AgentType
    if ($result.SessionId -isnot [string] -or [string]::IsNullOrWhiteSpace($result.SessionId)) {
        $result.Anomaly = 'MissingSessionId'
    } elseif ($result.Event -isnot [string] -or [string]::IsNullOrWhiteSpace($result.Event)) {
        $result.Anomaly = 'MissingEvent'
    } elseif ($result.Event -eq 'PreToolUse') {
        $toolInputIsObject = ($result.ToolInput -is [System.Collections.IDictionary]) -or ($result.ToolInput -is [System.Management.Automation.PSCustomObject])
        if (-not $toolInputIsObject) { $result.Anomaly = 'NonObjectToolInput' }
    }
    return [pscustomobject]$result
}

function ConvertFrom-DiscoveryHostPayloadText {
    <#
    .SYNOPSIS
        Parses raw envelope JSON text and normalizes it for HostName.
    .DESCRIPTION
        Empty, whitespace-only or unparseable text yields the EmptyEnvelope anomaly
        rather than an exception, so a hook can deny with a reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$HostName,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Text
    )

    $envelope = $null
    if (-not [string]::IsNullOrWhiteSpace($Text)) {
        try {
            $envelope = ConvertFrom-Json -InputObject $Text -Depth 16 -NoEnumerate
        } catch {
            $envelope = $null
        }
    }
    return ConvertFrom-DiscoveryHostEnvelope -HostName $HostName -Envelope $envelope
}

function Get-DiscoveryAttestedValue {
    <#
    .SYNOPSIS
        Returns a non-blank attested environment value from Table, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Table,
        [Parameter(Mandatory = $true)][string]$Key
    )

    if ($Table.ContainsKey($Key) -and -not [string]::IsNullOrWhiteSpace([string]$Table[$Key])) { return [string]$Table[$Key] }
    return $null
}

function Get-DiscoveryTrustedPrincipal {
    <#
    .SYNOPSIS
        Derives the trusted principal from a normalized envelope and the attested host environment.
    .DESCRIPTION
        The native host adapter places DRM_DISCOVERY_HOST, DRM_DISCOVERY_SESSION_ID,
        DRM_DISCOVERY_PARENT_AGENT_ID, DRM_DISCOVERY_PARENT_ROLE and, for a
        discovery specialist, DRM_DISCOVERY_AGENT_ID and DRM_DISCOVERY_AGENT_ROLE in
        the environment. The principal is attributed only when the envelope carries
        no anomaly, the attested host equals the envelope host, and the attested
        session equals the envelope session. Agent identity is reported only when
        both agent values are present; a role asserted without an identity is
        ignored. Nothing in tool input can supply any of these values.
    .PARAMETER Environment
        Hashtable of environment values (tests pass it explicitly; the default reads
        the process environment for the six keys).
    .OUTPUTS
        [pscustomobject] HostName, SessionId, ParentAgentId, ParentRole, AgentId,
        Role, Attributed, Reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-DiscoveryHostEnvironmentValueTable)
    )

    $attestedHost = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.Host
    $attestedSession = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.SessionId
    $agentId = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.AgentId
    $agentRole = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.AgentRole
    $principal = [ordered]@{
        HostName      = $Normalized.HostName
        SessionId     = $Normalized.SessionId
        ParentAgentId = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.ParentAgentId
        ParentRole    = Get-DiscoveryAttestedValue -Table $Environment -Key $script:EnvironmentKeys.ParentRole
        AgentId       = $(if ($null -ne $agentId -and $null -ne $agentRole) { $agentId } else { $null })
        Role          = $(if ($null -ne $agentId -and $null -ne $agentRole) { $agentRole } else { $null })
        Attributed    = $false
        Reason        = $null
    }
    # Attribution requires an anomaly-free envelope whose host and session match
    # the attested context exactly; any gap leaves the principal unattributed.
    if ($null -ne $Normalized.Anomaly) {
        $principal.Reason = Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly
    } elseif ($null -eq $attestedHost -or $null -eq $attestedSession) {
        $principal.Reason = 'the native host did not attest a discovery host and session for this process'
    } elseif ($attestedHost -ne $Normalized.HostName) {
        $principal.Reason = "the attested host '$attestedHost' differs from the envelope host '$($Normalized.HostName)'"
    } elseif ($attestedSession -ne $Normalized.SessionId) {
        $principal.Reason = 'the attested session differs from the envelope session'
    } else {
        $principal.Attributed = $true
    }
    return [pscustomobject]$principal
}

function Get-DiscoveryHostEnvironmentValueTable {
    <#
    .SYNOPSIS
        Reads the six DRM_DISCOVERY_* process environment values into a hashtable.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $values = @{}
    # Only the documented keys are read; nothing else in the environment is trusted.
    foreach ($key in $script:EnvironmentKeys.Values) {
        $values[$key] = [System.Environment]::GetEnvironmentVariable($key)
    }
    return $values
}

Export-ModuleMember -Function `
    Test-DiscoverySupportedHost, `
    ConvertFrom-DiscoveryHostEnvelope, `
    ConvertFrom-DiscoveryHostPayloadText, `
    Get-DiscoveryTrustedPrincipal, `
    Get-DiscoveryHostEnvironmentValueTable, `
    Get-DiscoveryPayloadAnomalyReason
