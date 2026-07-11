Set-StrictMode -Version Latest

Describe "Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullRelease.ps1")).Path
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
        $script:capturedConfigPaths = @()
        $script:capturedMcpVersion = $null
        $script:ghInvokedAfterGitCount = -1
    }

    Context "confirmation guard" {
        It "returns 2 and invokes no npm/git/gh wrapper when ConfirmToken is 'no'" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "no" -RepoRoot "/repo"

            $result | Should -Be 2
            $script:capturedMessage | Should -Match "Full release not confirmed \(got 'no'\)"
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken '<ConfirmToken>' (<CaseLabel>) is rejected with code 2" -ForEach @(
            @{ ConfirmToken = "YES"; CaseLabel = "uppercase" }
            @{ ConfirmToken = "Yes"; CaseLabel = "titlecase" }
        ) {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken $ConfirmToken -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "confirmed run opens a PR" {
        It "bumps both manifests and opens a PR against main" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Get-NpmVersion -MockWith {
                param([string]$ManifestPath)
                if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
                return "0.0.3"
            }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgsList.Add($NpmArgs)
                return 0
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                # Clean tree on status; success otherwise (including the branch push).
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedGhArgsList.Add($GhArgs)
                # Record the relative order of git vs gh calls so the test can
                # assert the push is issued before PR creation.
                $script:ghInvokedAfterGitCount = $script:capturedGitArgsList.Count
                return 0
            }
            Mock -CommandName Set-CodexMcpVersionPin -MockWith {
                param([string[]]$ConfigPaths, [string]$Version)
                $script:capturedConfigPaths = $ConfigPaths
                $script:capturedMcpVersion = $Version
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-NpmExe -Times 2 -Exactly
            $npmFlat = @($script:capturedNpmArgsList | ForEach-Object { $_ -join " " })
            ($npmFlat -join "`n") | Should -Match "extensions[\\/]drm-copilot"
            ($npmFlat -join "`n") | Should -Match "packages[\\/]mcp-server"
            ($npmFlat -join "`n") | Should -Match "--no-git-tag-version"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            $ghFlat = @($script:capturedGhArgsList | ForEach-Object { $_ }) -join " "
            $ghFlat | Should -Match "pr create"
            $ghFlat | Should -Match "--base main"
            Should -Invoke -CommandName Set-CodexMcpVersionPin -Times 1 -Exactly
            $script:capturedMcpVersion | Should -Be "0.0.2"
            ($script:capturedConfigPaths -join "`n") | Should -Match "[\\/]\.codex[\\/]config\.toml"
            ($script:capturedConfigPaths -join "`n") | Should -Match "codex-and-agents-customizations[\\/]\.codex[\\/]config\.toml"

            # The 'git add' staging call must include both package.json manifests
            # and both package-lock.json lockfiles. npm version (npm 7+) updates
            # the lockfiles too, so all four paths must be staged or the lockfile
            # changes are left uncommitted.
            $addCall = $script:capturedGitArgsList | Where-Object { @($_)[0] -eq 'add' } | Select-Object -First 1
            $addCall | Should -Not -BeNullOrEmpty
            $addFlat = (@($addCall) -join " ")
            $addFlat | Should -Match "extensions[\\/]drm-copilot[\\/]package\.json"
            $addFlat | Should -Match "packages[\\/]mcp-server[\\/]package\.json"
            $addFlat | Should -Match "extensions[\\/]drm-copilot[\\/]package-lock\.json"
            $addFlat | Should -Match "packages[\\/]mcp-server[\\/]package-lock\.json"
            $addFlat | Should -Match "[\\/]\.codex[\\/]config\.toml"
            $addFlat | Should -Match "codex-and-agents-customizations[\\/]\.codex[\\/]config\.toml"

            # The release branch must be pushed to origin before the PR is opened.
            $gitFlat = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            $pushIndex = $gitFlat.IndexOf(($gitFlat | Where-Object { $_ -match "^push -u origin release/" } | Select-Object -First 1))
            $pushIndex | Should -BeGreaterOrEqual 0
            ($gitFlat[$pushIndex]) | Should -Match "^push -u origin release/"
            # gh pr create was invoked only after all recorded git calls, which
            # include the push; therefore the push precedes PR creation.
            $script:ghInvokedAfterGitCount | Should -Be $script:capturedGitArgsList.Count
            ($pushIndex + 1) | Should -BeLessOrEqual $script:ghInvokedAfterGitCount
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
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(" M extensions/drm-copilot/package.json"); ExitCode = 0 }
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Working tree is not clean"
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "release-branch derivation (pure function)" {
        It "derives release/full-<timestamp> from a fixed Now" {
            $fixed = [datetime]::new(2026, 6, 19, 21, 18, 0, [DateTimeKind]::Utc)
            Get-ReleaseBranchName -Label 'full' -Now $fixed | Should -Be "release/full-20260619211800"
        }
    }

    Context "tag/publish absence" {
        It "the production script body invokes no git tag, tag push, or publish seam" {
            $raw = Get-Content -LiteralPath (Resolve-Path -Path $script:scriptPath) -Raw
            $raw | Should -Not -Match 'Invoke-PublishScript'
            $raw | Should -Not -Match "'tag'"
            $raw | Should -Not -Match 'vsce publish'
        }
    }

    Context "missing manifests" {
        It "reports a missing extension manifest and returns 1" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Extension manifest not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }

        It "reports a missing mcp-server manifest and returns 1" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) return ($LiteralPath -notmatch 'mcp-server') }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "mcp-server manifest not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "git/npm/gh seam failures" {
        BeforeEach {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Get-NpmVersion -MockWith {
                param([string]$ManifestPath)
                if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
                return "0.0.3"
            }
            Mock -CommandName Set-CodexMcpVersionPin -MockWith {
                param([string[]]$ConfigPaths, [string]$Version)
                $null = $ConfigPaths
                $null = $Version
            }
        }

        It "returns 1 when 'git status --porcelain' fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^status ") { return @{ Output = @("fatal"); ExitCode = 128 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

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

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to create release branch"
        }

        It "returns the npm exit code when the extension version bump fails" {
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; return @{ Output = @(); ExitCode = 0 } }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 7 }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 7
            $script:capturedMessage | Should -Match "Extension version bump failed"
        }

        It "returns the npm exit code when the mcp-server version bump fails" {
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; return @{ Output = @(); ExitCode = 0 } }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                if (($NpmArgs -join " ") -match "mcp-server") { return 9 }
                return 0
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 9
            $script:capturedMessage | Should -Match "mcp-server version bump failed"
        }

        It "returns 1 when staging the bumped manifests fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^add ") { return @{ Output = @("err"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to stage bumped manifests"
        }

        It "returns 1 before staging when the Codex MCP pin cannot be synchronized" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^add ") { throw "git add should not be invoked" }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Set-CodexMcpVersionPin -MockWith {
                param([string[]]$ConfigPaths, [string]$Version)
                $null = $ConfigPaths
                $null = $Version
                throw "invalid transport"
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to synchronize the Codex MCP package pin: invalid transport"
        }

        It "returns 1 when committing the bumped manifests fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^commit ") { return @{ Output = @("err"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to commit bumped manifests"
        }

        It "returns 1 when 'gh pr create' fails" {
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; return @{ Output = @(); ExitCode = 0 } }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; return 1 }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to open release PR"
        }

        It "returns 1 and does not open a PR when 'git push -u origin <branch>' fails" {
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                if (($GitArgs -join " ") -match "^push ") { return @{ Output = @("rejected"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to push release branch"
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "Get-NpmVersion (real reader)" {
        It "returns the version field from a manifest" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith { param($LiteralPath, [switch]$Raw) $null = $LiteralPath; $null = $Raw; return '{ "version": "2.3.4" }' }

            Get-NpmVersion -ManifestPath "/repo/extensions/drm-copilot/package.json" | Should -Be "2.3.4"
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
    }

    Context "Set-CodexMcpVersionPin (real updater)" {
        It "validates both configurations before writing the exact new package pin" {
            $writtenContent = @{}
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith {
                param($LiteralPath, [switch]$Raw)
                $null = $LiteralPath
                $null = $Raw
                return "[mcp_servers.drm-copilot]`ncommand = `"npx`"`nargs = [`"-y`", `"@danmoisan/drm-copilot-mcp@1.0.14`"]`nrequired = true`n"
            }
            Mock -CommandName Set-Content -MockWith {
                param($LiteralPath, $Value, $Encoding, [switch]$NoNewline)
                $null = $Encoding
                $null = $NoNewline
                $writtenContent[$LiteralPath] = $Value
            }

            Set-CodexMcpVersionPin -ConfigPaths @('/repo/.codex/config.toml', '/repo/bundle/.codex/config.toml') -Version '1.0.15' -Confirm:$false

            Should -Invoke -CommandName Set-Content -Times 2 -Exactly
            $writtenContent.Count | Should -Be 2
            foreach ($content in $writtenContent.Values) {
                $content | Should -Match 'args = \["-y", "@danmoisan/drm-copilot-mcp@1\.0\.15"\]'
                $content | Should -Not -Match '@danmoisan/drm-copilot-mcp@1\.0\.14'
            }
        }

        It "writes no configuration when any transport entry is missing" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith {
                param($LiteralPath, [switch]$Raw)
                $null = $Raw
                if ($LiteralPath -match 'bundle') { return '[mcp_servers.other]' }
                return 'args = ["-y", "@danmoisan/drm-copilot-mcp@1.0.14"]'
            }
            Mock -CommandName Set-Content -MockWith {
                param($LiteralPath, $Value, $Encoding, [switch]$NoNewline)
                $null = $LiteralPath
                $null = $Value
                $null = $Encoding
                $null = $NoNewline
                throw "Set-Content should not be invoked"
            }

            { Set-CodexMcpVersionPin -ConfigPaths @('/repo/.codex/config.toml', '/repo/bundle/.codex/config.toml') -Version '1.0.15' -Confirm:$false } |
                Should -Throw "*must contain exactly one drm-copilot MCP args entry; found 0*"
            Should -Invoke -CommandName Set-Content -Times 0 -Exactly
        }
    }

    Context "Write-StderrLine (real writer)" {
        It "writes the supplied message to the console error stream" {
            $originalError = [Console]::Error
            $capture = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($capture)
                Write-StderrLine -Message "full release diagnostic"
            }
            finally {
                [Console]::SetError($originalError)
            }
            $capture.ToString() | Should -Match "full release diagnostic"
        }
    }

    Context "entry point (script invoked, not dot-sourced)" {
        It "returns exit code 2 when invoked with an unconfirmed token" {
            # Execute the production entry-point block in-process via the call
            # operator. The confirmation guard returns 2 before any seam call, so
            # no real git/npm/gh executable is invoked and the run is deterministic.
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
            $capture.ToString() | Should -Match "Full release not confirmed"
        }
    }
}
