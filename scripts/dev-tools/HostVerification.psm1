<#
.SYNOPSIS
    Host verification logic behind scripts/dev-tools/verify-host.ps1 (issue #847).

.DESCRIPTION
    Holds the verification orchestrator, the five section checks, and the poetry and
    version helpers. Host calls go through HostTooling.psm1 seams or cmdlets that tests
    mock with Mock -ModuleName HostVerification. The module returns status lines and a
    numeric ExitCode value; the entry script writes the lines and ends the process.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostTooling.psm1')

function Get-PoetryVersionInfo {
    <#
    .SYNOPSIS
        Returns poetry availability, version, and source (poetry or python -m poetry).
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param()

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        return [pscustomobject]@{
            IsAvailable = $true
            Version     = Get-CommandVersion -Command 'poetry'
            Source      = 'poetry'
        }
    }

    $unavailable = [pscustomobject]@{
        IsAvailable = $false
        Version     = $null
        Source      = ''
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        return $unavailable
    }

    $result = Invoke-HostNativeCommand -FilePath $pythonCommand.Source -ArgumentList @('-m', 'poetry', '--version') -MergeErrorStream
    if ($result.ExitCode -ne 0) {
        return $unavailable
    }

    $version = ConvertTo-HostToolVersion -Text ($result.Output | Out-String)
    if ($null -eq $version) {
        return $unavailable
    }

    return [pscustomobject]@{
        IsAvailable = $true
        Version     = $version
        Source      = 'python -m poetry'
    }
}

function Invoke-PoetryCommand {
    <#
    .SYNOPSIS
        Runs a poetry command through poetry or python -m poetry and returns Output and ExitCode.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PoetryArgs
    )

    $poetryCommand = Get-Command poetry -ErrorAction SilentlyContinue
    if ($poetryCommand) {
        return (Invoke-HostNativeCommand -FilePath $poetryCommand.Source -ArgumentList $PoetryArgs -MergeErrorStream)
    }

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        return (Invoke-HostNativeCommand -FilePath $pythonCommand.Source -ArgumentList (@('-m', 'poetry') + $PoetryArgs) -MergeErrorStream)
    }

    throw 'poetry not found'
}

function Test-VersionAtLeast {
    <#
    .SYNOPSIS
        Returns $true when the actual version is at least the minimum version.
    #>
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
    <#
    .SYNOPSIS
        Returns the manifest required commands, omitting bashdb and copilot on Windows.
    #>
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
        return [string[]]@($requiredCommands | Where-Object { $_ -notin @('bashdb', 'copilot') })
    }

    return [string[]]$requiredCommands
}

function Test-HostCoreVersion {
    <#
    .SYNOPSIS
        Checks python, poetry, pwsh, and node against the manifest minimum versions.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $failureCount = 0
    $versionChecks = @(
        @{ Name = 'python'; Args = @('--version'); Minimum = [string]$Manifest.minimumVersions.python },
        @{ Name = 'poetry'; Args = @('--version'); Minimum = [string]$Manifest.minimumVersions.poetry },
        @{ Name = 'pwsh'; Args = @('--version'); Minimum = [string]$Manifest.minimumVersions.pwsh },
        @{ Name = 'node'; Args = @('--version'); Minimum = [string]$Manifest.minimumVersions.node }
    )

    foreach ($check in $versionChecks) {
        if ($check.Name -eq 'poetry') {
            $poetryInfo = Get-PoetryVersionInfo
            if (-not $poetryInfo.IsAvailable) {
                $lines.Add('  [FAIL] poetry: not found')
                $failureCount++
                continue
            }

            if (Test-VersionAtLeast -Actual $poetryInfo.Version -Minimum $check.Minimum) {
                $lines.Add("  [OK] poetry: $($poetryInfo.Version) (>= $($check.Minimum)) via $($poetryInfo.Source)")
            }
            else {
                $lines.Add("  [FAIL] poetry: $($poetryInfo.Version) (requires >= $($check.Minimum))")
                $failureCount++
            }

            continue
        }

        $cmd = Get-Command $check.Name -ErrorAction SilentlyContinue
        if (-not $cmd) {
            $lines.Add("  [FAIL] $($check.Name): not found")
            $failureCount++
            continue
        }

        $actual = Get-CommandVersion -Command $check.Name -VersionArgs $check.Args
        if (Test-VersionAtLeast -Actual $actual -Minimum $check.Minimum) {
            $lines.Add("  [OK] $($check.Name): $actual (>= $($check.Minimum))")
        }
        else {
            $lines.Add("  [FAIL] $($check.Name): $actual (requires >= $($check.Minimum))")
            $failureCount++
        }
    }

    return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = $failureCount }
}

function Test-HostRequiredCommand {
    <#
    .SYNOPSIS
        Checks that every required command for this host resolves on PATH.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest,

        [Parameter()]
        [bool]$IsWindowsHost = $IsWindows
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $failureCount = 0
    foreach ($commandName in (Get-RequiredCommandsForHost -Manifest $Manifest -IsWindowsHost $IsWindowsHost)) {
        $cmd = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($cmd) {
            $lines.Add("  [OK] ${commandName}: $($cmd.Source)")
        }
        else {
            $lines.Add("  [FAIL] ${commandName}: not found")
            $failureCount++
        }
    }

    return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = $failureCount }
}

function Test-HostOptionalCommand {
    <#
    .SYNOPSIS
        Reports optional commands; a missing optional command is a warning, never a failure.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($commandName in $Manifest.optionalCommands) {
        $cmd = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($cmd) {
            $lines.Add("  [OK] ${commandName}: $($cmd.Source)")
        }
        else {
            $lines.Add("  [WARN] ${commandName}: not found (optional)")
        }
    }

    return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = 0 }
}

function Test-HostPowerShellModule {
    <#
    .SYNOPSIS
        Checks that every manifest PowerShell module is installed at its minimum version.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $failureCount = 0
    foreach ($moduleSpec in $Manifest.powershellModules) {
        $available = Get-Module -ListAvailable -Name $moduleSpec.name |
            Sort-Object Version -Descending |
                Select-Object -First 1

        if (-not $available) {
            $lines.Add("  [FAIL] $($moduleSpec.name): not found")
            $failureCount++
            continue
        }

        if ([version]$available.Version -ge ([version]$moduleSpec.minimumVersion)) {
            $lines.Add("  [OK] $($moduleSpec.name): $($available.Version)")
        }
        else {
            $lines.Add("  [FAIL] $($moduleSpec.name): $($available.Version) (requires >= $($moduleSpec.minimumVersion))")
            $failureCount++
        }
    }

    return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = $failureCount }
}

function Test-HostPoetryTool {
    <#
    .SYNOPSIS
        Checks that every manifest Python quality tool runs through poetry.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $failureCount = 0
    $poetryInfo = Get-PoetryVersionInfo
    if (-not $poetryInfo.IsAvailable) {
        $lines.Add('  [FAIL] poetry: not found (cannot verify Python tooling)')
        return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = 1 }
    }

    foreach ($toolName in $Manifest.pythonTools) {
        $result = Invoke-PoetryCommand -PoetryArgs @('run', $toolName, '--version')
        if ($result.ExitCode -eq 0) {
            $toolOutput = $result.Output | Out-String
            $firstLine = ($toolOutput -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
            $lines.Add("  [OK] ${toolName}: $firstLine")
        }
        else {
            $lines.Add("  [FAIL] ${toolName}: not available via poetry")
            $failureCount++
        }
    }

    return [pscustomobject]@{ Lines = [string[]]$lines.ToArray(); FailureCount = $failureCount }
}

function Invoke-HostVerification {
    <#
    .SYNOPSIS
        Runs every host check and returns the report Lines and the ExitCode (0 or 1).
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter()]
        [string]$ManifestPath = (Get-HostToolsManifestPath),

        [Parameter()]
        [bool]$IsWindowsHost = $IsWindows
    )

    $manifest = Read-HostToolsManifest -Path $ManifestPath
    if ($null -eq $manifest) {
        Write-Error -Message "Manifest not found at $ManifestPath" -ErrorAction Stop
    }

    $sessionPath = Get-SessionPathFromMachineAndUser
    if ($sessionPath) {
        Set-HostEnvironmentVariable -Name 'Path' -Value $sessionPath -Target 'Process'
    }

    $banner = '========================================='
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add($banner)
    $lines.Add('Host Environment Verification')
    $lines.Add($banner)

    $sections = [ordered]@{}
    $sections['Core versions:'] = Test-HostCoreVersion -Manifest $manifest
    $sections['Required commands:'] = Test-HostRequiredCommand -Manifest $manifest -IsWindowsHost $IsWindowsHost
    $sections['Optional commands:'] = Test-HostOptionalCommand -Manifest $manifest
    $sections['PowerShell modules:'] = Test-HostPowerShellModule -Manifest $manifest
    $sections['Poetry quality tools:'] = Test-HostPoetryTool -Manifest $manifest

    $failureCount = 0
    foreach ($heading in $sections.Keys) {
        $lines.Add('')
        $lines.Add($heading)
        foreach ($line in $sections[$heading].Lines) {
            $lines.Add($line)
        }

        $failureCount += $sections[$heading].FailureCount
    }

    $lines.Add('')
    $lines.Add($banner)
    $exitCode = 0
    if ($failureCount -eq 0) {
        $lines.Add('[OK] Host verification passed')
    }
    else {
        $lines.Add("[WARN] Host verification failed with $failureCount issue(s)")
        $lines.Add('Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply')
        $exitCode = 1
    }

    return [pscustomobject]@{
        Lines    = [string[]]$lines.ToArray()
        ExitCode = $exitCode
    }
}

Export-ModuleMember -Function Invoke-HostVerification, Test-HostCoreVersion, Test-HostRequiredCommand, Test-HostOptionalCommand, Test-HostPowerShellModule, Test-HostPoetryTool, Test-VersionAtLeast, Get-RequiredCommandsForHost, Get-PoetryVersionInfo, Invoke-PoetryCommand
