Set-StrictMode -Version Latest
Describe "Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
        . $script:scriptPath -ConfirmToken 'no'
    }

    BeforeEach {
        $script:capturedMessage = $null
        $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedGhArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedChildCalls = [System.Collections.Generic.List[object]]::new()
        $script:branchReadCount = 0
    }

    function script:Initialize-SuccessfulGitFlowMock {
        Mock -CommandName Invoke-GitExe -MockWith {
            param([string[]]$GitArgs)

            $script:capturedGitArgsList.Add($GitArgs)
            $joined = $GitArgs -join " "

            if ($joined -eq 'status --porcelain') {
                return @{ Output = @(); ExitCode = 0 }
            }

            if ($joined -eq 'branch --show-current') {
                $script:branchReadCount++
                if ($script:branchReadCount -eq 1) {
                    return @{ Output = @('main'); ExitCode = 0 }
                }
                return @{ Output = @('release/full-20260703171500'); ExitCode = 0 }
            }

            if ($joined -eq 'fetch origin main') {
                return @{ Output = @(); ExitCode = 0 }
            }

            if ($joined -eq 'rev-parse main') {
                return @{ Output = @('abc123'); ExitCode = 0 }
            }

            if ($joined -eq 'rev-parse origin/main') {
                return @{ Output = @('abc123'); ExitCode = 0 }
            }

            if ($joined -eq 'checkout main') {
                return @{ Output = @(); ExitCode = 0 }
            }

            if ($joined -eq 'pull origin main') {
                return @{ Output = @(); ExitCode = 0 }
            }

            return @{ Output = @(); ExitCode = 0 }
        }
    }

    function script:Initialize-SuccessfulGhFlowMock {
        Mock -CommandName Invoke-GhExe -MockWith {
            param([string[]]$GhArgs)

            $script:capturedGhArgsList.Add($GhArgs)
            $joined = $GhArgs -join " "

            if ($joined -eq 'pr view release/full-20260703171500 --json number --jq .number') {
                return @{ Output = @('291'); ExitCode = 0 }
            }

            if ($joined -eq 'pr checks 291 --watch') {
                return @{ Output = @('checks passed'); ExitCode = 0 }
            }

            if ($joined -eq 'pr merge 291 --merge --delete-branch') {
                return @{ Output = @('merged'); ExitCode = 0 }
            }

            return @{ Output = @(); ExitCode = 0 }
        }
    }

    function script:Initialize-SuccessfulChildScriptMock {
        Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
            param(
                [string]$ScriptPath,
                [string[]]$ScriptArguments
            )

            $script:capturedChildCalls.Add(@{
                    ScriptPath = $ScriptPath
                    Arguments  = $ScriptArguments
                })
            return 0
        }
    }

    Context "confirmation guard" {
        It "returns 2 and invokes no wrapper when ConfirmToken is 'no'" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "no" -RepoRoot "/repo"

            $result | Should -Be 2
            $script:capturedMessage | Should -Match "Automated full release flow not confirmed \(got 'no'\)"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken 'YES' is rejected with code 2" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "YES" -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
        }
    }

    Context "successful automated flow" {
        It "opens the release PR, waits for checks, merges, pulls main, and invokes tag push" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulGhFlowMock
            Initialize-SuccessfulChildScriptMock

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0

            $childScriptNames = @($script:capturedChildCalls | ForEach-Object { Split-Path -Leaf $_.ScriptPath })
            $childScriptNames | Should -Be @('Invoke-FullRelease.ps1', 'Invoke-ReleaseTagPush.ps1')
            @($script:capturedChildCalls[0].Arguments) | Should -Be @('-ConfirmToken', 'yes')
            @($script:capturedChildCalls[1].Arguments) | Should -Be @('-ConfirmToken', 'yes')

            $gitFlat = @($script:capturedGitArgsList | ForEach-Object { $_ -join " " })
            $gitFlat | Should -Contain 'status --porcelain'
            $gitFlat | Should -Contain 'branch --show-current'
            $gitFlat | Should -Contain 'fetch origin main'
            $gitFlat | Should -Contain 'rev-parse main'
            $gitFlat | Should -Contain 'rev-parse origin/main'
            $gitFlat | Should -Contain 'checkout main'
            $gitFlat | Should -Contain 'pull origin main'

            $ghFlat = @($script:capturedGhArgsList | ForEach-Object { $_ -join " " })
            $ghFlat | Should -Be @(
                'pr view release/full-20260703171500 --json number --jq .number',
                'pr checks 291 --watch',
                'pr merge 291 --merge --delete-branch'
            )
        }
    }

    Context "preflight blocks" {
        It "blocks dirty worktrees before opening the release PR" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return @{ Output = @(' M extensions/drm-copilot/package.json'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Working tree is not clean"
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "checkout main"
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pull origin main"
        }

        It "blocks when the current branch is not main" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                if (($GitArgs -join " ") -eq 'status --porcelain') {
                    return @{ Output = @(); ExitCode = 0 }
                }
                return @{ Output = @('feature/work'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "must start from branch 'main'"
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }

        It "blocks when local main is not up to date with origin/main" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                $joined = $GitArgs -join " "
                if ($joined -eq 'status --porcelain') { return @{ Output = @(); ExitCode = 0 } }
                if ($joined -eq 'branch --show-current') { return @{ Output = @('main'); ExitCode = 0 } }
                if ($joined -eq 'fetch origin main') { return @{ Output = @(); ExitCode = 0 } }
                if ($joined -eq 'rev-parse main') { return @{ Output = @('local'); ExitCode = 0 } }
                if ($joined -eq 'rev-parse origin/main') { return @{ Output = @('remote'); ExitCode = 0 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Local main is not up to date"
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly
        }
    }

    Context "post-PR stop cases" {
        It "returns 1 when PR lookup fails after the full release script runs" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedGhArgsList.Add($GhArgs)
                return @{ Output = @('not found'); ExitCode = 1 }
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to resolve pull request"
            @($script:capturedChildCalls).Count | Should -Be 1
            (@($script:capturedGhArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pr checks"
            (@($script:capturedGhArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pr merge"
        }

        It "stops before merge, pull, and tag push when checks fail" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedGhArgsList.Add($GhArgs)
                $joined = $GhArgs -join " "
                if ($joined -eq 'pr view release/full-20260703171500 --json number --jq .number') {
                    return @{ Output = @('291'); ExitCode = 0 }
                }
                if ($joined -eq 'pr checks 291 --watch') {
                    return @{ Output = @('failing check'); ExitCode = 8 }
                }
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "checks did not pass"
            @($script:capturedChildCalls).Count | Should -Be 1
            (@($script:capturedChildCalls | ForEach-Object { Split-Path -Leaf $_.ScriptPath }) -join "`n") | Should -Not -Match "Invoke-ReleaseTagPush.ps1"
            (@($script:capturedGhArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pr merge"
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "checkout main"
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pull origin main"
        }

        It "stops before checkout, pull, and tag push when merge fails" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Initialize-SuccessfulGitFlowMock
            Initialize-SuccessfulChildScriptMock
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedGhArgsList.Add($GhArgs)
                $joined = $GhArgs -join " "
                if ($joined -eq 'pr view release/full-20260703171500 --json number --jq .number') {
                    return @{ Output = @('291'); ExitCode = 0 }
                }
                if ($joined -eq 'pr checks 291 --watch') {
                    return @{ Output = @('checks passed'); ExitCode = 0 }
                }
                if ($joined -eq 'pr merge 291 --merge --delete-branch') {
                    return @{ Output = @('merge blocked'); ExitCode = 1 }
                }
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "merge failed"
            @($script:capturedChildCalls).Count | Should -Be 1
            (@($script:capturedChildCalls | ForEach-Object { Split-Path -Leaf $_.ScriptPath }) -join "`n") | Should -Not -Match "Invoke-ReleaseTagPush.ps1"
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "checkout main"
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pull origin main"
        }

        It "stops before tag push when checkout main fails after merge" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Initialize-SuccessfulGhFlowMock
            Initialize-SuccessfulChildScriptMock
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                $joined = $GitArgs -join " "
                if ($joined -eq 'branch --show-current') {
                    $script:branchReadCount++
                    if ($script:branchReadCount -eq 1) { return @{ Output = @('main'); ExitCode = 0 } }
                    return @{ Output = @('release/full-20260703171500'); ExitCode = 0 }
                }
                if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') {
                    return @{ Output = @('abc123'); ExitCode = 0 }
                }
                if ($joined -eq 'checkout main') {
                    return @{ Output = @('blocked'); ExitCode = 1 }
                }
                return @{ Output = @(); ExitCode = 0 }
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Failed to checkout main"
            @($script:capturedChildCalls).Count | Should -Be 1
            (@($script:capturedGitArgsList | ForEach-Object { $_ -join " " }) -join "`n") | Should -Not -Match "pull origin main"
        }
    }

    Context "additional failure paths" {
        It "returns 1 when preflight command '<FailingCommand>' fails" -ForEach @(
            @{ FailingCommand = 'status --porcelain'; ExpectedMessage = 'Failed to read git status' }
            @{ FailingCommand = 'branch --show-current'; ExpectedMessage = 'Failed to read current git branch' }
            @{ FailingCommand = 'fetch origin main'; ExpectedMessage = 'Failed to fetch origin/main' }
            @{ FailingCommand = 'rev-parse main'; ExpectedMessage = 'Failed to resolve local main' }
            @{ FailingCommand = 'rev-parse origin/main'; ExpectedMessage = 'Failed to resolve origin/main' }
        ) {
            $script:failingCommand = $FailingCommand
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $joined = $GitArgs -join " "
                if ($joined -eq $script:failingCommand) { return @{ Output = @('failed'); ExitCode = 1 } }
                if ($joined -eq 'branch --show-current') { return @{ Output = @('main'); ExitCode = 0 } }
                if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') { return @{ Output = @('abc123'); ExitCode = 0 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptPath
                $null = $ScriptArguments
                throw "child script wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match $ExpectedMessage
            Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
        }

        It "returns 1 and stops correctly for post-PR scenario '<Scenario>'" -ForEach @(
            @{ Scenario = 'FullScript'; ExpectedMessage = 'Full release PR script failed'; ExpectedChildCount = 1 }
            @{ Scenario = 'ReleaseBranchRead'; ExpectedMessage = 'Failed to read release branch'; ExpectedChildCount = 1 }
            @{ Scenario = 'ReleaseBranchMain'; ExpectedMessage = 'Release branch could not be determined'; ExpectedChildCount = 1 }
            @{ Scenario = 'EmptyPrNumber'; ExpectedMessage = 'gh returned no pull request number'; ExpectedChildCount = 1 }
            @{ Scenario = 'PullMain'; ExpectedMessage = 'Failed to pull merged main'; ExpectedChildCount = 1 }
            @{ Scenario = 'TagPush'; ExpectedMessage = 'Release tag push script failed'; ExpectedChildCount = 2 }
        ) {
            $script:postPrScenario = $Scenario
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                $joined = $GitArgs -join " "
                if ($joined -eq 'branch --show-current') {
                    $script:branchReadCount++
                    if ($script:branchReadCount -eq 1) { return @{ Output = @('main'); ExitCode = 0 } }
                    if ($script:postPrScenario -eq 'ReleaseBranchRead') { return @{ Output = @('failed'); ExitCode = 1 } }
                    if ($script:postPrScenario -eq 'ReleaseBranchMain') { return @{ Output = @('main'); ExitCode = 0 } }
                    return @{ Output = @('release/full-20260703171500'); ExitCode = 0 }
                }
                if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') { return @{ Output = @('abc123'); ExitCode = 0 } }
                if ($joined -eq 'pull origin main' -and $script:postPrScenario -eq 'PullMain') { return @{ Output = @('failed'); ExitCode = 1 } }
                return @{ Output = @(); ExitCode = 0 }
            }
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $joined = $GhArgs -join " "
                if ($joined -match '^pr view ' -and $script:postPrScenario -eq 'EmptyPrNumber') { return @{ Output = @(''); ExitCode = 0 } }
                if ($joined -match '^pr view ') { return @{ Output = @('291'); ExitCode = 0 } }
                return @{ Output = @('ok'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                param([string]$ScriptPath, [string[]]$ScriptArguments)
                $null = $ScriptArguments
                $script:capturedChildCalls.Add($ScriptPath)
                if ($script:postPrScenario -eq 'FullScript') { return 7 }
                if ($script:postPrScenario -eq 'TagPush' -and $ScriptPath -match 'Invoke-ReleaseTagPush') { return 9 }
                return 0
            }

            $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match $ExpectedMessage
            @($script:capturedChildCalls).Count | Should -Be $ExpectedChildCount
        }
    }

    Context "helpers" {
        It "creates command result objects with output and exit code" {
            $result = ConvertTo-CommandResult -Output @('line') -ExitCode 3
            $result.Output | Should -Be @('line')
            $result.ExitCode | Should -Be 3
        }

        It "returns the first non-empty output line" {
            Get-FirstOutputLine -Output @('', '  42  ', '43') | Should -Be '42'
        }

        It "returns an empty string when no output line contains text" {
            Get-FirstOutputLine -Output @('', '   ') | Should -Be ''
        }

        It "accepts an empty array as Output without throwing" {
            { ConvertTo-CommandResult -Output @() -ExitCode 0 } | Should -Not -Throw
            $result = ConvertTo-CommandResult -Output @() -ExitCode 0
            $result.Output.Count | Should -Be 0
            $result.ExitCode | Should -Be 0
        }
    }

    Context "entry point" {
        It "returns exit code 2 when invoked with an unconfirmed token" {
            $originalError = [Console]::Error
            $capture = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($capture)
                & $script:scriptPath -ConfirmToken 'no' -RepoRoot '/repo'
            }
            finally {
                [Console]::SetError($originalError)
            }
            $LASTEXITCODE | Should -Be 2
            $capture.ToString() | Should -Match "Automated full release flow not confirmed"
        }
    }
}
