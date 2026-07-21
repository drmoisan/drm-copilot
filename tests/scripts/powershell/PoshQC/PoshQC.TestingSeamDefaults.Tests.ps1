[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Stub function parameters mirror real command signatures for testing')]
param()

Set-StrictMode -Version Latest

BeforeAll {
    # Module-collision guard following the existing pattern in PoshQC.Comprehensive.Tests.ps1:
    # remove any PoshQC instance loaded from a path other than the repo-root module before
    # importing the repo-root copy, so exactly one PoshQC instance is loaded (issue #392).
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force
}

Describe 'Invoke-PoshQCTest default $InvokePester seam (issue #392)' {
    BeforeAll {
        # Obtain the exact default value scriptblock of the $InvokePester parameter from the
        # imported Invoke-PoshQCTest command via its AST, so the assertions exercise the real
        # default source rather than a re-typed copy.
        $ast = (Get-Command Invoke-PoshQCTest).ScriptBlock.Ast
        $isInvokePesterParam = {
            param($node)
            $node -is [System.Management.Automation.Language.ParameterAst] -and
            $node.Name.VariablePath.UserPath -eq 'InvokePester'
        }
        $parameter = $ast.FindAll($isInvokePesterParam, $true) | Select-Object -First 1
        $script:InvokePesterDefault = $parameter.DefaultValue.ScriptBlock.GetScriptBlock()
    }

    AfterEach {
        # Ensure no trampoline function or stub leaks between tests.
        Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun' -Force -ErrorAction SilentlyContinue
        Remove-Item -Path 'Function:\Invoke-Pester' -Force -ErrorAction SilentlyContinue
    }

    It 'defines function:global:Invoke-PoshQCPesterRun during the run, removes it after, and returns the result unmodified' {
        # Arrange: a stubbed global Invoke-Pester records whether the trampoline global function
        # exists while the run is in flight, and rides that presence flag plus a marker back on
        # the returned object so the assertions can confirm the seam does not swallow the
        # PassThru result. The flag is returned (not stored in a global variable) to avoid
        # introducing global state.
        function global:Invoke-Pester {
            [CmdletBinding()]
            param($Configuration)
            [PSCustomObject]@{
                Marker                      = 'stub-result'
                TrampolinePresentDuringCall = [bool](Test-Path 'Function:\Invoke-PoshQCPesterRun')
                Config                      = $Configuration
            }
        }
        $config = [PSCustomObject]@{ Marker = 'cfg' }

        # Act
        $result = & $script:InvokePesterDefault $config

        # Assert: the trampoline global function existed during the call and is removed after.
        $result.TrampolinePresentDuringCall | Should -BeTrue
        Test-Path 'Function:\Invoke-PoshQCPesterRun' | Should -BeFalse
        # Assert: the seam returns Invoke-Pester's result object unmodified (PassThru survives).
        $result.Marker | Should -Be 'stub-result'
        $result.Config.Marker | Should -Be 'cfg'
    }
}

Describe 'Invoke-PoshQCTest default $EnsureModule seam (issue #392)' {
    It 'imports the requested module with -Global' {
        InModuleScope PoshQC {
            # Mock Import-Module in module scope so the default $EnsureModule seam's import is
            # intercepted; provide a nonexistent settings path so Invoke-PoshQCTest throws at the
            # settings check immediately after $EnsureModule runs, isolating the import behavior.
            Mock -CommandName Import-Module -MockWith { }

            { Invoke-PoshQCTest -Root '/seam-test-root' -SettingsPath '/nonexistent-seam-settings.psd1' } |
                Should -Throw '*Settings not found*'

            # Assert the seam requested a global import of Pester.
            Should -Invoke -CommandName Import-Module -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Pester' -and $Global -eq $true
            }
        }
    }

    It 'throws the supplied error when the module is unavailable' {
        InModuleScope PoshQC {
            # Mock Get-Module -ListAvailable to report no Pester so the default seam raises the
            # supplied error message.
            Mock -CommandName Get-Module -MockWith { $null }

            { Invoke-PoshQCTest -Root '/seam-test-root' -SettingsPath '/nonexistent-seam-settings.psd1' } |
                Should -Throw '*Pester is not installed*'
        }
    }
}
