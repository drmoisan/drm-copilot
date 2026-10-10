<#
.SYNOPSIS
    Host bootstrap logic behind scripts/dev-tools/bootstrap-host.ps1 (issue #847).

.DESCRIPTION
    Holds the bootstrap orchestrator, the install, PATH, and RunOnce functions, and the
    named process wrappers. Host calls go through HostTooling.psm1 seams, the wrappers
    below, or cmdlets that tests mock with Mock -ModuleName HostBootstrap. The module
    contains no exit statement; the entry script owns the process exit code.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostTooling.psm1')
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostBootstrapWorkspace.psm1')

function Get-HostManifest {
    <#
    .SYNOPSIS
        Reads the host tools manifest and throws when it is absent.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param()

    $manifestPath = Get-HostToolsManifestPath
    $manifest = Read-HostToolsManifest -Path $manifestPath
    if ($null -eq $manifest) {
        throw "Host tools manifest not found at $manifestPath"
    }

    return $manifest
}

function Install-WithWinget {
    <#
    .SYNOPSIS
        Installs a package with winget in apply mode, with a pip fallback for poetry.
    #>
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
        Invoke-HostBootstrapWinget -WingetArgs @(
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

function Add-DirectoryToUserPath {
    <#
    .SYNOPSIS
        Appends an existing directory to the User Path when it is not already present.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath
    )

    if (-not (Test-Path $DirectoryPath)) {
        return
    }

    [string]$userPath = Get-HostEnvironmentVariable -Name 'Path' -Target 'User'
    [string[]]$pathParts = @($userPath -split ";") | Where-Object { $_ }
    $alreadyPresent = $pathParts | Where-Object {
        $_.TrimEnd("\\").ToLower() -eq $DirectoryPath.TrimEnd("\\").ToLower()
    }

    if ($alreadyPresent) {
        return
    }

    $newUserPath = @($pathParts + $DirectoryPath) -join ";"
    Set-HostEnvironmentVariable -Name 'Path' -Value $newUserPath -Target 'User'
}

function Install-PoetryWithPip {
    <#
    .SYNOPSIS
        Installs poetry with python -m pip in apply mode and refreshes the session Path.
    #>
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
    $pipResult = Invoke-HostNativeCommand -FilePath $pythonCommand.Source -ArgumentList @('-m', 'pip', 'install', '--user', 'poetry')
    $pipResult.Output
    if ($pipResult.ExitCode -ne 0) {
        throw "Poetry fallback install failed with exit code $($pipResult.ExitCode)"
    }

    $appDataPath = Get-HostEnvironmentVariable -Name 'APPDATA' -Target 'Process'
    $poetryExecutable = Get-ChildItem -Path (Join-Path -Path $appDataPath -ChildPath "Python") -Recurse -Filter "poetry.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($poetryExecutable) {
        Add-DirectoryToUserPath -DirectoryPath $poetryExecutable.Directory.FullName
    }

    $sessionPath = Get-SessionPathFromMachineAndUser
    if ($sessionPath) {
        Set-HostEnvironmentVariable -Name 'Path' -Value $sessionPath -Target 'Process'
    }
}

function Install-WslIfMissing {
    <#
    .SYNOPSIS
        Installs WSL in apply mode when the wsl command is missing.
    #>
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
    Invoke-HostBootstrapWsl -WslArgs @("--install", "--no-distribution")
}

function Get-WingetPackagesFromManifest {
    <#
    .SYNOPSIS
        Returns the Windows winget packages of the manifest and throws when none exist.
    #>
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

function Get-BootstrapResumeArgument {
    <#
    .SYNOPSIS
        Builds the argument string passed to the RunOnce bootstrap resume command.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$WorkspaceRoot,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$RepoRoot,

        [Parameter()]
        [switch]$SkipProjectPoetryInstall
    )

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

    return ($resumeArgs -join " ")
}

function Set-BootstrapResumeRunOnce {
    <#
    .SYNOPSIS
        Registers the one-time RunOnce bootstrap resume command.
    #>
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
    <#
    .SYNOPSIS
        Removes the one-time RunOnce bootstrap resume command when the key exists.
    #>
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

function Install-HostPowerShellModule {
    <#
    .SYNOPSIS
        Installs a PowerShell module at the required version for the current user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$RequiredVersion
    )

    Install-Module -Name $Name -RequiredVersion $RequiredVersion -Scope CurrentUser -AllowClobber -Force
}

function Invoke-BootstrapHost {
    <#
    .SYNOPSIS
        Runs the host bootstrap: dry run by default, installs and syncs with -Apply.
    #>
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
        Write-Error -Message 'This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.' -ErrorAction Stop
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error -Message 'winget is required on Windows. Install App Installer from Microsoft Store and rerun.' -ErrorAction Stop
    }

    $resolvedWorkspaceRoot = Resolve-WorkspaceRoot -WorkspaceRootPath $WorkspaceRoot
    Write-Output "Workspace root: $resolvedWorkspaceRoot"
    Initialize-WorkspaceRoot -WorkspaceRootPath $resolvedWorkspaceRoot -ApplyMode:$Apply

    Install-WslIfMissing -ApplyMode:$Apply

    $manifest = Get-HostManifest
    $wingetPackages = Get-WingetPackagesFromManifest -Manifest $manifest
    $projects = Get-ProjectRepositoriesFromManifest -Manifest $manifest

    if ($Apply -and $EnableAutoResumeAfterReboot) {
        $resumeArguments = Get-BootstrapResumeArgument -WorkspaceRoot $WorkspaceRoot -RepoRoot $RepoRoot -SkipProjectPoetryInstall:$SkipProjectPoetryInstall
        Set-BootstrapResumeRunOnce -ResumeArguments $resumeArguments
        Write-Output "[INFO] Registered one-time bootstrap resume after reboot."
    }

    Write-Output ""
    Write-Output "Installing required packages:"
    foreach ($pkg in $wingetPackages) {
        Install-WithWinget -Id $pkg.id -Name $pkg.name -ApplyMode:$Apply
    }

    $sessionPath = Get-SessionPathFromMachineAndUser
    if ($sessionPath) {
        Set-HostEnvironmentVariable -Name 'Path' -Value $sessionPath -Target 'Process'
    }

    Write-Output ""
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        if ($Apply) {
            Write-Output "Installing Graphite CLI via npm"
            Invoke-HostBootstrapNpm -NpmArgs @("install", "-g", "@withgraphite/graphite-cli@1.7.14")
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
            Install-HostPowerShellModule -Name $moduleSpec.name -RequiredVersion $moduleSpec.minimumVersion
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
                    Invoke-HostBootstrapPoetry -PoetryArgs @("install", "--no-interaction")
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
            Invoke-HostBootstrapVerifyScript -ScriptPath $verifyScriptPath
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

Export-ModuleMember -Function Invoke-BootstrapHost, Get-HostManifest, Install-WithWinget, Install-PoetryWithPip, Install-WslIfMissing, Add-DirectoryToUserPath, Get-WingetPackagesFromManifest, Get-BootstrapResumeArgument, Set-BootstrapResumeRunOnce, Remove-BootstrapResumeRunOnce, Install-HostPowerShellModule
