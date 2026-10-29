<#
.SYNOPSIS
    Native PreToolUse authorization adapter for Claude Code discovery agents.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook. The hook reads the PreToolUse
    envelope, derives the trusted principal from the envelope session and the
    DRM_DISCOVERY_* values the native host adapter placed in the environment, and
    takes its decision from the shared DiscoveryAuthorization module:

    - a process without an attested discovery agent is allowed, so root and
      ordinary sessions keep the behavior of their other gates;
    - a discovery specialist may use read-only native tools and the controlled
      discovery MCP tools only; shell, terminal, exec and evaluation tools, generic
      Write/Edit/apply_patch mutations, nested agents, foreign MCP servers,
      root-only discovery operations and caller-supplied identity fields are denied
      before execution;
    - an admitted controlled call is bound to the agent's started protected
      invocation and recorded as one short-lived, one-use tool-authorization in the
      protected store, which the gateway consumes exactly once.

    Envelope anomalies and dependency failures deny with the
    DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix. The hook performs no validation of
    artifact content itself: the installed Python runtime owns artifact semantics
    and the gateway validates proposed bytes at the service boundary (issue #980).

.NOTES
    Requires PowerShell 7+. Invokes NO external process and never reads a profile,
    locator or request field to decide identity or authority.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryToolRouting.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryToolRouting.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }

$script:DiscoveryGateReasonPrefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
$script:DiscoveryGateHandlerPath = $PSCommandPath

function Get-DiscoveryGateHandlerSha256 {
    <#
    .SYNOPSIS
        Returns the SHA-256 of this handler's own bytes for the authorization writer record.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][string]$HandlerPath = $script:DiscoveryGateHandlerPath)

    if ([string]::IsNullOrEmpty($HandlerPath) -or -not (Test-Path -LiteralPath $HandlerPath -PathType Leaf)) {
        return ('0' * 64)
    }
    return Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($HandlerPath))
}

function Invoke-DiscoveryArtifactGateDecision {
    <#
    .SYNOPSIS
        Parses the PreToolUse envelope and returns the allow-or-deny decision for a discovery agent.
    .DESCRIPTION
        Every seam defaults to the real host (process environment, platform state
        roots, protected store, clock, nonce) and is injectable so tests run over
        in-memory values. A recorded dependency failure denies before the envelope
        is read.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolInputRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$EnvironmentValues = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][nullable[datetime]]$Now = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix $script:DiscoveryGateReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    # Seams resolve only after the dependency check so a missing module denies
    # instead of raising while a default is evaluated.
    if ($null -eq $EnvironmentValues) { $EnvironmentValues = Get-DiscoveryHostEnvironmentValueTable }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryDefaultStore }
    if ($null -eq $Now) { $Now = [datetime]::UtcNow }
    if ([string]::IsNullOrEmpty($Nonce)) { $Nonce = Get-DiscoveryAuthorizationNonce }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $ToolInputRaw
    $outcome = Get-DiscoveryPreToolDecision -Normalized $normalized -Environment $EnvironmentValues -HostEnvironment $HostEnvironment `
        -HandlerSha256 (Get-DiscoveryGateHandlerSha256) -Store $Store -Now $Now -Nonce $Nonce
    return ConvertTo-DiscoveryPreToolHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryGateReasonPrefix
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_ARTIFACT_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (Read-ClaudeHookRawPayload)

$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

exit 0
