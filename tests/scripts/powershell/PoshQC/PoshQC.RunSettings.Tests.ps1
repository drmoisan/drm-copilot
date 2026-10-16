#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.4.0' }
Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Regression tests for the shipped PoshQC Pester runsettings, the installer Pester minimum, and
    the Pester major-version ceiling below 6.0 (issue #953, decision D8).

.DESCRIPTION
    Reads the checked-in runsettings and workflow files and builds a Pester configuration in
    memory. The installer cases drive Install-PoshQCTool through its injected seams, so no module
    is installed, no repository is queried, and no file is written. The import case mocks
    Import-Module inside the PoshQC module scope and stops Invoke-PoshQCTest at the settings check.
#>

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root source.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force
    $script:RepoRunSettingsPath = (Resolve-Path (Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/settings/pester.runsettings.psd1')).Path
    $script:BundledRunSettingsPath = (Resolve-Path (Join-Path $PSScriptRoot '../../../../extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1')).Path
    $script:WorkflowPath = (Resolve-Path (Join-Path $PSScriptRoot '../../../../.github/workflows/_poshqc.yml')).Path
}

Describe 'PoshQC shipped Pester runsettings (issue #953)' {
    It 'RS01-RUNSETTINGS-PROFILER-MODE sets UseBreakpoints to false and keeps the coverage keys' {
        # Arrange / Act
        $coverage = (Import-PowerShellDataFile -Path $script:RepoRunSettingsPath).CodeCoverage

        # Assert
        $coverage.ContainsKey('UseBreakpoints') | Should -BeTrue -Because 'issue #953 selects profiler-based coverage explicitly'
        ($coverage.UseBreakpoints -is [bool]) | Should -BeTrue
        $coverage.UseBreakpoints | Should -Be $false
        $coverage.Enabled | Should -Be $true
        $coverage.OutputFormat | Should -BeExactly 'CoverageGutters'
        $coverage.OutputPath | Should -BeExactly 'artifacts/pester/powershell-coverage.xml'
        $coverage.CoveragePercentTarget | Should -Be 0
    }

    It 'RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE builds a Pester configuration whose UseBreakpoints value is false' {
        # Arrange
        $settings = Import-PowerShellDataFile -Path $script:RepoRunSettingsPath

        # Act
        $configuration = New-PesterConfiguration -Hashtable $settings

        # Assert
        $configuration.CodeCoverage.UseBreakpoints.Value | Should -Be $false
        $configuration.CodeCoverage.Enabled.Value | Should -Be $true
    }

    It 'RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE sets UseBreakpoints to false in the bundled copy' {
        # Arrange / Act
        $coverage = (Import-PowerShellDataFile -Path $script:BundledRunSettingsPath).CodeCoverage

        # Assert
        $coverage.ContainsKey('UseBreakpoints') | Should -BeTrue -Because 'the bundled copy must match the repository copy'
        $coverage.UseBreakpoints | Should -Be $false
        $coverage.Enabled | Should -Be $true
        $coverage.OutputFormat | Should -BeExactly 'CoverageGutters'
    }
}

Describe 'Install-PoshQCTool Pester minimum (issue #953)' {
    It 'RS03-INSTALLER-PESTER-590 passes Pester version 5.9.0 to the injected install seam' {
        # Arrange: no module is present until the install seam records it.
        $installed = @{}
        $installCalls = [System.Collections.Generic.List[object]]::new()
        $findModule = {
            param([string] $Name)
            if ($installed.ContainsKey($Name)) { [pscustomobject]@{ Name = $Name; Version = $installed[$Name] } }
        }
        $installModule = {
            param([string] $Name, [string] $Version)
            $installCalls.Add([pscustomobject]@{ Name = $Name; Version = $Version })
            $installed[$Name] = [version] $Version
        }
        $logger = { param([string] $Message, [string] $Level) [void] $Message; [void] $Level }

        # Act
        Install-PoshQCTool -SetTls { } -GetRepository { [pscustomobject]@{ InstallationPolicy = 'Trusted' } } -SetRepository { } -RegisterRepository { } -FindModule $findModule -InstallModule $installModule -Logger $logger

        # Assert
        $pesterCalls = @($installCalls | Where-Object { $_.Name -eq 'Pester' })
        $pesterCalls.Count | Should -Be 1
        $pesterCalls[0].Version | Should -BeExactly '5.9.0'
    }

    It 'RS05-INSTALLER-PESTER-CEILING-BELOW-6 installs Pester 5.9.0 when only Pester 6.0.0 is present' {
        # Arrange: an installed Pester 6.0.0 must not satisfy the requirement (decision D8).
        $installed = @{ 'Pester' = @([version]'6.0.0'); 'PSScriptAnalyzer' = @([version]'1.22.0') }
        $installCalls = [System.Collections.Generic.List[object]]::new()
        $findModule = {
            param([string] $Name)
            if ($installed.ContainsKey($Name)) {
                foreach ($version in $installed[$Name]) { [pscustomobject]@{ Name = $Name; Version = $version } }
            }
        }
        $installModule = {
            param([string] $Name, [string] $Version)
            $installCalls.Add([pscustomobject]@{ Name = $Name; Version = $Version })
            $installed[$Name] = @($installed[$Name]) + [version] $Version
        }
        $logger = { param([string] $Message, [string] $Level) [void] $Message; [void] $Level }

        # Act
        Install-PoshQCTool -SetTls { } -GetRepository { [pscustomobject]@{ InstallationPolicy = 'Trusted' } } -SetRepository { } -RegisterRepository { } -FindModule $findModule -InstallModule $installModule -Logger $logger

        # Assert
        $pesterCalls = @($installCalls | Where-Object { $_.Name -eq 'Pester' })
        $pesterCalls.Count | Should -Be 1 -Because 'an installed Pester 6.0.0 is above the ceiling'
        $pesterCalls[0].Version | Should -BeExactly '5.9.0'
        @($installCalls | Where-Object { $_.Name -eq 'PSScriptAnalyzer' }).Count | Should -Be 0
    }
}

Describe 'Invoke-PoshQCTest Pester import ceiling (issue #953)' {
    It 'RS06-TEST-IMPORT-PESTER-MAXIMUM imports Pester with MaximumVersion 5.99.99 through the default EnsureModule seam' {
        InModuleScope PoshQC {
            # Arrange: intercept the import; a nonexistent settings path stops the run right after the seam.
            Mock -CommandName Import-Module -MockWith { }
            # Report a supported Pester so the result does not depend on the modules installed on the host (issue #953, CR-1).
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'5.9.5' } }

            # Act
            { Invoke-PoshQCTest -Root '/rs06-root' -SettingsPath '/rs06-missing-settings.psd1' } | Should -Throw '*Settings not found*'

            # Assert
            Should -Invoke -CommandName Import-Module -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Pester' -and $Global -eq $true -and $MaximumVersion -eq '5.99.99'
            }
        }
    }
}

Describe 'PoshQC Linux hook job Pester import (issue #953)' {
    It 'RS07-WORKFLOW-LINUX-PESTER-RANGE imports Pester at minimum 5.9.0 and maximum 5.99.99' {
        # Arrange: collect the body lines of the poshqc-linux-hooks job only.
        $inJob = $false
        $jobLines = foreach ($line in Get-Content -LiteralPath $script:WorkflowPath) {
            if ($line -match '^  [A-Za-z0-9_-]+:\s*$') {
                $inJob = ($line -match '^  poshqc-linux-hooks:\s*$')
                continue
            }
            if ($inJob) { $line }
        }

        # Act
        $imports = @($jobLines | Where-Object { $_ -match '^\s*Import-Module Pester\b' })

        # Assert
        $imports.Count | Should -Be 1 -Because 'the Linux hook job imports Pester once'
        $imports[0] | Should -Match '-MinimumVersion 5\.9\.0(\s|$)'
        $imports[0] | Should -Match '-MaximumVersion 5\.99\.99(\s|$)'
    }
}

Describe 'Invoke-PoshQCTest Pester presence check and import range (issue #953, CR-1, CR-2)' {
    It 'RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS queries and imports Pester with minimum 5.9.0 and maximum 5.99.99' {
        InModuleScope PoshQC {
            # Arrange: one installed Pester is below, one inside, and one above the supported range. The
            # unqualified lookup returns all three; the range-qualified lookup applies the requested bounds.
            Mock -CommandName Get-Module -MockWith {
                foreach ($version in '3.4.0', '5.9.5', '6.0.0') { [pscustomobject]@{ Name = 'Pester'; Version = [version]$version } }
            }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                foreach ($version in '3.4.0', '5.9.5', '6.0.0') {
                    if ([version]$version -ge $range.Version -and [version]$version -le [version]$range.MaximumVersion) {
                        [pscustomobject]@{ Name = 'Pester'; Version = [version]$version }
                    }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act: a nonexistent settings path stops the run right after the seam.
            { Invoke-PoshQCTest -Root '/rs08-root' -SettingsPath '/rs08-missing-settings.psd1' } | Should -Throw '*Settings not found*'

            # Assert: the import carries both bounds, and the presence query carries the same range.
            Should -Invoke -CommandName Import-Module -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Pester' -and $Global -eq $true -and $MinimumVersion -eq [version]'5.9.0' -and $MaximumVersion -eq '5.99.99'
            }
            Should -Invoke -CommandName Get-Module -Times 1 -Exactly -ParameterFilter {
                $ListAvailable -and $null -ne $FullyQualifiedName -and $FullyQualifiedName[0].Name -eq 'Pester' -and $FullyQualifiedName[0].Version -eq [version]'5.9.0' -and $FullyQualifiedName[0].MaximumVersion -eq '5.99.99'
            }
        }
    }

    It 'RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 6.0.0 is installed' {
        InModuleScope PoshQC {
            # Arrange: the only installed Pester is above the ceiling, so the range-qualified lookup returns nothing.
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'6.0.0' } }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                if ([version]'6.0.0' -ge $range.Version -and [version]'6.0.0' -le [version]$range.MaximumVersion) {
                    [pscustomobject]@{ Name = 'Pester'; Version = [version]'6.0.0' }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act / Assert
            { Invoke-PoshQCTest -Root '/rs09-root' -SettingsPath '/rs09-missing-settings.psd1' } | Should -Throw '*Run Install-PoshQCTool*'
            Should -Invoke -CommandName Import-Module -Times 0 -Exactly
        }
    }

    It 'RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 3.4.0 is installed' {
        InModuleScope PoshQC {
            # Arrange: the only installed Pester is the inbox 3.4.0 below the minimum, so the range-qualified lookup returns nothing.
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'3.4.0' } }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                if ([version]'3.4.0' -ge $range.Version -and [version]'3.4.0' -le [version]$range.MaximumVersion) {
                    [pscustomobject]@{ Name = 'Pester'; Version = [version]'3.4.0' }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act / Assert
            { Invoke-PoshQCTest -Root '/rs10-root' -SettingsPath '/rs10-missing-settings.psd1' } | Should -Throw '*Run Install-PoshQCTool*'
            Should -Invoke -CommandName Import-Module -Times 0 -Exactly
        }
    }
}
