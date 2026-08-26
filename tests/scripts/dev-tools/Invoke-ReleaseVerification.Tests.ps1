Set-StrictMode -Version Latest

Describe "Invoke-ReleaseVerification.ps1 - out-of-band tag publish verification" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseVerification.ps1")).Path
        # Dot-source (never execute) the production module so its on-disk lines run
        # under Pester coverage instrumentation. The entry-point block is skipped
        # because $MyInvocation.InvocationName -eq '.' when dot-sourced, so loading
        # the file starts no process and performs no network call.
        . $script:scriptPath

        $script:tag = 'mcp-server-v1.1.2'
        $script:package = '@danmoisan/drm-copilot-mcp'
        $script:runListFound = '[{"databaseId":42,"headBranch":"mcp-server-v1.1.2","status":"completed","conclusion":"success"}]'
        $script:runListEmpty = '[]'
        $script:viewInProgress = '{"status":"in_progress","conclusion":null,"jobs":[]}'
        $script:viewStepSuccess = '{"status":"completed","conclusion":"success","jobs":[{"name":"Publish to npm","steps":[{"name":"Publish to npm","conclusion":"success"}]}]}'
        $script:viewStepSkipped = '{"status":"completed","conclusion":"success","jobs":[{"name":"Publish to npm","steps":[{"name":"Publish to npm","conclusion":"skipped"}]}]}'
        $script:viewStepMissing = '{"status":"completed","conclusion":"success","jobs":[{"name":"Publish to npm","steps":[{"name":"Build MCP server bundle","conclusion":"success"}]}]}'
        $script:viewRunFailure = '{"status":"completed","conclusion":"failure","jobs":[]}'
        $script:codexConfig = 'args = ["-y", "@danmoisan/drm-copilot-mcp@1.1.2"]'
        $script:neverAttempt = 999
    }

    BeforeEach {
        # Deterministic seam state. Each "OnAttempt" knob makes the corresponding
        # seam report "nothing yet" until the named attempt, so a test can place a
        # result on the first attempt, on a later attempt, or never. All three
        # external surfaces are mocked, so no real gh, npm, or wall-clock wait
        # occurs anywhere in this file.
        $script:listAttempt = 0
        $script:viewAttempt = 0
        $script:npmAttempt = 0
        $script:listFoundOnAttempt = 1
        $script:viewCompletedOnAttempt = 1
        $script:npmResolvesOnAttempt = 1
        $script:viewPayload = $script:viewStepSuccess
        $script:capturedNpmArgs = [System.Collections.Generic.List[object]]::new()
        $script:verifyArgs = @{
            TagName     = $script:tag
            Version     = '1.1.2'
            PackageName = $script:package
            MaxAttempts = 3
        }

        Mock -CommandName Invoke-GhExe -MockWith {
            param([string[]]$GhArgs)
            if (($GhArgs -join ' ') -match '^run list') {
                $script:listAttempt++
                if ($script:listAttempt -lt $script:listFoundOnAttempt) {
                    return @{ Output = @($script:runListEmpty); ExitCode = 0 }
                }
                return @{ Output = @($script:runListFound); ExitCode = 0 }
            }
            $script:viewAttempt++
            if ($script:viewAttempt -lt $script:viewCompletedOnAttempt) {
                return @{ Output = @($script:viewInProgress); ExitCode = 0 }
            }
            return @{ Output = @($script:viewPayload); ExitCode = 0 }
        }
        Mock -CommandName Invoke-NpmExe -MockWith {
            param([string[]]$NpmArgs)
            $script:capturedNpmArgs.Add($NpmArgs)
            $script:npmAttempt++
            if ($script:npmAttempt -lt $script:npmResolvesOnAttempt) {
                return @{ Output = @('npm error code E404'); ExitCode = 1 }
            }
            return @{ Output = @('1.1.2'); ExitCode = 0 }
        }
        Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }
    }

    Context "module surface and seams" {
        It "dot-sources the module and resolves all three mocked seams" {
            foreach ($seam in @('Invoke-GhExe', 'Invoke-NpmExe', 'Invoke-Sleep')) {
                Get-Command -Name $seam -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
            $null = Invoke-GhExe -GhArgs @('run', 'list')
            $null = Invoke-NpmExe -NpmArgs @('view', $script:package)
            Invoke-Sleep -Seconds 1
            Should -Invoke -CommandName Invoke-GhExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-NpmExe -Times 1 -Exactly
            Should -Invoke -CommandName Invoke-Sleep -Times 1 -Exactly
        }
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

    Context "registry resolution check (c)" {
        It "passes the package operand in exact-version form to the npm seam" {
            $null = Test-NpmVersionResolved -Version '1.1.2' -PackageName $script:package

            $script:capturedNpmArgs.Count | Should -Be 1
            $operand = $script:capturedNpmArgs[0][1]
            $operand | Should -Be "$($script:package)@1.1.2"
            # The bare-package operand resolves the 'latest' dist-tag, so it would
            # have reported success throughout the 1.0.25 failure.
            $operand | Should -Not -Be $script:package
        }

        It "reports failure when the exact version is absent while the latest dist-tag resolves" {
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgs.Add($NpmArgs)
                if ($NpmArgs[1] -eq '@danmoisan/drm-copilot-mcp') {
                    # Bare-package form: resolves 'latest' and exits 0 with a different version.
                    return @{ Output = @('1.1.2'); ExitCode = 0 }
                }
                return @{ Output = @('npm error code E404'); ExitCode = 1 }
            }

            Test-NpmVersionResolved -Version '1.0.25' -PackageName $script:package | Should -BeFalse
            # The reported failure must come from the exact-version query. Without
            # this operand assertion the test would still pass against a
            # bare-package implementation, which is the defect the issue's own
            # proposal contained, so the assertion is what makes it able to fail.
            $script:capturedNpmArgs[0][1] | Should -Be "$($script:package)@1.0.25"
        }
    }

    Context "verification state machine" {
        It "returns RESOLVED on a fully successful verification" {
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'RESOLVED'
            $result.ExitCode | Should -Be 0
        }

        It "returns NO_RUN when the run-existence budget is exhausted" {
            $script:listFoundOnAttempt = $script:neverAttempt
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'NO_RUN'
        }

        It "returns RUN_FAILED when the run conclusion is failure" {
            $script:viewPayload = $script:viewRunFailure
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'RUN_FAILED'
        }

        It "returns STEP_SKIPPED when the publish step concluded skipped" {
            $script:viewPayload = $script:viewStepSkipped
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'STEP_SKIPPED'
        }

        It "returns STEP_MISSING when the named step is absent from the payload" {
            $script:viewPayload = $script:viewStepMissing
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'STEP_MISSING'
        }

        It "returns UNRESOLVED when the registry budget is exhausted after the publish step succeeded" {
            $script:npmResolvesOnAttempt = $script:neverAttempt
            $result = Invoke-TagPublishVerification @script:verifyArgs
            $result.State | Should -Be 'UNRESOLVED'
            $result.StepConclusion | Should -Be 'SUCCESS'
        }

        It "does not invoke the npm seam when the registry-resolution check is skipped" {
            # The extension release path publishes to the VS Code Marketplace, so
            # there is no npm version for check (c) to resolve.
            $result = Invoke-TagPublishVerification @script:verifyArgs -SkipRegistryResolutionCheck

            $result.State | Should -Be 'RESOLVED'
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
        }

        It "treats a missing publish step as a non-zero failure rather than absence of evidence" {
            $script:viewPayload = $script:viewStepMissing
            $result = Invoke-TagPublishVerification @script:verifyArgs

            $result.State | Should -Be 'STEP_MISSING'
            $result.ExitCode | Should -Not -Be 0
        }

        It "distinguishes an exhausted run-existence budget from a negative publish-step result" {
            $script:listFoundOnAttempt = $script:neverAttempt
            $exhausted = Invoke-TagPublishVerification @script:verifyArgs

            $script:listFoundOnAttempt = 1
            $script:listAttempt = 0
            $script:viewPayload = $script:viewStepSkipped
            $negative = Invoke-TagPublishVerification @script:verifyArgs

            $exhausted.State | Should -Not -Be $negative.State
            $exhausted.ExitCode | Should -Not -Be 0
            $negative.ExitCode | Should -Not -Be 0
        }
    }

    Context "publish-step classification" {
        It "returns STEP_MISSING when the named job is absent from the run payload" {
            # The absent-JOB path, distinct from the absent-STEP path asserted by
            # "returns STEP_MISSING when the named step is absent from the payload".
            # Every property the classifier reads is present, because this file sets
            # strict mode and an omitted property would throw before the branch
            # under test is reached.
            $payload = '{"status":"completed","conclusion":"success","jobs":[{"name":"Build MCP server bundle","steps":[{"name":"Publish to npm","conclusion":"success"}]}]}' | ConvertFrom-Json

            Resolve-PublishStepConclusion -Run $payload -JobName 'Publish to npm' -StepName 'Publish to npm' |
                Should -Be 'STEP_MISSING'
        }

        It "returns RUN_FAILED when the publish step concluded neither skipped nor success" {
            # A successful run conclusion with a cancelled publish step reaches the
            # fall-through return past both the skipped and the success branches.
            $payload = '{"status":"completed","conclusion":"success","jobs":[{"name":"Publish to npm","steps":[{"name":"Publish to npm","conclusion":"cancelled"}]}]}' | ConvertFrom-Json

            Resolve-PublishStepConclusion -Run $payload -JobName 'Publish to npm' -StepName 'Publish to npm' |
                Should -Be 'RUN_FAILED'
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

        It "returns an empty instruction for an unrecognized state token" {
            # The lookup miss is the branch a future state token lands on before
            # its instruction is authored.
            $instruction = Get-RecoveryInstruction -State 'NOT_A_STATE_TOKEN'

            $instruction | Should -BeNullOrEmpty
            ($instruction -eq '') | Should -BeTrue
        }
    }

    Context "bounded polling budgets" {
        It "check (a) finds the run on the first attempt without sleeping" {
            Wait-ForWorkflowRun -TagName $script:tag -MaxAttempts 4 | Should -Be '42'
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "check (a) finds the run on a later attempt and sleeps once per prior attempt" {
            $script:listFoundOnAttempt = 3
            Wait-ForWorkflowRun -TagName $script:tag -MaxAttempts 4 | Should -Be '42'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "check (a) returns NO_RUN when its attempt budget is exhausted" {
            $script:listFoundOnAttempt = $script:neverAttempt
            Wait-ForWorkflowRun -TagName $script:tag -MaxAttempts 3 | Should -Be 'NO_RUN'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "check (b) reads a completed run on the first attempt without sleeping" {
            Test-PublishStepConclusion -RunIdentifier '42' -MaxAttempts 4 | Should -Be 'SUCCESS'
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "check (b) reads a completed run on a later attempt and sleeps once per prior attempt" {
            $script:viewCompletedOnAttempt = 3
            Test-PublishStepConclusion -RunIdentifier '42' -MaxAttempts 4 | Should -Be 'SUCCESS'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "check (b) returns RUN_FAILED when its attempt budget is exhausted" {
            $script:viewCompletedOnAttempt = $script:neverAttempt
            Test-PublishStepConclusion -RunIdentifier '42' -MaxAttempts 3 | Should -Be 'RUN_FAILED'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "check (c) resolves the version on the first attempt without sleeping" {
            $script:verifyArgs.MaxAttempts = 4
            (Invoke-TagPublishVerification @script:verifyArgs).State | Should -Be 'RESOLVED'
            Should -Invoke -CommandName Invoke-Sleep -Times 0 -Exactly
        }

        It "check (c) resolves the version on a later attempt and sleeps once per prior attempt" {
            $script:verifyArgs.MaxAttempts = 4
            $script:npmResolvesOnAttempt = 3
            (Invoke-TagPublishVerification @script:verifyArgs).State | Should -Be 'RESOLVED'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }

        It "check (c) returns UNRESOLVED when its attempt budget is exhausted" {
            $script:npmResolvesOnAttempt = $script:neverAttempt
            (Invoke-TagPublishVerification @script:verifyArgs).State | Should -Be 'UNRESOLVED'
            Should -Invoke -CommandName Invoke-Sleep -Times 2 -Exactly
        }
    }

    Context "Codex pin registry guard" {
        It "reads the pinned mcp version from in-memory config content and passes it to the registry check" {
            # The config content is supplied in memory; no temporary file is created
            # and no path on disk is read by this test or by the function.
            $pinned = Get-CodexPinnedMcpVersion -ConfigContent $script:codexConfig -PackageName $script:package
            $pinned | Should -Be '1.1.2'

            Test-NpmVersionResolved -Version $pinned -PackageName $script:package | Should -BeTrue
            $script:capturedNpmArgs[0][1] | Should -Be "$($script:package)@1.1.2"
        }

        It "fails when the pinned version does not resolve on the registry" {
            $script:npmResolvesOnAttempt = $script:neverAttempt
            $pinned = Get-CodexPinnedMcpVersion -ConfigContent $script:codexConfig -PackageName $script:package

            Test-NpmVersionResolved -Version $pinned -PackageName $script:package | Should -BeFalse
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
