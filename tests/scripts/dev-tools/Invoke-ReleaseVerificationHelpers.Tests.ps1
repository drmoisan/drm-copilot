Set-StrictMode -Version Latest

Describe "Invoke-ReleaseVerificationHelpers.ps1 - pure helpers" {
    BeforeAll {
        $script:helpersPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1")).Path
        # Dot-source the helpers module and nothing else. Every function under test
        # here is pure, so this file registers no mock, starts no process, opens no
        # file, and takes no wall-clock wait.
        . $script:helpersPath

        $script:package = '@danmoisan/drm-copilot-mcp'
        $script:codexConfig = 'args = ["-y", "@danmoisan/drm-copilot-mcp@1.1.2"]'
    }

    Context "JSON parse tolerance" {
        It "returns null for whitespace-only JSON text" {
            # An empty or whitespace-only seam response means "nothing found yet",
            # which a bounded poll must treat as a retryable attempt.
            $parsed = ConvertFrom-JsonSafely -Text '   '

            $parsed | Should -BeNullOrEmpty
        }

        It "returns null instead of throwing for malformed JSON text" {
            # A transient non-JSON response must retry rather than abort the poll,
            # so a parse failure is returned as a value and never raised as a
            # terminating error.
            $parsed = ConvertFrom-JsonSafely -Text '{"databaseId":'

            $parsed | Should -BeNullOrEmpty
        }
    }

    Context "operator recovery instructions" {
        It "emits pairwise distinct recovery instructions for NO_RUN, STEP_SKIPPED, and UNRESOLVED" {
            $noRun = Get-RecoveryInstruction -State 'NO_RUN'
            $skipped = Get-RecoveryInstruction -State 'STEP_SKIPPED'
            $unresolved = Get-RecoveryInstruction -State 'UNRESOLVED'

            $noRun | Should -Not -BeNullOrEmpty
            $skipped | Should -Not -BeNullOrEmpty
            $unresolved | Should -Not -BeNullOrEmpty
            # A single generic failure message would not tell the operator whether
            # the version number was consumed, which is what decides retry safety.
            $noRun | Should -Not -Be $skipped
            $noRun | Should -Not -Be $unresolved
            $skipped | Should -Not -Be $unresolved
        }

        It "emits a RUN_INCOMPLETE instruction distinct from the RUN_FAILED instruction" {
            # RUN_INCOMPLETE means the polling budget expired with the run still in
            # progress, so the correct action is to re-run the verifier.
            # RUN_FAILED means a terminal failure conclusion was observed, so the
            # correct action is to read the run logs. Sharing one instruction would
            # send the operator to read the logs of a run that has not concluded.
            $incomplete = Get-RecoveryInstruction -State 'RUN_INCOMPLETE'
            $failed = Get-RecoveryInstruction -State 'RUN_FAILED'

            $incomplete | Should -Not -BeNullOrEmpty
            $failed | Should -Not -BeNullOrEmpty
            $incomplete | Should -Not -Be $failed
        }

        It "returns an empty instruction for an unrecognized state token" {
            # The lookup miss is the branch a future state token lands on before
            # its instruction is authored.
            $instruction = Get-RecoveryInstruction -State 'NOT_A_STATE_TOKEN'

            $instruction | Should -BeNullOrEmpty
            ($instruction -eq '') | Should -BeTrue
        }
    }

    Context "verification result construction" {
        It "sets ExitCode 0 only for the RESOLVED state" {
            # The success path is the sole zero exit code. Any other token must
            # carry a non-zero code, because a release script reads this value to
            # decide whether the release succeeded.
            $resolved = ConvertTo-VerificationResult -State 'RESOLVED' -RunExistence '42' -StepConclusion 'SUCCESS'
            $resolved.ExitCode | Should -Be 0
            $resolved.State | Should -Be 'RESOLVED'
            $resolved.RunExistence | Should -Be '42'
            $resolved.StepConclusion | Should -Be 'SUCCESS'

            foreach ($state in @('NO_RUN', 'RUN_FAILED', 'STEP_SKIPPED', 'STEP_MISSING', 'UNRESOLVED')) {
                $result = ConvertTo-VerificationResult -State $state -RunExistence 'NOT_REACHED' -StepConclusion 'NOT_REACHED'
                $result.ExitCode | Should -Not -Be 0
                $result.State | Should -Be $state
            }
        }

        It "carries the recovery instruction of its own state token" {
            $result = ConvertTo-VerificationResult -State 'STEP_SKIPPED' -RunExistence '42' -StepConclusion 'STEP_SKIPPED'

            $result.Instruction | Should -Be (Get-RecoveryInstruction -State 'STEP_SKIPPED')
            $result.Instruction | Should -Not -BeNullOrEmpty
        }
    }

    Context "Codex pin parsing" {
        It "reads the pinned mcp version from in-memory Codex config content" {
            # The config content is supplied in memory; no temporary file is created
            # and no path on disk is read by this test or by the function.
            $pinned = Get-CodexPinnedMcpVersion -ConfigContent $script:codexConfig -PackageName $script:package

            $pinned | Should -Be '1.1.2'
        }

        It "returns null when the Codex config content is empty" {
            # The AllowEmptyString attribute admits the empty operand, so the
            # whitespace guard is what decides the result.
            $pinned = Get-CodexPinnedMcpVersion -ConfigContent '' -PackageName $script:package

            $pinned | Should -BeNullOrEmpty
        }

        It "returns null when the Codex config pins no mcp-server package" {
            # The regex-miss path. Content is supplied in memory; neither this test
            # nor the function reads a path on disk or opens a temporary file.
            $pinned = Get-CodexPinnedMcpVersion -ConfigContent 'args = ["-y", "@scope/other-package@9.9.9"]' -PackageName $script:package

            $pinned | Should -BeNullOrEmpty
        }
    }
}
