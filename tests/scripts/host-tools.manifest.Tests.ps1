#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Shape and consumer tests for scripts/host-tools.manifest.json (issue #887).

.DESCRIPTION
    Reads only the committed manifest. The shape cases assert the top-level keys,
    pinned versions, and entry shapes. The consumer cases run the five
    HostVerification section functions over the committed manifest with every host
    seam mocked with -ModuleName HostVerification, so no process starts and no file
    is written.
#>

BeforeAll {
    $script:ManifestPath = (Resolve-Path "$PSScriptRoot/../../scripts/host-tools.manifest.json").Path
    $script:ManifestText = Get-Content -LiteralPath $script:ManifestPath -Raw
    $script:Manifest = $script:ManifestText | ConvertFrom-Json

    Import-Module (Resolve-Path "$PSScriptRoot/../../scripts/dev-tools/HostVerification.psm1").Path -Force
}

AfterAll {
    Remove-Module HostVerification, HostTooling -ErrorAction SilentlyContinue
}

Describe 'host-tools.manifest.json shape' {
    It 'AC01-MANIFEST-TOP-LEVEL-KEYS parses and carries the seven top-level keys' {
        # Arrange
        $expectedKeys = @(
            'installPackages',
            'powershellModules',
            'projectRepositories',
            'minimumVersions',
            'requiredCommands',
            'optionalCommands',
            'pythonTools'
        )

        # Act
        $actualKeys = @($script:Manifest.PSObject.Properties.Name)

        # Assert
        foreach ($key in $expectedKeys) {
            $actualKeys | Should -Contain $key -Because "the manifest must carry the top-level key '$key'"
        }

        @($script:Manifest.installPackages.windows.PSObject.Properties.Name) | Should -Contain 'winget'
    }

    It 'AC02-MINIMUM-VERSIONS-PINNED pins python, poetry, pwsh, and node and each casts to version' {
        # Arrange
        $expected = [ordered]@{
            python = '3.13.12'
            poetry = '2.3.2'
            pwsh   = '7.6.6'
            node   = '24.14.0'
        }

        foreach ($name in $expected.Keys) {
            # Act
            $value = [string]$script:Manifest.minimumVersions.$name

            # Assert
            $value | Should -BeExactly $expected[$name] -Because "minimumVersions.$name is pinned"
            { [version]$value } | Should -Not -Throw
        }
    }

    It 'AC03-POWERSHELL-MODULES-PINNED lists Pester 5.9.0 and PSScriptAnalyzer 1.22.0' {
        # Arrange
        $modules = @($script:Manifest.powershellModules)

        # Act
        $pester = @($modules | Where-Object { $_.name -eq 'Pester' })
        $analyzer = @($modules | Where-Object { $_.name -eq 'PSScriptAnalyzer' })

        # Assert
        $pester.Count | Should -Be 1
        $pester[0].minimumVersion | Should -BeExactly '5.9.0'
        $analyzer.Count | Should -Be 1
        $analyzer[0].minimumVersion | Should -BeExactly '1.22.0'
    }

    It 'AC04-ENTRY-SHAPES has non-empty winget id and name, an empty projectRepositories array, and non-empty command strings' {
        # Arrange
        $wingetEntries = @($script:Manifest.installPackages.windows.winget)

        # Assert: winget entries
        $wingetEntries.Count | Should -Be 6
        foreach ($entry in $wingetEntries) {
            [string]::IsNullOrWhiteSpace([string]$entry.id) | Should -BeFalse -Because 'every winget entry needs an id'
            [string]::IsNullOrWhiteSpace([string]$entry.name) | Should -BeFalse -Because 'every winget entry needs a name'
        }

        # Assert: projectRepositories is an explicit empty array in the committed text
        $script:ManifestText | Should -Match '"projectRepositories"\s*:\s*\[\s*\]'

        # Assert: command lists are non-empty lists of non-blank strings
        foreach ($listName in @('requiredCommands', 'optionalCommands', 'pythonTools')) {
            $items = @($script:Manifest.$listName)
            $items.Count | Should -BeGreaterThan 0 -Because "$listName must not be empty"
            foreach ($item in $items) {
                $item | Should -BeOfType [string]
                [string]::IsNullOrWhiteSpace($item) | Should -BeFalse -Because "$listName entries must not be blank"
            }
        }
    }
}

Describe 'HostVerification sections over the committed manifest' {
    BeforeEach {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ Source = 'C:\fixture\tool.exe' }
        }
        Mock -CommandName Get-CommandVersion -ModuleName HostVerification -MockWith {
            param([string]$Command, [string[]]$VersionArgs)
            $null = $VersionArgs
            switch ($Command) {
                'python' { [version]'3.13.12' }
                'pwsh' { [version]'7.6.6' }
                'node' { [version]'24.14.0' }
                default { $null }
            }
        }
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $true; Version = [version]'2.3.2'; Source = 'poetry' }
        }
        Mock -CommandName Get-Module -ModuleName HostVerification -MockWith {
            param([string[]]$Name)
            $moduleName = @($Name)[0]
            switch ($moduleName) {
                'Pester' { [pscustomobject]@{ Name = $moduleName; Version = [version]'5.9.0' } }
                'PSScriptAnalyzer' { [pscustomobject]@{ Name = $moduleName; Version = [version]'1.22.0' } }
                default { $null }
            }
        }
        Mock -CommandName Invoke-PoetryCommand -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ Output = @('tool 1.0.0'); ExitCode = 0 }
        }
    }

    It 'AC06-CORE-VERSION-ZERO-FAILURES reports no core version failure' {
        { $script:sectionResult = Test-HostCoreVersion -Manifest $script:Manifest } | Should -Not -Throw
        $script:sectionResult.FailureCount | Should -Be 0
    }

    It 'AC06-REQUIRED-COMMAND-ZERO-FAILURES reports no required command failure' {
        { $script:sectionResult = Test-HostRequiredCommand -Manifest $script:Manifest -IsWindowsHost $false } | Should -Not -Throw
        $script:sectionResult.FailureCount | Should -Be 0
    }

    It 'AC06-OPTIONAL-COMMAND-ZERO-FAILURES reports no optional command failure' {
        { $script:sectionResult = Test-HostOptionalCommand -Manifest $script:Manifest } | Should -Not -Throw
        $script:sectionResult.FailureCount | Should -Be 0
    }

    It 'AC06-POWERSHELL-MODULE-ZERO-FAILURES reports no PowerShell module failure' {
        { $script:sectionResult = Test-HostPowerShellModule -Manifest $script:Manifest } | Should -Not -Throw
        $script:sectionResult.FailureCount | Should -Be 0
    }

    It 'AC06-POETRY-TOOL-ZERO-FAILURES reports no poetry tool failure' {
        { $script:sectionResult = Test-HostPoetryTool -Manifest $script:Manifest } | Should -Not -Throw
        $script:sectionResult.FailureCount | Should -Be 0
    }
}
