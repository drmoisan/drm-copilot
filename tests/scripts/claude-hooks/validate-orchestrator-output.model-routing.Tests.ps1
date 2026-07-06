#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the model-routing additions to the
    validate-orchestrator-output.ps1 SubagentStop hook. Kept in a sibling file
    because the primary test file is already at the 500-line cap.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected routing stubs mirror the production $Invoker scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
}

Describe 'validate-orchestrator-output.ps1 model-routing gate' {
    Context 'default routing invoker threads --require-model-routing' {
        It 'passes both --require-complete and --require-model-routing to the Python CLI' {
            # The default $Invoker scriptblock is embedded in the function source;
            # assert both flags are threaded so one subprocess covers both gates.
            $source = ${function:Invoke-RoutingContractValidation}.Ast.Extent.Text
            $source | Should -Match '--require-complete'
            $source | Should -Match '--require-model-routing'
        }
    }

    Context 'MODEL_ROUTING_BLOCKED surfacing' {
        BeforeEach {
            # A structurally valid checkpoint so the routing seam is the deciding
            # factor.
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-07-04T00-00"}'
                }
            }
        }

        It 'blocks DONE with MODEL_ROUTING_BLOCKED when the validator names model_routing_receipts' {
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path)
                [pscustomobject]@{
                    ExitCode = 1
                    Output   = 'Checkpoint model_routing_receipts is missing a receipt for delegated agent: atomic-executor.'
                }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '^MODEL_ROUTING_BLOCKED:'
            $result.Message | Should -Match 'atomic-executor'
        }

        It 'blocks DONE with MODEL_ROUTING_BLOCKED when the validator names complexity_assessments' {
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path)
                [pscustomobject]@{
                    ExitCode = 1
                    Output   = 'Checkpoint complexity_assessments is missing an entry for phase 7 referenced by a model_routing_receipts entry.'
                }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '^MODEL_ROUTING_BLOCKED:'
        }

        It 'falls back to ROUTING_CONTRACT_BLOCKED for a generic routing error' {
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path)
                [pscustomobject]@{
                    ExitCode = 1
                    Output   = 'Checkpoint selected route is not a routing-matrix route: bogus_route.'
                }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '^ROUTING_CONTRACT_BLOCKED:'
        }
    }

    Context 'capability detection (portable-path routing)' {
        BeforeAll {
            # Pre-import the portable completion module so
            # Test-OrchestratorStateCompletionReadiness is a resolvable command that the
            # default invoker's guarded import reuses and that tests can mock.
            $portableModule = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1").Path
            Import-Module $portableModule -Force
        }

        BeforeEach {
            # A structurally valid checkpoint so the routing seam is the deciding factor
            # for the hook's own base validation.
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-07-04T00-00"}'
                }
            }
        }

        It 'surfaces MODEL_ROUTING_BLOCKED via the portable path for an uncovered delegated agent when the probe reports unavailable' {
            # Probe reports the Python validator unavailable, so the default invoker
            # routes to the portable completion seam, which reports a missing routing
            # receipt; the hook maps it to MODEL_ROUTING_BLOCKED.
            Mock -CommandName Test-PythonOrchestratorValidatorAvailable -MockWith { $false }
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith {
                @{ ExitCode = 1; Output = 'Checkpoint model_routing_receipts is missing a receipt for delegated agent: atomic-executor.' }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload '{"output":"Final summary."}'

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '^MODEL_ROUTING_BLOCKED:'
            $result.Message | Should -Match 'atomic-executor'
            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 1 -Exactly
        }

        It 'does not block a covered checkpoint on the portable path when the probe reports unavailable' {
            # Probe reports unavailable and the portable completion seam reports a clean
            # checkpoint (ExitCode 0, no output), so DONE is not blocked.
            Mock -CommandName Test-PythonOrchestratorValidatorAvailable -MockWith { $false }
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith {
                @{ ExitCode = 0; Output = '' }
            }

            $result = Invoke-OrchestratorOutputValidation -RawPayload '{"output":"Final summary."}'

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }
}
