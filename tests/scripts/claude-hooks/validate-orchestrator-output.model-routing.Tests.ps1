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
}
