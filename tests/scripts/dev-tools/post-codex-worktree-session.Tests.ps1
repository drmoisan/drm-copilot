Set-StrictMode -Version Latest

BeforeAll {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    . (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../.codex/scripts/post-codex-worktree-session.ps1"
}

Describe "post-codex-worktree-session.ps1 - Get-CodexCustomizationCopyPlan" {
    BeforeEach {
        . (Import-ScriptFunction -Path $script:scriptPath -Name "ConvertTo-NormalizedRootPath")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-RelativeCustomizationPath")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-CodexCustomizationCopyPlan")
    }

    It "returns no operations when source and worktree roots resolve to the same path" {
        $result = Get-CodexCustomizationCopyPlan `
            -SourceRoot "C:/repo" `
            -WorktreeRoot "C:/repo" `
            -TestPath { param([string] $LiteralPath) throw "Unexpected TestPath: $LiteralPath" } `
            -GetChildItem { param([string] $LiteralPath) throw "Unexpected GetChildItem: $LiteralPath" }

        @($result).Count | Should -Be 0
    }

    It "returns no operations when source customization folders are missing" {
        $result = Get-CodexCustomizationCopyPlan `
            -SourceRoot "C:/repo" `
            -WorktreeRoot "C:/repo-wt" `
            -TestPath { param([string] $LiteralPath) $null = $LiteralPath; $false } `
            -GetChildItem { param([string] $LiteralPath) throw "Unexpected GetChildItem: $LiteralPath" }

        @($result).Count | Should -Be 0
    }

    It "plans .codex copy operations before .agents copy operations" {
        $filesByFolder = @{
            "C:/repo/.codex"  = @(
                [pscustomobject]@{ FullName = "C:/repo/.codex/config.toml" }
            )
            "C:/repo/.agents" = @(
                [pscustomobject]@{ FullName = "C:/repo/.agents/skills/example/SKILL.md" }
            )
        }

        $result = @(
            Get-CodexCustomizationCopyPlan `
                -SourceRoot "C:/repo" `
                -WorktreeRoot "C:/repo-wt" `
                -TestPath {
                param([string] $LiteralPath)
                return $filesByFolder.ContainsKey($LiteralPath)
            } `
                -GetChildItem {
                param([string] $LiteralPath)
                return $filesByFolder[$LiteralPath]
            }
        )

        $result.Count | Should -Be 2
        $result[0].CustomizationFolder | Should -Be ".codex"
        $result[0].SourcePath | Should -Be "C:/repo/.codex/config.toml"
        $result[0].DestinationPath | Should -Be "C:/repo-wt/.codex/config.toml"
        $result[1].CustomizationFolder | Should -Be ".agents"
        $result[1].SourcePath | Should -Be "C:/repo/.agents/skills/example/SKILL.md"
        $result[1].DestinationPath | Should -Be "C:/repo-wt/.agents/skills/example/SKILL.md"
    }
}

