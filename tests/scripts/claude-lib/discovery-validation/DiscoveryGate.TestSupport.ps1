<#
.SYNOPSIS
    Shared in-memory fixtures for the native discovery PreToolUse adapter suites (issue #980).

.DESCRIPTION
    Dot-sourced by the DiscoveryAuthorization module suite and by the Claude, Codex and
    Copilot hook suites. Builds an in-memory protected store (activation record,
    started invocation record) keyed to the shared cross-runtime fixtures, the
    attested environment table, the trusted host environment, and host-shaped
    PreToolUse envelopes. Every store operation is a seam over a hashtable; no file,
    process, network or clock is touched.
#>

Set-StrictMode -Version Latest

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

function Get-GateEnvironment {
    <#
    .SYNOPSIS
        Returns the attested DRM_DISCOVERY_* table for host HostName, optionally without an agent.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][switch]$NoAgent
    )

    $table = @{
        DRM_DISCOVERY_HOST            = $HostName
        DRM_DISCOVERY_SESSION_ID      = 'session-alpha'
        DRM_DISCOVERY_PARENT_AGENT_ID = 'root-alpha'
        DRM_DISCOVERY_PARENT_ROLE     = $null
        DRM_DISCOVERY_AGENT_ID        = 'agent-alpha'
        DRM_DISCOVERY_AGENT_ROLE      = 'legacy-parity-analyst'
    }
    if ($NoAgent) { $table['DRM_DISCOVERY_AGENT_ID'] = $null; $table['DRM_DISCOVERY_AGENT_ROLE'] = $null }
    return $table
}

function Get-GateActivationText {
    <#
    .SYNOPSIS
        Returns the generation-1 activate record text for the fixture workspace.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][string]$Action = 'activate')

    return ([ordered]@{
            action           = $Action
            generation       = 1
            locator_sha256   = $script:GateLocatorSha256
            previous_sha256  = $null
            profile_path     = $script:GateProfilePath
            profile_sha256   = $script:GateProfileSha256
            schema_version   = '2.0.0'
            workspace_sha256 = $script:GateWorkspaceSha256
        } | ConvertTo-Json -Depth 4)
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
        parent_agent_id       = 'root-alpha'
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
    $store['EnsureDirectory'] = { param([string]$Directory) $store.Directories.Add($Directory) }.GetNewClosure()
    return $store
}

function Get-GateEnvelope {
    <#
    .SYNOPSIS
        Builds a host-shaped PreToolUse envelope JSON for ToolName with ToolInput.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $true)][string]$ToolName,
        [Parameter(Mandatory = $false)][AllowNull()][object]$ToolInput = @{},
        [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha',
        [Parameter(Mandatory = $false)][string]$Event = 'PreToolUse'
    )

    if ($HostName -eq 'github-copilot') {
        $envelope = [ordered]@{ sessionId = $SessionId; hookEventName = $Event; toolName = $ToolName; toolInput = $ToolInput; cwd = $script:GateWorkspaceRoot; toolUseId = 'tool-use-alpha' }
    } else {
        $envelope = [ordered]@{ session_id = $SessionId; hook_event_name = $Event; tool_name = $ToolName; tool_input = $ToolInput; cwd = $script:GateWorkspaceRoot; tool_use_id = 'tool-use-alpha' }
    }
    return ($envelope | ConvertTo-Json -Compress -Depth 8)
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
