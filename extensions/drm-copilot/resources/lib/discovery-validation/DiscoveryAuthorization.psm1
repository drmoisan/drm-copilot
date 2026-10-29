<#
.SYNOPSIS
    Native PreToolUse authorization decisions and one-use tool-authorization records.

.DESCRIPTION
    Every native discovery PreToolUse adapter (Claude Code, Codex, GitHub Copilot)
    takes its decision from this module. For a process that the host attests as a
    discovery specialist, only the controlled discovery MCP tools and read-only
    native tools are admitted: shell, terminal, exec and evaluation tools, generic
    Write/Edit/apply_patch mutations, subagent spawning, every other MCP server,
    root-only discovery operations, unknown operations and caller-supplied identity
    fields are denied before execution. An admitted controlled request is bound to
    the agent's started invocation in the protected store and recorded as one
    short-lived, one-use `tool-authorization` whose input digest is
    `sha256(canonical_json({inputs, operation, tool}))`, exactly as the gateway
    recomputes it. A process without an attested discovery agent is left to the
    ordinary gates, so root and unrelated sessions keep their behavior.

    No value in tool input can supply identity or authority; every binding comes
    from the trusted principal and the protected activation and invocation records.
    Store access flows through injected seams; the module never invokes a process.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload and DiscoveryToolRouting modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryToolRouting.psm1') -ErrorAction Stop

$script:AuthorizationSchema = 'urn:drm-copilot:discovery:2.0.0:tool-authorization'
# Schema timestamp spelling for issued_at and expires_at.
$script:TimestampFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
$script:DiscoveryRoles = @('legacy-parity-analyst', 'runtime-characterization-analyst', 'requirements-reconciler', 'migration-coverage-reviewer')
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'

function Find-DiscoveryAgentInvocation {
    <#
    .SYNOPSIS
        Finds the single started invocation bound to the attributed agent in the protected session.
    .DESCRIPTION
        Enumerates `<session>/invocations/*/invocation.json` through the ListEntries
        and ReadText seams and returns the one record whose host, session, agent and
        role equal the principal's and whose state is `started` with a start
        attestation. Zero or several matches return $null; an unreadable record is
        skipped so a corrupt neighbour cannot admit a request.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $Principal.SessionId)/invocations"
    $bindings = [System.Collections.Generic.List[object]]::new()
    # Every partition is inspected; only an exact identity binding in the started state counts.
    foreach ($entry in @(Invoke-DiscoveryStoreSeam -Seam $Store.ListEntries -Arguments @($directory))) {
        $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @("$directory/$entry/invocation.json")
        if ($null -eq $text) { continue }
        try { $record = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { continue }
        if ($null -eq $record -or $record -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $bound = ($record.host -eq $Principal.HostName) -and ($record.session_id -eq $Principal.SessionId) -and
        ($record.agent_id -eq $Principal.AgentId) -and ($record.role -eq $Principal.Role) -and
        ($record.state -eq 'started') -and -not [string]::IsNullOrWhiteSpace([string]$record.start_attestation_ref)
        if ($bound) { $bindings.Add([pscustomobject]@{ Record = $record; Directory = "$directory/$entry" }) }
    }
    if ($bindings.Count -ne 1) { return $null }
    return $bindings[0]
}

function ConvertTo-DiscoveryToolAuthorizationRecord {
    <#
    .SYNOPSIS
        Builds one `tool-authorization` record bound to the principal, invocation and request digest.
    .DESCRIPTION
        State is always `issued`; the gateway consumes it exactly once. `issued_at`
        and `expires_at` come from the injected instant and TTL, never from the
        request. The record is state in the protected store; no file is changed here.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][pscustomobject]$Invocation,
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$InputSha256,
        [Parameter(Mandatory = $true)][string]$RequestId,
        [Parameter(Mandatory = $true)][string]$EventId,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 300
    )

    $workspace = [ordered]@{
        workspace_root   = [string]$Invocation.workspace.workspace_root
        workspace_sha256 = [string]$Invocation.workspace.workspace_sha256
        profile_path     = [string]$Invocation.workspace.profile_path
        profile_sha256   = [string]$Invocation.workspace.profile_sha256
    }
    return [ordered]@{
        '$schema'             = $script:AuthorizationSchema
        schema_version        = '2.0.0'
        artifact_kind         = 'tool-authorization'
        id                    = "authz-$Nonce"
        authorization_ref     = "authz-$Nonce"
        request_id            = $RequestId
        workspace             = $workspace
        identity              = [ordered]@{
            host          = $Principal.HostName
            session_id    = $Principal.SessionId
            agent_id      = $Principal.AgentId
            role          = $Principal.Role
            invocation_id = [string]$Invocation.invocation_id
        }
        tool                  = $Tool
        operation             = $Operation
        input_sha256          = $InputSha256
        # Names the invocation itself (as invocation_ref and the start attestation do), never the record id.
        invocation_ref        = [string]$Invocation.invocation_id
        start_attestation_ref = [string]$Invocation.start_attestation_ref
        capability_ref        = [string]$Invocation.capability_ref
        issued_at             = $Now.ToUniversalTime().ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
        expires_at            = $Now.ToUniversalTime().AddSeconds($TtlSeconds).ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
        state                 = 'issued'
        consumed_at           = $null
        writer                = [ordered]@{ kind = 'native-pretooluse'; host = $Principal.HostName; event_id = $EventId; handler_sha256 = $HandlerSha256 }
    }
}

function Get-DiscoveryDefaultStore {
    <#
    .SYNOPSIS
        Returns the real-filesystem store seams (ReadText, ListEntries, WriteText, ReplaceText, EnsureDirectory).
    .DESCRIPTION
        WriteText creates the file exclusively, so a second writer for the same
        authorization reference fails instead of replacing a record; ReplaceText is
        the explicit in-place rewrite that only the session capability attestation uses.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        ReadText        = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        }
        ListEntries     = {
            param([string]$Directory)
            if (-not (Test-Path -LiteralPath $Directory -PathType Container)) { return @() }
            return @(Get-ChildItem -LiteralPath $Directory -Force | Sort-Object -Property Name | ForEach-Object { $_.Name })
        }
        WriteText       = {
            param([string]$Path, [string]$Text)
            $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try {
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $stream.Write($bytes, 0, $bytes.Length)
            } finally { $stream.Dispose() }
        }
        ReplaceText     = {
            param([string]$Path, [string]$Text)
            [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
        }
        EnsureDirectory = { param([string]$Directory) [void](New-Item -ItemType Directory -Path $Directory -Force) }
    }
}

function Get-DiscoveryAuthorizationNonce {
    <#
    .SYNOPSIS
        Returns 20 lowercase hex characters from the platform random generator.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $bytes = [byte[]]::new(10)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return [Convert]::ToHexString($bytes).ToLowerInvariant()
}

function Get-DiscoveryPreToolOutcome {
    <#
    .SYNOPSIS
        Builds one decision object (allow or deny) with its code and reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('allow', 'deny')][string]$Decision,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Record = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$RecordPath = $null
    )

    return [pscustomobject]@{ Decision = $Decision; Code = $Code; Reason = $Reason; Record = $Record; RecordPath = $RecordPath }
}

function Get-DiscoveryPreToolDecision {
    <#
    .SYNOPSIS
        Decides one PreToolUse event for a native discovery adapter.
    .DESCRIPTION
        Order of decision: envelope anomalies deny; a process without an attested
        discovery agent (no DRM_DISCOVERY_AGENT_ID and DRM_DISCOVERY_AGENT_ROLE) is
        allowed so ordinary gates apply; an unattributed or unknown-role principal
        denies; the tool family then routes (read-only natives allow; shell,
        mutation, spawn, foreign MCP and unknown tools deny); a controlled discovery
        tool must name a known non-root operation without caller identity fields;
        the protected activation must be active, the agent must own exactly one
        started invocation bound to that activation, and only then is a one-use
        record written and the call allowed.
    .PARAMETER Store
        Seams ReadText, ListEntries, WriteText, EnsureDirectory; defaults to the real filesystem.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Record, RecordPath.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$Environment,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $false)][hashtable]$Store = (Get-DiscoveryDefaultStore),
        [Parameter(Mandatory = $false)][datetime]$Now = [datetime]::UtcNow,
        [Parameter(Mandatory = $false)][string]$Nonce = (Get-DiscoveryAuthorizationNonce),
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 300
    )

    if ($null -ne $Normalized.Anomaly) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ENVELOPE' -Reason ('payload anomaly - ' + (Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly) + '. The gate fails closed on an envelope it cannot read.')
    }
    $agentId = [string]$Environment['DRM_DISCOVERY_AGENT_ID']
    $agentRole = [string]$Environment['DRM_DISCOVERY_AGENT_ROLE']
    if ([string]::IsNullOrWhiteSpace($agentId) -and [string]::IsNullOrWhiteSpace($agentRole)) {
        return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'NOT_DISCOVERY_AGENT' -Reason 'no discovery agent is attested for this process; ordinary gates apply'
    }
    $principal = Get-DiscoveryTrustedPrincipal -Normalized $Normalized -Environment $Environment
    if (-not $principal.Attributed -or $null -eq $principal.Role) {
        $reason = $(if ($null -ne $principal.Reason) { $principal.Reason } else { 'the attested agent identity is incomplete' })
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'IDENTITY' -Reason "the discovery agent could not be attributed: $reason"
    }
    if ($script:DiscoveryRoles -notcontains $principal.Role) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ROLE' -Reason "'$($principal.Role)' is not a discovery role"
    }
    $tool = Resolve-DiscoveryToolName -ToolName $Normalized.ToolName
    # Family routing: only read-only natives and controlled discovery tools proceed.
    switch ($tool.Family) {
        'read' { return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'READ_ONLY' -Reason "read-only tool $($tool.Name) is permitted" }
        'shell' { return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'SHELL' -Reason "shell, terminal, exec and evaluation tools are not available to discovery role $($principal.Role) ($($tool.Name))" }
        'mutation' { return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'MUTATION' -Reason "generic file mutation tool $($tool.Name) is not available to discovery role $($principal.Role); draft mutations go through the controlled discovery tools" }
        'spawn' { return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'SPAWN' -Reason "discovery role $($principal.Role) cannot launch nested agents ($($tool.Name))" }
        'mcp-other' { return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'FOREIGN_MCP' -Reason "MCP server '$($tool.Server)' is outside the discovery grant" }
        'other' { return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'UNKNOWN_TOOL' -Reason "tool $($tool.Name) is outside the discovery grant" }
    }
    if ((Get-DiscoveryRootOnlyToolName) -contains $tool.Name) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ROOT_ONLY' -Reason "$($tool.Name) is a root-only discovery operation and cannot be used by role $($principal.Role)"
    }
    if ((Get-DiscoveryControlledToolName) -notcontains $tool.Name) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'UNKNOWN_TOOL' -Reason "$($tool.Name) is not a controlled discovery tool"
    }
    $inputs = $Normalized.ToolInput
    foreach ($key in (Get-DiscoveryCallerIdentityKey)) {
        if ($null -ne (Get-DiscoveryInputMember -ToolInput $inputs -Name $key)) {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'CALLER_IDENTITY' -Reason "tool input must not carry the identity field '$key'; identity comes from the native event"
        }
    }
    $operation = Get-DiscoveryToolOperation -Tool $tool.Name -ToolInput $inputs
    if ($null -eq $operation) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'OPERATION' -Reason "the operation of $($tool.Name) could not be derived from its input"
    }
    if ((Get-DiscoveryRootOnlyOperationName) -contains $operation) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ROOT_ONLY' -Reason "operation $operation requires the local-user principal"
    }
    if ([string]::IsNullOrWhiteSpace([string]$Normalized.Cwd)) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason 'the native event carries no workspace directory'
    }
    try {
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot ([string]$Normalized.Cwd) -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason $_.Exception.Message
    }
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    if ($activation.Status -ne 'active') {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ACTIVATION' -Reason "discovery is not active for this workspace ($($activation.Status): $($activation.Reason))"
    }
    $invocation = Find-DiscoveryAgentInvocation -Location $location -Principal $principal -Store $Store
    if ($null -eq $invocation) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'NO_INVOCATION' -Reason "no started protected invocation is bound to agent $($principal.AgentId) as $($principal.Role) in this session"
    }
    $record = $invocation.Record
    $sameBinding = ([string]$record.workspace.workspace_sha256 -eq $location.WorkspaceSha256) -and
    ([string]$record.workspace.profile_path -eq [string]$activation.Record.profile_path) -and
    ([string]$record.workspace.profile_sha256 -eq [string]$activation.Record.profile_sha256)
    if (-not $sameBinding) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'BINDING' -Reason 'the invocation is bound to another workspace or profile than the current activation'
    }
    $digest = Get-DiscoveryInputDigest -Tool $tool.Name -Operation $operation -Inputs $inputs
    $requestId = [string]$Normalized.ToolUseId
    if ($requestId -cnotmatch $script:CorrelationIdPattern) { $requestId = "event-$Nonce" }
    $authorization = ConvertTo-DiscoveryToolAuthorizationRecord -Principal $principal -Invocation $record -Tool $tool.Name -Operation $operation `
        -InputSha256 $digest -RequestId $requestId -EventId $requestId -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce -TtlSeconds $TtlSeconds
    $directory = "$($invocation.Directory)/authorizations"
    $path = "$directory/$($authorization['authorization_ref']).json"
    try {
        Invoke-DiscoveryStoreSeam -Seam $Store.EnsureDirectory -Arguments @($directory)
        Invoke-DiscoveryStoreSeam -Seam $Store.WriteText -Arguments @($path, (($authorization | ConvertTo-Json -Depth 8) + "`n"))
    } catch {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'STORE' -Reason "the one-use authorization could not be recorded: $($_.Exception.Message)"
    }
    return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'AUTHORIZED' -Reason "authorized $($tool.Name) $operation for $($principal.Role)" -Record $authorization -RecordPath $path
}

function ConvertTo-DiscoveryPreToolHookOutput {
    <#
    .SYNOPSIS
        Renders a decision as the PreToolUse hookSpecificOutput envelope with the hook's reason prefix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Outcome,
        [Parameter(Mandatory = $true)][string]$ReasonPrefix
    )

    if ($Outcome.Decision -eq 'allow') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }
    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "$ReasonPrefix $($Outcome.Reason)"
        }
    }
}

Export-ModuleMember -Function `
    Find-DiscoveryAgentInvocation, `
    ConvertTo-DiscoveryToolAuthorizationRecord, `
    Get-DiscoveryDefaultStore, `
    Get-DiscoveryAuthorizationNonce, `
    Get-DiscoveryPreToolDecision, `
    ConvertTo-DiscoveryPreToolHookOutput
