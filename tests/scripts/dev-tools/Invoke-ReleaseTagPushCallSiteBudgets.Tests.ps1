Set-StrictMode -Version Latest

Describe "Invoke-ReleaseTagPush.ps1 - call-site polling budget forwarding" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseTagPush.ps1")).Path
        # Dot-source the production script so its on-disk lines execute under Pester
        # coverage instrumentation. The mandatory -ConfirmToken is supplied to bind
        # the param without prompting; the entry-point block is skipped because
        # $MyInvocation.InvocationName -eq '.' when dot-sourced.
        . $script:scriptPath -ConfirmToken 'no'
    }

    BeforeEach {
        Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
        Mock -CommandName Get-NpmVersion -MockWith {
            param([string]$ManifestPath)
            if ($ManifestPath -match 'mcp-server') { return "0.0.2" }
            return "0.0.3"
        }
        Mock -CommandName Invoke-GitExe -MockWith {
            param([string[]]$GitArgs)
            $null = $GitArgs
            return @{ Output = @(); ExitCode = 0 }
        }
        Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
        # Every call always fails, so the real, unmocked Test-NpmVersionResolved
        # always reports $false. This both satisfies the pre-push guard's "not
        # yet consumed" requirement and drives check (c)'s full attempt budget
        # when a test reaches it.
        Mock -CommandName Invoke-NpmExe -MockWith {
            param([string[]]$NpmArgs)
            $null = $NpmArgs
            return @{ Output = @('npm error code E404'); ExitCode = 1 }
        }
    }

    Context "call-site budget forwarding to Invoke-TagPublishVerification" {
        # This composition/forwarding logic under Invoke-TagPublishVerification
        # itself is never mocked in this file: as long as it stays real, its own
        # defaults genuinely flow through to the mocked check entry points below,
        # reproducing the #526 reaudit's m8 probe methodology exactly.

        It "forwards the check (a) interval and attempt budget to Wait-ForWorkflowRun" {
            Mock -CommandName Wait-ForWorkflowRun -ParameterFilter { $IntervalSeconds -eq 10 -and $MaxAttempts -eq 18 } -MockWith { 'NO_RUN' }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken 'yes' -RepoRoot '/repo'

            $result | Should -Be 1
            Should -Invoke -CommandName Wait-ForWorkflowRun -Times 1 -Exactly -ParameterFilter { $IntervalSeconds -eq 10 -and $MaxAttempts -eq 18 }
        }

        It "forwards the check (b) interval and attempt budget to Test-PublishStepConclusion" {
            Mock -CommandName Wait-ForWorkflowRun -MockWith { '4242' }
            Mock -CommandName Test-PublishStepConclusion -ParameterFilter { $IntervalSeconds -eq 20 -and $MaxAttempts -eq 60 } -MockWith { 'STEP_SKIPPED' }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken 'yes' -RepoRoot '/repo'

            $result | Should -Be 1
            Should -Invoke -CommandName Test-PublishStepConclusion -Times 1 -Exactly -ParameterFilter { $IntervalSeconds -eq 20 -and $MaxAttempts -eq 60 }
        }

        It "polls the registry with the check (c) interval and attempt budget" {
            # Wait-ForWorkflowRun and Test-PublishStepConclusion are mocked
            # permissively so execution reaches check (c). The npm seam never
            # resolves, so check (c) runs its full default 40-attempt budget
            # with 39 intervening 15-second sleeps. The pre-push guard above it
            # contributes exactly one additional Invoke-NpmExe call, for a total
            # of 41; the guard itself performs no sleep.
            Mock -CommandName Wait-ForWorkflowRun -MockWith { '4242' }
            Mock -CommandName Test-PublishStepConclusion -MockWith { 'SUCCESS' }

            $result = Invoke-ReleaseTagPushGuarded -ConfirmToken 'yes' -RepoRoot '/repo'

            $result | Should -Be 1
            Should -Invoke -CommandName Invoke-NpmExe -Times 41 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 39 -Exactly -ParameterFilter { $Seconds -eq 15 }
        }
    }
}
