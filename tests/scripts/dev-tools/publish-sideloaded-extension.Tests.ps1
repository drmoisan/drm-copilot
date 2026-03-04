Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))

Describe "publish-sideloaded-extension.ps1 - Resolve-ExtensionProjectRoot" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/publish-sideloaded-extension.ps1"
    }

    BeforeEach {
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-PackageManifest")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Test-IsVsCodeExtensionManifest")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Resolve-ExtensionProjectRoot")
    }

    It "selects the extension folder when root package.json is not a VS Code extension manifest" {
        $repoRoot = "C:\repo"
        $repoPackagePath = "C:\repo\package.json"
        $extensionRoot = "C:\repo\extensions\scaffold-extension"
        $extensionPackagePath = "C:\repo\extensions\scaffold-extension\package.json"

        Mock -CommandName Test-Path -MockWith {
            param([string]$LiteralPath)

            switch ($LiteralPath) {
                $repoPackagePath { return $true }
                $extensionPackagePath { return $true }
                default { return $false }
            }
        }

        Mock -CommandName Get-Content -MockWith {
            param([string]$LiteralPath, [switch]$Raw)
            $null = $Raw

            switch ($LiteralPath) {
                $repoPackagePath { return '{"name":"repo-package"}' }
                $extensionPackagePath { return '{"name":"scaffold-extension","engines":{"vscode":"^1.108.0"}}' }
                default { throw "Unexpected path: $LiteralPath" }
            }
        }

        $result = Resolve-ExtensionProjectRoot -RepoRoot $repoRoot
        $result | Should -Be $extensionRoot
    }

    It "keeps repo root when package.json already has engines.vscode" {
        $repoRoot = "C:\repo"
        $repoPackagePath = "C:\repo\package.json"

        Mock -CommandName Test-Path -MockWith {
            param([string]$LiteralPath)
            return ($LiteralPath -eq $repoPackagePath)
        }

        Mock -CommandName Get-Content -MockWith {
            param([string]$LiteralPath, [switch]$Raw)
            $null = $Raw

            if ($LiteralPath -eq $repoPackagePath) {
                return '{"name":"repo-extension","engines":{"vscode":"^1.108.0"}}'
            }

            throw "Unexpected path: $LiteralPath"
        }

        $result = Resolve-ExtensionProjectRoot -RepoRoot $repoRoot
        $result | Should -Be $repoRoot
    }
}

Describe "scaffold extension package identity" {
    It "uses canonical drm-copilot name metadata" {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
        $packageJsonPath = Join-Path $repoRoot "extensions/scaffold-extension/package.json"
        $manifest = Get-Content -LiteralPath $packageJsonPath -Raw | ConvertFrom-Json

        $manifest.name | Should -Be "drm-copilot"
        $manifest.displayName | Should -Be "drm-copilot"
    }
}
