Set-StrictMode -Version Latest

BeforeAll {
    # Module-collision guard following PoshQC.TestingInvokeConfigPaths.Tests.ps1: remove any PoshQC
    # instance loaded from another path, then import the repository-root module (issue #392).
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

Describe 'Get-PoshQCLeakFinding detected kinds (issue #1096)' {
    It 'LS-K01 reports <Label> as one finding of its kind and name' -ForEach @(
        @{ Label = 'an env assignment'; Content = '$env:FOO = "a"'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'a braced env assignment'; Content = '${env:FOO} = "a"'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'a compound env assignment'; Content = '$env:PATH += ";x"'; Kind = 'env'; Name = 'PATH' }
        @{ Label = 'Set-Item on Env:X'; Content = 'Set-Item -Path Env:FOO -Value 1'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'New-Item on Env:\X'; Content = 'New-Item Env:\FOO -Value 1'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'New-Item on the Env: drive with -Name'; Content = 'New-Item -Path Env: -Name FOO -Value 1'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'Remove-Item on Env:X'; Content = 'Remove-Item Env:FOO'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'Clear-Item on Env:X'; Content = 'Clear-Item Env:FOO'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'Environment SetEnvironmentVariable'; Content = '[Environment]::SetEnvironmentVariable("FOO", "1")'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'System.Environment SetEnvironmentVariable'; Content = '[System.Environment]::SetEnvironmentVariable("FOO", "1")'; Kind = 'env'; Name = 'FOO' }
        @{ Label = 'a global variable assignment'; Content = '$global:BAR = 1'; Kind = 'global-variable'; Name = 'BAR' }
        @{ Label = 'Set-Variable -Scope Global'; Content = 'Set-Variable -Name BAR -Value 1 -Scope Global'; Kind = 'global-variable'; Name = 'BAR' }
        @{ Label = 'New-Variable -Scope Global'; Content = 'New-Variable BAR 1 -Scope Global'; Kind = 'global-variable'; Name = 'BAR' }
        @{ Label = 'Remove-Variable -Scope Global'; Content = 'Remove-Variable -Name BAR -Scope Global'; Kind = 'global-variable'; Name = 'BAR' }
        @{ Label = 'a function global: definition'; Content = 'function global:Baz { }'; Kind = 'global-function'; Name = 'Baz' }
        @{ Label = 'New-Item on Function:\global:X'; Content = 'New-Item -Path Function:\global:Baz -Value { }'; Kind = 'global-function'; Name = 'Baz' }
        @{ Label = 'Set-Item on function:global:X'; Content = 'Set-Item function:global:Baz -Value { }'; Kind = 'global-function'; Name = 'Baz' }
        @{ Label = 'Set-Location'; Content = 'Set-Location -Path ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'Push-Location'; Content = 'Push-Location ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'the cd alias'; Content = 'cd ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'the chdir alias'; Content = 'chdir ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'the sl alias'; Content = 'sl ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'the pushd alias'; Content = 'pushd ''C:\'''; Kind = 'location'; Name = 'location' }
        @{ Label = 'an Environment CurrentDirectory assignment'; Content = '[Environment]::CurrentDirectory = ''C:\'''; Kind = 'process-directory'; Name = 'process-directory' }
        @{ Label = 'IO.Directory SetCurrentDirectory'; Content = '[IO.Directory]::SetCurrentDirectory(''C:\'')'; Kind = 'process-directory'; Name = 'process-directory' }
        @{ Label = 'System.IO.Directory SetCurrentDirectory'; Content = '[System.IO.Directory]::SetCurrentDirectory(''C:\'')'; Kind = 'process-directory'; Name = 'process-directory' }
    ) {
        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $Content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 1 -Because "the form '$Content' is one write"
        $findings[0].Kind | Should -BeExactly $Kind
        $findings[0].Name | Should -BeExactly $Name
        $findings[0].Line | Should -Be 1
        $findings[0].Path | Should -BeExactly 'tests/scripts/sample.Tests.ps1'
    }

    It 'LS-K02 does not report <Label>' -ForEach @(
        @{ Label = 'text inside a here-string'; Content = "`$text = @'`n`$env:FOO = 1`n'@" }
        @{ Label = 'text inside a command string'; Content = 'pwsh -Command ''$env:FOO = 1; Set-Location C:\''' }
        @{ Label = 'a Mock-named Set-Location'; Content = 'Mock Set-Location { }' }
        @{ Label = 'a Mock-named Remove-Item'; Content = 'Mock -CommandName Remove-Item -MockWith { }' }
        @{ Label = 'a Set-Variable with a local scope'; Content = 'Set-Variable -Name BAR -Value 1 -Scope 1' }
        @{ Label = 'a function without a global: prefix'; Content = 'function Baz { }' }
        @{ Label = 'a read of an env variable'; Content = '$value = $env:FOO' }
        @{ Label = 'a script-scope variable assignment'; Content = '$script:BAR = 1' }
    ) {
        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $Content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 0 -Because "'$Content' changes no process state"
    }

    It 'LS-K03 reports the exact line of a write below other statements' {
        # Arrange
        $content = "`$first = 1`n`n    `$env:LATE_NAME = 'x'`n"

        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].Line | Should -Be 3
        $findings[0].Name | Should -BeExactly 'LATE_NAME'
    }

    It 'LS-K04 keys a dynamic name on its expression text' {
        # Arrange
        $content = 'Set-Item -Path "Env:$name" -Value 1'

        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].Name | Should -BeExactly '$name'
    }

    It 'LS-K05 sorts findings by line and normalizes backslashes in the path' {
        # Arrange
        $content = "`$env:B_NAME = 'b'`n`$global:A_NAME = 'a'`nSet-Location 'C:\'`n"

        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests\scripts\sample.Tests.ps1'
            })

        # Assert
        @($findings | ForEach-Object Line) | Should -Be @(1, 2, 3)
        @($findings | ForEach-Object Kind) | Should -Be @('env', 'global-variable', 'location')
        @($findings | ForEach-Object Path | Select-Object -Unique) | Should -Be @('tests/scripts/sample.Tests.ps1')
    }

    It 'LS-K06 returns nothing for a script with no state operation' {
        # Act
        $findings = @(InModuleScope PoshQC {
                Get-PoshQCLeakFinding -Content 'Describe d { It i { 1 | Should -Be 1 } }' -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 0
    }
}

Describe 'Get-PoshQCLeakFinding restore pairing (issue #1096)' {
    It 'LS-R01 does not report a write paired by <Label>' -ForEach @(
        @{ Label = 'R1 with a finally restore'; Content = 'try { $env:FOO = 1 } finally { $env:FOO = $prior }' }
        @{ Label = 'R1 at a deeper nesting'; Content = 'try { if ($ok) { foreach ($i in 1) { $env:FOO = 1 } } } finally { Remove-Item Env:FOO }' }
        @{ Label = 'R2 with a following try'; Content = "Push-Location 'C:\'`ntry { 1 } finally { Pop-Location }" }
        @{ Label = 'R3 with a variable restore'; Content = "`$prior = `$env:FOO`n`$env:FOO = 'a'`n`$env:FOO = `$prior" }
        @{ Label = 'R3 with a null restore'; Content = "`$env:FOO = 'a'`n`$env:FOO = `$null" }
        @{ Label = 'R3 with a removal'; Content = "`$env:FOO = 'a'`nRemove-Item Env:FOO" }
        @{ Label = 'R3 with a member restore'; Content = "`$global:BAR = 1`n`$global:BAR = `$saved.Bar" }
        @{ Label = 'R4 with AfterEach in the enclosing Describe'; Content = 'Describe d { BeforeEach { $env:FOO = 1 }; AfterEach { $env:FOO = $p }; It i { } }' }
        @{ Label = 'R4 with AfterAll at file level'; Content = "BeforeAll { `$global:BAR = 1 }`nAfterAll { Remove-Variable -Name BAR -Scope Global }" }
        @{ Label = 'R5 with a cleanup helper'; Content = "function Reset-State { `$env:FOO = `$p }`nDescribe d { BeforeAll { `$env:FOO = 1 }; AfterAll { Reset-State } }" }
        @{ Label = 'a matching dynamic name'; Content = 'Set-Item -Path "Env:$name" -Value 1; Remove-Item "Env:$name"' }
        @{ Label = 'a function path normalized to the global key'; Content = "function global:gh { }`nAfterAll { Remove-Item Function:\gh }" }
        @{ Label = 'Pop-Location for a location change'; Content = "Set-Location 'C:\'`nPop-Location" }
        @{ Label = 'Set-Location to a saved location'; Content = "Set-Location 'C:\'`nSet-Location `$saved" }
        @{ Label = 'SetEnvironmentVariable with a saved value'; Content = "[Environment]::SetEnvironmentVariable('FOO', '1')`n[Environment]::SetEnvironmentVariable('FOO', `$prior)" }
    ) {
        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $Content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 0 -Because "'$Content' restores the key it writes"
    }

    It 'LS-R02 does not report writes located in <Label>' -ForEach @(
        @{ Label = 'a finally block'; Content = 'try { 1 } finally { $env:FOO = $null; Set-Location C:\ }' }
        @{ Label = 'an AfterEach block'; Content = 'AfterEach { $global:BAR = 2; Remove-Item Env:FOO }' }
        @{ Label = 'an AfterAll block'; Content = 'AfterAll { function global:Tidy { }; [Environment]::CurrentDirectory = ''C:\'' }' }
        @{ Label = 'a cleanup helper body'; Content = "function Reset-State { `$env:FOO = 'x' }`nAfterAll { Reset-State }" }
    ) {
        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $Content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 0 -Because 'a write in cleanup is a restore'
    }

    It 'LS-R03 reports <Label>' -ForEach @(
        @{ Label = 'a write with no restore'; Content = 'Describe d { It i { $env:FOO = 1 } }'; Count = 1 }
        @{ Label = 'a restore of a different name'; Content = 'try { $env:FOO = 1 } finally { $env:BAR = $prior }'; Count = 1 }
        @{ Label = 'an AfterEach that restores a different name'; Content = 'Describe d { BeforeEach { $env:FOO = 1 }; AfterEach { $env:OTHER = $p } }'; Count = 1 }
        @{ Label = 'a later literal assignment'; Content = "`$env:FOO = 'a'`n`$env:FOO = 'b'"; Count = 2 }
        @{ Label = 'a dynamic name restored under another expression'; Content = 'Set-Item -Path "Env:$name" -Value 1; Remove-Item "Env:$other"'; Count = 2 }
        @{ Label = 'a restore placed before the write'; Content = "`$env:FOO = `$prior`n`$env:FOO = 'a'"; Count = 2 }
        @{ Label = 'a restore in a nested block of a later statement'; Content = "`$env:FOO = 'a'`nif (`$ok) { `$env:FOO = `$prior }"; Count = 2 }
        @{ Label = 'a write in a catch clause'; Content = 'try { 1 } catch { $env:FOO = 1 } finally { $env:BAR = $p }'; Count = 1 }
        @{ Label = 'a cleanup helper reached only through another function'; Content = "function Reset-Inner { `$env:FOO = `$p }`nfunction Reset-Outer { Reset-Inner }`nBeforeAll { `$env:FOO = 1 }`nAfterAll { Reset-Outer }"; Count = 2 }
    ) {
        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $Content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be $Count -Because "'$Content' leaves state changed"
    }

    It 'LS-R04 throws a parse error that names the path' {
        # Act
        $action = {
            InModuleScope PoshQC {
                Get-PoshQCLeakFinding -Content 'function {' -Path 'tests\scripts\broken.Tests.ps1'
            }
        }

        # Assert
        $action | Should -Throw -ExpectedMessage '*tests/scripts/broken.Tests.ps1*'
    }

    It 'LS-R05 treats a .ps1 helper path the same as a Tests.ps1 path' {
        # Arrange
        $content = "function Set-Helper { `$env:HELPER_NAME = 'x' }`nfunction global:Import-Helper { }"

        # Act
        $result = InModuleScope PoshQC -Parameters @{ Content = $content } {
            param([string] $Content)
            @{
                Helper = @(Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/Support/Helper.ps1')
                Tests  = @(Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/Helper.Tests.ps1')
            }
        }

        # Assert
        $result.Helper.Count | Should -Be 2
        @($result.Helper | ForEach-Object { '{0}|{1}|{2}' -f $_.Line, $_.Kind, $_.Name }) |
            Should -Be @($result.Tests | ForEach-Object { '{0}|{1}|{2}' -f $_.Line, $_.Kind, $_.Name })
        $result.Helper[0].Path | Should -BeExactly 'tests/scripts/Support/Helper.ps1'
    }

    It 'LS-R06 consumes the restore that pairs an earlier write' {
        # Arrange: the second statement restores the first, so it is not reported as a write.
        $content = "`$global:BAR = 1`n`$global:BAR = `$saved`n`$global:BAR = 3"

        # Act
        $findings = @(InModuleScope PoshQC -Parameters @{ Content = $content } {
                param([string] $Content)
                Get-PoshQCLeakFinding -Content $Content -Path 'tests/scripts/sample.Tests.ps1'
            })

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].Line | Should -Be 3
    }
}
