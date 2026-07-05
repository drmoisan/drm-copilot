Set-StrictMode -Version Latest
Describe "Invoke-FullReleaseFlow.ps1 - Wait-ForPullRequestChecks" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
        . $script:scriptPath -ConfirmToken 'no'
    }

    BeforeEach {
        $script:ghCallCount = 0
        $script:sleepCallCount = 0
        $script:capturedMessage = $null
    }

    Context "registration phase" {
        It "waits through the registration race then merges" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                $script:ghCallCount++
                if ($script:ghCallCount -le 2) {
                    return @{ Output = @("no checks reported on the 'release/full-20260703171500' branch"); ExitCode = 1 }
                }
                return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-Sleep -MockWith {
                param([int]$Seconds)
                $null = $Seconds
                $script:sleepCallCount++
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 5 -RegistrationIntervalSeconds 1

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "returns failure on registration timeout" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                $script:ghCallCount++
                return @{ Output = @('no checks reported'); ExitCode = 1 }
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 3 -RegistrationIntervalSeconds 1

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "did not register within the timeout"
            Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
        }
    }

    Context "completion phase" {
        It "waits through pending checks then completes" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                $script:ghCallCount++
                if ($script:ghCallCount -eq 1) {
                    return @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 }
                }
                return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 5 -CompletionIntervalSeconds 1

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-Sleep -Times 1 -Exactly
        }

        It "returns failure on completion timeout" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                return @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 3 -CompletionIntervalSeconds 1

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "did not complete within the timeout"
        }

        It "returns failure immediately on a genuine check failure without exhausting the completion timeout" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                return @{ Output = @('[{"bucket":"fail"}]'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 50

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "A required check failed for PR #291"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
        }
    }

    Context "sleep seam" {
        It "invokes the sleep seam between registration polls and between completion polls" {
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                $script:ghCallCount++
                if ($script:ghCallCount -le 2) {
                    return @{ Output = @("no checks reported on the 'release/full-20260703171500' branch"); ExitCode = 1 }
                }
                if ($script:ghCallCount -eq 3) {
                    return @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 }
                }
                return @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
            }
            Mock -CommandName Invoke-Sleep -MockWith {
                param([int]$Seconds)
                $null = $Seconds
                $script:sleepCallCount++
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 5 -RegistrationIntervalSeconds 1 -CompletionMaxAttempts 5 -CompletionIntervalSeconds 1

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-Sleep -Times 3 -Exactly
        }
    }
}
