#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Proves managed bootstrap version decisions without host installation or native calls.
#>

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../scripts/dev-tools/HostBootstrap.psm1') -Force
}

AfterAll {
    Remove-Module HostBootstrap, HostBootstrapWorkspace, HostTooling -ErrorAction SilentlyContinue
}

Describe 'Install-WithWinget managed versions' {
    BeforeEach {
        Mock Get-Command -ModuleName HostBootstrap { [pscustomobject]@{ Source = 'fixture-node' } }
        Mock Get-CommandVersion -ModuleName HostBootstrap { [version]'26.12.0' }
        Mock Invoke-HostBootstrapWinget -ModuleName HostBootstrap { }
    }

    It 'previews an upgrade of an installed stale version without invoking winget' {
        $actual = @(Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0)

        $actual | Should -Contain "- Would upgrade node from 26.12.0 to at least 26.13.0 using winget id 'OpenJS.NodeJS.LTS'"
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'uses upgrade for an installed stale managed tool in apply mode' {
        $actual = @(Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 -ApplyMode)

        $actual | Should -Contain 'Upgrading node (OpenJS.NodeJS.LTS)'
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            ($WingetArgs -join ' ') -eq 'upgrade --id OpenJS.NodeJS.LTS --exact --source winget --accept-source-agreements --accept-package-agreements'
        }
    }

    It 'preserves a tool exactly at the minimum' {
        Mock Get-CommandVersion -ModuleName HostBootstrap { [version]'26.13.0' }

        @(Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 -ApplyMode) |
            Should -Contain '[OK] node 26.13.0 meets minimum 26.13.0'
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'preserves a newer tool without downgrading' {
        Mock Get-CommandVersion -ModuleName HostBootstrap { [version]'27.0.0' }

        @(Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 -ApplyMode) |
            Should -Contain '[OK] node 27.0.0 meets minimum 26.13.0'
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'fails explicitly when an installed managed version cannot be read' {
        Mock Get-CommandVersion -ModuleName HostBootstrap { $null }

        { Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 } |
            Should -Throw '*Unable to determine installed version for node*'
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'installs a missing managed command only in apply mode' {
        Mock Get-Command -ModuleName HostBootstrap { }

        $null = Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
        $null = Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 -ApplyMode
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $WingetArgs[0] -eq 'install' }
        Should -Invoke Get-CommandVersion -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'propagates an upgrade failure' {
        Mock Invoke-HostBootstrapWinget -ModuleName HostBootstrap { throw 'fixture upgrade failed' }

        { Install-WithWinget -Id OpenJS.NodeJS.LTS -Name node -MinimumVersion 26.13.0 -ApplyMode } |
            Should -Throw '*fixture upgrade failed*'
    }

    It 'retains missing-only behavior for unmanaged callers' {
        $actual = @(Install-WithWinget -Id Git.Git -Name git -ApplyMode)

        $actual | Should -Contain '[OK] git already installed'
        Should -Invoke Get-CommandVersion -ModuleName HostBootstrap -Times 0 -Exactly
        Should -Invoke Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }
}

Describe 'Install-PoetryWithPip managed versions' {
    BeforeEach {
        Mock Get-Command -ModuleName HostBootstrap {
            param([string[]]$Name)
            [pscustomobject]@{ Source = "fixture-$(@($Name)[0])" }
        }
        Mock Get-CommandVersion -ModuleName HostBootstrap { [version]'2.2.1' }
        Mock Invoke-HostNativeCommand -ModuleName HostBootstrap {
            param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
            [pscustomobject]@{ ExitCode = 0; Output = @("$FilePath $($ArgumentList -join ' ') streamed=$StreamToHost") }
        }
        Mock Get-HostEnvironmentVariable -ModuleName HostBootstrap { 'fixture-appdata' }
        Mock Get-ChildItem -ModuleName HostBootstrap { }
        Mock Get-SessionPathFromMachineAndUser -ModuleName HostBootstrap { $null }
        Mock Set-HostEnvironmentVariable -ModuleName HostBootstrap { throw 'unexpected environment write' }
    }

    It 'previews missing minimum-constrained Poetry without side effects' {
        Mock Get-Command -ModuleName HostBootstrap { } -ParameterFilter { $Name -eq 'poetry' }

        @(Install-PoetryWithPip -MinimumVersion 2.3.2) |
            Should -Contain '- Would install poetry using python -m pip install --user poetry>=2.3.2'
        Should -Invoke Invoke-HostNativeCommand -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'previews stale Poetry without running pip' {
        @(Install-PoetryWithPip -MinimumVersion 2.3.2) |
            Should -Contain '- Would upgrade poetry from 2.2.1 to at least 2.3.2 using python -m pip'
        Should -Invoke Invoke-HostNativeCommand -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'applies a minimum-constrained pip upgrade through the existing streamed seam' {
        $null = Install-PoetryWithPip -MinimumVersion 2.3.2 -ApplyMode

        Should -Invoke Invoke-HostNativeCommand -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'fixture-python' -and $StreamToHost -and
            ($ArgumentList -join ' ') -eq '-m pip install --user --upgrade poetry>=2.3.2'
        }
        Should -Invoke Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'preserves compliant Poetry <Version> without downgrading' -TestCases @(
        @{ Version = '2.3.2' }, @{ Version = '2.4.0' }
    ) {
        param([string]$Version)
        $versionResponse = { [version]$Version }.GetNewClosure()
        Mock Get-CommandVersion -ModuleName HostBootstrap -MockWith $versionResponse

        @(Install-PoetryWithPip -MinimumVersion 2.3.2 -ApplyMode) |
            Should -Contain "[OK] poetry $Version meets minimum 2.3.2"
        Should -Invoke Invoke-HostNativeCommand -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'fails explicitly for unreadable installed Poetry versions' {
        Mock Get-CommandVersion -ModuleName HostBootstrap { $null }

        { Install-PoetryWithPip -MinimumVersion 2.3.2 } |
            Should -Throw '*Unable to determine installed version for poetry*'
    }

    It 'propagates a constrained pip installation failure' {
        Mock Invoke-HostNativeCommand -ModuleName HostBootstrap { [pscustomobject]@{ ExitCode = 7; Output = @() } }

        { Install-PoetryWithPip -MinimumVersion 2.3.2 -ApplyMode } |
            Should -Throw '*Poetry fallback install failed with exit code 7*'
    }

    It 'fails when Python is unavailable for the constrained fallback' {
        Mock Get-Command -ModuleName HostBootstrap { } -ParameterFilter { $Name -eq 'python' -or $Name -eq 'poetry' }

        { Install-PoetryWithPip -MinimumVersion 2.3.2 -ApplyMode } |
            Should -Throw '*python is required to install poetry fallback*'
    }

    It 'forwards the minimum through a failed Poetry winget installation' {
        Mock Get-Command -ModuleName HostBootstrap { }
        Mock Invoke-HostBootstrapWinget -ModuleName HostBootstrap { throw 'fixture winget failed' }
        Mock Install-PoetryWithPip -ModuleName HostBootstrap {
            param([switch]$ApplyMode, [string]$MinimumVersion)
            "fallback ($ApplyMode): $MinimumVersion"
        }

        $null = Install-WithWinget -Id Python.Poetry -Name poetry -MinimumVersion 2.3.2 -ApplyMode

        Should -Invoke Install-PoetryWithPip -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $ApplyMode -and $MinimumVersion -eq '2.3.2'
        }
    }
}
