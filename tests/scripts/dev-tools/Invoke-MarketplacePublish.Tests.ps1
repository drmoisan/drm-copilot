Set-StrictMode -Version Latest

Describe "Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-MarketplacePublish.ps1")).Path
        # Dot-source the production script so its on-disk lines execute under Pester
        # coverage instrumentation. The mandatory -ConfirmToken is supplied to bind
        # the param without prompting; the entry-point block is skipped because
        # $MyInvocation.InvocationName -eq '.' when dot-sourced.
        . $script:scriptPath -ConfirmToken 'no'
    }

    BeforeEach {
        $script:capturedMessage = $null
        $script:capturedNpmArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedGhArgsList = [System.Collections.Generic.List[object]]::new()
    }

    Context "confirmation guard" {
        It "returns 2 and invokes no seam when ConfirmToken is 'no'" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "no" -RepoRoot "/repo"

            $result | Should -Be 2
            $script:capturedMessage | Should -Match "Extension release PR not confirmed \(got 'no'\)"
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken 'YES' is rejected with code 2" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "YES" -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "confirmed run opens a PR" {
        It "bumps only the extension manifest and opens a PR against main" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Get-NpmVersion -MockWith { param([string]$ManifestPath) $null = $ManifestPath; return "0.0.3" }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgsList.Add($NpmArgs)
                return 0
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedGhArgsList.Add($GhArgs)
                return 0
            }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-NpmExe -Times 1 -Exactly
            $npmFlat = @($script:capturedNpmArgsList | ForEach-Object { $_ }) -join " "
            $npmFlat | Should -Match "extensions[\\/]drm-copilot"
            $npmFlat | Should -Not -Match "packages[\\/]mcp-server"
            $npmFlat | Should -Match "--no-git-tag-version"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            $ghFlat = @($script:capturedGhArgsList | ForEach-Object { $_ }) -join " "
            $ghFlat | Should -Match "pr create"
            $ghFlat | Should -Match "--base main"
        }
    }

    Context "dirty working tree" {
        It "blocks the bump and returns 1 before any npm call when git status is non-empty" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $null = $GitArgs
                return @{ Output = @(" M extensions/drm-copilot/package.json"); ExitCode = 0 }
            }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Working tree is not clean"
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "tag/publish absence" {
        It "the production script body invokes no Invoke-PublishScript, vsce publish, or git tag" {
            $raw = Get-Content -LiteralPath (Resolve-Path -Path $script:scriptPath) -Raw
            $raw | Should -Not -Match 'Invoke-PublishScript'
            $raw | Should -Not -Match 'vsce publish'
            $raw | Should -Not -Match "'tag'"
        }
    }

    Context "missing manifest" {
        It "reports a missing extension manifest and returns 1" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Extension manifest not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "git/npm/gh seam failures" {
        BeforeEach {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Get-NpmVersion -MockWith { param([string]$ManifestPath) $null = $ManifestPath; return "0.0.3" }
        }

        It "returns 1 when 'git status --porcelain' fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^status ") { return @{ Output = @("fatal"); ExitCode = 128 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to read git status"
        }

        It "returns 1 when 'git checkout -b' (branch create) fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^checkout ") { return @{ Output = @("exists"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to create release branch"
        }

        It "returns the npm exit code when the extension version bump fails" {
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; return @{ Output = @(); ExitCode = 0 } }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 5 }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 5
            $script:capturedMessage | Should -Match "Extension version bump failed"
        }

        It "returns 1 when staging the bumped manifest fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^add ") { return @{ Output = @("err"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to stage bumped manifest"
        }

        It "returns 1 when committing the bumped manifest fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^commit ") { return @{ Output = @("err"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to commit bumped manifest"
        }

        It "returns 1 when 'gh pr create' fails" {
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; return @{ Output = @(); ExitCode = 0 } }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; return 1 }

            $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to open release PR"
        }
    }

    Context "Get-NpmVersion (real reader) and Get-ReleaseBranchName" {
        It "returns the version field from a manifest" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith { param($LiteralPath, [switch]$Raw) $null = $LiteralPath; $null = $Raw; return '{ "version": "3.4.5" }' }

            Get-NpmVersion -ManifestPath "/repo/extensions/drm-copilot/package.json" | Should -Be "3.4.5"
        }

        It "throws when the manifest file does not exist" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }

            { Get-NpmVersion -ManifestPath "/repo/missing/package.json" } | Should -Throw "*Manifest not found*"
        }

        It "throws when the manifest has no version field" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith { param($LiteralPath, [switch]$Raw) $null = $LiteralPath; $null = $Raw; return '{ "name": "no-version" }' }

            { Get-NpmVersion -ManifestPath "/repo/extensions/drm-copilot/package.json" } | Should -Throw "*no 'version' field*"
        }

        It "derives release/extension-<timestamp> from a fixed Now" {
            $fixed = [datetime]::new(2026, 6, 19, 21, 18, 0, [DateTimeKind]::Utc)
            Get-ReleaseBranchName -Label 'extension' -Now $fixed | Should -Be "release/extension-20260619211800"
        }
    }

    Context "Write-StderrLine (real writer)" {
        It "writes the supplied message to the console error stream" {
            $originalError = [Console]::Error
            $capture = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($capture)
                Write-StderrLine -Message "marketplace diagnostic"
            }
            finally {
                [Console]::SetError($originalError)
            }
            $capture.ToString() | Should -Match "marketplace diagnostic"
        }
    }

    Context "entry point (script invoked, not dot-sourced)" {
        It "returns exit code 2 when invoked with an unconfirmed token" {
            $originalError = [Console]::Error
            $capture = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($capture)
                & $script:scriptPath -ConfirmToken 'no'
            }
            finally {
                [Console]::SetError($originalError)
            }
            $LASTEXITCODE | Should -Be 2
            $capture.ToString() | Should -Match "Extension release PR not confirmed"
        }
    }
}
