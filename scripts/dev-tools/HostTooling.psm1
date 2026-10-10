<#
.SYNOPSIS
    Shared host seams for the host bootstrap and host verification modules (issue #847).

.DESCRIPTION
    Holds the manifest path and read seam, the environment-variable seams, the single
    native-process seam, and the version parsing shared by HostBootstrap.psm1,
    HostBootstrapWorkspace.psm1, and HostVerification.psm1. Tests mock these functions
    with Mock -ModuleName so no host process, environment write, or file read occurs.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HostToolsManifestPath {
    <#
    .SYNOPSIS
        Returns the unnormalized path of the host tools manifest beside scripts/dev-tools.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return (Join-Path -Path $PSScriptRoot -ChildPath '..\host-tools.manifest.json')
}

function Read-HostToolsManifest {
    <#
    .SYNOPSIS
        Reads and parses the host tools manifest, or returns $null when the file is absent.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        return $null
    }

    return (Get-Content -Path $Path -Raw | ConvertFrom-Json)
}

function Get-HostEnvironmentVariable {
    <#
    .SYNOPSIS
        Reads an environment variable from the Process, User, or Machine target.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Target
    )

    return [System.Environment]::GetEnvironmentVariable($Name, $Target)
}

function Set-HostEnvironmentVariable {
    <#
    .SYNOPSIS
        Writes an environment variable to the Process, User, or Machine target.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Target
    )

    if ($PSCmdlet.ShouldProcess("$Target environment variable $Name", 'Set environment variable')) {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
}

function Get-SessionPathFromMachineAndUser {
    <#
    .SYNOPSIS
        Joins the Machine and User Path values into one session Path string.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    [string[]]$pathParts = @(
        Get-HostEnvironmentVariable -Name 'Path' -Target 'Machine'
        Get-HostEnvironmentVariable -Name 'Path' -Target 'User'
    ) | Where-Object { $_ }

    return ($pathParts -join ';')
}

function Invoke-HostNativeCommand {
    <#
    .SYNOPSIS
        Runs a host command and returns its captured output and ExitCode value.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter()]
        [string[]]$ArgumentList = @(),

        [Parameter()]
        [switch]$MergeErrorStream
    )

    if ($MergeErrorStream) {
        $output = & $FilePath @ArgumentList 2>&1
    }
    else {
        $output = & $FilePath @ArgumentList
    }

    $exitCode = Get-Variable -Name 'LASTEXITCODE' -Scope Global -ValueOnly -ErrorAction SilentlyContinue
    if ($null -eq $exitCode) {
        $exitCode = 0
    }

    return [pscustomobject]@{
        Output   = @($output)
        ExitCode = [int]$exitCode
    }
}

function ConvertTo-HostToolVersion {
    <#
    .SYNOPSIS
        Parses the first dotted version number in tool output text, or returns $null.
    #>
    [CmdletBinding()]
    [OutputType([version])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $match = [regex]::Match($Text, '(\d+\.\d+(?:\.\d+)?)')
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

function Get-CommandVersion {
    <#
    .SYNOPSIS
        Returns the version reported by a host command, or $null when it is unavailable.
    #>
    [CmdletBinding()]
    [OutputType([version])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$VersionArgs = @('--version')
    )

    $commandInfo = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $commandInfo) {
        return $null
    }

    $result = Invoke-HostNativeCommand -FilePath $commandInfo.Source -ArgumentList $VersionArgs -MergeErrorStream
    $rawOutput = $result.Output | Out-String
    return (ConvertTo-HostToolVersion -Text $rawOutput)
}

Export-ModuleMember -Function Get-HostToolsManifestPath, Read-HostToolsManifest, Get-HostEnvironmentVariable, Set-HostEnvironmentVariable, Get-SessionPathFromMachineAndUser, Invoke-HostNativeCommand, ConvertTo-HostToolVersion, Get-CommandVersion
