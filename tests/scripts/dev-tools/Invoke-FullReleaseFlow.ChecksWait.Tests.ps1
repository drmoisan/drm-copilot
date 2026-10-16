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

        It "returns failure at once without sleeping when gh fails with '<FailureText>'" -ForEach @(
            @{ FailureText = 'HTTP 401: Bad credentials (https://api.github.com/graphql)'; FailureExitCode = 1 }
            @{ FailureText = 'To get started with GitHub CLI, please run:  gh auth login'; FailureExitCode = 4 }
            @{ FailureText = 'error connecting to api.github.com'; FailureExitCode = 1 }
        ) {
            $script:failurePoll = @{ Output = @($FailureText); ExitCode = $FailureExitCode }
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                return $script:failurePoll
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Could not query the checks for PR #291"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "keeps retrying while gh reports no registered checks as an error record" {
            $script:notRegistered = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new("no checks reported on the 'release/full-20260703171500' branch"), 'gh', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $null = $GhArgs
                $script:ghCallCount++
                if ($script:ghCallCount -le 2) {
                    return @{ Output = @($script:notRegistered); ExitCode = 1 }
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
            $script:capturedMessage | Should -Match "A check failed for PR #291"
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

    Context "all-checks classification" {
        BeforeEach {
            # Each test sets $script:responses; the mock returns them in call order and repeats the last one.
            $script:responses = @()
            $script:capturedArgs = $null
            Mock -CommandName Invoke-GhExe -MockWith {
                param([string[]]$GhArgs)
                $script:capturedArgs = $GhArgs
                $index = [Math]::Min($script:ghCallCount, $script:responses.Count - 1)
                $script:ghCallCount++
                return $script:responses[$index]
            }
            Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
        }

        It "polls gh pr checks without the required flag" {
            $script:responses = @(@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 0
            ($script:capturedArgs -join ' ') | Should -Be 'pr checks 291 --json bucket'
            $script:capturedArgs | Should -Not -Contain '--required'
        }

        It "returns failure when a non-required check fails" {
            $script:responses = @(@{ Output = @('[{"bucket":"pass"},{"bucket":"fail"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 50

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "A check failed for PR #291"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "returns failure when a check is cancelled" {
            $script:responses = @(@{ Output = @('[{"bucket":"pass"},{"bucket":"cancel"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 1
        }

        It "keeps polling and times out on an empty check set" {
            $script:responses = @(@{ Output = @('[]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 3

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "did not complete within the timeout"
            Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
        }

        It "returns failure on an unrecognized bucket" {
            $script:responses = @(@{ Output = @('[{"bucket":"queued"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 50

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "unrecognized bucket"
            $script:capturedMessage | Should -Match "queued"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
        }

        It "returns failure on a check with no bucket property" {
            $script:responses = @(@{ Output = @('[{"name":"lint"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "unrecognized bucket"
        }

        It "reports a failed check ahead of an unrecognized bucket" {
            $script:responses = @(@{ Output = @('[{"bucket":"queued"},{"bucket":"fail"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "A check failed for PR #291"
        }

        It "returns success when buckets are a mix of pass and skipping" {
            $script:responses = @(@{ Output = @('[{"bucket":"pass"},{"bucket":"skipping"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "returns success when every bucket is skipping" {
            $script:responses = @(@{ Output = @('[{"bucket":"skipping"}]'); ExitCode = 0 })

            $result = Wait-ForPullRequestChecks -PrNumber '291'

            $result | Should -Be 0
        }

        It "returns failure without throwing on unparsable check output" {
            $script:responses = @(@{ Output = @('not json'); ExitCode = 0 })

            { $script:result = Wait-ForPullRequestChecks -PrNumber '291' } | Should -Not -Throw

            $script:result | Should -Be 1
            $script:capturedMessage | Should -Match "Could not parse the check results"
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
        }

        It "continues after a non-zero completion poll" {
            $script:responses = @(
                @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 },
                @{ Output = @('HTTP 502: Bad Gateway'); ExitCode = 1 },
                @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
            )

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 5

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "continues after an unparsable completion poll" {
            $script:responses = @(
                @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 },
                @{ Output = @('not json'); ExitCode = 0 },
                @{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }
            )

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 5

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
        }

        It "times out when completion polls keep failing" {
            $script:responses = @(
                @{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 },
                @{ Output = @('HTTP 502: Bad Gateway'); ExitCode = 1 }
            )

            $result = Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 3

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "did not complete within the timeout"
            Should -Invoke -CommandName Invoke-GhExe -Times 3 -Exactly
        }
    }
}
