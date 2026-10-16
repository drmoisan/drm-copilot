<#
.SYNOPSIS
    Merge-confirmation wait for scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (issue #952).

.DESCRIPTION
    Defines Wait-ForPullRequestMerged. It lives in this sibling file so that
    scripts/dev-tools/Invoke-FullReleaseFlow.ps1 stays under the 500-line cap.
    This file declares no entry-point block and is dot-sourced by
    scripts/dev-tools/Invoke-FullReleaseFlow.ps1. Wait-ForPullRequestMerged calls
    the Invoke-GhExe, Invoke-Sleep, and Write-StderrLine seams that the release
    script defines, so Pester tests mock them without touching gh or the clock.
#>

# Merge-state parser shared with the orchestration procedures; dot-sourcing defines
# Invoke-MergeConfirmationParser without running it.
. (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1')

function Wait-ForPullRequestMerged {
    <#
    .SYNOPSIS
        Waits until a pull request's merge is confirmed (issue #952).
    .DESCRIPTION
        Under a merge queue gh pr merge exits 0 after it enqueues the pull request, so a zero exit
        does not prove a merge. Reads the pull-request state through gh api graphql (Invoke-GhExe
        seam) and classifies each snapshot with Invoke-MergeConfirmationParser. Polls at most
        floor(TimeoutSeconds / PollIntervalSeconds) + 1 times and calls Invoke-Sleep between
        consecutive polls, never after the last one. Without a queue the first poll reports merged.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER PollIntervalSeconds
        Seconds between polls.
    .PARAMETER TimeoutSeconds
        Total wait budget in seconds (5400 is 90 minutes).
    .OUTPUTS
        Integer: 0 when the merge is confirmed; 1 on a read failure, an unclassifiable snapshot, a
        closed or not-queued pull request, or timeout. Each 1 writes one stderr line.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PrNumber,

        [Parameter()]
        [ValidateRange(1, 86400)]
        [int]$PollIntervalSeconds = 30,

        [Parameter()]
        [ValidateRange(1, 86400)]
        [int]$TimeoutSeconds = 5400
    )

    $query = 'query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}'
    $ghArgs = @('api', 'graphql', '-f', "query=$query", '-F', 'owner={owner}', '-F', 'name={repo}', '-F', "number=$PrNumber", '--jq', '.data.repository.pullRequest')
    $stop = 'Stopping before checkout, pull, and tag push.'
    $maxPolls = [int][Math]::Floor($TimeoutSeconds / $PollIntervalSeconds) + 1

    for ($poll = 1; $poll -le $maxPolls; $poll++) {
        if ($poll -gt 1) {
            Invoke-Sleep -Seconds $PollIntervalSeconds
        }

        $result = Invoke-GhExe -GhArgs $ghArgs
        if ($result.ExitCode -ne 0) {
            Write-StderrLine -Message "Failed to read merge state for PR #$PrNumber (gh exit code $($result.ExitCode)). $stop"
            return 1
        }

        try {
            $state = Invoke-MergeConfirmationParser -PrJson ($result.Output -join "`n")
        }
        catch {
            Write-StderrLine -Message "Merge state for PR #$PrNumber could not be classified: $($_.Exception.Message) $stop"
            return 1
        }

        switch ($state.Status) {
            'merged' { return 0 }
            'closed' {
                Write-StderrLine -Message "PR #$PrNumber was closed without merging. $stop"
                return 1
            }
            'not_queued' {
                Write-StderrLine -Message "PR #$PrNumber is open but neither merged nor queued; it was removed from the merge queue or never enqueued. $stop"
                return 1
            }
        }
    }

    Write-StderrLine -Message "PR #$PrNumber did not merge within $TimeoutSeconds seconds and is still awaiting the merge queue. $stop"
    return 1
}
