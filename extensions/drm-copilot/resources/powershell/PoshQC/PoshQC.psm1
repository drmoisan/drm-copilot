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
# functions defined in them do not enter the parent module scope.  A scriptblock
# obtained from [Parser]::ParseFile(...).GetScriptBlock() still executes in the
# caller's (module) scope when dot-sourced, preserving that workaround, while
# also retaining the on-disk file association.  The file association is required
# so Pester code-coverage breakpoints can bind to the sub-module source files
# (issue #344 remediation cycle 1, R2); the previous fileless
# [scriptblock]::Create((Get-Content -Raw)) approach produced scriptblocks with
# no source file, so breakpoints never bound and PoshQC.ScanConfig.psm1 fell
# outside the coverage denominator.  Parse errors fail module import fast.
#
# issue #392 remediation cycle 2: re-parsing and re-compiling a fresh ScriptBlock
# for each sub-module on every Import-Module -Force made Pester's code-coverage
# merge lose already-recorded hit credit for previously covered lines of the
# re-compiled files (per-file LINE coverage of PoshQC.Testing.psm1 regressed from
# 149/195 to 131/195 across a bundled run).  To avoid that re-parse/re-compile
# churn, the parsed ScriptBlock for each sub-module is cached in a process-lifetime
# AppDomain data slot keyed by absolute path, so ParseFile/GetScriptBlock runs at
# most once per sub-module per PowerShell process.  Dot-sourcing still runs on
# every -Force reimport, so functions rebind into each new module session state and
# the test module-collision guards keep detecting/removing a mismatched instance.
# The AppDomain slot (not a $global: variable, which PSAvoidGlobalVars forbids)
# provides the process-lifetime persistence that -Force (which discards the
# module's own script scope each time) does not.  A cache-miss parse error still
# fails module import fast.
$script:PoshQCSubModuleCacheKey = 'PoshQC.ParsedSubModuleScriptBlocks'
$subModuleCache = [System.AppDomain]::CurrentDomain.GetData($script:PoshQCSubModuleCacheKey)
if (-not $subModuleCache) {
    $subModuleCache = @{}
    [System.AppDomain]::CurrentDomain.SetData($script:PoshQCSubModuleCacheKey, $subModuleCache)
}
foreach ($subModuleName in @(
        'PoshQC.FileDiscovery.psm1',
        'PoshQC.ScanConfig.psm1',
        'PoshQC.Analyzer.psm1',
        'PoshQC.Testing.psm1'
    )) {
    $subModulePath = Join-Path $script:ModuleRoot $subModuleName
    $cachedScriptBlock = $subModuleCache[$subModulePath]
    if (-not $cachedScriptBlock) {
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $subModulePath, [ref]$null, [ref]$parseErrors)
        if ($parseErrors) {
            throw "Failed to parse sub-module '$subModuleName': $($parseErrors -join '; ')"
        }
        $cachedScriptBlock = $ast.GetScriptBlock()
        $subModuleCache[$subModulePath] = $cachedScriptBlock
    }
    . $cachedScriptBlock
}

Set-Alias -Name Install-PoshQCTools -Value Install-PoshQCTool

Export-ModuleMember -Function @(
    'Get-PoshQCFileList',
    'Install-PoshQCTool',
    'Invoke-PoshQCFormat',
    'Invoke-PoshQCAnalyze',
    'Invoke-PoshQCAnalyzeAutofix',
    'Invoke-PoshQCSuite',
    'Invoke-PoshQCTest',
    'Convert-PoshQCCoverageToRelative',
    'Get-PoshQCScanConfigFolder'
) -Alias @('Install-PoshQCTools')

