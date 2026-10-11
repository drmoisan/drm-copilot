#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for scripts/dev-tools/HostTooling.psm1 (issue #847).

.DESCRIPTION
    Every host seam the module reaches from inside itself is mocked with
    -ModuleName HostTooling, and the default mocks throw so a test that reaches an
    unmocked seam fails. The only real seam calls are the direct calls to
    Invoke-HostNativeCommand (with the in-process cmdlet Write-Output, which starts
    no process), Get-HostEnvironmentVariable (a Process-scope read of PATH), and
    Set-HostEnvironmentVariable (with -WhatIf only). No test writes a file.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostTooling.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Set-HostEnvironmentVariable' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
}

AfterAll {
    Remove-Module HostTooling -ErrorAction SilentlyContinue
}

Describe 'Get-HostToolsManifestPath' {
    It 'returns the unnormalized dev-tools relative manifest path' {
        # Arrange / Act
        $actual = (Get-HostToolsManifestPath) -replace '\\', '/'

        # Assert: the '..' segment is preserved so error messages keep their form.
        $actual | Should -BeLike '*scripts/dev-tools/../host-tools.manifest.json'
    }
}

Describe 'Read-HostToolsManifest' {
    It 'returns $null without reading content when the file is absent' {
        # Arrange
        Mock -CommandName Test-Path -ModuleName HostTooling -MockWith { $false }
        Mock -CommandName Get-Content -ModuleName HostTooling -MockWith { throw 'Get-Content must not be called' }

        # Act
        $actual = Read-HostToolsManifest -Path 'C:\fixture\host-tools.manifest.json'

        # Assert
        $actual | Should -BeNullOrEmpty
        Should -Invoke -CommandName Get-Content -ModuleName HostTooling -Times 0 -Exactly
    }

    It 'returns the parsed manifest object when the file exists' {
        # Arrange
        Mock -CommandName Test-Path -ModuleName HostTooling -MockWith { $true }
        Mock -CommandName Get-Content -ModuleName HostTooling -MockWith { '{"requiredCommands":["git","node"]}' }

        # Act
        $actual = Read-HostToolsManifest -Path 'C:\fixture\host-tools.manifest.json'

        # Assert
        @($actual.requiredCommands) | Should -Be @('git', 'node')
    }
}

Describe 'Get-SessionPathFromMachineAndUser' {
    It 'joins Machine and User values with a semicolon' {
        # Arrange
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith {
            param([string]$Name, [string]$Target)
            $null = $Name
            if ($Target -eq 'Machine') { 'C:\machine-a;C:\machine-b' } else { 'C:\user-a' }
        }

        # Act
        $actual = Get-SessionPathFromMachineAndUser

        # Assert
        $actual | Should -BeExactly 'C:\machine-a;C:\machine-b;C:\user-a'
    }

    It 'returns only the Machine value when the User value is empty' {
        # Arrange
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith {
            param([string]$Name, [string]$Target)
            $null = $Name
            if ($Target -eq 'Machine') { 'C:\machine-a' } else { $null }
        }

        # Act
        $actual = Get-SessionPathFromMachineAndUser

        # Assert
        $actual | Should -BeExactly 'C:\machine-a'
    }

    It 'returns an empty string when neither value is set' {
        # Arrange
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith {
            param([string]$Name, [string]$Target)
            $null = $Name
            $null = $Target
            $null
        }

        # Act
        $actual = Get-SessionPathFromMachineAndUser

        # Assert
        $actual | Should -BeExactly ''
    }
}

Describe 'Get-HostEnvironmentVariable' {
    It 'returns the Process-scope PATH value' {
        # Arrange
        $expected = [System.Environment]::GetEnvironmentVariable('PATH', 'Process')

        # Act
        $actual = Get-HostEnvironmentVariable -Name 'PATH' -Target 'Process'

        # Assert
        $actual | Should -BeExactly $expected
    }
}

Describe 'Set-HostEnvironmentVariable' {
    It 'writes nothing under -WhatIf' {
        # Arrange
        $before = [System.Environment]::GetEnvironmentVariable('DRM847_UNSET_PROBE', 'Process')

        # Act
        Set-HostEnvironmentVariable -Name 'DRM847_UNSET_PROBE' -Value 'probe-value' -Target 'Process' -WhatIf

        # Assert
        $before | Should -BeNullOrEmpty
        [System.Environment]::GetEnvironmentVariable('DRM847_UNSET_PROBE', 'Process') | Should -BeNullOrEmpty
    }
}

Describe 'Invoke-HostNativeCommand' {
    It 'returns the command output without merging the error stream' {
        # Arrange / Act
        $actual = Invoke-HostNativeCommand -FilePath 'Write-Output' -ArgumentList @('alpha')

        # Assert
        @($actual.Output) | Should -Be @('alpha')
        $actual.ExitCode | Should -BeOfType [int]
    }

    It 'returns the command output when merging the error stream' {
        # Arrange / Act
        $actual = Invoke-HostNativeCommand -FilePath 'Write-Output' -ArgumentList @('alpha') -MergeErrorStream

        # Assert
        @($actual.Output) | Should -Be @('alpha')
        $actual.ExitCode | Should -BeOfType [int]
    }
}

Describe 'ConvertTo-HostToolVersion' {
    It 'parses a three-part version from tool text' {
        ConvertTo-HostToolVersion -Text 'Python 3.12.1' | Should -Be ([version]'3.12.1')
    }

    It 'parses a two-part version with a v prefix' {
        ConvertTo-HostToolVersion -Text 'v20.11' | Should -Be ([version]'20.11')
    }

    It 'returns $null for text without digits' {
        ConvertTo-HostToolVersion -Text 'not a version' | Should -BeNullOrEmpty
    }

    It 'returns $null for empty text' {
        ConvertTo-HostToolVersion -Text '' | Should -BeNullOrEmpty
    }

    It 'returns $null when the matched value cannot be cast to a version' {
        ConvertTo-HostToolVersion -Text 'build 99999999999.1' | Should -BeNullOrEmpty
    }
}

Describe 'Get-CommandVersion' {
    It 'returns $null when the command is not found' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostTooling -MockWith { $null }

        # Act
        $actual = Get-CommandVersion -Command 'python'

        # Assert
        $actual | Should -BeNullOrEmpty
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -Times 0 -Exactly
    }

    It 'returns the parsed version from the merged command output' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostTooling -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith {
            param([string]$FilePath, [string[]]$ArgumentList, [switch]$MergeErrorStream)
            $null = $FilePath
            $null = $ArgumentList
            $null = $MergeErrorStream
            [pscustomobject]@{ Output = @('Python 3.12.1'); ExitCode = 0 }
        }

        # Act
        $actual = Get-CommandVersion -Command 'python'

        # Assert
        $actual | Should -Be ([version]'3.12.1')
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'C:\fixture\python.exe' -and ($ArgumentList -join ' ') -eq '--version' -and $MergeErrorStream
        }
    }

    It 'returns $null when the command output is blank' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostTooling -MockWith { [pscustomobject]@{ Source = 'C:\fixture\node.exe' } }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith {
            param([string]$FilePath, [string[]]$ArgumentList, [switch]$MergeErrorStream)
            $null = $FilePath
            $null = $ArgumentList
            $null = $MergeErrorStream
            [pscustomobject]@{ Output = @(); ExitCode = 0 }
        }

        # Act
        $actual = Get-CommandVersion -Command 'node' -VersionArgs @('-v')

        # Assert
        $actual | Should -BeNullOrEmpty
    }

    It 'returns $null when the command output has no version' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostTooling -MockWith { [pscustomobject]@{ Source = 'C:\fixture\node.exe' } }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith {
            param([string]$FilePath, [string[]]$ArgumentList, [switch]$MergeErrorStream)
            $null = $FilePath
            $null = $ArgumentList
            $null = $MergeErrorStream
            [pscustomobject]@{ Output = @('unknown option'); ExitCode = 9 }
        }

        # Act
        $actual = Get-CommandVersion -Command 'node'

        # Assert
        $actual | Should -BeNullOrEmpty
    }
}
