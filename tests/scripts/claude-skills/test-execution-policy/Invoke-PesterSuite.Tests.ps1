#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for Invoke-PesterSuite.ps1, the pester suite of the test-execution launcher (issue #1158, D26).

.DESCRIPTION
    Every case runs against the .claude and .agents copies. The script is dot-sourced for the function
    cases; the script-file cases invoke it with the call operator and inject PesterSuiteSeams in the It
    scope, so no module is imported by the script and no suite runs.
#>

BeforeDiscovery {
    $script:Copies = @(
        @{ Copy = '.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1' }
        @{ Copy = '.agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1' }
    )
}

Describe 'Invoke-PesterSuite.ps1 (<Copy>)' -ForEach $script:Copies {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
        $script:ScriptPath = Join-Path $repoRoot $Copy
        $script:Names = @('Root', 'WorkerCount', 'ExcludeTag', 'ExcludeTestFileSuffix')

        $modulePath = Join-Path $repoRoot 'scripts/powershell/PoshQC/PoshQC.psm1'
        $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
        foreach ($module in Get-Module -Name PoshQC) {
            $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
            if ($loadedPath -ne $resolvedModulePath) { Remove-Module -ModuleInfo $module -Force }
        }
        Import-Module -Name $resolvedModulePath -Force
        # Dot-source after the forced import: a PoshQC-hosted shard runs this file in the PoshQC session
        # state, and the forced re-import would discard functions defined there before it.
        . $script:ScriptPath
    }

    It 'keeps a dash-leading word that is not a declared name as a value' {
        # Act
        $table = ConvertTo-PesterSuiteParameter -ArgumentList @('-ExcludeTestFileSuffix', '-integration.test.ts', '.integration.tests.ps1') -ParameterName $script:Names

        # Assert
        ($table['ExcludeTestFileSuffix'] -join ',') | Should -BeExactly '-integration.test.ts,.integration.tests.ps1'
    }

    It 'matches parameter names case-insensitively' {
        # Act
        $table = ConvertTo-PesterSuiteParameter -ArgumentList @('-excludetag', 'Integration') -ParameterName $script:Names

        # Assert
        $table['ExcludeTag'] | Should -BeExactly 'Integration'
    }

    It 'appends the values of a repeated key' {
        # Act
        $table = ConvertTo-PesterSuiteParameter -ArgumentList @('-ExcludeTag', 'Integration', '-ExcludeTag', 'Golden') -ParameterName $script:Names

        # Assert
        ($table['ExcludeTag'] -join ',') | Should -BeExactly 'Integration,Golden'
    }

    It 'gives a key with no value the value $true' {
        # Act
        $table = ConvertTo-PesterSuiteParameter -ArgumentList @('-ExcludeTag') -ParameterName $script:Names

        # Assert
        $table['ExcludeTag'] | Should -BeTrue
        $table['ExcludeTag'] | Should -BeOfType ([bool])
    }

    It 'throws for a value before any key' {
        # Act / Assert
        { ConvertTo-PesterSuiteParameter -ArgumentList @('stray') -ParameterName $script:Names } | Should -Throw 'Invoke-PesterSuite: unexpected argument*'
    }

    It 'exits 1 from the script-file entry for a value before any key' {
        # Arrange
        $PesterSuiteSeams = @{
            ImportModule       = { param([string] $Path) [void] $Path }
            GetParameterName   = { @('Root', 'ExcludeTag') }
            InvokeParallelTest = { param([hashtable] $Parameter) [void] $Parameter; [pscustomobject]@{ ExitCode = 0 } }
        }
        [void] $PesterSuiteSeams

        # Act
        & $script:ScriptPath stray 2>$null

        # Assert
        $LASTEXITCODE | Should -Be 1
    }

    It 'replaces the default Root with a given -Root' {
        # Arrange
        $recorded = @{}

        # Act
        $null = Invoke-PesterSuite -ArgumentList @('-Root', 'sub') -RepositoryRoot '/repo' -ImportModule { param([string] $Path) [void] $Path } -GetParameterName { @('Root') } -InvokeParallelTest { param([hashtable] $Parameter) $recorded['Root'] = $Parameter['Root']; [pscustomobject]@{ ExitCode = 0 } }.GetNewClosure()

        # Assert
        $recorded['Root'] | Should -BeExactly 'sub'
    }

    It 'imports the PoshQC manifest joined to RepositoryRoot and returns the ExitCode' {
        # Arrange
        $recorded = @{}

        # Act
        $code = Invoke-PesterSuite -ArgumentList @() -RepositoryRoot '/repo' -ImportModule { param([string] $Path) $recorded['Path'] = $Path }.GetNewClosure() -GetParameterName { @('Root') } -InvokeParallelTest { param([hashtable] $Parameter) $recorded['Root'] = $Parameter['Root']; [pscustomobject]@{ ExitCode = 1 } }.GetNewClosure()

        # Assert
        $recorded['Path'] | Should -BeExactly (Join-Path '/repo' 'scripts/powershell/PoshQC/PoshQC.psd1')
        $recorded['Root'] | Should -BeExactly '.'
        $code | Should -Be 1
    }

    It 'reads ExcludeTag and ExcludeTestFileSuffix through the default GetParameterName' {
        # Arrange
        $recorded = @{}

        # Act
        $null = Invoke-PesterSuite -ArgumentList @('-ExcludeTag', 'Integration', '-ExcludeTestFileSuffix', '-integration.test.ts') -RepositoryRoot '/repo' -ImportModule { param([string] $Path) [void] $Path } -InvokeParallelTest { param([hashtable] $Parameter) foreach ($key in $Parameter.Keys) { $recorded[$key] = $Parameter[$key] }; [pscustomobject]@{ ExitCode = 0 } }.GetNewClosure()

        # Assert
        $recorded['ExcludeTag'] | Should -BeExactly 'Integration'
        $recorded['ExcludeTestFileSuffix'] | Should -BeExactly '-integration.test.ts'
        $recorded.ContainsKey('WorkerCount') | Should -BeFalse
    }
}
