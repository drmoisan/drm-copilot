<#
.SYNOPSIS
    Shared in-memory fixtures for the native discovery PreToolUse adapter suites (issue #980).

.DESCRIPTION
    Dot-sourced by the DiscoveryAuthorization module suite and by the Claude, Codex and
    Copilot hook suites. Builds an in-memory protected store (activation record,
    started invocation record) keyed to the shared cross-runtime fixtures, the
    trusted host environment, and host-shaped PreToolUse envelopes that carry the
    payload identity (agent id, agent type, parent) the gate attributes. Every
    store operation is a seam over a hashtable; no file, process, network or
    clock is touched.
#>

Set-StrictMode -Version Latest

# The sentinel helper builds its records through the gate's own modules; importing without -Force is a no-op
# in a suite that already imported them and makes them visible in a suite that imported only the probe module.
$script:GateLibrary = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/discovery-validation").Path
foreach ($gateModule in @('DiscoveryEncoding', 'DiscoveryAuthority', 'DiscoveryPayload', 'DiscoveryToolRouting', 'DiscoveryObservation')) {
    Import-Module (Join-Path $script:GateLibrary "$gateModule.psm1")
}

$script:GateWorkspaceRoot = 'C:/Users/Example/Repos/Workspace'
$script:GateWorkspaceSha256 = '77f077989d4b47c3249dcb4b1f5d5c59fa91f1045e244879660ef1ef212a19b6'
$script:GateProfilePath = 'docs/migration/discovery/domain-profile.yaml'
$script:GateProfileSha256 = '342429e9dc6d7c15c1437172be47630b3b779e7187164cc653dcaea906bc7653'
$script:GateLocatorSha256 = '5b778b46d4bcffa9a0ac7f4c7d949a5839d0417cb222d150fe056fac449cb219'
$script:GateNow = [datetime]::new(2026, 10, 22, 12, 0, 0, [System.DateTimeKind]::Utc)
$script:GateNonce = '0123456789abcdef0123'
$script:GateHostEnvironment = @{ Platform = 'windows'; UserHome = 'C:/Users/Example'; LocalAppData = 'C:/Users/Example/AppData/Local'; XdgStateHome = $null }
$script:GateLocation = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $script:GateWorkspaceRoot -Platform 'windows' -UserHome 'C:/Users/Example' -LocalAppData 'C:/Users/Example/AppData/Local'
$script:GateInvocationDirectory = Get-DiscoveryInvocationDirectory -Location $script:GateLocation -SessionId 'session-alpha' -InvocationId 'invocation-alpha'

function Get-GateActivationText {
    <#
    .SYNOPSIS
        Returns the generation-1 activate record text for the fixture workspace.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$Action = 'activate',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{}
    )

    $record = [ordered]@{
        action           = $Action
        generation       = 1
        locator_sha256   = $script:GateLocatorSha256
        previous_sha256  = $null
        profile_path     = $script:GateProfilePath
        profile_sha256   = $script:GateProfileSha256
        schema_version   = '2.0.0'
        workspace_sha256 = $script:GateWorkspaceSha256
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 4)
}

function Get-GateInvocationText {
    <#
    .SYNOPSIS
        Returns a started discovery-invocation record text bound to agent-alpha, with overrides.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{}
    )

    $record = [ordered]@{
        id                    = 'invocation-alpha-000000000001'
        invocation_id         = 'invocation-alpha'
        host                  = $HostName
        session_id            = 'session-alpha'
        parent_agent_id       = 'root'
        agent_id              = 'agent-alpha'
        role                  = 'legacy-parity-analyst'
        state                 = 'started'
        start_attestation_ref = 'attestation-alpha-00000000001'
        capability_ref        = 'capability-alpha-000000000001'
        workspace             = [ordered]@{
            workspace_root   = $script:GateWorkspaceRoot
            workspace_sha256 = $script:GateWorkspaceSha256
            profile_path     = $script:GateProfilePath
            profile_sha256   = $script:GateProfileSha256
        }
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 6)
}

function Get-GateStore {
    <#
    .SYNOPSIS
        Builds an in-memory protected store with the activation record and one started invocation.
    .OUTPUTS
        [hashtable] Files, Directories, Writes plus the ReadText/ListEntries/WriteText/EnsureDirectory seams.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][switch]$NoActivation,
        [Parameter(Mandatory = $false)][switch]$NoInvocation,
        [Parameter(Mandatory = $false)][string]$ActivationAction = 'activate',
        [Parameter(Mandatory = $false)][hashtable]$InvocationOverrides = @{}
    )

    $files = @{}
    if (-not $NoActivation) { $files[(Get-DiscoveryActivationRecordPath -Location $script:GateLocation)] = Get-GateActivationText -Action $ActivationAction }
    if (-not $NoInvocation) { $files["$($script:GateInvocationDirectory)/invocation.json"] = Get-GateInvocationText -HostName $HostName -Overrides $InvocationOverrides }
    $store = @{ Files = $files; Directories = [System.Collections.Generic.List[string]]::new(); Writes = [System.Collections.Generic.List[string]]::new() }
    $store['ReadText'] = { param([string]$Path) if ($store.Files.ContainsKey($Path)) { return $store.Files[$Path] } return $null }.GetNewClosure()
    $store['ListEntries'] = {
        param([string]$Directory)
        $prefix = $Directory.TrimEnd('/') + '/'
        $names = @($store.Files.Keys | Where-Object { $_.StartsWith($prefix) } | ForEach-Object { $_.Substring($prefix.Length).Split('/')[0] } | Sort-Object -Unique)
        return $names
    }.GetNewClosure()
    $store['WriteText'] = {
        param([string]$Path, [string]$Text)
        if ($store.Files.ContainsKey($Path)) { throw "exists: $Path" }
        $store.Files[$Path] = $Text
        $store.Writes.Add($Path)
    }.GetNewClosure()
    $store['ReplaceText'] = {
        param([string]$Path, [string]$Text)
        $store.Files[$Path] = $Text
        $store.Writes.Add($Path)
    }.GetNewClosure()
    $store['EnsureDirectory'] = { param([string]$Directory) $store.Directories.Add($Directory) }.GetNewClosure()
    return $store
}

function Get-GateEnvelope {
    <#
    .SYNOPSIS
        Builds a host-shaped PreToolUse envelope JSON for ToolName with ToolInput and the payload identity.
    .DESCRIPTION
        The defaults describe the specialist agent-alpha (legacy-parity-analyst) with
        no parent field. Pass -AgentId $null -AgentType $null for a root envelope;
        each of AgentId, AgentType and ParentAgentId is emitted only when non-null,
        using the host's key spelling.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $true)][string]$ToolName,
        [Parameter(Mandatory = $false)][AllowNull()][object]$ToolInput = @{},
        [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha',
        [Parameter(Mandatory = $false)][string]$Event = 'PreToolUse',
        [Parameter(Mandatory = $false)][AllowNull()][string]$Cwd = $script:GateWorkspaceRoot,
        [Parameter(Mandatory = $false)][AllowNull()][string]$AgentId = 'agent-alpha',
        [Parameter(Mandatory = $false)][AllowNull()][string]$AgentType = 'legacy-parity-analyst',
        [Parameter(Mandatory = $false)][AllowNull()][string]$ParentAgentId = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ToolUseId = 'tool-use-alpha'
    )

    # A [string] parameter renders $null as ''; either means the host omitted the field.
    if ($HostName -eq 'github-copilot') {
        $envelope = [ordered]@{ sessionId = $SessionId; hookEventName = $Event; toolName = $ToolName; toolInput = $ToolInput; cwd = $Cwd }
        if (-not [string]::IsNullOrEmpty($ToolUseId)) { $envelope['toolUseId'] = $ToolUseId }
        if (-not [string]::IsNullOrEmpty($AgentId)) { $envelope['agentId'] = $AgentId }
        if (-not [string]::IsNullOrEmpty($AgentType)) { $envelope['agentType'] = $AgentType }
        if (-not [string]::IsNullOrEmpty($ParentAgentId)) { $envelope['parentAgentId'] = $ParentAgentId }
    } else {
        $envelope = [ordered]@{ session_id = $SessionId; hook_event_name = $Event; tool_name = $ToolName; tool_input = $ToolInput; cwd = $Cwd }
        if (-not [string]::IsNullOrEmpty($ToolUseId)) { $envelope['tool_use_id'] = $ToolUseId }
        if (-not [string]::IsNullOrEmpty($AgentId)) { $envelope['agent_id'] = $AgentId }
        if (-not [string]::IsNullOrEmpty($AgentType)) { $envelope['agent_type'] = $AgentType }
        if (-not [string]::IsNullOrEmpty($ParentAgentId)) { $envelope['parent_agent_id'] = $ParentAgentId }
    }
    return ($envelope | ConvertTo-Json -Compress -Depth 8)
}

$script:GateRepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
# The registered PreToolUse handler of each host; the gate records the hash of its own bytes and the probe hashes the same file.
$script:GateToolHandlers = @{ 'claude-code' = '.claude/hooks/enforce-discovery-artifact-gate.ps1'; 'codex' = '.codex/hooks/enforce-discovery-artifact-gate.ps1'; 'github-copilot' = '.github/hooks/discovery-pre-tool.ps1' }
# The shared sentinel consumption fixture: the gate envelopes, the records the gate builds from them and the exact consumer latch.
$script:GateSentinelFixture = Get-Content -LiteralPath (Join-Path $script:GateRepoRoot 'tests/fixtures/discovery_host/sentinel-consumption.json') -Raw | ConvertFrom-Json -Depth 12
# The references the gate derives from the fixture tool-call identifiers; the probe suites assert these instead of hand-chosen names.
$script:GateSentinelToolRef = [string]$script:GateSentinelFixture.records.tool.observation_ref
$script:GateSentinelShellRef = [string]$script:GateSentinelFixture.records.shell.observation_ref

function Get-GateSentinelRecord {
    <#
    .SYNOPSIS
        Builds one fixture observation exactly as the gate does for HostName.
    .DESCRIPTION
        The fixture envelope is re-emitted in HostName's key spelling with the fixture
        identity fields, then normalized, attributed, routed and recorded through the
        gate's own modules with the fixture clock, nonce and TTL and the given handler hash.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][pscustomobject]$Envelope,
        [Parameter(Mandatory = $true)][string]$HandlerSha256
    )

    $fixture = $script:GateSentinelFixture
    $toolInput = [ordered]@{}
    foreach ($property in $Envelope.tool_input.PSObject.Properties) { $toolInput[$property.Name] = $property.Value }
    $json = Get-GateEnvelope -HostName $HostName -ToolName $Envelope.tool_name -ToolInput $toolInput -SessionId $Envelope.session_id -Cwd $Envelope.cwd `
        -AgentId $Envelope.agent_id -AgentType $Envelope.agent_type -ToolUseId $Envelope.tool_use_id
    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text $json
    $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
    $tool = Resolve-DiscoveryToolName -ToolName $normalized.ToolName
    # The gate allows the sentinel tool with a grant digest and denies the sentinel shell command; the fixture holds one of each.
    $isSentinelTool = ($tool.Family -eq 'mcp-discovery' -and $tool.Name -ceq 'discovery_capability_sentinel')
    $digest = $(if ($isSentinelTool) { Get-DiscoveryInputDigest -Tool 'discovery_capability_sentinel' -Operation 'sentinel' -Inputs $normalized.ToolInput } else { $null })
    return ConvertTo-DiscoveryHostObservationRecord -Normalized $normalized -Principal $principal -ToolName ([string]$normalized.ToolName) `
        -Decision $(if ($isSentinelTool) { 'allow' } else { 'deny' }) -Code $(if ($isSentinelTool) { 'SENTINEL' } else { 'SHELL' }) `
        -HandlerSha256 $HandlerSha256 -Now ([datetime]$fixture.gate_now).ToUniversalTime() -Nonce ([string]$fixture.nonce) `
        -SentinelInputSha256 $digest -TtlSeconds ([int]$fixture.ttl_seconds)
}

function Add-GateSentinelObservation {
    <#
    .SYNOPSIS
        Seeds session-alpha's sentinel observation pair from the shared consumption fixture into Store and returns the store.
    .DESCRIPTION
        The pair is what the native PreToolUse gate records while the capability sentinel
        agent runs. Both records are built from the fixture envelopes through the gate's own
        normalizer, principal, tool routing and record builder (Get-GateSentinelRecord) with
        the hash of the repository's registered tool handler for HostName, so their references
        are the ones the gate derives from the fixture tool-call identifiers
        ($script:GateSentinelToolRef and $script:GateSentinelShellRef). The consumer's effect is
        the fixture latch text placed verbatim at the tool record path plus `.consumed`; NoLatch
        omits it, and a caller that overrides observation_ref passes NoLatch. Tool overrides
        fields of the tool record after it is built; NoTool and NoShell omit a record. Records
        are placed directly in Files, so Writes is unchanged.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][hashtable]$Tool = @{},
        [Parameter(Mandatory = $false)][switch]$NoTool,
        [Parameter(Mandatory = $false)][switch]$NoShell,
        [Parameter(Mandatory = $false)][switch]$NoLatch
    )

    $fixture = $script:GateSentinelFixture
    $directory = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/observations"
    $handlerSha256 = Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:GateRepoRoot $script:GateToolHandlers[$HostName])))
    if (-not $NoTool) {
        $record = Get-GateSentinelRecord -HostName $HostName -Envelope $fixture.envelopes.tool -HandlerSha256 $handlerSha256
        foreach ($key in $Tool.Keys) { $record[$key] = $Tool[$key] }
        $path = "$directory/$($record['observation_ref']).json"
        $Store.Files[$path] = (($record | ConvertTo-Json -Depth 8) + "`n")
        if (-not $NoLatch) { $Store.Files["$path.consumed"] = [string]$fixture.latch.text }
    }
    if (-not $NoShell) {
        $record = Get-GateSentinelRecord -HostName $HostName -Envelope $fixture.envelopes.shell -HandlerSha256 $handlerSha256
        $Store.Files["$directory/$($record['observation_ref']).json"] = (($record | ConvertTo-Json -Depth 8) + "`n")
    }
    return $Store
}

function Get-GateInventoryInput {
    <#
    .SYNOPSIS
        Returns the `inventory-sorted` digest-vector inputs from the shared host fixture.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{ analyzer_ids = @('repository'); repository_id = 'legacy-crm'; draft = $false }
}

$script:GateInventoryInputSha256 = '78f78320c46cf2952bcbcef7f2e73286dfa59ab16c44fa51b3a6210b2d56375c'
