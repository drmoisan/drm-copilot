<#
.SYNOPSIS
    Codex capability probe for discovery agents: observes registration, handler hashes and the recorded sentinel observations.

.DESCRIPTION
    Not an event hook. The gateway doctor and the operator script
    scripts/dev-tools/Test-DiscoveryHostCapability.ps1 run this probe to observe
    whether this workspace's Codex host provides the required discovery controls:
    the SubagentStart, PreToolUse and SubagentStop handlers registered in
    .codex/config.toml for the four discovery agents and the controlled tools, their
    current hashes, and the host observations the PreToolUse gate recorded while the
    discovery-capability-sentinel agent ran in session SessionId. The result is a
    capability-attestation-shaped JSON document on stdout; exit 0 when supported, 1
    when unsupported. A session without observations, or whose sentinel observation
    carries no agent_id, is unsupported.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process and makes no
    in-process sentinel decision.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][string]$WorkspaceRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    [Parameter(Mandatory = $false)][string]$SessionId = 'capability-probe',
    [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null,
    [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
    [Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson = $null
)

. (Join-Path $PSScriptRoot 'enforce-discovery-artifact-gate.ps1')
Import-Module (Get-DiscoveryHelperModulePath -ModuleName 'DiscoveryCapability.psm1') -Force -Global -ErrorAction Stop

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
    $configuration = Join-Path $WorkspaceRoot '.codex/config.toml'
    $digest = $(if (Test-Path -LiteralPath $configuration -PathType Leaf) { Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($configuration)) } else { '0' * 64 })
    return [ordered]@{ build_sha256 = $digest; package_version = '2.0.0'; policy_sha256 = $digest; policy_version = 2; schema_version = '2.0.0' }
}

function Invoke-DiscoveryCapabilityProbe {
    <#
    .SYNOPSIS
        Runs the Codex capability observation and returns the attestation-shaped document.
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
    $parameters = @{
        HostName = 'codex'; WorkspaceRoot = $WorkspaceRoot; SessionId = $SessionId; Nonce = $Nonce; WorkspaceTrusted = $WorkspaceTrusted; Now = $Now
        Runtime = (Get-DiscoveryProbeRuntime -RuntimeJson $RuntimeJson -WorkspaceRoot $WorkspaceRoot)
        HostEnvironment = $HostEnvironment; Store = $Store
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
