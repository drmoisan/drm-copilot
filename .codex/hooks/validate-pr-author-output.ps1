<#
.SYNOPSIS
    Codex SubagentStop hook that verifies the pr-author agent reported a created or updated PR (issue #1030).

.DESCRIPTION
    Registered in .codex/config.toml as a [[hooks.SubagentStop]] table whose matcher admits pr-author. Reads
    the Codex SubagentStop payload from stdin once and classifies it through the shared envelope helper
    (subagentstop-envelope.ps1), whose fields are last_assistant_message, stop_hook_active, agent_type and
    hook_event_name. The hook allows (exit 0) when the last assistant message contains a GitHub PR URL, a
    "PR #<n>" reference, or a "gh pr create"/"gh pr edit" confirmation that includes a PR number. Otherwise
    it blocks with exit 2 and a stderr reason carrying one of the prefixes PR_AUTHOR_OUTPUT_MALFORMED,
    PR_AUTHOR_OUTPUT_EMPTY, PR_AUTHOR_OUTPUT_NO_PR or PR_AUTHOR_OUTPUT_MISSING.

    One continuation: a blocked stop is allowed (exit 0) when the payload reports stop_hook_active true,
    so the agent receives one block and is never held in a repeated continuation loop. A dependency
    failure and an unparseable payload with stop_hook_active unset fail closed with exit 2.

    The hook never writes stdout and emits no decision, continue or stopReason field. The functions
    Test-PrAuthorOutputReportsPr and Get-PrAuthorOutputDecision are text-identical to the Claude source
    .claude/hooks/validate-pr-author-output.ps1.

.NOTES
    Compatible with PowerShell 7+. Enforcement strength: a policy guardrail, not a security control; the
    output text is forgeable by any actor that controls the agent transcript.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }

function Test-PrAuthorOutputReportsPr {
    <#
    .SYNOPSIS
        Return $true when the supplied output text reports a created or updated PR.
    .DESCRIPTION
        Detection helper (injectable boundary for tests). Matches a GitHub PR URL, a "PR #<n>"
        reference, or a "gh pr create"/"gh pr edit" confirmation that contains a PR number.
    .PARAMETER OutputText
        The pr-author agent's last assistant message text.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [string] $OutputText
    )

    if ([string]::IsNullOrWhiteSpace($OutputText)) {
        return $false
    }

    # GitHub PR URL, e.g. https://github.com/owner/repo/pull/123
    if ($OutputText -match '(?i)github\.com/[^\s/]+/[^\s/]+/pull/\d+') {
        return $true
    }

    # Explicit PR number reference, e.g. "PR #123".
    if ($OutputText -match '(?i)\bPR\s*#\d+') {
        return $true
    }

    # gh pr create / gh pr edit confirmation that includes a PR number anywhere in the output.
    if (($OutputText -match '(?i)\bgh\s+pr\s+(create|edit)\b') -and ($OutputText -match '#\d+')) {
        return $true
    }

    return $false
}

function Get-PrAuthorOutputDecision {
    <#
    .SYNOPSIS
        Read the SubagentStop envelope and return an allow-or-block decision.
    .DESCRIPTION
        Returns an ordered dictionary with 'allowed' (bool) and 'reason' (string). Allowed is $true
        only when the envelope's last assistant message reports a PR per
        Test-PrAuthorOutputReportsPr. An invalid envelope (payload anomaly), a blank last assistant
        message, and a message without a PR reference all yield allowed = $false.
    .PARAMETER InputText
        The SubagentStop envelope JSON. When the parameter is not bound, Read-SubagentStopEnvelope
        reads the envelope from stdin.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'PR_AUTHOR_OUTPUT_MISSING:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
    if (-not $envelope.IsValid) { return [ordered]@{ allowed = $false; reason = "PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly - $(Get-SubagentStopEnvelopeAnomalyReason -Anomaly $envelope.Anomaly)" } }
    $assistantMessage = [string]$envelope.AssistantText

    if ([string]::IsNullOrWhiteSpace($assistantMessage)) {
        return [ordered]@{
            allowed = $false
            reason  = 'PR_AUTHOR_OUTPUT_EMPTY: the pr-author last assistant message is empty; it must report the created or updated PR URL or number.'
        }
    }

    if (Test-PrAuthorOutputReportsPr -OutputText $assistantMessage) {
        return [ordered]@{ allowed = $true }
    }

    return [ordered]@{
        allowed = $false
        reason  = 'PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request.'
    }
}

function Get-CodexPrAuthorStopDecision {
    <#
    .SYNOPSIS
        Return the Codex SubagentStop exit code and reason for one pr-author stop payload.
    .DESCRIPTION
        Returns the dependency-failure result first when a hook dependency failed to load. Otherwise it
        evaluates Get-PrAuthorOutputDecision; an error from that call yields the Claude source's
        PR_AUTHOR_OUTPUT_MISSING: validator error reason with ExitCode 2. An allowed stop returns
        ExitCode 0. A blocked stop returns ExitCode 0 when the payload reports stop_hook_active true (the
        one continuation) and ExitCode 2 with the reason otherwise.
    .PARAMETER InputText
        The Codex SubagentStop payload JSON read from stdin.
    .OUTPUTS
        A PSCustomObject with ExitCode (0 or 2) and Reason (empty when the stop is allowed).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'PR_AUTHOR_OUTPUT_MISSING:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    try { $decision = Get-PrAuthorOutputDecision -InputText $InputText }
    catch {
        $reason = 'PR_AUTHOR_OUTPUT_MISSING: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.'
        return [pscustomobject]@{ ExitCode = 2; Reason = $reason }
    }
    if ($decision['allowed']) { return [pscustomobject]@{ ExitCode = 0; Reason = '' } }
    # One continuation: a stop already re-entered after a block is allowed so the agent cannot loop.
    if ((Read-SubagentStopEnvelope -InputText $InputText).StopHookActive) { return [pscustomobject]@{ ExitCode = 0; Reason = [string]$decision['reason'] } }
    return [pscustomobject]@{ ExitCode = 2; Reason = [string]$decision['reason'] }
}

# Allow dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PR_AUTHOR_OUTPUT_MISSING: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'PR_AUTHOR_OUTPUT_MISSING:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }

$payloadText = [Console]::In.ReadToEnd()
$stopDecision = Get-CodexPrAuthorStopDecision -InputText $payloadText
if ($stopDecision.ExitCode -eq 2) { Exit-SubagentStopBlock -Message $stopDecision.Reason }
exit 0
