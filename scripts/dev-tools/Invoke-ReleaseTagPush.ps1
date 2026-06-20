<#
.SYNOPSIS
    Post-merge task that pushes the release tags behind an explicit confirmation
    token.

.DESCRIPTION
    Invoked by the VS Code task "Release: Push Release Tags (post-merge)" after
    a version-bump PR has merged to main. Exits non-zero unless -ConfirmToken
    equals the literal string 'yes'. On confirmation, in one run:

      1. Updates local main from origin (git pull origin main).
      2. Reads the merged versions from both committed manifests
         (extensions/drm-copilot/package.json and
         packages/mcp-server/package.json).
      3. Derives the tags v<ext-version> and mcp-server-v<mcp-version>.
      4. Creates and pushes both tags to origin, which fires the CI publish
         workflows (publish-extension.yml and publish-mcp-npm.yml).

    This is the only task that pushes a release tag. It performs no version
    bump and no Marketplace/npm upload; publishing happens in CI against the
    tagged commits.

    All external executable calls are isolated behind a wrapper-function seam
    (Invoke-GitExe) so Pester unit tests can mock it without touching real git
    or the network, per repo policy.

.PARAMETER ConfirmToken
    Must be the literal string 'yes' (case-sensitive) for the tag push to
    proceed. Any other value causes the wrapper to write an error and return
    exit code 2. Named -ConfirmToken (rather than -Confirm) to avoid collision
    with the PowerShell common parameter -Confirm.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-ReleaseTagPush.ps1 -ConfirmToken yes
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

function Get-ExtensionTagName {
    <#
    .SYNOPSIS
        Constructs the extension git tag name from a version string. Pure
        function; performs no external call.
    .OUTPUTS
        The tag name in the form v<version>.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version
    )
    return "v$Version"
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

function Invoke-ReleaseTagPushGuarded {
    <#
    .SYNOPSIS
        Validates the confirmation token and pushes the release tags: update
        main, read the merged manifest versions, then create and push both
        v<ext-version> and mcp-server-v<mcp-version> tags. Performs no version
        bump and no upload.
    .OUTPUTS
        Integer exit code: 0 on success; 1 on a missing manifest or a failed
        git seam; 2 on missing confirmation.
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
        Write-StderrLine -Message "Release tag push not confirmed (got '$ConfirmToken'). Re-run the task and select 'yes' to proceed."
        return 2
    }

    $extensionManifest = Join-Path -Path $RepoRoot -ChildPath 'extensions/drm-copilot/package.json'
    $mcpManifest = Join-Path -Path $RepoRoot -ChildPath 'packages/mcp-server/package.json'

    if (-not (Test-Path -LiteralPath $extensionManifest)) {
        Write-StderrLine -Message "Extension manifest not found at '$extensionManifest'."
        return 1
    }
    if (-not (Test-Path -LiteralPath $mcpManifest)) {
        Write-StderrLine -Message "mcp-server manifest not found at '$mcpManifest'."
        return 1
    }

    # Step 1: update local main so the tags point at the merged commit.
    $pull = Invoke-GitExe -GitArgs @('pull', 'origin', 'main')
    if ($pull.ExitCode -ne 0) {
        Write-StderrLine -Message "Failed to update main from origin (git exit code $($pull.ExitCode))."
        return 1
    }

    # Step 2: read the merged versions from both manifests.
    $extVersion = Get-NpmVersion -ManifestPath $extensionManifest
    $mcpVersion = Get-NpmVersion -ManifestPath $mcpManifest

    # Step 3: derive both tag names.
    $extTag = Get-ExtensionTagName -Version $extVersion
    $mcpTag = Get-McpServerTagName -Version $mcpVersion

    # Step 4: create and push both tags.
    foreach ($entry in @(
            @{ Tag = $extTag; Message = "Release $extTag" },
            @{ Tag = $mcpTag; Message = "mcp-server $mcpVersion" }
        )) {
        $create = Invoke-GitExe -GitArgs @('tag', '-a', $entry.Tag, '-m', $entry.Message)
        if ($create.ExitCode -ne 0) {
            Write-StderrLine -Message "Failed to create git tag '$($entry.Tag)' (git exit code $($create.ExitCode))."
            return 1
        }
        $push = Invoke-GitExe -GitArgs @('push', 'origin', $entry.Tag)
        if ($push.ExitCode -ne 0) {
            Write-StderrLine -Message "Failed to push git tag '$($entry.Tag)' (git exit code $($push.ExitCode))."
            return 1
        }
    }

    return 0
}

# Entry point: skipped when the script is dot-sourced for testing.
if ($MyInvocation.InvocationName -ne '.') {
    $resolvedRepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $exitCode = Invoke-ReleaseTagPushGuarded -ConfirmToken $ConfirmToken -RepoRoot $resolvedRepoRoot
    exit $exitCode
}
