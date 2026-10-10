#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for Invoke-SideloadedExtensionPublish in
    scripts/dev-tools/SideloadedExtensionPublish.psm1 (issue #847).

.DESCRIPTION
    Runs the real orchestrator with its helpers mocked with -ModuleName
    SideloadedExtensionPublish. The top-level default mocks throw, so a test that
    reaches an unmocked host seam fails. Call order is recorded in a module-scope list
    created with InModuleScope; the same object is referenced from this test scope so
    the mock bodies can append to it. Every run passes a fixed -Now clock.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/SideloadedExtensionPublish.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Invoke-SideloadedExtensionProcess' }
    Mock -CommandName New-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName Remove-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Remove-Item' }
    Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Stop-Process' }
    Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Get-Process' }

    $script:publishArgs = @{
        RepoRoot      = 'C:\fixture\repo'
        VsixOutputDir = 'C:\fixture\vsix'
        Now           = { [datetime]::new(2026, 1, 2, 3, 4, 5) }
    }
}

AfterAll {
    Remove-Module SideloadedExtensionPublish -ErrorAction SilentlyContinue
}

Describe 'Invoke-SideloadedExtensionPublish' {
    BeforeEach {
        $script:recorder = InModuleScope SideloadedExtensionPublish {
            $script:recorder = [pscustomobject]@{ CallOrder = [System.Collections.Generic.List[string]]::new() }
            $script:recorder
        }

        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $true }
        Mock -CommandName Assert-RequiredCommandAvailable -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Resolve-ExtensionProjectRoot -ModuleName SideloadedExtensionPublish -MockWith { 'C:\fixture\repo\extensions\drm-copilot' }
        Mock -CommandName Write-Information -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Invoke-NpmCiWithRetry -ModuleName SideloadedExtensionPublish -MockWith { $script:recorder.CallOrder.Add('npm ci') }
        Mock -CommandName Invoke-ProjectCompile -ModuleName SideloadedExtensionPublish -MockWith { $script:recorder.CallOrder.Add('compile') }
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$FilePath, [string[]]$ArgumentList, [string]$WorkingDirectory)
            $null = $WorkingDirectory
            if ($ArgumentList -contains '@vscode/vsce') {
                $script:recorder.CallOrder.Add('vsce package')
            }
            else {
                $script:recorder.CallOrder.Add(('{0} {1}' -f $FilePath, $ArgumentList[0]))
            }
        }
    }

    Context 'with a resolved VS Code CLI' {
        BeforeEach {
            Mock -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -MockWith { 'code' }
        }

        It 'AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order' {
            # Act
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs

            # Assert
            $callOrder = @(InModuleScope SideloadedExtensionPublish { $script:recorder.CallOrder.ToArray() })
            $callOrder | Should -Be @('npm ci', 'compile', 'vsce package', 'code --install-extension')
            Should -Invoke -CommandName Invoke-NpmCiWithRetry -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $WorkingDirectory -eq 'C:\fixture\repo\extensions\drm-copilot' -and -not $ForceCleanup
            }
            Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'code' -and $ArgumentList.Count -eq 2 -and $WorkingDirectory -eq 'C:\fixture\repo'
            }
        }

        It 'AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi' {
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs -SkipNpmCi

            @(InModuleScope SideloadedExtensionPublish { $script:recorder.CallOrder.ToArray() }) | Should -Be @('compile', 'vsce package', 'code --install-extension')
        }

        It 'AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile' {
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs -SkipCompile

            @(InModuleScope SideloadedExtensionPublish { $script:recorder.CallOrder.ToArray() }) | Should -Be @('npm ci', 'vsce package', 'code --install-extension')
        }

        It 'AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall' {
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs -SkipInstall

            @(InModuleScope SideloadedExtensionPublish { $script:recorder.CallOrder.ToArray() }) | Should -Be @('npm ci', 'compile', 'vsce package')
            Should -Invoke -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
            Should -Invoke -CommandName Write-Information -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $MessageData -eq 'Install skipped (rerun without -SkipInstall to install).'
            }
        }

        It 'AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX' {
            # Arrange
            Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
                param([string]$LiteralPath)
                -not ($LiteralPath -like '*.vsix')
            }

            # Act / Assert
            { Invoke-SideloadedExtensionPublish @script:publishArgs } | Should -Throw -ExpectedMessage 'VSIX was not created as expected: *drm-copilot-20260102-030405.vsix'
            Should -Invoke -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        }

        It 'returns the VSIX path named from the -Now clock as its only output' {
            $result = @(Invoke-SideloadedExtensionPublish @script:publishArgs)

            $result.Count | Should -Be 1
            ($result[-1] -replace '\\', '/') | Should -BeLike 'C:/fixture/vsix/drm-copilot-20260102-030405.vsix'
            Should -Invoke -CommandName Write-Information -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $MessageData -like 'VSIX created: *drm-copilot-20260102-030405.vsix'
            }
        }

        It 'adds --force to the install arguments and requests npm cleanup with -Force' {
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs -Force

            Should -Invoke -CommandName Invoke-NpmCiWithRetry -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter { $ForceCleanup }
            Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'code' -and $ArgumentList[0] -eq '--install-extension' -and $ArgumentList[-1] -eq '--force'
            }
        }

        It 'creates the output directory through New-Item when it is absent' {
            Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
                param([string]$LiteralPath)
                $LiteralPath -ne 'C:\fixture\vsix'
            }
            Mock -CommandName New-Item -ModuleName SideloadedExtensionPublish -MockWith { }

            $null = Invoke-SideloadedExtensionPublish @script:publishArgs

            Should -Invoke -CommandName New-Item -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $ItemType -eq 'Directory' -and $Path -eq 'C:\fixture\vsix'
            }
        }

        It 'throws when RepoRoot does not exist' {
            Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $false }

            { Invoke-SideloadedExtensionPublish @script:publishArgs } | Should -Throw -ExpectedMessage 'RepoRoot does not exist: C:\fixture\repo'
            Should -Invoke -CommandName Assert-RequiredCommandAvailable -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
        }

        It 'throws when the extension package.json is missing' {
            Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
                param([string]$LiteralPath)
                -not ($LiteralPath -like '*package.json')
            }

            { Invoke-SideloadedExtensionPublish @script:publishArgs } | Should -Throw -ExpectedMessage 'package.json not found at RepoRoot: *package.json'
        }

        It 'passes an explicit -CodeCommand to the CLI resolver' {
            $null = Invoke-SideloadedExtensionPublish @script:publishArgs -CodeCommand 'code-insiders' -UseInsiders

            Should -Invoke -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
                $PreferredCommand -eq 'code-insiders' -and $PreferInsiders
            }
        }
    }

    Context 'VS Code CLI resolution failures' {
        It 'AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH' {
            # Arrange: the real resolver runs; no command resolves.
            Mock -CommandName Get-Command -ModuleName SideloadedExtensionPublish -MockWith { $null }

            # Act / Assert
            { Invoke-SideloadedExtensionPublish @script:publishArgs -CodeCommand 'code-missing' } | Should -Throw -ExpectedMessage "VS Code CLI command 'code-missing' was explicitly requested but was not found on PATH."
            Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 0 -Exactly -ParameterFilter { $ArgumentList -contains '--install-extension' }
        }

        It 'throws when no VS Code CLI command is found on PATH' {
            Mock -CommandName Resolve-VSCodeCliCommand -ModuleName SideloadedExtensionPublish -MockWith { $null }

            { Invoke-SideloadedExtensionPublish @script:publishArgs } | Should -Throw -ExpectedMessage "Could not find a VS Code CLI command on PATH (expected 'code' or 'code-insiders')."
        }
    }
}
