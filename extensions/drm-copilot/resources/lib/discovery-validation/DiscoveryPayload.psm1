<#
.SYNOPSIS
    Host event-envelope normalization and trusted principal attribution for discovery hooks.

.DESCRIPTION
    Claude Code, Codex and the GitHub Copilot harness deliver hook events as JSON
    envelopes with host-specific key spellings. This module normalizes each
    supported envelope into one shape (host, event, session, agent, parent, tool
    name, tool input, working directory) and derives the trusted principal from
    the payload alone: the host is fixed by which hook file runs, the session is
    the envelope session, a specialist is an envelope that carries an `agent_id`
    with a discovery `agent_type`, the root is an envelope without `agent_id`,
    and the parent is the envelope parent when the host supplies one, else the
    literal `root`. Identity never comes from caller arguments, tool input or the
    process environment; when the envelope carries an anomaly the principal is
    unattributed and the calling hook fails closed.

    Malformed envelopes are typed anomalies, never silent nulls, so a hook can emit
    one deny reason per contract leg that drifted.

.NOTES
    Issue #980. Compatible with PowerShell 7+. No filesystem access, no subprocess,
    no network, no wall-clock read, no environment read.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:SupportedHosts = @('claude-code', 'codex', 'github-copilot')
$script:RootParentAgentId = 'root'
# Identifier grammar shared with the sibling modules: one leading alphanumeric,
# then alphanumerics, dot, underscore, colon or hyphen.
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
# The four discovery roles with their optional Codex complexity suffix.
$script:DiscoveryAgentTypePattern = '^(?<role>legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer)(?:-c(?:1|2|3|4|3-elevated))?$'
# Per-host envelope key spellings, most specific first. Claude Code and Codex use
# snake_case; the Copilot harness uses camelCase and may fall back to snake_case
# for fields it shares with the Claude shape. Only Copilot documents a parent
# identifier; the snake_case spelling is read on every host.
$script:EnvelopeKeys = @{
    'claude-code'    = @{ SessionId = @('session_id'); Event = @('hook_event_name'); ToolName = @('tool_name'); ToolInput = @('tool_input'); Cwd = @('cwd'); AgentId = @('agent_id'); AgentType = @('agent_type'); ToolUseId = @('tool_use_id'); ParentAgentId = @('parent_agent_id') }
    'codex'          = @{ SessionId = @('session_id'); Event = @('hook_event_name'); ToolName = @('tool_name'); ToolInput = @('tool_input'); Cwd = @('cwd'); AgentId = @('agent_id'); AgentType = @('agent_type'); ToolUseId = @('tool_use_id'); ParentAgentId = @('parent_agent_id') }
    'github-copilot' = @{ SessionId = @('sessionId', 'session_id'); Event = @('hookEventName', 'hook_event_name'); ToolName = @('toolName', 'tool_name'); ToolInput = @('toolInput', 'tool_input'); Cwd = @('cwd'); AgentId = @('agentId', 'agent_id'); AgentType = @('agentType', 'agent_type'); ToolUseId = @('toolUseId', 'tool_use_id'); ParentAgentId = @('parentAgentId', 'parent_agent_id') }
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

function Get-DiscoveryAgentRole {
    <#
    .SYNOPSIS
        Returns the discovery role named by a native agent type, or $null for any other agent.
    .DESCRIPTION
        `legacy-parity-analyst-c3` and `legacy-parity-analyst` both name the
        legacy-parity-analyst role; the comparison is case-sensitive. The agent
        type is the payload `agent_type` the host reports for the running agent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$AgentType)

    if ([string]::IsNullOrWhiteSpace($AgentType)) { return $null }
    $match = [regex]::Match($AgentType, $script:DiscoveryAgentTypePattern)
    if (-not $match.Success) { return $null }
    return $match.Groups['role'].Value
}

function ConvertFrom-DiscoveryHostEnvelope {
    <#
    .SYNOPSIS
        Normalizes one host event envelope into the shared discovery shape.
    .DESCRIPTION
        Returns an object with HostName, Event, SessionId, AgentId, AgentType,
        ParentAgentId, ToolName, ToolInput, Cwd, ToolUseId and Anomaly. Anomaly is
        $null for a usable envelope or one of EmptyEnvelope, UnsupportedHost,
        MissingSessionId, MissingEvent and NonObjectToolInput (a PreToolUse event
        whose tool input is absent or not an object). Property-level absence in a
        well-formed tool input is not an anomaly; that is each hook's own scope filter.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$HostName,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Envelope
    )

    $result = [ordered]@{
        HostName = $HostName; Event = $null; SessionId = $null; AgentId = $null; AgentType = $null; ParentAgentId = $null
        ToolName = $null; ToolInput = $null; Cwd = $null; ToolUseId = $null; Anomaly = $null
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
    $result.ParentAgentId = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.ParentAgentId
    $result.ToolUseId = Get-DiscoveryEnvelopeMember -Envelope $Envelope -Names $keys.ToolUseId
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

function Get-DiscoveryPayloadIdentifier {
    <#
    .SYNOPSIS
        Returns Value as a string when it is a non-blank string matching the identifier grammar, else $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { return $null }
    if ($Value -notmatch $script:CorrelationIdPattern) { return $null }
    return [string]$Value
}

function Get-DiscoveryTrustedPrincipal {
    <#
    .SYNOPSIS
        Derives the trusted principal from a normalized envelope alone.
    .DESCRIPTION
        The host is the adapter that received the envelope and the session is the
        envelope session. An envelope without `agent_id` is the root of its
        session (IsRoot). An envelope whose `agent_id` matches the identifier
        grammar and whose `agent_type` names a discovery role is a specialist, and
        AgentId and Role are set; every other agent leaves both null. ParentAgentId
        is the envelope parent when the host supplies a valid one, else the literal
        `root`. The principal is attributed for every anomaly-free envelope, which
        always carries a session; an anomalous envelope is unattributed with the
        anomaly reason. Nothing in tool input or the process environment supplies
        any of these values.
    .OUTPUTS
        [pscustomobject] HostName, SessionId, ParentAgentId, AgentId, Role, IsRoot,
        Attributed, Reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject]$Normalized)

    $agentId = Get-DiscoveryPayloadIdentifier -Value $Normalized.AgentId
    $role = $(if ($Normalized.AgentType -is [string]) { Get-DiscoveryAgentRole -AgentType $Normalized.AgentType } else { $null })
    $parent = Get-DiscoveryPayloadIdentifier -Value $Normalized.ParentAgentId
    $isSpecialist = ($null -ne $agentId) -and ($null -ne $role)
    $principal = [ordered]@{
        HostName      = $Normalized.HostName
        SessionId     = $Normalized.SessionId
        ParentAgentId = $(if ($null -ne $parent) { $parent } else { $script:RootParentAgentId })
        AgentId       = $(if ($isSpecialist) { $agentId } else { $null })
        Role          = $(if ($isSpecialist) { $role } else { $null })
        IsRoot        = ($null -eq $Normalized.AgentId)
        Attributed    = $false
        Reason        = $null
    }
    # Attribution requires an anomaly-free envelope; an anomaly carries its reason.
    if ($null -ne $Normalized.Anomaly) {
        $principal.Reason = Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly
    } else {
        $principal.Attributed = $true
    }
    return [pscustomobject]$principal
}

Export-ModuleMember -Function `
    Test-DiscoverySupportedHost, `
    Get-DiscoveryAgentRole, `
    ConvertFrom-DiscoveryHostEnvelope, `
    ConvertFrom-DiscoveryHostPayloadText, `
    Get-DiscoveryTrustedPrincipal, `
    Get-DiscoveryPayloadAnomalyReason
