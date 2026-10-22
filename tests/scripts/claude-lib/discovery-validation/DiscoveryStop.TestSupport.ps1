<#
.SYNOPSIS
    Shared in-memory fixtures for the native discovery SubagentStop adapter suites (issue #980).

.DESCRIPTION
    Dot-sourced after DiscoveryGate.TestSupport.ps1 and DiscoveryStart.TestSupport.ps1 by the
    DiscoveryStop module suite and by the Claude, Codex and Copilot stop-hook suites. Builds an
    in-memory workspace (domain profile, one source input, one required output), the protected
    store with the activation bound to that profile, one finalized discovery invocation, its
    gateway-written completion receipt and the tampered mirror, plus host-shaped SubagentStop
    envelopes. Every operation is a seam over a hashtable; no file, process, network or clock
    is touched.
#>

Set-StrictMode -Version Latest

$script:StopProfileBytes = [System.Text.Encoding]::UTF8.GetBytes("schema_version: 2.0.0`n")
$script:StopProfileSha256 = Get-DiscoveryBytesSha256Hex -Bytes $script:StopProfileBytes
$script:StopSourcePath = 'src/Orders/OrderService.cs'
$script:StopSourceBytes = [System.Text.Encoding]::UTF8.GetBytes('class OrderService {}')
$script:StopOutputPath = 'docs/migration/discovery/coverage-ledger.json'
$script:StopOutputBytes = [System.Text.Encoding]::UTF8.GetBytes('{"ledger":1}')
$script:StopReceiptRef = 'receipt-alpha-000000000001'
$script:StopRoleAgentTypes = @{
    'legacy-parity-analyst'            = 'legacy-parity-analyst-c3'
    'runtime-characterization-analyst' = 'runtime-characterization-analyst-c2'
    'requirements-reconciler'          = 'requirements-reconciler-c3-elevated'
    'migration-coverage-reviewer'      = 'migration-coverage-reviewer-c1'
}

function Get-StopWorkspace {
    <#
    .SYNOPSIS
        Returns the workspace byte store (relative path to bytes) with the profile, one input and one output.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        $script:GateProfilePath = $script:StopProfileBytes
        $script:StopSourcePath  = $script:StopSourceBytes
        $script:StopOutputPath  = $script:StopOutputBytes
    }
}

function Get-StopByteReader {
    <#
    .SYNOPSIS
        Returns a ReadBytes seam over a workspace byte store rooted at the fixture workspace.
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param([Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace))

    $snapshot = $Workspace
    $prefix = $script:GateWorkspaceRoot + '/'
    return {
        param([string]$Path)
        if (-not $Path.StartsWith($prefix)) { return $null }
        $relative = $Path.Substring($prefix.Length)
        if ($snapshot.ContainsKey($relative)) { return , $snapshot[$relative] }
        return $null
    }.GetNewClosure()
}

function Get-StopActivationText {
    <#
    .SYNOPSIS
        Returns the activation record text bound to the fixture profile bytes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][string]$Action = 'activate')

    return Get-GateActivationText -Action $Action -Overrides @{ profile_sha256 = $script:StopProfileSha256 }
}

function Get-StopWorkspaceBinding {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{ workspace_root = $script:GateWorkspaceRoot; workspace_sha256 = $script:GateWorkspaceSha256; profile_path = $script:GateProfilePath; profile_sha256 = $script:StopProfileSha256 }
}

function Get-StopRequiredOutputManifest {
    <#
    .SYNOPSIS
        Returns the required-output manifest of the fixture invocation for Role.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)][string]$Role = 'legacy-parity-analyst',
        [Parameter(Mandatory = $false)][AllowNull()][object[]]$Outputs = $null
    )

    if ($null -eq $Outputs) {
        $Outputs = @([ordered]@{ artifact_kind = 'coverage-ledger'; id = 'ledger-alpha'; path = $script:StopOutputPath; format = 'json'; expected_sha256 = $null })
    }
    $body = [ordered]@{
        '$schema'      = 'urn:drm-copilot:discovery:2.0.0:required-output-manifest'
        schema_version = '2.0.0'
        artifact_kind  = 'required-output-manifest'
        id             = 'manifest-alpha'
        invocation_id  = 'invocation-alpha'
        workspace      = Get-StopWorkspaceBinding
        role           = $Role
        outputs        = @($Outputs)
    }
    $body['manifest_sha256'] = Get-DiscoverySha256Hex -Text (ConvertTo-DiscoveryCanonicalJson -Value $body)
    return $body
}

function Get-StopInputManifest {
    <#
    .SYNOPSIS
        Returns the receipt input manifest over the fixture workspace (profile and one source input).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace))

    $entries = @(
        [ordered]@{ category = 'profile'; path = $script:GateProfilePath; sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:GateProfilePath]); size = $Workspace[$script:GateProfilePath].Length }
        [ordered]@{ category = 'source'; path = $script:StopSourcePath; sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:StopSourcePath]); size = $Workspace[$script:StopSourcePath].Length }
    )
    $manifest = [ordered]@{ entries = $entries; missing_paths = @(); source_repositories = @(); target_repositories = @() }
    $manifest['sha256'] = Get-DiscoveryInputManifestDigest -Manifest $manifest
    return $manifest
}

function Get-StopInvocationText {
    <#
    .SYNOPSIS
        Returns a finalized discovery-invocation record text for Role on HostName.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$Role = 'legacy-parity-analyst',
        [Parameter(Mandatory = $false)][string]$State = 'finalized',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{}
    )

    $record = [ordered]@{
        workspace              = Get-StopWorkspaceBinding
        role                   = $Role
        agent_id               = 'agent-alpha'
        state                  = $State
        start_attestation_ref  = 'start-0123456789abcdef0123'
        completion_receipt_ref = $(if ($State -eq 'finalized') { $script:StopReceiptRef } else { $null })
        required_outputs       = Get-StopRequiredOutputManifest -Role $Role
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return Get-StartInvocationText -HostName $HostName -AgentType $script:StopRoleAgentTypes[$Role] -Overrides $record
}

function Get-StopReceiptText {
    <#
    .SYNOPSIS
        Returns the gateway-written validation receipt for the fixture invocation, with overrides.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$Role = 'legacy-parity-analyst',
        [Parameter(Mandatory = $false)][string]$ValidationResult = 'pass',
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$IdentityOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$WriterOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace)
    )

    $identity = [ordered]@{ kind = 'discovery-agent'; host = $HostName; session_id = 'session-alpha'; agent_id = 'agent-alpha'; request_id = 'request-alpha'; role = $Role; invocation_id = 'invocation-alpha' }
    foreach ($key in $IdentityOverrides.Keys) { $identity[$key] = $IdentityOverrides[$key] }
    $writer = [ordered]@{ kind = 'host-gateway'; component = 'extension'; host = $HostName; id = 'gateway-alpha'; build_sha256 = ('b' * 64) }
    foreach ($key in $WriterOverrides.Keys) { $writer[$key] = $WriterOverrides[$key] }
    $findings = @()
    if ($ValidationResult -eq 'fail') {
        $findings = @([ordered]@{ code = 'COVERAGE_GAP'; severity = 'error'; artifact_path = $script:StopOutputPath; pointer = '/members/0'; related_ids = @(); related_paths = @(); message = 'A selected member has no disposition.'; next_action = 'Record the disposition.' })
    }
    $record = [ordered]@{
        '$schema'         = 'urn:drm-copilot:discovery:2.0.0:validation-receipt'
        schema_version    = '2.0.0'
        artifact_kind     = 'validation-receipt'
        id                = 'receipt-alpha'
        receipt_version   = '2.0.0'
        receipt_ref       = $script:StopReceiptRef
        workspace         = Get-StopWorkspaceBinding
        activation_sha256 = Get-DiscoverySha256Hex -Text (Get-StopActivationText)
        input_manifest    = Get-StopInputManifest -Workspace $Workspace
        runtime           = Get-StartRuntime
        mode              = 'agent-output'
        identity          = $identity
        required_outputs  = Get-StopRequiredOutputManifest -Role $Role
        output_valid      = $true
        validation_result = $ValidationResult
        findings          = $findings
        issued_at         = '2026-10-22T11:45:00Z'
        writer            = $writer
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 10)
}

function Get-StopStore {
    <#
    .SYNOPSIS
        Builds the in-memory protected store for a stop: activation, finalized invocation, receipt and tampered mirror.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$Role = 'legacy-parity-analyst',
        [Parameter(Mandatory = $false)][string]$State = 'finalized',
        [Parameter(Mandatory = $false)][string]$ValidationResult = 'pass',
        [Parameter(Mandatory = $false)][switch]$NoActivation,
        [Parameter(Mandatory = $false)][switch]$NoInvocation,
        [Parameter(Mandatory = $false)][switch]$NoReceipt,
        [Parameter(Mandatory = $false)][switch]$SecondInvocation,
        [Parameter(Mandatory = $false)][string]$ActivationAction = 'activate',
        [Parameter(Mandatory = $false)][hashtable]$InvocationOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$ReceiptOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$IdentityOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$WriterOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace)
    )

    $files = @{}
    if (-not $NoActivation) { $files[(Get-DiscoveryActivationRecordPath -Location $script:GateLocation)] = Get-StopActivationText -Action $ActivationAction }
    if (-not $NoInvocation) { $files["$($script:GateInvocationDirectory)/invocation.json"] = Get-StopInvocationText -HostName $HostName -Role $Role -State $State -Overrides $InvocationOverrides }
    if ($SecondInvocation) { $files["$($script:StartSessionDirectory)/invocations/$(Get-DiscoveryPartitionName -CorrelationId 'invocation-beta')/invocation.json"] = Get-StopInvocationText -HostName $HostName -Role $Role -State 'started' -Overrides @{ invocation_id = 'invocation-beta'; id = 'inv-beta' } }
    if (-not $NoReceipt) { $files["$($script:GateInvocationDirectory)/receipts/$($script:StopReceiptRef).json"] = Get-StopReceiptText -HostName $HostName -Role $Role -ValidationResult $ValidationResult -Overrides $ReceiptOverrides -IdentityOverrides $IdentityOverrides -WriterOverrides $WriterOverrides -Workspace $Workspace }
    # The diagnostic mirror claims a finalized invocation of another agent; the adapters must never read it.
    $files[$script:StartMirrorPath] = Get-StopInvocationText -HostName $HostName -Role 'migration-coverage-reviewer' -Overrides @{ agent_id = 'agent-forged' }
    $store = @{ Files = $files; Reads = [System.Collections.Generic.List[string]]::new(); Writes = [System.Collections.Generic.List[string]]::new() }
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
    $store['WriteText'] = { param([string]$Path, [string]$Text) $store.Files[$Path] = $Text; $store.Writes.Add($Path) }.GetNewClosure()
    $store['ReplaceText'] = { param([string]$Path, [string]$Text) $store.Files[$Path] = $Text; $store.Writes.Add($Path) }.GetNewClosure()
    return $store
}

function Get-StopEnvelope {
    <#
    .SYNOPSIS
        Builds a host-shaped SubagentStop envelope JSON for the stopping specialist.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$AgentType = 'legacy-parity-analyst-c3',
        [Parameter(Mandatory = $false)][AllowNull()][string]$AgentId = 'agent-alpha',
        [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha',
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Text = 'Inventory recorded. Result: PASS',
        [Parameter(Mandatory = $false)][bool]$StopHookActive = $false,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Cwd = $script:GateWorkspaceRoot
    )

    if ($HostName -eq 'github-copilot') {
        $envelope = [ordered]@{ sessionId = $SessionId; hookEventName = 'SubagentStop'; agentId = $AgentId; agentType = $AgentType; cwd = $Cwd; stopHookActive = $StopHookActive; lastAssistantMessage = $Text }
    } else {
        $envelope = [ordered]@{ session_id = $SessionId; hook_event_name = 'SubagentStop'; agent_id = $AgentId; agent_type = $AgentType; cwd = $Cwd; stop_hook_active = $StopHookActive; last_assistant_message = $Text }
    }
    return ($envelope | ConvertTo-Json -Compress -Depth 4)
}
