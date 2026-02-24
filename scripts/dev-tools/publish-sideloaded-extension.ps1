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

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "RepoRoot does not exist: $RepoRoot"
}

$packageJsonPath = Join-Path $RepoRoot "package.json"
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
    if ($PSCmdlet.ShouldProcess($RepoRoot, "npm ci")) {
        Invoke-NpmCiWithRetry -WorkingDirectory $RepoRoot -ForceCleanup:$Force
    }
}

if (-not $SkipCompile) {
    if ($PSCmdlet.ShouldProcess($RepoRoot, "npm run compile")) {
        Invoke-ExternalCommand -FilePath "npm" -ArgumentList @("run", "compile") -WorkingDirectory $RepoRoot
    }
}

if ($PSCmdlet.ShouldProcess($RepoRoot, "npx vsce package")) {
    Invoke-ExternalCommand -FilePath "npx" -ArgumentList @("--yes", "@vscode/vsce", "package", "--allow-missing-repository", "--skip-license", "--out", $vsixPath) -WorkingDirectory $RepoRoot
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
