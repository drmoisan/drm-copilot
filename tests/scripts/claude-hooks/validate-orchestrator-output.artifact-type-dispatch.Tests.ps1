#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the $ArtifactType dispatch of the default routing invoker in
    .claude/hooks/validate-orchestrator-output.ps1 (issue #475, SD-2 / D-1 / PD-3).

.DESCRIPTION
    Kept in a sibling file because validate-orchestrator-output.Tests.ps1 is close
    to the 500-line cap and cannot absorb these contexts.

    Three dispatch legs are wired and are covered here:

      orchestrator-state
          routes to the complete-parity completion validation.

      epic-orchestrator-state, parallel-orchestrator-state
          route to the type-scoped structural check (exists, parses as JSON,
          object root). PD-3: the Python reference exits 2 with an argparse usage
          error for these types under this hook's flag pair and runs zero checks,
          so parity is UNDEFINED there; the structural check is DEFINED fail-closed
          behavior chosen for that region, not a deferral.

      any other type
          fails closed naming the type.

    The D-1 regression is pinned directly: a well-formed epic or parallel
    checkpoint that carries none of the standard checkpoint's REQUIRED_STATE_KEYS
    must NOT produce a ROUTING_CONTRACT_BLOCKED verdict, and the model-routing gate
    must not run against it.

    This suite is intended as a behavioral oracle for the eventual bash migration of
    the hook surface (AC-24): every assertion is expressed against observable
    verdicts and exit codes, never against PowerShell-specific internals.

    No temporary files are created. Structural fixtures are either injected through
    the mocked Get-OrchestratorStateCheckpoint load boundary or are read-only files
    that already exist in the repository. No test mutates PATH, probes a live
    executable, or defines a shadow interpreter function.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected routing stubs mirror the production $Invoker scriptblock signature param($Path, $Type) for testing')]
param()

BeforeAll {
    # Dot-source the hook so its helper functions are exercisable without running
    # the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath

    # Pre-import the portable completion module so Test-OrchestratorStateCompletionReadiness
    # is a resolvable command the default invoker's guarded import reuses and that
    # these tests can mock.
    $script:CompletionModulePath = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1").Path
    Import-Module $script:CompletionModulePath -Force

    # The U-family aggregator and the U6.H family entry point, for the AC-25
    # both-layers assertions.
    $script:UnconditionalModulePath = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1").Path
    Import-Module $script:UnconditionalModulePath -Force
    $script:ReceiptsModulePath = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1").Path
    Import-Module $script:ReceiptsModulePath -Force

    # Each of the modules above performs its own nested Import-Module of
    # OrchestratorState.psm1 during its load, and a nested import inside a .psm1
    # drops this scope's visibility of that module's exported commands. Re-importing
    # it LAST restores visibility of Get-OrchestratorStateCheckpoint, which the
    # hook's structural leg calls unqualified from script scope and which the
    # structural fixtures below mock.
    $script:OrchestratorStateModulePath = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorState.psm1").Path
    Import-Module $script:OrchestratorStateModulePath -Force

    # Read-only repository fixtures. Neither file is written by this suite.
    #   - A path that deliberately does not exist, for the missing-file leg.
    #   - An existing non-JSON leaf file, for the invalid-JSON leg.
    $script:MissingCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.nonexistent-fixture.json'
    $script:NonJsonFixturePath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
}

Describe 'validate-orchestrator-output.ps1 $ArtifactType dispatch' {

    Context 'orchestrator-state routes to the complete-parity completion validation' {
        It 'invokes the completion entry point and reports its clean verdict' {
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/path.json' -ArtifactType 'orchestrator-state'

            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -BeNullOrEmpty
            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 1 -Exactly
        }

        It 'surfaces the completion entry point failure text unchanged' {
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith {
                @{ ExitCode = 1; Output = 'Checkpoint missing required key: plan-path' }
            }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/path.json' -ArtifactType 'orchestrator-state'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Be 'Checkpoint missing required key: plan-path'
        }

        It 'uses the orchestrator-state leg when no ArtifactType is supplied' {
            # The parameter default must keep every existing caller of this hook on
            # the standard-checkpoint leg.
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $null = Invoke-RoutingContractValidation -CheckpointPath 'any/path.json'

            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 1 -Exactly
        }
    }

    Context 'epic-orchestrator-state and parallel-orchestrator-state route to the structural check (PD-3)' {
        BeforeEach {
            # Detect any leak of the standard-checkpoint leg into the epic/parallel
            # legs: the completion validation must never run for these types.
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith { @{ ExitCode = 1; Output = 'completion leg must not run' } }
        }

        It 'accepts a well-formed epic checkpoint that carries none of the standard required keys' {
            # D-1 regression. The fixture is valid JSON with an object root and holds
            # only epic-shaped fields; applying REQUIRED_STATE_KEYS to it would emit a
            # long missing-key list and produce a false ROUTING_CONTRACT_BLOCKED.
            Mock -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{
                    Ok    = $true
                    State = ('{"epic_slug":"demo-epic","waves":[],"features":[],"current_wave":0}' | ConvertFrom-Json)
                    Error = ''
                }
            }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/epic.json' -ArtifactType 'epic-orchestrator-state'

            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -BeNullOrEmpty
            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 0 -Exactly
        }

        It 'accepts a well-formed parallel checkpoint that carries none of the standard required keys' {
            Mock -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{
                    Ok    = $true
                    State = ('{"parallel_slug":"demo","mode":"closed","max_concurrency":4,"items":[]}' | ConvertFrom-Json)
                    Error = ''
                }
            }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/parallel.json' -ArtifactType 'parallel-orchestrator-state'

            $result.HasErrors | Should -BeFalse
            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 0 -Exactly
        }

        It 'does not run the model-routing gate for an epic checkpoint with no routing receipts' {
            # The epic/parallel legs must not emit model_routing_receipts or
            # complexity_assessments text, because those keys belong to the standard
            # checkpoint. A leak would misroute the hook to MODEL_ROUTING_BLOCKED.
            Mock -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{
                    Ok    = $true
                    State = ('{"epic_slug":"demo-epic","next_step":"atomic-executor"}' | ConvertFrom-Json)
                    Error = ''
                }
            }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/epic.json' -ArtifactType 'epic-orchestrator-state'

            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -Not -Match 'model_routing_receipts|complexity_assessments'
        }

        It 'denies a missing epic checkpoint (fail closed)' {
            $result = Invoke-RoutingContractValidation -CheckpointPath $script:MissingCheckpointPath -ArtifactType 'epic-orchestrator-state'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'does not exist'
        }

        It 'denies a missing parallel checkpoint (fail closed)' {
            $result = Invoke-RoutingContractValidation -CheckpointPath $script:MissingCheckpointPath -ArtifactType 'parallel-orchestrator-state'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'does not exist'
        }

        It 'denies a JSON-invalid checkpoint of an epic type (fail closed)' {
            # The fixture is an existing, read-only repository file that is not JSON.
            $result = Invoke-RoutingContractValidation -CheckpointPath $script:NonJsonFixturePath -ArtifactType 'epic-orchestrator-state'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'not valid JSON'
        }

        It 'denies a non-object JSON root for a parallel checkpoint (fail closed)' {
            Mock -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{
                    Ok    = $false
                    State = $null
                    Error = "Checkpoint file 'any/parallel.json' root must be a JSON object."
                }
            }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/parallel.json' -ArtifactType 'parallel-orchestrator-state'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'root must be a JSON object'
        }
    }

    Context 'an unsupported artifact type fails closed' {
        It 'denies an unwired type and names it in the error text' {
            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/path.json' -ArtifactType 'not-a-real-artifact-type'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'unsupported artifact type'
            $result.ErrorText | Should -Match 'not-a-real-artifact-type'
        }

        It 'denies an empty artifact type rather than defaulting to a validated leg' {
            $result = Invoke-RoutingContractValidation -CheckpointPath 'any/path.json' -ArtifactType ''

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'unsupported artifact type'
        }
    }

    Context 'the hook threads its -ArtifactType parameter into the dispatch' {
        BeforeEach {
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-08-15T00-00"}'
                }
            }
        }

        It 'passes the requested artifact type through to the routing invoker' {
            $script:ObservedType = $null
            $routingStub = {
                param($Path, $Type)
                $script:ObservedType = $Type
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            $result = Invoke-OrchestratorOutputValidation `
                -RawPayload '{"output":"Final summary."}' `
                -ArtifactType 'parallel-orchestrator-state' `
                -RoutingInvoker $routingStub

            $result.Ok | Should -BeTrue
            $script:ObservedType | Should -Be 'parallel-orchestrator-state'
        }
    }

    Context 'human_interaction is validated by both layers (AC-25, strictness is additive)' {
        It 'executes the hook-internal Test-HumanInteractionShape on the checkpoint path' {
            # Layer 1 in the live path: a halt response blocks with the hook-internal
            # message before the routing dispatch is reached.
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"o","completed_steps":[],"next_step":"complete","last_updated":"2026-08-15T00-00","human_interaction":{"requirements":[{"response":"halt"}]}}'
                }
            }
            $script:RoutingReached = $false
            $routingStub = {
                param($Path, $Type)
                $script:RoutingReached = $true
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload '{"output":"Final summary."}' -RoutingInvoker $routingStub

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "DONE is blocked while a halt is present"
            $script:RoutingReached | Should -BeFalse -Because 'layer 1 short-circuits before the dispatch'
        }

        It 'executes the library U6.H checks through the U-family aggregator the dispatch runs' {
            # Layer 2 in the live path: the orchestrator-state leg runs the completion
            # validation, which composes Get-OrchestratorStateUnconditionalError, which
            # carries the U6.H family. A non-list requirements value is a U6.H error.
            $state = '{"human_interaction":{"requirements":{"not":"a list"}}}' | ConvertFrom-Json

            $errors = @(Get-OrchestratorStateUnconditionalError -State $state)

            $errors | Should -Contain 'Checkpoint human_interaction.requirements must be a list.'
        }

        It 'has both layers reject the same malformed block, so neither layer relaxes the other' {
            # One input, two independent rejections: the hook-internal layer reports
            # its own message and the library layer reports the U6.H message. The
            # library is additive to the stricter hook-internal check.
            $humanInteraction = '{"requirements":{"not":"a list"}}' | ConvertFrom-Json

            $layerOne = Test-HumanInteractionShape -HumanInteraction $humanInteraction
            $layerTwo = @(Get-OrchestratorStateHumanInteractionError -Value $humanInteraction)

            $layerOne.Ok | Should -BeFalse
            $layerTwo | Should -Contain 'Checkpoint human_interaction.requirements must be a list.'
        }

        It 'keeps the hook-internal layer strictly stronger for a halt the library enum permits' {
            # halt is a member of the library's response enum, so layer 2 accepts it;
            # layer 1 blocks it. Strictness never decreases when the layers combine.
            $humanInteraction = '{"requirements":[{"response":"halt"}]}' | ConvertFrom-Json

            $layerOne = Test-HumanInteractionShape -HumanInteraction $humanInteraction
            $layerTwo = @(Get-OrchestratorStateHumanInteractionError -Value $humanInteraction)

            $layerOne.Ok | Should -BeFalse
            $layerTwo | Should -BeNullOrEmpty
        }
    }
}
