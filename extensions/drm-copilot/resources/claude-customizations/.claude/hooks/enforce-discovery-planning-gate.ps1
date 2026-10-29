<#
.SYNOPSIS
    PreToolUse hook that gates planner and orchestrator delegations on current configured discovery authority.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the Agent tool. The hook reads the
    PreToolUse envelope, recognizes an atomic-planner or orchestrator launch, and
    takes its decision from the shared DiscoveryPlanning module:

    - a call that is not a planner or orchestrator launch, and a workspace without
      a protected discovery activation (or with a deliberate deactivation), are
      allowed, so the existing planning gates apply unchanged;
    - an active workspace must still hold the activated locator and domain profile,
      and the protected session must hold a current, passing, gateway-written
      planning-mode receipt for this host and session whose inputs are unchanged
      and whose manifest reflects the profile's planning prerequisite; a
      structural, agent-output, completion-mode or version-1 receipt, a failing or
      stale receipt, and a missing, disabled or malformed locator or profile deny
      with the DISCOVERY_PLANNING_GATE_BLOCKED: prefix before the delegation runs.

    The hook only verifies authority: it never runs Python or starts validation
    (issue #980). Envelope anomalies and dependency failures deny with the prefix.

.NOTES
    Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryManifest.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryToolRouting.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryToolRouting.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPlanning.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPlanning.psm1' -ErrorRecord $_ }

$script:DiscoveryPlanningReasonPrefix = 'DISCOVERY_PLANNING_GATE_BLOCKED:'

function Invoke-DiscoveryPlanningGateDecision {
    <#
    .SYNOPSIS
        Parses the PreToolUse envelope and returns the allow-or-deny decision for a planning delegation.
    .DESCRIPTION
        Every seam defaults to the real host (platform state roots, protected store,
        workspace bytes) and is injectable so tests run over in-memory values. A
        recorded dependency failure denies before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolInputRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix $script:DiscoveryPlanningReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    # Seams resolve only after the dependency check so a missing module denies
    # instead of raising while a default is evaluated.
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $ToolInputRaw
    $parameters = @{ Normalized = $normalized; HostEnvironment = $HostEnvironment; Store = $Store }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    $outcome = Get-DiscoveryPlanningDecision @parameters
    return ConvertTo-DiscoveryPlanningHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryPlanningReasonPrefix
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_PLANNING_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DISCOVERY_PLANNING_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$decision = Invoke-DiscoveryPlanningGateDecision -ToolInputRaw (Read-ClaudeHookRawPayload)

$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

exit 0
