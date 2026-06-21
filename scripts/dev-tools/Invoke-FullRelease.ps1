<#
.SYNOPSIS
    Task wrapper that opens a full release version-bump PR behind an explicit
    confirmation token.

.DESCRIPTION
    Invoked by the VS Code task "Release: Open Full Version-Bump PR". Exits
    non-zero unless -ConfirmToken equals the literal string 'yes'. On
    confirmation, in one run:

      1. Verifies a clean working tree (git status --porcelain). A non-empty
         status blocks the run with a reported error and a non-zero exit.
      2. Creates a release branch from the current HEAD.
      3. Patch-bumps both manifests (extensions/drm-copilot/package.json and
         packages/mcp-server/package.json) via npm with --no-git-tag-version
         (smallest increment; npm does not create a tag).
      4. Commits the bumped manifests on the release branch.
      5. Pushes the release branch to origin so the PR has a remote ref.
      6. Opens a PR against main via gh pr create.

    This task never publishes and never pushes a release tag. Marketplace
    upload and npm publish are performed by CI after the bump PR merges and the
    post-merge tag-push task (Invoke-ReleaseTagPush.ps1) pushes the release
    tags.

    All external executable calls are isolated behind wrapper-function seams
    (Invoke-GitExe, Invoke-NpmExe, Invoke-GhExe) so Pester unit tests can mock
    them without touching real git/npm/gh or the network, per repo policy.

.PARAMETER ConfirmToken
    Must be the literal string 'yes' (case-sensitive) for the PR opener to
    proceed. Any other value causes the wrapper to write an error and return
    exit code 2. Named -ConfirmToken (rather than -Confirm) to avoid collision
    with the PowerShell common parameter -Confirm.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-FullRelease.ps1 -ConfirmToken yes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfirmToken
)

function Write-StderrLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    [Console]::Error.WriteLine($Message)
}

function Invoke-GitExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking git. Exists so tests can mock the external
        call without executing real git. Splats the supplied argument array
        into git and returns the captured output plus exit code.
    .OUTPUTS
        A hashtable with keys Output (string[]) and ExitCode (int).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GitArgs
    )
    $output = & git @GitArgs 2>&1
    return @{ Output = @($output); ExitCode = $LASTEXITCODE }
}

function Invoke-NpmExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking npm. Exists so tests can mock the external
        call without executing real npm. Splats the supplied argument array
        into npm and returns the process exit code.
    .OUTPUTS
        The npm process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NpmArgs
    )
    & npm @NpmArgs 2>&1 | Out-Host
    return $LASTEXITCODE
}

function Invoke-GhExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking gh. Exists so tests can mock the external
        call without executing real gh. Splats the supplied argument array
        into gh and returns the process exit code.
    .OUTPUTS
        The gh process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GhArgs
    )
    & gh @GhArgs 2>&1 | Out-Host
    return $LASTEXITCODE
}

function Get-NpmVersion {
    <#
    .SYNOPSIS
        Reads the version field from a package.json manifest by JSON parse.
        Pure read; performs no external executable call.
    .OUTPUTS
        The version string from the manifest.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest not found at '$ManifestPath'."
    }

    $raw = Get-Content -LiteralPath $ManifestPath -Raw
    $manifest = $raw | ConvertFrom-Json

    $version = $manifest.version
    if ([string]::IsNullOrWhiteSpace($version)) {
        throw "Manifest '$ManifestPath' has no 'version' field."
    }

    return [string]$version
}

function Get-ReleaseBranchName {
    <#
    .SYNOPSIS
        Constructs a release branch name from a label and a UTC timestamp.
        Pure function; performs no external call.
    .OUTPUTS
        The branch name in the form release/<Label>-<yyyyMMddHHmmss>.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [datetime]$Now
    )
    return "release/$Label-$($Now.ToString('yyyyMMddHHmmss'))"
}

function Invoke-FullReleaseGuarded {
    <#
    .SYNOPSIS
        Validates the confirmation token and opens a full release PR: verify a
        clean tree, create a release branch, patch-bump both manifests, commit,
        and open a PR against main. Never publishes and never tags.
    .OUTPUTS
        Integer exit code: 0 on success; 1 on a missing manifest, a dirty tree,
        or a failed git/gh seam; 2 on missing confirmation; or the npm bump
        exit code on a failed version bump.
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
        Write-StderrLine -Message "Full release not confirmed (got '$ConfirmToken'). Re-run the task and select 'yes' to proceed."
        return 2
    }

    $extensionManifest = Join-Path -Path $RepoRoot -ChildPath 'extensions/drm-copilot/package.json'
    $mcpManifest = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server/package.json'
    $extensionLockfile = Join-Path -Path $RepoRoot -ChildPath 'extensions/drm-copilot/package-lock.json'
    $mcpLockfile = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server/package-lock.json'
    $extensionDir = Join-Path -Path $RepoRoot -ChildPath 'extensions/drm-copilot'
    $mcpServerDir = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server'

    if (-not (Test-Path -LiteralPath $extensionManifest)) {
        Write-StderrLine -Message "Extension manifest not found at '$extensionManifest'."
        return 1
    }
    if (-not (Test-Path -LiteralPath $mcpManifest)) {
        Write-StderrLine -Message "mcp-server manifest not found at '$mcpManifest'."
        return 1
    }

    # Step 1: verify a clean working tree. Non-empty porcelain output blocks.
    $status = Invoke-GitExe -GitArgs @('status', '--porcelain')
    if ($status.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to read git status (git exit code $($status.ExitCode))."
        return 1
    }
    $statusText = ($status.Output -join "`n").Trim()
    if (-not [string]::IsNullOrWhiteSpace($statusText)) {
        Write-StderrLine -Message "Working tree is not clean. Commit or stash changes before opening a release PR."
        return 1
    }

    # Step 2: create a release branch.
    $branchName = Get-ReleaseBranchName -Label 'full' -Now ([datetime]::UtcNow)
    $branch = Invoke-GitExe -GitArgs @('checkout', '-b', $branchName)
    if ($branch.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to create release branch '$branchName' (git exit code $($branch.ExitCode))."
        return 1
    }

    # Step 3: patch-bump both manifests (npm does not create a tag).
    $extBumpExit = Invoke-NpmExe -NpmArgs @('--prefix', $extensionDir, 'version', 'patch', '--no-git-tag-version')
    if ($extBumpExit -ne 0) {
        Write-StderrLine -Message "Extension version bump failed (npm exit code $extBumpExit)."
        return $extBumpExit
    }
    $mcpBumpExit = Invoke-NpmExe -NpmArgs @('--prefix', $mcpServerDir, 'version', 'patch', '--no-git-tag-version')
    if ($mcpBumpExit -ne 0) {
        Write-StderrLine -Message "mcp-server version bump failed (npm exit code $mcpBumpExit)."
        return $mcpBumpExit
    }

    $newExtVersion = Get-NpmVersion -ManifestPath $extensionManifest
    $newMcpVersion = Get-NpmVersion -ManifestPath $mcpManifest

    # Step 4: commit the bumped manifests and their lockfiles. npm version
    # (npm 7+) updates both package.json and package-lock.json, so all four
    # files must be staged or the lockfile changes are left uncommitted.
    $add = Invoke-GitExe -GitArgs @('add', $extensionManifest, $mcpManifest, $extensionLockfile, $mcpLockfile)
    if ($add.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to stage bumped manifests (git exit code $($add.ExitCode))."
        return 1
    }
    $commitMessage = "release: bump extension to $newExtVersion and mcp-server to $newMcpVersion"
    $commit = Invoke-GitExe -GitArgs @('commit', '-m', $commitMessage)
    if ($commit.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to commit bumped manifests (git exit code $($commit.ExitCode))."
        return 1
    }

    # Step 5: publish the release branch so gh pr create has a remote ref.
    $push = Invoke-GitExe -GitArgs @('push', '-u', 'origin', $branchName)
    if ($push.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to push release branch '$branchName' to origin (git exit code $($push.ExitCode))."
        return 1
    }

    # Step 6: open a PR against main.
    $prTitle = "release: bump extension $newExtVersion and mcp-server $newMcpVersion"
    $prBody = "Automated full release version-bump PR. Extension -> $newExtVersion, mcp-server -> $newMcpVersion. Merge to main, then run the post-merge tag-push task to publish."
    $prExit = Invoke-GhExe -GhArgs @('pr', 'create', '--base', 'main', '--head', $branchName, '--title', $prTitle, '--body', $prBody)
    if ($prExit -ne 0) {
        Write-StderrLine -Message "Failed to open release PR (gh exit code $prExit)."
        return 1
    }

    return 0
}

# Entry point: skipped when the script is dot-sourced for testing.
if ($MyInvocation.InvocationName -ne '.') {
    $resolvedRepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $exitCode = Invoke-FullReleaseGuarded -ConfirmToken $ConfirmToken -RepoRoot $resolvedRepoRoot
    exit $exitCode
}
