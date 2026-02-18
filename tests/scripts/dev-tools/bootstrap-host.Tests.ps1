Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))

Describe "bootstrap-host.ps1 - Resolve-DependencyCatalog" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\scripts\dev-tools\bootstrap-host.ps1"
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Resolve-DependencyCatalog')
        }
    }

    It "Resolve-DependencyCatalog scenario A returns catalog including git, python, poetry, pwsh, node, and npm" {
        $catalog = Resolve-DependencyCatalog
        $names = @($catalog | ForEach-Object { $_.name })

        $names | Should -Contain 'git'
        $names | Should -Contain 'python'
        $names | Should -Contain 'poetry'
        $names | Should -Contain 'pwsh'
        $names | Should -Contain 'node'
        $names | Should -Contain 'npm'
    }

    It "Resolve-DependencyCatalog scenario B returns deterministic error when devcontainer input parse fails" {
        Mock -CommandName Get-Content -MockWith {
            throw 'mock parse failure'
        }

        { Resolve-DependencyCatalog } | Should -Throw -ExpectedMessage '*devcontainer parse failed*'
    }
}

Describe "bootstrap-host.ps1 - Test-DependencyPresence" {
    BeforeAll {
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Test-DependencyPresence')
        }
    }

    It "Test-DependencyPresence scenario C returns missing status and remediation hint when command is not found" {
        Mock -CommandName Get-Command -MockWith { $null }

        $result = Test-DependencyPresence -DependencyName 'gh' -RequiredVersion '0.0.0'

        $result.status | Should -Be 'missing'
        $result.message | Should -Not -BeNullOrEmpty
    }

    It "Test-DependencyPresence scenario D returns missing status with detected and required version guidance" {
        Mock -CommandName Get-Command -MockWith {
            [pscustomobject]@{ Source = 'C:\\tools\\pwsh.exe' }
        }
        Mock -CommandName Invoke-Expression -MockWith { '7.4.9' }

        $result = Test-DependencyPresence -DependencyName 'pwsh' -RequiredVersion '7.5.0'

        $result.status | Should -Be 'missing'
        $result.message | Should -Match '7.4.9'
        $result.message | Should -Match '7.5.0'
    }

    It "Test-DependencyPresence scenario E returns present status when version is compatible" {
        Mock -CommandName Get-Command -MockWith {
            [pscustomobject]@{ Source = 'C:\\tools\\poetry.exe' }
        }
        Mock -CommandName Invoke-Expression -MockWith { '2.2.1' }

        $result = Test-DependencyPresence -DependencyName 'poetry' -RequiredVersion '2.2.1'

        $result.status | Should -Be 'present'
    }
}

Describe "bootstrap-host.ps1 - Resolve-InstallStrategy" {
    BeforeAll {
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Resolve-InstallStrategy')
        }
    }

    It "Resolve-InstallStrategy scenario F returns deterministic install action metadata on supported Windows" {
        $dependency = [pscustomobject]@{
            name             = 'node'
            required_version = '0.0.0'
        }

        $result = Resolve-InstallStrategy -Dependency $dependency -OperatingSystem 'windows'

        $result.install_action | Should -Not -BeNullOrEmpty
    }

    It "Resolve-InstallStrategy scenario G returns unsupported classification for unsupported operating system" {
        $dependency = [pscustomobject]@{
            name             = 'git'
            required_version = '0.0.0'
        }

        $result = Resolve-InstallStrategy -Dependency $dependency -OperatingSystem 'plan9'

        $result.status | Should -Be 'unsupported'
    }
}

Describe "bootstrap-host.ps1 - Invoke-BootstrapVerify" {
    BeforeAll {
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Invoke-BootstrapVerify')
        }
    }

    It "Invoke-BootstrapVerify scenario H returns non-zero exit code when required dependency is missing" {
        $dependencies = @(
            [pscustomobject]@{ name = 'git'; status = 'missing' }
        )

        $exitCode = Invoke-BootstrapVerify -DependencyRows $dependencies -Format 'text'
        $exitCode | Should -Not -Be 0
    }

    It "Invoke-BootstrapVerify scenario I returns deterministic validation message for unknown dependency filter" {
        {
            Invoke-BootstrapVerify -DependencyRows @() -Format 'text' -Only 'unknown-tool'
        } | Should -Throw -ExpectedMessage '*Unknown dependency filter*'
    }
}

Describe "bootstrap-host.ps1 - Invoke-BootstrapInstall" {
    BeforeAll {
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Invoke-BootstrapInstall')
        }
    }

    It "Invoke-BootstrapInstall scenario J performs no install calls in dry-run mode" {
        Mock -CommandName Invoke-DependencyInstall -MockWith {
            param($Dependency)
            return $Dependency
        }

        $dependencies = @(
            [pscustomobject]@{ name = 'node'; status = 'missing'; is_auto_installable = $true }
        )

        $null = Invoke-BootstrapInstall -DependencyRows $dependencies -DryRun

        Should -Invoke -CommandName Invoke-DependencyInstall -Times 0 -Exactly
    }

    It "Invoke-BootstrapInstall scenario K emits skipped on second run for already-present dependency" {
        $callCount = 0
        Mock -CommandName Invoke-DependencyInstall -MockWith {
            param($Dependency)
            $script:callCount++
            if ($script:callCount -eq 1) {
                return [pscustomobject]@{ name = $Dependency.name; status = 'installed' }
            }

            return [pscustomobject]@{ name = $Dependency.name; status = 'skipped' }
        }

        $dependencies = @(
            [pscustomobject]@{ name = 'poetry'; status = 'missing'; is_auto_installable = $true }
        )

        $first = Invoke-BootstrapInstall -DependencyRows $dependencies
        $second = Invoke-BootstrapInstall -DependencyRows $dependencies

        [void]$first
        $second[0].status | Should -Be 'skipped'
    }

    It "Invoke-BootstrapInstall scenario L returns aggregate non-zero behavior and continues processing after first dependency fails" {
        $processed = New-Object System.Collections.Generic.List[string]
        Mock -CommandName Invoke-DependencyInstall -MockWith {
            param($Dependency)
            [void]$processed.Add($Dependency.name)
            if ($Dependency.name -eq 'git') {
                return [pscustomobject]@{ name = 'git'; status = 'failed' }
            }

            return [pscustomobject]@{ name = $Dependency.name; status = 'installed' }
        }

        $dependencies = @(
            [pscustomobject]@{ name = 'git'; status = 'missing'; is_auto_installable = $true },
            [pscustomobject]@{ name = 'node'; status = 'missing'; is_auto_installable = $true }
        )

        $result = Invoke-BootstrapInstall -DependencyRows $dependencies

        ($result | Where-Object { $_.name -eq 'git' }).status | Should -Be 'failed'
        $processed | Should -Contain 'node'
    }
}

Describe "bootstrap-host.ps1 - Format-BootstrapReport" {
    BeforeAll {
        if (Test-Path -Path $script:scriptPath) {
            . (Import-ScriptFunction -Path $script:scriptPath -Name 'Format-BootstrapReport')
        }
    }

    It "Format-BootstrapReport scenario M outputs JSON rows containing required schema keys" {
        $rows = @(
            [pscustomobject]@{
                name             = 'git'
                required_version = '0.0.0'
                detected_version = '2.47.0'
                status           = 'present'
                install_action   = 'none'
                message          = 'already installed'
            }
        )

        $jsonOutput = Format-BootstrapReport -Rows $rows -Format 'json'
        $parsed = $jsonOutput | ConvertFrom-Json

        foreach ($item in @($parsed)) {
            $item.PSObject.Properties.Name | Should -Contain 'name'
            $item.PSObject.Properties.Name | Should -Contain 'required_version'
            $item.PSObject.Properties.Name | Should -Contain 'detected_version'
            $item.PSObject.Properties.Name | Should -Contain 'status'
            $item.PSObject.Properties.Name | Should -Contain 'install_action'
            $item.PSObject.Properties.Name | Should -Contain 'message'
        }
    }
}
