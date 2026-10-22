<#
.SYNOPSIS
    Shared in-memory fixtures for the native discovery planning-gate suites (issue #980).

.DESCRIPTION
    Dot-sourced after DiscoveryGate.TestSupport.ps1 by the DiscoveryPlanning module suite and by
    the Claude, Codex and Copilot planning-gate suites. Builds an in-memory workspace (locator,
    domain profile with a configurable planning prerequisite, one source input), the protected
    store with the activation bound to those bytes and the session's root planning receipts, and
    host-shaped PreToolUse agent-launch envelopes. Every operation is a seam over a hashtable; no
    file, process, network or clock is touched.
#>

Set-StrictMode -Version Latest

$script:PlanLocatorPath = 'config/discovery.json'
$script:PlanSourcePath = 'src/Orders/OrderService.cs'
$script:PlanSourceBytes = [System.Text.Encoding]::UTF8.GetBytes('class OrderService {}')
$script:PlanReceiptRef = 'receipt-planning-00000000001'
$script:PlanSessionDirectory = Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha'

function Get-PlanLocatorByteArray {
    [CmdletBinding()]
    [OutputType([byte[]], [object[]])]
    param([Parameter(Mandatory = $false)][bool]$Enabled = $true, [Parameter(Mandatory = $false)][string]$ProfilePath = $script:GateProfilePath)

    $text = "{`n  `"enabled`": $($Enabled.ToString().ToLowerInvariant()),`n  `"profile_path`": `"$ProfilePath`",`n  `"required_runtime_major`": 2,`n  `"schema_version`": `"2.0.0`"`n}`n"
    return , [System.Text.Encoding]::UTF8.GetBytes($text)
}

function Get-PlanProfileByteArray {
    [CmdletBinding()]
    [OutputType([byte[]], [object[]])]
    param([Parameter(Mandatory = $false)][AllowNull()][string]$Prerequisite = 'discovery-complete', [Parameter(Mandatory = $false)][switch]$NoSchemaVersion)

    $lines = @("profile_version: 1")
    if (-not $NoSchemaVersion) { $lines = @('schema_version: 2.0.0') + $lines }
    $lines += 'completion_gates:'
    $lines += '  require_confirmed_scope: true'
    if (-not [string]::IsNullOrEmpty($Prerequisite)) { $lines += "  planning_prerequisite: $Prerequisite" }
    return , [System.Text.Encoding]::UTF8.GetBytes((($lines -join "`n") + "`n"))
}

function Get-PlanWorkspace {
    <#
    .SYNOPSIS
        Returns the workspace byte store (relative path to bytes) for Prerequisite.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $false)][string]$Prerequisite = 'discovery-complete')

    return @{
        $script:PlanLocatorPath = Get-PlanLocatorByteArray
        $script:GateProfilePath = Get-PlanProfileByteArray -Prerequisite $Prerequisite
        $script:PlanSourcePath  = $script:PlanSourceBytes
    }
}

function Get-PlanByteReader {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param([Parameter(Mandatory = $true)][hashtable]$Workspace)

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

function Get-PlanActivationText {
    <#
    .SYNOPSIS
        Returns the activation record bound to the workspace's locator and profile bytes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][hashtable]$Workspace, [Parameter(Mandatory = $false)][string]$Action = 'activate')

    return Get-GateActivationText -Action $Action -Overrides @{
        locator_sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:PlanLocatorPath])
        profile_sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:GateProfilePath])
    }
}

function Get-PlanReceiptText {
    <#
    .SYNOPSIS
        Returns a gateway-written native-root planning receipt over Workspace, with overrides.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Workspace,
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$Mode = 'planning',
        [Parameter(Mandatory = $false)][string]$ValidationResult = 'pass',
        [Parameter(Mandatory = $false)][object[]]$SourceRepositories = @([ordered]@{ id = 'legacy-crm'; revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }),
        [Parameter(Mandatory = $false)][object[]]$TargetRepositories = @(),
        [Parameter(Mandatory = $false)][hashtable]$Overrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$IdentityOverrides = @{},
        [Parameter(Mandatory = $false)][hashtable]$WriterOverrides = @{}
    )

    $profileSha = Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:GateProfilePath]
    $entries = @(
        [ordered]@{ category = 'profile'; path = $script:GateProfilePath; sha256 = $profileSha; size = $Workspace[$script:GateProfilePath].Length }
        [ordered]@{ category = 'source'; path = $script:PlanSourcePath; sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $Workspace[$script:PlanSourcePath]); size = $Workspace[$script:PlanSourcePath].Length }
    )
    $manifest = [ordered]@{ entries = $entries; missing_paths = @(); source_repositories = @($SourceRepositories); target_repositories = @($TargetRepositories) }
    $manifest['sha256'] = Get-DiscoveryInputManifestDigest -Manifest $manifest
    $identity = [ordered]@{ kind = 'native-root'; host = $HostName; session_id = 'session-alpha'; agent_id = 'root-alpha'; request_id = 'request-plan'; role = $null; invocation_id = $null }
    foreach ($key in $IdentityOverrides.Keys) { $identity[$key] = $IdentityOverrides[$key] }
    $writer = [ordered]@{ kind = 'host-gateway'; component = 'extension'; host = $HostName; id = 'gateway-alpha'; build_sha256 = ('b' * 64) }
    foreach ($key in $WriterOverrides.Keys) { $writer[$key] = $WriterOverrides[$key] }
    $findings = @()
    if ($ValidationResult -eq 'fail') { $findings = @([ordered]@{ code = 'DISCOVERY_INCOMPLETE'; severity = 'error'; artifact_path = $null; pointer = ''; related_ids = @(); related_paths = @(); message = 'Dispositions are incomplete.'; next_action = 'Complete the ledger.' }) }
    $record = [ordered]@{
        '$schema'         = 'urn:drm-copilot:discovery:2.0.0:validation-receipt'
        schema_version    = '2.0.0'
        artifact_kind     = 'validation-receipt'
        id                = 'receipt-planning'
        receipt_version   = '2.0.0'
        receipt_ref       = $script:PlanReceiptRef
        workspace         = [ordered]@{ workspace_root = $script:GateWorkspaceRoot; workspace_sha256 = $script:GateWorkspaceSha256; profile_path = $script:GateProfilePath; profile_sha256 = $profileSha }
        activation_sha256 = Get-DiscoverySha256Hex -Text (Get-PlanActivationText -Workspace $Workspace)
        input_manifest    = $manifest
        runtime           = Get-StartRuntime
        mode              = $Mode
        identity          = $identity
        required_outputs  = $null
        output_valid      = $null
        validation_result = $ValidationResult
        findings          = $findings
        issued_at         = '2026-10-22T11:50:00Z'
        writer            = $writer
    }
    foreach ($key in $Overrides.Keys) { $record[$key] = $Overrides[$key] }
    return ($record | ConvertTo-Json -Depth 10)
}

function Get-PlanStore {
    <#
    .SYNOPSIS
        Builds the in-memory protected store for a planning gate: activation plus the session's root receipts.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Workspace,
        [Parameter(Mandatory = $false)][switch]$NoActivation,
        [Parameter(Mandatory = $false)][switch]$NoReceipt,
        [Parameter(Mandatory = $false)][string]$ActivationAction = 'activate',
        [Parameter(Mandatory = $false)][AllowNull()][string]$ReceiptText = $null,
        [Parameter(Mandatory = $false)][hashtable]$ExtraReceipts = @{}
    )

    $files = @{}
    if (-not $NoActivation) { $files[(Get-DiscoveryActivationRecordPath -Location $script:GateLocation)] = Get-PlanActivationText -Workspace $Workspace -Action $ActivationAction }
    if (-not $NoReceipt) { $files["$($script:PlanSessionDirectory)/receipts/$($script:PlanReceiptRef).json"] = $(if (-not [string]::IsNullOrEmpty($ReceiptText)) { $ReceiptText } else { Get-PlanReceiptText -Workspace $Workspace }) }
    foreach ($name in $ExtraReceipts.Keys) { $files["$($script:PlanSessionDirectory)/receipts/$name.json"] = $ExtraReceipts[$name] }
    $store = @{ Files = $files; Reads = [System.Collections.Generic.List[string]]::new() }
    $store['ReadText'] = { param([string]$Path) $store.Reads.Add($Path); if ($store.Files.ContainsKey($Path)) { return $store.Files[$Path] } return $null }.GetNewClosure()
    $store['ListEntries'] = {
        param([string]$Directory)
        $prefix = $Directory.TrimEnd('/') + '/'
        return @($store.Files.Keys | Where-Object { $_.StartsWith($prefix) } | ForEach-Object { $_.Substring($prefix.Length).Split('/')[0] } | Sort-Object -Unique)
    }.GetNewClosure()
    $store['WriteText'] = { param([string]$Path, [string]$Text) $store.Files[$Path] = $Text }.GetNewClosure()
    $store['ReplaceText'] = { param([string]$Path, [string]$Text) $store.Files[$Path] = $Text }.GetNewClosure()
    return $store
}

function Get-PlanEnvelope {
    <#
    .SYNOPSIS
        Builds a host-shaped PreToolUse agent-launch envelope targeting SubagentType.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
        [Parameter(Mandatory = $false)][string]$ToolName = 'Agent',
        [Parameter(Mandatory = $false)][string]$SubagentType = 'atomic-planner',
        [Parameter(Mandatory = $false)][AllowNull()][string]$Cwd = $script:GateWorkspaceRoot
    )

    return Get-GateEnvelope -HostName $HostName -ToolName $ToolName -ToolInput ([ordered]@{ subagent_type = $SubagentType; prompt = 'Plan issue #980 on branch: feature/example' }) -SessionId 'session-alpha' -Event 'PreToolUse' -Cwd $Cwd
}
