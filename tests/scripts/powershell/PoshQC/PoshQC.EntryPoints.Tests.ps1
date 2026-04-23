Set-StrictMode -Version Latest
# PSScriptAnalyzerSuppressRule PSUseConsistentWhitespace
# PSScriptAnalyzerSuppressRule PSAlignAssignmentStatement

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force
    $moduleInfo = Get-Module PoshQC |
        Where-Object { $_.Path -and (Resolve-Path -Path $_.Path).Path -eq $resolvedModulePath } |
            Select-Object -First 1
    $moduleRoot = Split-Path -Parent $moduleInfo.Path
    $script:TestSettingsPath = Join-Path $moduleRoot 'settings/pssa.settings.psd1'
    if (-not (Test-Path -Path $script:TestSettingsPath)) {
        throw "Test settings file missing at $script:TestSettingsPath"
    }
}

# Note: These tests focus on behavioral integration rather than full isolation
# due to the tight coupling with PSScriptAnalyzer and Pester modules.
# Mocking core PowerShell cmdlets (Get-Module, Import-Module, etc.) is
# problematic and leads to brittle tests.

Describe 'Install-PoshQCTool' {
    It 'keeps manifest dependency requirements empty to allow bootstrap installs' {
        $manifestPath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psd1'
        $manifest = Import-PowerShellDataFile -Path $manifestPath

        # RequiredModules prevents module import when tools are missing, which blocks the installer entry point.
        $manifest.RequiredModules | Should -BeNullOrEmpty
    }

    It 'reports already-installed modules without external module lookup' {
        $logs = New-Object System.Collections.Generic.List[string]

        {
            Install-PoshQCTool -FindModule {
                param([string] $Name)
                [pscustomobject]@{ Name = $Name; Version = [version]'9.9.9' }
            } -InstallModule {
                throw 'InstallModule should not be called for already-installed modules.'
            } -SetTls { } -GetRepository {
                [pscustomobject]@{ InstallationPolicy = 'Trusted' }
            } -SetRepository { } -RegisterRepository { } -Logger {
                param([string] $Message, [string] $Level)
                [void] $Level
                $logs.Add($Message) | Out-Null
            }
        } | Should -Not -Throw

        $logs | Should -Contain 'PSScriptAnalyzer 9.9.9 already present.'
        $logs | Should -Contain 'Pester 9.9.9 already present.'
    }
}

Describe 'Invoke-PoshQCFormat' {
    It 'handles empty file list without error' {
        # Mock the internal Get-PoshQCFileList function within the module scope
        $testRoot = $PSScriptRoot
        $testSettings = $TestSettingsPath
        InModuleScope PoshQC -Parameters @{ testRoot = $testRoot; testSettings = $testSettings } {
            param($testRoot, $testSettings)
            # Suppress warnings about unused parameters (they ARE used in the Should assertion below)
            $null = $testRoot
            $null = $testSettings
            Mock -CommandName Get-PoshQCFileList -MockWith { @() }
            { Invoke-PoshQCFormat -Root $testRoot -SettingsPath $testSettings -InformationAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

Describe 'Invoke-PoshQCAnalyze' {
    It 'validates settings path exists' {
        { Invoke-PoshQCAnalyze -Root $PSScriptRoot -SettingsPath '/missing/settings.psd1' } | Should -Throw '*Settings not found*'
    }
}

Describe 'Invoke-PoshQCTest' {
    It 'validates Pester module availability through injected module lookup' {
        {
            Invoke-PoshQCTest -Root $PSScriptRoot -EnsureModule {
                param([string] $Name, [string] $ErrorMessage)
                [void] $Name
                throw $ErrorMessage
            }
        } | Should -Throw '*Pester is not installed*'
    }
}
