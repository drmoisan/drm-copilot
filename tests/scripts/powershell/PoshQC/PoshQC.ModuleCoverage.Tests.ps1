#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.4.0' }
Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Coverage tests for the default Logger, the post-install check, and the sub-module
    cache-miss import path of PoshQC.psm1 (issue #953).

.DESCRIPTION
    The Install-PoshQCTool cases inject every seam except -Logger, so the default Logger
    runs while no module is installed, no repository is queried, and no file is written.
    The cache-miss case clears the process-lifetime AppDomain cache slot, re-imports the
    module from the checked-in source, and restores the saved slot value afterwards.
#>

BeforeAll {
    $script:PoshQCModulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    Import-Module $script:PoshQCModulePath -Force
    $script:CacheKey = 'PoshQC.ParsedSubModuleScriptBlocks'
    $script:TrustedGallery = { [pscustomobject]@{ InstallationPolicy = 'Trusted' } }
    $script:PresentModule = {
        param([string] $Name)
        [pscustomobject]@{ Name = $Name; Version = [version]'5.9.5' }
    }
    $script:NoOpInstall = { param([string] $Name, [string] $Version) [void] $Name; [void] $Version }
}

Describe 'Install-PoshQCTool default Logger (issue #953)' {
    It 'MC01-LOGGER-DEFAULT-WARNING writes a warning when PSGallery trust cannot be set' {
        # Arrange
        $untrustedGallery = { [pscustomobject]@{ InstallationPolicy = 'Untrusted' } }
        $failingSetRepository = { param([string] $Name, [string] $Policy) [void] $Name; [void] $Policy; throw 'cannot set' }

        # Act
        $records = Install-PoshQCTool -SetTls { } -GetRepository $untrustedGallery -RegisterRepository { } -SetRepository $failingSetRepository -FindModule $script:PresentModule -InstallModule $script:NoOpInstall 3>&1 6>&1

        # Assert
        $warnings = @($records | Where-Object { $_ -is [System.Management.Automation.WarningRecord] -and $_.Message -like '*PSGallery as trusted*' })
        $warnings.Count | Should -Be 1 -Because 'the default Logger maps the Warning level to Write-Warning'
    }

    It 'MC02-LOGGER-DEFAULT-VERBOSE writes a verbose record when TLS 1.2 cannot be enforced' {
        # Arrange
        $failingSetTls = { throw 'tls unavailable' }

        # Act
        $records = Install-PoshQCTool -Verbose -SetTls $failingSetTls -GetRepository $script:TrustedGallery -RegisterRepository { } -SetRepository { } -FindModule $script:PresentModule -InstallModule $script:NoOpInstall 4>&1 6>&1

        # Assert
        $verbose = @($records | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] -and $_.Message -like 'Unable to enforce TLS 1.2*tls unavailable' })
        $verbose.Count | Should -Be 1 -Because 'the default Logger maps the Verbose level to Write-Verbose'
    }

    It 'MC03-LOGGER-DEFAULT-INFORMATION writes information records when both modules are present' {
        # Arrange
        $installMustNotRun = { param([string] $Name, [string] $Version) [void] $Name; [void] $Version; throw 'install must not run' }

        # Act
        $records = Install-PoshQCTool -SetTls { } -GetRepository $script:TrustedGallery -RegisterRepository { } -SetRepository { } -FindModule $script:PresentModule -InstallModule $installMustNotRun 6>&1

        # Assert
        $information = @($records | Where-Object { $_ -is [System.Management.Automation.InformationRecord] -and "$($_.MessageData)" -like '* already present.' })
        $information.Count | Should -Be 2 -Because 'the default Logger writes one information record per present module'
    }

    It 'MC04-INSTALL-POSTCHECK-THROWS throws when the module is still absent after installation' {
        # Arrange
        $absentModule = { param([string] $Name) [void] $Name }

        # Act / Assert
        { Install-PoshQCTool -SetTls { } -GetRepository $script:TrustedGallery -RegisterRepository { } -SetRepository { } -FindModule $absentModule -InstallModule $script:NoOpInstall 6>$null } |
            Should -Throw -ExpectedMessage 'Failed to install PSScriptAnalyzer 1.22.0.'
    }
}

Describe 'PoshQC.psm1 sub-module cache miss (issue #953)' {
    BeforeEach {
        $script:SavedCache = [System.AppDomain]::CurrentDomain.GetData($script:CacheKey)
    }

    AfterEach {
        [System.AppDomain]::CurrentDomain.SetData($script:CacheKey, $script:SavedCache)
        Import-Module $script:PoshQCModulePath -Force
    }

    It 'MC05-SUBMODULE-CACHE-MISS-IMPORT parses and caches every sub-module when the cache is empty' {
        # Arrange
        $moduleFolder = Split-Path -Parent $script:PoshQCModulePath
        $expected = @(Get-ChildItem -LiteralPath $moduleFolder -File -Filter '*.psm1' | Where-Object { $_.Name -ne 'PoshQC.psm1' } | ForEach-Object { $_.Name } | Sort-Object)
        [System.AppDomain]::CurrentDomain.SetData($script:CacheKey, $null)

        # Act
        Import-Module $script:PoshQCModulePath -Force

        # Assert
        $cache = [System.AppDomain]::CurrentDomain.GetData($script:CacheKey)
        $cache | Should -Not -BeNullOrEmpty -Because 'the cache-miss path initialises the slot'
        $expected.Count | Should -BeGreaterOrEqual 5
        $cache.Count | Should -Be $expected.Count
        @($cache.Keys | ForEach-Object { Split-Path -Leaf $_ } | Sort-Object) | Should -Be $expected
    }
}
