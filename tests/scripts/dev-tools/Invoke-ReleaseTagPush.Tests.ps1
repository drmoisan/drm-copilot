Set-StrictMode -Version Latest

Describe "Invoke-ReleaseTagPush.ps1 - Invoke-ReleaseTagPushGuarded" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseTagPush.ps1")).Path
        # Dot-source the production script so its on-disk lines execute under Pester
        # coverage instrumentation. The mandatory -ConfirmToken is supplied to bind
        # the param without prompting; the entry-point block is skipped because
        # $MyInvocation.InvocationName -eq '.' when dot-sourced.
        . $script:scriptPath -ConfirmToken 'no'
    }

    BeforeEach {
        $script:capturedMessage = $null
        $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
    }

    Context "confirmation guard" {
        It "returns 2 and invokes no git wrapper when ConfirmToken is 'no'" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "no" -RepoRoot "/repo"

            $result | Should -Be 2
            $script:capturedMessage | Should -Match "Release tag push not confirmed \(got 'no'\)"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken 'YES' is rejected with code 2" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "YES" -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "confirmed run pushes both tags" {
        It "derives both tags from the committed manifests and pushes both" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Get-NpmVersion -MockWith {
                param([string]$ManifestPath)
                if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
                return "0.0.3"
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            $flattened = @($script:capturedGitArgsList | ForEach-Object { $_ }) -join " "
            # One pull + two tag-creates + two tag-pushes = 5 git invocations.
            $script:capturedGitArgsList.Count | Should -Be 5
            $flattened | Should -Match "pull origin main"
            # Two push invocations carrying the derived tag names.
            $pushArgs = @($script:capturedGitArgsList | Where-Object { ($_ -join " ") -match "^push " })
            ($pushArgs | ForEach-Object { $_ -join " " }) -join "`n" | Should -Match "push origin v0\.0\.3"
            ($pushArgs | ForEach-Object { $_ -join " " }) -join "`n" | Should -Match "push origin mcp-server-v0\.0\.2"
            $pushArgs.Count | Should -Be 2
        }
    }

    Context "missing manifest" {
        It "reports a missing extension manifest and returns 1 (not silently ignored)" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/nonexistent/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "manifest not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "tag-name derivation (pure functions)" {
        It "derives v0.0.3 from input 0.0.3" {
            Get-ExtensionTagName -Version "0.0.3" | Should -Be "v0.0.3"
        }

        It "derives mcp-server-v0.0.2 from input 0.0.2" {
            Get-McpServerTagName -Version "0.0.2" | Should -Be "mcp-server-v0.0.2"
        }
    }

    Context "missing mcp-server manifest" {
        It "reports a missing mcp-server manifest and returns 1" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            # Extension manifest exists; mcp-server manifest does not.
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath)
                return ($LiteralPath -notmatch 'mcp-server')
            }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "mcp-server manifest not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "git seam failures" {
        It "returns 1 when 'git pull origin main' fails" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Get-NpmVersion -MockWith { param([string]$ManifestPath) $null = $ManifestPath; return "0.0.3" }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @("network error"); ExitCode = 1 }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to update main from origin"
        }

        It "returns 1 when 'git tag' creation fails" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Get-NpmVersion -MockWith {
                param([string]$ManifestPath)
                if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
                return "0.0.3"
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                # Pull succeeds; tag-create fails.
                if (($GitArgs -join " ") -match "^tag ") { return @{ Output = @("tag exists"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to create git tag"
        }

        It "returns 1 when 'git push' of a tag fails" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Get-NpmVersion -MockWith {
                param([string]$ManifestPath)
                if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
                return "0.0.3"
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                # Pull and tag-create succeed; push fails.
                if (($GitArgs -join " ") -match "^push ") { return @{ Output = @("rejected"); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to push git tag"
        }
    }

    Context "Get-NpmVersion (real reader)" {
        It "returns the version field from a manifest" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith { param($LiteralPath, [switch]$Raw) $null = $LiteralPath; $null = $Raw; return '{ "version": "1.2.3" }' }

            Get-NpmVersion -ManifestPath "/repo/extensions/drm-copilot/package.json" | Should -Be "1.2.3"
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

    Context "Write-StderrLine (real writer)" {
        It "writes the supplied message to the console error stream" {
            $originalError = [Console]::Error
            $capture = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($capture)
                Write-StderrLine -Message "diagnostic line"
            }
            finally {
                [Console]::SetError($originalError)
            }
            $capture.ToString() | Should -Match "diagnostic line"
        }
    }

    Context "entry point (script invoked, not dot-sourced)" {
        It "returns exit code 2 when invoked with an unconfirmed token" {
            # Execute the production entry-point block in-process via the call
            # operator. The confirmation guard returns 2 before any seam call, so
            # no real git executable is invoked and the run is deterministic.
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
            $capture.ToString() | Should -Match "Release tag push not confirmed"
        }
    }
}
