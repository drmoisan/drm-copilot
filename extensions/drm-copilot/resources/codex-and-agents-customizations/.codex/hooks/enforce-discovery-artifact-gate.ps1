<#
.SYNOPSIS
    Native PreToolUse authorization adapter for Codex discovery agents.

.DESCRIPTION
    Invoked by the Codex PreToolUse hook. The hook reads the Codex envelope from
    stdin, derives the trusted principal from the envelope session and the
    DRM_DISCOVERY_* values the native host adapter placed in the environment, and
    takes its decision from the shared DiscoveryAuthorization module (published
    under .codex/lib/discovery-validation, or read from .claude/lib when this
    repository hosts itself):

    - a process without an attested discovery agent allows silently (no stdout),
      so root and ordinary sessions keep the behavior of their other gates;
    - a discovery specialist may use read-only native tools and the controlled
      discovery MCP tools only; shell, exec and evaluation tools, generic
      apply_patch/Write/Edit mutations, nested agents, foreign MCP servers,
      root-only discovery operations and caller-supplied identity fields are denied
      before execution with a PreToolUse deny decision at exit 0;
    - an admitted controlled call is bound to the agent's started protected
      invocation and recorded as one short-lived, one-use tool-authorization.

    An envelope the hook cannot read is a hard failure: the reason goes to stderr
    and the hook exits 2. Dependency failures deny with the
    DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix (issue #980).

.NOTES
    Requires PowerShell 7+. Invokes NO external process and never reads a profile,
    locator or request field to decide identity or authority.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

function Get-DiscoveryHelperModulePath {
    <#
    .SYNOPSIS
        Returns the published (.codex/lib) or self-hosting (.claude/lib) path of one helper module.
    .DESCRIPTION
        The published destination holds the helpers beside .codex/hooks under
        .codex/lib/discovery-validation; this repository holds them under
        .claude/lib/discovery-validation. The first existing candidate wins; when
        neither exists the published path is returned so the import failure names it.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$ModuleName,
        [Parameter(Mandatory = $false)][string]$ScriptRoot = $PSScriptRoot
    )

    $published = Join-Path $ScriptRoot "../lib/discovery-validation/$ModuleName"
    $selfHosted = Join-Path $ScriptRoot "../../.claude/lib/discovery-validation/$ModuleName"
    # Resolution order: the destination layout first, then the repository layout.
    foreach ($candidate in @($published, $selfHosted)) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $published
}

function Import-DiscoveryGateSelfHostedModule {
    <#
    .SYNOPSIS
        Imports the shared helpers from this repository's .claude/lib layout when no published .codex/lib exists (exemption D4).
    #>
    [CmdletBinding()]
    param()

    $ScriptRoot = $PSScriptRoot
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryToolRouting.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryToolRouting.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $ScriptRoot '../../.claude/lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }
}

# The published destination keeps the helpers beside .codex/hooks; this repository hosts them under .claude/lib.
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -PathType Leaf) {
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryToolRouting.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryToolRouting.psm1' -ErrorRecord $_ }
    try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthorization.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1' -ErrorRecord $_ }
} else {
    Import-DiscoveryGateSelfHostedModule
}

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
        Parses the Codex PreToolUse envelope and returns the decision outcome.
    .DESCRIPTION
        Returns the shared outcome object (Decision, Code, Reason, Record,
        RecordPath). Every seam defaults to the real host and is injectable. A
        recorded dependency failure returns a deny outcome before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
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

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'codex' -Text $ToolInputRaw
    return Get-DiscoveryPreToolDecision -Normalized $normalized -Environment $EnvironmentValues -HostEnvironment $HostEnvironment `
        -HandlerSha256 (Get-DiscoveryGateHandlerSha256) -Store $Store -Now $Now -Nonce $Nonce
}

function Invoke-DiscoveryArtifactGateEntryPoint {
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

    $outcome = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $PayloadRaw
    # A dependency failure is already the PreToolUse deny decision.
    if ($outcome -is [System.Collections.IDictionary]) { [Console]::Out.WriteLine(($outcome | ConvertTo-Json -Compress -Depth 5)); return 0 }
    if ($outcome.Decision -eq 'allow') { return 0 }
    if ($outcome.Code -eq 'ENVELOPE') {
        [Console]::Error.WriteLine("$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)")
        return 2
    }
    $decision = ConvertTo-DiscoveryPreToolHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryGateReasonPrefix
    [Console]::Out.WriteLine(($decision | ConvertTo-Json -Compress -Depth 5))
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_ARTIFACT_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

exit (Invoke-DiscoveryArtifactGateEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
