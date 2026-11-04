Set-StrictMode -Version Latest

# Regression guard for issue #1066: run-actionlint.Tests.ps1 must leave the process environment and
# $global:LASTEXITCODE as it found them. The guarded suite runs through a nested in-process Invoke-Pester
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
    }

    BeforeEach {
        $script:savedEnvironment = & $script:getEnvironmentSnapshot
        $script:savedHadLastExitCode = $null -ne (Get-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue)
        $script:savedLastExitCode = if ($script:savedHadLastExitCode) { $global:LASTEXITCODE } else { $null }
    }

    AfterEach {
        & $script:restoreEnvironment $script:savedEnvironment
        if ($script:savedHadLastExitCode) {
            $global:LASTEXITCODE = $script:savedLastExitCode
        } else {
            Remove-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
        }
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

    It 'run-actionlint.Tests.ps1 leaves global LASTEXITCODE as the nested harness leaves it' {
        # Arrange
        $global:LASTEXITCODE = $script:lastExitCodeSentinel
        $null = & $script:invokeNestedPester (& $script:newControlContainer)
        $controlValue = $global:LASTEXITCODE
        $global:LASTEXITCODE = $script:lastExitCodeSentinel

        # Act
        $null = & $script:invokeNestedPester (New-PesterContainer -Path $script:guardedTestPath)
        $targetValue = $global:LASTEXITCODE

        # Assert
        $targetValue | Should -Be $controlValue -Because 'run-actionlint.Tests.ps1 must restore global LASTEXITCODE after each test'
    }
}
