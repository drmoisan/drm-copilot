Set-StrictMode -Version Latest

Describe "Invoke-CiGateParser.ps1" {
    BeforeAll {
        # Resolve and dot-source the production script so its functions are
        # available in the test scope and its on-disk lines execute under Pester
        # coverage instrumentation. The mandatory parameters are supplied to bind
        # the param block without prompting; the entry-point body is skipped
        # because $MyInvocation.InvocationName -eq '.' when dot-sourced. No live
        # gh, no network, and no temp files are involved.
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/orchestration/Invoke-CiGateParser.ps1")).Path
        . $script:scriptPath -ChecksJson '[]' -HeadSha 'bootstrap-sha'

        # A fixed clock delegate used wherever a deterministic verified_at is
        # required. Returns a constant ISO-8601 string so assertions are stable.
        $script:fixedClock = { '2026-06-24T17:00:00Z' }

        # Helper that serializes an in-memory check set to the JSON shape that
        # `gh pr checks --json bucket,...` produces, so each test can express its
        # scenario as objects rather than hand-written JSON strings.
        function script:ConvertChecksToJson {
            param([object[]]$Checks)
            if ($null -eq $Checks) { return '[]' }
            return (ConvertTo-Json -InputObject @($Checks) -Depth 5)
        }
    }

    Context "conclusion derivation across bucket combinations" {
        It "returns success when all required checks pass" {
            # Arrange: every required check is in the 'pass' bucket.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'build'; bucket = 'pass' },
                @{ name = 'test'; bucket = 'pass' }
            )

            # Act
            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            # Assert
            $result.conclusion | Should -Be 'success'
        }

        It "returns failure when any required check failed" {
            # Arrange: one 'fail' bucket among passing checks.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'build'; bucket = 'pass' },
                @{ name = 'test'; bucket = 'fail' }
            )

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'failure'
        }

        It "returns pending when a check is in progress and none failed" {
            # Arrange: one 'pending' bucket, no failures.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'build'; bucket = 'pass' },
                @{ name = 'test'; bucket = 'pending' }
            )

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'pending'
        }

        It "returns failure when a check is cancelled (cancel maps to failure)" {
            # Arrange: a 'cancel' bucket among otherwise-passing checks.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'build'; bucket = 'pass' },
                @{ name = 'deploy'; bucket = 'cancel' }
            )

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'failure'
        }

        It "returns success when a check is skipping (skipping is non-blocking)" {
            # Arrange: a 'skipping' bucket among otherwise-passing checks.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'build'; bucket = 'pass' },
                @{ name = 'optional'; bucket = 'skipping' }
            )

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'success'
        }

        It "returns success for an empty required-check array (vacuous satisfaction)" {
            # Arrange: no required checks configured.
            $json = '[]'

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'success'
        }

        It "prefers failure over pending when both are present" {
            # Arrange: failure precedence over pending; both buckets present.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'a'; bucket = 'pending' },
                @{ name = 'b'; bucket = 'fail' }
            )

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $result.conclusion | Should -Be 'failure'
        }
    }

    Context "fail-fast error handling" {
        It "throws an explicit error on malformed JSON" {
            # Arrange: not valid JSON.
            $bad = '{ this is not json'

            # Act / Assert
            { Invoke-CiGateParser -ChecksJson $bad -HeadSha 'sha1' -NowProvider $script:fixedClock } |
                Should -Throw -ExpectedMessage '*malformed checks JSON*'
        }

        It "throws an explicit error naming an unrecognized bucket value" {
            # Arrange: an unknown bucket enum value.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'mystery'; bucket = 'weird-state' }
            )

            { Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock } |
                Should -Throw -ExpectedMessage "*unrecognized check bucket 'weird-state'*"
        }

        It "throws an explicit error when a check element lacks a bucket property" {
            # Arrange: a check object that omits the required 'bucket' property.
            $json = script:ConvertChecksToJson -Checks @(
                @{ name = 'no-bucket-here' }
            )

            { Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock } |
                Should -Throw -ExpectedMessage "*missing a 'bucket' property*"
        }
    }

    Context "deterministic verified_at via injected clock" {
        It "produces verified_at from the injected NowProvider delegate" {
            # Arrange: a fixed clock returning a known ISO-8601 string.
            $json = '[]'

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            # Assert the exact injected value (no wall-clock read).
            $result.verified_at | Should -Be '2026-06-24T17:00:00Z'
        }
    }

    Context "field passthrough" {
        It "passes head_sha, pr_pipeline_run_id, and pr_pipeline_run_url through to the emitted object" {
            # Arrange
            $json = '[]'

            # Act
            $result = Invoke-CiGateParser `
                -ChecksJson $json `
                -HeadSha 'head-abc123' `
                -PrPipelineRunId 'run-99' `
                -PrPipelineRunUrl 'https://example.test/run/99' `
                -NowProvider $script:fixedClock

            # Assert each field equals its input.
            $result.head_sha | Should -Be 'head-abc123'
            $result.pr_pipeline_run_id | Should -Be 'run-99'
            $result.pr_pipeline_run_url | Should -Be 'https://example.test/run/99'
        }

        It "emits all five ci_gate fields" {
            $json = '[]'

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock

            $names = @($result.PSObject.Properties.Name)
            $names | Should -Contain 'head_sha'
            $names | Should -Contain 'pr_pipeline_run_id'
            $names | Should -Contain 'pr_pipeline_run_url'
            $names | Should -Contain 'conclusion'
            $names | Should -Contain 'verified_at'
        }
    }

    Context "JSON emission" {
        It "emits a JSON string carrying the conclusion when -AsJson is set" {
            $json = script:ConvertChecksToJson -Checks @(@{ name = 'build'; bucket = 'pass' })

            $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -NowProvider $script:fixedClock -AsJson

            $result | Should -BeOfType ([string])
            ($result | ConvertFrom-Json).conclusion | Should -Be 'success'
        }
    }

    Context "Get-CiGateConclusion pure helper" {
        It "returns success for a null check set" {
            Get-CiGateConclusion -Checks $null | Should -Be 'success'
        }
    }
}
