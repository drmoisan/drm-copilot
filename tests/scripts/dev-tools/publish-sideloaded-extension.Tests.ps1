#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Entry-point tests for scripts/dev-tools/publish-sideloaded-extension.ps1 (issue #847).

.DESCRIPTION
    Runs the entry script in-process with &. The -WhatIf case runs the real
    Invoke-SideloadedExtensionPublish with its helpers mocked with -ModuleName
    SideloadedExtensionPublish; the forwarding cases mock Invoke-SideloadedExtensionPublish
    at test scope and assert the bound parameters it received. The top-level default
    mocks throw for every host seam the module can reach, so a test that reaches an
    unmocked seam fails. The helper-function cases live in
    SideloadedExtensionPublish.Tests.ps1.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/SideloadedExtensionPublish.psm1").Path
    Import-Module $script:ModulePath -Force
    $script:entryPath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/publish-sideloaded-extension.ps1").Path

    Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Invoke-SideloadedExtensionProcess' }
    Mock -CommandName New-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName Remove-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Remove-Item' }
    Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Stop-Process' }
    Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Get-Process' }

    $script:fixtureVsixPath = 'C:\fixture\vsix\drm-copilot-20260102-030405.vsix'
}

AfterAll {
    Remove-Module SideloadedExtensionPublish -ErrorAction SilentlyContinue
}

Describe 'publish-sideloaded-extension.ps1 entry point - real orchestrator' {
    BeforeEach {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath)
            $LiteralPath -ne 'C:\fixture\vsix'
        }
        Mock -CommandName Assert-RequiredCommandAvailable -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Resolve-ExtensionProjectRoot -ModuleName SideloadedExtensionPublish -MockWith { 'C:\fixture\repo\extensions\drm-copilot' }
        Mock -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -MockWith { 'code' }
        Mock -CommandName Write-Information -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Invoke-NpmCiWithRetry -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Invoke-ProjectCompile -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { }
    }

    It 'AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf' {
        # Act
        $output = @(& $script:entryPath -RepoRoot 'C:\fixture\repo' -VsixOutputDir 'C:\fixture\vsix' -WhatIf)

        # Assert
        $output[-1] | Should -BeLike '*drm-copilot-*.vsix'
        Should -Invoke -CommandName New-Item -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-NpmCiWithRetry -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-ProjectCompile -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
    }
}

Describe 'publish-sideloaded-extension.ps1 entry point - parameter forwarding' {
    BeforeEach {
        Mock -CommandName Invoke-SideloadedExtensionPublish -MockWith { Write-Output 'C:\fixture\vsix\drm-copilot-20260102-030405.vsix' }
    }

    It 'AC05-PUBLISH-VSIX-OUTPUT returns the VSIX path and resolves both default expressions' {
        # Arrange
        $expectedRepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $expectedVsixOutputDir = Join-Path $expectedRepoRoot 'artifacts\vsix'

        # Act
        $output = @(& $script:entryPath)

        # Assert
        $output[-1] | Should -BeExactly $script:fixtureVsixPath
        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $RepoRoot -eq $expectedRepoRoot -and $VsixOutputDir -eq $expectedVsixOutputDir
        }
    }

    It 'AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand' {
        $null = & $script:entryPath -RepoRoot 'C:\fixture\repo' -CodeCommand ''

        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $PesterBoundParameters.ContainsKey('CodeCommand') -and $PesterBoundParameters['CodeCommand'] -eq ''
        }
    }

    It 'AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied' {
        $null = & $script:entryPath -RepoRoot 'C:\fixture\repo'

        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            -not $PesterBoundParameters.ContainsKey('CodeCommand')
        }
    }

    It 'AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false' {
        $null = & $script:entryPath -RepoRoot 'C:\fixture\repo' -Confirm:$false

        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $PesterBoundParameters.ContainsKey('Confirm') -and -not [bool]$PesterBoundParameters['Confirm']
        }
    }

    It 'forwards -Verbose and -WarningAction and does not forward -ErrorAction' {
        $null = & $script:entryPath -RepoRoot 'C:\fixture\repo' -Verbose -WarningAction SilentlyContinue -ErrorAction Stop 4>$null

        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $PesterBoundParameters.ContainsKey('Verbose') -and
            $PesterBoundParameters['Verbose'] -eq $true -and
            $PesterBoundParameters.ContainsKey('WarningAction') -and
            $PesterBoundParameters['WarningAction'] -eq 'SilentlyContinue' -and
            -not $PesterBoundParameters.ContainsKey('ErrorAction')
        }
    }

    It 'forwards the switch parameters as passed' {
        $null = & $script:entryPath -RepoRoot 'C:\fixture\repo' -UseInsiders -SkipNpmCi -SkipCompile -SkipInstall -Force

        Should -Invoke -CommandName Invoke-SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $UseInsiders -and $SkipNpmCi -and $SkipCompile -and $SkipInstall -and $Force -and
            -not $PesterBoundParameters.ContainsKey('WhatIf')
        }
    }
}

Describe "scaffold extension package identity" {
    It "uses canonical drm-copilot name metadata" {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
        $packageJsonPath = Join-Path $repoRoot "extensions/drm-copilot/package.json"
        $manifest = Get-Content -LiteralPath $packageJsonPath -Raw | ConvertFrom-Json

        $manifest.name | Should -Be "drm-copilot"
        $manifest.displayName | Should -Be "drm-copilot"
    }
}
