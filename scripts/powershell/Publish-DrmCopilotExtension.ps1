<#
.SYNOPSIS
    Build, validate, and locally package the drm-copilot VS Code extension.

.DESCRIPTION
    Provides the local-only modes for the extensions/drm-copilot/ extension.
    Always runs pre-flight validation against the extension manifest. Modes:

      -DryRun    : Validate manifest and run vsce ls. No package, no upload.
      -Package   : Validate, build, and produce a timestamped .vsix in
                   artifacts/vsix/. No upload.

    Default mode is -DryRun. This script never uploads to the VS Code
    Marketplace and never creates or pushes a release tag. Marketplace upload
    and release tagging are performed by CI: the tag-triggered workflow
    .github/workflows/publish-extension.yml runs the Marketplace upload against
    the tagged commit. The local responsibility of this script ends at
    producing a .vsix for inspection (-Package) and validating the manifest
    (-DryRun).

    External executable calls (npm, vsce) are isolated behind wrapper-function
    seams (Invoke-NpmExe, Invoke-VsceExe, Get-VsceListing) so Pester unit tests
    can mock them without invoking real npm/vsce or the network, per repo
    policy.

.PARAMETER SkipBuild
    Skip the npm install + npm run compile steps. Useful when the extension
    is already built and you only want to repackage.

.EXAMPLE
    pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -DryRun

    Validates the manifest and lists files that would ship.

.EXAMPLE
    pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Package

    Produces a timestamped .vsix in artifacts/vsix/ for local testing.

.NOTES
    Version bumping is a PR-gated source change (open a release PR via the
    "Release: Open ... Version-Bump PR" tasks). Marketplace upload and the
    v<version> release tag are performed by CI after the bump PR merges, not
    by this script.

    Marketplace versions are immutable. A published version cannot be
    republished or deleted, only unpublished.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'SkipBuild', Justification = 'Forwarded to Invoke-ExtensionPackage as a switch.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '', Justification = 'npm and vsce are external tools that require positional command arguments by convention.')]
[CmdletBinding(DefaultParameterSetName = 'DryRun')]
param(
    [Parameter(ParameterSetName = 'DryRun')]
    [switch]$DryRun,

    [Parameter(ParameterSetName = 'Package')]
    [switch]$Package,

    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

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

function Invoke-VsceExe {
    <#
    .SYNOPSIS
        Wrapper seam for invoking vsce. Exists so tests can mock the external
        call without executing real vsce. Splats the supplied argument array
        into vsce and returns the process exit code.
    .OUTPUTS
        The vsce process exit code.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$VsceArgs
    )
    & vsce @VsceArgs 2>&1 | Out-Host
    return $LASTEXITCODE
}

function Get-VsceListing {
    <#
    .SYNOPSIS
        Wrapper seam for `vsce ls`. Exists so tests can mock the file listing
        without executing real vsce. Returns the raw listing lines.
    .OUTPUTS
        The lines emitted by `vsce ls`.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    return (vsce ls 2>&1)
}

function Test-ExtensionManifest {
    <#
    .SYNOPSIS
        Validates the extension manifest. Pure read of the manifest JSON;
        performs no external executable call. Throws on a missing manifest or
        a missing required field; emits warnings for missing recommended files.
    .OUTPUTS
        The parsed manifest object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionDir
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Extension manifest not found at $ManifestPath"
    }

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json

    $requiredFields = @{
        'name'           = $manifest.name
        'version'        = $manifest.version
        'publisher'      = $manifest.publisher
        'engines.vscode' = if ($manifest.engines) { $manifest.engines.vscode } else { $null }
        'main'           = $manifest.main
        'displayName'    = $manifest.displayName
        'description'    = $manifest.description
    }

    $missingFields = @()
    foreach ($field in $requiredFields.Keys) {
        if ([string]::IsNullOrWhiteSpace($requiredFields[$field])) {
            $missingFields += $field
        }
    }

    if ($missingFields.Count -gt 0) {
        throw "Manifest is missing required fields: $($missingFields -join ', ')"
    }

    $recommendedFields = @{
        'license'    = $manifest.license
        'repository' = $manifest.repository
        'categories' = $manifest.categories
    }

    $missingRecommended = @()
    foreach ($field in $recommendedFields.Keys) {
        $value = $recommendedFields[$field]
        if ($null -eq $value -or ($value -is [string] -and [string]::IsNullOrWhiteSpace($value))) {
            $missingRecommended += $field
        }
    }

    if ($missingRecommended.Count -gt 0) {
        Write-Warning "Manifest is missing recommended fields: $($missingRecommended -join ', ')"
    }

    $licensePath = Join-Path $ExtensionDir 'LICENSE'
    if (-not (Test-Path $licensePath)) {
        Write-Warning "LICENSE file not found at $licensePath. Marketplace listing will lack license attribution."
    }

    $changelogPath = Join-Path $ExtensionDir 'CHANGELOG.md'
    if (-not (Test-Path $changelogPath)) {
        Write-Warning "CHANGELOG.md not found at $changelogPath. Marketplace will not display a changelog."
    }

    $readmePath = Join-Path $ExtensionDir 'README.md'
    if (-not (Test-Path $readmePath)) {
        throw "README.md not found at $readmePath. vsce requires a README."
    }

    return $manifest
}

function Get-ForbiddenPackagedFile {
    <#
    .SYNOPSIS
        Filters a `vsce ls` listing for files that must never ship. Pure
        function; performs no external call.
    .OUTPUTS
        The listing lines that match a forbidden pattern.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Listing
    )

    # resources/**/.claude/ is intentionally bundled by this extension (it
    # pushes those templates down to user repos), so .claude/ outside
    # resources/ is the only forbidden form.
    $forbidden = @($Listing | Select-String -Pattern '(^|/)\.git/|\.venv/|virtual/|pyproject\.toml|\.whl$|\.pyc$|\.pyo$|__pycache__|coverage\.xml|^artifacts/|^docs/|^memories/')
    $forbidden += @($Listing | Select-String -Pattern '\.claude/' | Where-Object { $_ -notmatch '^resources/' })
    return $forbidden
}

function Invoke-ExtensionPackage {
    <#
    .SYNOPSIS
        Runs the local package/dry-run workflow: validate the manifest,
        optionally build, run the `vsce ls` forbidden-file scan, and, in
        Package mode, produce a timestamped .vsix. Never uploads to the
        Marketplace and never tags.
    .OUTPUTS
        In Package mode, the .vsix path produced. In DryRun mode, $null.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('DryRun', 'Package')]
        [string]$Mode,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionDir,
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,
        [Parameter(Mandatory = $true)]
        [string]$VsixOutDir,
        [switch]$SkipBuild
    )

    Write-Information "drm-copilot package script - mode: $Mode"
    Write-Information "Extension directory: $ExtensionDir"
    Write-Information ""

    Write-Information "[1/5] Validating manifest..."
    $manifest = Test-ExtensionManifest -ManifestPath $ManifestPath -ExtensionDir $ExtensionDir
    Write-Information "  Publisher : $($manifest.publisher)"
    Write-Information "  Name      : $($manifest.name)"
    Write-Information "  Version   : $($manifest.version)"
    Write-Information ""

    if (-not $SkipBuild) {
        Write-Information "[2/5] Building extension..."
        Push-Location $ExtensionDir
        try {
            if (-not (Test-Path (Join-Path $ExtensionDir 'node_modules'))) {
                Write-Information "  Running npm install..."
                $installExit = Invoke-NpmExe -NpmArgs @('install')
                if ($installExit -ne 0) { throw "npm install failed." }
            }
            Write-Information "  Running npm run compile..."
            $compileExit = Invoke-NpmExe -NpmArgs @('run', 'compile')
            if ($compileExit -ne 0) { throw "npm run compile failed." }
        }
        finally {
            Pop-Location
        }
        Write-Information ""
    }
    else {
        Write-Information "[2/5] Build skipped (-SkipBuild)."
        Write-Information ""
    }

    Write-Information "[3/5] Listing files to be packaged..."
    Push-Location $ExtensionDir
    try {
        $lsOutput = Get-VsceListing
        $fileCount = ($lsOutput | Measure-Object -Line).Lines
        Write-Information "  Files to ship: $fileCount"
        $forbidden = Get-ForbiddenPackagedFile -Listing @($lsOutput)
        if ($forbidden) {
            Write-Warning "vsce ls flagged potentially unwanted files:"
            $forbidden | ForEach-Object { Write-Information "    $_" }
        }
    }
    finally {
        Pop-Location
    }
    Write-Information ""

    if ($Mode -eq 'DryRun') {
        Write-Information "[4/5] Dry-run complete. No package performed."
        Write-Information "[5/5] To produce a .vsix, re-run with -Package."
        Write-Information "      Marketplace upload and tagging are performed by CI after the version-bump PR merges."
        return $null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $vsixName = "drm-copilot-$($manifest.version)-$timestamp.vsix"
    $vsixPath = Join-Path $VsixOutDir $vsixName

    Write-Information "[4/5] Packaging to $vsixPath..."
    Push-Location $ExtensionDir
    try {
        $packageExit = Invoke-VsceExe -VsceArgs @('package', '--out', $vsixPath)
        if ($packageExit -ne 0) { throw "vsce package failed." }
    }
    finally {
        Pop-Location
    }
    Write-Information ""

    Write-Information "[5/5] Package complete. Install locally with:"
    Write-Information "      code --install-extension `"$vsixPath`""
    Write-Information "      Marketplace upload and the release tag are performed by CI"
    Write-Information "      (.github/workflows/publish-extension.yml) after the bump PR merges."
    return $vsixPath
}

# Entry point: skipped when the script is dot-sourced for testing.
if ($MyInvocation.InvocationName -ne '.') {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $extensionDir = Join-Path $repoRoot 'extensions\drm-copilot'
    $manifestPath = Join-Path $extensionDir 'package.json'
    $vsixOutDir = Join-Path $repoRoot 'artifacts\vsix'

    if (-not (Test-Path $vsixOutDir)) {
        New-Item -ItemType Directory -Path $vsixOutDir -Force | Out-Null
    }

    $vsceCmd = Get-Command vsce -ErrorAction SilentlyContinue
    if ($null -eq $vsceCmd) {
        Write-Error "vsce is not on PATH. Install with: npm install -g @vscode/vsce"
    }

    $mode = $PSCmdlet.ParameterSetName
    $null = $DryRun
    $null = $Package
    $null = Invoke-ExtensionPackage -Mode $mode -ExtensionDir $extensionDir -ManifestPath $manifestPath -VsixOutDir $vsixOutDir -SkipBuild:$SkipBuild
}
