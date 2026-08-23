<#
.SYNOPSIS
    SubagentStop hook that verifies the pr-author agent reported a created or updated PR.

.DESCRIPTION
    Invoked by the Claude Code SubagentStop hook for the pr-author matcher. Reads the agent
    transcript JSON from the CLAUDE_HOOK_INPUT environment variable, extracts the .output field,
    and confirms the output reports that a pull request was created or updated. The hook allows
    (exit 0) when the output contains:
      - a GitHub PR URL (github.com/<owner>/<repo>/pull/<n>), or
      - a PR reference of the form "PR #<n>", or
      - a "gh pr create"/"gh pr edit" confirmation that includes a PR number.
    The hook blocks (exit 1) when:
      - CLAUDE_HOOK_INPUT is empty,
      - the input is not valid JSON,
      - the .output field is empty, or
      - the output contains no PR URL or PR number.

.NOTES
    Compatible with PowerShell 7+. No external module dependencies.

    Enforcement strength: this validator is a policy guardrail, not a cryptographic or security
    control. It confirms that the pr-author agent's final output references a PR; it cannot verify
    that the referenced PR actually exists on GitHub, and the output text is forgeable by any actor
    that controls the agent transcript. It MUST NOT be described as tamper-proof or as a security
    boundary.
#>
[CmdletBinding()]
param()

function Test-PrAuthorOutputReportsPr {
    <#
    .SYNOPSIS
        Return $true when the supplied output text reports a created or updated PR.
    .DESCRIPTION
        Detection helper (injectable boundary for tests). Matches a GitHub PR URL, a "PR #<n>"
        reference, or a "gh pr create"/"gh pr edit" confirmation that contains a PR number.
    .PARAMETER OutputText
        The pr-author agent's final output text extracted from CLAUDE_HOOK_INPUT.output.
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
        Parse CLAUDE_HOOK_INPUT and return an allow-or-block decision with exit code semantics.
    .DESCRIPTION
        Returns an ordered dictionary with 'allowed' (bool) and 'reason' (string). Allowed is $true
        only when the parsed .output reports a PR per Test-PrAuthorOutputReportsPr. Empty input,
        malformed JSON, empty output, and PR-less output all yield allowed = $false.
    .PARAMETER HookInputRaw
        The raw JSON transcript payload supplied by Claude Code via CLAUDE_HOOK_INPUT.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $HookInputRaw
    )

    if ([string]::IsNullOrWhiteSpace($HookInputRaw)) {
        return [ordered]@{
            allowed = $false
            reason  = 'PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.'
        }
    }

    try {
        $parsed = $HookInputRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return [ordered]@{
            allowed = $false
            reason  = 'PR_AUTHOR_OUTPUT_MALFORMED: CLAUDE_HOOK_INPUT is not valid JSON.'
        }
    }

    $outputText = [string]$parsed.output
    if ([string]::IsNullOrWhiteSpace($outputText)) {
        return [ordered]@{
            allowed = $false
            reason  = 'PR_AUTHOR_OUTPUT_EMPTY: the pr-author agent output is empty; it must report the created or updated PR URL or number.'
        }
    }

    if (Test-PrAuthorOutputReportsPr -OutputText $outputText) {
        return [ordered]@{ allowed = $true }
    }

    return [ordered]@{
        allowed = $false
        reason  = 'PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request.'
    }
}

# Allow dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$decision = Get-PrAuthorOutputDecision -HookInputRaw $env:CLAUDE_HOOK_INPUT

if (-not $decision['allowed']) {
    Write-Error $decision['reason']
    exit 1
}

exit 0
