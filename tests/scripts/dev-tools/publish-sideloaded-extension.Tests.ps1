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
        $repoRoot = "/repo"
        $repoPackagePath = "/repo/package.json"
        $extensionRoot = "/repo/extensions/drm-copilot"
        $extensionPackagePath = "/repo/extensions/drm-copilot/package.json"

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
                $extensionPackagePath { return '{"name":"drm-copilot","engines":{"vscode":"^1.108.0"}}' }
                default { throw "Unexpected path: $LiteralPath" }
            }
        }

        $result = Resolve-ExtensionProjectRoot -RepoRoot $repoRoot
        $result | Should -Be $extensionRoot
    }

    It "keeps repo root when package.json already has engines.vscode" {
        $repoRoot = "/repo"
        $repoPackagePath = "/repo/package.json"

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

    It "treats a manifest without engines.vscode as non-extension metadata" {
        $manifest = [pscustomobject]@{
            name    = 'repo-package'
            engines = [pscustomobject]@{}
        }

        $result = Test-IsVsCodeExtensionManifest -Manifest $manifest

        $result | Should -BeFalse
    }
}

Describe "scaffold extension package identity" {
    It "uses canonical drm-copilot name metadata" {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../../..")
        $packageJsonPath = Join-Path $repoRoot "extensions/drm-copilot/package.json"
        $manifest = Get-Content -LiteralPath $packageJsonPath -Raw | ConvertFrom-Json

        $manifest.name | Should -Be "drm-copilot"
        $manifest.displayName | Should -Be "drm-copilot"
    }
}
