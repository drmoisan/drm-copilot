Set-StrictMode -Version Latest
Describe "Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded - additional failure paths" {
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
        Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
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
                if ($joined -match '^pr checks ') { return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 } }
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
}
