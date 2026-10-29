<#
.SYNOPSIS
    Native SubagentStop output validation adapter for GitHub Copilot (VS Code local harness) discovery agents.

.DESCRIPTION
    Registered through .github/hooks/*.json. The hook reads the Copilot stop
    envelope from stdin (camelCase keys, snake_case accepted), derives the stopping
    principal from the payload alone (session, agentId and agentType, and
    parentAgentId or the literal parent root), and takes its decision from the
    shared DiscoveryStop module under .claude/lib/discovery-validation:

    - a stop whose agent type is not a discovery specialist writes nothing;
    - a discovery specialist may stop only when its protected invocation was
      finalized through the gateway with a current, gateway-written completion
      receipt whose required outputs are present and whose inputs are unchanged;
    - a stop that cannot be validated writes a decision=block JSON with the
      DISCOVERY_ARTIFACT_GATE_BLOCKED: reason at exit 0, or ends the stop with the
      reason when a continuation was already requested.

    A helper that fails to load and an envelope that cannot be read write the reason
    to stderr at exit 2; the hook never fails open. No orchestrator checkpoint is
    read or written.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()

$script:DiscoveryGateReasonPrefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
$script:DiscoveryStopDependencyFailures = [System.Collections.Generic.List[object]]::new()

function Add-DiscoveryStopDependencyFailure {
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
    [void]$script:DiscoveryStopDependencyFailures.Add([pscustomobject]@{ Name = $Name; Message = $message })
}

foreach ($moduleName in @('DiscoveryEncoding.psm1', 'DiscoveryAuthority.psm1', 'DiscoveryManifest.psm1', 'DiscoveryPayload.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryStop.psm1')) {
    try { Import-Module (Join-Path $PSScriptRoot "../../.claude/lib/discovery-validation/$moduleName") -Force -Global -ErrorAction Stop } catch { Add-DiscoveryStopDependencyFailure -Name $moduleName -ErrorRecord $_ }
}

function Invoke-DiscoveryAgentStopDecision {
    <#
    .SYNOPSIS
        Parses the Copilot SubagentStop envelope and returns the shared stop outcome.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($script:DiscoveryStopDependencyFailures.Count -gt 0) {
        $first = $script:DiscoveryStopDependencyFailures[0]
        return [pscustomobject]@{ Decision = 'block'; Code = 'DEPENDENCY'; Reason = "the dependency '$($first.Name)' failed to load ($($first.Message)); the gate fails closed."; Receipt = $null; Invocation = $null }
    }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $PayloadRaw
    $assistantText = ''
    $stopHookActive = $false
    if ($null -eq $normalized.Anomaly) {
        $payload = ConvertFrom-Json -InputObject $PayloadRaw -Depth 16
        $names = @($payload.PSObject.Properties.Name)
        foreach ($key in @('lastAssistantMessage', 'last_assistant_message')) {
            if ($names -contains $key -and $payload.$key -is [string]) { $assistantText = [string]$payload.$key; break }
        }
        foreach ($key in @('stopHookActive', 'stop_hook_active')) {
            if ($names -contains $key -and $payload.$key -is [bool]) { $stopHookActive = [bool]$payload.$key; break }
        }
    }
    $parameters = @{
        Normalized = $normalized; HostEnvironment = $HostEnvironment
        AssistantText = $assistantText; StopHookActive = $stopHookActive; Store = $Store
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    return Get-DiscoveryStopDecision @parameters
}

function Invoke-DiscoveryAgentStopEntryPoint {
    <#
    .SYNOPSIS
        Reads one Copilot SubagentStop payload, writes the decision and returns the process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw)

    $outcome = Invoke-DiscoveryAgentStopDecision -PayloadRaw $PayloadRaw
    if ($outcome.Code -in @('ENVELOPE', 'DEPENDENCY')) {
        [Console]::Error.WriteLine("$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)")
        return 2
    }
    $reason = "$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)"
    if ($outcome.Decision -eq 'block') {
        [Console]::Out.WriteLine(([ordered]@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress -Depth 5))
    } elseif ($outcome.Code -eq 'CONTINUED') {
        [Console]::Out.WriteLine(([ordered]@{ continue = $false; stopReason = $reason; systemMessage = $reason } | ConvertTo-Json -Compress -Depth 5))
    }
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

exit (Invoke-DiscoveryAgentStopEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
