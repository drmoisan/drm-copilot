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
        $script:capturedVerificationCalls = [System.Collections.Generic.List[object]]::new()
        # The version pinned by .codex/config.toml, distinct from both manifest
        # versions so the two opposite-polarity guards can be told apart.
        $script:codexPinnedVersion = "9.9.9"

        # Seams introduced by the Layer B verification module (issue #526). Every
        # confirmed-token run of Invoke-ReleaseTagPushGuarded reaches these call
        # sites, so they are declared here once and therefore apply to every
        # context in this file, including "confirmed run pushes both tags", "tag
        # push ordering", "git seam failures", and both missing-manifest
        # contexts. Without them a confirmed run would spawn a real npm process,
        # a real gh process, and read .codex/config.toml from disk. Any test
        # needing different behaviour re-declares the mock inline, which wins.
        #
        # Test-NpmVersionResolved is consumed by two guards of OPPOSITE polarity,
        # so this mock discriminates on the requested version rather than
        # returning one blanket value. The pre-push guard aborts when the target
        # mcp version resolves, so the success path needs it reported NOT
        # resolved; the Codex pin guard needs the pinned version reported
        # resolved.
        Mock -CommandName Test-NpmVersionResolved -MockWith {
            param([string]$Version, [string]$PackageName)
            $null = $PackageName
            return ($Version -eq $script:codexPinnedVersion)
        }
        Mock -CommandName Invoke-TagPublishVerification -MockWith {
            param(
                [string]$TagName,
                [string]$WorkflowFileName,
                [string]$JobName,
                [string]$StepName,
                [string]$Version,
                [string]$PackageName,
                [int]$IntervalSeconds,
                [int]$MaxAttempts,
                [switch]$SkipRegistryResolutionCheck
            )
            $null = $JobName, $StepName, $Version, $PackageName, $IntervalSeconds, $MaxAttempts
            $script:capturedVerificationCalls.Add([pscustomobject]@{
                    TagName                     = $TagName
                    WorkflowFileName            = $WorkflowFileName
                    SkipRegistryResolutionCheck = [bool]$SkipRegistryResolutionCheck
                })
            return [pscustomobject]@{
                State          = "RESOLVED"
                ExitCode       = 0
                RunExistence   = "4242"
                StepConclusion = "SUCCESS"
                Instruction    = ""
            }
        }
        Mock -CommandName Get-CodexPinnedMcpVersion -MockWith {
            param([string]$ConfigContent, [string]$PackageName)
            $null = $ConfigContent, $PackageName
            return $script:codexPinnedVersion
        }
        # The Codex config is supplied in memory; no test reads it from disk.
        Mock -CommandName Get-Content -MockWith {
            param($LiteralPath, [switch]$Raw)
            $null = $LiteralPath, $Raw
            return 'command = ["npx", "-y", "@danmoisan/drm-copilot-mcp@9.9.9"]'
        }
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
        BeforeEach {
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
        }

        It "derives both tags from the committed manifests and pushes both" {
            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            $flattened = @($script:capturedGitArgsList | ForEach-Object { $_ }) -join " "
            $flattened | Should -Match "pull origin main"
            # The invocation shape is now dependency-ordered: the mcp-server tag
            # is created and pushed, verified, and only then is the extension tag
            # created and pushed. Both pushes are present and the mcp-server push
            # precedes the extension push.
            $pushLines = @(
                $script:capturedGitArgsList |
                    ForEach-Object { $_ -join " " } |
                        Where-Object { $_ -match "^push " }
            )
            $pushLines.Count | Should -Be 2
            $pushLines[0] | Should -Be "push origin mcp-server-v0.0.2"
            $pushLines[1] | Should -Be "push origin v0.0.3"
        }

        It "verifies the mcp-server tag with the registry check and the extension tag without it" {
            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            $script:capturedVerificationCalls.Count | Should -Be 2
            $script:capturedVerificationCalls[0].TagName | Should -Be "mcp-server-v0.0.2"
            $script:capturedVerificationCalls[0].WorkflowFileName | Should -Be "publish-mcp-npm.yml"
            $script:capturedVerificationCalls[0].SkipRegistryResolutionCheck | Should -BeFalse
            $script:capturedVerificationCalls[1].TagName | Should -Be "v0.0.3"
            $script:capturedVerificationCalls[1].WorkflowFileName | Should -Be "publish-extension.yml"
            $script:capturedVerificationCalls[1].SkipRegistryResolutionCheck | Should -BeTrue
        }
    }

    Context "tag push ordering" {
        It "pushes the mcp-server tag before the extension tag" {
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
            # The mcp-server tag is the dependency the extension consumes, so it must be
            # pushed first: if its publish fails, the extension consumer tag is never
            # created and no artifact pinning an unpublished version reaches a user.
            $pushLines = @(
                $script:capturedGitArgsList |
                    ForEach-Object { $_ -join " " } |
                        Where-Object { $_ -match "^push " }
            )
            $mcpPushIndex = [array]::IndexOf([object[]]$pushLines, [object]"push origin mcp-server-v0.0.2")
            $extensionPushIndex = [array]::IndexOf([object[]]$pushLines, [object]"push origin v0.0.3")
            $mcpPushIndex | Should -BeGreaterOrEqual 0
            $extensionPushIndex | Should -BeGreaterOrEqual 0
            $mcpPushIndex | Should -BeLessThan $extensionPushIndex
        }
    }

    Context "inter-push verification gate" {
        BeforeEach {
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
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(); ExitCode = 0 }
            }
        }

        It "performs zero extension tag operations when the mcp verification does not resolve" {
            Mock -CommandName Invoke-TagPublishVerification -MockWith {
                param([string]$TagName)
                $null = $TagName
                return [pscustomobject]@{
                    State          = "STEP_SKIPPED"
                    ExitCode       = 1
                    RunExistence   = "4242"
                    StepConclusion = "STEP_SKIPPED"
                    Instruction    = "Fix the guard or the trigger, then re-dispatch."
                }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Not -Be 0
            $gitLines = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            $pushLines = @($gitLines | Where-Object { $_ -match "^push " })
            $pushLines.Count | Should -Be 1
            $pushLines[0] | Should -Be "push origin mcp-server-v0.0.2"
            @($gitLines | Where-Object { $_ -match "^tag .*(\s|^)v0\.0\.3(\s|$)" }).Count | Should -Be 0
        }

        It "returns non-zero when the extension post-push verification does not succeed" {
            # The mcp-server tag verifies clean; only the extension tag fails, so
            # the failure must still propagate rather than returning 0.
            Mock -CommandName Invoke-TagPublishVerification -MockWith {
                param([string]$TagName)
                if ($TagName -match '^mcp-server-') {
                    return [pscustomobject]@{
                        State          = "RESOLVED"
                        ExitCode       = 0
                        RunExistence   = "4242"
                        StepConclusion = "SUCCESS"
                        Instruction    = ""
                    }
                }
                return [pscustomobject]@{
                    State          = "NO_RUN"
                    ExitCode       = 1
                    RunExistence   = "NO_RUN"
                    StepConclusion = "NOT_REACHED"
                    Instruction    = "No run started for the tag ref."
                }
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Not -Be 0
            $script:capturedMessage | Should -Match "v0\.0\.3"
            $script:capturedMessage | Should -Match "NO_RUN"
        }

        It "requires the Codex-pinned version itself to resolve after the mcp verification succeeds" {
            # Neither the target version nor the pinned version resolves. The
            # target not resolving is the success path of the pre-push guard, so
            # execution reaches the Codex pin guard, which then fails.
            Mock -CommandName Test-NpmVersionResolved -MockWith {
                param([string]$Version, [string]$PackageName)
                $null = $Version, $PackageName
                return $false
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "pinned by \.codex/config\.toml"
            $gitLines = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            # The mcp-server tag was pushed; the extension tag was never created.
            @($gitLines | Where-Object { $_ -match "^push " }).Count | Should -Be 1
            @($gitLines | Where-Object { $_ -match "^tag .*(\s|^)v0\.0\.3(\s|$)" }).Count | Should -Be 0
        }
    }

    Context "pre-push registry check" {
        It "aborts with VERSION_CONSUMED_ELSEWHERE and pushes nothing when the target version already resolves" {
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
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(); ExitCode = 0 }
            }
            # The target mcp version resolves, meaning the number was consumed by
            # some other run and this push could never publish it.
            Mock -CommandName Test-NpmVersionResolved -MockWith {
                param([string]$Version, [string]$PackageName)
                $null = $PackageName
                return ($Version -eq "0.0.2")
            }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Not -Be 0
            $script:capturedMessage | Should -Match "VERSION_CONSUMED_ELSEWHERE"
            $gitLines = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            @($gitLines | Where-Object { $_ -match "^push " }).Count | Should -Be 0
            @($gitLines | Where-Object { $_ -match "^tag " }).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-TagPublishVerification -Times 0 -Exactly
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
