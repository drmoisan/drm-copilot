<#
.SYNOPSIS
    Native PreToolUse authorization adapter for GitHub Copilot (VS Code local harness) discovery agents.

.DESCRIPTION
    Registered through .github/hooks/*.json. The hook reads the Copilot PreToolUse
    envelope from stdin (camelCase keys, snake_case accepted), derives the trusted
    principal from the payload alone (session, agentId and agentType when the
    harness supplies them, and parentAgentId or the literal parent root), and
    takes its decision from the shared DiscoveryAuthorization module under
    .claude/lib/discovery-validation:

    - a root call (no agentId) of prepare_discovery_agent, run_discovery_doctor or
      a controlled discovery tool is allowed with a one-use root grant the MCP
      server consumes; every other root call and every call of an agent that is
      not a discovery specialist is allowed, so ordinary sessions keep their behavior;
    - a sentinel envelope is observed for the capability probe and never granted;
    - a discovery specialist may use read-only native tools and the controlled
      discovery MCP tools only; shell, terminal, exec and evaluation tools, generic
      file mutations, nested agents, foreign MCP servers, root-only discovery
      operations and caller-supplied identity fields are denied before execution;
    - the specialist's first controlled call binds the single prepared invocation
      of its session, parent and agent type (the Copilot subagentStart payload
      carries no agent identifier); every controlled call must name that invocation
      through invocation_ref and is recorded as one short-lived, one-use tool-authorization.

    A helper that fails to load and an envelope that cannot be read both deny with
    the DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix; the hook never fails open.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()

$script:DiscoveryGateReasonPrefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
$script:DiscoveryGateHandlerPath = $PSCommandPath
$script:DiscoveryGateDependencyFailures = [System.Collections.Generic.List[object]]::new()

function Add-DiscoveryGateDependencyFailure {
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
    [void]$script:DiscoveryGateDependencyFailures.Add([pscustomobject]@{ Name = $Name; Message = $message })
}

foreach ($moduleName in @('DiscoveryEncoding.psm1', 'DiscoveryAuthority.psm1', 'DiscoveryPayload.psm1', 'DiscoveryToolRouting.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryRootGrant.psm1', 'DiscoveryObservation.psm1', 'DiscoveryStart.psm1', 'DiscoveryAuthorization.psm1')) {
    try { Import-Module (Join-Path $PSScriptRoot "../../.claude/lib/discovery-validation/$moduleName") -Force -Global -ErrorAction Stop } catch { Add-DiscoveryGateDependencyFailure -Name $moduleName -ErrorRecord $_ }
}

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

function Invoke-DiscoveryPreToolDecision {
    <#
    .SYNOPSIS
        Parses the Copilot PreToolUse envelope and returns the hookSpecificOutput decision.
    .DESCRIPTION
        Every seam defaults to the real host and is injectable so tests run over
        in-memory values. A recorded helper failure denies before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolInputRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][nullable[datetime]]$Now = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null
    )

    if ($script:DiscoveryGateDependencyFailures.Count -gt 0) {
        $first = $script:DiscoveryGateDependencyFailures[0]
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "$($script:DiscoveryGateReasonPrefix) the dependency '$($first.Name)' failed to load ($($first.Message)); the gate fails closed."
            }
        }
    }
    # Seams resolve only after the dependency check so a missing module denies
    # instead of raising while a default is evaluated.
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryDefaultStore }
    if ($null -eq $Now) { $Now = [datetime]::UtcNow }
    if ([string]::IsNullOrEmpty($Nonce)) { $Nonce = Get-DiscoveryAuthorizationNonce }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $ToolInputRaw
    $outcome = Get-DiscoveryPreToolDecision -Normalized $normalized -HostEnvironment $HostEnvironment `
        -HandlerSha256 (Get-DiscoveryGateHandlerSha256) -Store $Store -Now $Now -Nonce $Nonce
    return ConvertTo-DiscoveryPreToolHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryGateReasonPrefix
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$decision = Invoke-DiscoveryPreToolDecision -ToolInputRaw ([Console]::In.ReadToEnd())
$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
exit 0
