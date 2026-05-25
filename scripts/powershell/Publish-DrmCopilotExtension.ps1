<#
.SYNOPSIS
    Build, validate, and publish the drm-copilot VS Code extension.

.DESCRIPTION
    Automates the publish workflow for extensions/drm-copilot/. Always runs
    pre-flight validation against the extension manifest. Modes:

      -DryRun    : Validate manifest and run vsce ls. No package, no publish.
      -Package   : Validate, build, and produce a timestamped .vsix in
                   artifacts/vsix/. No publish.
      -Publish   : Validate, build, package, and publish to the VS Code
                   Marketplace via vsce publish. Requires an authenticated
                   vsce session (run 'vsce login DanMoisan' once first).

    Default mode is -DryRun. The script never publishes unless -Publish is
    supplied explicitly.

.PARAMETER VersionBump
    Optional. One of patch | minor | major. If supplied, the version field
    in extensions/drm-copilot/package.json is incremented before packaging.
    Ignored in -DryRun mode.

.PARAMETER SkipBuild
    Skip the npm install + npm run compile steps. Useful when the extension
    is already built and you only want to repackage.

.PARAMETER Tag
    Optional git tag to create after a successful publish. Format: v<version>.

.EXAMPLE
    pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -DryRun

    Validates the manifest and lists files that would ship.

.EXAMPLE
    pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Package

    Produces a timestamped .vsix in artifacts/vsix/ for local testing.

.EXAMPLE
    pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Publish -VersionBump patch -Tag

    Bumps the patch version, builds, packages, publishes to Marketplace,
    and creates a v<new-version> git tag.

.NOTES
    Prerequisites for -Publish mode:
      1. Marketplace publisher 'DanMoisan' exists.
      2. PAT with Marketplace (Manage) scope obtained from Azure DevOps.
      3. 'vsce login DanMoisan' has been run successfully on this machine.
      4. The extension manifest contains all required fields (the script
         validates this and exits non-zero if any are missing).

    Marketplace versions are immutable. A published version cannot be
    republished or deleted, only unpublished. Confirm the version is correct
    before invoking -Publish.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'DryRun', Justification = 'Used indirectly via PSCmdlet.ParameterSetName.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Package', Justification = 'Used indirectly via PSCmdlet.ParameterSetName.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Publish', Justification = 'Used indirectly via PSCmdlet.ParameterSetName.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '', Justification = 'npm and vsce are external tools that require positional command arguments by convention.')]
[CmdletBinding(DefaultParameterSetName = 'DryRun')]
param(
    [Parameter(ParameterSetName = 'DryRun')]
    [switch]$DryRun,

    [Parameter(ParameterSetName = 'Package')]
    [switch]$Package,

    [Parameter(ParameterSetName = 'Publish')]
    [switch]$Publish,

    [ValidateSet('patch', 'minor', 'major')]
    [string]$VersionBump,

    [switch]$SkipBuild,

    [switch]$Tag
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

# ---------------------------------------------------------------------------
# Resolve paths.
# ---------------------------------------------------------------------------

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$ExtensionDir = Join-Path $RepoRoot 'extensions\drm-copilot'
$ManifestPath = Join-Path $ExtensionDir 'package.json'
$VsixOutDir = Join-Path $RepoRoot 'artifacts\vsix'

if (-not (Test-Path $ManifestPath)) {
    Write-Error "Extension manifest not found at $ManifestPath"
}

if (-not (Test-Path $VsixOutDir)) {
    New-Item -ItemType Directory -Path $VsixOutDir -Force | Out-Null
}

# Determine mode.
$Mode = $PSCmdlet.ParameterSetName
Write-Information "drm-copilot publish script — mode: $Mode"
Write-Information "Extension directory: $ExtensionDir"
Write-Information ""

# ---------------------------------------------------------------------------
# Verify vsce is available.
# ---------------------------------------------------------------------------

$VsceCmd = Get-Command vsce -ErrorAction SilentlyContinue
if ($null -eq $VsceCmd) {
    Write-Error "vsce is not on PATH. Install with: npm install -g @vscode/vsce"
}

# ---------------------------------------------------------------------------
# Manifest pre-flight validation.
# ---------------------------------------------------------------------------

Write-Information "[1/6] Validating manifest..."

$Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

$RequiredFields = @{
    'name'           = $Manifest.name
    'version'        = $Manifest.version
    'publisher'      = $Manifest.publisher
    'engines.vscode' = if ($Manifest.engines) { $Manifest.engines.vscode } else { $null }
    'main'           = $Manifest.main
    'displayName'    = $Manifest.displayName
    'description'    = $Manifest.description
}

$MissingFields = @()
foreach ($field in $RequiredFields.Keys) {
    if ([string]::IsNullOrWhiteSpace($RequiredFields[$field])) {
        $MissingFields += $field
    }
}

if ($MissingFields.Count -gt 0) {
    Write-Error "Manifest is missing required fields: $($MissingFields -join ', ')"
}

$RecommendedFields = @{
    'license'    = $Manifest.license
    'repository' = $Manifest.repository
    'categories' = $Manifest.categories
}

$MissingRecommended = @()
foreach ($field in $RecommendedFields.Keys) {
    $value = $RecommendedFields[$field]
    if ($null -eq $value -or ($value -is [string] -and [string]::IsNullOrWhiteSpace($value))) {
        $MissingRecommended += $field
    }
}

if ($MissingRecommended.Count -gt 0) {
    Write-Warning "Manifest is missing recommended fields: $($MissingRecommended -join ', ')"
}

$LicensePath = Join-Path $ExtensionDir 'LICENSE'
if (-not (Test-Path $LicensePath)) {
    Write-Warning "LICENSE file not found at $LicensePath. Marketplace listing will lack license attribution."
}

$ChangelogPath = Join-Path $ExtensionDir 'CHANGELOG.md'
if (-not (Test-Path $ChangelogPath)) {
    Write-Warning "CHANGELOG.md not found at $ChangelogPath. Marketplace will not display a changelog."
}

$ReadmePath = Join-Path $ExtensionDir 'README.md'
if (-not (Test-Path $ReadmePath)) {
    Write-Error "README.md not found at $ReadmePath. vsce requires a README."
}

Write-Information "  Publisher : $($Manifest.publisher)"
Write-Information "  Name      : $($Manifest.name)"
Write-Information "  Version   : $($Manifest.version)"
Write-Information "  Engine    : $($Manifest.engines.vscode)"
Write-Information "  Main      : $($Manifest.main)"
Write-Information ""

# ---------------------------------------------------------------------------
# Optional: bump version.
# ---------------------------------------------------------------------------

if ($VersionBump -and $Mode -ne 'DryRun') {
    Write-Information "[2/6] Bumping version ($VersionBump)..."
    Push-Location $ExtensionDir
    try {
        npm version $VersionBump --no-git-tag-version | Out-Null
    }
    finally {
        Pop-Location
    }
    $Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    Write-Information "  New version: $($Manifest.version)"
    Write-Information ""
}
else {
    Write-Information "[2/6] No version bump requested."
    Write-Information ""
}

# ---------------------------------------------------------------------------
# Build (npm install + npm run compile).
# ---------------------------------------------------------------------------

if (-not $SkipBuild) {
    Write-Information "[3/6] Building extension..."
    Push-Location $ExtensionDir
    try {
        if (-not (Test-Path (Join-Path $ExtensionDir 'node_modules'))) {
            Write-Information "  Running npm install..."
            npm install
            if ($LASTEXITCODE -ne 0) { Write-Error "npm install failed." }
        }
        Write-Information "  Running npm run compile..."
        npm run compile
        if ($LASTEXITCODE -ne 0) { Write-Error "npm run compile failed." }
    }
    finally {
        Pop-Location
    }
    Write-Information ""
}
else {
    Write-Information "[3/6] Build skipped (-SkipBuild)."
    Write-Information ""
}

# ---------------------------------------------------------------------------
# vsce ls — list files that would ship.
# ---------------------------------------------------------------------------

Write-Information "[4/6] Listing files to be packaged..."
Push-Location $ExtensionDir
try {
    $LsOutput = vsce ls 2>&1
    $FileCount = ($LsOutput | Measure-Object -Line).Lines
    Write-Information "  Files to ship: $FileCount"

    # Patterns that should never ship. resources/**/.claude/ is intentionally
    # bundled by this extension (it pushes those templates down to user repos),
    # so .claude/ outside resources/ is the only forbidden form.
    $Forbidden = $LsOutput | Select-String -Pattern '(^|/)\.git/|\.venv/|virtual/|pyproject\.toml|\.whl$|\.pyc$|\.pyo$|__pycache__|coverage\.xml|^artifacts/|^docs/|^memories/'
    $Forbidden += $LsOutput | Select-String -Pattern '\.claude/' | Where-Object { $_ -notmatch '^resources/' }
    if ($Forbidden) {
        Write-Warning "vsce ls flagged potentially unwanted files:"
        $Forbidden | ForEach-Object { Write-Information "    $_" }
    }
}
finally {
    Pop-Location
}
Write-Information ""

# ---------------------------------------------------------------------------
# Mode-specific actions.
# ---------------------------------------------------------------------------

if ($Mode -eq 'DryRun') {
    Write-Information "[5/6] Dry-run complete. No package or publish performed."
    Write-Information "[6/6] To produce a .vsix, re-run with -Package."
    Write-Information "      To publish, re-run with -Publish (irreversible)."
    return
}

# Build vsix output filename.
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$VsixName = "drm-copilot-$($Manifest.version)-$Timestamp.vsix"
$VsixPath = Join-Path $VsixOutDir $VsixName

Write-Information "[5/6] Packaging to $VsixPath..."
Push-Location $ExtensionDir
try {
    vsce package --out $VsixPath
    if ($LASTEXITCODE -ne 0) { Write-Error "vsce package failed." }
    $VsixInfo = Get-Item $VsixPath
    Write-Information "  Created: $($VsixInfo.Name)"
    Write-Information "  Size   : $([math]::Round($VsixInfo.Length / 1KB, 1)) KB"
}
finally {
    Pop-Location
}
Write-Information ""

if ($Mode -eq 'Package') {
    Write-Information "[6/6] Package complete. Install locally with:"
    Write-Information "      code --install-extension `"$VsixPath`""
    Write-Information "  Or for VS Code Insiders:"
    Write-Information "      code-insiders --install-extension `"$VsixPath`""
    return
}

# ---------------------------------------------------------------------------
# Publish mode.
# ---------------------------------------------------------------------------

Write-Information "[6/6] Publishing to VS Code Marketplace..."
Write-Information "  Publisher: $($Manifest.publisher)"
Write-Information "  Version  : $($Manifest.version)"
Write-Information ""
Write-Information "  Marketplace versions are IMMUTABLE. Confirm before continuing."
$confirmation = Read-Host "  Type the version number to confirm publish ($($Manifest.version))"
if ($confirmation -ne $Manifest.version) {
    Write-Error "Confirmation did not match version. Publish aborted."
}

Push-Location $ExtensionDir
try {
    vsce publish --packagePath $VsixPath
    if ($LASTEXITCODE -ne 0) { Write-Error "vsce publish failed." }
}
finally {
    Pop-Location
}

Write-Information ""
Write-Information "Publish complete."
Write-Information "Marketplace URL: https://marketplace.visualstudio.com/items?itemName=$($Manifest.publisher).$($Manifest.name)"

if ($Tag) {
    $TagName = "v$($Manifest.version)"
    Write-Information ""
    Write-Information "Creating git tag $TagName..."
    git tag -a $TagName -m "Release $TagName"
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "git tag failed. Tag the release manually if desired."
    }
    else {
        Write-Information "  Tag created. Push with: git push origin $TagName"
    }
}

