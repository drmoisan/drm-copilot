Set-StrictMode -Version Latest

# Regression guard for issue #1066: run-actionlint.Tests.ps1 must leave the process environment,
# $global:LASTEXITCODE, global functions, and loaded modules as it found them. The guarded suite runs through a nested in-process Invoke-Pester
# (no result file, no coverage, verbosity None), and the process environment is compared before and after
# with case-insensitive keys, so the comparison holds on Windows (Path) and Linux (PATH) alike.
Describe 'run-actionlint.Tests.ps1 environment isolation' {
    BeforeAll {
        $script:guardedTestPath = Join-Path -Path $PSScriptRoot -ChildPath 'run-actionlint.Tests.ps1'
        $script:lastExitCodeSentinel = 41

        $script:getEnvironmentSnapshot = {
            $snapshot = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($entry in [System.Environment]::GetEnvironmentVariables().GetEnumerator()) {
                $snapshot[[string]$entry.Key] = [string]$entry.Value
            }
            return , $snapshot
        }

        # Returns the sorted, upper-cased names of variables that were added, removed, or changed (ordinal value comparison).
        $script:getEnvironmentDifference = {
            param($Before, $After)
            $differing = [System.Collections.Generic.List[string]]::new()
            foreach ($key in $After.Keys) {
                if (-not $Before.ContainsKey($key) -or -not [string]::Equals($Before[$key], $After[$key], [System.StringComparison]::Ordinal)) {
                    $differing.Add($key.ToUpperInvariant())
                }
            }
            foreach ($key in $Before.Keys) {
                if (-not $After.ContainsKey($key)) { $differing.Add($key.ToUpperInvariant()) }
            }
            return @($differing | Sort-Object -Unique)
        }

        $script:restoreEnvironment = {
            param($Snapshot)
            foreach ($key in @([System.Environment]::GetEnvironmentVariables().Keys)) {
                if (-not $Snapshot.ContainsKey([string]$key)) { [System.Environment]::SetEnvironmentVariable([string]$key, $null) }
            }
            foreach ($key in $Snapshot.Keys) { [System.Environment]::SetEnvironmentVariable($key, $Snapshot[$key]) }
        }

        $script:invokeNestedPester = {
            param($Container)
            $configuration = New-PesterConfiguration
            $configuration.Run.Container = $Container
            $configuration.Run.PassThru = $true
            $configuration.Run.Exit = $false
            $configuration.Output.Verbosity = 'None'
            $configuration.TestResult.Enabled = $false
            $configuration.CodeCoverage.Enabled = $false
            return Invoke-Pester -Configuration $configuration
        }

        $script:newControlContainer = {
            New-PesterContainer -ScriptBlock {
                Describe 'nested control' {
                    It 'passes' { $true | Should -BeTrue }
                }
            }
        }

        # The sentinel container sets global LASTEXITCODE to the sentinel before the next container runs.
        $script:newSentinelContainer = {
            New-PesterContainer -Data @{ Sentinel = $script:lastExitCodeSentinel } -ScriptBlock {
                param($Sentinel)
                # Referenced here as well, because the analyzer does not see the use inside the nested BeforeAll.
                $null = $Sentinel
                Describe 'nested LASTEXITCODE sentinel' {
                    BeforeAll { $global:LASTEXITCODE = $Sentinel }
                    It 'passes' { $true | Should -BeTrue }
                }
            }
        }

        # The probe container stores the global LASTEXITCODE it finds in the holder hashtable.
        $script:newProbeContainer = {
            param($Holder)
            New-PesterContainer -Data @{ Holder = $Holder } -ScriptBlock {
                param($Holder)
                # Referenced here as well, because the analyzer does not see the use inside the nested It.
                $null = $Holder
                Describe 'nested LASTEXITCODE probe' {
                    It 'reads global LASTEXITCODE' { $Holder.Value = $global:LASTEXITCODE }
                }
            }
        }

        # Returns the function names visible from the caller and the names of the loaded modules.
        $script:getGlobalStateSnapshot = {
            return @{
                Functions = @(Get-ChildItem -Path Function: | ForEach-Object { $_.Name } | Sort-Object -Unique)
                Modules   = @(Get-Module | ForEach-Object { $_.Name } | Sort-Object -Unique)
            }
        }

        # Returns 'function added <name>', 'module removed <name>', and similar entries; names compare case-insensitively.
        $script:getGlobalStateDelta = {
            param($Before, $After)
            $delta = [System.Collections.Generic.List[string]]::new()
            foreach ($kind in @('Functions', 'Modules')) {
                $label = if ($kind -eq 'Functions') { 'function' } else { 'module' }
                $beforeNames = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Before[$kind]), [System.StringComparer]::OrdinalIgnoreCase)
                $afterNames = [System.Collections.Generic.HashSet[string]]::new([string[]]@($After[$kind]), [System.StringComparer]::OrdinalIgnoreCase)
                foreach ($name in $After[$kind]) {
                    if (-not $beforeNames.Contains($name)) { $delta.Add(('{0} added {1}' -f $label, $name)) }
                }
                foreach ($name in $Before[$kind]) {
                    if (-not $afterNames.Contains($name)) { $delta.Add(('{0} removed {1}' -f $label, $name)) }
                }
            }
            return @($delta | Sort-Object -Unique)
        }

        # Returns the entries of Left that are not in Right (case-insensitive).
        $script:getEntriesNotIn = {
            param($Left, $Right)
            $known = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Right), [System.StringComparer]::OrdinalIgnoreCase)
            return @(@($Left) | Where-Object { -not $known.Contains($_) })
        }

        # Removes every loaded module and every function that the snapshot did not hold, modules first,
        # because removing a module also removes the functions it exported.
        $script:restoreGlobalState = {
            param($Snapshot)
            $modules = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Snapshot.Modules), [System.StringComparer]::OrdinalIgnoreCase)
            foreach ($module in @(Get-Module)) {
                if (-not $modules.Contains($module.Name)) { Remove-Module -ModuleInfo $module -Force -ErrorAction SilentlyContinue }
            }
            $functions = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Snapshot.Functions), [System.StringComparer]::OrdinalIgnoreCase)
            foreach ($name in @(Get-ChildItem -Path Function: | ForEach-Object { $_.Name })) {
                if (-not $functions.Contains($name)) { Remove-Item -LiteralPath ('Function:\{0}' -f $name) -Force -ErrorAction SilentlyContinue }
            }
        }
    }

    BeforeEach {
        $script:savedEnvironment = & $script:getEnvironmentSnapshot
        $script:savedHadLastExitCode = $null -ne (Get-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue)
        $script:savedLastExitCode = if ($script:savedHadLastExitCode) { $global:LASTEXITCODE } else { $null }
        $script:savedGlobalState = & $script:getGlobalStateSnapshot
    }

    AfterEach {
        & $script:restoreEnvironment $script:savedEnvironment
        if ($script:savedHadLastExitCode) {
            $global:LASTEXITCODE = $script:savedLastExitCode
        } else {
            Remove-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
        }
        & $script:restoreGlobalState $script:savedGlobalState
    }

    It 'nested harness leaves the process environment unchanged for an empty container' {
        # Arrange
        $before = & $script:getEnvironmentSnapshot

        # Act
        $result = & $script:invokeNestedPester (& $script:newControlContainer)
        $differingKeys = @(& $script:getEnvironmentDifference $before (& $script:getEnvironmentSnapshot))

        # Assert
        $result.PassedCount | Should -Be 1 -Because 'the nested control container holds one passing test'
        $differingKeys | Should -BeNullOrEmpty -Because ('the nested harness alone must not change the environment; differing keys: {0}' -f ($differingKeys -join ', '))
    }

    It 'run-actionlint.Tests.ps1 leaves every process environment variable unchanged' {
        # Arrange
        $before = & $script:getEnvironmentSnapshot

        # Act
        $result = & $script:invokeNestedPester (New-PesterContainer -Path $script:guardedTestPath)
        $differingKeys = @(& $script:getEnvironmentDifference $before (& $script:getEnvironmentSnapshot))

        # Assert
        $result.TotalCount | Should -BeGreaterThan 0 -Because 'the guarded suite must be discovered and run'
        $differingKeys | Should -BeNullOrEmpty -Because ('run-actionlint.Tests.ps1 must restore every environment variable it changes; differing keys: {0}' -f ($differingKeys -join ', '))
    }

    It 'run-actionlint.Tests.ps1 leaves global LASTEXITCODE at the value set before it runs' {
        # Arrange
        $controlHolder = @{ Value = $null }
        $targetHolder = @{ Value = $null }
        $null = & $script:invokeNestedPester @((& $script:newSentinelContainer), (& $script:newProbeContainer $controlHolder))

        # Act
        $null = & $script:invokeNestedPester @((& $script:newSentinelContainer), (New-PesterContainer -Path $script:guardedTestPath), (& $script:newProbeContainer $targetHolder))

        # Assert
        $controlHolder.Value | Should -Be $script:lastExitCodeSentinel -Because 'precondition: when this fails, the nested harness overwrote global LASTEXITCODE between containers, so the check below cannot observe run-actionlint.Tests.ps1'
        $targetHolder.Value | Should -Be $script:lastExitCodeSentinel -Because 'run-actionlint.Tests.ps1 must restore global LASTEXITCODE after each test'
    }

    It 'run-actionlint.Tests.ps1 leaves global functions and loaded modules as the nested harness leaves them' {
        # Arrange
        $controlBefore = & $script:getGlobalStateSnapshot
        $null = & $script:invokeNestedPester (& $script:newControlContainer)
        $controlDelta = @(& $script:getGlobalStateDelta $controlBefore (& $script:getGlobalStateSnapshot))
        $targetBefore = & $script:getGlobalStateSnapshot

        # Act
        $result = & $script:invokeNestedPester (New-PesterContainer -Path $script:guardedTestPath)
        $targetDelta = @(& $script:getGlobalStateDelta $targetBefore (& $script:getGlobalStateSnapshot))
        $unexplained = @(& $script:getEntriesNotIn $targetDelta $controlDelta)

        # Assert
        $result.TotalCount | Should -BeGreaterThan 0 -Because 'the guarded suite must be discovered and run'
        $unexplained | Should -BeNullOrEmpty -Because ('run-actionlint.Tests.ps1 must remove the global functions and modules it adds; entries: {0}' -f ($unexplained -join ', '))
    }
}
