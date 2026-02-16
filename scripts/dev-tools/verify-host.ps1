#!/usr/bin/env pwsh
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ManifestPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return (Join-Path -Path $PSScriptRoot -ChildPath "..\host-tools.manifest.json")
}

function Get-CommandVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$VersionArgs = @("--version")
    )

    $commandInfo = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $commandInfo) {
        return $null
    }

    $rawOutput = & $commandInfo.Source @VersionArgs 2>&1 | Out-String
    if (-not $rawOutput) {
        return $null
    }

    $match = [regex]::Match($rawOutput, "(\d+\.\d+(?:\.\d+)?)")
    if (-not $match.Success) {
        return $null
    }

    try {
        return [version]$match.Value
    }
    catch {
        return $null
    }
}

function Get-PoetryVersionInfo {
    [CmdletBinding()]
    [OutputType([psobject])]
    param()

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        return [pscustomobject]@{
            IsAvailable = $true
            Version     = Get-CommandVersion -Command "poetry"
            Source      = "poetry"
        }
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        return [pscustomobject]@{
            IsAvailable = $false
            Version     = $null
            Source      = ""
        }
    }

    $rawOutput = & $pythonCommand.Source -m poetry --version 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or -not $rawOutput) {
        return [pscustomobject]@{
            IsAvailable = $false
            Version     = $null
            Source      = ""
        }
    }

    $match = [regex]::Match($rawOutput, "(\d+\.\d+(?:\.\d+)?)")
    if (-not $match.Success) {
        return [pscustomobject]@{
            IsAvailable = $false
            Version     = $null
            Source      = ""
        }
    }

    try {
        return [pscustomobject]@{
            IsAvailable = $true
            Version     = [version]$match.Value
            Source      = "python -m poetry"
        }
    }
    catch {
        return [pscustomobject]@{
            IsAvailable = $false
            Version     = $null
            Source      = ""
        }
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

function Invoke-PoetryCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PoetryArgs
    )

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        return (& $poetryCommand.Source @PoetryArgs)
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        return (& $pythonCommand.Source -m poetry @PoetryArgs)
    }

    throw "poetry not found"
}

function Test-VersionAtLeast {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [version]$Actual,

        [Parameter(Mandatory = $true)]
        [string]$Minimum
    )

    if (-not $Actual) {
        return $false
    }

    return $Actual -ge ([version]$Minimum)
}

function Get-RequiredCommandsForHost {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest,

        [Parameter()]
        [bool]$IsWindowsHost = $IsWindows
    )

    [string[]]$requiredCommands = @($Manifest.requiredCommands)
    if ($IsWindowsHost) {
        return [string[]]@($requiredCommands | Where-Object { $_ -notin @("bashdb", "copilot") })
    }

    return [string[]]$requiredCommands
}

$manifestPath = Get-ManifestPath
if (-not (Test-Path $manifestPath)) {
    Write-Error "Manifest not found at $manifestPath"
    exit 1
}

$manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
$failureCount = 0

$sessionPath = Get-SessionPathFromMachineAndUser
if ($sessionPath) {
    $env:Path = $sessionPath
}

Write-Output "========================================="
Write-Output "Host Environment Verification"
Write-Output "========================================="

Write-Output ""
Write-Output "Core versions:"

$versionChecks = @(
    @{ Name = "python"; Args = @("--version"); Minimum = [string]$manifest.minimumVersions.python },
    @{ Name = "poetry"; Args = @("--version"); Minimum = [string]$manifest.minimumVersions.poetry },
    @{ Name = "pwsh"; Args = @("--version"); Minimum = [string]$manifest.minimumVersions.pwsh },
    @{ Name = "node"; Args = @("--version"); Minimum = [string]$manifest.minimumVersions.node }
)

foreach ($check in $versionChecks) {
    if ($check.Name -eq "poetry") {
        $poetryInfo = Get-PoetryVersionInfo
        if (-not $poetryInfo.IsAvailable) {
            Write-Output "  [FAIL] poetry: not found"
            $failureCount++
            continue
        }

        if (Test-VersionAtLeast -Actual $poetryInfo.Version -Minimum $check.Minimum) {
            Write-Output "  [OK] poetry: $($poetryInfo.Version) (>= $($check.Minimum)) via $($poetryInfo.Source)"
        }
        else {
            Write-Output "  [FAIL] poetry: $($poetryInfo.Version) (requires >= $($check.Minimum))"
            $failureCount++
        }

        continue
    }

    $cmd = Get-Command $check.Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Output "  [FAIL] $($check.Name): not found"
        $failureCount++
        continue
    }

    $actual = Get-CommandVersion -Command $check.Name -VersionArgs $check.Args
    if (Test-VersionAtLeast -Actual $actual -Minimum $check.Minimum) {
        Write-Output "  [OK] $($check.Name): $actual (>= $($check.Minimum))"
    }
    else {
        Write-Output "  [FAIL] $($check.Name): $actual (requires >= $($check.Minimum))"
        $failureCount++
    }
}

Write-Output ""
Write-Output "Required commands:"

$requiredCommands = Get-RequiredCommandsForHost -Manifest $manifest
foreach ($commandName in $requiredCommands) {
    $cmd = Get-Command $commandName -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Output "  [OK] ${commandName}: $($cmd.Source)"
    }
    else {
        Write-Output "  [FAIL] ${commandName}: not found"
        $failureCount++
    }
}

Write-Output ""
Write-Output "Optional commands:"

foreach ($commandName in $manifest.optionalCommands) {
    $cmd = Get-Command $commandName -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Output "  [OK] ${commandName}: $($cmd.Source)"
    }
    else {
        Write-Output "  [WARN] ${commandName}: not found (optional)"
    }
}

Write-Output ""
Write-Output "PowerShell modules:"

foreach ($moduleSpec in $manifest.powershellModules) {
    $available = Get-Module -ListAvailable -Name $moduleSpec.name |
        Sort-Object Version -Descending |
            Select-Object -First 1

    if (-not $available) {
        Write-Output "  [FAIL] $($moduleSpec.name): not found"
        $failureCount++
        continue
    }

    if ([version]$available.Version -ge ([version]$moduleSpec.minimumVersion)) {
        Write-Output "  [OK] $($moduleSpec.name): $($available.Version)"
    }
    else {
        Write-Output "  [FAIL] $($moduleSpec.name): $($available.Version) (requires >= $($moduleSpec.minimumVersion))"
        $failureCount++
    }
}

Write-Output ""
Write-Output "Poetry quality tools:"

$poetryInfo = Get-PoetryVersionInfo
if (-not $poetryInfo.IsAvailable) {
    Write-Output "  [FAIL] poetry: not found (cannot verify Python tooling)"
    $failureCount++
}
else {
    foreach ($toolName in $manifest.pythonTools) {
        $toolOutput = Invoke-PoetryCommand -PoetryArgs @("run", $toolName, "--version") 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            $firstLine = ($toolOutput -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
            Write-Output "  [OK] ${toolName}: $firstLine"
        }
        else {
            Write-Output "  [FAIL] ${toolName}: not available via poetry"
            $failureCount++
        }
    }
}

Write-Output ""
Write-Output "========================================="
if ($failureCount -eq 0) {
    Write-Output "[OK] Host verification passed"
    exit 0
}

Write-Output "[WARN] Host verification failed with $failureCount issue(s)"
Write-Output "Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply"
exit 1
