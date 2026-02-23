Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-GitExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GitArgs
    )

    git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed with exit code $LASTEXITCODE"
    }
}

function Get-ProjectRepositoriesFromManifest {
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
        Invoke-GitExe -GitArgs @("clone", [string]$project.url, $clonePath)
    }
}

function Resolve-ProjectRepoRoot {
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
