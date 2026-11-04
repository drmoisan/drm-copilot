Set-StrictMode -Version Latest

Describe "DrmCopilotPromptSupport.ps1" {
    BeforeAll {
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
        $script:supportScriptPath = Join-Path -Path $scriptRoot -ChildPath "../../../scripts/dev-tools/DrmCopilotPromptSupport.ps1"
        . $script:supportScriptPath
        $script:originalPrompt = $function:prompt

        # Portable fixture root: fully qualified on every host (the checkout drive on Windows,
        # '/' elsewhere) and never created; every repository and environment path joins from it.
        $script:FixtureRoot = Join-Path ([System.IO.Path]::GetPathRoot($scriptRoot)) 'enter-drmcopilotshell-root'
        $script:RepoRoot = Join-Path $script:FixtureRoot 'drm-copilot'
        $script:VenvPath = Join-Path $script:RepoRoot '.venv'
    }

    AfterEach {
        $function:prompt = $script:originalPrompt
    }

    Context "Get-DrmCopilotPromptPath" {
        It "returns a root marker when the current location is the repo root" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath $script:RepoRoot `
                -LocationPath $script:RepoRoot

            $result | Should -Be "\"
        }

        It "returns a repo-relative path with a leading backslash for nested folders" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath $script:RepoRoot `
                -LocationPath (Join-Path $script:RepoRoot 'scripts' 'dev-tools')

            $result | Should -Be "\scripts\dev-tools"
        }

        It "falls back to the absolute path when the location is outside the repo root" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath $script:RepoRoot `
                -LocationPath $script:FixtureRoot

            $result | Should -Be $script:FixtureRoot
        }
    }

    Context "Set-DrmCopilotPrompt" {
        It "renders the requested prompt name with the repo-relative folder" {
            # The location delegate is built from literal text so it keeps its value after the
            # production code re-binds it with GetNewClosure.
            $docsPath = Join-Path $script:RepoRoot 'docs'
            Set-DrmCopilotPrompt `
                -RepoRootPath $script:RepoRoot `
                -PromptName "drm-copilot" `
                -GetLocationPath ([scriptblock]::Create("'$docsPath'"))

            (& $function:prompt) | Should -Be "(drm-copilot):\docs> "
        }
    }

    Context "Start-DrmCopilotPromptSession" {
        It "activates the virtual environment with the requested prompt name and installs the custom prompt" {
            $script:capturedActivationScriptPath = $null
            $script:capturedPromptName = $null
            $scriptsPath = Join-Path $script:RepoRoot 'scripts'

            Start-DrmCopilotPromptSession `
                -RepoRootPath $script:RepoRoot `
                -VirtualEnvironmentPath $script:VenvPath `
                -PromptName "drm-copilot" `
                -ActivateEnvironment {
                param(
                    [string]$ActivationScriptPath,
                    [string]$ResolvedPromptName
                )

                $script:capturedActivationScriptPath = $ActivationScriptPath
                $script:capturedPromptName = $ResolvedPromptName
            } `
                -GetLocationPath ([scriptblock]::Create("'$scriptsPath'")) `
                -ResolveActivationScriptPath {
                param([string]$RepoRootPath, [string]$VirtualEnvironmentPath)
                $null = $RepoRootPath
                Join-Path -Path $VirtualEnvironmentPath -ChildPath "Scripts\Activate.ps1"
            }

            $script:capturedActivationScriptPath | Should -Be (Join-Path -Path $script:VenvPath -ChildPath "Scripts\Activate.ps1")
            $script:capturedPromptName | Should -Be "drm-copilot"
            (& $function:prompt) | Should -Be "(drm-copilot):\scripts> "
        }
    }

    Context "Get-DrmCopilotNormalizedPath" {
        It "resolves a relative path against the PowerShell location, not the process directory" {
            # Arrange: Set-Location does not move the process directory, so the two differ here.
            $priorProcessDirectory = [Environment]::CurrentDirectory
            Push-Location -LiteralPath $PSScriptRoot
            try {
                [Environment]::CurrentDirectory = [System.IO.Path]::GetPathRoot($PSScriptRoot)

                # Act
                $result = Get-DrmCopilotNormalizedPath -Path 'relative-repo'

                # Assert
                $result | Should -BeExactly (Join-Path $PSScriptRoot 'relative-repo')
            }
            finally {
                [Environment]::CurrentDirectory = $priorProcessDirectory
                Pop-Location
            }
        }

        It "returns an absolute path unchanged apart from a trimmed trailing separator" {
            $result = Get-DrmCopilotNormalizedPath -Path ($script:RepoRoot + [System.IO.Path]::DirectorySeparatorChar)

            $result | Should -BeExactly $script:RepoRoot
        }
    }

    Context "Resolve-DrmCopilotActivationScriptPath" {
        It "resolves a relative virtual environment path against the PowerShell location, not the process directory" {
            # Arrange: no real path is read; the existence probe is mocked.
            Mock Test-Path { $true }
            $expected = Join-Path $PSScriptRoot (Join-Path -Path 'relative-venv' -ChildPath "Scripts\Activate.ps1")
            $priorProcessDirectory = [Environment]::CurrentDirectory
            Push-Location -LiteralPath $PSScriptRoot
            try {
                [Environment]::CurrentDirectory = [System.IO.Path]::GetPathRoot($PSScriptRoot)

                # Act
                $result = Resolve-DrmCopilotActivationScriptPath -RepoRootPath $script:RepoRoot -VirtualEnvironmentPath 'relative-venv'

                # Assert
                $result | Should -BeExactly $expected
            }
            finally {
                [Environment]::CurrentDirectory = $priorProcessDirectory
                Pop-Location
            }
        }

        It "throws when the activation script is absent" {
            Mock Test-Path { $false }

            { Resolve-DrmCopilotActivationScriptPath -RepoRootPath $script:RepoRoot } |
                Should -Throw "*Virtual environment activation script not found*"
        }
    }
}
