<#
.SYNOPSIS
    Native SubagentStop output validation adapter for Codex discovery agents.

.DESCRIPTION
    Invoked by the Codex SubagentStop hook. The hook reads the Codex stop envelope
    from stdin, derives the stopping principal from the payload alone (session, the
    host-assigned agent_id and agent_type, and the literal parent root), and
    takes its decision from the shared DiscoveryStop module (published under
    .codex/lib/discovery-validation, or read from .claude/lib when this repository
    hosts itself):

    - a stop whose agent type is not a discovery specialist writes nothing, so the
      routing validator and the other Codex stop gates keep their behavior;
    - a discovery specialist may stop only when its protected invocation was
      finalized through the gateway with a current, gateway-written completion
      receipt whose required outputs are present and whose inputs are unchanged;
    - a stop that cannot be validated requests one continuation (decision=block at
      exit 0) and, when stop_hook_active is already true, ends the stop with the
      reason instead of looping.

    An envelope the hook cannot read writes the reason to stderr at exit 2.
    Dependency failures block with the DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix
    (issue #980). No orchestrator checkpoint is read or written.

.NOTES
    Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

function Get-DiscoveryStopHelperModulePath {
    <#
    .SYNOPSIS
        Returns the published (.codex/lib) or self-hosting (.claude/lib) path of one helper module.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$ModuleName,
        [Parameter(Mandatory = $false)][string]$ScriptRoot = $PSScriptRoot
    )

    $published = Join-Path $ScriptRoot "../lib/discovery-validation/$ModuleName"
    $selfHosted = Join-Path $ScriptRoot "../../.claude/lib/discovery-validation/$ModuleName"
    foreach ($candidate in @($published, $selfHosted)) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $published
}

function Import-DiscoveryOutputSelfHostedModule {
    <#
    .SYNOPSIS
        Imports the shared helpers from this repository's .claude/lib layout when no published .codex/lib exists (exemption D4).
    #>
    [CmdletBinding()]
    param()

    $ScriptRoot = $PSScriptRoot
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryManifest.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryStop.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStop.psm1' -ErrorRecord $_ }
}

# The published destination keeps the helpers beside .codex/hooks; this repository hosts them under .claude/lib.
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -PathType Leaf) {
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryManifest.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStop.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStop.psm1' -ErrorRecord $_ }
} else {
    Import-DiscoveryOutputSelfHostedModule
}

$script:DiscoveryGateReasonPrefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'

function Invoke-DiscoveryAgentOutputDecision {
    <#
    .SYNOPSIS
        Parses the Codex SubagentStop envelope and returns the shared stop outcome.
    .DESCRIPTION
        Returns the outcome object (Decision skip, allow or block; Code; Reason;
        Receipt; Invocation). Every seam defaults to the real host and is injectable.
        A recorded dependency failure blocks before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix $script:DiscoveryGateReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'codex' -Text $PayloadRaw
    $assistantText = ''
    $stopHookActive = $false
    if ($null -eq $normalized.Anomaly) {
        $payload = ConvertFrom-Json -InputObject $PayloadRaw -Depth 16
        $names = @($payload.PSObject.Properties.Name)
        if ($names -contains 'last_assistant_message' -and $payload.last_assistant_message -is [string]) { $assistantText = [string]$payload.last_assistant_message }
        if ($names -contains 'stop_hook_active' -and $payload.stop_hook_active -is [bool]) { $stopHookActive = [bool]$payload.stop_hook_active }
    }
    $parameters = @{
        Normalized = $normalized; HostEnvironment = $HostEnvironment
        AssistantText = $assistantText; StopHookActive = $stopHookActive; Store = $Store
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    return Get-DiscoveryStopDecision @parameters
}

function Get-DiscoveryAgentOutputContinuation {
    <#
    .SYNOPSIS
        Renders a blocked stop as the Codex continuation (decision=block) or, when already continued, the stop reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $true)][bool]$AlreadyContinued
    )

    if ($AlreadyContinued) {
        return [ordered]@{ continue = $false; stopReason = $Reason; systemMessage = $Reason }
    }
    return [ordered]@{ decision = 'block'; reason = $Reason }
}

function Invoke-DiscoveryAgentOutputEntryPoint {
    <#
    .SYNOPSIS
        Reads one Codex SubagentStop payload, writes the decision and returns the process exit code.
    .DESCRIPTION
        An unreadable envelope or a dependency failure writes its reason to stderr and
        returns 2. A blocked stop writes the continuation JSON and returns 0; a
        CONTINUED allow writes the stop reason JSON and returns 0. A skipped or
        validated stop writes nothing and returns 0.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw)

    $outcome = Invoke-DiscoveryAgentOutputDecision -PayloadRaw $PayloadRaw
    # A dependency failure is already the SubagentStop block result (ExitCode, Reason).
    if ($null -ne $outcome.PSObject.Properties['ExitCode']) { [Console]::Error.WriteLine([string]$outcome.Reason); return [int]$outcome.ExitCode }
    if ($outcome.Code -eq 'ENVELOPE') {
        [Console]::Error.WriteLine("$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)")
        return 2
    }
    if ($outcome.Decision -eq 'block' -or $outcome.Code -eq 'CONTINUED') {
        $continuation = Get-DiscoveryAgentOutputContinuation -Reason "$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)" -AlreadyContinued ($outcome.Code -eq 'CONTINUED')
        [Console]::Out.WriteLine(($continuation | ConvertTo-Json -Compress -Depth 5))
    }
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_ARTIFACT_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

exit (Invoke-DiscoveryAgentOutputEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
