Set-StrictMode -Version Latest

Describe "Invoke-CiGateParser.ps1" {
    BeforeAll {
        # Resolve and dot-source the production script so its functions are
        # available in the test scope and its on-disk lines execute under Pester
        # coverage instrumentation. The mandatory parameters are supplied to bind
        # the param block without prompting; the entry-point body is skipped
        # because $MyInvocation.InvocationName -eq '.' when dot-sourced. No live
        # gh, no network, and no temp files are involved.
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../../.claude/lib/ci-gate/Invoke-CiGateParser.ps1")).Path
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

        It "returns success for an empty required-check array without -RequireWorkflow (vacuous satisfaction)" {
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

    Context "-RequireWorkflow parameter surface" {
        BeforeAll {
            # Parse the production script once. The AST exposes every declared
            # parameter, its default value, and the comment-based help of the
            # script and of each function without executing the script.
            $script:scriptAst = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $isFunctionDefinition = { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }
            $script:functionAsts = @($script:scriptAst.FindAll($isFunctionDefinition, $true))
        }

        It "declares -RequireWorkflow as a string defaulting to '' on the script, Invoke-CiGateParser, and Get-CiGateConclusion" {
            # Arrange: the script param block and the param blocks of both functions.
            $paramBlocks = @(
                $script:scriptAst.ParamBlock
                ($script:functionAsts | Where-Object { $_.Name -eq 'Invoke-CiGateParser' }).Body.ParamBlock
                ($script:functionAsts | Where-Object { $_.Name -eq 'Get-CiGateConclusion' }).Body.ParamBlock
            )
            $paramBlocks.Count | Should -Be 3

            foreach ($paramBlock in $paramBlocks) {
                # Act: select the RequireWorkflow declaration of this surface.
                $parameter = @($paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'RequireWorkflow' })

                # Assert: declared once, typed [string], defaulting to ''.
                $parameter.Count | Should -Be 1 -Because 'each surface declares -RequireWorkflow exactly once'
                $parameter[0].StaticType | Should -Be ([string])
                $parameter[0].DefaultValue.Extent.Text | Should -Be "''"
            }
        }

        It "documents .PARAMETER RequireWorkflow in the help of the script, Invoke-CiGateParser, and Get-CiGateConclusion" {
            # Arrange: the comment-based help of the script and of both functions.
            $helpBlocks = @(
                $script:scriptAst.GetHelpContent()
                ($script:functionAsts | Where-Object { $_.Name -eq 'Invoke-CiGateParser' }).GetHelpContent()
                ($script:functionAsts | Where-Object { $_.Name -eq 'Get-CiGateConclusion' }).GetHelpContent()
            )
            $helpBlocks.Count | Should -Be 3

            foreach ($help in $helpBlocks) {
                # Assert: each help block documents the RequireWorkflow parameter.
                @($help.Parameters.Keys) | Should -Contain 'RequireWorkflow'
            }
        }
    }

    Context "-RequireWorkflow (epic-child guard)" {
        BeforeAll {
            # Runs the full parser over an in-memory check set with the guard set
            # to CI and returns only the derived conclusion.
            function script:Get-GuardedConclusion {
                param([object[]]$Checks)
                $json = script:ConvertChecksToJson -Checks $Checks
                $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -RequireWorkflow 'CI' -NowProvider $script:fixedClock
                return $result.conclusion
            }
        }

        It "returns pending for an empty check array with -RequireWorkflow CI" {
            # Act: no check is observed at all.
            $result = Invoke-CiGateParser -ChecksJson '[]' -HeadSha 'sha1' -RequireWorkflow 'CI' -NowProvider $script:fixedClock

            # Assert: an empty set never satisfies the guard.
            $result.conclusion | Should -Be 'pending'
        }

        It "returns pending for a null check set with -RequireWorkflow CI" {
            # Act / Assert: the pure helper treats $null like an empty set.
            Get-CiGateConclusion -Checks $null -RequireWorkflow 'CI' | Should -Be 'pending'
        }

        It "returns pending when only non-CI checks pass" {
            # Arrange: passing checks from other workflows only.
            $checks = @(
                @{ name = 'publish'; bucket = 'pass'; workflow = 'Publish Extension' },
                @{ name = 'verify'; bucket = 'pass'; workflow = 'Verify Published Releases' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns success when a CI check passes" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pass'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'success'
        }

        It "returns success when a CI check and a non-CI check both pass" {
            # Arrange
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'pass'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'success'
        }

        It "returns failure when a CI check failed" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'fail'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns failure when a CI check was cancelled" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'cancel'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns failure when a CI check passes and a non-CI check failed" {
            # Arrange: a failing non-CI check fails the gate on an epic child.
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'fail'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns pending when a CI check is pending" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pending'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns pending when a CI check passes and a non-CI check is pending" {
            # Arrange
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'pending'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns failure when a CI check is pending and another check failed" {
            # Arrange: failure outranks pending regardless of order.
            $checks = @(
                @{ name = 'build'; bucket = 'pending'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'fail'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns pending when the only CI checks are skipping" {
            # Arrange: a skipped CI run is not an observed success.
            $checks = @(
                @{ name = 'build'; bucket = 'skipping'; workflow = 'CI' },
                @{ name = 'test'; bucket = 'skipping'; workflow = 'CI' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "does not match a lowercase ci workflow name (case-sensitive)" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pass'; workflow = 'ci' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "treats an element without a workflow property as non-matching without throwing" {
            # Arrange: a status context without a workflow property, alone and beside a CI pass.
            $statusOnly = @(@{ name = 'status-context'; bucket = 'pass' })
            $withCi = @(
                @{ name = 'status-context'; bucket = 'pass' },
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' }
            )

            # Act / Assert: the element never matches and never throws.
            script:Get-GuardedConclusion -Checks $statusOnly | Should -Be 'pending'
            script:Get-GuardedConclusion -Checks $withCi | Should -Be 'success'
        }

        It "throws an error naming -RequireWorkflow for a whitespace-only value" {
            # Act / Assert: a whitespace-only name is rejected instead of disabling the guard.
            { Get-CiGateConclusion -Checks @() -RequireWorkflow '   ' } |
                Should -Throw -ExpectedMessage '*-RequireWorkflow*whitespace-only*'
        }

        It "forwards -RequireWorkflow from the script entry point" {
            # Act: run the script file so its process block forwards the parameter.
            $result = & $script:scriptPath -ChecksJson '[]' -HeadSha 'x' -RequireWorkflow 'CI' -NowProvider $script:fixedClock

            # Assert
            $result.conclusion | Should -Be 'pending'
        }
    }
}
