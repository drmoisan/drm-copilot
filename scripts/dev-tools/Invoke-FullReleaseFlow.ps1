<#
.SYNOPSIS
    Runs the full release flow behind an explicit confirmation token.

.DESCRIPTION
    Invoked by the VS Code task "Release: Automate Full Release Flow". Exits
    non-zero unless -ConfirmToken equals the literal string 'yes'. On
    confirmation, in one run:

      1. Verifies a clean working tree, current branch main, and local main at
         origin/main.
      2. Invokes scripts/dev-tools/Invoke-FullRelease.ps1 to open the release
         version-bump PR.
      3. Resolves the release branch and pull request number.
      4. Waits through gh for every GitHub check on the pull request head,
         merges only after every reported check passed or was skipped, and
         waits until the merge is confirmed (issue #952).
      5. Checks out main, pulls origin main, and invokes
         scripts/dev-tools/Invoke-ReleaseTagPush.ps1.

    The existing release scripts remain authoritative for version bumping and
    release tag creation. External calls are isolated behind wrapper-function
    seams so Pester tests can mock git, gh, and child PowerShell script
    invocation without touching live executables or the network.

.PARAMETER ConfirmToken
    Must be the literal string 'yes' (case-sensitive) for the flow to proceed.

.PARAMETER RepoRoot
    Repository root. Defaults to the parent of the scripts directory.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken yes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfirmToken,

    [Parameter()]
    [string]$RepoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

# The pure check-poll helpers live in a sibling file so this script stays under
# the 500-line cap. Dot-sourcing through $PSScriptRoot also resolves them when a
# Pester suite dot-sources this script.
. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.CheckHelpers.ps1')

# The merge-confirmation wait (issue #952) lives in a second sibling file,
# which also loads the shared merge-state parser.
. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.MergeWait.ps1')

function Write-StderrLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    [Console]::Error.WriteLine($Message)
}

function ConvertTo-CommandResult {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [object[]]$Output,

        [Parameter(Mandatory = $true)]
        [int]$ExitCode
    )

    return [pscustomobject]@{ Output = $Output; ExitCode = $ExitCode }
}

function Invoke-GitExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking git.
    .OUTPUTS
        A pscustomobject with properties Output (object[]) and ExitCode (int), built by ConvertTo-CommandResult.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GitArgs
    )
    $output = @(& git @GitArgs 2>&1)
    return ConvertTo-CommandResult -Output $output -ExitCode $LASTEXITCODE
}

function Invoke-GhExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking gh.
    .OUTPUTS
        A pscustomobject with properties Output (object[]) and ExitCode (int), built by ConvertTo-CommandResult.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GhArgs
    )
    $output = @(& gh @GhArgs 2>&1)
    return ConvertTo-CommandResult -Output $output -ExitCode $LASTEXITCODE
}

function Invoke-ChildPowerShellScript {
    <#
    .SYNOPSIS
        Wrapper seam for invoking child PowerShell scripts.
    .OUTPUTS
        The child pwsh process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter()]
        [string[]]$ScriptArguments = @()
    )
    & pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @ScriptArguments 2>&1 | Out-Host
    return $LASTEXITCODE
}

function Invoke-Sleep {
    <#
    .SYNOPSIS
        Wrapper seam for pausing execution.
    .DESCRIPTION
        Isolates Start-Sleep behind a mockable function so Pester tests can
        assert on wait behavior (poll counts, retry intervals) without
        incurring a real wall-clock delay.
    .PARAMETER Seconds
        Number of seconds to sleep.
    .OUTPUTS
        None.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Seconds
    )
    Start-Sleep -Seconds $Seconds
}

function Get-FirstOutputLine {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Output
    )

    foreach ($line in $Output) {
        $text = ([string]$line).Trim()
        if (-not [string]::IsNullOrWhiteSpace($text)) {
            return $text
        }
    }

    return ''
}

function Wait-ForPullRequestChecks {
    <#
    .SYNOPSIS
        Waits for every check on a pull request head to register and complete.
    .DESCRIPTION
        Polls `gh pr checks <PrNumber> --json bucket` through the Invoke-GhExe
        seam in two bounded phases.
        The poll queries every check on the pull request head, whether or not branch protection requires it.

        Phase A (registration): GitHub takes several seconds to register
        workflow checks after a pull request is opened. While the poll
        command fails with the gh error text 'no checks reported', the check
        set has not yet registered; this phase retries up to
        RegistrationMaxAttempts times, sleeping RegistrationIntervalSeconds
        between attempts, before declaring a registration timeout. Any other
        poll failure, such as a gh authentication or network error, returns 1
        at once without sleeping.

        Phase B (completion): once the poll succeeds, its JSON output is
        parsed into an array of check objects with a `bucket` property; an
        unparsable first result returns 1. If any bucket is 'fail' or
        'cancel', the function returns 1 immediately. If any check reports a
        bucket outside 'pass', 'skipping', 'pending', 'fail', and 'cancel', or
        has no bucket property, the function returns 1. If any bucket is
        'pending', or no check is reported, the function sleeps
        CompletionIntervalSeconds and re-polls, up to CompletionMaxAttempts
        times, before declaring a completion timeout; a re-poll that fails or
        cannot be parsed consumes an attempt and counts as an empty set. The
        function returns 0 only when at least one check is reported and every
        bucket is 'pass' or 'skipping'.
    .PARAMETER PrNumber
        The pull request number to poll checks for.
    .PARAMETER RegistrationMaxAttempts
        Maximum number of registration-phase poll attempts before timing out.
    .PARAMETER RegistrationIntervalSeconds
        Seconds to sleep between registration-phase poll attempts.
    .PARAMETER CompletionMaxAttempts
        Maximum number of completion-phase poll attempts before timing out.
    .PARAMETER CompletionIntervalSeconds
        Seconds to sleep between completion-phase poll attempts.
    .OUTPUTS
        Integer: 0 when at least one check is reported and every bucket is
        pass or skipping; 1 on a gh poll failure other than an unregistered
        check set, registration timeout, completion timeout, an unparsable
        result, an unrecognized bucket, or a failing or cancelled check.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function name matches the gh CLI concept of the set of checks on a pull request (plural); the plan contract for issue #310 binds this exact name.')]
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PrNumber,

        [Parameter()]
        [int]$RegistrationMaxAttempts = 24,

        [Parameter()]
        [int]$RegistrationIntervalSeconds = 5,

        [Parameter()]
        [int]$CompletionMaxAttempts = 120,

        [Parameter()]
        [int]$CompletionIntervalSeconds = 10
    )

    $ghArgs = @('pr', 'checks', $PrNumber, '--json', 'bucket')
    $poll = Invoke-GhExe -GhArgs $ghArgs

    $registrationAttempt = 1
    while ($poll.ExitCode -ne 0) {
        if (-not (Test-UnregisteredCheckPollOutput -Output $poll.Output)) {
            Write-StderrLine -Message "Could not query the checks for PR #$PrNumber (gh exit code $($poll.ExitCode))."
            return 1
        }
        if ($registrationAttempt -ge $RegistrationMaxAttempts) {
            Write-StderrLine -Message "Pull request checks did not register within the timeout for PR #$PrNumber."
            return 1
        }
        Invoke-Sleep -Seconds $RegistrationIntervalSeconds
        $poll = Invoke-GhExe -GhArgs $ghArgs
        $registrationAttempt++
    }

    $parsed = ConvertFrom-CheckPollOutput -Output $poll.Output
    if (-not $parsed.Succeeded) {
        Write-StderrLine -Message "Could not parse the check results for PR #$PrNumber."
        return 1
    }
    $checks = $parsed.Checks

    $completionAttempt = 1
    while ($true) {
        $verdict = Get-CheckSetVerdict -Checks $checks
        if ($verdict.Verdict -ceq 'fail') {
            Write-StderrLine -Message "A check failed for PR #$PrNumber."
            return 1
        }

        if ($verdict.Verdict -ceq 'unknown') {
            $value = $verdict.Detail
            Write-StderrLine -Message "A check reported an unrecognized bucket for PR #${PrNumber}: ${value}."
            return 1
        }

        if ($verdict.Verdict -ceq 'pass') {
            return 0
        }

        if ($completionAttempt -ge $CompletionMaxAttempts) {
            Write-StderrLine -Message "Pull request checks did not complete within the timeout for PR #$PrNumber."
            return 1
        }

        Invoke-Sleep -Seconds $CompletionIntervalSeconds
        $poll = Invoke-GhExe -GhArgs $ghArgs
        $checks = @()
        if ($poll.ExitCode -eq 0) {
            $parsed = ConvertFrom-CheckPollOutput -Output $poll.Output
            if ($parsed.Succeeded) {
                $checks = $parsed.Checks
            }
        }
        $completionAttempt++
    }
}

function Invoke-FullReleaseFlowGuarded {
    <#
    .SYNOPSIS
        Validates release preconditions, opens and merges the release PR, then
        invokes the post-merge release tag push script.
    .OUTPUTS
        Integer exit code: 0 on success; 1 on preflight, PR, checks, merge,
        checkout, pull, or tag-push failure; 2 on missing confirmation.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfirmToken,

        [Parameter(Mandatory = $true)]
        [string]$RepoRoot
    )

    if ($ConfirmToken -cne 'yes') {
        Write-StderrLine -Message "Automated full release flow not confirmed (got '$ConfirmToken'). Re-run the task and select 'yes' to proceed."
        return 2
    }

    $status = Invoke-GitExe -GitArgs @('status', '--porcelain')
    if ($status.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to read git status (git exit code $($status.ExitCode))."
        return 1
    }

    $statusText = ($status.Output -join "`n").Trim()
    if (-not [string]::IsNullOrWhiteSpace($statusText)) {
        Write-StderrLine -Message "Working tree is not clean. Commit or stash changes before running the automated full release flow."
        return 1
    }

    $currentBranchResult = Invoke-GitExe -GitArgs @('branch', '--show-current')
    if ($currentBranchResult.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to read current git branch (git exit code $($currentBranchResult.ExitCode))."
        return 1
    }

    $currentBranch = Get-FirstOutputLine -Output $currentBranchResult.Output
    if ($currentBranch -cne 'main') {
        Write-StderrLine -Message "Automated full release flow must start from branch 'main'. Current branch is '$currentBranch'."
        return 1
    }

    $fetch = Invoke-GitExe -GitArgs @('fetch', 'origin', 'main')
    if ($fetch.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to fetch origin/main (git exit code $($fetch.ExitCode))."
        return 1
    }

    $localMain = Invoke-GitExe -GitArgs @('rev-parse', 'main')
    if ($localMain.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to resolve local main (git exit code $($localMain.ExitCode))."
        return 1
    }

    $originMain = Invoke-GitExe -GitArgs @('rev-parse', 'origin/main')
    if ($originMain.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to resolve origin/main (git exit code $($originMain.ExitCode))."
        return 1
    }

    $localMainSha = Get-FirstOutputLine -Output $localMain.Output
    $originMainSha = Get-FirstOutputLine -Output $originMain.Output
    if ($localMainSha -cne $originMainSha) {
        Write-StderrLine -Message "Local main is not up to date with origin/main. Pull or reconcile main before running the automated full release flow."
        return 1
    }

    $fullReleaseScript = Join-Path -Path $RepoRoot -ChildPath 'scripts/dev-tools/Invoke-FullRelease.ps1'
    $fullReleaseExit = Invoke-ChildPowerShellScript -ScriptPath $fullReleaseScript -ScriptArguments @('-ConfirmToken', $ConfirmToken)
    if ($fullReleaseExit -ne 0) {
        Write-StderrLine -Message "Full release PR script failed (exit code $fullReleaseExit)."
        return 1
    }

    $releaseBranchResult = Invoke-GitExe -GitArgs @('branch', '--show-current')
    if ($releaseBranchResult.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to read release branch after opening the PR (git exit code $($releaseBranchResult.ExitCode))."
        return 1
    }

    $releaseBranch = Get-FirstOutputLine -Output $releaseBranchResult.Output
    if ([string]::IsNullOrWhiteSpace($releaseBranch) -or $releaseBranch -ceq 'main') {
        Write-StderrLine -Message "Release branch could not be determined after full release PR script completed."
        return 1
    }

    $prView = Invoke-GhExe -GhArgs @('pr', 'view', $releaseBranch, '--json', 'number', '--jq', '.number')
    if ($prView.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to resolve pull request for release branch '$releaseBranch' (gh exit code $($prView.ExitCode))."
        return 1
    }

    $prNumber = Get-FirstOutputLine -Output $prView.Output
    if ([string]::IsNullOrWhiteSpace($prNumber)) {
        Write-StderrLine -Message "gh returned no pull request number for release branch '$releaseBranch'."
        return 1
    }

    $checksResult = Wait-ForPullRequestChecks -PrNumber $prNumber
    if ($checksResult -ne 0) {
        return 1
    }

    $merge = Invoke-GhExe -GhArgs @('pr', 'merge', $prNumber, '--merge')
    if ($merge.ExitCode -ne 0) {
        Write-StderrLine -Message "Pull request merge failed for PR #$prNumber (gh exit code $($merge.ExitCode)). Stopping before checkout, pull, and tag push."
        return 1
    }

    # A merge queue makes gh pr merge return before the merge happens (issue #952).
    $mergeWait = Wait-ForPullRequestMerged -PrNumber $prNumber
    if ($mergeWait -ne 0) {
        return 1
    }

    $checkout = Invoke-GitExe -GitArgs @('checkout', 'main')
    if ($checkout.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to checkout main after merge (git exit code $($checkout.ExitCode)). Stopping before tag push."
        return 1
    }

    $pull = Invoke-GitExe -GitArgs @('pull', 'origin', 'main')
    if ($pull.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to pull merged main from origin (git exit code $($pull.ExitCode)). Stopping before tag push."
        return 1
    }

    $tagPushScript = Join-Path -Path $RepoRoot -ChildPath 'scripts/dev-tools/Invoke-ReleaseTagPush.ps1'
    $tagPushExit = Invoke-ChildPowerShellScript -ScriptPath $tagPushScript -ScriptArguments @('-ConfirmToken', $ConfirmToken)
    if ($tagPushExit -ne 0) {
        Write-StderrLine -Message "Release tag push script failed (exit code $tagPushExit)."
        return 1
    }

    return 0
}

# Entry point: skipped when the script is dot-sourced for testing.
if ($MyInvocation.InvocationName -ne '.') {
    $exitCode = Invoke-FullReleaseFlowGuarded -ConfirmToken $ConfirmToken -RepoRoot $RepoRoot
    exit $exitCode
}
