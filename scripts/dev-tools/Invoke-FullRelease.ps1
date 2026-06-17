<#
.SYNOPSIS
    Task wrapper that gates a combined extension + mcp-server release behind an
    explicit confirmation token.

.DESCRIPTION
    Invoked by the VS Code task "Publish: Full Release (bump both + Marketplace
    + npm tag)". Exits non-zero unless -ConfirmToken equals the literal string
    'yes'. On confirmation, in one run:

      1. Patch-bumps the mcp-server manifest (packages/mcp-server/package.json)
         via npm with --no-git-tag-version (smallest increment, no git tag),
         then derives the post-bump version and the mcp-server-v<version> tag.
      2. Publishes the extension to the VS Code Marketplace by delegating to
         scripts/powershell/Publish-DrmCopilotExtension.ps1 with -Publish
         -VersionBump patch -Tag (the delegated script bumps the extension
         manifest's patch version). A non-zero publish exit code stops the run
         before the mcp-server tag is pushed.
      3. Creates and pushes the mcp-server-v<version> git tag, which fires the
         existing .github/workflows/publish-mcp-npm.yml workflow (tag-trigger
         model; no local npm token required).

    The wrapper exists so the task can use pwsh -File (no nested-quoting
    issues) instead of an inline -Command string. All external executable
    calls are isolated behind wrapper-function seams (Invoke-GitExe,
    Invoke-NpmExe, Invoke-PublishScript) so Pester unit tests can mock them
    without touching real git/npm or the network, per repo policy.

.PARAMETER ConfirmToken
    Must be the literal string 'yes' (case-sensitive) for the release to
    proceed. Any other value causes the wrapper to write an error and return
    exit code 2. Named -ConfirmToken (rather than -Confirm) to avoid collision
    with the PowerShell common parameter -Confirm. Marketplace and npm
    versions are immutable, so confirmation is required.

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
        into git and propagates the process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GitArgs
    )
    & git @GitArgs 2>&1 | Out-Host
    return $LASTEXITCODE
}

function Invoke-NpmExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking npm. Exists so tests can mock the external
        call without executing real npm. Splats the supplied argument array
        into npm and propagates the process exit code.
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

function Invoke-PublishScript {
    <#
    .SYNOPSIS
        Wrapper seam for invoking the underlying extension publish script.
        Exists so tests can mock the external call without executing the real
        publish. Returns the publish script's exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    & $ScriptPath -Publish -VersionBump patch -Tag
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

function Get-McpServerTagName {
    <#
    .SYNOPSIS
        Constructs the mcp-server git tag name from a version string. Pure
        function; performs no external call.
    .OUTPUTS
        The tag name in the form mcp-server-v<version>.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version
    )
    return "mcp-server-v$Version"
}

function Invoke-FullReleaseGuarded {
    <#
    .SYNOPSIS
        Validates the confirmation token and performs the combined release:
        mcp-server manifest patch bump, extension Marketplace publish, and
        mcp-server tag creation + push.
    .OUTPUTS
        Integer exit code: 0 on success; 1 on missing publish script or a
        failed git tag operation; 2 on missing confirmation; or the publish
        script's own non-zero exit code on publish failure.
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

    $publishScript = Join-Path -Path $RepoRoot -ChildPath 'scripts/powershell/Publish-DrmCopilotExtension.ps1'
    $mcpManifest = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server/package.json'
    $extensionManifest = Join-Path -Path $RepoRoot -ChildPath 'extensions/drm-copilot/package.json'
    $mcpServerDir = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server'

    if (-not (Test-Path -LiteralPath $publishScript)) {
        Write-StderrLine -Message "Publish script not found at '$publishScript'."
        return 1
    }

    # Step 1: patch-bump the mcp-server manifest (no git tag), then derive the
    # new version and the mcp-server-v<version> tag name.
    $bumpExit = Invoke-NpmExe -NpmArgs @('--prefix', $mcpServerDir, 'version', 'patch', '--no-git-tag-version')
    if ($bumpExit -ne 0) {
        Write-StderrLine -Message "mcp-server version bump failed (npm exit code $bumpExit)."
        return $bumpExit
    }

    $newMcpVersion = Get-NpmVersion -ManifestPath $mcpManifest
    $mcpTagName = Get-McpServerTagName -Version $newMcpVersion

    # Step 2: publish the extension via the delegated script (it patch-bumps
    # the extension manifest). Stop before the tag push on any failure.
    $publishExit = Invoke-PublishScript -ScriptPath $publishScript
    if ($publishExit -ne 0) {
        Write-StderrLine -Message "Extension publish failed (exit code $publishExit). mcp-server tag '$mcpTagName' was not pushed."
        return $publishExit
    }

    $null = $extensionManifest

    # Step 3: create and push the mcp-server tag to trigger the npm publish.
    $tagCreateExit = Invoke-GitExe -GitArgs @('tag', '-a', $mcpTagName, '-m', "mcp-server $newMcpVersion")
    if ($tagCreateExit -ne 0) {
        Write-StderrLine -Message "Failed to create git tag '$mcpTagName' (git exit code $tagCreateExit)."
        return 1
    }

    $tagPushExit = Invoke-GitExe -GitArgs @('push', 'origin', $mcpTagName)
    if ($tagPushExit -ne 0) {
        Write-StderrLine -Message "Failed to push git tag '$mcpTagName' (git exit code $tagPushExit)."
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
