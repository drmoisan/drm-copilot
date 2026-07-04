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
      4. Waits for GitHub checks through gh and merges only after gh reports
         checks success.
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
        A hashtable with keys Output (string[]) and ExitCode (int).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
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
        A hashtable with keys Output (string[]) and ExitCode (int).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
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

    $checks = Invoke-GhExe -GhArgs @('pr', 'checks', $prNumber, '--watch')
    if ($checks.ExitCode -ne 0) {
        Write-StderrLine -Message "Pull request checks did not pass for PR #$prNumber (gh exit code $($checks.ExitCode)). Stopping before merge and tag push."
        return 1
    }

    $merge = Invoke-GhExe -GhArgs @('pr', 'merge', $prNumber, '--merge', '--delete-branch')
    if ($merge.ExitCode -ne 0) {
        Write-StderrLine -Message "Pull request merge failed for PR #$prNumber (gh exit code $($merge.ExitCode)). Stopping before checkout, pull, and tag push."
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
