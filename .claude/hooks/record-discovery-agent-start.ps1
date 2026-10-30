<#
.SYNOPSIS
    Native SubagentStart attestation adapter for Claude Code discovery agents.

.DESCRIPTION
    Invoked by the Claude Code SubagentStart hook. The hook reads the start envelope,
    derives the launch context from the payload alone (session, the host-assigned
    agent_id and agent_type, and the literal parent root), and takes its decision
    from the shared DiscoveryStart module. The start is observational: Claude Code
    does not let a SubagentStart hook prevent the agent from running.

    - a start whose agent type is not a discovery specialist is left to the
      ordinary and epic attestation path and produces no output;
    - a discovery specialist is attested when the protected store holds exactly one
      prepared discovery-invocation bound to this host, session, parent and agent
      type and the activation, deployment, agent profile hash and capability pins
      agree; the start-attestation is recorded and the invocation moves to started;
    - a start that cannot be attested writes the DISCOVERY_START_ATTESTATION_BLOCKED:
      reason as the SubagentStart system message; the PreToolUse adapter then binds
      the prepared invocation at the first controlled call or denies every grant.

    No orchestrator checkpoint is read or written. An envelope the hook cannot read
    and a dependency that fails to load write the reason to stderr at exit 2
    (issue #980).

.NOTES
    Requires PowerShell 7+. Invokes NO external process and never reads a profile,
    locator or payload field to decide identity or authority.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStart.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStart.psm1' -ErrorRecord $_ }

$script:DiscoveryStartReasonPrefix = 'DISCOVERY_START_ATTESTATION_BLOCKED:'
$script:DiscoveryStartHandlerPath = $PSCommandPath

function Get-DiscoveryStartHandlerSha256 {
    <#
    .SYNOPSIS
        Returns the SHA-256 of this handler's own bytes for the attestation writer record.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][string]$HandlerPath = $script:DiscoveryStartHandlerPath)

    if ([string]::IsNullOrEmpty($HandlerPath) -or -not (Test-Path -LiteralPath $HandlerPath -PathType Leaf)) {
        return ('0' * 64)
    }
    return Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($HandlerPath))
}

function Invoke-DiscoveryAgentStartDecision {
    <#
    .SYNOPSIS
        Parses the SubagentStart envelope and returns the shared start outcome.
    .DESCRIPTION
        Returns the outcome object (Decision skip, observe or attest; Code; Reason;
        Attestation; AttestationPath; Invocation). Every seam defaults to the real
        host and is injectable so tests run over in-memory values. A recorded
        dependency failure denies before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][nullable[datetime]]$Now = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )
    if (Test-HookDependencyFailure) {
        $reason = Get-HookDependencyFailureReason -ReasonPrefix $script:DiscoveryStartReasonPrefix
        return [pscustomobject]@{ Decision = 'deny'; Code = 'DEPENDENCY'; Reason = $reason.Substring($script:DiscoveryStartReasonPrefix.Length).TrimStart(); Attestation = $null; AttestationPath = $null; Invocation = $null }
    }

    # Seams resolve only after the dependency check so a missing module denies
    # instead of raising while a default is evaluated.
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }
    if ($null -eq $Now) { $Now = [datetime]::UtcNow }
    if ([string]::IsNullOrEmpty($Nonce)) { $Nonce = Get-DiscoveryAuthorizationNonceText }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $PayloadRaw
    $parameters = @{
        Normalized = $normalized; HostEnvironment = $HostEnvironment
        HandlerSha256 = (Get-DiscoveryStartHandlerSha256); Store = $Store; Now = $Now; Nonce = $Nonce
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    return Get-DiscoveryStartDecision @parameters
}

function Invoke-DiscoveryAgentStartEntryPoint {
    <#
    .SYNOPSIS
        Reads one SubagentStart payload, writes the hook output and returns the process exit code.
    .DESCRIPTION
        An unreadable envelope or a dependency failure writes its reason to stderr
        and returns 2. An observed (unattested) start writes the SubagentStart output
        JSON to stdout and returns 0. A skipped or attested start writes nothing and returns 0.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw)

    $outcome = Invoke-DiscoveryAgentStartDecision -PayloadRaw $PayloadRaw
    if ($outcome.Decision -notin @('deny', 'observe')) { return 0 }
    if ($outcome.Code -in @('ENVELOPE', 'DEPENDENCY')) {
        [Console]::Error.WriteLine("$($script:DiscoveryStartReasonPrefix) $($outcome.Reason)")
        return 2
    }
    $output = ConvertTo-DiscoveryStartHookOutput -Outcome $outcome -ReasonPrefix $script:DiscoveryStartReasonPrefix
    [Console]::Out.WriteLine(($output | ConvertTo-Json -Compress -Depth 5))
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_START_ATTESTATION_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'DISCOVERY_START_ATTESTATION_BLOCKED:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

exit (Invoke-DiscoveryAgentStartEntryPoint -PayloadRaw (Read-ClaudeHookRawPayload))
