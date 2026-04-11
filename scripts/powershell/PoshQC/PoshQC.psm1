$script:ModuleRoot = Split-Path -Parent $PSCommandPath
$script:PssaSettings = Join-Path $ModuleRoot 'settings/pssa.settings.psd1'
$script:PesterSettings = Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'

$script:DefaultExcludedDirs = @(
    '.git', '.venv', 'venv', 'node_modules', 'dist', 'build', '.pytest_cache',
    '__pycache__', '.mypy_cache', '.ruff_cache', '.vscode', '.idea', 'artifacts',
    '.vscode-test'
)

<#
.SYNOPSIS
Installs PoshQC dependencies (PSScriptAnalyzer and Pester).
.DESCRIPTION
Ensures PSGallery is trusted and installs required module versions in the CurrentUser scope.
#>
function Install-PoshQCTool {
    [CmdletBinding()]
    param(
        [scriptblock] $SetTls = { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 },
        [scriptblock] $GetRepository = { param([string] $Name) Get-PSRepository -Name $Name -ErrorAction SilentlyContinue },
        [scriptblock] $RegisterRepository = { Register-PSRepository -Default -InstallationPolicy Trusted },
        [scriptblock] $SetRepository = { param([string] $Name, [string] $Policy) Set-PSRepository -Name $Name -InstallationPolicy $Policy -ErrorAction Stop },
        [scriptblock] $FindModule = { param([string] $Name) Get-Module -ListAvailable -Name $Name },
        [scriptblock] $InstallModule = { param([string] $Name, [string] $Version) Install-Module -Name $Name -RequiredVersion $Version -Scope CurrentUser -AllowClobber -Force },
        [scriptblock] $Logger = {
            param([string] $Message, [string] $Level = 'Information')
            switch ($Level) {
                'Warning' { Write-Warning $Message }
                'Verbose' { Write-Verbose $Message }
                default { Write-Information $Message -InformationAction Continue }
            }
        }
    )

    $ErrorActionPreference = 'Stop'

    try {
        & $SetTls
    } catch {
        & $Logger "Unable to enforce TLS 1.2 for module install: $($_.Exception.Message)" 'Verbose'
    }
    $gallery = & $GetRepository 'PSGallery'
    if (-not $gallery) {
        & $Logger 'PSGallery not found; registering.'
        & $RegisterRepository
    } elseif ($gallery.InstallationPolicy -ne 'Trusted') {
        try {
            & $SetRepository 'PSGallery' 'Trusted'
        } catch {
            & $Logger 'Could not set PSGallery as trusted automatically. You may be prompted during install.' 'Warning'
        }
    }

    $requiredModules = @(
        @{ Name = 'PSScriptAnalyzer'; Version = '1.22.0' },
        @{ Name = 'Pester'; Version = '5.6.1' }
    )

    foreach ($module in $requiredModules) {
        $installed = & $FindModule $module.Name | Where-Object { $_.Version -ge [version]$module.Version } | Select-Object -First 1
        if ($installed) {
            & $Logger "$($module.Name) $($installed.Version) already present."
            continue
        }

        & $Logger "Installing $($module.Name) $($module.Version) (CurrentUser scope)..."
        try {
            & $InstallModule $module.Name $module.Version
        } catch {
            throw "Failed to install $($module.Name) $($module.Version): $($_.Exception.Message)"
        }

        $post = & $FindModule $module.Name | Where-Object { $_.Version -ge [version]$module.Version } | Select-Object -First 1
        if (-not $post) {
            throw "Failed to install $($module.Name) $($module.Version)."
        }
        & $Logger "$($module.Name) $($module.Version) installed."
    }
}

# PowerShell 7.6+ treats dot-sourced .psm1 files as isolated modules, so
# functions defined in them do not enter the parent module scope.  Loading the
# file content as a scriptblock bypasses that behaviour.
. ([scriptblock]::Create((Get-Content (Join-Path $script:ModuleRoot 'PoshQC.FileDiscovery.psm1') -Raw)))
. ([scriptblock]::Create((Get-Content (Join-Path $script:ModuleRoot 'PoshQC.Analyzer.psm1') -Raw)))
. ([scriptblock]::Create((Get-Content (Join-Path $script:ModuleRoot 'PoshQC.Testing.psm1') -Raw)))

Set-Alias -Name Install-PoshQCTools -Value Install-PoshQCTool

Export-ModuleMember -Function @(
    'Get-PoshQCFileList',
    'Install-PoshQCTool',
    'Invoke-PoshQCFormat',
    'Invoke-PoshQCAnalyze',
    'Invoke-PoshQCAnalyzeAutofix',
    'Invoke-PoshQCSuite',
    'Invoke-PoshQCTest',
    'Convert-PoshQCCoverageToRelative'
) -Alias @('Install-PoshQCTools')

