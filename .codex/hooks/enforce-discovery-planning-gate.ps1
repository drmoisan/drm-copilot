<#
.SYNOPSIS
    Codex PreToolUse hook that gates planner and orchestrator launches on current configured discovery authority.

.DESCRIPTION
    Invoked by the Codex PreToolUse hook. The hook reads the Codex envelope from
    stdin, recognizes an atomic-planner or orchestrator launch, and takes its
    decision from the shared DiscoveryPlanning module (published under
    .codex/lib/discovery-validation, or read from .claude/lib when this repository
    hosts itself):

    - a call that is not a planner or orchestrator launch, and a workspace without
      a protected discovery activation, allow silently (no stdout) so the existing
      Codex gates keep their behavior;
    - an active workspace must still hold the activated locator and domain profile
      and the protected session must hold a current, passing, gateway-written
      planning-mode receipt for this host and session; otherwise the launch is
      denied with a PreToolUse deny decision at exit 0.

    An envelope the hook cannot read is a hard failure: the reason goes to stderr
    and the hook exits 2. Dependency failures deny with the
    DISCOVERY_PLANNING_GATE_BLOCKED: prefix. The hook never runs Python (issue #980).

.NOTES
    Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

function Get-DiscoveryPlanningHelperModulePath {
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

function Import-DiscoveryPlanningSelfHostedModule {
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
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryPlanning.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPlanning.psm1' -ErrorRecord $_ }
}

# The published destination keeps the helpers beside .codex/hooks; this repository hosts them under .claude/lib.
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -PathType Leaf) {
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryManifest.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPlanning.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPlanning.psm1' -ErrorRecord $_ }
} else {
    Import-DiscoveryPlanningSelfHostedModule
}

$script:DiscoveryPlanningReasonPrefix = 'DISCOVERY_PLANNING_GATE_BLOCKED:'

function Invoke-DiscoveryPlanningGateDecision {
    <#
    .SYNOPSIS
        Parses the Codex PreToolUse envelope and returns the planning outcome.
    .DESCRIPTION
        Returns the shared outcome object (Decision, Code, Reason, Receipt,
        Prerequisite). Every seam defaults to the real host and is injectable. A
        recorded dependency failure returns a deny outcome before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolInputRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix $script:DiscoveryPlanningReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'codex' -Text $ToolInputRaw
    $parameters = @{ Normalized = $normalized; HostEnvironment = $HostEnvironment; Store = $Store }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    return Get-DiscoveryPlanningDecision @parameters
}

function Invoke-DiscoveryPlanningGateEntryPoint {
    <#
    .SYNOPSIS
        Reads one Codex PreToolUse payload, writes the decision and returns the process exit code.
    .DESCRIPTION
        An unreadable envelope writes its reason to stderr and returns 2. A deny
        writes the PreToolUse decision JSON to stdout and returns 0. An allow writes
        nothing and returns 0, as the Codex gates do.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw)

    $outcome = Invoke-DiscoveryPlanningGateDecision -ToolInputRaw $PayloadRaw
    # A dependency failure is already the PreToolUse deny decision.
    if ($outcome -is [System.Collections.IDictionary]) { [Console]::Out.WriteLine(($outcome | ConvertTo-Json -Compress -Depth 5)); return 0 }
    if ($outcome.Decision -eq 'allow') { return 0 }
    if ($outcome.Code -eq 'ENVELOPE') {
        [Console]::Error.WriteLine("$($script:DiscoveryPlanningReasonPrefix) $($outcome.Reason)")
        return 2
    }
    $decision = ConvertTo-DiscoveryPlanningHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryPlanningReasonPrefix
    [Console]::Out.WriteLine(($decision | ConvertTo-Json -Compress -Depth 5))
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_PLANNING_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DISCOVERY_PLANNING_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

exit (Invoke-DiscoveryPlanningGateEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
