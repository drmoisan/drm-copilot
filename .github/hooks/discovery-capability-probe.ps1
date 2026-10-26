<#
.SYNOPSIS
    GitHub Copilot (VS Code local harness) capability probe for discovery agents.

.DESCRIPTION
    Not an event hook. The gateway doctor and the operator script
    scripts/dev-tools/Test-DiscoveryHostCapability.ps1 run this probe to observe
    whether this workspace's Copilot local harness provides the required discovery
    controls: the SubagentStart, PreToolUse and SubagentStop handlers registered in
    .github/hooks/discovery.json, their current hashes, and a harmless
    forbidden-operation sentinel that the PreToolUse adapter decision must deny.
    Workspace Trust and enabled hooks are host requirements the harness enforces
    before running any hook; the caller reports them through -WorkspaceTrusted.
    The result is a capability-attestation-shaped JSON document on stdout; exit 0
    when supported, 1 when unsupported.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][string]$WorkspaceRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    [Parameter(Mandatory = $false)][string]$SessionId = 'capability-probe',
    [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null,
    [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
    [Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson = $null
)

Import-Module (Join-Path $PSScriptRoot '../../.claude/lib/discovery-validation/DiscoveryCapability.psm1') -Force -Global -ErrorAction Stop
. (Join-Path $PSScriptRoot 'discovery-pre-tool.ps1')

function Get-DiscoveryProbeRuntime {
    <#
    .SYNOPSIS
        Returns the runtime identity the probe records: the caller's JSON, or the local configuration digest.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson, [Parameter(Mandatory = $true)][string]$WorkspaceRoot)

    if (-not [string]::IsNullOrWhiteSpace($RuntimeJson)) {
        $parsed = ConvertFrom-Json -InputObject $RuntimeJson -Depth 4
        $runtime = [ordered]@{}
        foreach ($key in @('build_sha256', 'package_version', 'policy_sha256', 'policy_version', 'schema_version')) {
            # The runtime identity contract types policy_version as an integer; the hosts compare it canonically.
            $runtime[$key] = $(if ($key -eq 'policy_version') { [int]$parsed.$key } else { [string]$parsed.$key })
        }
        return $runtime
    }
    $configuration = Join-Path $WorkspaceRoot '.github/hooks/discovery.json'
    $digest = $(if (Test-Path -LiteralPath $configuration -PathType Leaf) { Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($configuration)) } else { '0' * 64 })
    return [ordered]@{ build_sha256 = $digest; package_version = '2.0.0'; policy_sha256 = $digest; policy_version = 2; schema_version = '2.0.0' }
}

function Invoke-DiscoveryCapabilityProbe {
    <#
    .SYNOPSIS
        Runs the Copilot capability observation and returns the attestation-shaped document.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null,
        [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
        [Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null,
        [Parameter(Mandatory = $false)][AllowNull()][nullable[datetime]]$Now = $null
    )

    if ([string]::IsNullOrEmpty($Nonce)) { $Nonce = Get-DiscoveryAuthorizationNonce }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryDefaultStore }
    if ($null -eq $Now) { $Now = [datetime]::UtcNow }
    $sentinel = {
        param([string]$EnvelopeJson, [hashtable]$Environment)
        $decision = Invoke-DiscoveryPreToolDecision -ToolInputRaw $EnvelopeJson -EnvironmentValues $Environment
        $text = $decision | ConvertTo-Json -Compress -Depth 5
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
        $code = $(if ($reason -like '*shell, terminal, exec and evaluation tools are not available*') { 'SHELL' } else { 'OTHER' })
        return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Code = $code; Text = $text }
    }
    $parameters = @{
        HostName = 'github-copilot'; WorkspaceRoot = $WorkspaceRoot; SessionId = $SessionId; Nonce = $Nonce; WorkspaceTrusted = $WorkspaceTrusted; Now = $Now
        Runtime = (Get-DiscoveryProbeRuntime -RuntimeJson $RuntimeJson -WorkspaceRoot $WorkspaceRoot)
        SentinelDecision = $sentinel; HostEnvironment = $HostEnvironment; Store = $Store
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    $observation = Get-DiscoveryCapabilityObservation @parameters
    # The doctor, the agent preparation and the start attestation read only the protected session copy.
    [void](Write-DiscoveryCapabilityAttestation -Observation $observation -WorkspaceRoot $WorkspaceRoot -HostEnvironment $HostEnvironment -Store $Store)
    return $observation
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
$observation = Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $WorkspaceRoot -SessionId $SessionId -Nonce $Nonce -WorkspaceTrusted $WorkspaceTrusted -RuntimeJson $RuntimeJson
$observation | ConvertTo-Json -Depth 8 | Write-Output
exit $(if ($observation['status'] -eq 'supported') { 0 } else { 1 })
