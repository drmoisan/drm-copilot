<#
.SYNOPSIS
    Pure helper functions supporting the release-verification module of issue
    #526.

.DESCRIPTION
    These four functions are pure: each is a total function of its parameters,
    performs no external executable call, no filesystem access, no network
    access, and no wait, and changes no state outside the value it returns.
    They were moved here verbatim from
    scripts/dev-tools/Invoke-ReleaseVerification.ps1 because that file stood one
    line under the repository's 500-line cap and could not absorb the per-check
    polling-budget parameters that issue #526 requires.

    This file declares no entry-point block. It is dot-sourced by
    scripts/dev-tools/Invoke-ReleaseVerification.ps1 and has no standalone
    behaviour of its own, so there is nothing to guard against being run
    directly.

.EXAMPLE
    . ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1
#>

function ConvertFrom-JsonSafely {
    <#
    .SYNOPSIS
        Parses JSON text, returning $null instead of throwing when the text is
        empty or malformed. Pure helper; performs no external call.
    .DESCRIPTION
        The gh seam returns whatever the CLI wrote, which on a transient error is
        not JSON. A poll must treat that attempt as "nothing found yet" and retry
        rather than terminate, so a parse failure is a value here, not a throw.
    .OUTPUTS
        The deserialized object, or $null when the text is empty or unparseable.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    try {
        return ($Text | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

function Get-RecoveryInstruction {
    <#
    .SYNOPSIS
        Maps a state token to its operator recovery instruction. Pure lookup.
    .DESCRIPTION
        Each non-success state carries its own instruction and no two of them are
        the same string. A single generic failure message would say that
        something went wrong without saying whether the version number was
        consumed, which is the one fact that decides whether a retry is safe. The
        table mirrors section 3.2 of the feature spec for issue #526.
    .OUTPUTS
        The instruction string, or an empty string for an unrecognized token.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    $instructions = @{
        VERSION_CONSUMED_ELSEWHERE = 'Abort before pushing anything. The target version number is already taken on the registry; bump the version again and re-run the release.'
        NO_RUN                     = 'No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.'
        RUN_FAILED                 = 'The run did not reach a successful conclusion. Read the run logs. The version may or may not be consumed; evaluate the registry-resolution check before any retry.'
        RUN_INCOMPLETE             = 'The run had not reached a terminal conclusion when the polling budget expired, so no failure was observed and the run may still be in progress. The version may or may not be consumed. Re-run the verifier rather than reading the run logs; the logs of an unconcluded run cannot answer whether the publish succeeded.'
        STEP_SKIPPED               = 'The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.'
        STEP_MISSING               = 'The named job or step was not found in the run payload, which means the workflow was renamed. Treat this as a failure, never as absence of evidence, and reconcile the job and step names before retrying.'
        UNRESOLVED                 = 'The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.'
        RESOLVED                   = ''
    }

    if ($instructions.ContainsKey($State)) {
        return [string]$instructions[$State]
    }
    return ''
}

function ConvertTo-VerificationResult {
    <#
    .SYNOPSIS
        Builds the verification result object for one state token. Pure
        constructor; performs no external call and changes no state outside the
        object it returns.
    .OUTPUTS
        A PSCustomObject with State, ExitCode, RunExistence, StepConclusion, and
        Instruction. ExitCode is 0 only for RESOLVED.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$State,
        [Parameter(Mandatory = $true)]
        [string]$RunExistence,
        [Parameter(Mandatory = $true)]
        [string]$StepConclusion
    )

    return [pscustomobject]@{
        State          = $State
        ExitCode       = $(if ($State -eq 'RESOLVED') { 0 } else { 1 })
        RunExistence   = $RunExistence
        StepConclusion = $StepConclusion
        Instruction    = (Get-RecoveryInstruction -State $State)
    }
}

function Get-CodexPinnedMcpVersion {
    <#
    .SYNOPSIS
        Reads the mcp-server version pinned in the npx argument array of a
        .codex/config.toml document. Pure function over an in-memory string that
        performs no filesystem access and opens no temporary file.
    .DESCRIPTION
        The content is a parameter rather than a disk read so the caller owns the
        single read and the function stays testable without a temporary file,
        which repo test policy prohibits outright. The pin appears in the
        exact-version form, so the version is whatever follows the at sign up to
        the closing quote.
    .OUTPUTS
        The pinned version string, or $null when the package is not pinned.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ConfigContent,
        [string]$PackageName = '@danmoisan/drm-copilot-mcp'
    )

    if ([string]::IsNullOrWhiteSpace($ConfigContent)) {
        return $null
    }

    $pattern = [regex]::Escape($PackageName) + '@([^"'']+)'
    $match = [regex]::Match($ConfigContent, $pattern)
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups[1].Value.Trim()
}
