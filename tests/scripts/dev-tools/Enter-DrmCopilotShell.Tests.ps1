Set-StrictMode -Version Latest

Describe "DrmCopilotPromptSupport.ps1" {
    BeforeAll {
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
        $script:supportScriptPath = Join-Path -Path $scriptRoot -ChildPath "../../../scripts/dev-tools/DrmCopilotPromptSupport.ps1"
        . $script:supportScriptPath
        $script:originalPrompt = $function:prompt
    }

    AfterEach {
        $function:prompt = $script:originalPrompt
    }

    Context "Get-DrmCopilotPromptPath" {
        It "returns a root marker when the current location is the repo root" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath "C:\Users\DanMoisan\repos\drm-copilot" `
                -LocationPath "C:\Users\DanMoisan\repos\drm-copilot"

            $result | Should -Be "\"
        }

        It "returns a repo-relative path with a leading backslash for nested folders" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath "C:\Users\DanMoisan\repos\drm-copilot" `
                -LocationPath "C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools"

            $result | Should -Be "\scripts\dev-tools"
        }

        It "falls back to the absolute path when the location is outside the repo root" {
            $result = Get-DrmCopilotPromptPath `
                -RepoRootPath "C:\Users\DanMoisan\repos\drm-copilot" `
                -LocationPath "C:\Users\DanMoisan"

            $result | Should -Be "C:\Users\DanMoisan"
        }
    }

    Context "Set-DrmCopilotPrompt" {
        It "renders the requested prompt name with the repo-relative folder" {
            Set-DrmCopilotPrompt `
                -RepoRootPath "C:\Users\DanMoisan\repos\drm-copilot" `
                -PromptName "drm-copilot" `
                -GetLocationPath { "C:\Users\DanMoisan\repos\drm-copilot\docs" }

            (& $function:prompt) | Should -Be "(drm-copilot):\docs> "
        }
    }

    Context "Start-DrmCopilotPromptSession" {
        It "activates the virtual environment with the requested prompt name and installs the custom prompt" {
            $script:capturedActivationScriptPath = $null
            $script:capturedPromptName = $null

            Start-DrmCopilotPromptSession `
                -RepoRootPath "C:\Users\DanMoisan\repos\drm-copilot" `
                -VirtualEnvironmentPath "C:\Users\DanMoisan\repos\drm-copilot\.venv" `
                -PromptName "drm-copilot" `
                -ActivateEnvironment {
                param(
                    [string]$ActivationScriptPath,
                    [string]$ResolvedPromptName
                )

                $script:capturedActivationScriptPath = $ActivationScriptPath
                $script:capturedPromptName = $ResolvedPromptName
            } `
                -GetLocationPath { "C:\Users\DanMoisan\repos\drm-copilot\scripts" } `
                -ResolveActivationScriptPath {
                param([string]$RepoRootPath, [string]$VirtualEnvironmentPath)
                $null = $RepoRootPath
                Join-Path -Path $VirtualEnvironmentPath -ChildPath "Scripts\Activate.ps1"
            }

            $script:capturedActivationScriptPath | Should -Be "C:\Users\DanMoisan\repos\drm-copilot\.venv\Scripts\Activate.ps1"
            $script:capturedPromptName | Should -Be "drm-copilot"
            (& $function:prompt) | Should -Be "(drm-copilot):\scripts> "
        }
    }
}



