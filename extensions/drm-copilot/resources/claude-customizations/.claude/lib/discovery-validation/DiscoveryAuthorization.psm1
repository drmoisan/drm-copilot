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
    DiscoveryEncoding, DiscoveryAuthority and DiscoveryPayload modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop

$script:AuthorizationSchema = 'urn:drm-copilot:discovery:2.0.0:tool-authorization'
$script:ControlledToolOperations = [ordered]@{
    read_discovery_source             = @('read-source')
    run_discovery_repo_inventory      = @('inventory')
    run_discovery_dotnet_analyzer     = @('inventory')
    run_discovery_vsto_analyzer       = @('inventory')
    create_discovery_artifact         = @('new-contract', 'new-scenario')
    update_discovery_artifact         = @('update-artifact')
    link_discovery_evidence           = @('link-evidence')
    run_discovery_scenario_generation = @('generate-acceptance')
    run_discovery_report              = @('coverage-report', 'parity-report', 'completion-report')
    validate_discovery_artifacts      = @('profile', 'validate-profile', 'validate-feature-contract', 'validate-coverage-ledger', 'validate-runtime-scenario', 'validate-parity-matrix', 'validate-unspecified-behavior', 'validate-product-decision', 'validate-evidence-reference', 'validate-decisions', 'validate-all')
    finalize_discovery_agent          = @('finalize-agent')
}
# Schema timestamp spelling for issued_at and expires_at.
$script:TimestampFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
$script:RootOnlyOperations = @('init', 'configure', 'snapshot-export', 'snapshot-import', 'import-inventory', 'migrate', 'doctor', 'prepare-agent')
$script:RootOnlyTools = @('run_discovery_init', 'configure_discovery_workspace', 'prepare_discovery_agent', 'run_discovery_doctor', 'transfer_discovery_snapshot', 'import_discovery_inventory', 'migrate_discovery_artifacts')
$script:DiscoveryServerAliases = @('drm-copilot', 'drmCopilotExtension', 'drm_copilot')
$script:DiscoveryRoles = @('legacy-parity-analyst', 'runtime-characterization-analyst', 'requirements-reconciler', 'migration-coverage-reviewer')
$script:CallerIdentityKeys = @('agent_id', 'host', 'invocation_id', 'request_id', 'role', 'session_id')
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
$script:ValidateArtifactOperations = @{
    'profile' = 'validate-profile'; 'domain-profile' = 'validate-profile'; 'feature-contract' = 'validate-feature-contract'
    'coverage-ledger' = 'validate-coverage-ledger'; 'runtime-scenario' = 'validate-runtime-scenario'
    'runtime-characterization-scenario' = 'validate-runtime-scenario'; 'parity-matrix' = 'validate-parity-matrix'
    'unspecified-behavior' = 'validate-unspecified-behavior'; 'product-decision' = 'validate-product-decision'
    'evidence-reference' = 'validate-evidence-reference'; 'decisions' = 'validate-decisions'; 'all' = 'validate-all'
}
# Tool-name families. A shell-like token anywhere in a native tool name denies it;
# the mutation, spawn and read families are matched on the whole name.
$script:ShellToolPattern = '(?i)(^|[_.-])(bash|sh|zsh|shell|terminal|exec|execute|eval|cmd|powershell|pwsh|command)([_.-]|$)'
$script:MutationToolPattern = '(?i)^(write|edit|multiedit|notebookedit|apply_patch|create_file|edit_file|write_file|delete_file|delete|insert_edit_into_file|replace_string_in_file|create_directory|move_file|rename_file|remove_file)$'
$script:SpawnToolPattern = '(?i)^(agent|task|spawn_agent|run_subagent|runsubagent|delegate)$'
$script:ReadToolPattern = '(?i)^(read|glob|grep|ls|list_dir|list_directory|read_file|file_search|grep_search|semantic_search|get_file|todoread)$'

function Resolve-DiscoveryToolName {
    <#
    .SYNOPSIS
        Classifies a host tool name into a family and, for MCP tools, its server and tool.
    .OUTPUTS
        [pscustomobject] Family (mcp-discovery, mcp-other, shell, mutation, spawn, read, other), Server, Name.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolName)

    $name = [string]$ToolName
    $match = [regex]::Match($name, '^mcp__(?<server>[^_][^_]*?(?:_[^_]+)*?)__(?<tool>[A-Za-z0-9_.-]+)$')
    # Decision order: an MCP tool is routed by its server; a native tool by the
    # shell, mutation, spawn and read families; anything else is unknown.
    if ($match.Success) {
        $server = $match.Groups['server'].Value
        $family = $(if ($script:DiscoveryServerAliases -contains $server) { 'mcp-discovery' } else { 'mcp-other' })
        return [pscustomobject]@{ Family = $family; Server = $server; Name = $match.Groups['tool'].Value }
    }
    $family = 'other'
    if ($name -match $script:ShellToolPattern) { $family = 'shell' }
    elseif ($name -match $script:MutationToolPattern) { $family = 'mutation' }
    elseif ($name -match $script:SpawnToolPattern) { $family = 'spawn' }
    elseif ($name -match $script:ReadToolPattern) { $family = 'read' }
    return [pscustomobject]@{ Family = $family; Server = $null; Name = $name }
}

function Get-DiscoveryInputMember {
    <#
    .SYNOPSIS
        Reads one member of a tool-input object (hashtable or PSCustomObject), or $null.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)][object]$ToolInput,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($ToolInput -is [System.Collections.IDictionary]) {
        if ($ToolInput.Contains($Name)) { return $ToolInput[$Name] }
        return $null
    }
    $property = $ToolInput.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-DiscoveryToolOperation {
    <#
    .SYNOPSIS
        Derives the controlled operation a tool call performs from the tool and its input.
    .DESCRIPTION
        Single-operation tools map directly. create_discovery_artifact selects by
        artifact_kind, run_discovery_report by report_type, and
        validate_discovery_artifacts by artifact_type (validate-all when absent).
        Returns $null when the operation cannot be derived, which the caller denies.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][object]$ToolInput
    )

    if (-not $script:ControlledToolOperations.Contains($Tool)) { return $null }
    $operations = @($script:ControlledToolOperations[$Tool])
    if ($operations.Count -eq 1) { return $operations[0] }
    # Multi-operation tools select by one input field; an unknown value is refused.
    switch ($Tool) {
        'create_discovery_artifact' {
            $kind = [string](Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'artifact_kind')
            if ($kind -eq 'feature-contract') { return 'new-contract' }
            if ($kind -eq 'runtime-scenario' -or $kind -eq 'runtime-characterization-scenario') { return 'new-scenario' }
            return $null
        }
        'run_discovery_report' {
            $report = [string](Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'report_type')
            if ($report -in @('coverage', 'parity', 'completion')) { return "$report-report" }
            return $null
        }
        'validate_discovery_artifacts' {
            $type = Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'artifact_type'
            if ($null -eq $type) { return 'validate-all' }
            if ($script:ValidateArtifactOperations.ContainsKey([string]$type)) { return $script:ValidateArtifactOperations[[string]$type] }
            return $null
        }
    }
    return $null
}

function Get-DiscoveryInputDigest {
    <#
    .SYNOPSIS
        Returns sha256(canonical_json({inputs, operation, tool})) for a controlled request.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][object]$Inputs
    )

    $payload = [ordered]@{ inputs = $Inputs; operation = $Operation; tool = $Tool }
    return Get-DiscoverySha256Hex -Text (ConvertTo-DiscoveryCanonicalJson -Value $payload)
}

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
    foreach ($entry in @(& $Store.ListEntries $directory)) {
        $text = & $Store.ReadText "$directory/$entry/invocation.json"
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
        invocation_ref        = [string]$Invocation.id
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
        Returns the real-filesystem store seams (ReadText, ListEntries, WriteText, EnsureDirectory).
    .DESCRIPTION
        WriteText creates the file exclusively, so a second writer for the same
        authorization reference fails instead of replacing a record.
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
    if ($script:RootOnlyTools -contains $tool.Name) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'ROOT_ONLY' -Reason "$($tool.Name) is a root-only discovery operation and cannot be used by role $($principal.Role)"
    }
    if (-not $script:ControlledToolOperations.Contains($tool.Name)) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'UNKNOWN_TOOL' -Reason "$($tool.Name) is not a controlled discovery tool"
    }
    $inputs = $Normalized.ToolInput
    foreach ($key in $script:CallerIdentityKeys) {
        if ($null -ne (Get-DiscoveryInputMember -ToolInput $inputs -Name $key)) {
            return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'CALLER_IDENTITY' -Reason "tool input must not carry the identity field '$key'; identity comes from the native event"
        }
    }
    $operation = Get-DiscoveryToolOperation -Tool $tool.Name -ToolInput $inputs
    if ($null -eq $operation) {
        return Get-DiscoveryPreToolOutcome -Decision 'deny' -Code 'OPERATION' -Reason "the operation of $($tool.Name) could not be derived from its input"
    }
    if ($script:RootOnlyOperations -contains $operation) {
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
        & $Store.EnsureDirectory $directory
        & $Store.WriteText $path (($authorization | ConvertTo-Json -Depth 8) + "`n")
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
    Resolve-DiscoveryToolName, `
    Get-DiscoveryToolOperation, `
    Get-DiscoveryInputDigest, `
    Find-DiscoveryAgentInvocation, `
    ConvertTo-DiscoveryToolAuthorizationRecord, `
    Get-DiscoveryDefaultStore, `
    Get-DiscoveryAuthorizationNonce, `
    Get-DiscoveryPreToolDecision, `
    ConvertTo-DiscoveryPreToolHookOutput
