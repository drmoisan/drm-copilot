<#
.SYNOPSIS
    Native SubagentStart attestation adapter for GitHub Copilot (VS Code local harness) discovery agents.

.DESCRIPTION
    Registered through .github/hooks/*.json. The hook reads the Copilot start
    envelope from stdin (camelCase keys, snake_case accepted), derives the trusted
    launch context from the envelope session and the DRM_DISCOVERY_* values the
    native host adapter placed in the environment, and takes its decision from the
    shared DiscoveryStart module under .claude/lib/discovery-validation:

    - a start whose agent type is not a discovery specialist produces no output;
    - a discovery specialist is attested only when exactly one prepared
      discovery-invocation in the protected store binds this host, session, parent
      and agent type and the activation, deployment, agent profile hash and
      capability pins agree; the start-attestation is recorded and the invocation
      moves to started;
    - a start that cannot be attested writes the DISCOVERY_START_ATTESTATION_BLOCKED:
      reason as the SubagentStart system message; the PreToolUse adapter then denies
      every grant because no started invocation exists.

    A helper that fails to load and an envelope that cannot be read write the reason
    to stderr at exit 2; the hook never fails open. No orchestrator checkpoint is
    read or written.

.NOTES
    Issue #980. Requires PowerShell 7+. Invokes NO external process.
#>
[CmdletBinding()]
param()

$script:DiscoveryStartReasonPrefix = 'DISCOVERY_START_ATTESTATION_BLOCKED:'
$script:DiscoveryStartHandlerPath = $PSCommandPath
$script:DiscoveryStartDependencyFailures = [System.Collections.Generic.List[object]]::new()

function Add-DiscoveryStartDependencyFailure {
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
    [void]$script:DiscoveryStartDependencyFailures.Add([pscustomobject]@{ Name = $Name; Message = $message })
}

foreach ($moduleName in @('DiscoveryEncoding.psm1', 'DiscoveryAuthority.psm1', 'DiscoveryPayload.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryStart.psm1')) {
    try { Import-Module (Join-Path $PSScriptRoot "../../.claude/lib/discovery-validation/$moduleName") -Force -Global -ErrorAction Stop } catch { Add-DiscoveryStartDependencyFailure -Name $moduleName -ErrorRecord $_ }
}

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
        Parses the Copilot SubagentStart envelope and returns the shared start outcome.
    .DESCRIPTION
        Every seam defaults to the real host and is injectable so tests run over
        in-memory values. A recorded helper failure denies before the envelope is read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$EnvironmentValues = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][nullable[datetime]]$Now = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Nonce = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($script:DiscoveryStartDependencyFailures.Count -gt 0) {
        $first = $script:DiscoveryStartDependencyFailures[0]
        return [pscustomobject]@{ Decision = 'deny'; Code = 'DEPENDENCY'; Reason = "the dependency '$($first.Name)' failed to load ($($first.Message)); the gate fails closed."; Attestation = $null; AttestationPath = $null; Invocation = $null }
    }
    # Seams resolve only after the dependency check so a missing module denies
    # instead of raising while a default is evaluated.
    if ($null -eq $EnvironmentValues) { $EnvironmentValues = Get-DiscoveryHostEnvironmentValueTable }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }
    if ($null -eq $Now) { $Now = [datetime]::UtcNow }
    if ([string]::IsNullOrEmpty($Nonce)) { $Nonce = Get-DiscoveryAuthorizationNonceText }

    $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $PayloadRaw
    $parameters = @{
        Normalized = $normalized; Environment = $EnvironmentValues; HostEnvironment = $HostEnvironment
        HandlerSha256 = (Get-DiscoveryStartHandlerSha256); Store = $Store; Now = $Now; Nonce = $Nonce
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    return Get-DiscoveryStartDecision @parameters
}

function Invoke-DiscoveryAgentStartEntryPoint {
    <#
    .SYNOPSIS
        Reads one Copilot SubagentStart payload, writes the hook output and returns the process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$PayloadRaw)

    $outcome = Invoke-DiscoveryAgentStartDecision -PayloadRaw $PayloadRaw
    if ($outcome.Decision -ne 'deny') { return 0 }
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

exit (Invoke-DiscoveryAgentStartEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
