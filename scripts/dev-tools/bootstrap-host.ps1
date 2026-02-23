#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Apply,

    [Parameter()]
    [switch]$EnableAutoResumeAfterReboot,

    [Parameter()]
    [string]$WorkspaceRoot,

    [Parameter()]
    [string]$RepoRoot,

    [Parameter()]
    [switch]$SkipProjectPoetryInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$helperScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "bootstrap-host.helpers.ps1"
if (-not (Test-Path -Path $helperScriptPath)) {
    throw "Bootstrap helper script not found at $helperScriptPath"
}

. $helperScriptPath

function Get-HostManifest {
    [CmdletBinding()]
    [OutputType([psobject])]
    param()

    $manifestPath = Join-Path -Path $PSScriptRoot -ChildPath "..\host-tools.manifest.json"
    if (-not (Test-Path $manifestPath)) {
        throw "Host tools manifest not found at $manifestPath"
    }

    return (Get-Content -Path $manifestPath -Raw | ConvertFrom-Json)
}

function Install-WithWinget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter()]
        [switch]$ApplyMode
    )

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Output "[OK] $Name already installed"
        return
    }

    if (-not $ApplyMode) {
        Write-Output "- Would install $Name using winget id '$Id'"
        return
    }

    Write-Output "Installing $Name ($Id)"

    try {
        Invoke-WingetExe -WingetArgs @(
            "install",
            "--id",
            $Id,
            "--exact",
            "--source",
            "winget",
            "--accept-source-agreements",
            "--accept-package-agreements"
        )
    }
    catch {
        if ($Name -eq "poetry") {
            Write-Output "[WARN] winget install for poetry failed; trying python -m pip install --user poetry"
            Install-PoetryWithPip -ApplyMode:$ApplyMode
            return
        }

        throw
    }
}

function Invoke-WingetExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$WingetArgs
    )

    winget @WingetArgs
    if ($LASTEXITCODE -ne 0) {
        throw "winget command failed with exit code $LASTEXITCODE"
    }
}

function Invoke-NpmExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NpmArgs
    )

    npm @NpmArgs
}

function Invoke-WslExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$WslArgs
    )

    wsl @WslArgs
    if ($LASTEXITCODE -ne 0) {
        throw "wsl command failed with exit code $LASTEXITCODE"
    }
}

function Invoke-VerifyHostScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    & $ScriptPath
}

function Invoke-PoetryExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PoetryArgs
    )

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        & $poetryCommand.Source @PoetryArgs
        if ($LASTEXITCODE -ne 0) {
            throw "poetry command failed with exit code $LASTEXITCODE"
        }

        return
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        throw "python is required to execute poetry"
    }

    & $pythonCommand.Source -m poetry @PoetryArgs
    if ($LASTEXITCODE -ne 0) {
        throw "python -m poetry failed with exit code $LASTEXITCODE"
    }
}

function Get-SessionPathFromMachineAndUser {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    [string[]]$pathParts = @(
        [System.Environment]::GetEnvironmentVariable("Path", "Machine"),
        [System.Environment]::GetEnvironmentVariable("Path", "User")
    ) | Where-Object { $_ }

    return ($pathParts -join ";")
}

function Add-DirectoryToUserPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath
    )

    if (-not (Test-Path $DirectoryPath)) {
        return
    }

    [string]$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    [string[]]$pathParts = @($userPath -split ";") | Where-Object { $_ }
    $alreadyPresent = $pathParts | Where-Object {
        $_.TrimEnd("\\").ToLower() -eq $DirectoryPath.TrimEnd("\\").ToLower()
    }

    if ($alreadyPresent) {
        return
    }

    $newUserPath = @($pathParts + $DirectoryPath) -join ";"
    [System.Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
}

function Install-PoetryWithPip {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$ApplyMode
    )

    if (Get-Command poetry -ErrorAction SilentlyContinue) {
        Write-Output "[OK] poetry already installed"
        return
    }

    if (-not $ApplyMode) {
        Write-Output "- Would install poetry using python -m pip install --user poetry"
        return
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        throw "python is required to install poetry fallback"
    }

    Write-Output "Installing poetry via python -m pip"
    & $pythonCommand.Source -m pip install --user poetry
    if ($LASTEXITCODE -ne 0) {
        throw "Poetry fallback install failed with exit code $LASTEXITCODE"
    }

    $poetryExecutable = Get-ChildItem -Path (Join-Path -Path $env:APPDATA -ChildPath "Python") -Recurse -Filter "poetry.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($poetryExecutable) {
        Add-DirectoryToUserPath -DirectoryPath $poetryExecutable.Directory.FullName
    }

    $sessionPath = Get-SessionPathFromMachineAndUser
    if ($sessionPath) {
        $env:Path = $sessionPath
    }
}

function Install-WslIfMissing {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$ApplyMode
    )

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Write-Output "[OK] wsl already installed"
        return
    }

    if (-not $ApplyMode) {
        Write-Output "- Would install WSL (requires elevation and may require reboot)"
        return
    }

    Write-Output "Installing WSL (requires elevation and may require reboot)"
    Invoke-WslExe -WslArgs @("--install", "--no-distribution")
}

function Get-WingetPackagesFromManifest {
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    $wingetPackages = @($Manifest.installPackages.windows.winget)
    if (-not $wingetPackages -or $wingetPackages.Count -eq 0) {
        throw "No Windows winget packages configured in host-tools.manifest.json (installPackages.windows.winget)."
    }

    return $wingetPackages
}

function Set-BootstrapResumeRunOnce {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$ResumeArguments = ""
    )

    $runOncePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    if (-not (Test-Path $runOncePath)) {
        New-Item -Path $runOncePath -Force | Out-Null
    }

    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "bootstrap-host.ps1"
    $command = "pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Apply -EnableAutoResumeAfterReboot $ResumeArguments"
    if ($PSCmdlet.ShouldProcess("$runOncePath\\DrmCopilotHostBootstrapResume", "Set RunOnce bootstrap resume command")) {
        New-ItemProperty -Path $runOncePath -Name "DrmCopilotHostBootstrapResume" -Value $command -PropertyType String -Force | Out-Null
    }
}

function Remove-BootstrapResumeRunOnce {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $runOncePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    if (-not (Test-Path $runOncePath)) {
        return
    }

    if ($PSCmdlet.ShouldProcess("$runOncePath\\DrmCopilotHostBootstrapResume", "Remove RunOnce bootstrap resume command")) {
        Remove-ItemProperty -Path $runOncePath -Name "DrmCopilotHostBootstrapResume" -ErrorAction SilentlyContinue
    }
}

function Invoke-BootstrapHost {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Apply,

        [Parameter()]
        [switch]$EnableAutoResumeAfterReboot,

        [Parameter()]
        [string]$WorkspaceRoot,

        [Parameter()]
        [string]$RepoRoot,

        [Parameter()]
        [switch]$SkipProjectPoetryInstall,

        [Parameter()]
        [bool]$IsWindowsHost = $IsWindows
    )

    Write-Output "========================================="
    Write-Output "Host Bootstrap (Windows)"
    Write-Output "========================================="

    if (-not $IsWindowsHost) {
        Write-Error "This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS."
        exit 1
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget is required on Windows. Install App Installer from Microsoft Store and rerun."
        exit 1
    }

    $resolvedWorkspaceRoot = Resolve-WorkspaceRoot -WorkspaceRootPath $WorkspaceRoot
    Write-Output "Workspace root: $resolvedWorkspaceRoot"
    Initialize-WorkspaceRoot -WorkspaceRootPath $resolvedWorkspaceRoot -ApplyMode:$Apply

    Install-WslIfMissing -ApplyMode:$Apply

    $manifest = Get-HostManifest
    $wingetPackages = Get-WingetPackagesFromManifest -Manifest $manifest
    $projects = Get-ProjectRepositoriesFromManifest -Manifest $manifest

    if ($Apply -and $EnableAutoResumeAfterReboot) {
        $resumeArgs = @()
        if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
            $resumeArgs += "-WorkspaceRoot `"$WorkspaceRoot`""
        }

        if (-not [string]::IsNullOrWhiteSpace($RepoRoot)) {
            $resumeArgs += "-RepoRoot `"$RepoRoot`""
        }

        if ($SkipProjectPoetryInstall) {
            $resumeArgs += "-SkipProjectPoetryInstall"
        }

        Set-BootstrapResumeRunOnce -ResumeArguments ($resumeArgs -join " ")
        Write-Output "[INFO] Registered one-time bootstrap resume after reboot."
    }

    Write-Output ""
    Write-Output "Installing required packages:"
    foreach ($pkg in $wingetPackages) {
        Install-WithWinget -Id $pkg.id -Name $pkg.name -ApplyMode:$Apply
    }

    $sessionPath = Get-SessionPathFromMachineAndUser
    if ($sessionPath) {
        $env:Path = $sessionPath
    }

    Write-Output ""
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        if ($Apply) {
            Write-Output "Installing Graphite CLI via npm"
            Invoke-NpmExe -NpmArgs @("install", "-g", "@withgraphite/graphite-cli@1.7.14")
        }
        else {
            Write-Output "- Would install Graphite CLI: npm install -g @withgraphite/graphite-cli@1.7.14"
        }
    }
    else {
        Write-Output "[WARN] npm not found; Graphite CLI install skipped"
    }

    if ($Apply) {
        Write-Output ""
        Write-Output "Installing PowerShell modules"
        foreach ($moduleSpec in $manifest.powershellModules) {
            Install-Module -Name $moduleSpec.name -RequiredVersion $moduleSpec.minimumVersion -Scope CurrentUser -AllowClobber -Force
        }

        Write-Output ""
        if ($projects.Count -gt 0) {
            Write-Output "Syncing project repositories from manifest"
            Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $resolvedWorkspaceRoot -ApplyMode
        }

        if (-not $SkipProjectPoetryInstall) {
            $projectRepoRoot = Resolve-ProjectRepoRoot -RepoRootPath $RepoRoot -WorkspaceRootPath $resolvedWorkspaceRoot -Projects $projects
            if ($projectRepoRoot -and (Test-Path -Path (Join-Path -Path $projectRepoRoot -ChildPath "pyproject.toml"))) {
                Write-Output ""
                Write-Output "Installing Python project dependencies via poetry in $projectRepoRoot"
                Push-Location -Path $projectRepoRoot
                try {
                    Invoke-PoetryExe -PoetryArgs @("install", "--no-interaction")
                }
                catch {
                    Write-Output "[WARN] Poetry dependency install failed; python quality tools may be unavailable"
                }
                finally {
                    Pop-Location
                }
            }
            else {
                Write-Output "[WARN] pyproject.toml not found; skipping poetry project install"
            }
        }
        else {
            Write-Output "[INFO] Skipping project poetry install by request"
        }
    }
    else {
        $modulePreview = $manifest.powershellModules |
            ForEach-Object { "$($_.name) $($_.minimumVersion)" } |
                Join-String -Separator ", "
        Write-Output "- Would install PowerShell modules: $modulePreview"

        if ($projects.Count -gt 0) {
            Write-Output "- Would sync project repositories to $resolvedWorkspaceRoot"
            Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $resolvedWorkspaceRoot
        }

        if (-not $SkipProjectPoetryInstall) {
            Write-Output "- Would install Python project dependencies via poetry"
        }
    }

    Write-Output ""
    if ($Apply) {
        Write-Output "GitHub Copilot CLI installation requires manual step on Windows."
        Write-Output "Install manually: https://gh.io/copilot-install"

        Write-Output ""
        Write-Output "Running host verification"
        $verifyScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "verify-host.ps1"
        if (Test-Path -Path $verifyScriptPath) {
            Invoke-VerifyHostScript -ScriptPath $verifyScriptPath
        }
        else {
            Write-Output "[WARN] verify-host.ps1 not found beside bootstrap-host.ps1; verification skipped"
        }

        if ($EnableAutoResumeAfterReboot) {
            Remove-BootstrapResumeRunOnce
            Write-Output "[INFO] Cleared one-time bootstrap resume entry."
        }
    }
    else {
        Write-Output "- Would install Copilot CLI from https://gh.io/copilot-install"
        Write-Output ""
        Write-Output "Dry run complete. Re-run with -Apply to install tools."
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-BootstrapHost -Apply:$Apply -EnableAutoResumeAfterReboot:$EnableAutoResumeAfterReboot -WorkspaceRoot $WorkspaceRoot -RepoRoot $RepoRoot -SkipProjectPoetryInstall:$SkipProjectPoetryInstall
}
