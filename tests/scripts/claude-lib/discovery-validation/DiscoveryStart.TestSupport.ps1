<#
.SYNOPSIS
    Shared in-memory fixtures for the native discovery SubagentStart adapter suites (issue #980).

.DESCRIPTION
    Dot-sourced after DiscoveryGate.TestSupport.ps1 by the DiscoveryStart module suite and by
    the Claude, Codex and Copilot start-hook suites. Builds an in-memory protected store with
    the activation record, one prepared discovery invocation, the session capability
    attestation and a tampered diagnostic mirror inside the workspace; host-shaped
    SubagentStart envelopes; agent-profile readings and Markdown profile bytes. Every store
    operation is a seam over a hashtable and records what it read, wrote or replaced; no
    file, process, network or clock is touched.
#>

Set-StrictMode -Version Latest

$script:StartAgentType = 'legacy-parity-analyst-c3'
$script:StartRole = 'legacy-parity-analyst'
$script:StartModel = 'gpt-6.1-sol'
$script:StartEffort = 'high'
$script:StartCapabilityRef = 'capability-alpha-000000000001'
$script:StartProfileSha256 = ('a' * 64)
$script:StartMirrorPath = "$($script:GateWorkspaceRoot)/docs/migration/discovery/invocations/invocation-alpha.json"
$script:StartSessionDirectory = Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha'

function Get-StartRuntime {
    <#
    .SYNOPSIS
        Returns the pinned runtime identity shared by the invocation and the capability attestation.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][hashtable]$Overrides = @{})

    $runtime = [ordered]@{
        package_version = '2.0.0'
        schema_version  = '2.0.0'
        build_sha256    = ('b' * 64)
        policy_version  = '2.0.0'
        policy_sha256   = ('c' * 64)
    }
    foreach ($key in $Overrides.Keys) { $runtime[$key] = $Overrides[$key] }
    return $runtime
}

function Get-StartInvocationText {
    <#
    .SYNOPSIS
        Returns a prepared discovery-invocation record text for AgentType under parent root-alpha.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = $script:StartAgentType,
        [Parameter(Mandatory = $false)][string]$InvocationId = 'invocation-alpha',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$DeploymentOverrides = @{}
    )

    $deployment = [ordered]@{
        provider          = $HostName
        agent_name        = $AgentType
        model             = $script:StartModel
        reasoning_effort  = $script:StartEffort
        profile_path      = $script:GateProfilePath
        profile_sha256    = $script:GateProfileSha256
        complexity        = 'C3'
        execution_context = 'standalone'
    }
    foreach ($key in $DeploymentOverrides.Keys) { $deployment[$key] = $DeploymentOverrides[$key] }
    $record = [ordered]@{
        '$schema'              = 'urn:drm-copilot:discovery:2.0.0:discovery-invocation'
        schema_version         = '2.0.0'
        artifact_kind          = 'discovery-invocation'
        id                     = "inv-$($InvocationId -replace '^invocation-', '')"
        invocation_id          = $InvocationId
        workspace              = [ordered]@{
            workspace_root   = $script:GateWorkspaceRoot
            workspace_sha256 = $script:GateWorkspaceSha256
            profile_path     = $script:GateProfilePath
            profile_sha256   = $script:GateProfileSha256
        }
        host                   = $HostName
        session_id             = 'session-alpha'
        parent_agent_id        = 'root-alpha'
        agent_id               = $null
        role                   = $script:StartRole
        skill_id               = 'inventory-legacy-system'
        operation              = 'inventory'
        gate_mode              = 'draft'
        selected_ids           = @('legacy-crm')
        selected_paths         = @('src')
        scope_sha256           = ('d' * 64)
        input_sha256           = ('e' * 64)
        runtime                = Get-StartRuntime
        deployment             = $deployment
        required_outputs       = [ordered]@{ outputs = @() }
        capability_ref         = $script:StartCapabilityRef
        topology_receipt_ref   = 'topology-alpha-000000000001'
        model_receipt_ref      = 'model-alpha-000000000001'
        production_write_count = 0
        state                  = 'prepared'
        created_at             = '2026-10-22T11:00:00Z'
        start_attestation_ref  = $null
        completion_receipt_ref = $null
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 8)
}

function Get-StartCapabilityText {
    <#
    .SYNOPSIS
        Returns the session's supported capability attestation text, with overrides.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$RuntimeOverrides = @{}
    )

    $record = [ordered]@{
        '$schema'            = 'urn:drm-copilot:discovery:2.0.0:capability-attestation'
        schema_version       = '2.0.0'
        artifact_kind        = 'capability-attestation'
        id                   = 'capability-alpha'
        attestation_ref      = $script:StartCapabilityRef
        workspace            = [ordered]@{
            workspace_root   = $script:GateWorkspaceRoot
            workspace_sha256 = $script:GateWorkspaceSha256
            profile_path     = $script:GateProfilePath
            profile_sha256   = $script:GateProfileSha256
        }
        host                 = $HostName
        session_id           = 'session-alpha'
        runtime              = Get-StartRuntime -Overrides $RuntimeOverrides
        configuration_sha256 = ('f' * 64)
        handlers             = @()
        controls             = [ordered]@{}
        probe                = [ordered]@{ sentinel_id = 'probe-alpha'; result = 'denied'; evidence_ref = 'evidence-alpha' }
        status               = 'supported'
        findings             = @()
        observed_at          = '2026-10-22T11:30:00Z'
        expires_at           = '2026-10-22T13:00:00Z'
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 8)
}

function Get-StartProfile {
    <#
    .SYNOPSIS
        Returns the shared agent-profile reading for AgentType on HostName.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = $script:StartAgentType,
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{}
    )

    $reading = [ordered]@{
        ProfilePath            = Get-DiscoveryAgentProfilePath -HostName $HostName -AgentType $AgentType
        ProfileSha256          = $script:StartProfileSha256
        ProfileName            = $AgentType
        ProfileModel           = $script:StartModel
        ProfileReasoningEffort = $script:StartEffort
    }
    foreach ($key in $Overrides.Keys) { $reading[$key] = $Overrides[$key] }
    return [pscustomobject]$reading
}

function Get-StartProfileMarkdown {
    <#
    .SYNOPSIS
        Returns Markdown agent-profile text whose front matter declares Name.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][string]$Name = $script:StartAgentType)

    return "---`nname: $Name`ndescription: Fixture profile.`ntools:`n  - `"mcp__drm-copilot__read_discovery_source`"`nmemory: project`n---`n`n# Fixture`n"
}

function Get-StartProfileReader {
    <#
    .SYNOPSIS
        Returns a ReadBytes seam serving one Markdown profile at the host's profile path.
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = $script:StartAgentType,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Text = (Get-StartProfileMarkdown -Name $script:StartAgentType)
    )

    $expected = "$($script:GateWorkspaceRoot)/$(Get-DiscoveryAgentProfilePath -HostName $HostName -AgentType $AgentType)"
    $bytes = $(if ($null -eq $Text) { $null } else { [System.Text.Encoding]::UTF8.GetBytes($Text) })
    return { param([string]$Path) if ($Path -eq $expected) { return $bytes } return $null }.GetNewClosure()
}

function Get-StartStore {
    <#
    .SYNOPSIS
        Builds an in-memory protected store for a start: activation, prepared invocation, capability and a tampered mirror.
    .OUTPUTS
        [hashtable] Files, Reads, Writes, Replacements plus ReadText/ListEntries/WriteText/ReplaceText seams.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = $script:StartAgentType,
        [Parameter(Mandatory = $false)][switch]$NoActivation,
        [Parameter(Mandatory = $false)][switch]$NoInvocation,
        [Parameter(Mandatory = $false)][switch]$NoCapability,
        [Parameter(Mandatory = $false)][switch]$SecondInvocation,
        [Parameter(Mandatory = $false)][string]$ActivationAction = 'activate',
        [Parameter(Mandatory = $false)][hashtable]$InvocationOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$DeploymentOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$CapabilityOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$RuntimeOverrides = @{}
    )

    $files = @{}
    if (-not $NoActivation) { $files[(Get-DiscoveryActivationRecordPath -Location $script:GateLocation)] = Get-GateActivationText -Action $ActivationAction }
    if (-not $NoInvocation) { $files["$($script:GateInvocationDirectory)/invocation.json"] = Get-StartInvocationText -HostName $HostName -AgentType $AgentType -Overrides $InvocationOverrides -DeploymentOverrides $DeploymentOverrides }
    if ($SecondInvocation) { $files["$($script:StartSessionDirectory)/invocations/$(Get-DiscoveryPartitionName -CorrelationId 'invocation-beta')/invocation.json"] = Get-StartInvocationText -HostName $HostName -AgentType $AgentType -InvocationId 'invocation-beta' }
    if (-not $NoCapability) { $files["$($script:StartSessionDirectory)/capability-attestation.json"] = Get-StartCapabilityText -HostName $HostName -Overrides $CapabilityOverrides -RuntimeOverrides $RuntimeOverrides }
    # The diagnostic mirror names another agent and model; the adapters must never read it.
    $files[$script:StartMirrorPath] = Get-StartInvocationText -HostName $HostName -AgentType 'migration-coverage-reviewer-c1' -DeploymentOverrides @{ model = 'tampered-model' }
    $store = @{
        Files        = $files
        Reads        = [System.Collections.Generic.List[string]]::new()
        Writes       = [System.Collections.Generic.List[string]]::new()
        Replacements = [System.Collections.Generic.List[string]]::new()
    }
    $store['ReadText'] = {
        param([string]$Path)
        $store.Reads.Add($Path)
        if ($store.Files.ContainsKey($Path)) { return $store.Files[$Path] }
        return $null
    }.GetNewClosure()
    $store['ListEntries'] = {
        param([string]$Directory)
        $prefix = $Directory.TrimEnd('/') + '/'
        return @($store.Files.Keys | Where-Object { $_.StartsWith($prefix) } | ForEach-Object { $_.Substring($prefix.Length).Split('/')[0] } | Sort-Object -Unique)
    }.GetNewClosure()
    $store['WriteText'] = {
        param([string]$Path, [string]$Text)
        if ($store.Files.ContainsKey($Path)) { throw "exists: $Path" }
        $store.Files[$Path] = $Text
        $store.Writes.Add($Path)
    }.GetNewClosure()
    $store['ReplaceText'] = {
        param([string]$Path, [string]$Text)
        if (-not $store.Files.ContainsKey($Path)) { throw "missing: $Path" }
        $store.Files[$Path] = $Text
        $store.Replacements.Add($Path)
    }.GetNewClosure()
    return $store
}

function Get-StartEnvelope {
    <#
    .SYNOPSIS
        Builds a host-shaped SubagentStart envelope JSON for AgentType.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = $script:StartAgentType,
        [Parameter(Mandatory = $false)][AllowNull()][string]$AgentId = 'agent-alpha',
        [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha',
        [Parameter(Mandatory = $false)][AllowNull()][string]$Cwd = $script:GateWorkspaceRoot
    )

    if ($HostName -eq 'github-copilot') {
        $envelope = [ordered]@{ sessionId = $SessionId; hookEventName = 'SubagentStart'; agentId = $AgentId; agentType = $AgentType; cwd = $Cwd }
    } else {
        $envelope = [ordered]@{ session_id = $SessionId; hook_event_name = 'SubagentStart'; agent_id = $AgentId; agent_type = $AgentType; cwd = $Cwd; transcript_path = 'transcripts/agent-alpha.jsonl' }
    }
    return ($envelope | ConvertTo-Json -Compress -Depth 4)
}

function Get-StartEnvironment {
    <#
    .SYNOPSIS
        Returns the attested parent-launch environment (host, session, parent; no agent) for HostName.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][switch]$Nested,
        [Parameter(Mandatory = $false)][switch]$NoParent
    )

    $table = Get-GateEnvironment -HostName $HostName -NoAgent
    if ($Nested) { $table['DRM_DISCOVERY_AGENT_ID'] = 'agent-outer'; $table['DRM_DISCOVERY_AGENT_ROLE'] = 'legacy-parity-analyst' }
    if ($NoParent) { $table['DRM_DISCOVERY_PARENT_AGENT_ID'] = $null }
    return $table
}
