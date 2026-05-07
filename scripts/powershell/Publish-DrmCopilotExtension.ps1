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
Write-Host "drm-copilot publish script — mode: $Mode" -ForegroundColor Cyan
Write-Host "Extension directory: $ExtensionDir" -ForegroundColor DarkGray
Write-Host ""

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

Write-Host "[1/6] Validating manifest..." -ForegroundColor Cyan

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

Write-Host "  Publisher : $($Manifest.publisher)" -ForegroundColor Gray
Write-Host "  Name      : $($Manifest.name)" -ForegroundColor Gray
Write-Host "  Version   : $($Manifest.version)" -ForegroundColor Gray
Write-Host "  Engine    : $($Manifest.engines.vscode)" -ForegroundColor Gray
Write-Host "  Main      : $($Manifest.main)" -ForegroundColor Gray
Write-Host ""

# ---------------------------------------------------------------------------
# Optional: bump version.
# ---------------------------------------------------------------------------

if ($VersionBump -and $Mode -ne 'DryRun') {
    Write-Host "[2/6] Bumping version ($VersionBump)..." -ForegroundColor Cyan
    Push-Location $ExtensionDir
    try {
        npm version $VersionBump --no-git-tag-version | Out-Null
    }
    finally {
        Pop-Location
    }
    $Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    Write-Host "  New version: $($Manifest.version)" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host "[2/6] No version bump requested." -ForegroundColor DarkGray
    Write-Host ""
}

# ---------------------------------------------------------------------------
# Build (npm install + npm run compile).
# ---------------------------------------------------------------------------

if (-not $SkipBuild) {
    Write-Host "[3/6] Building extension..." -ForegroundColor Cyan
    Push-Location $ExtensionDir
    try {
        if (-not (Test-Path (Join-Path $ExtensionDir 'node_modules'))) {
            Write-Host "  Running npm install..." -ForegroundColor Gray
            npm install
            if ($LASTEXITCODE -ne 0) { Write-Error "npm install failed." }
        }
        Write-Host "  Running npm run compile..." -ForegroundColor Gray
        npm run compile
        if ($LASTEXITCODE -ne 0) { Write-Error "npm run compile failed." }
    }
    finally {
        Pop-Location
    }
    Write-Host ""
}
else {
    Write-Host "[3/6] Build skipped (-SkipBuild)." -ForegroundColor DarkGray
    Write-Host ""
}

# ---------------------------------------------------------------------------
# vsce ls — list files that would ship.
# ---------------------------------------------------------------------------

Write-Host "[4/6] Listing files to be packaged..." -ForegroundColor Cyan
Push-Location $ExtensionDir
try {
    $LsOutput = vsce ls 2>&1
    $FileCount = ($LsOutput | Measure-Object -Line).Lines
    Write-Host "  Files to ship: $FileCount" -ForegroundColor Gray

    # Patterns that should never ship. resources/**/.claude/ is intentionally
    # bundled by this extension (it pushes those templates down to user repos),
    # so .claude/ outside resources/ is the only forbidden form.
    $Forbidden = $LsOutput | Select-String -Pattern '(^|/)\.git/|\.venv/|virtual/|pyproject\.toml|\.whl$|\.pyc$|\.pyo$|__pycache__|coverage\.xml|^artifacts/|^docs/|^memories/'
    $Forbidden += $LsOutput | Select-String -Pattern '\.claude/' | Where-Object { $_ -notmatch '^resources/' }
    if ($Forbidden) {
        Write-Warning "vsce ls flagged potentially unwanted files:"
        $Forbidden | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    }
}
finally {
    Pop-Location
}
Write-Host ""

# ---------------------------------------------------------------------------
# Mode-specific actions.
# ---------------------------------------------------------------------------

if ($Mode -eq 'DryRun') {
    Write-Host "[5/6] Dry-run complete. No package or publish performed." -ForegroundColor Green
    Write-Host "[6/6] To produce a .vsix, re-run with -Package." -ForegroundColor Green
    Write-Host "      To publish, re-run with -Publish (irreversible)." -ForegroundColor Green
    return
}

# Build vsix output filename.
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$VsixName = "drm-copilot-$($Manifest.version)-$Timestamp.vsix"
$VsixPath = Join-Path $VsixOutDir $VsixName

Write-Host "[5/6] Packaging to $VsixPath..." -ForegroundColor Cyan
Push-Location $ExtensionDir
try {
    vsce package --out $VsixPath
    if ($LASTEXITCODE -ne 0) { Write-Error "vsce package failed." }
    $VsixInfo = Get-Item $VsixPath
    Write-Host "  Created: $($VsixInfo.Name)" -ForegroundColor Gray
    Write-Host "  Size   : $([math]::Round($VsixInfo.Length / 1KB, 1)) KB" -ForegroundColor Gray
}
finally {
    Pop-Location
}
Write-Host ""

if ($Mode -eq 'Package') {
    Write-Host "[6/6] Package complete. Install locally with:" -ForegroundColor Green
    Write-Host "      code --install-extension `"$VsixPath`"" -ForegroundColor Green
    Write-Host "  Or for VS Code Insiders:" -ForegroundColor Green
    Write-Host "      code-insiders --install-extension `"$VsixPath`"" -ForegroundColor Green
    return
}

# ---------------------------------------------------------------------------
# Publish mode.
# ---------------------------------------------------------------------------

Write-Host "[6/6] Publishing to VS Code Marketplace..." -ForegroundColor Cyan
Write-Host "  Publisher: $($Manifest.publisher)" -ForegroundColor Gray
Write-Host "  Version  : $($Manifest.version)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Marketplace versions are IMMUTABLE. Confirm before continuing." -ForegroundColor Yellow
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

Write-Host ""
Write-Host "Publish complete." -ForegroundColor Green
Write-Host "Marketplace URL: https://marketplace.visualstudio.com/items?itemName=$($Manifest.publisher).$($Manifest.name)" -ForegroundColor Green

if ($Tag) {
    $TagName = "v$($Manifest.version)"
    Write-Host ""
    Write-Host "Creating git tag $TagName..." -ForegroundColor Cyan
    git tag -a $TagName -m "Release $TagName"
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "git tag failed. Tag the release manually if desired."
    }
    else {
        Write-Host "  Tag created. Push with: git push origin $TagName" -ForegroundColor Gray
    }
}

