Set-StrictMode -Version Latest

BeforeAll {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    . (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1"
}

Describe "post-codex-worktree-session.ps1 - Get-CodexCustomizationCopyPlan" {
    BeforeEach {
        . $script:scriptPath
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

Describe "post-codex-worktree-session.ps1 - Invoke-CodexCustomizationCopyPlan" {
    BeforeEach {
        . $script:scriptPath
    }

    It "does not throw when same-root planning produces no copy operations" {
        $copyOperations = @(
            Get-CodexCustomizationCopyPlan `
                -SourceRoot "C:/repo" `
                -WorktreeRoot "C:/repo" `
                -TestPath { param([string] $LiteralPath) throw "Unexpected TestPath: $LiteralPath" } `
                -GetChildItem { param([string] $LiteralPath) throw "Unexpected GetChildItem: $LiteralPath" }
        )

        {
            Invoke-CodexCustomizationCopyPlan `
                -CopyOperation $copyOperations `
                -NewDirectory { param([string] $LiteralPath) throw "Unexpected NewDirectory: $LiteralPath" } `
                -CopyFile { param([string] $SourcePath, [string] $DestinationPath) throw "Unexpected CopyFile: $SourcePath -> $DestinationPath" }
        } | Should -Not -Throw
    }

    It "does not throw when missing source customization folders produce no copy operations" {
        $copyOperations = @(
            Get-CodexCustomizationCopyPlan `
                -SourceRoot "C:/repo" `
                -WorktreeRoot "C:/repo-wt" `
                -TestPath { param([string] $LiteralPath) $null = $LiteralPath; $false } `
                -GetChildItem { param([string] $LiteralPath) throw "Unexpected GetChildItem: $LiteralPath" }
        )

        {
            Invoke-CodexCustomizationCopyPlan `
                -CopyOperation $copyOperations `
                -NewDirectory { param([string] $LiteralPath) throw "Unexpected NewDirectory: $LiteralPath" } `
                -CopyFile { param([string] $SourcePath, [string] $DestinationPath) throw "Unexpected CopyFile: $SourcePath -> $DestinationPath" }
        } | Should -Not -Throw
    }

    It "copies .codex and .agents from explicit source root to an initially missing worktree root" {
        $filesByFolder = @{
            "C:/repo/.codex"  = @(
                [pscustomobject]@{ FullName = "C:/repo/.codex/config.toml" }
            )
            "C:/repo/.agents" = @(
                [pscustomobject]@{ FullName = "C:/repo/.agents/skills/example/SKILL.md" }
            )
        }
        $createdDirectories = [System.Collections.Generic.List[string]]::new()
        $copiedFiles = [System.Collections.Generic.List[string]]::new()

        $copyOperations = @(
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

        Invoke-CodexCustomizationCopyPlan `
            -CopyOperation $copyOperations `
            -NewDirectory {
            param([string] $LiteralPath)
            $createdDirectories.Add($LiteralPath)
        } `
            -CopyFile {
            param([string] $SourcePath, [string] $DestinationPath)
            $copiedFiles.Add("$SourcePath -> $DestinationPath")
        }

        $createdDirectories.ToArray() | Should -Be @(
            "C:/repo-wt/.codex",
            "C:/repo-wt/.agents/skills/example"
        )
        $copiedFiles.ToArray() | Should -Be @(
            "C:/repo/.codex/config.toml -> C:/repo-wt/.codex/config.toml",
            "C:/repo/.agents/skills/example/SKILL.md -> C:/repo-wt/.agents/skills/example/SKILL.md"
        )
    }

    It "is rerunnable when destination .codex and .agents entries already exist" {
        $copyOperations = @(
            [pscustomobject]@{
                Action              = "Copy"
                CustomizationFolder = ".codex"
                SourcePath          = "C:/repo/.codex/config.toml"
                DestinationPath     = "C:/repo-wt/.codex/config.toml"
            },
            [pscustomobject]@{
                Action              = "Copy"
                CustomizationFolder = ".agents"
                SourcePath          = "C:/repo/.agents/skills/example/SKILL.md"
                DestinationPath     = "C:/repo-wt/.agents/skills/example/SKILL.md"
            }
        )
        $copiedFiles = [System.Collections.Generic.List[string]]::new()

        foreach ($run in 1..2) {
            Invoke-CodexCustomizationCopyPlan `
                -CopyOperation $copyOperations `
                -NewDirectory {
                param([string] $LiteralPath)
                $LiteralPath | Should -Match "^C:/repo-wt/"
            } `
                -CopyFile {
                param([string] $SourcePath, [string] $DestinationPath)
                $copiedFiles.Add("run$run $SourcePath -> $DestinationPath")
            }
        }

        $copiedFiles.ToArray() | Should -Be @(
            "run1 C:/repo/.codex/config.toml -> C:/repo-wt/.codex/config.toml",
            "run1 C:/repo/.agents/skills/example/SKILL.md -> C:/repo-wt/.agents/skills/example/SKILL.md",
            "run2 C:/repo/.codex/config.toml -> C:/repo-wt/.codex/config.toml",
            "run2 C:/repo/.agents/skills/example/SKILL.md -> C:/repo-wt/.agents/skills/example/SKILL.md"
        )
    }

    It "stops execution when a copy operation fails" {
        $copyOperations = @(
            [pscustomobject]@{
                Action              = "Copy"
                CustomizationFolder = ".codex"
                SourcePath          = "C:/repo/.codex/config.toml"
                DestinationPath     = "C:/repo-wt/.codex/config.toml"
            }
        )

        {
            Invoke-CodexCustomizationCopyPlan `
                -CopyOperation $copyOperations `
                -NewDirectory { param([string] $LiteralPath) $null = $LiteralPath } `
                -CopyFile {
                param([string] $SourcePath, [string] $DestinationPath)
                throw "copy failed: $SourcePath -> $DestinationPath"
            }
        } | Should -Throw "copy failed: C:/repo/.codex/config.toml -> C:/repo-wt/.codex/config.toml"
    }
}

Describe "post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot" {
    BeforeEach {
        . $script:scriptPath
    }

    It "prefers explicit source root over git metadata" {
        $result = Resolve-CodexCustomizationSourceRoot `
            -SourceRoot "C:\repo" `
            -WorktreeRoot "C:/repo-wt" `
            -InvokeGit { param([string[]] $GitArgs) throw "Unexpected git call: $GitArgs" }

        $result | Should -Be "C:/repo"
    }

    It "resolves source root from git common-dir metadata when available" {
        $result = Resolve-CodexCustomizationSourceRoot `
            -WorktreeRoot "C:/repo-wt" `
            -InvokeGit {
            param([string[]] $GitArgs)
            if (($GitArgs -join " ") -match "rev-parse --git-common-dir") {
                return "C:/repo/.git"
            }

            throw "Unexpected git call: $GitArgs"
        }

        $result | Should -Be "C:/repo"
    }

    It "resolves source root from main worktree metadata when common-dir is unavailable" {
        $result = Resolve-CodexCustomizationSourceRoot `
            -WorktreeRoot "C:/repo-wt" `
            -InvokeGit {
            param([string[]] $GitArgs)
            if (($GitArgs -join " ") -match "rev-parse --git-common-dir") {
                return ""
            }

            if (($GitArgs -join " ") -match "worktree list --porcelain") {
                return @("worktree C:/repo", "HEAD 476b110", "branch refs/heads/main")
            }

            throw "Unexpected git call: $GitArgs"
        }

        $result | Should -Be "C:/repo"
    }

    It "falls back deterministically to the repository root implied by the script path" {
        $result = Resolve-CodexCustomizationSourceRoot `
            -WorktreeRoot "C:/repo-wt" `
            -ScriptRoot "C:/repo/.codex/scripts" `
            -InvokeGit { param([string[]] $GitArgs) $null = $GitArgs; return "" }

        $result | Should -Be "C:/repo"
    }
}

Describe "post-codex-worktree-session.ps1 - skip filtering and logging" {
    BeforeEach {
        . $script:scriptPath
    }

    It "skips transient source paths and reports concise skipped entries" {
        $filesByFolder = @{
            "C:/repo/.codex"  = @(
                [pscustomobject]@{ FullName = "C:/repo/.codex/config.toml" },
                [pscustomobject]@{ FullName = "C:/repo/.codex/sessions/2026-07-03.jsonl" },
                [pscustomobject]@{ FullName = "C:/repo/.codex/logs/session.log" }
            )
            "C:/repo/.agents" = @(
                [pscustomobject]@{ FullName = "C:/repo/.agents/skills/example/SKILL.md" },
                [pscustomobject]@{ FullName = "C:/repo/.agents/node_modules/package/index.js" },
                [pscustomobject]@{ FullName = "C:/repo/.agents/.cache/index.json" }
            )
        }
        $logLines = [System.Collections.Generic.List[string]]::new()

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

        $copyOperations = @($result | Where-Object { $_.Action -eq "Copy" })
        $skippedOperations = @($result | Where-Object { $_.Action -eq "Skip" })
        $copyOperations.SourcePath | Should -Be @(
            "C:/repo/.codex/config.toml",
            "C:/repo/.agents/skills/example/SKILL.md"
        )
        $skippedOperations.SourcePath | Should -Be @(
            "C:/repo/.codex/logs/session.log",
            "C:/repo/.codex/sessions/2026-07-03.jsonl",
            "C:/repo/.agents/.cache/index.json",
            "C:/repo/.agents/node_modules/package/index.js"
        )

        Write-CodexCustomizationCopySummary `
            -SourceRoot "C:/repo" `
            -WorktreeRoot "C:/repo-wt" `
            -CopyOperation $copyOperations `
            -SkippedOperation $skippedOperations `
            -WriteLog { param([string] $Message) $logLines.Add($Message) }

        ($logLines -join "`n") | Should -Match "SourceRoot: C:/repo"
        ($logLines -join "`n") | Should -Match "WorktreeRoot: C:/repo-wt"
        ($logLines -join "`n") | Should -Match "Copied: 2"
        ($logLines -join "`n") | Should -Match "Skipped: 4"
        ($logLines -join "`n") | Should -Not -Match "2026-07-03.jsonl.*session.log.*node_modules.*\\.cache"
    }
}
