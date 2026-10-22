<#
.SYNOPSIS
    GitHub Copilot (VS Code local harness) PreToolUse hook that gates planner and orchestrator launches on discovery authority.

.DESCRIPTION
    Registered through .github/hooks/*.json. The hook reads the Copilot PreToolUse
    envelope from stdin (camelCase keys, snake_case accepted), recognizes an
    atomic-planner or orchestrator launch, and takes its decision from the shared
    DiscoveryPlanning module under .claude/lib/discovery-validation:

    - a call that is not a planner or orchestrator launch, and a workspace without
      a protected discovery activation, are allowed so existing behavior continues;
    - an active workspace must still hold the activated locator and domain profile
      and the protected session must hold a current, passing, gateway-written
      planning-mode receipt for this host and session; otherwise the launch is
      denied with the DISCOVERY_PLANNING_GATE_BLOCKED: prefix.

    A helper that fails to load and an envelope that cannot be read both deny with
    the prefix; the hook never fails open and never runs Python.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()

$script:DiscoveryPlanningReasonPrefix = 'DISCOVERY_PLANNING_GATE_BLOCKED:'
$script:DiscoveryPlanningDependencyFailures = [System.Collections.Generic.List[object]]::new()

function Add-DiscoveryPlanningDependencyFailure {
    <#
    .SYNOPSIS
        Records one helper module that failed to load.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $false)][AllowNull()][System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $message = 'no error record'
    if ($null -ne $ErrorRecord) { $message = ([string]$ErrorRecord.Exception.Message -split "`r?`n")[0] }
    [void]$script:DiscoveryPlanningDependencyFailures.Add([pscustomobject]@{ Name = $Name; Message = $message })
}

foreach ($moduleName in @('DiscoveryEncoding.psm1', 'DiscoveryAuthority.psm1', 'DiscoveryManifest.psm1', 'DiscoveryPayload.psm1', 'DiscoveryAuthorization.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryPlanning.psm1')) {
    try { Import-Module (Join-Path $PSScriptRoot "../../.claude/lib/discovery-validation/$moduleName") -Force -Global -ErrorAction Stop } catch { Add-DiscoveryPlanningDependencyFailure -Name $moduleName -ErrorRecord $_ }
}

function Invoke-DiscoveryPlanningDecision {
    <#
    .SYNOPSIS
        Parses the Copilot PreToolUse envelope and returns the hookSpecificOutput decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolInputRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($script:DiscoveryPlanningDependencyFailures.Count -gt 0) {
        $first = $script:DiscoveryPlanningDependencyFailures[0]
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "$($script:DiscoveryPlanningReasonPrefix) the dependency '$($first.Name)' failed to load ($($first.Message)); the gate fails closed."
            }
        }
    }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $ToolInputRaw
    $parameters = @{ Normalized = $normalized; HostEnvironment = $HostEnvironment; Store = $Store }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    $outcome = Get-DiscoveryPlanningDecision @parameters
    return ConvertTo-DiscoveryPlanningHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryPlanningReasonPrefix
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$decision = Invoke-DiscoveryPlanningDecision -ToolInputRaw ([Console]::In.ReadToEnd())
$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
exit 0
