<#
.SYNOPSIS
    SubagentStop hook for the four documentation roles (issue #1037).

.DESCRIPTION
    Blocks termination of docs-architect, docs-author, docs-reconciler and docs-coverage-reviewer
    until the role's final message reports every result token of its contract with a valid value
    (Test-DocsRoleOutput in docs-role-contract.ps1). An agent outside the four roles is allowed.

    A missing or invalid token is repairable and blocks on every stop. A payload anomaly or an
    unknown-role condition is not repairable: it blocks once and is allowed when stop_hook_active is
    set, following validate-required-artifact-output.ps1. A dependency failure and an unhandled error
    always block.

.NOTES
    Reads the SubagentStop envelope through Read-SubagentStopEnvelope (subagentstop-envelope.ps1).
    Every block writes a reason starting with DOCS_ROLE_OUTPUT_BLOCKED: to stderr and exits 2.
    File existence goes through Test-DocsRoleOutputFile so tests can mock the boundary without
    writing files. Byte-identical bundled mirror at
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-docs-role-output.ps1.
#>

[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'docs-role-contract.ps1') } catch { Add-HookDependencyFailure -Name 'docs-role-contract.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'subagentstop-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-target-worktree.ps1' -ErrorRecord $_ }

$script:DocsRoleOutputReportAndHaltLine = 'This condition is not repairable by the subagent. Report it to the operator and halt.'

function Test-DocsRoleOutputFile {
    # File seam: returns $true when a regular file exists at the repository-relative path.
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] [string] $Path)

    return [bool](Test-Path -LiteralPath $Path -PathType Leaf)
}

function Invoke-DocsRoleOutputValidation {
    <#
    .SYNOPSIS
        Reads the SubagentStop envelope, validates a documentation role's output and applies the re-entry policy.
    .DESCRIPTION
        Each docs-profile, docs-snapshot, and docs-pages-written value is probed beneath the item
        worktree that Resolve-SubagentStopTargetWorktree resolves from the envelope (issue #1163);
        an unresolved present identity blocks repairably before any probe, and with no identity
        the repository-relative probe is unchanged.
    .PARAMETER InputText
        The envelope text; omit to read standard input.
    .PARAMETER SessionRoot
        The hook's session root; defaults to the current location.
    .PARAMETER ReadTranscriptHead
        Optional transcript reader passed to Resolve-SubagentStopTargetWorktree.
    .PARAMETER WorktreeListInvoker
        Optional worktree-list seam passed to Resolve-SubagentStopTargetWorktree.
    .OUTPUTS
        @{ Ok; Message } for a validation result, or the dependency-failure decision object
        (ExitCode, Reason) when a dependency failed to load.
    #>
    [CmdletBinding()]
    [OutputType([hashtable], [pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText,
        [string] $SessionRoot = (Get-Location).Path,
        [scriptblock] $ReadTranscriptHead,
        [scriptblock] $WorktreeListInvoker
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'DOCS_ROLE_OUTPUT_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    $ErrorActionPreference = 'Stop'

    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
    $agentType = [string]$envelope.AgentType
    if (-not [string]::IsNullOrEmpty($agentType) -and (Get-DocsRoleName) -cnotcontains $agentType) { return @{ Ok = $true; Message = $null } }
    if ($envelope.IsValid -and [string]::IsNullOrEmpty($agentType)) { return @{ Ok = $true; Message = $null } }

    if (-not $envelope.IsValid) {
        $decision = @{ Ok = $false; Repairable = $false; Message = 'payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $envelope.Anomaly) + '.' }
    }
    else {
        $targetArguments = @{ Envelope = $envelope.Envelope; AdvertisedPath = @(); SessionRoot = $SessionRoot }
        if ($null -ne $ReadTranscriptHead) { $targetArguments['ReadTranscriptHead'] = $ReadTranscriptHead }
        if ($null -ne $WorktreeListInvoker) { $targetArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
        $docsTarget = Resolve-SubagentStopTargetWorktree @targetArguments
        $docsSessionRoot = $SessionRoot
        if ($null -ne $docsTarget.ReasonCode) {
            $decision = @{ Ok = $false; Repairable = $true; Message = "target worktree resolution returned $($docsTarget.ReasonCode) ($($docsTarget.Detail)); no output path was probed." }
        }
        else {
            $decision = Test-DocsRoleOutput -Role $agentType -Text ([string]$envelope.AssistantText) -TestFile {
                param([string] $Path)
                $location = Resolve-SubagentStopArtifactLocation -Path $Path -WorktreeRoot $docsTarget.WorktreeRoot -SessionRoot $docsSessionRoot -Target $docsTarget
                if ($location.Rejected) { return $false }
                Test-DocsRoleOutputFile -Path $location.ProbePath
            }
        }
    }
    if ($decision.Ok) { return @{ Ok = $true; Message = $null } }

    $message = 'DOCS_ROLE_OUTPUT_BLOCKED: ' + $decision.Message
    if (-not $decision.Repairable) {
        if ($envelope.StopHookActive) { return @{ Ok = $true; Message = $null } }
        $message = $message + "`n" + $script:DocsRoleOutputReportAndHaltLine
    }
    return @{ Ok = $false; Message = $message }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DOCS_ROLE_OUTPUT_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'DOCS_ROLE_OUTPUT_BLOCKED:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-DocsRoleOutputValidation }
catch { Exit-SubagentStopBlock -Message ('DOCS_ROLE_OUTPUT_BLOCKED: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + $script:DocsRoleOutputReportAndHaltLine) }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
