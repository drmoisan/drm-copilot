<#
.SYNOPSIS
    Native PreToolUse authorization decisions and one-use tool-authorization records.

.DESCRIPTION
    Every native discovery PreToolUse adapter (Claude Code, Codex, GitHub Copilot)
    takes its decision from this module. The caller's identity comes from the hook
    payload alone: an envelope without `agent_id` is the root of its session, and
    an envelope whose `agent_id` carries a discovery `agent_type` is a specialist.

    A root call of `prepare_discovery_agent`, `run_discovery_doctor` or a
    controlled discovery tool is allowed with a one-use `root-grant` that the MCP
    server consumes by tool, operation and input digest (the prepare and
    controlled grants require a current supported capability attestation); every
    other root tool is allowed so the ordinary gates apply. A sentinel envelope is
    observed and never granted. For a specialist, only the controlled discovery MCP
    tools and read-only native tools are admitted: shell, terminal, exec and
    evaluation tools, generic Write/Edit/apply_patch mutations, subagent spawning,
    every other MCP server, root-only discovery operations, unknown operations and
    caller-supplied identity fields are denied before execution. The specialist's
    first controlled call starts the single prepared invocation of its session,
    parent and agent type; every controlled call must name that invocation through
    `invocation_ref`, and the admitted request is recorded as one short-lived,
    one-use `tool-authorization` whose input digest is
    `sha256(canonical_json({inputs, operation, tool}))`, exactly as the gateway
    recomputes it.

    No value in tool input can supply identity or authority; every binding comes
    from the payload principal and the protected activation and invocation records.
    Store access flows through injected seams; the module never invokes a process.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload, DiscoveryToolRouting,
    DiscoveryRootGrant, DiscoveryObservation, DiscoveryStartRecord and DiscoveryStart modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryToolRouting.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryRootGrant.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryObservation.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStartRecord.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStart.psm1') -ErrorAction Stop

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

function Resolve-DiscoveryGateLocation {
    <#
    .SYNOPSIS
        Resolves the protected-store location of the event's workspace, or returns the WORKSPACE deny outcome.
    .OUTPUTS
        [pscustomobject] Location (or $null) and Outcome (the deny, or $null).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment
    )

    if ([string]::IsNullOrWhiteSpace([string]$Normalized.Cwd)) {
        return [pscustomobject]@{ Location = $null; Outcome = (Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason 'the native event carries no workspace directory') }
    }
    try {
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot ([string]$Normalized.Cwd) -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return [pscustomobject]@{ Location = $null; Outcome = (Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason $_.Exception.Message) }
    }
    return [pscustomobject]@{ Location = $location; Outcome = $null }
}

function Get-DiscoveryRootDecision {
    <#
    .SYNOPSIS
        Decides a root call: a one-use root grant for prepare, doctor and the controlled tools; every other tool is allowed.
    .DESCRIPTION
        A root grant for prepare and for a controlled tool requires a current
        supported capability attestation of the session; the doctor grant does not,
        because the probe produces that attestation. A root call must not carry
        `invocation_ref` or an identity field; the server takes host, session and
        parent from the consumed grant.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][pscustomobject]$Tool,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $true)][int]$TtlSeconds
    )

    $grantable = @('prepare_discovery_agent', 'run_discovery_doctor') + @(Get-DiscoveryControlledToolName)
    if ($Tool.Family -ne 'mcp-discovery' -or $grantable -cnotcontains $Tool.Name) {
        return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'ROOT' -Reason "root call of $($Tool.Name); ordinary gates apply"
    }
    $inputs = $Normalized.ToolInput
    if ($null -ne (Get-DiscoveryInputMember -ToolInput $inputs -Name 'invocation_ref')) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'INVOCATION_REF' -Reason 'a root call must not carry invocation_ref; only a started specialist names its invocation'
    }
    foreach ($key in (Get-DiscoveryCallerIdentityKey)) {
        if ($null -ne (Get-DiscoveryInputMember -ToolInput $inputs -Name $key)) {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'CALLER_IDENTITY' -Reason "tool input must not carry the identity field '$key'; identity comes from the native event"
        }
    }
    # The operation of prepare and doctor is fixed; a controlled tool derives it from its input.
    switch ($Tool.Name) {
        'prepare_discovery_agent' { $operation = 'prepare-agent' }
        'run_discovery_doctor' { $operation = 'doctor' }
        default { $operation = Get-DiscoveryToolOperation -Tool $Tool.Name -ToolInput $inputs }
    }
    if ($null -eq $operation) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'OPERATION' -Reason "the operation of $($Tool.Name) could not be derived from its input"
    }
    $resolved = Resolve-DiscoveryGateLocation -Normalized $Normalized -HostEnvironment $HostEnvironment
    if ($null -ne $resolved.Outcome) { return $resolved.Outcome }
    if ($Tool.Name -ne 'run_discovery_doctor') {
        $deficiency = Test-DiscoveryRootGrantPrecondition -Location $resolved.Location -Principal $Principal -Store $Store -Now $Now
        if ($null -ne $deficiency) {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'CAPABILITY' -Reason "no root grant for $($Tool.Name): $deficiency"
        }
    }
    $digest = Get-DiscoveryInputDigest -Tool $Tool.Name -Operation $operation -Inputs $inputs
    $grant = ConvertTo-DiscoveryRootGrantRecord -Principal $Principal -Tool $Tool.Name -Operation $operation -InputSha256 $digest `
        -ToolUseId ([string]$Normalized.ToolUseId) -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce -TtlSeconds $TtlSeconds
    try {
        $path = Write-DiscoveryRootGrant -Location $resolved.Location -Record $grant -Store $Store
    } catch {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'STORE' -Reason "the root grant could not be recorded: $($_.Exception.Message)"
    }
    return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'ROOT_GRANTED' -Reason "granted root call of $($Tool.Name) $operation once" -Record $grant -RecordPath $path
}

function Get-DiscoveryPreToolDecision {
    <#
    .SYNOPSIS
        Decides one PreToolUse event for a native discovery adapter.
    .DESCRIPTION
        Order of decision: envelope anomalies deny; a sentinel envelope is observed
        through the sentinel decision; a root envelope (no agent_id) is allowed, with
        a one-use root grant for prepare, doctor and the controlled tools; an agent
        that is not a discovery specialist is allowed so ordinary gates apply, unless
        it declares a discovery agent type without a usable agent identifier; for a
        specialist the tool family routes (read-only natives allow; shell, mutation,
        spawn, foreign MCP and unknown tools deny), a controlled discovery tool must
        name a known non-root operation without caller identity fields, the
        protected activation must be active, the agent's started invocation is
        resolved (its first controlled call starts the single prepared invocation of
        its session, parent and agent type), `invocation_ref` must name that
        invocation, and only then is a one-use record written and the call allowed.
    .PARAMETER Store
        Seams ReadText, ListEntries, WriteText, ReplaceText, EnsureDirectory and the
        optional ReadBytes or ReadAgentProfile profile seams; defaults to the real filesystem.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Record, RecordPath.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
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
    $principal = Get-DiscoveryTrustedPrincipal -Normalized $Normalized
    $tool = Resolve-DiscoveryToolName -ToolName $Normalized.ToolName
    # Sentinel envelopes are observed before any grant path; root calls take the grant path.
    if (Test-DiscoverySentinelEnvelope -Normalized $Normalized -Tool $tool) {
        $resolved = Resolve-DiscoveryGateLocation -Normalized $Normalized -HostEnvironment $HostEnvironment
        if ($null -ne $resolved.Outcome) { return $resolved.Outcome }
        return Get-DiscoverySentinelDecision -Normalized $Normalized -Principal $principal -Tool $tool -Location $resolved.Location -Store $Store `
            -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce -TtlSeconds $TtlSeconds
    }
    if ($principal.IsRoot) {
        return Get-DiscoveryRootDecision -Normalized $Normalized -Principal $principal -Tool $tool -HostEnvironment $HostEnvironment `
            -HandlerSha256 $HandlerSha256 -Store $Store -Now $Now -Nonce $Nonce -TtlSeconds $TtlSeconds
    }
    if ($null -eq $principal.Role) {
        # A discovery agent type without a usable agent identifier cannot be bound and fails closed.
        $declared = $(if ($Normalized.AgentType -is [string]) { Get-DiscoveryAgentRole -AgentType $Normalized.AgentType } else { $null })
        if ($null -ne $declared) {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'IDENTITY' -Reason "the discovery agent could not be attributed: the payload agent identifier is not a usable identifier for $declared"
        }
        return Get-DiscoveryPreToolOutcome -Decision 'allow' -Code 'NOT_DISCOVERY_AGENT' -Reason 'the calling agent is not a discovery specialist; ordinary gates apply'
    }
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
    $resolved = Resolve-DiscoveryGateLocation -Normalized $Normalized -HostEnvironment $HostEnvironment
    if ($null -ne $resolved.Outcome) { return $resolved.Outcome }
    $location = $resolved.Location
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    if ($activation.Status -ne 'active') {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ACTIVATION' -Reason "discovery is not active for this workspace ($($activation.Status): $($activation.Reason))"
    }
    $invocation = Find-DiscoveryAgentInvocation -Location $location -Principal $principal -Store $Store
    if ($null -eq $invocation) {
        # First controlled call: bind the agent to the single prepared invocation and start it.
        $started = Start-DiscoveryPreparedInvocation -Location $location -Principal $principal -AgentId $principal.AgentId -AgentType ([string]$Normalized.AgentType) `
            -Activation $activation.Record -WorkspaceRoot ([string]$Normalized.Cwd) -Store $Store -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce
        if ($started.Decision -ne 'attest') {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code $started.Code -Reason $started.Reason
        }
        $invocation = [pscustomobject]@{ Record = $started.Invocation; Directory = $started.Directory }
    }
    $record = $invocation.Record
    $invocationRef = Get-DiscoveryInputMember -ToolInput $inputs -Name 'invocation_ref'
    if ($invocationRef -isnot [string] -or $invocationRef -cne [string]$record.invocation_id) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'INVOCATION_REF' -Reason "tool input must carry invocation_ref $($record.invocation_id), the started invocation of agent $($principal.AgentId)"
    }
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
