#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the helper functions in
    scripts/dev-tools/SideloadedExtensionPublish.psm1 (issue #847).

.DESCRIPTION
    Every host seam the module can reach is mocked with -ModuleName
    SideloadedExtensionPublish, and the top-level default mocks throw, so a test that
    reaches an unmocked seam fails. The retry backoff is observed through a -Sleep
    scriptblock created in module scope that records its argument instead of sleeping.
    No test starts a process, sleeps, or writes a file.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/SideloadedExtensionPublish.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Invoke-SideloadedExtensionProcess' }
    Mock -CommandName New-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName Remove-Item -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Remove-Item' }
    Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Stop-Process' }
    Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith { throw 'unmocked host seam: Get-Process' }
}

AfterAll {
    Remove-Module SideloadedExtensionPublish -ErrorAction SilentlyContinue
}

Describe 'Resolve-ExtensionProjectRoot' {
    It 'selects the extension folder when it contains a VS Code extension manifest' {
        # Arrange
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath)
            $LiteralPath -in @('/repo/package.json', '/repo/extensions/drm-copilot/package.json')
        }
        Mock -CommandName Get-Content -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath, [switch]$Raw)
            $null = $Raw
            switch ($LiteralPath) {
                '/repo/package.json' { '{"name":"repo-package"}' }
                '/repo/extensions/drm-copilot/package.json' { '{"name":"drm-copilot","engines":{"vscode":"^1.108.0"}}' }
                default { throw "Unexpected path: $LiteralPath" }
            }
        }

        # Act
        $result = Resolve-ExtensionProjectRoot -RepoRoot '/repo'

        # Assert
        $result | Should -Be '/repo/extensions/drm-copilot'
    }

    It 'prefers the extension folder when both root and extension package.json have engines.vscode' {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath)
            $LiteralPath -in @('/repo/package.json', '/repo/extensions/drm-copilot/package.json')
        }
        Mock -CommandName Get-Content -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath, [switch]$Raw)
            $null = $Raw
            switch ($LiteralPath) {
                '/repo/package.json' { '{"name":"repo-extension","engines":{"vscode":"^1.108.0"}}' }
                '/repo/extensions/drm-copilot/package.json' { '{"name":"drm-copilot","engines":{"vscode":"^1.108.0"}}' }
                default { throw "Unexpected path: $LiteralPath" }
            }
        }

        $result = Resolve-ExtensionProjectRoot -RepoRoot '/repo'

        $result | Should -Be '/repo/extensions/drm-copilot'
    }

    It 'keeps repo root when only root package.json has engines.vscode' {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath)
            $LiteralPath -eq '/repo/package.json'
        }
        Mock -CommandName Get-Content -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$LiteralPath, [switch]$Raw)
            $null = $Raw
            if ($LiteralPath -eq '/repo/package.json') {
                return '{"name":"repo-extension","engines":{"vscode":"^1.108.0"}}'
            }

            throw "Unexpected path: $LiteralPath"
        }

        $result = Resolve-ExtensionProjectRoot -RepoRoot '/repo'

        $result | Should -Be '/repo'
    }

    It 'throws when neither manifest declares engines.vscode' {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $true }
        Mock -CommandName Get-Content -ModuleName SideloadedExtensionPublish -MockWith { '{"name":"plain-package"}' }

        { Resolve-ExtensionProjectRoot -RepoRoot '/repo' } | Should -Throw -ExpectedMessage "Could not find a VS Code extension manifest with 'engines.vscode'. Checked: /repo/package.json, /repo/extensions/drm-copilot/package.json"
    }
}

Describe 'Test-IsVsCodeExtensionManifest' {
    It 'treats a manifest without engines.vscode as non-extension metadata' {
        $manifest = [pscustomobject]@{ name = 'repo-package'; engines = [pscustomobject]@{} }

        Test-IsVsCodeExtensionManifest -Manifest $manifest | Should -BeFalse
    }

    It 'treats a manifest with a blank vscode engine as non-extension metadata' {
        $manifest = [pscustomobject]@{ name = 'repo-package'; engines = [pscustomobject]@{ vscode = '  ' } }

        Test-IsVsCodeExtensionManifest -Manifest $manifest | Should -BeFalse
    }

    It 'treats a manifest without engines as non-extension metadata' {
        Test-IsVsCodeExtensionManifest -Manifest ([pscustomobject]@{ name = 'repo-package' }) | Should -BeFalse
    }

    It 'accepts a manifest with a vscode engine' {
        $manifest = [pscustomobject]@{ name = 'drm-copilot'; engines = [pscustomobject]@{ vscode = '^1.108.0' } }

        Test-IsVsCodeExtensionManifest -Manifest $manifest | Should -BeTrue
    }
}

Describe 'Get-PackageManifest' {
    It 'throws when the package.json file is missing' {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $false }

        { Get-PackageManifest -PackageJsonPath '/repo/package.json' } | Should -Throw -ExpectedMessage 'package.json not found: /repo/package.json'
    }

    It 'throws a parse error that names the file when the JSON is invalid' {
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $true }
        Mock -CommandName Get-Content -ModuleName SideloadedExtensionPublish -MockWith { '{"name": ' }

        { Get-PackageManifest -PackageJsonPath '/repo/package.json' } | Should -Throw -ExpectedMessage "Failed to parse package.json at '/repo/package.json': *"
    }
}

Describe 'Assert-RequiredCommandAvailable' {
    It 'does not throw when command is available on PATH' {
        Mock -CommandName Get-Command -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ Name = 'npm' } }

        { Assert-RequiredCommandAvailable -CommandName 'npm' -InstallHint 'Install Node.js' } | Should -Not -Throw
    }

    It 'throws a clear prerequisite message when command is missing' {
        Mock -CommandName Get-Command -ModuleName SideloadedExtensionPublish -MockWith { $null }

        { Assert-RequiredCommandAvailable -CommandName 'npm' -InstallHint 'Install Node.js' } | Should -Throw "*Required command 'npm' was not found on PATH*Install Node.js*"
    }
}

Describe 'Invoke-ExternalCommand' {
    It 'runs the command line through cmd.exe /c and returns quietly on exit 0' {
        # Arrange
        Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ ExitCode = 0 } }

        # Act
        $result = Invoke-ExternalCommand -FilePath 'npm' -ArgumentList @('ci', '--no-audit') -WorkingDirectory 'C:\fixture\ext'

        # Assert
        $result | Should -BeNullOrEmpty
        Should -Invoke -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $ProcessParameters.FilePath -eq 'cmd.exe' -and
            ($ProcessParameters.ArgumentList -join '|') -eq '/c|npm ci --no-audit' -and
            $ProcessParameters.WorkingDirectory -eq 'C:\fixture\ext' -and
            $ProcessParameters.Wait -and $ProcessParameters.NoNewWindow -and $ProcessParameters.PassThru
        }
    }

    It 'throws with ExitCode, FilePath, and Arguments data on a nonzero exit' {
        # Arrange
        Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ ExitCode = 2 } }
        $caught = $null

        # Act
        try {
            Invoke-ExternalCommand -FilePath 'npm' -ArgumentList @('run', 'compile') -WorkingDirectory 'C:\fixture\ext'
        }
        catch {
            $caught = $_
        }

        # Assert
        $caught | Should -Not -BeNullOrEmpty
        $caught.Exception.Message | Should -BeExactly 'Command failed with exit code 2: npm run compile'
        $caught.Exception.Data['ExitCode'] | Should -Be 2
        $caught.Exception.Data['FilePath'] | Should -BeExactly 'npm'
        $caught.Exception.Data['Arguments'] | Should -BeExactly 'run compile'
    }

    It 'passes only the file path when the argument list is empty' {
        Mock -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ ExitCode = 0 } }

        Invoke-ExternalCommand -FilePath 'npm' -WorkingDirectory 'C:\fixture\ext'

        Should -Invoke -CommandName Invoke-SideloadedExtensionProcess -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            ($ProcessParameters.ArgumentList -join '|') -eq '/c|npm'
        }
    }
}

Describe 'Invoke-NpmCiWithRetry' {
    BeforeEach {
        $script:recordSleep = InModuleScope SideloadedExtensionPublish {
            $script:sleepCalls = [System.Collections.Generic.List[int]]::new()
            { param([int]$Seconds) $script:sleepCalls.Add($Seconds) }
        }
        # One state object referenced from both the module scope and this test scope, so the
        # mock bodies below count attempts regardless of the session state they run in.
        $script:npmState = InModuleScope SideloadedExtensionPublish {
            $script:npmState = [pscustomobject]@{ Attempts = 0 }
            $script:npmState
        }
    }

    It 'returns after a first-attempt success without sleeping' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { }

        Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -Sleep $script:recordSleep

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            ($ArgumentList -join ' ') -eq 'ci --no-audit --no-fund --loglevel=error' -and $FilePath -eq 'npm' -and $WorkingDirectory -eq 'C:\fixture\ext'
        }
        @(InModuleScope SideloadedExtensionPublish { $script:sleepCalls.ToArray() }).Count | Should -Be 0
    }

    It 'retries after an EPERM failure and then succeeds' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith {
            $script:npmState.Attempts++
            if ($script:npmState.Attempts -eq 1) { throw 'npm ERR! code EPERM' }
        }

        Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -Sleep $script:recordSleep -WarningAction SilentlyContinue

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 2 -Exactly
        @(InModuleScope SideloadedExtensionPublish { $script:sleepCalls.ToArray() }) | Should -Be @(5)
    }

    It 'treats exit code -4048 as EPERM' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith {
            $script:npmState.Attempts++
            if ($script:npmState.Attempts -eq 1) {
                $exception = [System.Exception]::new('Command failed with exit code -4048: npm ci')
                $exception.Data['ExitCode'] = -4048
                throw $exception
            }
        }

        Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -Sleep $script:recordSleep -WarningAction SilentlyContinue

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 2 -Exactly
    }

    It 'AC06-EPERM-RETRY-LIMIT rethrows EPERM after three attempts' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { throw 'EPERM: operation not permitted, rename' }

        { Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -Sleep $script:recordSleep -WarningAction SilentlyContinue } | Should -Throw -ExpectedMessage 'EPERM: operation not permitted, rename'

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 3 -Exactly
    }

    It 'AC06-EPERM-BACKOFF passes DelaySeconds times the attempt number to the sleep seam' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { throw 'operation not permitted' }

        { Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -DelaySeconds 2 -MaxAttempts 3 -Sleep $script:recordSleep -WarningAction SilentlyContinue } | Should -Throw

        @(InModuleScope SideloadedExtensionPublish { $script:sleepCalls.ToArray() }) | Should -Be @(2, 4)
    }

    It 'AC06-NONEPERM-RETHROW rethrows a non-EPERM failure without sleeping' {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { throw 'npm ERR! code E404' }

        { Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -Sleep $script:recordSleep } | Should -Throw -ExpectedMessage 'npm ERR! code E404'

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly
        @(InModuleScope SideloadedExtensionPublish { $script:sleepCalls.ToArray() }).Count | Should -Be 0
    }

    It 'AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache' {
        # Arrange
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith {
            param([string]$FilePath, [string[]]$ArgumentList, [string]$WorkingDirectory)
            $null = $FilePath
            $null = $WorkingDirectory
            if ($ArgumentList[0] -eq 'ci') {
                $script:npmState.Attempts++
                if ($script:npmState.Attempts -eq 1) { throw 'npm ERR! code EPERM' }
            }
        }
        Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ ProcessName = 'node'; Id = 4242 } }
        Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $true }
        Mock -CommandName Remove-Item -ModuleName SideloadedExtensionPublish -MockWith { }

        # Act
        Invoke-NpmCiWithRetry -WorkingDirectory 'C:\fixture\ext' -ForceCleanup -Sleep $script:recordSleep -WarningAction SilentlyContinue

        # Assert
        Should -Invoke -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter { $Id -eq 4242 }
        Should -Invoke -CommandName Remove-Item -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            ($LiteralPath -replace '\\', '/') -eq 'C:/fixture/ext/node_modules'
        }
        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            ($ArgumentList -join ' ') -eq 'cache clean --force'
        }
    }
}

Describe 'Stop-NodeProcess' {
    It 'stops nothing when no node process is running' {
        Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith { }
        Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { }

        InModuleScope SideloadedExtensionPublish { Stop-NodeProcess }

        Should -Invoke -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
    }

    It 'stops every running node process' {
        Mock -CommandName Get-Process -ModuleName SideloadedExtensionPublish -MockWith {
            [pscustomobject]@{ ProcessName = 'node'; Id = 101 }
            [pscustomobject]@{ ProcessName = 'node'; Id = 102 }
        }
        Mock -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -MockWith { }

        InModuleScope SideloadedExtensionPublish { Stop-NodeProcess }

        Should -Invoke -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -Times 2 -Exactly
        Should -Invoke -CommandName Stop-Process -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter { $Id -eq 102 }
    }
}

Describe 'Invoke-ProjectCompile' {
    BeforeEach {
        Mock -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -MockWith { }
    }

    It 'runs the npm compile script when package.json defines one' {
        Mock -CommandName Get-PackageManifest -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ scripts = [pscustomobject]@{ compile = 'tsc -p ./' } } }

        Invoke-ProjectCompile -ProjectRoot 'C:\fixture\ext'

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'npm' -and ($ArgumentList -join ' ') -eq 'run compile' -and $WorkingDirectory -eq 'C:\fixture\ext'
        }
    }

    It 'runs tsc when only tsconfig.json exists' {
        Mock -CommandName Get-PackageManifest -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ scripts = [pscustomobject]@{ test = 'jest' } } }
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $true }

        Invoke-ProjectCompile -ProjectRoot 'C:\fixture\ext'

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'npx' -and ($ArgumentList -join ' ') -eq '--yes tsc -p ./'
        }
    }

    It 'skips compilation when neither a compile script nor tsconfig.json exists' {
        Mock -CommandName Get-PackageManifest -ModuleName SideloadedExtensionPublish -MockWith { [pscustomobject]@{ name = 'no-scripts' } }
        Mock -CommandName Test-Path -ModuleName SideloadedExtensionPublish -MockWith { $false }

        Invoke-ProjectCompile -ProjectRoot 'C:\fixture\ext'

        Should -Invoke -CommandName Invoke-ExternalCommand -ModuleName SideloadedExtensionPublish -Times 0 -Exactly
    }
}
