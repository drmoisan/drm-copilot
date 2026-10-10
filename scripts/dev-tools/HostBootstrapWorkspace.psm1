<#
.SYNOPSIS
    Workspace and project-repository functions for the host bootstrap (issue #847).

.DESCRIPTION
    Holds the workspace-root resolution, workspace creation, project clone, and project
    repository root resolution used by HostBootstrap.psm1, plus the named process
    wrappers (git, winget, npm, wsl, poetry, and the verify script), which live here
    under the HostBootstrap size contingency of the #847 plan. Host calls go through
    HostTooling.psm1 seams or cmdlets that tests mock with
    Mock -ModuleName HostBootstrapWorkspace.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostTooling.psm1')

function Invoke-HostBootstrapGit {
    <#
    .SYNOPSIS
        Runs git with the given arguments and throws when git reports a nonzero code.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GitArgs
    )

    $result = Invoke-HostNativeCommand -FilePath 'git' -ArgumentList $GitArgs
    $result.Output
    if ($result.ExitCode -ne 0) {
        throw "git command failed with exit code $($result.ExitCode)"
    }
}

function Get-ProjectRepositoriesFromManifest {
    <#
    .SYNOPSIS
        Returns the projectRepositories entries of the manifest, or an empty list.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    if (-not $Manifest.PSObject.Properties.Name.Contains("projectRepositories")) {
        return @()
    }

    return @($Manifest.projectRepositories)
}

function Resolve-WorkspaceRoot {
    <#
    .SYNOPSIS
        Resolves the workspace root from the given path or the current location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$WorkspaceRootPath
    )

    if ([string]::IsNullOrWhiteSpace($WorkspaceRootPath)) {
        return (Get-Location).Path
    }

    return [System.IO.Path]::GetFullPath($WorkspaceRootPath)
}

function Initialize-WorkspaceRoot {
    <#
    .SYNOPSIS
        Creates the workspace root directory in apply mode, or reports the planned action.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRootPath,

        [Parameter()]
        [switch]$ApplyMode
    )

    if (Test-Path -Path $WorkspaceRootPath) {
        Write-Output "[OK] Workspace root exists: $WorkspaceRootPath"
        return
    }

    if (-not $ApplyMode) {
        Write-Output "- Would create workspace root: $WorkspaceRootPath"
        return
    }

    New-Item -Path $WorkspaceRootPath -ItemType Directory -Force | Out-Null
    Write-Output "[OK] Created workspace root: $WorkspaceRootPath"
}

function Sync-ProjectsFromManifest {
    <#
    .SYNOPSIS
        Clones each manifest project repository that is not yet present in the workspace.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Projects,

        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRootPath,

        [Parameter()]
        [switch]$ApplyMode
    )

    foreach ($project in $Projects) {
        $hasUrl = $project.PSObject.Properties.Name.Contains("url")
        if (-not $hasUrl -or [string]::IsNullOrWhiteSpace([string]$project.url)) {
            throw "Each projectRepositories entry must include a non-empty 'url'."
        }

        $targetPath = ""
        if ($project.PSObject.Properties.Name.Contains("targetPath")) {
            $targetPath = [string]$project.targetPath
        }

        if (-not $targetPath) {
            $targetPath = [System.IO.Path]::GetFileNameWithoutExtension([string]$project.url)
        }

        $clonePath = Join-Path -Path $WorkspaceRootPath -ChildPath $targetPath
        if (Test-Path -Path $clonePath) {
            Write-Output "[OK] Project already present: $clonePath"
            continue
        }

        if (-not $ApplyMode) {
            Write-Output "- Would clone $($project.url) to $clonePath"
            continue
        }

        Write-Output "Cloning $($project.url) into $clonePath"
        Invoke-HostBootstrapGit -GitArgs @("clone", [string]$project.url, $clonePath)
    }
}

function Resolve-ProjectRepoRoot {
    <#
    .SYNOPSIS
        Resolves the repository root used for the poetry project install.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$RepoRootPath,

        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRootPath,

        [Parameter(Mandatory = $true)]
        [object[]]$Projects
    )

    if (-not [string]::IsNullOrWhiteSpace($RepoRootPath)) {
        return [System.IO.Path]::GetFullPath($RepoRootPath)
    }

    $defaultRepoRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath "..\.."))
    if (Test-Path -Path (Join-Path -Path $defaultRepoRoot -ChildPath "pyproject.toml")) {
        return $defaultRepoRoot
    }

    $drmProject = $Projects | Where-Object { $_.name -eq "drm-copilot" } | Select-Object -First 1
    if ($drmProject) {
        $drmTargetPath = if ($drmProject.targetPath) { [string]$drmProject.targetPath } else { "drm-copilot" }
        return [System.IO.Path]::GetFullPath((Join-Path -Path $WorkspaceRootPath -ChildPath $drmTargetPath))
    }

    return ""
}

function Invoke-HostBootstrapWinget {
    <#
    .SYNOPSIS
        Runs winget with the given arguments and throws on a nonzero code.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$WingetArgs
    )

    $result = Invoke-HostNativeCommand -FilePath 'winget' -ArgumentList $WingetArgs
    $result.Output
    if ($result.ExitCode -ne 0) {
        throw "winget command failed with exit code $($result.ExitCode)"
    }
}

function Invoke-HostBootstrapNpm {
    <#
    .SYNOPSIS
        Runs npm with the given arguments without checking its code.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NpmArgs
    )

    $result = Invoke-HostNativeCommand -FilePath 'npm' -ArgumentList $NpmArgs
    $result.Output
}

function Invoke-HostBootstrapWsl {
    <#
    .SYNOPSIS
        Runs wsl with the given arguments and throws on a nonzero code.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$WslArgs
    )

    $result = Invoke-HostNativeCommand -FilePath 'wsl' -ArgumentList $WslArgs
    $result.Output
    if ($result.ExitCode -ne 0) {
        throw "wsl command failed with exit code $($result.ExitCode)"
    }
}

function Invoke-HostBootstrapVerifyScript {
    <#
    .SYNOPSIS
        Invokes the sibling verify-host.ps1 script by path.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    & $ScriptPath
}

function Invoke-HostBootstrapPoetry {
    <#
    .SYNOPSIS
        Runs poetry, or python -m poetry, and throws on a nonzero code.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PoetryArgs
    )

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        $result = Invoke-HostNativeCommand -FilePath $poetryCommand.Source -ArgumentList $PoetryArgs
        $result.Output
        if ($result.ExitCode -ne 0) {
            throw "poetry command failed with exit code $($result.ExitCode)"
        }

        return
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        throw "python is required to execute poetry"
    }

    $result = Invoke-HostNativeCommand -FilePath $pythonCommand.Source -ArgumentList (@('-m', 'poetry') + $PoetryArgs)
    $result.Output
    if ($result.ExitCode -ne 0) {
        throw "python -m poetry failed with exit code $($result.ExitCode)"
    }
}

Export-ModuleMember -Function Invoke-HostBootstrapGit, Get-ProjectRepositoriesFromManifest, Resolve-WorkspaceRoot, Initialize-WorkspaceRoot, Sync-ProjectsFromManifest, Resolve-ProjectRepoRoot, Invoke-HostBootstrapWinget, Invoke-HostBootstrapNpm, Invoke-HostBootstrapWsl, Invoke-HostBootstrapVerifyScript, Invoke-HostBootstrapPoetry
