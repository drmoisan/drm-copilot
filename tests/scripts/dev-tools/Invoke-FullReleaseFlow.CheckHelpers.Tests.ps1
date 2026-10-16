Set-StrictMode -Version Latest
Describe "Invoke-FullReleaseFlow.CheckHelpers.ps1 - Get-CheckSetVerdict" {
    BeforeAll {
        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path
        . $script:helpersPath
    }

    It "reports pass for a set of pass buckets" {
        $checks = @([pscustomobject]@{ bucket = 'pass' }, [pscustomobject]@{ bucket = 'pass' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'pass'
    }

    It "reports pass for a set of pass and skipping buckets" {
        $checks = @([pscustomobject]@{ bucket = 'pass' }, [pscustomobject]@{ bucket = 'skipping' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'pass'
    }

    It "reports pending when a pending bucket accompanies pass buckets" {
        $checks = @([pscustomobject]@{ bucket = 'pass' }, [pscustomobject]@{ bucket = 'pending' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'pending'
    }

    It "reports fail for a fail bucket" {
        $checks = @([pscustomobject]@{ bucket = 'pass' }, [pscustomobject]@{ bucket = 'fail' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'fail'
    }

    It "reports fail for a cancel bucket" {
        $checks = @([pscustomobject]@{ bucket = 'cancel' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'fail'
    }

    It "reports fail ahead of pending and unknown buckets" {
        $checks = @(
            [pscustomobject]@{ bucket = 'queued' },
            [pscustomobject]@{ bucket = 'pending' },
            [pscustomobject]@{ bucket = 'fail' }
        )

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'fail'
    }

    It "reports unknown for a bucket outside the vocabulary" {
        $checks = @([pscustomobject]@{ bucket = 'pass' }, [pscustomobject]@{ bucket = 'queued' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'unknown'
        $verdict.Detail | Should -Be 'queued'
    }

    It "reports unknown for a missing bucket property" {
        $checks = @([pscustomobject]@{ name = 'lint' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'unknown'
        $verdict.Detail | Should -Be '(missing)'
    }

    It "reports unknown for a blank bucket value" {
        $checks = @([pscustomobject]@{ bucket = '   ' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'unknown'
        $verdict.Detail | Should -Be '(missing)'
    }

    It "reports unknown for a bucket that differs only in case" {
        $checks = @([pscustomobject]@{ bucket = 'PASS' })

        $verdict = Get-CheckSetVerdict -Checks $checks

        $verdict.Verdict | Should -Be 'unknown'
        $verdict.Detail | Should -BeExactly 'PASS'
    }

    It "reports empty for an empty check set" {
        $verdict = Get-CheckSetVerdict -Checks @()

        $verdict.Verdict | Should -Be 'empty'
    }
}

Describe "Invoke-FullReleaseFlow.CheckHelpers.ps1 - ConvertFrom-CheckPollOutput" {
    BeforeAll {
        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path
        . $script:helpersPath
    }

    It "parses a JSON array into check objects" {
        $output = @('[{"bucket":"pass"},{"bucket":"pending"}]')

        $parsed = ConvertFrom-CheckPollOutput -Output $output

        $parsed.Succeeded | Should -BeTrue
        @($parsed.Checks).Count | Should -Be 2
        @($parsed.Checks)[0].bucket | Should -Be 'pass'
    }

    It "parses an empty JSON array as an empty successful result" {
        $parsed = ConvertFrom-CheckPollOutput -Output @('[]')

        $parsed.Succeeded | Should -BeTrue
        @($parsed.Checks).Count | Should -Be 0
        $parsed.Checks | Should -BeNullOrEmpty
    }

    It "joins multi-line output before parsing" {
        $output = @('[', '  {"bucket":"skipping"}', ']')

        $parsed = ConvertFrom-CheckPollOutput -Output $output

        $parsed.Succeeded | Should -BeTrue
        @($parsed.Checks).Count | Should -Be 1
        @($parsed.Checks)[0].bucket | Should -Be 'skipping'
    }

    It "reports failure for blank output" {
        $parsed = ConvertFrom-CheckPollOutput -Output @('', '   ')

        $parsed.Succeeded | Should -BeFalse
    }

    It "reports failure for text that is not JSON" {
        $parsed = ConvertFrom-CheckPollOutput -Output @('not json')

        $parsed.Succeeded | Should -BeFalse
    }

    It "reports failure for a null element" {
        $parsed = ConvertFrom-CheckPollOutput -Output @('[null]')

        $parsed.Succeeded | Should -BeFalse
    }

    It "reports failure for a scalar element" {
        $parsed = ConvertFrom-CheckPollOutput -Output @('[1]')

        $parsed.Succeeded | Should -BeFalse
    }
}

Describe "Invoke-FullReleaseFlow.CheckHelpers.ps1 - Test-UnregisteredCheckPollOutput" {
    BeforeAll {
        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1")).Path
        . $script:helpersPath
    }

    It "reports true for the gh no-checks message" {
        $output = @("no checks reported on the 'release/full-20260703171500' branch")

        $result = Test-UnregisteredCheckPollOutput -Output $output

        $result | Should -BeTrue
    }

    It "reports true for the gh no-checks message delivered as an error record" {
        $record = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new("no checks reported on the 'release/full-20260703171500' branch"), 'gh', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)

        $result = Test-UnregisteredCheckPollOutput -Output @($record)

        $result | Should -BeTrue
    }

    It "reports false for a gh authentication failure" {
        $output = @('HTTP 401: Bad credentials (https://api.github.com/graphql)')

        $result = Test-UnregisteredCheckPollOutput -Output $output

        $result | Should -BeFalse
    }

    It "reports false for empty output" {
        $result = Test-UnregisteredCheckPollOutput -Output @()

        $result | Should -BeFalse
    }
}
