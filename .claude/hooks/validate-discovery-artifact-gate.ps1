<#
.SYNOPSIS
    SubagentStop hook that validates a discovery specialist's protected output authority.

.DESCRIPTION
    Invoked by the Claude Code SubagentStop hook under the existing broad
    generic-agent matcher group. The hook reads the SubagentStop envelope through
    the shared envelope helper (subagentstop-envelope.ps1), derives the trusted
    launch context from the envelope session and the DRM_DISCOVERY_* values the
    native host adapter placed in the environment, and takes its decision from the
    shared DiscoveryStop module:

    - a stop whose agent type is not a discovery specialist is allowed, so the
      other SubagentStop validators keep their behavior;
    - a discovery specialist may stop only when its protected invocation was
      finalized through the gateway and the completion receipt is the gateway's
      validation-receipt for this invocation, session, role and gate mode, bound to
      the current activation and workspace, with every required output present,
      every input unchanged since the receipt and output_valid true; the
      migration-coverage-reviewer may stop on a valid failing report;
    - filenames or success prose in the final message never admit a stop, and a
      blank final message never skips the validation.

    A stop that cannot be validated blocks: the reason is written with the
    DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix to stderr and the hook exits 2 through
    the shared envelope helper. An invalid envelope blocks with a "payload anomaly"
    reason. An unhandled error during validation blocks with exit 2 and a reason
    (issue #928). No orchestrator checkpoint is read or written.

.NOTES
    Requires PowerShell 7+. Invokes NO external process and never reads a profile,
    locator or final-message field to decide identity or authority (issue #980).
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryEncoding.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryAuthority.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryAuthority.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryManifest.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryPayload.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStartRecord.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/discovery-validation/DiscoveryStop.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DiscoveryStop.psm1' -ErrorRecord $_ }

$script:DiscoveryGateReasonPrefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'

function Invoke-DiscoveryArtifactGateValidation {
    <#
    .SYNOPSIS
        Reads the SubagentStop envelope and returns an Ok/Message validation result for a discovery stop.
    .DESCRIPTION
        Every seam defaults to the real host (process environment, platform state
        roots, protected store, workspace bytes) and is injectable so tests run over
        in-memory values. A recorded dependency failure blocks before the envelope is
        read. The result also carries the shared outcome Code for diagnostics.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$EnvironmentValues = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix $script:DiscoveryGateReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
    if (-not $envelope.IsValid) { return @{ Ok = $false; Message = "$($script:DiscoveryGateReasonPrefix) payload anomaly - $(Get-SubagentStopEnvelopeAnomalyReason -Anomaly $envelope.Anomaly)"; Code = 'ENVELOPE' } }

    # Seams resolve only after the dependency check so a missing module blocks
    # instead of raising while a default is evaluated.
    if ($null -eq $EnvironmentValues) { $EnvironmentValues = Get-DiscoveryHostEnvironmentValueTable }
    if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
    if ($null -eq $Store) { $Store = Get-DiscoveryStartStore }

    $normalized = ConvertFrom-DiscoveryHostEnvelope -HostName 'claude-code' -Envelope $envelope.Envelope
    $parameters = @{
        Normalized = $normalized; Environment = $EnvironmentValues; HostEnvironment = $HostEnvironment
        AssistantText = [string]$envelope.AssistantText; StopHookActive = [bool]$envelope.StopHookActive; Store = $Store
    }
    if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
    $outcome = Get-DiscoveryStopDecision @parameters
    if ($outcome.Decision -eq 'block') {
        return @{ Ok = $false; Message = "$($script:DiscoveryGateReasonPrefix) $($outcome.Reason)"; Code = $outcome.Code }
    }
    return @{ Ok = $true; Message = $null; Code = $outcome.Code }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DISCOVERY_ARTIFACT_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

try { $result = Invoke-DiscoveryArtifactGateValidation }
catch { Exit-SubagentStopBlock -Message ('DISCOVERY_ARTIFACT_GATE_BLOCKED: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
