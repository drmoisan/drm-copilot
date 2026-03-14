<#
.SYNOPSIS
Packages the VS Code extension into a VSIX and installs it locally (side-loaded).

.DESCRIPTION
This script is intended for development workflows where you want to install the
extension into your local VS Code without publishing to the Marketplace.

It performs, in order:
- (Optional) npm ci
- (Optional) npm run compile
- npx vsce package (writes a VSIX)
- (Optional) code --install-extension <vsix> --force

All state-changing actions are gated behind ShouldProcess so you can use -WhatIf.

.NOTES
- Requires Node.js + npm.
- Requires VS Code CLI "code" (or "code-insiders") on PATH for installation.
- Uses "npx vsce" so you do not need a global vsce install.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,

    [Parameter()]
    [AllowEmptyString()]
    [string]$CodeCommand = "",

    [Parameter()]
    [switch]$UseInsiders,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$VsixOutputDir = (Join-Path $RepoRoot "artifacts\vsix"),

    [Parameter()]
    [switch]$SkipNpmCi,

    [Parameter()]
    [switch]$SkipCompile,

    [Parameter()]
    [switch]$SkipInstall,

    [Parameter()]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path -Path $PSScriptRoot -ChildPath 'vscode-cli.helpers.ps1')

function Get-PackageManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageJsonPath
    )

    if (-not (Test-Path -LiteralPath $PackageJsonPath)) {
        throw "package.json not found: $PackageJsonPath"
    }

    try {
        $manifestJson = Get-Content -LiteralPath $PackageJsonPath -Raw
        return ($manifestJson | ConvertFrom-Json)
    } catch {
        throw "Failed to parse package.json at '$PackageJsonPath': $($_.Exception.Message)"
    }
}

function Test-IsVsCodeExtensionManifest {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Manifest
    )

    if ($Manifest.PSObject.Properties.Match("engines").Count -eq 0) {
        return $false
    }

    $engines = $Manifest.engines
    if ($null -eq $engines -or $engines.PSObject.Properties.Match("vscode").Count -eq 0) {
        return $false
    }

    $vscodeEngineVersion = $engines.vscode
    return -not [string]::IsNullOrWhiteSpace([string]$vscodeEngineVersion)
}

function Resolve-ExtensionProjectRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoRoot,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RelativeExtensionPath = "extensions\drm-copilot"
    )

    $joinProjectPath = {
        param(
            [string]$BasePath,
            [string]$ChildPath
        )

        $usesPosixSeparators = $BasePath.Contains('/') -and -not $BasePath.Contains('\\')
        if (-not $usesPosixSeparators) {
            return Join-Path $BasePath $ChildPath
        }

        $normalizedBasePath = $BasePath.TrimEnd([char[]]@('/', '\'))
        $normalizedChildPath = $ChildPath -replace '\\', '/'
        return '{0}/{1}' -f $normalizedBasePath, $normalizedChildPath.TrimStart('/')
    }

    $repoPackageJsonPath = & $joinProjectPath $RepoRoot "package.json"
    $repoManifest = Get-PackageManifest -PackageJsonPath $repoPackageJsonPath
    if (Test-IsVsCodeExtensionManifest -Manifest $repoManifest) {
        return $RepoRoot
    }

    $extensionProjectRoot = & $joinProjectPath $RepoRoot $RelativeExtensionPath
    $extensionPackageJsonPath = & $joinProjectPath $extensionProjectRoot "package.json"

    if (Test-Path -LiteralPath $extensionPackageJsonPath) {
        $extensionManifest = Get-PackageManifest -PackageJsonPath $extensionPackageJsonPath
        if (Test-IsVsCodeExtensionManifest -Manifest $extensionManifest) {
            return $extensionProjectRoot
        }
    }

    throw "Could not find a VS Code extension manifest with 'engines.vscode'. Checked: $repoPackageJsonPath, $extensionPackageJsonPath"
}

function Invoke-ExternalCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [string[]]$ArgumentList = @(),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$WorkingDirectory
    )

    $displayArgs = $ArgumentList -join " "
    Write-Verbose ("Running: {0} {1}" -f $FilePath, $displayArgs)

    # Build the full command line for cmd /c execution.
    # This avoids PowerShell call-operator parsing issues with external tools.
    $cmdLine = if ($ArgumentList.Count -gt 0) {
        "{0} {1}" -f $FilePath, $displayArgs
    } else {
        $FilePath
    }

    $processParams = @{
        FilePath         = "cmd.exe"
        ArgumentList     = @("/c", $cmdLine)
        WorkingDirectory = $WorkingDirectory
        Wait             = $true
        NoNewWindow      = $true
        PassThru         = $true
    }

    $process = Start-Process @processParams
    if ($process.ExitCode -ne 0) {
        $message = "Command failed with exit code {0}: {1} {2}" -f $process.ExitCode, $FilePath, $displayArgs
        $exception = [System.Exception]::new($message)
        $exception.Data["ExitCode"] = $process.ExitCode
        $exception.Data["FilePath"] = $FilePath
        $exception.Data["Arguments"] = $displayArgs
        throw $exception
    }
}

function Invoke-NpmCiWithRetry {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkingDirectory,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$MaxAttempts = 3,

        [Parameter()]
        [ValidateRange(1, 60)]
        [int]$DelaySeconds = 5,

        [Parameter()]
        [switch]$ForceCleanup
    )

    function Stop-NodeProcess {
        [CmdletBinding(SupportsShouldProcess = $true)]
        param()

        $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
        if (-not $nodeProcesses) {
            return
        }

        foreach ($process in $nodeProcesses) {
            if ($PSCmdlet.ShouldProcess($process.ProcessName, "Stop-Process")) {
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            }
        }
    }

    $attempt = 1
    while ($true) {
        try {
            Invoke-ExternalCommand -FilePath "npm" -ArgumentList @("ci") -WorkingDirectory $WorkingDirectory
            return
        } catch {
            $exitCode = $null
            if ($_.Exception.Data.Contains("ExitCode")) {
                $exitCode = $_.Exception.Data["ExitCode"]
            }

            $message = $_.Exception.Message
            $isEperm = ($exitCode -eq -4048) -or ($message -match "EPERM") -or ($message -match "operation not permitted")
            if (-not $isEperm -or $attempt -ge $MaxAttempts) {
                throw
            }

            Write-Warning ("npm ci failed with EPERM (attempt {0}/{1}). Retrying after {2}s." -f $attempt, $MaxAttempts, $DelaySeconds)

            if ($ForceCleanup) {
                if ($PSCmdlet.ShouldProcess($WorkingDirectory, "Stop node.exe processes")) {
                    Stop-NodeProcess
                }

                $nodeModulesPath = Join-Path $WorkingDirectory "node_modules"
                if (Test-Path -LiteralPath $nodeModulesPath) {
                    if ($PSCmdlet.ShouldProcess($nodeModulesPath, "Remove-Item -Recurse -Force")) {
                        Remove-Item -LiteralPath $nodeModulesPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }

                if ($PSCmdlet.ShouldProcess($WorkingDirectory, "npm cache clean --force")) {
                    Invoke-ExternalCommand -FilePath "npm" -ArgumentList @("cache", "clean", "--force") -WorkingDirectory $WorkingDirectory
                }
            }

            # Backoff between retries to allow file locks to clear.
            Start-Sleep -Seconds ($DelaySeconds * $attempt)
            $attempt += 1
        }
    }
}

function Invoke-ProjectCompile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectRoot
    )

    $manifestPath = Join-Path $ProjectRoot "package.json"
    $manifest = Get-PackageManifest -PackageJsonPath $manifestPath

    $hasCompileScript = $false
    if ($manifest.PSObject.Properties.Match("scripts").Count -gt 0 -and $null -ne $manifest.scripts) {
        $scripts = $manifest.scripts
        if ($scripts.PSObject.Properties.Match("compile").Count -gt 0) {
            $hasCompileScript = -not [string]::IsNullOrWhiteSpace([string]$scripts.compile)
        }
    }

    if ($hasCompileScript) {
        Invoke-ExternalCommand -FilePath "npm" -ArgumentList @("run", "compile") -WorkingDirectory $ProjectRoot
        return
    }

    $tsConfigPath = Join-Path $ProjectRoot "tsconfig.json"
    if (Test-Path -LiteralPath $tsConfigPath) {
        Invoke-ExternalCommand -FilePath "npx" -ArgumentList @("--yes", "tsc", "-p", "./") -WorkingDirectory $ProjectRoot
        return
    }

    Write-Verbose ("Skipping compile for '{0}' because no npm compile script or tsconfig.json was found." -f $ProjectRoot)
}

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "RepoRoot does not exist: $RepoRoot"
}

$extensionProjectRoot = Resolve-ExtensionProjectRoot -RepoRoot $RepoRoot

$packageJsonPath = Join-Path $extensionProjectRoot "package.json"
if (-not (Test-Path -LiteralPath $packageJsonPath)) {
    throw "package.json not found at RepoRoot: $packageJsonPath"
}

if (-not (Test-Path -LiteralPath $VsixOutputDir)) {
    if ($PSCmdlet.ShouldProcess($VsixOutputDir, 'Create output directory')) {
        New-Item -ItemType Directory -Path $VsixOutputDir -Force | Out-Null
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$vsixPath = Join-Path $VsixOutputDir ("drm-copilot-{0}.vsix" -f $timestamp)

if (-not $SkipNpmCi) {
    if ($PSCmdlet.ShouldProcess($extensionProjectRoot, "npm ci")) {
        Invoke-NpmCiWithRetry -WorkingDirectory $extensionProjectRoot -ForceCleanup:$Force
    }
}

if (-not $SkipCompile) {
    if ($PSCmdlet.ShouldProcess($extensionProjectRoot, "compile extension project")) {
        Invoke-ProjectCompile -ProjectRoot $extensionProjectRoot
    }
}

if ($PSCmdlet.ShouldProcess($extensionProjectRoot, "npx vsce package")) {
    Invoke-ExternalCommand -FilePath "npx" -ArgumentList @("--yes", "@vscode/vsce", "package", "--allow-missing-repository", "--skip-license", "--out", $vsixPath) -WorkingDirectory $extensionProjectRoot
}

if (-not (Test-Path -LiteralPath $vsixPath)) {
    throw "VSIX was not created as expected: $vsixPath"
}

if (-not $SkipInstall) {
    $hasExplicitCodeCommand = $PSBoundParameters.ContainsKey('CodeCommand')
    $preferredCodeCommand = if ($hasExplicitCodeCommand) { $CodeCommand } else { $null }
    $resolvedCodeCommand = Resolve-VSCodeCliCommand -PreferredCommand $preferredCodeCommand -PreferInsiders:$UseInsiders
    if (-not $resolvedCodeCommand) {
        throw "Could not find a VS Code CLI command on PATH (expected 'code' or 'code-insiders')."
    }

    $CodeCommand = $resolvedCodeCommand

    $installArgs = @("--install-extension", $vsixPath)
    if ($Force) {
        $installArgs += "--force"
    }

    if ($PSCmdlet.ShouldProcess($vsixPath, ("{0} --install-extension" -f $CodeCommand))) {
        Invoke-ExternalCommand -FilePath $CodeCommand -ArgumentList $installArgs -WorkingDirectory $RepoRoot
    }
}

Write-Information ("VSIX created: {0}" -f $vsixPath) -InformationAction Continue
if ($SkipInstall) {
    Write-Information "Install skipped (rerun without -SkipInstall to install)." -InformationAction Continue
}

# Make the VSIX path easy to consume from other scripts (e.g., piping or capture).
Write-Output $vsixPath
